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
function histogram1D(handles, biofilmData)

savePlots = get(handles.handles_analysis.uicontrols.checkbox.checkbox_savePlots, 'Value');
overwritePlots = get(handles.handles_analysis.uicontrols.checkbox.checkbox_overwritePlots, 'Value');

directory = fullfile(handles.settings.directory, 'data', 'evaluation');
addPlot = get(handles.handles_analysis.uicontrols.checkbox.checkbox_addPlotToCurrentFigure, 'Value');
NBinsX = str2num(get(handles.handles_analysis.uicontrols.edit.edit_binsX, 'String'));
plotType = handles.handles_analysis.uicontrols.popupmenu.popupmenu_plotType.Value;
plotErrorbars = get(handles.handles_analysis.uicontrols.checkbox.checkbox_errorbars, 'Value');

normalizeByBiomass = false;
switch get(handles.handles_analysis.uicontrols.popupmenu.popupmenu_averaging, 'Value')
    case 1
        normalizeByBiomass = true;
        method = 'normalized by biomass';
    case 2
        averagingFcn = @nanmean;
        method = 'mean';
    case 3
        averagingFcn = @nanmedian;
        method = 'median';
    case 4
        averagingFcn = @nansum;
        method = 'sum';
    case 5
        averagingFcn = @nanmin;
        method = 'min';
    case 6
        averagingFcn = @nanmax;
        method = 'max';
end

scaling = biofilmData.params.scaling_dxy/1000;

filterExp = get(handles.handles_analysis.uicontrols.edit.edit_filterField, 'String');

removeZOffset = 0;

databaseValue = get(handles.handles_analysis.uicontrols.popupmenu.popupmenu_database, 'Value');
databaseString = handles.settings.databases;
database = databaseString{databaseValue};

publication = true;

legendStr = {};

if ~isempty(get(handles.handles_analysis.uicontrols.edit.edit_yLabel, 'String'))
    yLabel = get(handles.handles_analysis.uicontrols.edit.edit_yLabel, 'String');
    yUnit = get(handles.handles_analysis.uicontrols.edit.edit_yLabel_unit, 'String');
else
    yLabel = 'Counts';
    yUnit = '';
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

field_xaxis = get(handles.handles_analysis.uicontrols.edit.edit_kymograph_xaxis, 'String');
if plotType == 6
    field_yaxis = get(handles.handles_analysis.uicontrols.edit.edit_kymograph_yaxis, 'String');
else
    field_yaxis = field_xaxis;
end

xFields = strtrim(strsplit(field_xaxis, ','));
nFields = numel(xFields);

if nFields == 1
    if get(handles.handles_analysis.uicontrols.checkbox.checkbox_autoXRange, 'Value')
        [xLabel, xUnit, xRange, legendStr] = returnUnitLabel(field_xaxis, biofilmData, database, get(handles.handles_analysis.uicontrols.popupmenu.popupmenu_rangeMethodX, 'Value'), get(handles.handles_analysis.uicontrols.checkbox.checkbox_returnTrueRangeX, 'Value'));
        set(handles.handles_analysis.uicontrols.edit.edit_xRange, 'String', num2str(xRange, '%.2f %.2f'));
        set(handles.handles_analysis.uicontrols.edit.edit_xLabel, 'String', xLabel);
        set(handles.handles_analysis.uicontrols.edit.edit_xLabel_unit, 'String', xUnit);
    else
        xRangeStr = str2num(get(handles.handles_analysis.uicontrols.edit.edit_xRange, 'String'));
        xRange = [xRangeStr(1) xRangeStr(2)];
    end

    if ~isempty(get(handles.handles_analysis.uicontrols.edit.edit_xLabel, 'String'))
        xLabel = get(handles.handles_analysis.uicontrols.edit.edit_xLabel, 'String');
        xUnit = get(handles.handles_analysis.uicontrols.edit.edit_xLabel_unit, 'String');
    end
else
    xLabel = strrep(field_xaxis, '_', '');
    xRange = [];
    xUnit = '';
end

if plotType == 6
    filename = [field_xaxis];
else
    filename = [field_yaxis, ' resolved vs ', field_xaxis, ' ', method];
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


set(h_ax, 'NextPlot', 'add');


for field = 1:nFields  

    [X, Y, ~, ~, B] = extractDataBiofilm(biofilmData,...
        'database',     database,...
        'fieldX',       field_xaxis,...
        'fieldY',       field_yaxis,...
        'timeShift',    timeShift,...
        'scaling',      scaling,...
        'removeZOffset',removeZOffset,...
        'averagingFcn', 'none',...
        'filterExpr', filterExp,...
        'clusterBiofilm', clusterBiofilm);
    
    X = [X{:}];
    Y = [Y{:}];
    B = [B{:}];
    
    if xRange(1) == xRange(2) && numel(unique(X)) == 1
        Y = sum(X);
        X = X(1);
    else
        dX = linspace(xRange(1), xRange(2), NBinsX);
        if plotType == 6
            [~, bins_idx] = histc(X , dX);
            
            bin_array = cell(numel(dX), 1);
            biomass_array = cell(numel(dX), 1);
            
            for b = 1:numel(bin_array)
                bin_idx = find(bins_idx==b);
                if ~isempty(bin_idx)
                    bin_array{b} = Y(bin_idx);
                    biomass_array{b} = B(bin_idx);
                end
            end
            biomass_array(cellfun(@isempty, bin_array)) = repmat({0}, sum(cellfun(@isempty, bin_array)), 1);
            bin_array(cellfun(@isempty, bin_array)) = repmat({0}, sum(cellfun(@isempty, bin_array)), 1);

            
            
            if normalizeByBiomass
                Y = cellfun(@(x, b) sum(x.*b)/sum(b), bin_array, biomass_array, 'UniformOutput', false);
                
                try
                    dY = cellfun(@(x, b, m) sqrt(sum((x-m).^2.*(b/sum(b)))), bin_array, biomass_array, Y, 'UniformOutput', true);
                catch
                    dY = cellfun(@(x, b, m) sqrt(sum((x-m).^2.*(b/sum(b)))), bin_array, biomass_array, Y, 'UniformOutput', false);
                    dY = generateUniformOutput(dY);
                end
                dY = [dY'; dY'];
                Y = generateUniformOutput(Y)';
            else
                Y = cellfun(averagingFcn, bin_array)';
                
                if isequal(averagingFcn, @nanmean)
                    try
                        dY = cellfun(@(x) nanstd(x), bin_array, 'UniformOutput', true);
                    catch
                        dY = cellfun(@(x) nanstd(x), bin_array, 'UniformOutput', false);
                        dY = generateUniformOutput(dY);
                    end
                    dY = [dY'; dY'];
                    
                    
                elseif isequal(averagingFcn, @nanmedian)
                    dY = cellfun(@(x) [nanmedian(x)-prctile(x, 25) prctile(x, 75)-nanmedian(x)], bin_array, 'UniformOutput', false);
                    dY_temp1 = [dY{:}];
                    dY = [dY_temp1(1:2:end); dY_temp1(2:2:end)];
                    
                else
                    dY = zeros(size(Y));
                end
            end
        else
            Y = histc(X, dX);
        end
        X = dX;
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
    
    if plotErrorbars && plotType == 6
        errorbar(h_ax, X, Y, dY(1,:), dY(2,:), '.')
    end
    
end

if strcmp(yUnit, '')
    ylabel(h_ax, yLabel)
else
    ylabel(h_ax, [yLabel, ' ', yUnit])
end

if publication
else
    title(h_ax, [yLabel, ' ',method]);
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
if nFields > 1
    legend(yFields);
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



savefig(h, fullfile(directory, [handles.settings.databaseNames{databaseValue}, ' ', filename, '.fig']));

set(h, 'PaperUnits', 'centimeters');
set(h, 'PaperPosition', [0 0 12 9]);
set(h, 'PaperPosition', [0 0 12 9]);

if publication
    set(h_ax, 'FontSize', 16, 'LineWidth', 1)
end



print(h, '-dpng','-r300',fullfile(directory, [handles.settings.databaseNames{databaseValue}, ' ', filename, '.png']));
if isunix
    print(h, '-depsc','-r300', '-painters' ,fullfile(directory, [handles.settings.databaseNames{databaseValue}, ' ', filename, '.eps']));
else
    print(h, '-depsc ','-r300', '-painters' ,fullfile(directory, [handles.settings.databaseNames{databaseValue}, ' ', filename, '.eps']));
end


function map = generateUniformOutput(map)
noEntry = cellfun(@(x) isempty(x), map, 'UniformOutput', true);
map(noEntry) = num2cell(repmat(NaN, sum(noEntry(:)),1));
map = cell2mat(map);



