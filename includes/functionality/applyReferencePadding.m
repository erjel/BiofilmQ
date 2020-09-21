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
function [img, x, y] = applyReferencePadding(params,img)

    currentFrame = params.cropRangeAfterRegistration;
    refFrame = params.registrationReferenceCropping;
    
    if params.scaleUp
        scaleFactor = params.scaleFactor;
    else
        scaleFactor = 1;
    end
    
    
    startX = round((currentFrame(2)-refFrame(2)+1)*scaleFactor);
    startX = max(startX, 1);
    dX = size(img,1)-1;
    x = round(startX:startX+dX);
    startY = round((currentFrame(1)-refFrame(1)+1)*scaleFactor);
    startY = max(startY, 1);
    dY = size(img,2)-1;
    y = round(startY:startY+dY);
    
    refStack = zeros(round((refFrame(4)+1)*scaleFactor), round((refFrame(3)+1)*scaleFactor),  size(img, 3));
    refStack(x,y,:) = img;

    img = refStack;

end




