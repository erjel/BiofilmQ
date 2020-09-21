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
function [objects] = calculatePearsonCorrelation(objects, img, ch_task, opts, task, range, params)

fprintf(' - determining Pearson''s correlation coefficient');

switch opts{task,7}
    case 0
        fprintf(' (per cell)');
        N = objects.NumObjects;
        
        
        s = round(range*(params.scaling_dxy/1000));
        fprintf(' - range corresponds to: %.2f um\n', s);
        
        [sX, sY, sZ] = size(img{ch_task(1)});
        
        pearson = nan(N, 1);
        
        centroids = [objects.stats.Centroid];
        centroids_floor = floor(centroids - range/2);
        centroids_ceil = ceil(centroids + range/2-1);
        bound_x = [centroids_floor(2:3:end); centroids_ceil(2:3:end)];
        bound_y = [centroids_floor(1:3:end); centroids_ceil(1:3:end)];
        bound_z = [centroids_floor(3:3:end); centroids_ceil(3:3:end)];
        
        bound_x(bound_x<1) = 1;
        bound_y(bound_y<1) = 1;
        bound_z(bound_z<1) = 1;
        bound_x(bound_x>sX) = sX;
        bound_y(bound_y>sY) = sY;
        bound_z(bound_z>sZ) = sZ;        
        
        for c = 1:N
            pearson(c) = pearson_coeff(...
                img{ch_task(1)}(bound_x(1,c):bound_x(2,c), bound_y(1,c):bound_y(2,c), bound_z(1,c):bound_z(2,c)), ...
                img{ch_task(2)}(bound_x(1,c):bound_x(2,c), bound_y(1,c):bound_y(2,c), bound_z(1,c):bound_z(2,c)));
        end
        
        pearson = num2cell(pearson);
        [objects.stats.(strrep(sprintf('Correlation_Pearson_ch%d_ch%d_range%d', ch_task(1), ch_task(2), range), '.', '_'))] = pearson{:};
        
    case 1
        fprintf(' (per stack)');
         
        
        
        
        
        
        
        
        
        img1 = img{ch_task(1)};
        img2 = img{ch_task(2)};
        
        
        
        
        objects.globalMeasurements.(sprintf('Biofilm_Correlation_Pearson_ch%d_ch%d', ch_task(1), ch_task(2))) = pearson_coeff(img1, img2);
end
end



