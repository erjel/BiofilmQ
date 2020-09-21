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
function handles = assignCallbacks(handles, importedChildren, newParent)

newHandlesofChildren = get(newParent, 'Children');

for i = 1:length(importedChildren)
    try
        cb = get(importedChildren(i), 'Callback');
        
        set(newHandlesofChildren(i), 'Callback', cb);
    end
    
    try
        cb = get(importedChildren(i), 'CellSelectionCallback');
        
        set(newHandlesofChildren(i), 'CellSelectionCallback', cb);
    end
    
    try
        cb = get(importedChildren(i), 'CellEditCallback');
        
        set(newHandlesofChildren(i), 'CellEditCallback', cb);
    end
    
    
    
    subChildren = get(importedChildren(i), 'Children');
    newHandlesofSubChildren = get(newHandlesofChildren(i), 'Children');
    for j = 1:length(subChildren)
        try
            cb = get(subChildren(j), 'Callback');
            
            set(newHandlesofSubChildren(j), 'Callback', cb);
        end
    end

end



