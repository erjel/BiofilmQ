%%
% BiofilmQ
%
% Copyright (c) 2020 Raimo Hartmann, Hannah Jeckel, and Eric Jelli <biofilmQ@gmail.com>
% Copyright (c) 2020 Drescher-lab, Max Planck Institute for Terrestrial Microbiology, Marburg, Germany
%
% This program is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program.  If not, see <http://www.gnu.org/licenses/>.
%
%%
function I = imread3D(f, params, silent)
ticValue = displayTime;
if nargin < 3
    silent = 0;
end

filename = f;

[filebase, fname, ext] = fileparts(filename);

deconvolvedVersion = false;
if exist(fullfile(filebase, 'deconvolved images'), 'dir')
    if exist(fullfile(filebase, 'deconvolved images', [fname, '_cmle', ext]), 'file')
        filename = fullfile(filebase, 'deconvolved images', [fname, '_cmle', ext]);
        deconvolvedVersion = true;
        if ~silent
            fprintf(' [deconvolved version]');
        end
    end
end

if ~silent
    textprogressbar('      ');
end

   
    
slice = imread(filename,1);
imInfo = imfinfo(filename);
z = length(imInfo);

if nargin == 1 || isempty(params)
    slices = z;
    params.maxHeight = 0;
else
    
    if ~isempty(params.maxHeight)
        slices = ceil(params.maxHeight/(params.scaling_dz/1000))+1;
    else
        slices = z;
        params.maxHeight = (slices-1) * (params.scaling_dz/1000);
    end
    
    if slices > z
        slices = z;
    end
end

I = zeros(imInfo(1).Height,imInfo(1).Width,slices, 'uint16');
for i = 1:slices
    try
        I(:,:,i) = imread(filename,'Index', i, 'Info', imInfo);
        if ~mod(i,10)
            if ~silent
                textprogressbar(i/slices*100);
            end
        end
    catch err
        warning(err.message);
        break;
    end
end

if deconvolvedVersion
    I(:,:,2:end+1) = I;
    proj = squeeze(sum(I, 3));
    I(:,:,1) = proj/max(proj(:))*(2^16-1);
end

if ~silent
    textprogressbar(100);
    textprogressbar(' Done.');
    fprintf(' %d slice(s) read (~%.02f m)', slices, params.maxHeight);
    displayTime(ticValue);
end


