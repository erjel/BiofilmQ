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
function  fSize = determineFilterSize(hObject, eventdata, handles, img1, params)

fprintf(' -> determining filter size');

if nargin == 3
    file = handles.java.files_jtable.getSelectedRow()+1;
    updateWaitbar(handles, 0.1);
    displayStatus(handles, 'Determining filter size... ', 'black');
    
    img1 = imread3D(fullfile(handles.settings.directory, handles.settings.lists.files_tif(file).name));
    params = load(fullfile(handles.settings.directory, 'parameters.mat'));
    params = params.params;
    img1 = img1(:,:,2:end);
end

intInt = zeros(size(img1, 3), 1);
for i = 1:size(img1, 3)
    slice = img1(:,:,i);
    intInt(i) = prctile(slice(:), 95);
end

[~, maxValInd] = max(intInt(2:end));
maxValInd = maxValInd + 1; 

if nargin == 3
    displayStatus(handles, [' -> Taking slice ', num2str(maxValInd)], 'black', 'add');
end

fprintf(' [brigthest slice: %d]\n', maxValInd);

if nargin == 3
    updateWaitbar(handles, 0.2);
end

if maxValInd==size(img1,3)
    slice = img1(:,:,maxValInd-1:maxValInd);
    slice(:,:,3) = img1(:,:,maxValInd);
elseif maxValInd == 1
    slice = repmat(img1(:,:,1), 1, 1, 2);
    slice(:,:,3) = img1(:,:,2);
else
    slice = img1(:,:,maxValInd-1:maxValInd+1);    
end


if params.denoiseImages
    
    params.noise_kernelSize(2) = 3;
    slice = convolveBySlice(slice, params);
    if nargin == 3
        updateWaitbar(handles, 0.3);
    end
end

if params.topHatFiltering
    
    slice = topHatFilter(slice, params);
    if nargin == 3
        updateWaitbar(handles, 0.4);
    end
end
slice = slice(:,:,2);

x = multithresh(slice, 3);

if nargin == 3
    updateWaitbar(handles, 0.9);
end

cells = regionprops((slice>x(2)), 'Area');

fSize = sqrt(median([cells.Area]));
fSize = 2.*round((fSize+1)/2)-1;

fprintf('    - filter size: %d px', fSize);

if fSize < 7
    fSize = 7;
    fprintf(' -> too small [corrected: fSize=%d px]', 7);
end

if fSize > 21
    fSize = 21;
    fprintf(' -> too large [corrected: fSize=%d px]', 21);
end
fprintf('\n');


if nargin == 3
    displayStatus(handles, [' -> Filter size: ', num2str(fSize), ' px.'], 'black', 'add');
    
    updateWaitbar(handles, 0);
    
end



