function setup
% Add package folders to the MATLAB path.
root = fileparts(mfilename('fullpath'));
addpath(fullfile(root,'src'), fullfile(root,'config'), ...
    fullfile(root,'simulations'), fullfile(root,'tests'));
end
