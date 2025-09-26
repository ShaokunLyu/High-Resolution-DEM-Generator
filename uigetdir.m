function p = uigetdir(varargin)
% 队列优先；无队列时临时移除 shim，再调用真正的 uigetdir（会弹窗）

q = getappdata(0, 'PreselectedDirsQueue');

if isempty(q)
    shimFolder = fileparts(mfilename('fullpath'));
    if contains(path, shimFolder)
        rmpath(shimFolder);
        rehash;
        c = onCleanup(@() restoreShim(shimFolder));
    else
        c = []; %#ok<NASGU>
    end
    p = uigetdir(varargin{:});  % 真正的 uigetdir；会弹窗
    clear c; % 恢复 shim
    return;
end

% 队列有值：静默返回
p = q{1}; q(1) = [];
setappdata(0, 'PreselectedDirsQueue', q);

if isstring(p), p = char(p); end
if iscell(p),   p = char(p{1}); end
end

function restoreShim(shimFolder)
    addpath(shimFolder, '-begin');
    rehash;
end