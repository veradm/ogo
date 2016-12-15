function varargout = GUIO(varargin)
% GUIO MATLAB code for GUIO.fig
%      GUIO, by itself, creates a new GUIO or raises the existing
%      singleton*.
%
%      H = GUIO returns the handle to a new GUIO or the handle to
%      the existing singleton*.
%
%      GUIO('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GUIO.M with the given input arguments.
%
%      GUIO('Property','Value',...) creates a new GUIO or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before GUIO_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to GUIO_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help GUIO

% Last Modified by GUIDE v2.5 15-Dec-2016 15:30:11

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @GUIO_OpeningFcn, ...
                   'gui_OutputFcn',  @GUIO_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


function GUIO_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   unrecognized PropertyName/PropertyValue pairs from the
%            command line (see VARARGIN)
% This creates the 'background' axes
ha = axes('units','normalized','position',[0 0 1 1]);

% Move the background axes to the bottom
uistack(ha,'bottom');

% Load in a background image and display it using the correct colors
% The image used below, is in the Image Processing Toolbox.  If you do not have %access to this toolbox, you can use another image file instead.
I=imread('GUI picture.png');
hi = imagesc(I);
colormap gray;

% Turn the handlevisibility off so that we don't inadvertently plot into the axes again
% Also, make the axes invisible
set(ha,'handlevisibility','on','visible','off')
% Choose default command line output for GUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes GUIO wait for user response (see UIRESUME)
%uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = GUIO_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure

s.c=get(handles.speed,'Value');
s.density=get(handles.density,'Value');
s.acoeff=get(handles.attenuation,'Value');
s.distance=get(handles.cmbetween,'Value');
s.nrays=get(handles.nrrays,'Value');
s.frequency=get(handles.frequency,'Value');

varargout{1} = s;

%uiwait(handles.figure1)


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
s.c=get(handles.speed,'Value');
s.density=get(handles.density,'Value');
s.acoeff=get(handles.attenuation,'Value');
s.distance=get(handles.cmbetween,'Value');
s.nrays=get(handles.nrrays,'Value');
s.frequency=get(handles.frequency,'Value');
output=s;
assignin('base','output',output)
%close(gcf)




% --- Executes on selection change in Initialpower.
function Initialpower_Callback(hObject, eventdata, handles)
% hObject    handle to Initialpower (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
indexChoice = get(hObject,'Value');
strChoices = get(hObject,'String');
strChoice=strChoices{indexChoice};
switch strChoice;
    case '100 Watt'
        Power = 100;
    case '150 Watt'
        Power = 150;
    case '200 Watt'
        Power = 200;
end
assignin('base','power',Power)

% Hints: contents = cellstr(get(hObject,'String')) returns Initialpower contents as cell array
%        contents{get(hObject,'Value')} returns selected item from Initialpower


% --- Executes during object creation, after setting all properties.
function Initialpower_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Initialpower (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function frequency_Callback(hObject, eventdata, handles)
% hObject    handle to frequency (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of frequency as text
%        str2double(get(hObject,'String')) returns contents of frequency as a double


% --- Executes during object creation, after setting all properties.
function frequency_CreateFcn(hObject, eventdata, handles)
% hObject    handle to frequency (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function nrrays_Callback(hObject, eventdata, handles)
% hObject    handle to nrrays (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of nrrays as text
%        str2double(get(hObject,'String')) returns contents of nrrays as a double


% --- Executes during object creation, after setting all properties.
function nrrays_CreateFcn(hObject, eventdata, handles)
% hObject    handle to nrrays (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on slider movement.
function slider1_Callback(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

sliderval = handles.slider1.Value;
set(handles.cmbetween,'String',sliderval)
set(handles.cmbetween,'Value',sliderval)
s.distance=get(handles.cmbetween,'Value');


% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function slider1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

function speed_Callback(hObject, eventdata, handles)
% hObject    handle to speed (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
c=str2double(get(hObject,'String'));
set(handles.speed,'Value',c)
s.c=get(handles.speed,'Value');

% Hints: get(hObject,'String') returns contents of speed as text
%        str2double(get(hObject,'String')) returns contents of speed as a double


% --- Executes during object creation, after setting all properties.
function speed_CreateFcn(hObject, eventdata, handles)
% hObject    handle to speed (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function density_Callback(hObject, eventdata, handles)
% hObject    handle to density (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
density=str2double(get(hObject,'String'));
set(handles.density,'Value',density);
s.density=get(handles.density,'Value');

% Hints: get(hObject,'String') returns contents of density as text
%        str2double(get(hObject,'String')) returns contents of density as a double


% --- Executes during object creation, after setting all properties.
function density_CreateFcn(hObject, eventdata, handles)
% hObject    handle to density (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function eenheiddichtheid_Callback(hObject, eventdata, handles)
% hObject    handle to eenheiddichtheid (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of eenheiddichtheid as text
%        str2double(get(hObject,'String')) returns contents of eenheiddichtheid as a double


% --- Executes during object creation, after setting all properties.
function eenheiddichtheid_CreateFcn(hObject, eventdata, handles)
% hObject    handle to eenheiddichtheid (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function attenuation_Callback(hObject, eventdata, handles)
% hObject    handle to attenuation (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
acoeff=str2double(get(hObject,'String'));
if acoeff<=0
    mode=struct('WindowStyle','nonmodal',...
        'Interpreter','tex');
    h=errordlg('Too small value',...
        'Value Error',mode);
end
if acoeff>=10
    mode=struct('WindowStyle','nonmodal',...
        'Interpreter','tex');
    h=errordlg('Too big value',...
        'Value Error',mode);
end 
set(handles.attenuation,'Value',acoeff);
s.acoeff=get(handles.attenuation,'Value');

% Hints: get(hObject,'String') returns contents of attenuation as text
%        str2double(get(hObject,'String')) returns contents of attenuation as a double


% --- Executes during object creation, after setting all properties.
function attenuation_CreateFcn(hObject, eventdata, handles)
% hObject    handle to attenuation (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function grootheiddensity_Callback(hObject, eventdata, handles)
% hObject    handle to grootheiddensity (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of grootheiddensity as text
%        str2double(get(hObject,'String')) returns contents of grootheiddensity as a double


% --- Executes during object creation, after setting all properties.
function grootheiddensity_CreateFcn(hObject, eventdata, handles)
% hObject    handle to grootheiddensity (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in cmbetween.
function cmbetween_Callback(hObject, eventdata, handles)
% hObject    handle to cmbetween (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
editval=str2double(get(hObject,'String'));
set(handles.slider1,'Value',editval)
set(handles.cmbetween,'Value',editval)
s.distance=get(handles.cmbetween,'Value');
% Hints: get(hObject,'String') returns contents of cmbetween as text
%        str2double(get(hObject,'String')) returns contents of cmbetween as a double


% --- Executes during object creation, after setting all properties.
function cmbetween_CreateFcn(hObject, eventdata, handles)
% hObject    handle to cmbetween (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
