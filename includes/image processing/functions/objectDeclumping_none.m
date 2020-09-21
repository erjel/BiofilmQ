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
function [objects, imgfilter, ImageContentFrame] = objectDeclumping_none(handles, params, imgfilter_edge_filled, imgfilter, prevData)
 disp(' - step 2: finding connected components');
    w = imgfilter_edge_filled;
    w = bwlabeln(w);


    if checkCancelButton(handles)
        toggleBusyPointer(handles, false);
        return;
    end

    
    try
        if params.removeBottomSlices
            if params.removeBottomSlices < size(w, 3)
                w = w>0;
                w(:,:,1:params.removeBottomSlices) = [];
                imgfilter(:,:,1:params.removeBottomSlices) = [];
                w = bwlabeln(w);
            else
                warning('backtrace', 'off');
                warning('Cannot remove %d bottom slice(s), as biofilm is not thick enough!', params.removeBottomSlices)
                warning('backtrace', 'on');
            end
        end
    end

    if params.median3D
        ticValue = displayTime;
        fprintf('      step 3b: 3D median filter');
        

        try
            w_med = medfilt3(w>0);
        catch
            if params.waitForMemory
                checkMemory(handles, 30);
            end
            w_med = ordfilt3D(w>0, 14);
        end
        w(~w_med) = 0;

        displayTime(ticValue);
    end

    if checkCancelButton(handles)
        return;
    end

    
    if params.fixedOutputSize && params.imageRegistration
        ticValue = displayTime;
        fprintf('      step 3c: padding image');

        w = applyReferencePadding(params, w);
        [imgfilter, x, y] = applyReferencePadding(params,imgfilter);

        ImageContentFrame = [min(x) max(x) min(y) max(y)];

        displayTime(ticValue);
    else
        ImageContentFrame = [];
    end

    if checkCancelButton(handles)
        return;
    end
    
    
    fprintf(' - step 4: finding connected components');
    ticValue = displayTime;
    objects = conncomp(w);
    fprintf(', found %d objects', objects.NumObjects);
    displayTime(ticValue);
    
    
    
    fprintf(' - step 5: obtain object sizes\n');
    objects.stats = regionprops(objects, 'Area');
    
    
    area = [objects.stats.Area];
    if params.removeVoxels
        smallObj = area < params.removeVoxelsOfSize;
        smallObjInd = find(smallObj);
        if ~isempty(smallObjInd)
            fprintf('      removing %d small cells (< %d voxels)\n', sum(smallObj), params.removeVoxelsOfSize);
            objects.PixelIdxList = objects.PixelIdxList(~smallObj);
            objects.NumObjects = sum(~smallObj);
            objects.stats = objects.stats(~smallObj);
        end
    else
        smallObj = area==1;
        smallObjInd = find(smallObj);
        if ~isempty(smallObjInd)
            fprintf('      removing %d very small cells (1 vox)\n', sum(smallObj));
            objects.PixelIdxList = objects.PixelIdxList(~smallObj);
            objects.NumObjects = sum(~smallObj);
            objects.stats = objects.stats(~smallObj);
        end
    end
    
    
    
    stats = regionprops(objects, imgfilter, 'Area', 'MeanIntensity', 'Centroid', 'BoundingBox');
    objects.stats = stats;


