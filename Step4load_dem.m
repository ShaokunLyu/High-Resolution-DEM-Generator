clc;

% 1 ѡ��ͷֱ���DEM_GEO final�Ķ������ļ� 
[filename1, pathname1] = uigetfile('*.*', 'ѡ��DEM_GEO .final �ļ�');
Fname = fullfile(pathname1, filename1);

lines = 4456;
final1 = freadbkB(Fname, lines, 'float32');

% final1 = freadbkB('F:\GAMMAHFT1\TerraSARX2\file\DEM_GEO\20160126geo.dem.final',4456,'float32');

figure(1);imagesc(final1);axis image off;


% 2 ѡ���ز������DEM TIFF final111.tif
[filename2, pathname2] = uigetfile('*.tif', 'ѡ���ز���DEM(final111.tif)');
img16 = imread(fullfile(pathname2, filename2));
% ��ʱ�ĵͷֱ�DEM���ڵ��λ�����������������أ��ɸ���final1 DEM�ķ�Χ����ArcGIS��ԭʼDEM�ļ��е�DEM���вü�final11��Ȼ������ز�����SARһ��final111��
% img16 = imread('F:\GAMMAHFT1\TerraSARX3\matlabgeo\final111.tif');
imgFloat = double(img16);
final1=imgFloat; 


% 3 �����м�Ŀ¼
if ~exist('postWork','var') || isempty(postWork)
    error('Step4:MissingPostWork','ǰ��δע�� postWork Ŀ¼');
end
if ~exist('finalOutDir','var') || isempty(finalOutDir)
    error('Step4:MissingFinalOut','ǰ��δע�� finalOutDir Ŀ¼');
end
if isstring(postWork),    postWork    = char(postWork); end
if isstring(finalOutDir), finalOutDir = char(finalOutDir); end


% 4 ���� GeoTIFF��ʹ��ԭ�ű��ĵ�����ղ�����===
cols = size(final1, 2);
myimage = flipud(final1);
latlim = [36.1572518 - 2.5473844e-05 * lines, 36.1572518];
lonlim = [103.2262400, 103.2262400 + 2.5473844e-05 * cols];
R = georefcells(latlim, lonlim, size(myimage));
geotiffwrite(fullfile(finalOutDir, 'final1.tif'), myimage, R);

% 5 �ü�
finaldem = final1(1:lines, 1:cols);   % �� final1 �ߴ�պõ��� lines��cols���������ԭ��
figure(2); imagesc(finaldem); axis image off;

myimage11 = flipud(finaldem);
R = georefcells(latlim, lonlim, size(myimage11));
geotiffwrite(fullfile(finalOutDir, 'finaldem.tif'), myimage11, R);

% 6 ���� MAT �����Ŀ¼
save(fullfile(postWork, 'final1.mat'), 'final1');
save(fullfile(postWork, 'finaldem.mat'), 'finaldem');



% % % imwrite(uint16(finaldem1),'finaldem11.tif','tif');
% save('F:\GAMMAHFT1\TerraSARX3\outputgeo\dem\final1','final1');
% save('F:\GAMMAHFT1\TerraSARX3\outputgeo\dem\finaldem','finaldem');
