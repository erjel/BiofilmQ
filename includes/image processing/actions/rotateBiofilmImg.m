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
function [img_rotated, params] = rotateBiofilmImg(img, params, silent)
ticValue = displayTime;

if nargin <= 2
    silent = 0;
end

if ~silent
    fprintf(' - rotating image');
end

if ~isfield('params', 'slideRotationAngle')
    minMap = zeros(size(img, 1), size(img, 2));
    
    [~, brightestPlane] = max(sum(sum(img, 2), 1));
    
    t = multithresh(img(:,:,brightestPlane));
    img_t = img;
    img_t(img_t<t) = 0;
    
    for x = 1:size(img, 1)
        for y = 1:size(img, 2)
            [maxVal, idx] = max(img_t(x, y, :));
            
            if abs(brightestPlane - idx) < 5 && maxVal>0
                minMap(x, y) = idx;
            end
        end
    end
    minMap(~minMap) = NaN;
    X = 1:x;
    Y = 1:y;
    warning off;
    plane = fitPlane(X, Y, minMap);
    warning on;
    
    
    P = [0, 0, plane(0,0)];
    p1 = [0, 1000, plane(1000,0)-plane(0,0)];
    p2 = [1000, 0, plane(0,1000)-plane(0,0)];
    
    p1 = (p1)/norm(p1);
    p2 = (p2)/norm(p2);
    
    n = cross(p1, p2);
    n = n/norm(n);
    
    inters_line = cross(n, [0 0 1]);
    inters_line = inters_line/norm(inters_line);
    
    params.slideRotationAngle = atan2d(norm(cross(n,[0 0 1])),dot(n,[0 0 1]))-180;
end

if ~silent
    fprintf(', [angle_z=%.2f, vector=[%.2f %.2f %.2f]]', params.slideRotationAngle, inters_line(1), inters_line(2), inters_line(3));
end

img_rotated = imrotate3(img,params.slideRotationAngle,[inters_line(2) inters_line(1) inters_line(3)]);

if ~silent
    ticValue = displayTime(ticValue);
end



