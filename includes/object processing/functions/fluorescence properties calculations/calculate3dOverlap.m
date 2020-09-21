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
function [objects, obj] = calculate3dOverlap(objects, ~, ch_task, opts, task, handles, filename, obj)
fprintf(' - determining 3D overlap between channels');

filename = fullfile(handles.settings.directory, 'data', [filename(1:end-4), '_data.mat']);
filename_ch1 = strrep(filename, sprintf('_ch%d', ch_task(2)), sprintf('_ch%d', ch_task(1)));
filename_ch2 = strrep(filename, sprintf('_ch%d', ch_task(1)), sprintf('_ch%d', ch_task(2)));

if isempty(obj{ch_task(1)})
    obj{ch_task(1)} = loadObjects(filename_ch1);
end
if isempty(obj{ch_task(2)})
    obj{ch_task(2)} = loadObjects(filename_ch2);
end

if numel(obj{ch_task(1)}.ImageSize)== 2
    stats = regionprops(obj{ch_task(1)}, labelmatrix(obj{ch_task(2)})>0, 'MeanIntensity', 'Area');
    overlap = [stats.Area].*[stats.MeanIntensity];
    overlap_perArea = [stats.MeanIntensity];
else
    try
        stats = regionprops3(obj{ch_task(1)}, labelmatrix(obj{ch_task(2)})>0, 'MeanIntensity', 'Volume');
        overlap = [stats.Volume].*[stats.MeanIntensity];
        overlap_perArea = [stats.MeanIntensity];
    catch exception
        if (strcmp(exception.identifier, 'MATLAB:UndefinedFunction'))
            w = double(labelmatrix(obj{ch_task(1)}));
            overlap_matrix = w .* (labelmatrix(obj{ch_task(2)})>0);
            overlap = histcounts(overlap_matrix(:), 1:obj{ch_task(1)}.NumObjects+1)';
            overlap_perArea = overlap./(histcounts(w(:), 1:obj{ch_task(1)}.NumObjects+1))';
        else
            rethrow(exception.message);
        end
    end
end

overlap = overlap.*((objects.params.scaling_dxy/1000)*(objects.params.scaling_dxy/1000)*(objects.params.scaling_dxy/1000));

switch opts{task,7}
    case 0
        fprintf(' (per cell)');

        overlap = num2cell(overlap);
        [objects.stats.(sprintf('Correlation_Local3dOverlap_ch%d_ch%d', ch_task(2), ch_task(1)))] = overlap{:};
        
        overlap_perArea = num2cell(overlap_perArea);
        [objects.stats.(sprintf('Correlation_LocalOverlapFraction_ch%d_ch%d', ch_task(2), ch_task(1)))] = overlap_perArea{:};
        
    case 1
        fprintf(' (global)\n');
        
        overlap = sum(overlap);
        objects.globalMeasurements.(sprintf('Biofilm_Overlap_ch%d_ch%d', ch_task(1), ch_task(2))) = overlap;
        overlap_perArea = mean(overlap_perArea);
        objects.globalMeasurements.(sprintf('Biofilm_OverlapFraction_ch%d_ch%d', ch_task(1), ch_task(2))) = overlap_perArea;
end

end


