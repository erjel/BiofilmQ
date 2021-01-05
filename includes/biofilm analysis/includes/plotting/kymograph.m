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
function kymograph(handles, biofilmData)

timeIntervals = biofilmData.timeIntervals;

savePlots = get(handles.handles_analysis.uicontrols.checkbox.checkbox_savePlots, 'Value');
overwritePlots = get(handles.handles_analysis.uicontrols.checkbox.checkbox_overwritePlots, 'Value');

invertHeatmap = get(handles.handles_analysis.uicontrols.checkbox.checkbox_invert, 'Value');

scaling = biofilmData.params.scaling_dxy;

databaseValue = get(handles.handles_analysis.uicontrols.popupmenu.popupmenu_database, 'Value');
databaseString = handles.settings.databases;
database = databaseString{databaseValue};

addPlot = get(handles.handles_analysis.uicontrols.checkbox.checkbox_addPlotToCurrentFigure, 'Value');

if get(handles.handles_analysis.uicontrols.checkbox.checkbox_clusterBiofilm, 'Value') && databaseValue ~= 2
    if ~isfield(biofilmData.data(end).stats, 'IsRelatedToFounderCells')
       fprintf('    - clustering biofilm(s)\n');
       biofilmData = determineIsRelatedToFounderCells(handles, biofilmData);
    end
    clusterBiofilm = 1;
else
    clusterBiofilm = 0;
end

if strcmp(databaseString{databaseValue}, 'globalMeasurements')
    uiwait(msgbox('Kymographs are not supported for this database', 'Warning', 'warn', 'modal'));
    return;
end

interpolate = 0;
faceColor = 'flat';

t_max = numel(biofilmData.data);

directory = fullfile(handles.settings.directory, 'data', 'evaluation');

field_xaxis = get(handles.handles_analysis.uicontrols.edit.edit_kymograph_xaxis, 'String');
field_yaxis = get(handles.handles_analysis.uicontrols.edit.edit_kymograph_yaxis, 'String');
field_caxis = get(handles.handles_analysis.uicontrols.edit.edit_kymograph_coloraxis, 'String');
yOffset = str2num(get(handles.handles_analysis.uicontrols.edit.edit_yOffset, 'String'));


normalizeByBiovolume = false;
switch get(handles.handles_analysis.uicontrols.popupmenu.popupmenu_averaging, 'Value')
    case 1
        averagingMethod = ' normalized by biovolume';
        normalizeByBiovolume = true;
        averagingFcn = '';
    case 2
        averagingMethod = '';
        averagingFcn = 'nanmean';
    case 3
        averagingMethod = ' median';
        averagingFcn = 'nanmedian';
    case 4
        averagingMethod = ' sum';
        averagingFcn = 'nansum';
    case 5
        averagingMethod = ' min';
        averagingFcn = 'nanmin';
    case 6
        averagingMethod = ' max';
        averagingFcn = 'nanmax';
end

filename = [field_xaxis, ' vs ', field_yaxis, ' vs ', field_caxis, averagingMethod];
if invertHeatmap
    filename = [filename, ' inverted'];
end


if exist(fullfile(directory, [handles.settings.databaseNames{databaseValue}, ' ', filename, '.fig']), 'file') && (~overwritePlots && savePlots)
    file = dir(fullfile(directory, [handles.settings.databaseNames{databaseValue}, ' ', filename, '.fig']));
    cellFiles = dir(fullfile(handles.settings.directory, 'data', '*_data.mat'));
    if file.datenum > cellFiles(1).datenum && savePlots 
        warning('backtrace', 'off')
        warning('File "%s" already exists. Overwriting is disabled. Aborting...', filename);
        warning('backtrace', 'on')
        return;
    end
end


if get(handles.handles_analysis.uicontrols.checkbox.checkbox_autoColorRange, 'Value')
    [~, ~, cRange] = returnUnitLabel(field_caxis, biofilmData, database, get(handles.handles_analysis.uicontrols.popupmenu.popupmenu_rangeMethodColor, 'Value'), get(handles.handles_analysis.uicontrols.checkbox.checkbox_returnTrueRangeColor, 'Value'));
    set(handles.handles_analysis.uicontrols.edit.edit_colorRange, 'String', num2str(cRange, '%.2g %.2g'));
else
    cRange = str2num(get(handles.handles_analysis.uicontrols.edit.edit_colorRange, 'String'));
end
if get(handles.handles_analysis.uicontrols.checkbox.checkbox_autoYRange, 'Value')
    [~, ~, yRange] = returnUnitLabel(field_yaxis, biofilmData, database, get(handles.handles_analysis.uicontrols.popupmenu.popupmenu_rangeMethodY, 'Value'), get(handles.handles_analysis.uicontrols.checkbox.checkbox_returnTrueRangeY, 'Value'));
    set(handles.handles_analysis.uicontrols.edit.edit_yRange, 'String', num2str(yRange, '%.2g %.2g'));
else
    yRange = str2num(get(handles.handles_analysis.uicontrols.edit.edit_yRange, 'String'));
end
if get(handles.handles_analysis.uicontrols.checkbox.checkbox_autoXRange, 'Value')
    [~, ~, xRange] = returnUnitLabel(field_xaxis, biofilmData, database, get(handles.handles_analysis.uicontrols.popupmenu.popupmenu_rangeMethodX, 'Value'), get(handles.handles_analysis.uicontrols.checkbox.checkbox_returnTrueRangeX, 'Value'));
    set(handles.handles_analysis.uicontrols.edit.edit_xRange, 'String', num2str(xRange, '%.2g %.2g'));
else
    xRange = str2num(get(handles.handles_analysis.uicontrols.edit.edit_xRange, 'String'));
end


[xLabel, yLabel, ~, cLabel] = getLabelsFromGUI(handles, {field_xaxis, field_yaxis, '', field_caxis});
[xUnit, yUnit, ~, cUnit] = getUnitsFromGUI(handles, {field_xaxis, field_yaxis, '', field_caxis});


publication = true;

NBinsX = str2num(get(handles.handles_analysis.uicontrols.edit.edit_binsX, 'String'));
NBinsY = str2num(get(handles.handles_analysis.uicontrols.edit.edit_binsY, 'String'));

if sum(timeIntervals) == 0 && numel(timeIntervals) > 1
    timeIntervals = repmat(1, numel(timeIntervals), 1)*60*60;
end

t_min = cumsum(timeIntervals)/60/60;
        
if get(handles.handles_analysis.uicontrols.checkbox.useRefTimepoint, 'Value')
    timeShift = biofilmData.timeShift/60/60;
else
    timeShift = 0;
end
tRange = [0 t_min(t_max)+timeIntervals(t_max)/60/60];

if strcmp(field_xaxis, 'Time') && get(handles.handles_analysis.uicontrols.checkbox.checkbox_autoXRange, 'Value')
    xRange = tRange;
end

if get(handles.handles_analysis.uicontrols.checkbox.checkbox_fitCellNumber, 'Value')
    fitCellNumber = true;
else
    fitCellNumber = false;
end

filterExp = get(handles.handles_analysis.uicontrols.edit.edit_filterField, 'String');

if get(handles.handles_analysis.uicontrols.checkbox.checkbox_logX, 'Value')
    scaleX = 'log';
else
    scaleX = 'linear';
end

if get(handles.handles_analysis.uicontrols.checkbox.checkbox_logY, 'Value')
    scaleY = 'log';
else
    scaleY = 'linear';
end

removeZOffset = get(handles.handles_analysis.uicontrols.checkbox.checkbox_removeZOffset, 'Value');

[X, Y, heatmapMatrix, N, Z] = extractDataBiofilm_kymograph(biofilmData,...
    'database',     database,...
    'fieldX',       field_xaxis,...
    'fieldY',       field_yaxis,...
    'fieldZ',       field_caxis,...
    'rangeX',       xRange,...
    'rangeY',       yRange,...
    'scaleX',       scaleX,...
    'scaleY',       scaleY,...
    'NBinsX',       NBinsX,...
    'NBinsY',       NBinsY,...
    'timeIntervals',timeIntervals,...
    'timeShift',    timeShift,...
    'scaling',      scaling,...
    'interpolate',  interpolate,...
    'fitCellNumber',fitCellNumber,...
    'removeZOffset',removeZOffset,...
    'averagingFcn', averagingFcn,...
    'filterExpr', filterExp,...
    'clusterBiofilm', clusterBiofilm,...
    'normalizeByBiovolume', normalizeByBiovolume);


if get(handles.handles_analysis.uicontrols.checkbox.checkbox_removeZOffsetHeatmapColumn, 'Value')
    for i = 1:size(heatmapMatrix,2)
        ind = find(~isnan(heatmapMatrix(:,i)), 1);
        if ~isempty(ind)
            
            heatmapMatrix(:,i) = heatmapMatrix( [ind:end,1:ind-1], i);
        end
    end
end

if invertHeatmap
    for i = 1:size(heatmapMatrix,2)
        firstDataPoint = find(~isnan(flip(heatmapMatrix(:,i))), 1);
        lastDataPoint = size(heatmapMatrix, 1) - firstDataPoint + 1;
        heatmapMatrix(1:lastDataPoint,i) = flip(heatmapMatrix(1:lastDataPoint,i));
    end
end
if yOffset
    Y = Y+yOffset;
end



normalizeFactor = str2num(get(handles.handles_analysis.uicontrols.edit.edit_normalizeFactor, 'String'));
heatmapMatrix = heatmapMatrix/normalizeFactor;
 

if ~exist(directory, 'dir')
    mkdir(directory);
end


figHandles = findobj('Type', 'figure');
if numel(figHandles) == 1
    addPlot = 0;
end
if addPlot
    h = figHandles(2);
    figure(h);
    h_ax = gca;
else
    h = figure;
    addIcon(h);
    h_ax = axes('Parent', h);
end
if yRange(2) == max(Y(:))
    
    
    Y = [Y; yRange(2)+((Y(end,1)-Y(end-1,1))*ones(1, size(Y,2)))];
    yRange(2) = yRange(2)+Y(end,1)-Y(end-1,1);
    X = [X; X(end,:)];
    heatmapMatrix = [heatmapMatrix; zeros(1, size(heatmapMatrix,2))];
end
if xRange(2) == max(X(:))
    X = [X, xRange(2)+((X(1,end)-X(1,end-1))*ones(size(X,1),1))];
    xRange(2) = xRange(2)+ X(1,end)-X(1,end-1);
    Y = [Y, Y(:,end)];
    heatmapMatrix = [heatmapMatrix, zeros(size(heatmapMatrix,1),1)];
end

surf(X, Y, zeros(size(X)), heatmapMatrix, 'Parent', h_ax, 'EdgeColor', 'none', 'FaceColor', faceColor)

box(h_ax, 'on');

view(h_ax, 0,90)

if strcmp(averagingFcn, 'nanmean') || strcmp(averagingFcn, 'nanmedian') || strcmp(averagingFcn, '')
    try
        h_ax.CLim = [cRange(1) cRange(2)];
    end
end
try
    h_ax.YLim = yRange;
end
try
    h_ax.XLim = xRange;
end
set(h_ax, 'ydir', 'normal', 'xscale', scaleX, 'yscale', scaleY);

if strcmp(xUnit, '')
    xlabel(h_ax, xLabel)
else
    xlabel(h_ax, [xLabel, ' ', xUnit])
end

if strcmp(yUnit, '')
    ylabel(h_ax, yLabel)
else
    ylabel(h_ax, [yLabel, ' ', yUnit])
end

set(h_ax, 'NextPlot', 'add');


c = colorbar;
if strcmp(cUnit, '')
    c.Label.String = cLabel;
else
    c.Label.String = [cLabel, ' ', cUnit];
end

if strcmp(field_xaxis, 'Cell_Number') && strcmp(scaleX, 'log')
    set(h_ax, 'XTick', [1 10 100 1000 10000], 'XTickLabel', {'1', '10', '10^2', '10^3', '10^4'});
end


if handles.handles_analysis.uicontrols.checkbox.checkbox_applyCustom2.Value
    if ~isempty(handles.handles_analysis.uicontrols.edit.edit_custom2.String)
        pathScript = handles.handles_analysis.uicontrols.edit.edit_custom2.String;
        try
            run(pathScript);
        catch err
            warning('backtrace', 'off')
            warning('Custom script "%s" not valid! Error msg: %s', pathScript, err.message);
            warning('backtrace', 'on')
        end
    end
end

if ~savePlots
    return;
end

save(fullfile(directory, [handles.settings.databaseNames{databaseValue}, ' ', filename, ' heatmap.mat']), 'heatmapMatrix', 'X', 'Y')

set(h, 'PaperUnits', 'centimeters');
set(h, 'PaperPosition', [0 0 12 9]);

if publication
    set(h_ax, 'FontSize', 16, 'LineWidth', 1)
end

set(h, 'PaperUnits', 'centimeters');
set(h, 'PaperPosition', [0 0 12 9]);

box(h_ax, 'on');
grid(h_ax, 'off');

savefig(h, fullfile(directory, [handles.settings.databaseNames{databaseValue}, ' ', filename, '.fig']));

print(h, '-depsc', '-r300', '-painters' ,fullfile(directory, [handles.settings.databaseNames{databaseValue}, ' ', filename, '.eps']));

pos = get(h_ax, 'Position');
set(h_ax, 'Position', [pos(1)+.05 pos(2)+.05 pos(3)*0.8, pos(4)*0.9]);
print(h, '-dpng','-r300',fullfile(directory, [handles.settings.databaseNames{databaseValue}, ' ', filename, '.png']));

assignin('base', 'heatmapMatrix', heatmapMatrix);



