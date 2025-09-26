clear,clc;
% 0) 取路径（由前端注入到 root-appdata）
maskWork      = getappdata(0,'Step7MaskWork');        % row_col_ct.mat
demRefineWork = getappdata(0,'Step7DemRefineWork');   % finaldem11.mat、dem30_1.mat
resolveWork   = getappdata(0,'Step8ResolveWork');     % SigmaH1.mat、S.mat
finalOutDir   = getappdata(0,'FinalOutDir');          % 最终 GeoTIFF 输出目录

if any(cellfun(@isempty,{maskWork,demRefineWork,resolveWork,finalOutDir}))
    error('Step9:PathsMissing','Step9 必需路径未注入（mask/demRefine/resolve/finalOutDir）');
end

% 1) 读入上一步的中继成果
S_row  = load(fullfile(maskWork,      'row_col_ct.mat'));    row_col_ct  = S_row.row_col_ct;
S_sig  = load(fullfile(resolveWork,   'SigmaH1.mat'));       SigmaH1     = S_sig.SigmaH1;
S_S    = load(fullfile(resolveWork,   'S.mat'));             S           = S_S.S;
S_dem  = load(fullfile(demRefineWork, 'finaldem11.mat'));    finaldem11  = S_dem.finaldem11;
S_dem3 = load(fullfile(demRefineWork, 'dem30_1.mat'));       dem30_1     = S_dem3.dem30_1;

% 2) 统一尺寸与索引
% 以 finaldem11 的尺寸为准
[lines, cols] = size(finaldem11);
SigmaH1 = -SigmaH1;                    % 与原脚本一致
x_idx = row_col_ct(:,1); y_idx = row_col_ct(:,2);

% 3) 可选：导出 finaldem1.tif（原脚本是直接把 finaldem11 另存为 tiff）
finaldem1 = finaldem11;                % 若中间还需其它尺度变换，在此插入
myimage = flipud(finaldem1);
latlim  = [36.1572518 - 2.5473844e-05*lines, 36.1572518];
lonlim  = [103.2262400,  103.2262400 + 2.5473844e-05*cols];
R = georefcells(latlim, lonlim, size(myimage));
geotiffwrite(fullfile(finalOutDir,'finaldem1.tif'), myimage, R);

% 4) 形变可视化（保持原逻辑 S 的第1列）
D = S(:,1);
HH = nan(lines, cols);
HH(sub2ind([lines,cols], x_idx, y_idx)) = D';
% figure(1); imagesc(HH); axis image off; colormap(flipud(jet)); caxis([-200 200]); % 可选

% 5) 稀疏 DEM 反演（HighlyDEM1）并导出
HighlyDEM1_pts = dem30_1 + SigmaH1';    % 点集上的高程
HHH = nan(lines, cols);
HHH(sub2ind([lines,cols], x_idx, y_idx)) = HighlyDEM1_pts;
HighlyDEM1 = HHH;

myimage = flipud(HighlyDEM1);
R = georefcells(latlim, lonlim, size(myimage));
geotiffwrite(fullfile(finalOutDir,'HighlyDEM1.tif'), myimage, R);

% 同时留一份 .mat 备查（入 demRefineWork 或新建 final_work 中继）
save(fullfile(demRefineWork,'HighlyDEM1.mat'), 'HighlyDEM1');

% 6) 生成稀疏矩阵 H（放置 SigmaH1 到 grid 上），并做平滑插值拟合
H = zeros(lines, cols);
H(sub2ind([lines,cols], x_idx, y_idx)) = SigmaH1';
% figure(2); imagesc(H); axis image off; colormap(flipud(jet)); % 可选

% pad 四邻域平滑（与原脚本一致，最多 40 次，t=8,16,24,32,40 输出）
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
        H_out = H2(2:end-1, 2:end-1);    % 去掉外圈
    end
end
H_out(isnan(H_out)) = 0;
% figure(3); imagesc(H_out); axis image off; colormap(flipud(jet)); % 可选

% 7) 整体 DEM 反演并导出
HighDEM11 = finaldem11 + H_out;
% figure(4); imagesc(HighDEM11); axis image off; colormap(jet); % 可选

myimage = flipud(HighDEM11);
R = georefcells(latlim, lonlim, size(myimage));
geotiffwrite(fullfile(finalOutDir,'HighDEM11.tif'), myimage, R);

% 过程性 .mat 留档（可留在 demRefineWork）
save(fullfile(demRefineWork,'H_out.mat'),     'H_out');
save(fullfile(demRefineWork,'HighDEM11.mat'), 'HighDEM11');
