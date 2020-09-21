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
function objects = calculateLocalAreaDensity(objects, params, range)

N = objects.NumObjects;
centroids = [objects.stats.Centroid];

fhypot = @(a,b,c) sqrt(abs(a).^2+abs(b).^2+abs(c).^2);

rangePix = range;
try
    fprintf(' - prepare calculation');
    
    
    localAreaDensity = zeros(N,1);
    
    centroids_ = ceil(centroids);
    
    if numel(objects.ImageSize) == 3 
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
            w(i == find(~objects.goodObjects)) = 0;
        end
        w = int8(bwperim(w)>0); 
        w = padarray(w, [rangePix rangePix rangePix], -1);
        
        
        fprintf(', calculate local roughness\n');
        h = ProgressBar(round(N/100));
        
        parfor i = 1:N
            if ~mod(i, 100)
                h.progress;
            end
            
            try
                localMap = w(...
                    y(i):y_(i),...
                    x(i):x_(i),...
                    z(i):z_(i) ...
                    );
                localMap = localMap(:).*sphere;
                
                outOfRange = sum(localMap==-1);
                
                localAreaDensity(i) = sum(localMap==1)/(Vsphere - outOfRange);
            catch
                localAreaDensity(i) = NaN;
            end
            
        end
    else 
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
            w(i == find(~objects.goodObjects)) = 0;
        end
        w = int8(bwperim(w)>0); 
        w = padarray(w, [rangePix rangePix], -1);
        
        
        fprintf(', calculate local roughness\n');
        h = ProgressBar(round(N/100));
        
        parfor i = 1:N
            if ~mod(i, 100)
                h.progress;
            end
            
            try
                localMap = w(...
                    y(i):y_(i),...
                    x(i):x_(i)...
                    );
                localMap = localMap(:).*sphere;
                
                outOfRange = sum(localMap==-1);
                
                localAreaDensity(i) = sum(localMap==1)/(Vsphere - outOfRange);
            catch
                localAreaDensity(i) = NaN;
            end
            
        end
    end
    
    
    h.stop;
        
    fprintf('   - local roughness (area density) [range: %d vox] on average <rho_area>=%.02f um\n', range, nanmean(localAreaDensity));
    
    localAreaDensity = num2cell(localAreaDensity);
    [objects.stats.(sprintf('Surface_LocalRoughness_range%d', range))] = localAreaDensity{:};
    
catch err
    warning(err.message);
end




