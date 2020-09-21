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
function img1raw = fadeBottom(img1raw, params, silent)

if nargin < 3
    silent = 0;
end

if ~silent
    fprintf(' - fading bottom');
end

I = squeeze(sum(sum(img1raw, 1), 2));

[~, ind] = max(I);

fadeBelow = ind+ceil(params.fadeBottomLength/(params.scaling_dz/1000));

if fadeBelow < 1
    fprintf(' -> fading not possible\n');
else
    if ~silent
        fprintf(', [fading slices=%d]\n', fadeBelow);
    end
    
    i = fadeBelow;
    count = 2;
    while i>0
        img1raw(:,:,i) = img1raw(:,:,i)/count;
        count = count * 2;
        i = i-1;
    end
end


