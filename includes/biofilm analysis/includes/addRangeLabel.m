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
function [rangeLabel, channel] = addRangeLabel(fieldName, unit, keywords)
if nargin == 1
    unit = '';
end

if nargin < 3
    keywords = [];
end

rangeLabel = '';
range = '';

rangeIdx = strfind(fieldName, '_range');

if ~isempty(rangeIdx)
    rangeIdx_end = strfind(fieldName(rangeIdx+1:end), '_');
    if ~isempty(rangeIdx_end)
        range = fieldName(rangeIdx+6:rangeIdx+rangeIdx_end-1);
    else
        range = fieldName(rangeIdx+6:end);
    end
end

chIdx = strfind(fieldName, '_ch');
if ~isempty(chIdx)
    channel = zeros(numel(chIdx), 1);
    for i = 1:numel(chIdx)
        channel(i) = str2num(fieldName(chIdx(i)+3));
    end
else
    channel = [];
end

if ~isempty(keywords)
    if ~iscell(keywords)
        keywords = {keywords, 'vox'};
    end
    for k = 1:2:numel(keywords)
        keyIdx = strfind(fieldName, ['_', keywords{k}]);
        if ~isempty(keyIdx)
            keyIdx_end = strfind(fieldName(keyIdx+1:end), '_');
            if ~isempty(keyIdx_end)
                key = fieldName(keyIdx+numel(keywords{k})+1:keyIdx+keyIdx_end-1);
            else
                key = fieldName(keyIdx+numel(keywords{k})+1:end);
            end
            rangeLabel = sprintf('%s (%s=%s%s)', rangeLabel, keywords{k}, key, keywords{k+1});
        end
    end
end

if ~isempty(range)
    rangeLabel = sprintf('%s (range=%s%s)', rangeLabel, range, unit);
end

ind = strfind(fieldName, '_');
if ~isempty(ind)
    range = fieldName(ind(end)+1:end);
end
try
    if strcmp(range, 'lineage')
        rangeLabel = sprintf('%s %s', rangeLabel, 'along lineage');
    end
end


