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
function img1raw = performImageAlignment3D(img1raw, metadata, silent)
if nargin == 2
    silent = 0;
end

tform = metadata.data.registration;


ticValue = displayTime;
if ~silent
    fprintf(' - aligning image, translation: [x=%0.3f, y=%0.3f, z=%0.3f]', tform.T(4,1), tform.T(4,2), tform.T(4,3));
end



addZSlices = ceil(tform.T(4,3));
if addZSlices > 1
    if ~silent
        fprintf(' -> adding %d additional z-planes', addZSlices);
    end
    img1raw(:,:,end+1) = img1raw(:,:,end);
end
 
img1raw  = imwarp(img1raw,tform,'OutputView',imref3d(size(img1raw)), 'Interp', 'linear', 'FillValues', double(min(img1raw(:))));

if ~silent
    ticValue = displayTime(ticValue);
end



