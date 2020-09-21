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
function [objects, img_noBG, img_corr] = calculateMeanIntensityPerObjectShell(objects, img, ch_task, background, range, img_noBG, img_corr)

objects_shells = calculateObjectShells(objects, range);

if isempty(img_noBG{ch_task})
    
    img_noBG{ch_task} = img{ch_task}-background(ch_task);
    img_noBG{ch_task}(img_noBG{ch_task}<0) = 0;
end


stats_temp_shell = regionprops(objects_shells, img{ch_task}, 'MeanIntensity');
stats_temp_shell = num2cell([stats_temp_shell.MeanIntensity]);
[objects.stats.(sprintf('Intensity_Shells_Mean_ch%d_range%d', ch_task, range))] = stats_temp_shell{:};


stats_temp_shell = regionprops(objects_shells, img_noBG{ch_task}, 'MeanIntensity');
stats_temp_shell = num2cell([stats_temp_shell.MeanIntensity]);
[objects.stats.(sprintf('Intensity_Shells_Mean_noBackground_ch%d_range%d', ch_task, range))] = stats_temp_shell{:};


end


