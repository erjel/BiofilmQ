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
function [objects, img_noBG] = calculateMeanIntensityPerObject(objects, img, ch_task, background, img_noBG)


stats_MeanIntensity_temp{ch_task} = regionprops(objects, img{ch_task}, 'MeanIntensity');
stats_MeanIntensity_temp{ch_task} = num2cell([stats_MeanIntensity_temp{ch_task}.MeanIntensity]);
[objects.stats.(sprintf('Intensity_Mean_ch%d', ch_task))] = stats_MeanIntensity_temp{ch_task}{:};

img_noBG{ch_task} = img{ch_task}-background(ch_task);
img_noBG{ch_task}(img_noBG{ch_task}<0) = 0;
stats_MeanIntensity_noBackground_temp{ch_task} = regionprops(objects, img_noBG{ch_task}, 'MeanIntensity');
stats_MeanIntensity_noBackground_temp{ch_task} = num2cell([stats_MeanIntensity_noBackground_temp{ch_task}.MeanIntensity]);
[objects.stats.(sprintf('Intensity_Mean_ch%d_noBackground', ch_task))] = stats_MeanIntensity_noBackground_temp{ch_task}{:};



end



