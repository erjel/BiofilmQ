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
function objects_shells = calculateObjectShells(objects, shellSize)

if isfield(objects.stats, 'Grid_ID')
    outline = find(bwperim(labelmatrix(objects)>0));
else
    outline = 0;
end

    
    
    objects_shells = objects;
    PixelIdxList = objects.PixelIdxList;
    PixelIdxList_shell = cell(1, numel(PixelIdxList));
    imageSize = objects.ImageSize;
    
    parfor i = 1:numel(PixelIdxList)
        shell = PixelIdxList{i};
        
        if outline
            shell = intersect(shell, outline);
        end
        
        for s = 1:shellSize
            if outline
                shell = setdiff(neighbourND(shell, imageSize), PixelIdxList{i});
            else
                shell = setxor(neighbourND(shell, imageSize), PixelIdxList{i});
            end
        end
        shell(~shell) = [];
        PixelIdxList_shell{i} = shell;
    end
    objects_shells.PixelIdxList = PixelIdxList_shell;

end


