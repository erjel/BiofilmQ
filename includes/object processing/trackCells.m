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
function trackCells(handles)
disp(['=========== Cell tracking ===========']);

fhypot = @(a,b,c) sqrt(abs(a).^2+abs(b).^2+abs(c).^2);
overlap3D = @(a,b) sum(ismember(a,b));
determineCellAngles = @(a,b) abs(dot(a(:,1), b(:,1)));


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
    uiwait(msgbox('No object files present.', 'Error', 'error', 'modal'));
    fprintf('No object files present -> Processing cancelled.\n');
    return;
end


object = loadObjects(fullfile(handles.settings.directory, 'data', files(range_new(1)).name));
if object.params.declumpingMethod == 1
    trackCubes(handles);
    return;
end

data = [];

maxTrack_ID = 0;

try
    enableCancelButton(handles)
end

if range(1) > 1
    disp(['=========== Loading parents/grandparents ===========']);
end

if ~params.trackingStartNewSeries
    if range(1) > 2 
        data{3}.objects = loadObjects(fullfile(handles.settings.directory, 'data', files(range(1)-2).name));
    end
    if range(1) > 1
        data{2}.objects = loadObjects(fullfile(handles.settings.directory, 'data', files(range(1)-1).name));
        objects2 = data{2}.objects;
        PixelIdxList2 = objects2.PixelIdxList;
        imageSize = objects2.ImageSize;
        PixelIdxList2_exp = cell(size(PixelIdxList2));
        
        if isfield(objects2, 'maxTrack_ID')
            maxTrack_ID = objects2.maxTrack_ID;
        else
            maxTrack_ID = max([objects2.stats.Track_ID]);
        end
        
        
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
        
    end
else
    data{2}.objects = loadObjects(fullfile(handles.settings.directory, 'data', files(range(1)).name));
    range(1) = [];
    objects2 = data{2}.objects;
    PixelIdxList2 = objects2.PixelIdxList;
    imageSize = objects2.ImageSize;
    PixelIdxList2_exp = cell(size(PixelIdxList2));
    
    parents = num2cell(zeros(objects2.NumObjects,1));
    grandparents = num2cell(zeros(objects2.NumObjects,1));
    Track_IDs = num2cell(1:double(objects2.NumObjects));
    
    
    [objects2.stats.parent] = parents{:};
    [objects2.stats.grandparent] = grandparents{:};
    
    switch trackMethod
        case 1
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
    saveObjects(fullfile(handles.settings.directory, 'data', files(range(1)-1).name), objects2, 'stats', '-append');
end

for i = 1:numel(range)
    f = range(i);
    
    metadata = load(fullfile(handles.settings.directory, strrep(files(f).name, '_data.mat', '_metadata.mat')));
    params.scaling_dxy = metadata.data.scaling.dxy * 1000;
    
    disp(['=========== Loading image ', num2str(f), ' of ', num2str(length(files)), ' ===========']);
    
    updateWaitbar(handles, (f-range(1))/(1+range(end)-range(1)));
    displayStatus(handles,['Tracking cells ', num2str(f), ' of ', num2str(length(files)), '...'], 'blue');
    
    if i == 1
        data{2}.objects = loadObjects(fullfile(handles.settings.directory, 'data', files(f).name));
        objects2 = data{2}.objects;
        
        
        objects2 = calculateGrowthRate([], objects2, params, 'init');
        
        
        objects2 = calculateVelocity([], objects2, params, 'init');
        
        try
            objects2 = rmfield(objects2, 'Track_Parent');
        end
        try
            objects2 = rmfield(objects2, 'Track_Grandparents');
        end
        disp(' - reference frame');
    end
    
    if i > 1
        ticValue = displayTime;
        
        data{1} = data{2};
        data{2}.objects = loadObjects(fullfile(handles.settings.directory, 'data', files(f).name));
        PixelIdxList1_exp = PixelIdxList2_exp;
        
        
        objects1 = data{1}.objects;
        try
            objects1 = rmfield(objects1, 'Track_Parent');
        end
        try
            objects1 = rmfield(objects1, 'Track_Grandparent');
        end
        objects2 = data{2}.objects;
        try
            objects2 = rmfield(objects2, 'Track_Parent');
        end
        try
            objects2 = rmfield(objects2, 'Track_Grandparent');
        end
        
        
        if ~isfield(objects1.stats, 'Orientation_Matrix')
            fprintf('    - determining cell orientations');
            objects1 = calculateObjectSizeAndOrientationEllipsoidalFit(objects1);
        end
        if ~isfield(objects2.stats, 'Orientation_Matrix')
            fprintf('    - determining cell orientations');
            objects2 = calculateObjectSizeAndOrientationEllipsoidalFit(objects2);
        end
        
        disp([' - children: ', num2str(objects2.NumObjects), ', parents: ', num2str(objects1.NumObjects)]);
        
        PixelIdxList1 = objects1.PixelIdxList;
        PixelIdxList2 = objects2.PixelIdxList;
        
        
        fprintf(' - calculating overlap');
        
        coords1 = [objects1.stats.Centroid];
        coords2 = {objects2.stats.Centroid};
        coords2_array = [objects2.stats.Centroid];
        
        x = coords1(1:3:end);
        y = coords1(2:3:end);
        z = coords1(3:3:end);
        
        imageSize = objects2.ImageSize;
        
        nObj1 = objects1.NumObjects;
        nObj2 = objects2.NumObjects;
        Track_ID1 = [objects1.stats.Track_ID];
        Track_ID2 = zeros(nObj2,1);
        parent = zeros(nObj2,1);
        grandparent = zeros(nObj2,1);
        

        evecs1 = {objects1.stats.Orientation_Matrix};
        evecs2 = {objects2.stats.Orientation_Matrix};
        
        displayStatus(handles, 'calculating 3D-overlap...', 'blue', 'add');
        updateWaitbar(handles, (f+0.3-range(1))/(1+range(end)-range(1)));
        
        PixelIdxList2_exp = cell(size(PixelIdxList2));
        probablyNewCell = false(1, nObj2);
        
        
        parfor obj2ID = 1:nObj2 
            
            if trackCellsDilatePx > 0
                shell = setxor(neighbourND(PixelIdxList2{obj2ID}, imageSize), PixelIdxList2{obj2ID});
                
                for j = 2:trackCellsDilatePx-1
                        shell = union(neighbourND(shell, imageSize), shell);
                end
                PixelIdxList2_exp{obj2ID} = union(shell, PixelIdxList2{obj2ID});
            end
            
            
            coordsOfActualCell = coords2{obj2ID};
            
            dist = fhypot(coordsOfActualCell(1)-x, coordsOfActualCell(2)-y, coordsOfActualCell(3)-z);
            
            cellsCloseBy = find(dist<scaled_searchRadius);
            
            if ~isempty(cellsCloseBy) && ~isempty(evecs2{obj2ID})
                
                angles = cellfun(@(x) determineCellAngles(x, evecs2{obj2ID}), evecs1(cellsCloseBy));
                
                
                overlappingObjects = [cellfun(overlap3D, PixelIdxList1_exp(cellsCloseBy), ...
                    repmat(PixelIdxList2_exp(obj2ID),size(PixelIdxList1_exp(cellsCloseBy))))' cellsCloseBy', angles'];

                
                
                
                [~, index] = sort((overlappingObjects(:,1)+overlappingObjects(:,1).*overlappingObjects(:,3))/2, 'descend'); 
                
                overlappingObjects = overlappingObjects(index,:);
                
                if overlappingObjects(1,1) > 0
                    
                    parent(obj2ID) = overlappingObjects(1,2);
                    Track_ID2(obj2ID) = Track_ID1(parent(obj2ID));
                else
                    
                    
                    probablyNewCell(obj2ID) = 1;
                    
                    
                    
                    
                    
                end
            else
                
                
                probablyNewCell(obj2ID) = 1;
                
                
                
                
            end
        end
        
        displayTime(ticValue);
        
        
        
        
        ticValue = displayTime;
        obj2ID_noNeighbors = find(probablyNewCell);
        reLinkCounter = 0;
        if ~isempty(obj2ID_noNeighbors)
            newCell = false(1, nObj2);
            
            fprintf(' - treating cells with no parents');
            for obj2ID = obj2ID_noNeighbors
                
                
                
                coordsOfActualCell = coords2{obj2ID};
                
                x = coords2_array(1:3:end);
                y = coords2_array(2:3:end);
                z = coords2_array(3:3:end);
                
                dist = fhypot(coordsOfActualCell(1)-x, coordsOfActualCell(2)-y, coordsOfActualCell(3)-z);
                
                cellsCloseBy = find(dist<scaled_searchRadius);
                
                cellsCloseBy(cellsCloseBy == obj2ID) = [];
                
                shell = setxor(neighbourND(PixelIdxList2{obj2ID}, imageSize), PixelIdxList2{obj2ID});
                
                
                if ~isempty(cellsCloseBy) && ~isempty(evecs2{obj2ID})
                    
                    angles = cellfun(@(x) determineCellAngles(x, evecs2{obj2ID}), evecs2(cellsCloseBy));
                    
                    
                    overlappingObjects = [ ...
                        cellfun(@(x) overlap3D(x, shell), PixelIdxList2(cellsCloseBy))' ...
                        cellsCloseBy', angles'];
                    
                    [~, index] = sort((overlappingObjects(:,1)+overlappingObjects(:,1).*overlappingObjects(:,3))/2, 'descend'); 
                    
                    overlappingObjects = overlappingObjects(index,:);
                    
                    if overlappingObjects(1,1) > 0
                        
                        if ~Track_ID2(overlappingObjects(1,2))
                            maxTrack_ID = maxTrack_ID + 1;
                            Track_ID2(overlappingObjects(1,2)) = maxTrack_ID;
                            Track_ID2(obj2ID) = maxTrack_ID;
                        else
                            Track_ID2(obj2ID) = Track_ID2(overlappingObjects(1,2));
                        end
                        reLinkCounter = reLinkCounter + 1;
                        parent(obj2ID) = parent(overlappingObjects(1,2));
                    else
                        
                        newCell(obj2ID) = 1;
                    end
                else
                    
                    newCell(obj2ID) = 1;
                end
            end
            displayTime(ticValue);
            
            
            
            
            obj2ID_noNeighbors = find(newCell);
            if ~isempty(obj2ID_noNeighbors)
                if i > 2
                    evecs3 = {data{3}.objects.stats.Orientation_Matrix};
                end
                for obj2ID = obj2ID_noNeighbors
                    if i > 2
                        assignNewTrack_ID = 0;
                        
                        
                        
                        coordsOfActualCell = coords2{obj2ID};
                        coords3 = [data{3}.objects.stats.Centroid];
                        
                        x = coords3(1:3:end);
                        y = coords3(2:3:end);
                        z = coords3(3:3:end);
                        
                        dist = fhypot(coordsOfActualCell(1)-x, coordsOfActualCell(2)-y, coordsOfActualCell(3)-z);
                        
                        searchRadius = 0.8; 
                        cellsCloseBy = find(dist<searchRadius/(scaling_dxy/1000));
                        
                        if ~isempty(cellsCloseBy)
                            angles = cellfun(@(x) determineCellAngles(x, evecs2{obj2ID}), evecs3(cellsCloseBy));
                            
                            
                            overlappingObjects = [ ... 
                                cellfun(@(x) overlap3D(x, PixelIdxList2{obj2ID}), data{3}.objects.PixelIdxList(cellsCloseBy))' ...
                                cellsCloseBy', angles'];
                            
                            [~, index] = sort(overlappingObjects(:,1), 'descend'); 
                            
                            if overlappingObjects(index(1),3) > 0.8 ... 
                                    && overlappingObjects(index(1),1) > 0.5*numel(data{3}.objects.PixelIdxList{cellsCloseBy(index(1))}) ...
                                    && overlappingObjects(index(1),1) > 0.5*numel(PixelIdxList2{obj2ID}) 
                                
                                
                                reLinkCounter = reLinkCounter + 1;
                                parent(obj2ID) = NaN;
                                grandparent(obj2ID) = cellsCloseBy(index(1));
                                Track_ID2(obj2ID) = data{3}.objects.stats(cellsCloseBy(index(1))).Track_ID;
                            else
                                assignNewTrack_ID = 1;
                            end
                        else
                            assignNewTrack_ID = 1;
                        end
                    else
                        assignNewTrack_ID = 1;
                    end
                    
                    if assignNewTrack_ID
                        parent(obj2ID) = 0;
                        maxTrack_ID = maxTrack_ID + 1;
                        Track_ID2(obj2ID) = maxTrack_ID;
                    end
                    
                end
            end
        end
        
        fprintf('   - relations: %d, new cells: %d, re-linked cells: %d, max Track_ID: %d\n', sum(parent>0), sum(parent==0), reLinkCounter, maxTrack_ID);
        
        parent = num2cell(parent);
        [objects2.stats.Track_Parent] = parent{:};
        
        grandparent = num2cell(grandparent);
        [objects2.stats.Track_Grandparent] = grandparent{:};
        
        objects2.maxTrack_ID = maxTrack_ID;
        
        NNewTracks = length(Track_ID2(Track_ID2 == max(Track_ID1)+1));
        Track_ID2(Track_ID2 == max(Track_ID1)+1) = max(Track_ID1)+1:max(Track_ID1)+NNewTracks;
        
        Track_ID2 = num2cell(Track_ID2);
        [objects2.stats.Track_ID] = Track_ID2{:};
        
        
        objects2 = calculateGrowthRate(objects1, objects2, params);
        
        
        objects2 = calculateVelocity(objects1, objects2, params);
        
        data{3} = data{1};
        data{1}.objects = objects1;
        data{2}.objects = objects2;
        
        if checkCancelButton(handles)
            break;
        end
        
    else
        PixelIdxList2 = objects2.PixelIdxList;
        imageSize = objects2.ImageSize;
        PixelIdxList2_exp = cell(size(PixelIdxList2));
        
        parents = num2cell(zeros(objects2.NumObjects,1));
        grandparents = num2cell(zeros(objects2.NumObjects,1));
        Track_IDs = num2cell(1:double(objects2.NumObjects));
        
        [objects2.stats.Track_Parent] = parents{:};
        [objects2.stats.Track_Grandparent] = grandparents{:};
        
        switch trackMethod
            case 1
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
                
                for j = 2:trackCellsDilatePx-1
                        shell = union(neighbourND(shell, imageSize), shell);
                end
                PixelIdxList2_exp{obj2ID} = union(shell, PixelIdxList2{obj2ID});
            end
        end
    end
    objects = objects2;
    
    data{2}.objects = objects;
    
    displayStatus(handles, 'updating file...', 'blue', 'add');
    updateWaitbar(handles, (f+0.3-range(1))/(1+range(end)-range(1)));
    
    saveObjects(fullfile(handles.settings.directory, 'data', files(f).name), objects, 'stats', '-append')
    displayStatus(handles, 'Done', 'blue', 'add');
    
    if checkCancelButton(handles)
        break;
    end
end


if params.sendEmail
    try
        email_to = get(handles.uicontrols.edit.email_to, 'String');
        email_from = get(handles.uicontrols.edit.email_from, 'String');
        email_smtp = get(handles.uicontrols.edit.email_smtp, 'String');
        
        setpref('Internet','E_mail',email_from);
        setpref('Internet','SMTP_Server',email_smtp);
        
        sendmail(email_to,['[Biofilm Toolbox] Cell tracking finished: "', handles.settings.directory, '"']', ...
            ['Cell tracking of "', handles.settings.directory, '" finished (Range: ', num2str(range(1)), ':', num2str(range(end)), ').', ]);
    end
end


updateWaitbar(handles, 0);
disp('Done');


