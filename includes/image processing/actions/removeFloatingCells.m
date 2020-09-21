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
function img1raw = removeFloatingCells(img1raw, silent)
ticValue = displayTime;

if nargin < 2
    silent = 0;
end

if ~silent
    fprintf(' - removing floating cells');
end

if size(img1raw, 3) > 1
    parfor i = 1:size(img1raw, 1)
        img1raw(i, :, :) = min(cat(3, medfilt2(squeeze(img1raw(i, :, :)), [1 3]), squeeze(img1raw(i, :, :))), [], 3);
    end
else
    fprintf(' -> 2D image (cancelled)');
end

if ~silent
    displayTime(ticValue);
end


