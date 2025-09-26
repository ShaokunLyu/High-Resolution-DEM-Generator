function varargout = uigetfile(varargin)
% 队列优先；无队列时临时移除 shim，再调用真正的 uigetfile（会弹窗）

q = getappdata(0, 'PreselectedFilesQueue');

if isempty(q)
    % --- 队列空：回落到原生 uigetfile ---
    shimFolder = fileparts(mfilename('fullpath'));  % 本文件所在的 shim 目录
    % 临时把 shim 目录移出 path，确保不会递归调回本函数
    if contains(path, shimFolder)
        rmpath(shimFolder);
        rehash;
        c = onCleanup(@() restoreShim(shimFolder));
    else
        c = []; %#ok<NASGU>
    end
    % 现在调用真正的 uigetfile（会弹窗）
    [varargout{1:nargout}] = uigetfile(varargin{:});
    clear c; % 触发 onCleanup，把 shim 加回
    return;
end

% --- 队列有值：静默返回，不弹窗 ---
next = q{1}; q(1) = [];
setappdata(0, 'PreselectedFilesQueue', q);

% 统一成 char，避免 string/char 混用
if isstring(next), next = char(next); end
if iscell(next),   next = char(next{1}); end

[p,f,e]  = fileparts(next);
filename = [f e];
pathname = [p filesep];

switch nargout
    case 1
        varargout{1} = filename;
    case 2
        varargout{1} = filename; varargout{2} = pathname;
    otherwise
        varargout{1} = filename; varargout{2} = pathname; varargout{3} = 1;
end
end

function restoreShim(shimFolder)
    addpath(shimFolder, '-begin');
    rehash;
end
        