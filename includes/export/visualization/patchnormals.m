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
function n = patchnormals(FV)

A = FV.faces(:,1);
B = FV.faces(:,2);
C = FV.faces(:,3);

n = cross(FV.vertices(A,:)-FV.vertices(B,:),FV.vertices(C,:)-FV.vertices(A,:)); 


N = zeros(size(FV.vertices)); 
for i = 1:size(FV.faces,1) 
N(A(i),:) = N(A(i),:)+n(i,:); 
N(B(i),:) = N(B(i),:)+n(i,:);
N(C(i),:) = N(C(i),:)+n(i,:);
end


