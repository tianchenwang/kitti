function varargout = kitti(varargin)
% KITTI MATLAB code for kitti.fig
%      KITTI, by itself, creates a new KITTI or raises the existing
%      singleton*.
%
%      H = KITTI returns the handle to a new KITTI or the handle to
%      the existing singleton*.
%
%      KITTI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in KITTI.M with the given input arguments.
%
%      KITTI('Property','Value',...) creates a new KITTI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before kitti_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to kitti_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help kitti

% Last Modified by GUIDE v2.5 30-May-2016 17:18:47

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @kitti_OpeningFcn, ...
                   'gui_OutputFcn',  @kitti_OutputFcn, ...
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


% --- Executes just before kitti is made visible.
function kitti_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to kitti (see VARARGIN)

% Choose default command line output for kitti
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes kitti wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = kitti_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[pic_name,pic_filename]=uigetfile('*.*','open');
pic_directory=strcat(pic_filename,pic_name);
set(handles.text2,'String',pic_directory);
% h=figure;
% setappdata(h,'pic_name',pic_name);
% setappdata(h,'pic_filename',pic_filename);


% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
detection_directory=uigetdir;
% setappdata(h,'detection_directory',detection_directory);
set(handles.text5,'String',detection_directory);

% --- Executes on button press in pushbutton4.
function pushbutton4_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
pic_directory=get(handles.text2,'String');
detection_directory=get(handles.text5,'String');
pic_name=regexp(pic_directory,'\\','split');
pic_name=char(pic_name(end));
pic_name=regexp(pic_name,'\.','split');
detection_label_directory=strcat(char(pic_name(1)),'.txt');
detection_label_directory=strcat(detection_directory,'\',detection_label_directory);
fid=fopen(detection_label_directory,'r');
file_contents=fscanf(fid,'%c',inf);
fclose(fid);
file_contents=regexp(file_contents,'\n','split');
len=length(file_contents);
index=1;
while(index<=len)
	if((~isempty(strfind(char(file_contents(index)),'DontCare')))|isempty(char(file_contents(index))))
		file_contents(index)=[];
		len=len-1;
	else
		index=index+1;
	end
end
% clear index;
img=imread(pic_directory);
for i=1:len
	str=char(file_contents(i));
	str=regexp(str,' ','split');
	tag=char(str(1));
	str=str(2:2+4-1);
    mat=char(str);
    mat=str2num(mat(1:4,:));
    img=draw_box(img,tag,mat(1),mat(2),mat(3),mat(4));
end
imshow(img);
% if(exist(pic_directory))
% 	img=imread(pic_directory);
% 	imshow(img);
% end



% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% pic_filename_temp=getappdata(h,'pic_filename')
% pic_name_temp=getappdata(h,'pic_name')
% detection_directory=get(handles.text5,'String');
pic_directory=get(handles.text2,'String');
% pic_directory_temp=strcat(pic_filename_temp,pic_name_temp)
% img=imread(pic_directory_temp);
if(exist(pic_directory))
	img=imread(pic_directory);
	imshow(img);
end
% global pic_name;
% global pic_filename;
% global pic_directory;

% function [img]=draw_box(img,xmin_input,ymin_input,xmax_input,ymax_input)
% 	xmin=floor(ymin_input);
% 	ymin=floor(xmin_input);
% 	xmax=floor(ymax_input);
% 	ymax=floor(xmax_input);
% 	img(xmin:xmax,ymin:ymin+1,:)=0;
% 	img(xmin:xmax,ymax-1:ymax,:)=0;
% 	img(xmin:xmin+1,ymin:ymax,:)=0;
% 	img(xmax-1:xmax,ymin:ymax,:)=0;
% 	img(xmin:xmax,ymin:ymin+1,2)=255;
% 	img(xmin:xmax,ymax-1:ymax,2)=255;
% 	img(xmin:xmin+1,ymin:ymax,2)=255;
% 	img(xmax-1:xmax,ymin:ymax,2)=255;
