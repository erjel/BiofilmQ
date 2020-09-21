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
function img_cropped = normalizeIntensities(img_cropped, I, x, z_max, removeFirstPart)
fprintf(' - normalize intensities');
ticValue = displayTime;

if removeFirstPart
    [~, maxIntDisp] = max(I);
    I(end) = I(maxIntDisp)/2;
    x = x(maxIntDisp:z_max);
    I = I(maxIntDisp:z_max);
end

[fitresult, gof] = fitIntensity(x, I);

parfor i = 1:size(img_cropped,3)
    img_cropped(:,:,i) = img_cropped(:,:,i)/fitresult(i);
end
displayTime(ticValue);


