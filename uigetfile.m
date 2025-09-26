function varargout = uigetfile(varargin)
% �������ȣ��޶���ʱ��ʱ�Ƴ� shim���ٵ��������� uigetfile���ᵯ����

q = getappdata(0, 'PreselectedFilesQueue');

if isempty(q)
    % --- ���пգ����䵽ԭ�� uigetfile ---
    shimFolder = fileparts(mfilename('fullpath'));  % ���ļ����ڵ� shim Ŀ¼
    % ��ʱ�� shim Ŀ¼�Ƴ� path��ȷ������ݹ���ر�����
    if contains(path, shimFolder)
        rmpath(shimFolder);
        rehash;
        c = onCleanup(@() restoreShim(shimFolder));
    else
        c = []; %#ok<NASGU>
    end
    % ���ڵ��������� uigetfile���ᵯ����
    [varargout{1:nargout}] = uigetfile(varargin{:});
    clear c; % ���� onCleanup���� shim �ӻ�
    return;
end

% --- ������ֵ����Ĭ���أ������� ---
next = q{1}; q(1) = [];
setappdata(0, 'PreselectedFilesQueue', q);

% ͳһ�� char������ string/char ����
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
        