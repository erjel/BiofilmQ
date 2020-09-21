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
function range = assembleImageRange(array)
if isempty(array)
    range = '';
    return;
end

array = double(array);

if numel(array) == 1
    range = num2str(array);
else
    range = num2str(array(1));
    for i = 2:numel(array)
        if numel(array) > i
            if array(i+1) > array(i)+1 && array(i) == array(i-1)+1
                range = [range, ':', num2str(array(i))];
            end 
            
            if array(i-1)+1 < array(i) && array(i)+1 == array(i+1)
                range = [range, ' ', num2str(array(i))];
            end
            
            if array(i+1) > array(i)+1 && array(i) > array(i-1)+1
                range = [range, ' ', num2str(array(i))];
            end
            
        else
            if array(i) > array(i-1)+1
                range = [range, ' ', num2str(array(i))];
            end
            
            if i == numel(array) && array(i-1)+1 == array(i)
                range = [range, ':', num2str(array(i))];
            end
        end
    end
end


