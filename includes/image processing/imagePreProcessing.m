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
function [imgfilter, status, params, thresh] = imagePreProcessing(hObject, eventdata, handles, f, params, range, silent, ~)

if nargin < 7
    silent = 0;
end

status = 1;
imgfilter = [];

files = handles.settings.lists.files_tif;

metadata = load(fullfile(handles.settings.directory, [files(f).name(1:end-4), '_metadata.mat']));

if isfield(metadata.data, 'I_base')
    params.I_base = metadata.data.I_base;
end
if isfield(metadata.data, 'cropRange')
    params.cropRange = metadata.data.cropRange;
end
if isfield(metadata.data, 'manualThreshold')
    params.manualThreshold = metadata.data.manualThreshold;
end

if ~isfield(metadata.data, 'scaling')
    disp(' - WARNING: Scaling not stored in metadata!');
    metadata.data.scaling.dxy = params.scaling_dxy/1000;
    metadata.data.scaling.dz = params.scaling_dz/1000;
end

if ~silent
    displayStatus(handles,['Loading image ', num2str(f), ' of ', num2str(length(files)), '...'], 'blue');
    fprintf(' - loading image "%s"', files(f).name);
    ticValue = displayTime;
end


loaded = 0;
while ~loaded
    try
        img1raw = double(imread3D(fullfile(params.inputDirectory, files(f).name), params, 1));
        loaded = 1;
    catch err
        if strcmp(err.identifier, 'MATLAB:imagesci:tiffmexutils:libtiffError')
            error(['File: "',files(f).name, '", ', err.message])
        end
        warning(err.message);
        pause(5)
    end
end
            
   
if ~silent
    displayTime(ticValue);
end
         
img1raw = img1raw(:,:,2:end);

if size(img1raw, 3) == 1 && params.segmentationMethod == 2
    fprintf(' - 2D image -> padding 4 slices (required for edge-detection-based segmentation\n');
    
    img1raw(:,:,2) = img1raw(:,:,1);
    img1raw(:,:,3) = img1raw(:,:,1);
    img1raw(:,:,4) = img1raw(:,:,1);
    img1raw(:,:,5) = img1raw(:,:,1);
end

if params.removeFloatingCells
    img1raw = removeFloatingCells(img1raw, silent);
end

if isfield(params, 'invertStack')
    if params.invertStack && size(img1raw, 3) > 1
        if ~silent
            fprintf(' - inverting stack');
        end
        img1raw = img1raw(:,:,linspace(size(img1raw,3),1,size(img1raw,3)));
    end
end

if params.imageRegistration
    try
        if size(img1raw, 3) == 1
            img1raw = performImageAlignment2D(img1raw, metadata, silent);
        else
            img1raw = performImageAlignment3D(img1raw, metadata, silent);
        end
    catch
        disp(['Image #',num2str(f),' is not registered!']);
        uiwait(msgbox(' - WARNING: Image is not registered! Cannot continue.', 'Error', 'error', 'modal'));
        displayStatus(handles, 'Processing cancelled!', 'red');
        updateWaitbar(handles, 0);
        status = 0;
        return;
    end
end

if params.autoFilterSize
    params.kernelSize = determineFilterSize([], [], [], img1raw, params);
end

if ~isempty(params.cropRange)
    params.cropRangeAfterRegistration = params.cropRange;
    
    if params.imageRegistration
        correctCropRange = 0;
        
        params.cropRangeAfterRegistration(1:2) = params.cropRange(1:2);
        
        
        
        if params.fixedOutputSize
            if params.cropRangeAfterRegistration(1) < params.registrationReferenceCropping(1)
                params.cropRangeAfterRegistration(1) = params.registrationReferenceCropping(1);
                correctCropRange = 1;
            end
            if params.cropRangeAfterRegistration(2) < params.registrationReferenceCropping(2)
                params.cropRangeAfterRegistration(2) = params.registrationReferenceCropping(2);
                correctCropRange = 1;
            end
            if params.cropRangeAfterRegistration(1) + params.cropRange(3) > params.registrationReferenceCropping(1) + params.registrationReferenceCropping(3)
                params.cropRangeAfterRegistration(3) = params.registrationReferenceCropping(1)+params.registrationReferenceCropping(3)-params.cropRange(1);
                correctCropRange = 1;
            end
            if params.cropRangeAfterRegistration(2) + params.cropRange(4) > params.registrationReferenceCropping(2) + params.registrationReferenceCropping(4)
                params.cropRangeAfterRegistration(4) = params.registrationReferenceCropping(2)+params.registrationReferenceCropping(4)-params.cropRange(2);
                correctCropRange = 1;
            end
        end
       
        if params.cropRange(3)+params.cropRangeAfterRegistration(1) > size(img1raw,2)
            params.cropRangeAfterRegistration(3) = size(img1raw,1)-params.cropRangeAfterRegistration(1);
            correctCropRange = 1;
        end
        
        if params.cropRange(4)+params.cropRangeAfterRegistration(2) > size(img1raw,1)
            params.cropRangeAfterRegistration(4) = size(img1raw,1)-params.cropRangeAfterRegistration(2);
            correctCropRange = 1;
        end
        
        if correctCropRange
            fprintf(' -> WARNING: crop range was confined by image border or crop range of reference frame to [%d %d %d %d]\n',  params.cropRangeAfterRegistration)
        end
    else
        
    end
    
    img1raw = img1raw(params.cropRangeAfterRegistration(2):params.cropRangeAfterRegistration(2)+params.cropRangeAfterRegistration(4), ...
        params.cropRangeAfterRegistration(1):params.cropRangeAfterRegistration(1)+params.cropRangeAfterRegistration(3),:);
else
    if params.imageRegistration && params.fixedOutputSize && ~isempty(params.registrationReferenceCropping)
        params.cropRange = params.registrationReferenceCropping;
        params.cropRangeAfterRegistration = params.cropRange;
        fprintf(' -> WARNING: crop range was confined by crop range of reference frame to [%d %d %d %d]\n',  params.cropRangeAfterRegistration)
        
        img1raw = img1raw(params.cropRangeAfterRegistration(2):params.cropRangeAfterRegistration(2)+params.cropRangeAfterRegistration(4), ...
            params.cropRangeAfterRegistration(1):params.cropRangeAfterRegistration(1)+params.cropRangeAfterRegistration(3),:);
    end
end

if params.exportVTKafterEachProcessingStep
    fprintf(' - saving intermediated processing results\n');
    if ~exist(fullfile(handles.settings.directory, 'data'), 'dir')
        mkdir(fullfile(handles.settings.directory, 'data'));
    end
    imwrite3D(img1raw, fullfile(handles.settings.directory, 'data', [files(f).name(1:end-4), '_cropped.tif']));
end
    
if params.fadeBottom && params.segmentationMethod == 2
    img1raw = fadeBottom(img1raw, params, silent);
end

if params.segmentationMethod==1
   [status, thresh] = determineSimpleThreshold(img1raw, params); 
else
    thresh = 0;
end


if ~silent
    displayStatus(handles, 'processing...', 'blue', 'add');
    updateWaitbar(handles, (f+0.2-range(1))/(1+range(end)-range(1)));
end

[imgfilter, params] = resizingAndDenoising(img1raw, metadata, params, silent);

if params.topHatFiltering
    
    imgfilter = topHatFilter(imgfilter, params);
end

if params.speedUpSSD
    parsave_img(fullfile(params.temp_directory_fullPath, 'img', ['img_', num2str(f), '.mat']),imgfilter, params);
end


