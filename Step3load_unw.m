%1.选择SBASNEED中的干涉对文件cc_unw1_mli_table
%2.选择unw的文件存储路径TerraSARX2\file\PRODUCT\unw
%3.选择unw的输出路径TerraSARX3\output\unw


clc;clear;
feature jit off
%% 
[filename,pathname] = uigetfile('*.*','所有文件');%
Fname=fullfile(pathname,filename);
fileID=fopen(Fname);
C = textscan(fileID,'%s %s %s');
D(:,1)=C{1,1}(:,1);
D(:,2)=C{1,2}(:,1);
D(:,3)=C{1,3}(:,1);
Path = uigetdir();
path = uigetdir();

%%
lines=4456;
cc=cell(1,length(D));
namestr = ['unw',num2str(1)];
outpath = [path '\' namestr];
str=[Path '\' D{1,2}];%
temp = freadbkB(str,lines,'float32');%
save(outpath,'temp');
% temp = zeros(size(temp_1));

tic
for i = 2:length(D)
    %%%%%%%%%
    display(num2str(i));
    namestr = ['unw',num2str(i)];
    outpath = [path '\' namestr];
    str=[Path '\' D{i,2}];%
    %%%%%%%%%
    temp = freadbkB(str,lines,'float32');%
    save(outpath,'temp')%
%     clear temp;%
end
toc
figure(1);imagesc(temp);axis image off;

