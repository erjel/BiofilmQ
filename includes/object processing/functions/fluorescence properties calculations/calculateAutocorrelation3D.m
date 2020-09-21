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

function [zero3D, zero2D, zero2D_Substrate, rVec, autocorr3D_mean, autocorrXY_mean, autocorrXY_substrate, autocorrXY_mean_par, posPixFraction] = calculateAutocorrelation3D(imBW, params)


ticValue = displayTime;

imBW = logical(imBW);
if nargin < 2
    
    params.scaling = 0.0632; 
    
    
    
    params.scaleFactor = 0.25;
    
    
    params.dr = 1;
    
    params.dilation = 0;
    
    
    
    params.fullFrame = 0;
end

if params.dilation
    imBW = imdilate(imBW, ones(3,3,3));
end

if params.scaleFactor ~= 1
    fprintf('    resizing image [scale = %.2f]\n', params.scaleFactor);
    
    
    
    
    if size(imBW, 3) == 1
        T = affine2d([params.scaleFactor 0 0; 0 params.scaleFactor 0; 0 0 1]);
    else
        T = affine3d([params.scaleFactor 0 0 0; 0 params.scaleFactor 0 0; 0 0 params.scaleFactor 0; 0 0 0 1]);
    end
    imBW = imwarp(double(imBW), T, 'interp', 'linear', 'FillValues', 1);
end

posPixFraction = squeeze(sum(sum(imBW, 1), 2)./(size(imBW,1)*size(imBW,2)));

r_max = size(imBW, 1);
fprintf('    correlating over length [d = %d px, %.1f um, dxyz = %.2f um/px, dr = %d px, dilation = %d, full frame = %d]\n', r_max, r_max*params.scaling, params.scaling, params.dr, params.dilation, params.fullFrame);

rVec = 0:params.dr:r_max;

autocorr3D_mean = NaN;
if size(imBW, 3) > 1
    
    fprintf('        -> in 3D');
    
    meanVal = mean(imBW(:));
    if params.fullFrame
        sX = size(imBW,1);
        sY = size(imBW,2);
        sZ = size(imBW,3);
        
        SFFT = 2*max([sX sY sZ]);
        correlationMap = meanVal*ones(SFFT,SFFT,SFFT);
        
        correlationMap(floor((SFFT-sX)/2):floor((SFFT+sX)/2)-1,...
            floor((SFFT-sY)/2):floor((SFFT+sY)/2)-1,...
            floor((SFFT-sZ)/2):floor((SFFT+sZ)/2)-1)= imBW;
        
        correlationMap_ref = zeros(SFFT,SFFT,SFFT);
        correlationMap_ref(floor((SFFT-sX)/2):floor((SFFT+sX)/2)-1,...
            floor((SFFT-sY)/2):floor((SFFT+sY)/2)-1,...
            floor((SFFT-sZ)/2):floor((SFFT+sZ)/2)-1) = 1;
    else
        correlationMap = imBW;
        correlationMap_ref = ones(size(imBW));
    end
    
    autocorr3D = abs(fftshift(ifftn(fftn(correlationMap).*conj(fftn(correlationMap)))));
    autocorr3D = autocorr3D - numel(correlationMap)*meanVal^2;
    autocorr3D_ref = abs(fftshift(ifftn(fftn(correlationMap_ref).*conj(fftn(correlationMap_ref)))));
    autocorr3D = autocorr3D./autocorr3D_ref;
    
    autocorr3D_mean = zeros(numel(rVec)-1, 1);
    autocorr3D_std = zeros(numel(rVec)-1, 1);
    
    
    x_c_m = round(size(autocorr3D,1)/2);
    y_c_m = round(size(autocorr3D,2)/2);
    z_c_m = round(size(autocorr3D,3)/2);
    
    
    
    indFrame = find(autocorr3D);
    [x_c, y_c, z_c] = ind2sub(size(autocorr3D), indFrame);
    
    fhypot = @(a,b,c) sqrt(abs(a).^2+abs(b).^2+abs(c).^2);
    
    dist = fhypot(x_c_m-x_c, y_c_m-y_c, z_c_m-z_c);
    
    for r_ind = 1:numel(rVec)-1
        indDist = find(dist > rVec(r_ind) & dist <= rVec(r_ind+1));
        
        ind = sub2ind(size(autocorr3D), x_c(indDist), y_c(indDist), z_c(indDist));
        autocorr3D_mean(r_ind, :) = mean(autocorr3D(ind));
        autocorr3D_std(r_ind, :) = std(autocorr3D(ind));
    end
    
    
    
    
end

fprintf(', for all xy-planes');
data_par = cell(size(imBW, 3), 1);
for z = 1:size(imBW, 3)
    data_par{z} = imBW(:,:,z);
end

[~, substrateID] = max(cellfun(@(x) sum(x(:)), data_par));

autocorrXY_mean_par = cell(size(imBW, 3), 1);
autocorrXY_std_par = cell(size(imBW, 3), 1);

parfor z = 1:size(imBW, 3)
    imBW_z = data_par{z};
    
    meanVal = mean(imBW_z(:));
    
    if params.fullFrame
        
        
        sX = size(imBW_z,1);
        sY = size(imBW_z,2);
        
        SFFT =2*max([sX sY]);
        
        correlationMap = meanVal*ones(SFFT,SFFT);
        
        correlationMap(floor((SFFT-sX)/2):floor((SFFT+sX)/2)-1,...
            floor((SFFT-sY)/2):floor((SFFT+sY)/2)-1) = imBW_z;

        correlationMap_ref = zeros(size(correlationMap,1),size(correlationMap,2));
        correlationMap_ref(floor((SFFT-sX)/2):floor((SFFT+sX)/2)-1,...
            floor((SFFT-sY)/2):floor((SFFT+sY)/2)-1) = 1;

    else
        correlationMap = imBW_z;
        correlationMap_ref = ones(size(imBW_z));
    end
    
    autocorrXY = autocorr2d(correlationMap);
    autocorrXY = autocorrXY - numel(correlationMap)*meanVal*meanVal;
    
    autocorrXY_ref = autocorr2d(ones(size(correlationMap_ref)));
    autocorrXY = autocorrXY./autocorrXY_ref;
    
    autocorrXY_mean_par{z} = zeros(numel(rVec)-1, 1);
    autocorrXY_std_par{z} = zeros(numel(rVec)-1, 1);
    
    
    x_c_m = round(size(autocorrXY,1)/2);
    y_c_m = round(size(autocorrXY,2)/2);
    
    
    
    indFrame = find(autocorrXY);
    [x_c, y_c] = ind2sub(size(autocorrXY), indFrame);
    
    
    dist = hypot(x_c_m-x_c, y_c_m-y_c);
    
    for r_ind = 1:numel(rVec)-1
        indDist = find(dist > rVec(r_ind) & dist <= rVec(r_ind+1));
        
        ind = sub2ind(size(autocorrXY), x_c(indDist), y_c(indDist));
        autocorrXY_mean_par{z}(r_ind, :) = nanmean(autocorrXY(ind));
        autocorrXY_std_par{z}(r_ind, :) = nanstd(autocorrXY(ind));
    end
    
    
    
    
end

autocorrXY_mean = nanmean([autocorrXY_mean_par{:}], 2);
autocorrXY_std = nanstd([autocorrXY_mean_par{:}], [], 2);
autocorrXY_substrate = autocorrXY_mean_par{substrateID};

rVec = rVec/params.scaleFactor*params.scaling;

zero3D = rVec(find(autocorr3D_mean < 0, 1));
if isempty(zero3D)
    zero3D = NaN;
end
zero2D = rVec(find(autocorrXY_mean < 0, 1));
zero2D_Substrate = rVec(find(autocorrXY_substrate < 0, 1));

if isempty(zero2D)
    zero2D = NaN;
end
if isempty(zero2D_Substrate)
    zero2D_Substrate = NaN;
end
displayTime(ticValue);




