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
function objects = calculateLocalDensity(objects, range)

ticValue = displayTime;


N = objects.NumObjects;
goodObjects = objects.goodObjects;
centroids = [objects.stats.Centroid];

scaling_dxy = objects.params.scaling_dxy;

toUm = @(voxel, scaling) voxel.*scaling/1000;
toPix = @(voxel, scaling) voxel./(scaling/1000);
fhypot = @(a,b,c) sqrt(abs(a).^2+abs(b).^2+abs(c).^2);

range_um = toUm(range, scaling_dxy);
rangePix = range;
try
    fprintf(' - prepare calculation');
    
    if numel(objects.ImageSize) == 3 
        
        
        localDensity_num = zeros(N,1);
        Vs = 4/3*pi*range_um^3;
        
        Cx = centroids(1:3:end);
        Cy = centroids(2:3:end);
        Cz = centroids(3:3:end);
        
        
        
        localDensity = zeros(N,1);
        
        centroids_ = ceil(centroids);
        x = centroids_(1:3:end);
        x_ = x + 2*rangePix-1;
        y = centroids_(2:3:end);
        y_ = y + 2*rangePix-1;
        z = centroids_(3:3:end);
        z_ = z + 2*rangePix-1;
        
        
        [X, Y, Z] = meshgrid(1:2*rangePix, 1:2*rangePix, 1:2*rangePix);
        X = X(:);
        Y = Y(:);
        Z = Z(:);
        V = fhypot(rangePix - X, rangePix - Y, rangePix - Z);
        
        
        sphere = int8(V < rangePix);
        
        Vsphere = sum(sphere(:));
        
        
        objects.Connectivity = 26;
        
        w = labelmatrix(objects);
        for i = 1:N
            w(i == find(~goodObjects)) = 0;
        end
        w = int8(w>0); 
        w = padarray(w, [rangePix rangePix rangePix], -1);
        
        
        fprintf(', calculate local densities\n');
        h = ProgressBar(round(N/100));
        
        parfor i = 1:N
            if ~mod(i, 100)
                h.progress;
            end
            
            
            try
                distances = fhypot(Cx(i)-Cx, Cy(i)-Cy, Cz(i)-Cz);
                distances(~goodObjects) = Inf;
                distances = toUm(distances, scaling_dxy);
                
                
                if numel(distances) > 1
                    [~, id_min] = min(distances);
                    distances(id_min) = [];
                end
                
                localDensity_num(i) =  sum(distances < range_um)/Vs;
            catch
                localDensity_num(i) = NaN;
            end
            
            
            try
                localMap = w(...
                    y(i):y_(i),...
                    x(i):x_(i),...
                    z(i):z_(i) ...
                    );
                localMap = localMap(:).*sphere;
                
                outOfRange = sum(localMap==-1);
                
                localDensity(i) = sum(localMap==1)/(Vsphere - outOfRange);
            catch
                localDensity(i) = NaN;
            end
            
        end
        
    else 
        
        localDensity_num = zeros(N,1);
        Vs = pi*range_um^2;
        
        Cx = centroids(1:3:end);
        Cy = centroids(2:3:end);      
        
        
        localDensity = zeros(N,1);
        
        centroids_ = ceil(centroids);
        x = centroids_(1:3:end);
        x_ = x + 2*rangePix-1;
        y = centroids_(2:3:end);
        y_ = y + 2*rangePix-1;
        
        
        [X, Y] = meshgrid(1:2*rangePix, 1:2*rangePix);
        X = X(:);
        Y = Y(:);
        V = hypot(rangePix - X, rangePix - Y);
        
        
        sphere = int8(V < rangePix);
        
        Vsphere = sum(sphere(:));
                
        w = labelmatrix(objects);
        for i = 1:N
            w(i == find(~goodObjects)) = 0;
        end
        w = int8(w>0); 
        w = padarray(w, [rangePix rangePix], -1);
        
        
        fprintf(', calculate local densities\n');
        h = ProgressBar(round(N/100));
        
        parfor i = 1:N
            if ~mod(i, 100)
                h.progress;
            end
            
            
            try
                distances = hypot(Cx(i)-Cx, Cy(i)-Cy);
                distances(~goodObjects) = Inf;
                distances = toUm(distances, scaling_dxy);
                
                
                if numel(distances) > 1
                    [~, id_min] = min(distances);
                    distances(id_min) = [];
                end
                
                localDensity_num(i) =  sum(distances < range_um)/Vs;
            catch
                localDensity_num(i) = NaN;
            end
            
            
            try
                localMap = w(...
                    y(i):y_(i),...
                    x(i):x_(i)...
                    );
                localMap = localMap(:).*sphere;
                
                outOfRange = sum(localMap==-1);
                
                localDensity(i) = sum(localMap==1)/(Vsphere - outOfRange);
            catch
                localDensity(i) = NaN;
            end
            
        end 
    end
    h.stop;
    fprintf('   - local number density [range: %d vox] on average <rho>=%.02f\n', range, nanmean(localDensity_num));
    
    localDensity_num = num2cell(localDensity_num);
    [objects.stats.(sprintf('Architecture_LocalNumberDensity_range%d', range))] = localDensity_num{:};
    
    
    
    fprintf('   - local density [range: %d vox] on average <rho>=%.02f', range, nanmean(localDensity));
    
    localDensity = num2cell(localDensity);
    [objects.stats.(sprintf('Architecture_LocalDensity_range%d', range))] = localDensity{:};
    
catch err
    warning('backtrace', 'off');
    warning(err.message);
    warning('backtrace', 'on')
end

displayTime(ticValue);




