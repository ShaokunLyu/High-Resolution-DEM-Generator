clear;clc;
filepath=uigetdir();%ѡ��cc�ļ��е�·��
% �Զ�ɨ�� cc*.mat
files = dir(fullfile(filepath, 'cc*.mat'));
if isempty(files)
    error('Step5:NoCC', '�� %s δ�ҵ� cc*.mat', filepath);
end
cc_sum = [];
for k = 1:numel(files)
    f = fullfile(filepath, files(k).name);
    S = load(f);                 % �����б��� temp
    if k == 1
        cc_sum = zeros(size(S.temp), 'like', S.temp);  % ��ʼ��ͬ�ߴ�ͬ����
    end
    cc_sum = cc_sum + S.temp;
end

CCaver = cc_sum ./ numel(files);
figure(1); imagesc(CCaver); axis image off; colormap(gray);

% ѡ�����Ŀ¼����ǰ��Ӱ�Ӻ���ι�� ccaverWork��
filepath2 = uigetdir();

% �����м̲���
save(fullfile(filepath2, 'CCaver.mat'), 'CCaver');
