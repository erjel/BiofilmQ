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
function plotXY(handles, biofilmData)

savePlots = get(handles.handles_analysis.uicontrols.checkbox.checkbox_savePlots, 'Value');
overwritePlots = get(handles.handles_analysis.uicontrols.checkbox.checkbox_overwritePlots, 'Value');

directory = fullfile(handles.settings.directory, 'data', 'evaluation');

timeIntervals = biofilmData.timeIntervals;

scaling = biofilmData.params.scaling_dxy/1000;

if get(handles.handles_analysis.uicontrols.checkbox.checkbox_fitCellNumber, 'Value')
    fitCellNumber = true;
else
    fitCellNumber = false;
end

addPlot = get(handles.handles_analysis.uicontrols.checkbox.checkbox_addPlotToCurrentFigure, 'Value');

removeZOffset = 0;

plotErrorbars = get(handles.handles_analysis.uicontrols.checkbox.checkbox_errorbars, 'Value');

normalizeByBiomass = false;
switch get(handles.handles_analysis.uicontrols.popupmenu.popupmenu_averaging, 'Value')
    case 1
        normalizeByBiomass = true;
        averagingFcn = '';
    case 2
        averagingFcn = 'nanmean';
    case 3
        averagingFcn = 'nanmedian';
    case 4
        averagingFcn = 'nansum';
    case 5
        averagingFcn = 'nanmin';
    case 6
        averagingFcn = 'nanmax';
end

databaseValue = get(handles.handles_analysis.uicontrols.popupmenu.popupmenu_database, 'Value');
databaseString = handles.settings.databases;
database = databaseString{databaseValue};

if databaseValue == 1
    filterExp = get(handles.handles_analysis.uicontrols.edit.edit_filterField, 'String');
else
    filterExp = '';
    normalizeByBiomass = false;
end

publication = true;

legendStr = {};

if get(handles.handles_analysis.uicontrols.checkbox.checkbox_clusterBiofilm, 'Value') && databaseValue ~= 2
    if ~isfield(biofilmData.data(end).stats, 'IsRelatedToFounderCells')
       fprintf('    - clustering biofilm(s)\n');
       biofilmData = determineIsRelatedToFounderCells(handles, biofilmData);
    end
    clusterBiofilm = 1;
else
    clusterBiofilm = 0;
end

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

field_yaxis = get(handles.handles_analysis.uicontrols.edit.edit_kymograph_yaxis, 'String');
field_xaxis = get(handles.handles_analysis.uicontrols.edit.edit_kymograph_xaxis, 'String');


filename = [field_xaxis, ' vs ' field_yaxis];

switch get(handles.handles_analysis.uicontrols.popupmenu.popupmenu_averaging, 'Value')
    case 1
        method = 'normalized by biomass';
    case 2
        method = 'mean';
    case 3
        method = 'median';
    case 4
        method = 'sum';
    case 5
        method = 'min';
    case 6
        method = 'max';
end

if get(handles.handles_analysis.uicontrols.checkbox.checkbox_autoXRange, 'Value')
    [xLabel, xUnit, xRange] = returnUnitLabel(field_xaxis, biofilmData, database, get(handles.handles_analysis.uicontrols.popupmenu.popupmenu_rangeMethodX, 'Value'), get(handles.handles_analysis.uicontrols.checkbox.checkbox_returnTrueRangeX, 'Value'));
    set(handles.handles_analysis.uicontrols.edit.edit_xRange, 'String', num2str(xRange, '%.2g %.2g'));
    set(handles.handles_analysis.uicontrols.edit.edit_xLabel, 'String', xLabel);
    set(handles.handles_analysis.uicontrols.edit.edit_xLabel_unit, 'String', xUnit);
else
    xRange = str2num(get(handles.handles_analysis.uicontrols.edit.edit_xRange, 'String'));
    xLabel = get(handles.handles_analysis.uicontrols.edit.edit_xLabel, 'String');
    xUnit = get(handles.handles_analysis.uicontrols.edit.edit_xLabel_unit, 'String');
end

y_type = field_xaxis;

if exist(fullfile(directory, [handles.settings.databaseNames{databaseValue}, ' ', filename, ' ', method, ' ', y_type,'.fig']), 'file') && (~overwritePlots && savePlots)
    file = dir(fullfile(directory, [handles.settings.databaseNames{databaseValue}, ' ', filename, ' ', method, ' ', y_type,'.fig']));
    cellFiles = dir(fullfile(handles.settings.directory, 'data', '*_data.mat'));
    if file.datenum > cellFiles(1).datenum && savePlots 
        warning('backtrace', 'off')
        warning('File "%s" already exists. Overwriting is disabled. Aborting...', filename);
        warning('backtrace', 'on')
        return;
    end
end

yFields = strtrim(strsplit(field_yaxis, ','));
nFields = numel(yFields);
yLabelEntered = '';
yUnitEntered = '';
yRangeEntered = [];
if get(handles.handles_analysis.uicontrols.checkbox.checkbox_autoYRange, 'Value')
    if nFields == 1
        [yLabelEntered, yUnitEntered, yRange] = returnUnitLabel(field_yaxis, biofilmData, database, get(handles.handles_analysis.uicontrols.popupmenu.popupmenu_rangeMethodY, 'Value'), get(handles.handles_analysis.uicontrols.checkbox.checkbox_returnTrueRangeY, 'Value'));
        set(handles.handles_analysis.uicontrols.edit.edit_yRange, 'String', num2str(yRange, '%.2f %.2f'));
    end
    set(handles.handles_analysis.uicontrols.edit.edit_yLabel, 'String', yLabelEntered);
    set(handles.handles_analysis.uicontrols.edit.edit_yLabel_unit, 'String', yUnitEntered);
else
    yRange = str2num(get(handles.handles_analysis.uicontrols.edit.edit_yRange, 'String'));
    yLabel = get(handles.handles_analysis.uicontrols.edit.edit_yLabel, 'String');
    yUnit = get(handles.handles_analysis.uicontrols.edit.edit_yLabel_unit, 'String');
    yRangeEntered = yRange;
    yLabelEntered = yLabel;
    yUnitEntered = yUnit;
end


if get(handles.handles_analysis.uicontrols.checkbox.useRefTimepoint, 'Value')
    timeShift = biofilmData.timeShift/60/60;
else
    timeShift = 0;
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

yUnit = cell(1, nFields);
yLabel = cell(1, nFields);
legendStr = cell(1, nFields);
for field = 1:nFields
    [yLabel{field}, yUnit{field}, yRange, legendStr{field}] = returnUnitLabel(yFields{field}, biofilmData, database, get(handles.handles_analysis.uicontrols.popupmenu.popupmenu_rangeMethodY, 'Value'), get(handles.handles_analysis.uicontrols.checkbox.checkbox_returnTrueRangeY, 'Value'));
    
    field_yaxis = yFields{field};
    
    [X, Y, dX, dY] = extractDataBiofilm(biofilmData,...
        'database',     database,...
        'fieldX',       field_xaxis,...
        'fieldY',       field_yaxis,...
        'timeIntervals',timeIntervals,...
        'timeShift',    timeShift,...
        'scaling',      scaling,...
        'fitCellNumber',fitCellNumber,...
        'removeZOffset',removeZOffset,...
        'averagingFcn', averagingFcn,...
        'filterExpr', filterExp,...
        'clusterBiofilm', clusterBiofilm,...
        'normalizeByBiomass', normalizeByBiomass);
    
    if nFields < 3
        if field == 1
            
            if (strcmp(method, 'mean') || strcmp(method, 'median')) && ~isempty(yRange)
                try
                    ylim(h_ax, [yRange(1) yRange(2)])
                catch
                    ylim(h_ax, [yRange(1)-1 yRange(1)+1])
                end
            end
        end
        
        if nFields == 2 && field ==2
            
            if (strcmp(method, 'mean') || strcmp(method, 'median')) && ~isempty(yRange)
                try
                    ylim(h_ax, [yRange(1) yRange(2)])
                catch
                    ylim(h_ax, [yRange(1)-1 yRange(1)+1])
                end
            end
            yyaxis(h_ax, 'right');
        end
    end
    
    
    if plotErrorbars
        if sum(dX) == 0
            errorbar(h_ax, X, Y, dY(1,:), dY(2,:), '.')
        else
            errorbar(h_ax, X, Y, dY(1,:), dY(2,:), dX(1,:), dX(2,:), '.')
        end
    else
        
        
    end
    set(h_ax, 'NextPlot', 'add');
    switch get(handles.handles_analysis.uicontrols.popupmenu.popupmenu_plotStyle, 'Value')
        case 1
            scatter(h_ax, X, Y, 'filled')
        case 2
            plot(h_ax, X, Y);
        case 3
            plot(h_ax, X, Y);
            scatter(h_ax, X, Y, 'filled');
        case 4
            stairs(h_ax, X,Y);
        case 5
            bar(h_ax, X, Y);
    end
    
end

switch nFields
    case 1
    yLabel = yLabel{1};
    yUnit = yUnit{1};
    
    if strcmp(yUnit, '')
        ylabel(h_ax, yLabel)
    else
        ylabel(h_ax, [yLabel, ' ', yUnit])
    end

    case 2 
        if isempty(yLabelEntered) 
            yyaxis(h_ax, 'left');
            if strcmp(yUnit{1}, '')
                ylabel(h_ax, yLabel{1})
            else
                ylabel(h_ax, [yLabel{1}, ' ', yUnit{1}])
            end
            
            yyaxis(h_ax, 'right');
            if strcmp(yUnit{2}, '')
                ylabel(h_ax, yLabel{2})
            else
                ylabel(h_ax, [yLabel{2}, ' ', yUnit{2}])
            end
        else
            yyaxis(h_ax, 'left');
            if strcmp(yUnitEntered, '')
                ylabel(h_ax, yLabelEntered)
            else
                ylabel(h_ax, [yLabelEntered, ' ', yUnitEntered])
            end
        end
        
    otherwise
        if strcmp(yUnitEntered, '')
            ylabel(h_ax, yLabelEntered)
        else
            ylabel(h_ax, [yLabelEntered, ' ', yUnitEntered])
        end
        
end

if (~isempty(yRange) && nFields == 1) && ((strcmp(method, 'mean') || strcmp(method, 'median') || normalizeByBiomass))
    try
        ylim(h_ax, [yRange(1) yRange(2)])
    catch
        ylim(h_ax, [yRange(1)-1 yRange(1)+1])
    end
end

if ~isempty(yRangeEntered)
    if nFields > 1
        yyaxis(h_ax, 'left');
        try
            ylim(h_ax, [yRangeEntered(1) yRangeEntered(2)])
        catch
            ylim(h_ax, [yRangeEntered(1)-1 yRangeEntered(1)+1])
        end
        yyaxis(h_ax, 'right');
    end
    try
        ylim(h_ax, [yRangeEntered(1) yRangeEntered(2)])
    catch
        ylim(h_ax, [yRangeEntered(1)-1 yRangeEntered(1)+1])
    end
    
end

try
    xlim(h_ax, [xRange(1)-0.05*diff(xRange) xRange(2)+0.05*diff(xRange)]);
end

if strcmp(xUnit, '')
    xlabel(h_ax, xLabel)
else
    xlabel(h_ax, [xLabel, ' ', xUnit])
end

if strcmp(scaleX, 'log')
    set(h_ax, 'XScale', 'log', 'Xtick', [1 10 10^2 10^3 10^4], 'XTickLabel', {'1', '10', '10^2', '10^3', '10^4'});
else
    set(h_ax, 'XScale', 'linear');
end

if strcmp(scaleY, 'log')
    set(h_ax, 'YScale', 'log');
else
    set(h_ax, 'YScale', 'linear');
end

box(h_ax, 'on');
if nFields > 2
    legend(legendStr);
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

if ~exist(directory, 'dir')
    mkdir(directory);
end

save(fullfile(directory, [handles.settings.databaseNames{databaseValue}, ' ', filename, ' xy.mat']), 'X', 'Y')

if ~exist(directory, 'dir')
    mkdir(directory);
end


savefig(h, fullfile(directory, [handles.settings.databaseNames{databaseValue}, ' ', filename, ' ', method, ' ', y_type, '.fig']));

set(h, 'PaperUnits', 'centimeters');
set(h, 'PaperPosition', [0 0 12 9]);
set(h, 'PaperPosition', [0 0 12 9]);

if publication
    set(h_ax, 'FontSize', 16, 'LineWidth', 1)
end



print(h, '-dpng','-r300',fullfile(directory, [handles.settings.databaseNames{databaseValue}, ' ', filename, ' ', method, ' ', y_type, '.png']));
if isunix
    print(h, '-depsc','-r300', '-painters' ,fullfile(directory, [handles.settings.databaseNames{databaseValue}, ' ', filename, ' ', method, ' ', y_type, '.eps']));
else
    print(h, '-depsc ','-r300', '-painters' ,fullfile(directory, [handles.settings.databaseNames{databaseValue}, ' ', filename, ' ', method, ' ', y_type, '.eps']));
end
end




