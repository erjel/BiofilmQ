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
function scatterPlotXY(handles, biofilmData)

savePlots = get(handles.handles_analysis.uicontrols.checkbox.checkbox_savePlots, 'Value');
overwritePlots = get(handles.handles_analysis.uicontrols.checkbox.checkbox_overwritePlots, 'Value');

directory = fullfile(handles.settings.directory, 'data', 'evaluation');

timeIntervals = biofilmData.timeIntervals;

databaseValue = get(handles.handles_analysis.uicontrols.popupmenu.popupmenu_database, 'Value');
databaseString = handles.settings.databases;
database = databaseString{databaseValue};

addPlot = get(handles.handles_analysis.uicontrols.checkbox.checkbox_addPlotToCurrentFigure, 'Value');

switch get(handles.handles_analysis.uicontrols.popupmenu.popupmenu_plotType, 'Value')
    case 3
        scatterType = '2D';
    case 4
        scatterType = '4D';
end


if get(handles.handles_analysis.uicontrols.checkbox.checkbox_clusterBiofilm, 'Value') && databaseValue ~= 2
    if ~isfield(biofilmData.data(end).stats, 'IsRelatedToFounderCells')
       fprintf('    - clustering biofilm(s)\n');
       biofilmData = determineIsRelatedToFounderCells(handles, biofilmData);
    end
    clusterBiofilm = 1;
else
    clusterBiofilm = 0;
end

files_range = numel(biofilmData.data);

scaling = biofilmData.params.scaling_dxy;

if get(handles.handles_analysis.uicontrols.checkbox.checkbox_fitCellNumber, 'Value')
    fitCellNumber = true;
else
    fitCellNumber = false;
end

filterExp = get(handles.handles_analysis.uicontrols.edit.edit_filterField, 'String');

removeZOffset = 0;

field_xaxis = get(handles.handles_analysis.uicontrols.edit.edit_kymograph_xaxis, 'String');
field_yaxis = get(handles.handles_analysis.uicontrols.edit.edit_kymograph_yaxis, 'String');
field_zaxis = get(handles.handles_analysis.uicontrols.edit.edit_kymograph_zaxis, 'String');
field_caxis = get(handles.handles_analysis.uicontrols.edit.edit_kymograph_coloraxis, 'String');

filename = [field_xaxis, ' vs ', field_yaxis, ' vs ', field_zaxis, ' vs ', field_caxis, '_scatter'];

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
    [cLabel, cUnit, cRange] = returnUnitLabel(field_caxis, biofilmData, database, get(handles.handles_analysis.uicontrols.popupmenu.popupmenu_rangeMethodColor, 'Value'), get(handles.handles_analysis.uicontrols.checkbox.checkbox_returnTrueRangeColor, 'Value'));
    set(handles.handles_analysis.uicontrols.edit.edit_colorRange, 'String', num2str(cRange, '%.2g %.2g'));
    set(handles.handles_analysis.uicontrols.edit.edit_colorLabel, 'String', cLabel);
    set(handles.handles_analysis.uicontrols.edit.edit_colorLabel_unit, 'String', cUnit);
else
    cRange = str2num(get(handles.handles_analysis.uicontrols.edit.edit_colorRange, 'String'));
end
if get(handles.handles_analysis.uicontrols.checkbox.checkbox_autoYRange, 'Value')
    [yLabel, yUnit, yRange] = returnUnitLabel(field_yaxis, biofilmData, database, get(handles.handles_analysis.uicontrols.popupmenu.popupmenu_rangeMethodY, 'Value'), get(handles.handles_analysis.uicontrols.checkbox.checkbox_returnTrueRangeY, 'Value'));
    set(handles.handles_analysis.uicontrols.edit.edit_yRange, 'String', num2str(yRange, '%.2g %.2g'));
    set(handles.handles_analysis.uicontrols.edit.edit_yLabel, 'String', yLabel);
    set(handles.handles_analysis.uicontrols.edit.edit_yLabel_unit, 'String', yUnit);
else
    yRange = str2num(get(handles.handles_analysis.uicontrols.edit.edit_yRange, 'String'));
end
if get(handles.handles_analysis.uicontrols.checkbox.checkbox_autoXRange, 'Value')
    [xLabel, xUnit, xRange] = returnUnitLabel(field_xaxis, biofilmData, database, get(handles.handles_analysis.uicontrols.popupmenu.popupmenu_rangeMethodX, 'Value'), get(handles.handles_analysis.uicontrols.checkbox.checkbox_returnTrueRangeX, 'Value'));
    set(handles.handles_analysis.uicontrols.edit.edit_xRange, 'String', num2str(xRange, '%.2g %.2g'));
    set(handles.handles_analysis.uicontrols.edit.edit_xLabel, 'String', xLabel);
    set(handles.handles_analysis.uicontrols.edit.edit_xLabel_unit, 'String', xUnit);
else
    xRange = str2num(get(handles.handles_analysis.uicontrols.edit.edit_xRange, 'String'));
end
if get(handles.handles_analysis.uicontrols.checkbox.checkbox_autoZRange, 'Value')
    [zLabel, zUnit, zRange] = returnUnitLabel(field_zaxis, biofilmData, database, get(handles.handles_analysis.uicontrols.popupmenu.popupmenu_rangeMethodZ, 'Value'), get(handles.handles_analysis.uicontrols.checkbox.checkbox_returnTrueRangeZ, 'Value'));
    set(handles.handles_analysis.uicontrols.edit.edit_zRange, 'String', num2str(zRange, '%.2g %.2g'));
    set(handles.handles_analysis.uicontrols.edit.edit_zLabel, 'String', zLabel);
    set(handles.handles_analysis.uicontrols.edit.edit_zLabel_unit, 'String', zUnit);
else
    zRange = str2num(get(handles.handles_analysis.uicontrols.edit.edit_zRange, 'String'));
end

if ~isempty(get(handles.handles_analysis.uicontrols.edit.edit_xLabel, 'String'))
    xLabel = get(handles.handles_analysis.uicontrols.edit.edit_xLabel, 'String');
    xUnit = get(handles.handles_analysis.uicontrols.edit.edit_xLabel_unit, 'String');
end

if ~isempty(get(handles.handles_analysis.uicontrols.edit.edit_yLabel, 'String'))
    yLabel = get(handles.handles_analysis.uicontrols.edit.edit_yLabel, 'String');
    yUnit = get(handles.handles_analysis.uicontrols.edit.edit_yLabel_unit, 'String');
end

if ~isempty(get(handles.handles_analysis.uicontrols.edit.edit_zLabel, 'String'))
    zLabel = get(handles.handles_analysis.uicontrols.edit.edit_zLabel, 'String');
    zUnit = get(handles.handles_analysis.uicontrols.edit.edit_zLabel_unit, 'String');
end

if ~isempty(get(handles.handles_analysis.uicontrols.edit.edit_colorLabel, 'String'))
    cLabel = get(handles.handles_analysis.uicontrols.edit.edit_colorLabel, 'String');
    cUnit = get(handles.handles_analysis.uicontrols.edit.edit_colorLabel_unit, 'String');
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

if get(handles.handles_analysis.uicontrols.checkbox.checkbox_logZ, 'Value')
    scaleZ = 'log';
else
    scaleZ = 'linear';
end

publication = true;

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

if get(handles.handles_analysis.uicontrols.checkbox.useRefTimepoint, 'Value')
    timeShift = biofilmData.timeShift/60/60;
else
    timeShift = 0;
end
colorPlot = 0;
switch scatterType
    case '2D'
        [X, Y, ~, ~, ~, C] = extractDataBiofilm(biofilmData,...
            'database',     database,...
            'fieldX',       field_xaxis,...
            'fieldY',       field_yaxis,...
            'fieldC',       field_caxis,...
            'timeIntervals',timeIntervals,...
            'timeShift',    timeShift,...
            'scaling',      scaling,...
            'fitCellNumber',fitCellNumber,...
            'removeZOffset',removeZOffset,...
            'averagingFcn', 'none',...
            'filterExpr', filterExp,...
            'clusterBiofilm', clusterBiofilm);
        
        for ind = 1:files_range
            i = ind;
            try
                x = X{i};
                y = Y{i};
                c = C{i};
                
                if isempty(c) || sum(c)~=sum(c)
                    scatter(h_ax, x, y, 8, 'filled', 'MarkerFaceColor', lines(1));
                else
                    scatter(h_ax, x, y, 8, c, 'filled');
                    colorPlot = 1;
                end
                
                if i == 1
                    set(h_ax, 'NextPlot', 'add')
                end
            catch
                disp('Error!');
            end
        end
        
        
    case '4D'
        colorPlot = 1;
        [X, Y, ~, ~, Z, C] = extractDataBiofilm(biofilmData,...
            'database',     database,...
            'fieldX',       field_xaxis,...
            'fieldY',       field_yaxis,...
            'fieldC',       field_caxis,...
            'fieldZ',       field_zaxis,...
            'timeIntervals',timeIntervals,...
            'timeShift',    timeShift,...
            'scaling',      scaling,...
            'fitCellNumber',fitCellNumber,...
            'removeZOffset',removeZOffset,...
            'averagingFcn', 'none',...
            'filterExpr', filterExp,...
            'clusterBiofilm', clusterBiofilm);
        
        for ind = 1:files_range
            i = ind;
            try
                x = X{i};
                y = Y{i};
                c = C{i};
                z = Z{i};
                
                scatter3(h_ax, x, y, z, 8, c, 'filled');
                if i == 1
                    set(h_ax, 'NextPlot', 'add')
                end
            catch
                disp('Error!');
            end
        end
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

set(h_ax, 'ylim', yRange, 'xlim', xRange)

if strcmp(scatterType, '4D')
    set(h_ax, 'zlim', zRange, 'clim', cRange);
    
    if strcmp(scaleZ, 'log')
        set(h_ax, 'ZScale', 'log');
    else
        set(h_ax, 'ZScale', 'linear');
    end
    
    if strcmp(zUnit, '')
        zlabel(h_ax, zLabel)
    else
        zlabel(h_ax, [zLabel, ' ', zUnit])
    end
end

if colorPlot 
    set(h_ax, 'clim', cRange);
    warning off;
    c = colorbar;
    if strcmp(cUnit, '')
        c.Label.String = cLabel;
    else
        c.Label.String = [cLabel, ' ', cUnit];
    end
    warning on;
end


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



if publication
else
    title(h_ax, [xLabel, ' vs. ', yLabel]);
end

box(h_ax, 'on');

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

set(h, 'PaperUnits', 'centimeters');
set(h, 'PaperPosition', [0 0 12 9]);

if publication
    set(h_ax, 'FontSize', 16, 'LineWidth', 1)
end

savefig(h, fullfile(directory, [handles.settings.databaseNames{databaseValue}, ' ', filename, '.fig']));

print(h, '-dpng','-r300',fullfile(directory, [handles.settings.databaseNames{databaseValue}, ' ', filename, '.png']));
if isunix
    print(h, '-depsc','-r300', '-painters' ,fullfile(directory, [database, ' ', filename, '.eps']));
else
    print(h, '-depsc ','-r300', '-painters' ,fullfile(directory, [database, ' ', filename, '.eps']));
end



