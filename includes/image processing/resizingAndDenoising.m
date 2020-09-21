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
function [img, params] = resizingAndDenoising(img1raw, metadata, params, silent)
if nargin == 3
    silent = 0;
end

if ~silent
    disp(' -> Preparing image');
end
dxy = metadata.data.scaling.dxy; 
dz = metadata.data.scaling.dz; 

img = img1raw;
    
if params.svd && size(img, 3) > 1
    img = performSVD(img, 0, silent);
end
   
if size(img, 3) > 1
    img = zInterpolation(img, dxy, dz, params, silent);
end

if params.denoiseImages
    
    img = convolveBySlice(img, params, silent);
end

if params.rotateImage && size(img, 3) > 1
    [img, params] = rotateBiofilmImg(img, params, silent);
end




