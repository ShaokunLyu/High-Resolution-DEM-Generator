% 计算沉降速率和高程改正值

% 基于沉降速率的DInSAR模型，（笔记3，或者尹宏杰的论文）
% 对于第j行，位于主辅影像获取时间之间的列B(j,k)=t（k+1)-t(k)，否则B=0.
clear;clc;

% 0) 取路径（前端已 set 到 root-appdata）
highcpWork   = getappdata(0,'Step7HighcpWork');    % 有 Num_mask_lungui.mat
maskWork     = getappdata(0,'Step7MaskWork');      % 有 row_col_ct.mat（如需）
resolveWork  = getappdata(0,'Step8ResolveWork');   % 目标中继输出
if any(cellfun(@isempty,{highcpWork, resolveWork}))
    error('Step8:PathsMissing','未注入 Step7/8 的中继目录');
end

% 1) 读取上一步输出
S1 = load(fullfile(highcpWork, 'Num_mask_lungui.mat'));   % 变量 Num_mask_lungui
Num_mask_lungui = S1.Num_mask_lungui;
% 如需 row_col_ct： S2 = load(fullfile(maskWork,'row_col_ct.mat')); row_col_ct = S2.row_col_ct;

% 2) 动态设置维度，替代写死的 38/23
PS_n = size(Num_mask_lungui, 1);      % 点数
M    = size(Num_mask_lungui, 2);      % 干涉对数量（列数）
% 你的时间序列 TT（长度 = n+1），仍保留为常量数组：
TT   = [0 11 22 33 44 55 66 77 99 110 121 132 143 154 165 176 198 209 220 242 253 264 275 297];
n    = numel(TT) - 1;                 % 影像个数减一（替代 n=23 的硬编码）

% 若 Num_mask_lungui 原脚本丢掉第1列（对应参考干涉？），保持一致但用动态写法：
if M >= 2
    Num_mask_lungui = Num_mask_lungui(:, 2:end);
    M = size(Num_mask_lungui,2);
end

% 3) 雷达/几何参数
Lambda = 0.032;
theta  = 40.9060;
R      = 660594.0682;
q      = 4*pi./Lambda;

% 垂直基线数组
B_p = [-252.3640 279.7347 -27.3441 -55.0688 -202.2146 ...
        -27.7307 -32.6496 35.9078 -207.1401 -138.5706 ...
         68.5532 -7.1482 -75.6882 53.9758 -8.2167 ...
         21.1404 -137.8998 -108.5447 29.3525 167.8376 ...
         67.1627 -100.1293 -100.6750 191.1042 173.4831 ...
         -65.6743 -180.1440 -239.1724 -59.0279 74.9480 ...
         133.9705 60.1916 76.4938 16.2992 133.0399 ...
         140.9453 -164.3963 7.9050]';   % 长度应 ≥ 原 38

% 与先前“B_p = B_p(2:38)”等价，但自适应到 M 的列数
if numel(B_p) < M+1
    error('Step8:BpLenMismatch','B_p 长度不足（需要 ≥ M+1 = %d）', M+1);
end
B_p = B_p(2:M+1);

% 4) 构造 B_perp 与 B1（时间差项）
q1     = Lambda*R*sind(theta);
B_perp = B_p * ((4*pi)/q1);   % 高程改正项系数，长度 M

% 构造时间差 DT
DT = zeros(1,n);
for i = 1:n
    DT(i) = (TT(i+1) - TT(i))/365;
end

B1 = zeros(38, n);
%0-1,0-2
B1(1,1)=[DT(1)];
B1(2,1:2)=[DT(1) DT(2)];
%1-2,1-4
B1(3,2)=[DT(2)];
B1(4,2:4)=[DT(2) DT(3) DT(4)];
%2-3,2-4
B1(5,3)=[DT(3)];
B1(6,3:4)=[DT(3) DT(4)];
%3-5,3-6
B1(7,4:5)=[DT(4) DT(5)];
B1(8,4:6)=[DT(4) DT(5) DT(6)];
%4-5，4-6
B1(9,5)=[DT(5)];
B1(10,5:6)=[DT(5) DT(6)];
%5-6,5-7
B1(11,6)=[DT(6)];
B1(12,6:7)=[DT(6) DT(7)];
%6-7 6-8
B1(13,7)=[DT(7)];
B1(14,7:8)=[DT(7) DT(8)];
%7-9，7-10
B1(15,8:9)=[DT(8) DT(9)];
B1(16,8:10)=[DT(8) DT(9) DT(10)];
%8-9，8-10
B1(17,9)=[DT(9)];
B1(18,9:10)=[DT(9) DT(10)];
%9-10
B1(19,10)=[DT(10)];
%10-12，10-13
B1(20,11:12)=[DT(11) DT(12)];
B1(21,11:13)=[DT(11) DT(12) DT(13)];
%11-12
B1(22,12)=[DT(12)];
%12-13
B1(23,13)=[DT(13)];
%13-15
B1(24,14:15)=[DT(14) DT(15)];
%14-15，14-17
B1(25,15)=[DT(15)];
B1(26,15:17)=[DT(15) DT(16) DT(17)];
%15-16 15-17
B1(27,16)=[DT(16)];
B1(28,16:17)=[DT(16) DT(17)];
%16-17,16-18
B1(29,17)=[DT(17)];
B1(30,17:18)=[DT(17) DT(18)];
%17-18
B1(31,18)=[DT(18)];
%18-19,18-20
B1(32,19)=[DT(19)];
B1(33,19:21)=[DT(19) DT(20) DT(21)];
%19-20
B1(34,20)=[DT(20)];
%20-22,20-23
B1(35,21:22)=[DT(21) DT(22)];
B1(36,21:23)=[DT(21) DT(22) DT(23)];
%21-23
B1(37,22:23)=[DT(22) DT(23)];
%22-23
B1(38,23)=[DT(23)];

if M > size(B1,1)-1
    warning('Step8:B1Rows','B1 模板行数不足以覆盖 M=%d，将按现有最大模板裁剪', M);
end
B1 = B1(2:min(1+M, size(B1,1)), :);   % 得到 M×n

% 5) 组装设计矩阵并求解
B    = B1*((4*pi)/Lambda);           % M×n
B13  = [B, B_perp];                  % M×(n+1)
Def_LP_X = zeros(n+1, PS_n);
for i = 1:PS_n
    L3 = Num_mask_lungui(i,:)';      % M×1
    Def_LP_X(:,i) = SVD(B13, L3);    % SVD 求解函数
end

% 6) 输出到中继目录 resolveWork
save(fullfile(resolveWork,'Def_LP_X.mat'), 'Def_LP_X');

% 拆出 V_LP / SigmaH1 并输出
V_LP   = Def_LP_X(1:n,:).';   % PS_n×n  （转置与原脚本一致）
SigmaH1= Def_LP_X(n+1,:);
save(fullfile(resolveWork,'V_LP.mat'),    'V_LP');
save(fullfile(resolveWork,'SigmaH1.mat'), 'SigmaH1');

% 7) 根据 V_LP 重建形变时间序列 S
theta = 40.9060;             
DT = diff(TT)./365;          % 1×n
S_Los = zeros(PS_n, n);
S_Los(:,1) = DT(1)*V_LP(:,1);
for i = 2:n
    S_Los(:,i) = S_Los(:,i-1) + DT(i)*V_LP(:,i);
end
S = 1000.*S_Los./cosd(theta);    % vertical deformation（mm）
save(fullfile(resolveWork,'S.mat'), 'S');