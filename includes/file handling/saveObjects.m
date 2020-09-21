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
function saveObjects(filename, objects, fieldnames, writeMode, silent)
[~, fname] = fileparts(filename);

measurementFields = fields(objects.stats);

fieldnames_save = fields(objects);

if nargin < 3
    fieldnames = 'all';
    writeMode = '-append';
end

if nargin < 4 
    writeMode = '-append';
end

if nargin < 5 
    silent = 0;
end

if ~silent
    fprintf(' - saving cells [%s.mat]', fname)
    ticValue = displayTime;
    textprogressbar('      ');
end

if strcmp(fieldnames, 'PixelIdxList')
    if isfield(objects, 'stats')
        objects = rmfield(objects, 'stats');
    end
end
if strcmp(fieldnames, 'stats')
    if isfield(objects, 'PixelIdxList')
        objects = rmfield(objects, 'PixelIdxList');
    end
end

objects.measurementFields = fields(objects.stats);

props = whos('objects');

if strcmp(writeMode, '-append')
    if props.bytes*10^(-9)>2
        save(filename, '-struct', 'objects', '-append', '-v7.3');
    else
        save(filename, '-struct', 'objects', '-append');
    end
else
    if props.bytes*10^(-9)>2
        save(filename, '-struct', 'objects', '-v7.3');
    else
        save(filename, '-struct', 'objects');
    end
end


if ~silent
    textprogressbar(100);
    textprogressbar(' Done.');
    displayTime(ticValue);
end



