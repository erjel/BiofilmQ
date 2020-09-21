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
function trackCubes(handles)
disp(['=========== Cube tracking ===========']);

hypot = @(a,b) sqrt((a(1)-b(1))^2 + (a(2)-b(2))^2 + (a(3)-b(3))^2);

params = load(fullfile(handles.settings.directory, 'parameters.mat'));
params = params.params;

range = str2num(params.action_imageRange);


scaling_dxy = params.scaling_dxy;
scaled_searchRadius = params.searchRadius/(scaling_dxy/1000);

if params.trackCellsDilate
    trackCellsDilatePx = params.trackCellsDilatePx;
else
    trackCellsDilatePx = 0;
end
trackMethod = params.trackMethod;

files = handles.settings.lists.files_cells;
validFiles = find(cellfun(@(x) isempty(x), strfind({files.name}, 'missing')));
range_new = intersect(range, validFiles);

if numel(range) ~= numel(range_new)
    fprintf('NOTE: Image range was adapted to [%d, %d]\n', min(range_new), max(range_new));
end
range = range_new;

if isempty(range)
    return;
end

data = [];

try
    enableCancelButton(handles)
end

if range(1) > 1
    disp(['=========== Loading parents/grandparents ===========']);
end

if ~params.trackingStartNewSeries && range(1)>validFiles(1)
    if range(1) > validFiles(2) 
        data{3}.objects = loadObjects(fullfile(handles.settings.directory, 'data', files(range(1)-2).name));
        if data{3}.objects.NumObjects==0
            data = data(1:2);
        end
    end
    
    data{2}.objects = loadObjects(fullfile(handles.settings.directory, 'data', files(range(1)-1).name));
    objects2 = data{2}.objects;
    
    if objects2.NumObjects == 0 || ~isfield(objects2.stats, 'Track_ID')
        params.trackingStartNewSeries = 1;
    else
        PixelIdxList2 = objects2.PixelIdxList;
        imageSize = objects2.ImageSize;
        PixelIdxList2_exp = cell(size(PixelIdxList2));
        
        maxTrack_ID = max([objects2.stats.Track_ID]);
        
        
        parfor obj2ID = 1:objects2.NumObjects
            if trackCellsDilatePx > 0
                shell = setxor(neighbourND(PixelIdxList2{obj2ID}, imageSize), PixelIdxList2{obj2ID});
                
                for i = 2:trackCellsDilatePx-1
                    shell = union(neighbourND(shell, imageSize), shell);
                end
                PixelIdxList2_exp{obj2ID} = union(shell, PixelIdxList2{obj2ID});
            end
        end
        
    end
end
if params.trackingStartNewSeries || range(1)<=validFiles(1)
    
    data{2}.objects = loadObjects(fullfile(handles.settings.directory, 'data', files(range(1)).name));
    objects2 = data{2}.objects;
    PixelIdxList2 = objects2.PixelIdxList;
    imageSize = objects2.ImageSize;
    PixelIdxList2_exp = cell(size(PixelIdxList2));
    
    parents = num2cell(zeros(objects2.NumObjects,1));
    grandparents = num2cell(zeros(objects2.NumObjects,1));
    
    
    [objects2.stats.Track_Parent] = parents{:};
    [objects2.stats.Track_Grandparent] = grandparents{:};
    
    
    switch trackMethod
        case 1
            if params.considerSiblings
                [siblings, ~] = findSiblings(objects2, 1:objects2.NumObjects);
            else
                siblings = 1:objects2.NumObjects;
            end
            groups = unique(siblings);
            id = 1;
            Track_IDs = zeros(objects2.NumObjects,1);
            for k = 1:length(groups)
                Track_IDs(siblings==groups(k))= id;
                id = id+1;
            end
            Track_IDs = num2cell(Track_IDs);
            [objects2.stats.Track_ID] = Track_IDs{:};
        case 2
            startTrack_ID = num2cell(ones(size(parents)));
            [objects2.stats.Track_ID] = startTrack_ID{:};
    end
    
    maxTrack_ID = max([objects2.stats.Track_ID]);
    objects2.maxTrack_ID = maxTrack_ID;
    
    
    parfor obj2ID = 1:objects2.NumObjects 
        if trackCellsDilatePx > 0
            shell = setxor(neighbourND(PixelIdxList2{obj2ID}, imageSize), PixelIdxList2{obj2ID});
            
            for i = 2:trackCellsDilatePx-1
                shell = union(neighbourND(shell, imageSize), shell);
            end
            PixelIdxList2_exp{obj2ID} = union(shell, PixelIdxList2{obj2ID});
        else
            PixelIdxList2_exp{obj2ID} = PixelIdxList2{obj2ID};
        end
    end
    
    data{2}.objects = objects2;
    
    
    objects2 = calculateGrowthRate([], objects2, params, 'init');
    
    saveObjects(fullfile(handles.settings.directory, 'data', files(range(1)).name), objects2, 'stats', '-append');
    range(1) = [];
end

for f = range
    
    disp(['=========== Tracking image ', num2str(f), ' of ', num2str(length(files)), ' ===========']);
    
    updateWaitbar(handles, (f-range(1))/(1+range(end)-range(1))+0.01);
    displayStatus(handles,['Tracking cells ', num2str(f), ' of ', num2str(length(files)), '...'], 'blue')
    
    ticValue = displayTime;
    
    data{1} = data{2};
    data{2}.objects = loadObjects(fullfile(handles.settings.directory, 'data', files(f).name));
    PixelIdxList1_exp = PixelIdxList2_exp;
    
    PixelIdxList2 = data{2}.objects.PixelIdxList;
    
    
    parfor objid = 1:data{2}.objects.NumObjects 
        if trackCellsDilatePx > 0
            shell = setxor(neighbourND(PixelIdxList2{objid}, imageSize), PixelIdxList2{objid});
            
            for i = 2:trackCellsDilatePx-1
                shell = union(neighbourND(shell, imageSize), shell);
            end
            PixelIdxList2_exp{objid} = union(shell, PixelIdxList2{objid});
        else
            PixelIdxList2_exp{objid} = PixelIdxList2{objid};
        end
    end
    
    
    noParent = zeros(data{2}.objects.NumObjects,1);
    stats2 = data{2}.objects.stats;
    centroids_2 = {stats2.Cube_CenterCoord};
    
    
    stats1 = data{1}.objects.stats;
    centroids_1 = {stats1.Cube_CenterCoord};
    parents_1 = [stats1.Track_Parent];
    ids_1 = [stats1.Track_ID];
    volume_1 = [stats1.Shape_Volume];
    
    
    if length(data)==3
        stats3 = data{3}.objects.stats;
        centroids_3 = {stats3.Cube_CenterCoord};
        parents_3 = [stats3.Track_Parent];
        ids_3 = [stats3.Track_ID];
        useGrandparent = 1;
    else
        centroids_3 = {};
        parents_3 = [];
        ids_3 = [];
        useGrandparent = 0;
    end
    parents = zeros(data{2}.objects.NumObjects,1);
    grandparents = zeros(data{2}.objects.NumObjects,1);
    Track_ID = zeros(data{2}.objects.NumObjects,1);
    distanceToParent = zeros(data{2}.objects.NumObjects,1);
    overlapWithParent = zeros(data{2}.objects.NumObjects,1);
    parfor k = 1:data{2}.objects.NumObjects
        
        coords = centroids_2{k};
        
        coordsEqual = @(x) sum(x==coords)==length(coords);
        
        if ~isempty(centroids_1{1})
            prevIndex = find(cellfun(coordsEqual, centroids_1),1);
            
            
            if ~isempty(prevIndex)
                parents(k) = prevIndex;
                grandparents(k) = parents_1(prevIndex);
                Track_ID(k) = ids_1(prevIndex);
                
            elseif useGrandparent && ~isempty(centroids_3{1})
                prevIndex = find(cellfun(coordsEqual, centroids_3),1);
                if ~isempty(prevIndex)
                    parents(k) = NaN;
                    grandparents(k) = parents_3(prevIndex);
                    Track_ID(k) = ids_3(prevIndex);
                end
            end
            
            
            if isempty(prevIndex)
                adjacent = @(x) hypot(x, coords);
                distance = cell2mat(cellfun(adjacent, centroids_1, 'Uniformoutput', false));
                neighbours = distance < scaled_searchRadius;
                neighbours = find(neighbours);
                
                if length(neighbours)==1
                    index = neighbours;
                    parents(k) = index;
                    grandparents(k) = parents_1(index);
                    Track_ID(k) = ids_1(index);
                    distanceToParent(k) = distance(neighbours);
                elseif length(neighbours)>1
                    
                    
                    calcOverlap = @(x) sum(ismember(x,PixelIdxList2_exp{k}));
                    overlap = cellfun(calcOverlap, PixelIdxList1_exp(neighbours), 'Uniformoutput', false);
                    overlap = cell2mat(overlap);
                    if sum(overlap)>0
                        [maxOverlap,index] = max(overlap);
                        overlapWithParent(k) = maxOverlap;
                        distanceToParent(k) = distance(index);
                        index = neighbours(index);
                        parents(k) = index;
                        grandparents(k) = parents_1(index);
                        Track_ID(k) = ids_1(index);
                        
                    else
                        neighbours = find(distance==min(distance));
                        [~, index] = max(volume_1(neighbours));
                        distanceToParent(k) = min(distance);
                        index = neighbours(index);
                        parents(k) = index;
                        grandparents(k) = parents_1(index);
                        Track_ID(k) = ids_1(index);
                    end
                end
            end
            
        elseif useGrandparent && ~isempty(centroids_3{1})
            prevIndex = find(cellfun(coordsEqual, centroids_3),1);
            if ~isempty(prevIndex)
                parents(k) = NaN;
                grandparents(k) = parents_3(prevIndex);
                Track_ID(k) = ids_3(prevIndex);
            end
            
        end
    end
    
    if handles.uicontrols.checkbox.considerSiblings.Value
        
        
        newObjects = find(parents==0);
        [siblings, dists] = findSiblings(data{2}.objects, newObjects);
        
        
        
        newTrack = [];
        for k = 1:length(newObjects)
            ind = newObjects(k);
            if ismember(siblings(ind), newTrack)
                continue;
            end
            
            neighbours = siblings==siblings(ind);
            
            hasParent = neighbours & parents~=0;
            
            
            
            if sum(hasParent)>0
                distance = dists(hasParent);
                [~, index] = min(distance);
                hasParent_id = find(hasParent);
                
                parents(ind) = parents(hasParent_id(index(1)));
                grandparents(ind) = grandparents(hasParent_id(index(1)));
                Track_ID(ind) = Track_ID(hasParent_id(index(1)));
            else
                
                
                Track_ID(neighbours)= maxTrack_ID +1 ;
                maxTrack_ID = maxTrack_ID + 1;
                newTrack = siblings(ind);
            end
            
        end
        
    elseif sum(parents==0)>0
        
        newTrackIDs = maxTrack_ID + (1:sum(parents==0));
        Track_ID(parents==0) = newTrackIDs;
        maxTrack_ID = max(newTrackIDs);
        
    end
    
    
    
    fprintf('   - related cells: %d, new cells: %d, max Track_ID: %d\n', sum(parents>0), sum(parents==0), maxTrack_ID);
    
    parents = num2cell(parents);
    grandparents = num2cell(grandparents);
    Track_ID = num2cell(Track_ID);
    if isempty(Track_ID)
        [stats2.Track_ID] = [];
        [stats2.Track_Parent] = [];
        [stats2.Track_Grandparent] = [];
    else
        [stats2.Track_Parent] = parents{:};
        [stats2.Track_Grandparent] = grandparents{:};
        [stats2.Track_ID] = Track_ID{:};
    end
    
    data{2}.objects.stats = stats2;
    
    
    data{2}.objects = calculateGrowthRate(data{1}.objects, data{2}.objects, params);
    
    saveObjects(fullfile(handles.settings.directory, 'data', files(f).name), data{2}.objects, 'stats', '-append');
    
    data{3}.objects = data{1}.objects;
    
    displayStatus(handles, 'Done', 'blue', 'add');
    
    if checkCancelButton(handles)
        break;
    end
end

    function [siblings, dists] = findSiblings(objects, newObjects)
        
        siblings = zeros(objects.NumObjects,1);
        dists = zeros(length(newObjects), objects.NumObjects);
        centers = {objects.stats.Cube_CenterCoord};
        for v = 1:length(newObjects)
            indexObject = newObjects(v);
            coordsObject = centers{indexObject};
            
            findNeighbours = @(x) hypot(x, coordsObject);
            d = cellfun(findNeighbours, centers);
            dists(v, :) = d;
            neighboursObject = d < scaled_searchRadius;
            
            
            
            
            if sum(siblings(neighboursObject))>0
                neigh = find((siblings&neighboursObject')~=0);
                for m = 1:length(neigh)
                    siblings(siblings==siblings(neigh(m))) = indexObject;
                end
            end
            siblings(neighboursObject) = indexObject;
        end
    end



updateWaitbar(handles, 0);
disp('Done');
end


