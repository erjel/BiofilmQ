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
function [img, params] = getND2Plane(reader, pos, z, ch, t)

reader.setSeries(pos-1);
iPlane = reader.getIndex(z-1, ch-1, t-1)+1;
img = double(bfGetPlane(reader, iPlane));

omeMeta = reader.getMetadataStore();
params.t = double(omeMeta.getPlaneDeltaT(0, iPlane));
params.dxy = str2num(char(omeMeta.getPixelsPhysicalSizeX(0)));
params.dz = str2num(char(omeMeta.getPixelsPhysicalSizeZ(0)));


