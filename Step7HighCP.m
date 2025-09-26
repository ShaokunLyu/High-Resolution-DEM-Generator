clear;clc;

% �� root-appdata��ȡ�м��ļ���·��
daWork = getappdata(0, 'Step6DaWork');
ccaverWork = getappdata(0,'Step5CcaverWork');
unwWork = getappdata(0, 'Step3UnwWork');
postWork = getappdata(0, 'Step4PostWork');
finalOutDir = getappdata(0, 'FinalOutDir');
maskWork = getappdata(0, 'Step7MaskWork');
highcpWork = getappdata(0, 'Step7HighcpWork');
demRefineWork = getappdata(0, 'Step7DemRefineWork');

req = {daWork, ccaverWork, unwWork, postWork, finalOutDir, maskWork, highcpWork, demRefineWork};
if any(cellfun(@isempty, req)), error('Step7:PathsMissing', '���߲�����·��δ����'); end

S_da = load(fullfile(daWork, 'Da.mat')); Da = S_da.Da;
S_mli = load(fullfile(daWork, 'mli.mat')); mli = S_mli.mli;
S_cc = load(fullfile(ccaverWork, 'CCaver.mat')); CCaver = S_cc.CCaver;


% �˴��ķ�Χֵ��DEM��ȡ��ֵ����һ�¡�
% (1999:15535,3013:10746)   13537   7734
% latlim=[36.618,36.811];
% lonlim=[109.356,109.596];

cc=CCaver(1:4456,1:6421);  
Da=Da(1:4456,1:6421);
mli=mli(1:4456,1:6421);
% % ��Ĥ��ֵ��
% cc(1:7000,1:1325)=1; 
% cc(4830:7000,1326:3006)=1;

figure(1);imagesc(Da);axis image off;colormap(gray)
figure(2);imagesc(mli);axis image off;colormap(gray)
figure(3);imagesc(cc);axis image off;colormap(gray)

% 3) ���ӻ�/������GeoTIFF ������Ŀ¼��
myimage = flipud(mli);
latlim  = [36.1572518 - 2.5473844e-05 * 4456, 36.1572518];
lonlim  = [103.2262400,  103.2262400 + 2.5473844e-05 * 6421];
R = georefcells(latlim, lonlim, size(myimage));
geotiffwrite(fullfile(finalOutDir,'mli.tif'), myimage, R);

myimage1 = flipud(cc);
R1 = georefcells(latlim, lonlim, size(myimage1));
geotiffwrite(fullfile(finalOutDir,'cc.tif'), myimage1, R1);

% 4) ����ֵ��Ĥ �� row_col_ct���м̵� maskWork��
mask = ~(mli < 0.30 | Da > 0.25 | cc < 0.54);
mask(isnan(mask)) = true;        % NaN ��Ϊͨ�����ȼ���ԭ���� cc(NaN)=1��
[x,y] = find(mask);              % ��������
row_col_ct = [x,y];
save(fullfile(maskWork,'row_col_ct.mat'),'row_col_ct');

% 5) ������Ĥ�������� unw*.mat������ Num_mask_lungui���м̵� highcpWork��
files_unw = dir(fullfile(unwWork,'unw*.mat'));
n_unw = numel(files_unw);
if n_unw == 0, error('Step7:NoUNW','δ�� %s �ҵ� unw*.mat', unwWork); end

Num_mask_lungui = zeros(size(row_col_ct,1), n_unw);
for j = 1:n_unw
    S = load(fullfile(unwWork, files_unw(j).name));  % ���� temp
    temp = S.temp(1:4456,1:6421);
    Num_mask_lungui(:,j) = temp(row_col_ct(:,1) + (row_col_ct(:,2)-1)*4456);
end
save(fullfile(highcpWork,'Num_mask_lungui.mat'),'Num_mask_lungui');

% 6) DEM ƽ���뵼��
S_dem = load(fullfile(postWork,'finaldem.mat'));  % ��4���� finaldem.mat
H = S_dem.finaldem;
[xm,ym] = size(H);

% ������ƽ������ԭ�߼���
H2 = padarray(H,[1 1],0,'both');
for t = 1:8
    for i = 2:xm+1
        for j = 2:ym
            if H2(i,j)==0, continue; end
            a = sum([H2(i-1,j),H2(i+1,j),H2(i,j-1),H2(i,j+1)]==0);
            H2(i,j) = 0.5*H2(i,j) + 0.125*4/(4-a)*(H2(i-1,j)+H2(i+1,j)+H2(i,j-1)+H2(i,j+1));
        end
    end
end
H_out = H2(2:end-1,2:end-1);
H_out(isnan(H_out)) = 0;
finaldem11 = H_out;

% GeoTIFF �� ����Ŀ¼��.mat �� demRefineWork
myimage = flipud(finaldem11);
R = georefcells(latlim, lonlim, size(myimage));
geotiffwrite(fullfile(finalOutDir,'finaldem11.tif'), myimage, R);

% ���� dem30_1����ԭ�߼�һ�£�
npts = size(row_col_ct,1);
dem30_1 = zeros(npts,1);
for ii = 1:npts
    dem30_1(ii,1) = finaldem11(row_col_ct(ii,1), row_col_ct(ii,2));
end

save(fullfile(demRefineWork,'finaldem11.mat'),'finaldem11');
save(fullfile(demRefineWork,'dem30_1.mat'),'dem30_1');