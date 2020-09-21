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
function [objects, img_noBG] = calculateIntegratedFluorescenceRatio(objects, img, ch_task, background, img_noBG )


for ch_task_ratio = ch_task
    stats_MeanIntensity_temp{ch_task_ratio} = regionprops(objects, img{ch_task_ratio}, 'MeanIntensity');
    
    if isempty(img_noBG{ch_task_ratio})
        img_noBG{ch_task_ratio} = img{ch_task_ratio}-background(ch_task_ratio);
        img_noBG{ch_task_ratio}(img_noBG{ch_task_ratio}<0) = 0;
    end
    stats_MeanIntensity_noBackground_temp{ch_task_ratio} = regionprops(objects, img_noBG{ch_task_ratio}, 'MeanIntensity');
end

ratio = num2cell(([stats_MeanIntensity_temp{ch_task(2)}.MeanIntensity].*[objects.stats.Shape_Volume])./([stats_MeanIntensity_temp{ch_task(1)}.MeanIntensity].*[objects.stats.Shape_Volume]));
[objects.stats.(sprintf('Intensity_Ratio_Integrated_ch%d_ch%d', ch_task(2), ch_task(1)))] = ratio{:};

ratio = num2cell(([stats_MeanIntensity_noBackground_temp{ch_task(2)}.MeanIntensity].*[objects.stats.Shape_Volume])./([stats_MeanIntensity_noBackground_temp{ch_task(1)}.MeanIntensity].*[objects.stats.Shape_Volume]));
[objects.stats.(sprintf('Intensity_Ratio_Integrated_ch%d_ch%d_noBackground', ch_task(2), ch_task(1)))] = ratio{:};

end


