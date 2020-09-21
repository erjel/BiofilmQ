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

function img1_topHat = topHatFilter(img1raw, params, silent)
if nargin < 3
    silent = 0;
end


if ~silent
    ticValue = displayTime;
    fprintf(' - top-hat filtering, slice-wise, disk-size [s=%d]', params.topHatSize);
end

tic
img1_topHat = zeros(size(img1raw));
se = strel('disk',params.topHatSize);

 parfor i=1:size(img1raw, 3)
     img = img1raw(:,:,i);  
     img1_topHat(:,:,i) = imtophat(img,se);
 end
 
if ~silent
    displayTime(ticValue);
end


