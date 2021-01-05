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
function img_normalized_resized = zInterpolation_nearest(img_normalized, dxy, dz, params, silent)

if nargin == 4
    silent = 0;
end

if ~silent
    fprintf(' - resize Biofilm');
end

if size(img_normalized, 3) == 1
    fprintf(' -> skipped (2D image!)');
    img_normalized_resized = img_normalized;
    return;
end

if dz == dxy
    fprintf(' -> skipped (scaling along xy and z is already equal)\n');
    img_normalized_resized = img_normalized;
    return;
end

ticValue = displayTime;

if params.scaleUp
    scaleFactor = params.scaleFactor;
else
    scaleFactor = 1;
end

dxy = dxy/scaleFactor;

resizeFactor = dz/dxy;

T = affine3d([scaleFactor 0 0 0; 0 scaleFactor 0 0; 0 0 resizeFactor 0; 0 0 0 1]);
img_normalized_resized = imwarp(img_normalized, T, 'interp', 'nearest', 'FillValues', 0);

if isfield(params, 'blindDeconvolution')
    if params.blindDeconvolution
        img_normalized_resized = img_normalized_resized(:,:,4:end-4);
    end
end

if ~silent
    fprintf(', new size: [x=%d, y=%d, z=%d] (scale-factor=%.02f)', size(img_normalized_resized,1), size(img_normalized_resized,2), size(img_normalized_resized,3), scaleFactor);
    displayTime(ticValue);
end


