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
function objects = filterCellsByIntensity(objects, filterField, logScale, thresh)

if strcmp(filterField, 'ID')
    meanInt = 1:numel(objects.stats);
elseif strcmp(filterField, 'CentroidCoordinate_x')
    meanInt = cellfun(@(x) x(1), {objects.stats.Centroid});
elseif strcmp(filterField, 'CentroidCoordinate_y')
    meanInt = cellfun(@(x) x(2), {objects.stats.Centroid});
elseif strcmp(filterField, 'CentroidCoordinate_z')
    meanInt = cellfun(@(x) x(3), {objects.stats.Centroid});
else
    meanInt = double([objects.stats.(filterField)]);
end


if isempty(meanInt)
    return;
end

if nargin < 4
    h = figure;
    h_ax = axes('Parent', h);
    title(h_ax, 'Please select threshold');
    
    
    
    if logScale
        minInt = min(meanInt);
        if minInt == 0
            minInt = 0.1;
        end
        maxInt = max(meanInt);
        if minInt >= maxInt
            maxInt = minInt + 1;
        end
        
        x = logspace(log10(minInt), log10(maxInt), 250);
    else
        x = linspace(min(meanInt), max(meanInt), 250);
    end
    try
        if numel(unique(meanInt)) < 5
            x = unique(meanInt);
        end
        N = histc(meanInt, x);
    catch
        N = 0;
    end
    
    if numel(N) >= 5
        plot(h_ax, x, N, '.-'); hold on;
    else
        plot(h_ax, x, N, 'o-'); hold on;
    end
    
    try
        xlim(h_ax, [0.9*min(x) 1.1*max(x)]);
    end
    
    if logScale && min(x) > 0
        set(h_ax, 'XScale', 'log');
        set(h_ax, 'YScale', 'log');
    end
    
    
    
    [label, unit] = returnUnitLabel(filterField);
    
    xlabel(h_ax, sprintf('%s %s', label, unit));
    ylabel(h_ax, 'Counts');
    
    
    drawnow
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
else
    
    if thresh(1) == -Inf
        objects.goodObjects = (meanInt <= thresh(2))';
    elseif thresh(2) == Inf
        objects.goodObjects = (meanInt >= thresh(1))';
    elseif thresh(1)==Inf && thresh(2) == Inf
        objects.goodObjects = ones(length(meanInt),1);
    else
        objects.goodObjects = (meanInt <= thresh(2))' & (meanInt >= thresh(1))';
    end
    
end




