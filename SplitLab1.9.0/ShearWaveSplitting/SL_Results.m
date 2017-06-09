function SL_Results
%Related functions: SL_Results_makeplots.m SL_Results_getvalues.m twolayermodel.m stereoplot.m
global eq


%% check if project/results are not empty
if isempty(eq)
    errordlg('Project appears to be empty...! Sorry', 'No database');
    return 
end

x=zeros(1,length(eq));
for i = 1 : length(eq)
    x(i)=~isempty(eq(i).results);
end
%res = find(x==1) ;
if isempty(find(x==1,1))
    errordlg('Project does not contain any results! Sorry', 'No Results');
    return
end

%define default style of theoretic line:
defcol   = [0 .6 0];
defwidth = 0.5;
defstyle = '.';


%% CREATE DIALOG
Plist={'P','Pdiff','PP','PPP','PcP','PcS','ScS','ScP','PS','SP',...
    'S','Sdiff','SS','SKP','PKS','SKS','SKiKS','sSKS','pSKS', ...
    'pP', 'sP', 'pS', 'sS','PKKP', 'PKKS','SKKS', 'SKKP'};

if ispref('Splitlab','RV_figpos')
    figpos = getpref('Splitlab','RV_figpos');
else
    S=get(0,'ScreenSize');
    figpos = [30 S(4)-450 420 380];
end

% check if window already open
fig = findobj('Tag','ResultViewer Options');
if isempty(fig)
    fig = figure('Position',figpos,...
                 'NumberTitle','off',...
                 'Name','ResultViewer Options',...
                 'CloseRequestFcn',@my_closereq,...
                 'Tag','ResultViewer Options',...
                 'Toolbar','None',...
                 'menubar','none');

    setappdata(fig, 'phases',  [Plist(15) Plist(16) Plist(17) Plist(18) Plist(19) Plist(25) Plist(26)] )
    setappdata(fig, 'method', 'Manual')
    setappdata(fig, 'Quality', [1 1 1])
    setappdata(fig, 'Nulls',   [1 1])
    setappdata(fig, 'NullLines', 0)
    setappdata(fig, 'theoLines', 1)
    setappdata(fig, 'period', 8)
    setappdata(fig, 'PlotErrors', 1)
    
    set(fig,'Color', get(0, 'DefaultUIcontrolBackgroundColor'));
else
    uistack(fig, 'top');
end


%% Phase List on the left
uicontrol('Units','pixel',...
    'Style','List','Min',1,'Max',20,...
    'BackgroundColor','w',...
    'Position',[15 15 70 figpos(4)-30],...
    'Value',[15 16 17 18 19 25 26],...
    'String', Plist,...
    'Callback','val=get(gcbo,''Value''); str=get(gcbo,''String'');setappdata(gcbf,''phases'', str(val)); clear str val');


%% Pushbuttons
button1  =  uicontrol('Units','pixel',...
    'Style','pushbutton',...
    'pos',[110 115 80 20],...
    'String', 'Split again',...
    'Callback',@questioncallback);

button2  =  uicontrol('Units','pixel',...
    'Style','Pushbutton',...
    'Position',[110 90 80 20],...
    'String', 'Plot',...
    'Callback',@LocalOKCallback);

% button3 =  uicontrol('Units','pixel',...
%     'Style','Pushbutton',...
%     'Position',[110 40 80 20],...
%     'String', 'Save Figure',...
%     'Callback',@localSavePicture);

button4 =  uicontrol('Units','pixel',...
    'Style','Pushbutton',...
    'Position',[110 65 80 20],...
    'String', 'Stack W&S',...
    'Callback',@(hObject,callbackdata)splitWolfeSilver);

button5 =  uicontrol('Units','pixel',...
   'Style','Pushbutton',...
   'Position',[110 40 80 20],...
   'String', 'Stack S&C',...
   'Callback',@(hObject,callbackdata)splitSilverChan);

button6 =  uicontrol('Units','pixel',...
   'Style','Pushbutton',...
   'Position',[110 15 80 20],...
   'String', 'Stack Chev',...
   'Callback',@(hObject,callbackdata)splitChevrot);


%%
r1 = uicontrol('Units','pixel',...
    'Style','Radio',...
    'Position',[90 300 120 20],...
    'String', 'Manual Quality',...
    'Value', 1,...
    'CallBack','set(get(gcbo,''Userdata''), ''Value'',0);  setappdata(gcbf,''method'',''Manual'')');
r2 = uicontrol('Units','pixel',...
    'Style','Radio',...
    'Position',[90 280 120 20],...
    'String', 'Automatic Quality',...
    'Value', 0,...
    'CallBack','set(get(gcbo,''Userdata''), ''Value'',0);  setappdata(gcbf,''method'',''Automatic'')');
set(r1,'Userdata',r2)
set(r2,'Userdata',r1)

uicontrol('Units','pixel', 'Style','checkbox',...
    'Position',[110 250 100 20], 'Value', 1, 'String', 'good',...
    'CallBack',' Q = getappdata(gcbf,''Quality'');Q(1) = get(gcbo,''Value'');  setappdata(gcbf,''Quality'',Q); clear Q');
uicontrol('Units','pixel', 'Style','checkbox',...
    'Position',[110 230 100 20], 'Value', 1, 'String', 'fair',...
    'CallBack',' Q = getappdata(gcbf,''Quality'');Q(2) = get(gcbo,''Value'');  setappdata(gcbf,''Quality'',Q); clear Q');
uicontrol('Units','pixel', 'Style','checkbox',...
    'Position',[110 210 100 20], 'Value', 1, 'String', 'poor',...
    'CallBack',' Q = getappdata(gcbf,''Quality'');Q(3) = get(gcbo,''Value'');  setappdata(gcbf,''Quality'',Q); clear Q');

uicontrol('Units','pixel', 'Style','checkbox',...
    'Position',[110 175 100 20], 'Value', 1, 'String', 'Nulls',...
    'CallBack',' N = getappdata(gcbf,''Nulls'');N(1) = get(gcbo,''Value'');  setappdata(gcbf,''Nulls'',N); clear N');
uicontrol('Units','pixel', 'Style','checkbox',...
    'Position',[110 155 100 20], 'Value', 1, 'String', 'Non Nulls',...
    'CallBack',' N = getappdata(gcbf,''Nulls'');N(2) = get(gcbo,''Value'');  setappdata(gcbf,''Nulls'',N); clear N');

% uicontrol('Units','pixel', 'Style','checkbox',...
%     'Position',[90 330 100 20], 'Value', 1, 'String', 'Show "Null grid"',...
%     'CallBack','W = get(gcbo,''Value'');  setappdata(gcbf,''NullLines'',W); clear W');
uicontrol('Units','pixel', 'Style','checkbox',...
    'Position',[90 335 120 20], 'Value', 1, 'String', 'Show Error Bars',...
    'CallBack','W = get(gcbo,''Value'');  setappdata(gcbf,''PlotErrors'',W); clear W');


%% Theroretic line GUI section
HP = uipanel('Units','pixel','Title','Fit to Model', 'FontSize',10,'Position',[220 10 195 360]);
handles.show=uicontrol('Units','pixel', 'Style','checkbox','Parent',HP,...
    'Position',[10 320 100 20], 'Value', 1, 'String', 'Show lines',...
    'CallBack',@showlines);
export=  uicontrol('Units','pixel',...
    'Style','Pushbutton',...
    'Position',[120 320 65 20],...
    'String', 'Export','Parent',HP,...
    'Callback',@ExportTheoLines);


handles.Layer1Phi = uicontrol('Units','pixel', 'Style','slider','Parent',HP,'Callback', @L1phiCallback,...
    'Position',[10 235 175 15], 'Value', 0, 'Min',-90,'Max',90, 'SliderStep', [1/180 1/12]);
handles.Layer1phitxt = uicontrol('Units','pixel', 'Style','text','Parent',HP,...
    'Position',[10 218 175 15],  'String', ['0' char(186)]);
uicontrol('Units','pixel', 'Style','text','Parent',HP,...
    'Position',[10 250 175 15], 'String', 'lower layer fast axis');

handles.Layer2Phi = uicontrol('Units','pixel', 'Style','slider','Parent',HP,'Callback', @L2phiCallback,...
    'Position',[10 280 175 15], 'Value', 0, 'Min',-90,'Max',90, 'SliderStep', [1/180 1/12]);
handles.Layer2phitxt = uicontrol('Units','pixel', 'Style','text','Parent',HP,...
    'Position',[10 263 175 15], 'String', ['0' char(186)]);
uicontrol('Units','pixel', 'Style','text','Parent',HP,...
    'Position',[10 297 175 15], 'String', 'upper layer fast axis');
%%%%%%%% DT
handles.Layer1dt = uicontrol('Units','pixel', 'Style','slider','Parent',HP,'Callback', @L1dtCallback,...
    'Position',[10 125 175 15], 'Value', 2,'Min',0,'Max',4, 'SliderStep', [.025 .1]);
handles.Layer1dttxt = uicontrol('Units','pixel', 'Style','text','Parent',HP,...
    'Position',[10 108 175 15], 'String', '2 sec');
uicontrol('Units','pixel', 'Style','text','Parent',HP,...
    'Position',[10 140 175 15], 'String', 'lower layer delay time');

handles.Layer2dt = uicontrol('Units','pixel', 'Style','slider','Parent',HP,'Callback', @L2dtCallback,...
    'Position',[10 170 175 15], 'Value', 0,'Min',0,'Max',4, 'SliderStep', [.025 .1] );
handles.Layer2dttxt = uicontrol('Units','pixel', 'Style','text','Parent',HP,...
    'Position',[10 153 175 15], 'String', '0 sec');
uicontrol('Units','pixel', 'Style','text','Parent',HP,...
    'Position',[10 185 175 15], 'String', 'upper layer delay time');


%%%%%%%%%%%%%%%%%  dominant frequency
handles.period = uicontrol('Units','pixel', 'Style','slider','Parent',HP,'Callback', @periodCallback,...
    'Position',[10 60 175 15], 'Value', 8,'Min',0,'Max',20, 'SliderStep', [1/20 .06] );
handles.periodtxt = uicontrol('Units','pixel', 'Style','text','Parent',HP,...
    'Position',[10 43 175 15], 'String', '8 sec');
uicontrol('Units','pixel', 'Style','text','Parent',HP,...
    'Position',[10 75 175 15], 'String', 'dominant frequency of signal');


%%%%%%%%%%%%%% Buttons
handles.color = uicontrol('Units','pixel', 'Style','pushbutton','Parent',HP,'Callback', @LocalSetColor,...
    'Position',[10 10 70 20], 'String', 'Line Color',  'UserData', defcol);

handles.style = uicontrol('Units','pixel', 'Style','popupmenu','Parent',HP,'Callback', @LocalSetLineStyle,...
    'Position',[78 10 57 20],'BackgroundColor','w', 'String', { '.' '-' '--' ':'}, 'UserData', defstyle );

handles.width = uicontrol('Units','pixel', 'Style','popupmenu','Parent',HP,'Callback', @LocalSetLinewidth,...
    'Position',[126 10 65 20], 'BackgroundColor','w','String', {'0.5' '1' '1.5' '2'}, 'UserData', defwidth );

handles.theoLines = [];
guidata(fig, handles)


%% SUBFUNCTIONS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function LocalOKCallback(src,evt)
out = SL_Results_getvalues;
if isempty(out)
    return
end
handles = guidata(gcbf);

SL_Results_makeplots(out.good, out.fair, out.poor, out.goodN, out.fairN,  ...
    out.evt, out.back, out.strikes, out.phiSC, out.dtSC, out.phiRC, out.dtRC,...
    out.phiEV, out.dtEV, out.Omega, out.inc, out.Phas );


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function showlines(scr,evt)
handles = guidata(gcbf);
W = get(gcbo,'Value');
setappdata(gcbf,'theoLines',W);

H= [handles.Layer1Phi handles.Layer2Phi handles.Layer1dt handles.Layer2dt];

if get(handles.show, 'Value');
    set(handles.theoLines(:), 'Visible', 'on')
    set(H, 'Enable', 'on')

else
    set(handles.theoLines(:), 'Visible', 'off')
    set(H, 'Enable', 'off')
    %      set(obj.Null,  'Visible', 'off')
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function LocalSetColor(src,evt)
handles = guidata(gcbf);

C =uisetcolor;
set(handles.theoLines(:), 'Color', C)
set(handles.color, 'Userdata', C)


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function LocalSetLineStyle(src,evt)
handles = guidata(gcbf);

val=get(gcbo,'Value');
str=get(gcbo, 'String');

if strcmp(str{val},'.')
    set(handles.theoLines(:),    'LineStyle', 'none',   'Marker','.',   'MarkerSize',3)
else
    set(handles.theoLines(:), 'LineStyle', str{val},'Marker','none')
end
set(handles.style, 'Userdata', str{val})


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function LocalSetLinewidth(src,evt)
handles = guidata(gcbf);

width = get(gcbo,'Value')*.5;
set(handles.theoLines(:), 'LineWidth', width)
set(handles.width, 'UserData', width)


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function periodCallback(src,evt)
handles = guidata(gcbf);
val =round(get(gcbo, 'Value'));
if val==0
    val=.1;
end
set(handles.periodtxt,'String', [num2str(val) ' sec']);
set(gcbo,'Value',val)
if ~isempty(handles.theoLines)
    drawTheoreticLines
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function L1phiCallback(src,evt)
handles = guidata(gcbf);
val =round(get(gcbo, 'Value'));
set(handles.Layer1phitxt,'String', [num2str(val) char(186)]);
set(gcbo,'Value',val)
if ~isempty(handles.theoLines)
    drawTheoreticLines
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function L2phiCallback(src,evt)
handles = guidata(gcbf);
val =round(get(gcbo, 'Value'));
set(handles.Layer2phitxt,'String', [num2str(val) char(186)]);
set(gcbo,'Value',val)
if ~isempty(handles.theoLines)
    drawTheoreticLines
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function L1dtCallback(src,evt)
handles = guidata(gcbf);
val =round(get(gcbo, 'Value')*10)/10;
set(handles.Layer1dttxt,'String', [num2str(val) ' sec']);
set(gcbo,'Value',val)
if ~isempty(handles.theoLines)
    drawTheoreticLines
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function L2dtCallback(src,evt)
handles = guidata(gcbf);
val =round(get(gcbo, 'Value')*10)/10;
set(handles.Layer2dttxt,'String', [num2str(val) ' sec']);
set(gcbo,'Value',val)
if ~isempty(handles.theoLines)
    drawTheoreticLines
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function ExportTheoLines(src,evt)
global config
handles = guidata(gcbf);

Bazi = get(handles.theoLines(1,1), 'Xdata');
Phi  = get(handles.theoLines(1,1), 'Ydata');
Dt   = get(handles.theoLines(1,2), 'Ydata');
defFname= fullfile( config.savedir, [config.project(1:end-4) '_2layerFit.txt' ]);


[filename, pathname] = uiputfile('*.txt', 'Search result plot', defFname);
if ~isequal(filename,0)
    p1  = get(handles.Layer1Phi, 'Value' );
    p2  = get(handles.Layer2Phi, 'Value' );
    dt1 = get(handles.Layer1dt,  'Value' );
    dt2 = get(handles.Layer2dt,  'Value' );

    fid=fopen(fullfile(pathname, filename ),'w');
    fprintf(fid, ['Upper Layer: Phi=%3.0f' char(186) '  dt=%3.1fsec\n'], p1, dt1);
    fprintf(fid, ['Lower Layer: Phi=%3.0f' char(186) '  dt=%3.1fsec\n'], p2, dt2);

    fprintf(fid, 'Bazi\tPhi\tdt\n');
    fprintf(fid, '%5.1f\t%7.2f\t%5.2f\n',[Bazi(:) Phi(:) Dt(:)]'  );
    fclose(fid);
end
disp('Backazimuthal variation successfully exported:')
disp(fullfile(pathname, filename))


% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function localSavePicture(hFig,evt)
% global config thiseq
% 
% tit =['Results of ' config.project ];
% fig = findobj('type', 'figure','Name', tit);
% 
% if isempty(fig)
%     errordlg(['Sorry, no Result Figure found with title:' tit])
% else
%     defaultname = [config.project(1:end-4) '_ResultPlot' config.exportformat];
%     exportfiguredlg(fig, defaultname, config.savedir, config.exportresolution)
% end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function questioncallback(src,evt)
choice = questdlg('Continue to split again automatically all measurements yet performed for this project?', ...
	'Split Again', ...
	'Ok', 'Cancel', 'Cancel');

switch choice
    case 'Ok'
        splitagain;
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function my_closereq(src,evt)
    result    = findobj('type','figure', 'Tag','ResultViewer Options');
    RV_figpos = get(result,'Position');
    setpref( 'Splitlab','RV_figpos',RV_figpos );
    delete(result);
    
    