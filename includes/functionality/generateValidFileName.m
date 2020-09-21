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
function newName = generateValidFileName(filename, index, s3)

if strcmp(filename(end-3:end), '.tif')
    filename = filename(1:end-4);
end
fileNameProps = getFeaturesFromName(filename);
startInd = length(filename);

if ~isnan(fileNameProps.pos)
    position = fileNameProps.pos;
    startInd = min(startInd, fileNameProps.pos_index-4);
else
    position = 1;
end
if ~isnan(fileNameProps.frame)
    frame = fileNameProps.frame;
    startInd = min(startInd, fileNameProps.frame_index-6);
else
    frame = index;
end
if ~isnan(fileNameProps.channel)
    channel = fileNameProps.channel;
    startInd = min(startInd, fileNameProps.channel_index-3);
else
    channel = 1;
end

newName = filename(1:startInd);
newName = strcat(newName, sprintf('pos%d_ch%d_frame', position, channel), num2str(frame, '%06d'), '_Nz', num2str(s3));

end


