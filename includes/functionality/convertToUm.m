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
function convertedValue = convertToUm(handles,curVal,exponent)

        pxSize = str2double(handles.uicontrols.edit.scaling_dxy.String)/1000;
        
        if handles.uicontrols.checkbox.scaleUp.Value
            scaling = str2double(handles.uicontrols.edit.scaleFactor.String);
            pxSize = pxSize/scaling;
        end
        pxSize = pxSize^exponent;
        
        convertedValue = pxSize*curVal;
end




