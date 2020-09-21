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
function biofilmData = determineIsRelatedToFounderCells(handles, biofilmData)

if ~isfield(biofilmData.params, 'searchRadiusBiofilm')
    biofilmData.params.searchRadiusBiofilm = str2num(handles.handles_analysis.uicontrols.edit.edit_scanRadius.String);
end

fhypot = @(a,b,c) sqrt(abs(a).^2+abs(b).^2+abs(c).^2);

scanRadius = biofilmData.params.searchRadiusBiofilm/(biofilmData.params.scaling_dxy/1000);

for i = 1:numel(biofilmData.data) 
    
    if i ~= 1 && biofilmData.data(i).NumObjects > 10
        IsRelatedToFounderCells1 = [biofilmData.data(i-1).stats.IsRelatedToFounderCells];
        IsRelatedToFounderCells2 = zeros(biofilmData.data(i).NumObjects, 1);
        
        coords1 = [biofilmData.data(i-1).stats(logical(IsRelatedToFounderCells1)).Centroid];
        coords2 = {biofilmData.data(i).stats.Centroid};
        
        parfor obj2ID = 1:numel(coords2)
            
            
            coordsOfActualCell = coords2{obj2ID};
            
            x = coords1(1:3:end);
            y = coords1(2:3:end);
            z = coords1(3:3:end);
            
            dist = fhypot(coordsOfActualCell(1)-x, coordsOfActualCell(2)-y, coordsOfActualCell(3)-z);
            
            IsRelatedToFounderCells2(obj2ID) = any(dist < scanRadius);
        end
    else
        IsRelatedToFounderCells2 = ones(biofilmData.data(i).NumObjects, 1);
    end
    
    
    IsRelatedToFounderCells2 = num2cell(logical(IsRelatedToFounderCells2));
    [biofilmData.data(i).stats.IsRelatedToFounderCells] = IsRelatedToFounderCells2{:};
end


