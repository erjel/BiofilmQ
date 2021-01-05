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
function img1raw = performImageAlignment2D(img1raw, metadata, method, displayOutput)

tform = metadata.data.registration;

if nargin == 2
    ticValue = displayTime;
    fprintf(' - aligning image, translation: [x=%0.3f, y=%0.3f, z=%0.3f]', tform.T(4,1), tform.T(4,2), tform.T(4,3));
    method = 'linear';
end

tform2 = affine2d;
tform2.T(3,1) = tform.T(4,1);
tform2.T(3,2) = tform.T(4,2);

for i = 1:size(img1raw, 3)
    
    
    img1raw(:,:,i)  = imwarp(img1raw(:,:,i),tform2,'OutputView',imref2d(size(img1raw)), 'Interp', method, 'FillValues', min(img1raw(:)));
end

if nargin == 2
    ticValue = displayTime(ticValue);
end


