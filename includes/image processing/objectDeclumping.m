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
function [objects, status] = objectDeclumping(handles, imgfilter, imgfilter_edge_filled, regMax, params, filebase, prevData, f, metadata)
objects = [];
status = 0;

scaling_dxy = metadata.data.scaling.dxy * 1000; 

disp('== Object declumping ==');

fprintf(' - step 1: preparing image\n');

if params.removeVoxels
    ticValue = displayTime;
    fprintf('      step 1a: removing small stuff (less than %d connected voxels)', params.removeVoxelsOfSize);
    imgfilter_edge_filled = bwareaopen(imgfilter_edge_filled, params.removeVoxelsOfSize);
    displayTime(ticValue);
end

switch params.declumpingMethod
    case 1
    
    [objects, imgfilter, ImageContentFrame] = objectDeclumping_cube( ...
        handles, params, imgfilter_edge_filled, imgfilter, prevData);


    case 2
    
   [objects, imgfilter, ImageContentFrame] = objectDeclumping_none( ...
       handles, params, imgfilter_edge_filled, imgfilter, prevData);
   
    case 3
    
   [objects, imgfilter, ImageContentFrame] = objectDeclumping_labels( ...
       handles, params, imgfilter_edge_filled, imgfilter, prevData);

    
    otherwise
        error('Requested instance segmentation not implemented')
    
end

if checkCancelButton(handles)
    return;
end

ticValue = displayTime;
fprintf(' - step 6: obtain object parameters');
toUm3 = @(voxel, scaling) voxel.*(scaling/1000)^3;

if objects.NumObjects > 0
    
    stats = objects.stats;
    
    
    if numel(objects.ImageSize)==2
        centroids = cellfun(@(x) [x 1], {stats.Centroid}, 'UniformOutput', false);
        [stats.Centroid] = centroids{:};
        boundingBoxes = cellfun(@(x) [x(1:2) 0.5 x(3:4) 1], {stats.BoundingBox}, 'UniformOutput', false);
        [stats.BoundingBox] = boundingBoxes{:};
    end
    
    
    objects.stats = stats;
    Volume = num2cell(toUm3([objects.stats.Area], scaling_dxy)); 
    
    [objects.stats.Shape_Volume] = Volume{:};
    
    objects.stats = rmfield(objects.stats, 'Area');
    
    [objects.stats.(sprintf('Intensity_Mean_ch%d', params.channel))] = stats.MeanIntensity;
    objects.stats = rmfield(objects.stats, 'MeanIntensity');
    
    
    if params.segmentationMethod == 1
        thres = 0;
    else
        
        thres = params.I_base;
    end
    meanInt = [objects.stats.(sprintf('Intensity_Mean_ch%d', params.channel))];
    goodObjects = find(meanInt>thres);
    
    
    objects.NumObjects = numel(goodObjects);
    objects.stats = objects.stats(goodObjects);
    objects.PixelIdxList = objects.PixelIdxList(goodObjects);
    objects.goodObjects = true(numel(goodObjects), 1);
    
    displayTime(ticValue);
    
    if params.fixedOutputSize && params.imageRegistration
        objects.ImageContentFrame = ImageContentFrame;
    end
    objects.params = params;
    objects.metadata = metadata;
    
    
else
        objects.stats = struct('Shape_Volume', [], sprintf('Intensity_Mean_ch%d', params.channel), [], 'Centroid', [], 'BoundingBox', [], strrep([sprintf('Intensity_Mean_ch%d_gamma', params.channel), num2str(params.gamma)], '.', '_'), [], ...
            'Cube_VolumeFraction', [], 'Grid_ID', [], 'Cube_CenterCoord', []);
    objects.goodObjects = [];
    
    if params.fixedOutputSize && params.imageRegistration
        objects.ImageContentFrame = ImageContentFrame;
    end
    
    objects.params = params;
    objects.metadata = metadata;
    
    displayTime(ticValue);
    warning('backtrace', 'off')
    warning('NO CELLS FOUND!');
    warning('backtrace', 'on')
end

fprintf(' - step 7: saving variables [objects]');

filename = [filebase, '_data.mat'];

props = whos('objects');
if props.bytes*10^(-9)> 2 
    if handles.settings.showMsgs
        answer = questdlg('The data file representing your segmentation is too large to be saved efficiently. Please crop or downscale your data using the scale option. If you continue, subsequent steps of the analysis will be significantly slower.', ...
        'Data file too large', ...
        'Stop segmentation', 'Continue segmentation','Stop segmentation');

        switch answer
            case 'Stop segmentation'
                handles.uicontrols.pushbutton.pushbutton_cancel.UserData = 1;
                guidata(handles.uicontrols.pushbutton.pushbutton_cancel, handles);
                return;
            case 'Continue segmentation'
                saveObjects(filename, objects, 'all', 'init');
        end
    else
        warning('backtrace', 'off');
        warning('The data file representing your segmentation is too large to be saved!\nDo not save segmentation results of "%s" ...', filename);
        warning('backtrace', 'on');
    end
else
    saveObjects(filename, objects, 'all', 'init');
end

status = 1;



