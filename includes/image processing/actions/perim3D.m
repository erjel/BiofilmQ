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
function e = perim3D(w)


if ~isa(w,'double') && ~isa(w,'single')
    w = double(w);
end

[m,n,o] = size(w);


if o == 1
    
    e = false(m-2,n-2,1);

    rr = 2:m-1; cc=2:n-1; zz=1;
else
    
    e = false(m-2,n-2,o-2);

    rr = 2:m-1; cc=2:n-1; zz=2:o-1;
end


ind = find( w(rr,cc,zz) > w(rr,cc+1,zz));
e(ind) = 1;


ind = find( w(rr,cc-1,zz) < w(rr,cc,zz));
e(ind) = 1;


ind = find( w(rr,cc,zz) > w(rr+1,cc,zz));
e(ind) = 1;


ind = find( w(rr-1,cc,zz) < w(rr,cc,zz));
e(ind) = 1;


if numel(zz) > 1
    
    
    ind = find( w(rr,cc,zz) > w(rr,cc,zz+1));
    
    
    
    e(ind) = 1;
    
    
    
    
    ind = find( w(rr,cc,zz-1) < w(rr,cc,zz));
    
    
    
    e(ind) = 1;
    
    
    e = padarray(e, [1 1 1], 0);
else
    e = padarray(e, [1 1], 0);
end
    







