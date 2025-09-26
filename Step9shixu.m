clear,clc;
% 0) ȡ·������ǰ��ע�뵽 root-appdata��
maskWork      = getappdata(0,'Step7MaskWork');        % row_col_ct.mat
demRefineWork = getappdata(0,'Step7DemRefineWork');   % finaldem11.mat��dem30_1.mat
resolveWork   = getappdata(0,'Step8ResolveWork');     % SigmaH1.mat��S.mat
finalOutDir   = getappdata(0,'FinalOutDir');          % ���� GeoTIFF ���Ŀ¼

if any(cellfun(@isempty,{maskWork,demRefineWork,resolveWork,finalOutDir}))
    error('Step9:PathsMissing','Step9 ����·��δע�루mask/demRefine/resolve/finalOutDir��');
end

% 1) ������һ�����м̳ɹ�
S_row  = load(fullfile(maskWork,      'row_col_ct.mat'));    row_col_ct  = S_row.row_col_ct;
S_sig  = load(fullfile(resolveWork,   'SigmaH1.mat'));       SigmaH1     = S_sig.SigmaH1;
S_S    = load(fullfile(resolveWork,   'S.mat'));             S           = S_S.S;
S_dem  = load(fullfile(demRefineWork, 'finaldem11.mat'));    finaldem11  = S_dem.finaldem11;
S_dem3 = load(fullfile(demRefineWork, 'dem30_1.mat'));       dem30_1     = S_dem3.dem30_1;

% 2) ͳһ�ߴ�������
% �� finaldem11 �ĳߴ�Ϊ׼
[lines, cols] = size(finaldem11);
SigmaH1 = -SigmaH1;                    % ��ԭ�ű�һ��
x_idx = row_col_ct(:,1); y_idx = row_col_ct(:,2);

% 3) ��ѡ������ finaldem1.tif��ԭ�ű���ֱ�Ӱ� finaldem11 ���Ϊ tiff��
finaldem1 = finaldem11;                % ���м仹�������߶ȱ任���ڴ˲���
myimage = flipud(finaldem1);
latlim  = [36.1572518 - 2.5473844e-05*lines, 36.1572518];
lonlim  = [103.2262400,  103.2262400 + 2.5473844e-05*cols];
R = georefcells(latlim, lonlim, size(myimage));
geotiffwrite(fullfile(finalOutDir,'finaldem1.tif'), myimage, R);

% 4) �α���ӻ�������ԭ�߼� S �ĵ�1�У�
D = S(:,1);
HH = nan(lines, cols);
HH(sub2ind([lines,cols], x_idx, y_idx)) = D';
% figure(1); imagesc(HH); axis image off; colormap(flipud(jet)); caxis([-200 200]); % ��ѡ

% 5) ϡ�� DEM ���ݣ�HighlyDEM1��������
HighlyDEM1_pts = dem30_1 + SigmaH1';    % �㼯�ϵĸ߳�
HHH = nan(lines, cols);
HHH(sub2ind([lines,cols], x_idx, y_idx)) = HighlyDEM1_pts;
HighlyDEM1 = HHH;

myimage = flipud(HighlyDEM1);
R = georefcells(latlim, lonlim, size(myimage));
geotiffwrite(fullfile(finalOutDir,'HighlyDEM1.tif'), myimage, R);

% ͬʱ��һ�� .mat ���飨�� demRefineWork ���½� final_work �м̣�
save(fullfile(demRefineWork,'HighlyDEM1.mat'), 'HighlyDEM1');

% 6) ����ϡ����� H������ SigmaH1 �� grid �ϣ�������ƽ����ֵ���
H = zeros(lines, cols);
H(sub2ind([lines,cols], x_idx, y_idx)) = SigmaH1';
% figure(2); imagesc(H); axis image off; colormap(flipud(jet)); % ��ѡ

% pad ������ƽ������ԭ�ű�һ�£���� 40 �Σ�t=8,16,24,32,40 �����
H2 = padarray(H, [1 1], 0, 'both');
for t = 1:40
    for i = 2:lines+1
        for j = 2:cols+1
            if H2(i,j)==0
                continue
            else
                a = sum([H2(i-1,j), H2(i+1,j), H2(i,j-1), H2(i,j+1)]==0);
                H2(i,j) = 0.5*H2(i,j) + 0.125*4/(4-a)*( H2(i-1,j)+H2(i+1,j)+H2(i,j-1)+H2(i,j+1) );
            end
        end
    end
    if any(t == [8 16 24 32 40])
        H_out = H2(2:end-1, 2:end-1);    % ȥ����Ȧ
    end
end
H_out(isnan(H_out)) = 0;
% figure(3); imagesc(H_out); axis image off; colormap(flipud(jet)); % ��ѡ

% 7) ���� DEM ���ݲ�����
HighDEM11 = finaldem11 + H_out;
% figure(4); imagesc(HighDEM11); axis image off; colormap(jet); % ��ѡ

myimage = flipud(HighDEM11);
R = georefcells(latlim, lonlim, size(myimage));
geotiffwrite(fullfile(finalOutDir,'HighDEM11.tif'), myimage, R);

% ������ .mat ������������ demRefineWork��
save(fullfile(demRefineWork,'H_out.mat'),     'H_out');
save(fullfile(demRefineWork,'HighDEM11.mat'), 'HighDEM11');
