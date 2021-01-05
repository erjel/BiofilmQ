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

function displayStatus(handles, str, color, add)

maxLength = 9;
lineLimit = 90;

if nargin <= 3
    add = false;
    if strcmp(color, 'green')
        color = '003300';
    end
    
else
    add = true;
    color = 'gray';
end


try
    status_str = get(handles.uicontrols.listbox.listbox_status, 'String');
catch err
    warning(err.message)
    status_str = {''};
end


if ~iscell(status_str)
    status_str = {status_str};
end

if ~add
    
    currentLength = min([maxLength, length(status_str)]);
    currentLength = max(2, currentLength);
    
    status_str(2:currentLength) = status_str(1:currentLength-1);
    status_str{1} = sprintf('<html><font color="%s">- %s', color, str);
    
else
    oldString = status_str{1};
    
    if nonHtmlLongerThanLimit(oldString, lineLimit)
        oldString = '<html>';
    end
    status_str{1} = sprintf('%s <font color="%s">%s', oldString , color, str);
end

try
    set(handles.uicontrols.listbox.listbox_status, 'String',status_str, 'Value', 1);
    drawnow;
catch err
    warning(err.message)
end

end

function boolean = nonHtmlLongerThanLimit(str, limit)
nonHTMLstr = regexprep(str, '<.*?>', '');
boolean = length(nonHTMLstr) > limit;
end


