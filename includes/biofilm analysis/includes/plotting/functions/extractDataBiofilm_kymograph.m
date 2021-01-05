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
function [X, Y, map, N, Z] = extractDataBiofilm_kymograph(biofilmData, varargin)

database = checkInput(varargin, 'database', 'stats');
scaleX = checkInput(varargin, 'scaleX', 'linear');
scaleY = checkInput(varargin, 'scaleY', 'linear');
rangeX = checkInput(varargin, 'rangeX', [1 10^4]);
fitCellNumber = checkInput(varargin, 'fitCellNumber', true);
NBinsX = checkInput(varargin, 'NBinsX', 50);
rangeY = checkInput(varargin, 'rangeY', []);
NBinsY = checkInput(varargin, 'NBinsY', 40);
timeIntervals = checkInput(varargin, 'timeIntervals', []); 
timeShift = checkInput(varargin, 'timeShift', []); 
scaling = checkInput(varargin, 'scaling', 0.0632);
fieldX = checkInput(varargin, 'fieldX', 'Frame');
fieldY = checkInput(varargin, 'fieldY', 'Frame');
fieldZ = checkInput(varargin, 'fieldZ', 'Frame');
removeZOffset = checkInput(varargin, 'removeZOffset', true);
averagingFcn = checkInput(varargin, 'averagingFcn', 'nanmean');
if isempty(averagingFcn)
   averagingFcn = 'nanmean'; 
end
interpolate = checkInput(varargin, 'interpolate', false);
filterExpr = checkInput(varargin, 'filterExpr', '');
clusterBiofilm = checkInput(varargin, 'clusterBiofilm', false);
normalizeByBiovolume = checkInput(varargin, 'normalizeByBiovolume', false);

clear varargin;

IsRelatedToFounderCells = cell(numel(biofilmData.data), 1);
for i = 1:numel(biofilmData.data)
    if clusterBiofilm
        IsRelatedToFounderCells{i} = logical([biofilmData.data(i).stats.IsRelatedToFounderCells]);
    else
        IsRelatedToFounderCells{i} = true(biofilmData.data(i).NumObjects, 1);
    end
end

if strcmpi(fieldX, 'Cell_Number') || strcmpi(fieldY, 'Cell_Number') || strcmpi(fieldZ, 'Cell_Number')
   
        
        cellNumber = [];
        
        for i = 1:numel(biofilmData.data)
            cellNumber(i) = sum(biofilmData.data(i).goodObjects(IsRelatedToFounderCells{i}));
        end
        x = 1:numel(biofilmData.data);
        
        
        if fitCellNumber && (strcmp(fieldX, 'Cell_Number') || strcmp(fieldY, 'Cell_Number'))
            Nfit = smoothCellNumber(x, cellNumber);
        end
end

if isempty(timeIntervals)
    timeIntervals = 1:numel(biofilmData.data);
end

timeIntervals = timeIntervals/60/60;


time = cumsum(timeIntervals)+timeShift;


if isempty(rangeX)
    [~, rangeX] = returnUnitLabel(fieldX, data);
end
if isempty(rangeY)
    [~, rangeY] = returnUnitLabel(fieldY, data);
end

switch fieldX
    case 'Time'
        
        times_in_range  = find(time>=rangeX(1) & time<=rangeX(2));
        binsX = [time(times_in_range); time(times_in_range(end)) + timeIntervals(times_in_range(end))];

    otherwise
        switch scaleX
            case 'log'
                binsX = logspace(log10(rangeX(1)), log10(rangeX(2)), NBinsX);
            case 'linear'
                binsX = linspace(rangeX(1), rangeX(2), NBinsX);
        end
end

switch fieldY
    case 'Time'
        times_in_range  = find(time>=rangeY(1) & time<=rangeY(2));
        binsY = [time(times_in_range); time(times_in_range(end))+timeIntervals(times_in_range(end))];
        
    otherwise
        
        switch scaleY
            case 'log'
                if rangeY(1) == 0
                    rangeY(1) = 1;
                end
                binsY = logspace(log10(rangeY(1)), log10(rangeY(2)), NBinsY);
            case 'linear'
                binsY = linspace(rangeY(1), rangeY(2), NBinsY);
        end
end

if removeZOffset && (strcmp(fieldX, 'Distance_FromSubstrate') || strcmp(fieldY, 'Distance_FromSubstrate') || strcmp(fieldZ, 'Distance_FromSubstrate'))
    zOffset = zeros(1, numel(biofilmData.data));
    for i = 1:numel(biofilmData.data)
        try
            centroids = [biofilmData.data(i).stats(IsRelatedToFounderCells{i}).Centroid];
            centroids_z = centroids(3:3:end);
            zOffset(i) = min(centroids_z);
        catch
            zOffset(i) = NaN;
        end
    end
    zOffset = nanmedian(zOffset);
else
    zOffset = 0;
end

[X, Y] = meshgrid(binsX, binsY);
Z = cell(size(X));
if normalizeByBiovolume
   B = cell(size(X));
end
ignoringData = false;
warning('backtrace', 'off')
for i = 1:numel(biofilmData.data)
    try
        switch fieldX
            case 'Cell_Number'
                
                if fitCellNumber
                    x = Nfit(i);
                    try
                        N = sum(biofilmData.data(i).goodObjects(IsRelatedToFounderCells{i})); 
                    catch
                        N = biofilmData.data(i).NumObjects; 
                    end
                    x = repmat(x, 1, N);
                else
                    try
                        x = sum(biofilmData.data(i).goodObjects(IsRelatedToFounderCells{i})); 
                    catch
                        x = biofilmData.data(i).NumObjects; 
                    end
                    x = repmat(x, 1, x);
                end
                
            case 'Time'
                x = getData(biofilmData.data(i), database, fieldX, scaling, zOffset, filterExpr, clusterBiofilm)+timeShift;
                
            otherwise
                x = getData(biofilmData.data(i), database, fieldX, scaling, zOffset, filterExpr, clusterBiofilm);
        end
        
        switch fieldY
            case 'Cell_Number'
                
                if fitCellNumber
                    y = Nfit(i);
                    try
                        N = sum(biofilmData.data(i).goodObjects(IsRelatedToFounderCells{i})); 
                    catch
                        N = biofilmData.data(i).NumObjects; 
                    end
                    y = repmat(y, 1, N);
                else
                    try
                        y = sum(biofilmData.data(i).goodObjects(IsRelatedToFounderCells{i})); 
                    catch
                        y = biofilmData.data(i).NumObjects; 
                    end
                    y = repmat(y, 1, y);
                end
                
            case 'Time'
                y = getData(biofilmData.data(i), database, fieldY, scaling, zOffset, filterExpr, clusterBiofilm)+timeShift;
                
            otherwise
                y = getData(biofilmData.data(i), database, fieldY, scaling, zOffset, filterExpr, clusterBiofilm);
        end
        
        switch fieldZ
            case 'Cell_Number'
                
                if fitCellNumber
                    z = Nfit(i);
                    try
                        N = sum(biofilmData.data(i).goodObjects(IsRelatedToFounderCells{i})); 
                    catch
                        N = biofilmData.data(i).NumObjects; 
                    end
                    z = repmat(z, 1, N);
                else
                    try
                        z = sum(biofilmData.data(i).goodObjects(IsRelatedToFounderCells{i})); 
                    catch
                        z = biofilmData.data(i).NumObjects; 
                    end
                    z = repmat(z, 1, z);
                end
                
            case 'Time'
                z = getData(biofilmData.data(i), database, fieldZ, scaling, zOffset, filterExpr, clusterBiofilm)+timeShift;    
                
            otherwise
                z = getData(biofilmData.data(i), database, fieldZ, scaling, zOffset, filterExpr, clusterBiofilm);
        end
        
        if normalizeByBiovolume
            if ~any(contains(biofilmData.data(i).measurementFields, 'Shape_Volume'))
                
                
                biovolume = getData(biofilmData.data(i), database, 'Volume', scaling, zOffset, filterExpr, clusterBiofilm);
            else
                biovolume = getData(biofilmData.data(i), database, 'Shape_Volume', scaling, zOffset, filterExpr, clusterBiofilm);
            end
        end
        
        if islogical(z) 
            z = double(z);
        end
        if islogical(y) 
            y = double(y);
        end
        
        if ~isnumeric(x) || ~isnumeric(y) || ~isnumeric(z)
            return;
        end
        
        for n = 1:numel(x)
            idxX = find(binsX >= x(n),1);
            idxY = find(binsY <= y(n),1, 'last');
            
            if ~isempty(idxX) && ~isempty(idxY)
                Z{idxY, idxX} = [Z{idxY, idxX} z(n)];
                if normalizeByBiovolume
                    B{idxY, idxX} = [B{idxY, idxX} biovolume(n)];
                end
            else
                ignoringData = true;
            end
        end
        
    catch error
        warning('"%s" at frame %d', error.message, i);
    end
end

if ignoringData
    warning('Some datapoints lie outside of the axis-limits!')
end
warning('backtrace', 'on')

if normalizeByBiovolume
    try
        
        map = cellfun(@mapNormalizedByBiovolume, Z, B, 'UniformOutput', true);
        
    catch
        map = cellfun(@(x, b) nansum(x.*b)/nansum(b), Z, B, 'UniformOutput', false);
        map = generateUniformOutput(map);
    end
else
    
    try
        eval(['map = cellfun(@(x) ',averagingFcn,'(x), Z, ''UniformOutput'', true);']);
    catch
        eval(['map = cellfun(@(x) ',averagingFcn,'(x), Z, ''UniformOutput'', false);']);
        map = generateUniformOutput(map);
    end
end

emptyEntries = cellfun(@(x) isempty(x), Z, 'UniformOutput', true);
map(emptyEntries) = NaN;

N = cellfun(@(x) numel(x), Z, 'UniformOutput', true);

if interpolate
    nans = isnan(map);
    s = size(nans, 2);
    for i = 1:size(map,1)
        map(i,:) = smooth(map(i,:))';
        idxDataStart = find(~nans(i,:), 1);
        if ~isempty(idxDataStart) && idxDataStart > 1
            map(i, 1:idxDataStart-1) = nan(1, idxDataStart-1);
        end
        idxDataStart = find(~nans(i,:), 1, 'last');
        if ~isempty(idxDataStart) && (idxDataStart < s)
            map(i, idxDataStart+1:end) = nan(1, s-idxDataStart);
        end
    end
    

end

function output = getData(data, database, field, scaling, zOffset, filterExpr, clusterBiofilm)
if ~isempty(filterExpr)
    try
        
        formulaRaw = filterExpr;
        
        try
            fields = extractBetween(formulaRaw,'{','}');
        catch
            fields = regexp(formulaRaw, '{.*?}', 'match');
            fields = cellfun(@(x) x(2:end-1), fields, 'UniformOutput', false);
        end
        
        formula = formulaRaw;
        if ~isempty(fields)
            for i = 1:numel(fields)
                formula = strrep(formula, ['{', fields{i}, '}'], sprintf('[data.%s.%s]', database, fields{i}));
            end
        else
            formula = formulaRaw;
        end
        
        eval(sprintf('filterMap = %s;', formula));
        
    catch err
        errorStr = sprintf('Filter expression (%s) is not valid! Error: %s', filterExpr, err.message);
        output = 'err';
        uiwait(msgbox(errorStr, 'Error', 'error', 'modal'));
        return;
    end
    
else
    filterMap = true(1, numel(data.(database)));
end


output = double([data.(database).(field)]);

if clusterBiofilm
    IsRelatedToFounderCells = [data.stats.IsRelatedToFounderCells];
else
    IsRelatedToFounderCells = true(1, numel(data.(database)));
end

output = output(filterMap(:) & IsRelatedToFounderCells(:) & data.goodObjects(:));


function map = generateUniformOutput(map)
noEntry = cellfun(@(x) isempty(x), map, 'UniformOutput', true);
map(noEntry) = num2cell(repmat(NaN, sum(noEntry(:)),1));
map = cell2mat(map);

function mapEntry = mapNormalizedByBiovolume(x, b)
nans = isnan(x) | isnan(b);
b(nans) = [];
x(nans) = [];
if ~isempty(x)
    mapEntry = sum(x.*b)/sum(b);
else
   mapEntry = NaN; 
end






