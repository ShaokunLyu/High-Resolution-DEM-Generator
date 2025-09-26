clear;clc;
filepath=uigetdir();%选择cc文件夹的路径
% 自动扫描 cc*.mat
files = dir(fullfile(filepath, 'cc*.mat'));
if isempty(files)
    error('Step5:NoCC', '在 %s 未找到 cc*.mat', filepath);
end
cc_sum = [];
for k = 1:numel(files)
    f = fullfile(filepath, files(k).name);
    S = load(f);                 % 里面有变量 temp
    if k == 1
        cc_sum = zeros(size(S.temp), 'like', S.temp);  % 初始化同尺寸同类型
    end
    cc_sum = cc_sum + S.temp;
end

CCaver = cc_sum ./ numel(files);
figure(1); imagesc(CCaver); axis image off; colormap(gray);

% 选择输出目录（由前端影子函数喂给 ccaverWork）
filepath2 = uigetdir();

% 保存中继产物
save(fullfile(filepath2, 'CCaver.mat'), 'CCaver');
