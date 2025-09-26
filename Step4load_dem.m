clc;

% 1 选择低分辨率DEM_GEO final的二进制文件 
[filename1, pathname1] = uigetfile('*.*', '选择DEM_GEO .final 文件');
Fname = fullfile(pathname1, filename1);

lines = 4456;
final1 = freadbkB(Fname, lines, 'float32');

% final1 = freadbkB('F:\GAMMAHFT1\TerraSARX2\file\DEM_GEO\20160126geo.dem.final',4456,'float32');

figure(1);imagesc(final1);axis image off;


% 2 选择重采样后的DEM TIFF final111.tif
[filename2, pathname2] = uigetfile('*.tif', '选择重采样DEM(final111.tif)');
img16 = imread(fullfile(pathname2, filename2));
% 此时的低分辨DEM由于地形畸变产生拉花现象严重，可根据final1 DEM的范围利用ArcGIS对原始DEM文件夹的DEM进行裁剪final11，然后进行重采样与SAR一致final111。
% img16 = imread('F:\GAMMAHFT1\TerraSARX3\matlabgeo\final111.tif');
imgFloat = double(img16);
final1=imgFloat; 


% 3 生成中继目录
if ~exist('postWork','var') || isempty(postWork)
    error('Step4:MissingPostWork','前端未注入 postWork 目录');
end
if ~exist('finalOutDir','var') || isempty(finalOutDir)
    error('Step4:MissingFinalOut','前端未注入 finalOutDir 目录');
end
if isstring(postWork),    postWork    = char(postWork); end
if isstring(finalOutDir), finalOutDir = char(finalOutDir); end


% 4 生成 GeoTIFF（使用原脚本的地理参照参数）===
cols = size(final1, 2);
myimage = flipud(final1);
latlim = [36.1572518 - 2.5473844e-05 * lines, 36.1572518];
lonlim = [103.2262400, 103.2262400 + 2.5473844e-05 * cols];
R = georefcells(latlim, lonlim, size(myimage));
geotiffwrite(fullfile(finalOutDir, 'final1.tif'), myimage, R);

% 5 裁剪
finaldem = final1(1:lines, 1:cols);   % 若 final1 尺寸刚好等于 lines×cols，这里等于原样
figure(2); imagesc(finaldem); axis image off;

myimage11 = flipud(finaldem);
R = georefcells(latlim, lonlim, size(myimage11));
geotiffwrite(fullfile(finalOutDir, 'finaldem.tif'), myimage11, R);

% 6 保存 MAT 到输出目录
save(fullfile(postWork, 'final1.mat'), 'final1');
save(fullfile(postWork, 'finaldem.mat'), 'finaldem');



% % % imwrite(uint16(finaldem1),'finaldem11.tif','tif');
% save('F:\GAMMAHFT1\TerraSARX3\outputgeo\dem\final1','final1');
% save('F:\GAMMAHFT1\TerraSARX3\outputgeo\dem\finaldem','finaldem');
