function p = uigetdir(varargin)
% �������ȣ��޶���ʱ��ʱ�Ƴ� shim���ٵ��������� uigetdir���ᵯ����

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
    p = uigetdir(varargin{:});  % ������ uigetdir���ᵯ��
    clear c; % �ָ� shim
    return;
end

% ������ֵ����Ĭ����
p = q{1}; q(1) = [];
setappdata(0, 'PreselectedDirsQueue', q);

if isstring(p), p = char(p); end
if iscell(p),   p = char(p{1}); end
end

function restoreShim(shimFolder)
    addpath(shimFolder, '-begin');
    rehash;
end