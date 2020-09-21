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
function im_conv = convolveBySlice(img1raw, params, silent)
ticValue = displayTime;

if nargin == 2
    silent = 0;
end

if ~silent
    fprintf(' - removing noise');
end

try
    dxy = params.noise_kernelSize(1);
    dz = params.noise_kernelSize(2);
catch
    dxy = 5;
    dz = 3;
end

if ~silent
    fprintf(', [dxy=%d, dz=%d]', dxy, dz);
end

strel = ones(dxy,dxy,dz);
strel(1, :, 1) = 0;
strel(end, :, 1) = 0;
strel(1, :, end) = 0;
strel(end, :, end) = 0;
strel(:, 1, 1) = 0;
strel(:, end, 1) = 0;
strel(:, 1, end) = 0;
strel(:, end, end) = 0;


strel = strel/sum(strel(:));

padsize = [dxy dxy dz];
img1raw = padarray(img1raw, padsize, 'replicate');
im_conv = convn(img1raw, strel, 'same');
im_conv = im_conv(1+padsize(1):end-padsize(1),1+padsize(2):end-padsize(2),1+padsize(3):end-padsize(3));



if ~silent
    ticValue = displayTime(ticValue);
end


