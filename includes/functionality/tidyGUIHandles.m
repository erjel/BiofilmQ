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
function handles = tidyGUIHandles(handles)

entries = sort(fieldnames(handles));
for i = 1:size(entries, 1)
    entry = entries{i};
    if strfind(entry, 'menu')
        if isempty(strfind(entry, 'popupmenu'))
            handles.menuHandles.menues.(entry) = handles.(entry);
            handles = rmfield(handles, entry);
        end
    end
    if strfind(entry, 'context')
        handles.menuHandles.context.(entry) = handles.(entry);
        handles = rmfield(handles, entry);
    end
    if strfind(entry, 'uitoolbar')
        handles.menuHandles.uitoolbars.(entry) = handles.(entry);
        handles = rmfield(handles, entry);
    end
    if strfind(entry, 'Context')
        handles.menuHandles.context.(entry) = handles.(entry);
        handles = rmfield(handles, entry);
    end
    if strfind(entry, 'colormap_')
        handles.menuHandles.context.colormaps.(entry) = handles.(entry);
        handles = rmfield(handles, entry);
    end
    if strfind(entry, 'uitoggletool')
        handles.menuHandles.uitoggletools.(entry) = handles.(entry);
        handles = rmfield(handles, entry);
    end
    try
        if strcmp(get(handles.(entry), 'Type'), 'uicontrol')
            handles.uicontrols.(get(handles.(entry), 'Style')).(entry) = handles.(entry);
            handles = rmfield(handles, entry);
        end
    end
    try
        if strcmp(get(handles.(entry), 'Type'), 'uitable')
            handles.uitables.(entry) = handles.(entry);
            handles = rmfield(handles, entry);
        end
    end
    if strfind(entry, 'uipanel')
        handles.layout.uipanels.(entry) = handles.(entry);
        handles = rmfield(handles, entry);
    end
    if strfind(entry, 'axes')
        handles.axes.(entry) = handles.(entry);
        handles = rmfield(handles, entry);
    end
end


