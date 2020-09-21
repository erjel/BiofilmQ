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
try
    Track_IDs = [handles.data.objects.stats.Track_ID];
    nColors = max(Track_IDs);
catch
    nColors = handles.data.objects.NumObjects;
end
    
displayStatus(handles, ['Creating colormap with ',num2str(nColors),' entries...'], 'black');


fid = fopen(fullfile(handles.settings.directory, 'data', ['cmap_N',num2str(nColors),'.json']),'wt');

str = '[\n{\n"ColorSpace" : "HSV",\n"Name" : "Preset 2",\n';

str = [str, '"RGBPoints" : ['];

prompt = {'Enter ID of cells to be highlighted (enter "rand" for random colors)'};
dlg_title = 'Colormap parameters';
num_lines = 1;
defaultans = {'rand'};
answer = inputdlg(prompt,dlg_title,num_lines,defaultans);
if ~isempty(answer)
    if strcmp(answer{1}, 'rand')
        for i = 1:nColors
            str = [str, ' ', num2str(i), ', ', num2str(rand), ', ', '0', ', ', '0', ','];
        end
        
    else
        defaultColor = [0.9 0.9 0.9];
        entries = str2num(answer{1});
        colors = colormap(lines(numel(entries)));
        
        count = 1;
        for i = 1:nColors
            if sum(find(entries == i))
                str = [str, ' ', num2str(i), ', ', num2str(colors(count, 1)), ', ', num2str(colors(count, 2)), ', ', num2str(colors(count, 3)), ','];
                count = count + 1;
            else
                str = [str, ' ', num2str(i), ', ', num2str(defaultColor(1)), ', ', num2str(defaultColor(2)), ', ', num2str(defaultColor(3)), ','];
            end
        end
    end
    
    
    str(end) = '';
    str = [str, ' ]\n}\n]'];
    
    fprintf(fid, str);
    fclose(fid);
    
    
    displayStatus(handles, 'Done', 'black', 'add');
else
    displayStatus(handles, 'Canceled', 'black', 'add');
end



