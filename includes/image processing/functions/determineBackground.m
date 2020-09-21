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
function  I_base = determineBackground(hObject, eventdata, handles, params, lastSlice)
disp('== Extracting background ==');
h = 0;
if nargin == 3
    
    h = waitbar(0.1, 'Extracting background', 'Name', 'Please wait');
    file = handles.settings.selectedFile;

    try
        NSlices = str2num(handles.settings.lists.files_tif(file).name(strfind(handles.settings.lists.files_tif(file).name, 'Nz')+2:strfind(handles.settings.lists.files_tif(file).name, '.tif')-1));
        displayStatus(handles, ['Extracting background of the last image (',handles.settings.lists.files_tif(file).name,')'], 'black');
        lastSlice = imread(fullfile(handles.settings.directory, handles.settings.lists.files_tif(file).name), NSlices);
    catch
        displayStatus(handles, ['Extracting background of the first image (',handles.settings.lists.files_tif(file).name,')'], 'black');
        lastSlice = imread(fullfile(handles.settings.directory, handles.settings.lists.files_tif(file).name), 1);
    end
    
    params = load(fullfile(handles.settings.directory, 'parameters.mat'));
    params = params.params;
else
    displayStatus(handles, 'Extracting background...', 'black');
end
    

if params.denoiseImages
    
    lastSlice = convolveBySlice(lastSlice, params);
    if ishandle(h)
        try
         waitbar(0.3, h);
        end
    end
end
if params.topHatFiltering
    
    lastSlice = topHatFilter(lastSlice, params);
    if ishandle(h)
        try
         waitbar(0.7, h);
        end
    end
end

im_values = sort(lastSlice(:));
I_base = round(10*mean(im_values(end-2000:end)))/10;

displayStatus(handles, [' -> Background: I=', num2str(I_base)], 'black', 'add');
set(handles.uicontrols.edit.I_base, 'String', num2str(I_base));

if ishandle(h)
    try
    waitbar(1, h);
    delete(h);
    end
end




