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
function img = performSVD(img1raw, removeFirstEigenvalue, silent)

if nargin == 1
    removeFirstEigenvalue = 0;
    silent = 0;
end
if nargin == 2
    silent = 0;
end

if ~silent
    fprintf(' - performing singular value decomposition\n');
end

ticValue = displayTime;

k = round(2/3*size(img1raw, 3));
if ~silent
    fprintf('      [keeping %d from %d eigenvalues]', k, size(img1raw, 3));
    fprintf(' - along xz');
end

img1 = img1raw;
for x = 1:size(img1raw,1)
    img_mean = mean(mean(squeeze(img1raw(x,:,:))));
    [U, S, V] = svd(squeeze(img1raw(x,:,:))-img_mean);
    for i = k+1:size(S,2)
        S(i,i) = 0;
    end
    
    img1(x,:,:) = U*S*V'+img_mean;
end

if ~silent
    fprintf(', along yz');
end
img2 = img1raw;
for y = 1:size(img1raw,2)
    img_mean = mean(mean(squeeze(img1raw(:,y,:))));
    [U, S, V] = svd(squeeze(img1raw(:,y,:))-img_mean);
    for i = k+1:size(S,2)
        S(i,i) = 0;
    end
    
    img2(:,y,:) = U*S*V'+img_mean;
end

img = (img1+img2)/2;

if removeFirstEigenvalue
    if ~silent
        fprintf(', remove first eigenvalue');
    end
    for z = 1:size(img, 3)
        img_mean = mean(mean(img(:,:,z)));
        [U, S, V] = svd(img(:,:,z)-img_mean);
        
        S(1,1) = 1.5*mean([S(2,2), S(3,3)]);
        img(:,:,z) = U*S*V'+img_mean;
    end
end

if ~silent
    displayTime(ticValue);
end


