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
function cancelled = checkCancelButton(handles, type)
cancelled = false;

if nargin == 1
    type = 'cancel';
end
try 
    if get(handles.uicontrols.pushbutton.pushbutton_cancel, 'UserData')
        switch type
            case 'cancel'
                displayStatus(handles, 'Processing cancelled!', 'red', 'add');
                updateWaitbar(handles, 0);
                set(handles.uicontrols.pushbutton.pushbutton_cancel, 'UserData', 0, 'Enable', 'off', 'String', 'Cancel');
                cancelled = true;
                uiwait(msgbox('Task was cancelled!', 'Please note', 'warn', 'modal'))
            case 'continue'
                displayStatus(handles, 'Continuing', 'red', 'add');
                set(handles.uicontrols.pushbutton.pushbutton_cancel, 'UserData', 0, 'String', 'Cancel')
                cancelled = true;
        end
    end
end


