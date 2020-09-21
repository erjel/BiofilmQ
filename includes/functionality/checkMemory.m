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
function checkMemory(handles, memSize, displayOutput)
if nargin == 2
    displayOutput = 1;
end

flag1 = 1;
flag2 = 1;
[~, systemview] = memory;
count = 1;
waitForMoreMem = 1;
memAvailable = [];


try
    handles.uicontrols.pushbutton.pushbutton_cancel.String = 'Continue';
    handles.uicontrols.pushbutton.pushbutton_cancel.Callback = @(hObject,eventdata)BiofilmQ('pushbutton_cancel_Callback',hObject,eventdata,guidata(hObject), 1);
    drawnow;
end

cancel = 0;
while waitForMoreMem
    
    memAvailable(count) = systemview.PhysicalMemory.Available;
    
    if memAvailable(end)/1e9 < memSize
        if flag1
            if displayOutput
            fprintf('\n -> waiting for %dGB of memory to be available', memSize);
            end
            flag1 = 0;
            flag2 = 1;
        end
        
        startTime = tic;
        delay = rand*60;
        while toc < startTime + delay
            if checkCancelButton(handles, 'continue')
                cancel = 1;
                break;
            end
            pause(1);
        end
    end
    
    if count > 5
       if mean(diff(memAvailable(count-5:count))) <= 1000000 
           waitForMoreMem = 0;
       else
           if flag2
               if displayOutput
               fprintf('\n -> memory consumption is increasing, checking');
               end
               flag2 = 0;
               flag1 = 1;
           end
       end
    end
    
    pause(0.01);
    count = count + 1;    
    [~, systemview] = memory;
    
    if checkCancelButton(handles, 'continue') || cancel
        flag1 = 1;
        flag2 = 0;
        break;
    end
end

if ~flag1
    t = rand*60;
    pause(t)
    if displayOutput
    fprintf('... starting in %d s', round(t));
    end
elseif ~flag2
    if displayOutput
    fprintf('... continuing now');
    end
end

try
    handles.uicontrols.pushbutton.pushbutton_cancel.String = 'Cancel';
    handles.uicontrols.pushbutton.pushbutton_cancel.Callback = @(hObject,eventdata)BiofilmQ('pushbutton_cancel_Callback',hObject,eventdata,guidata(hObject));
    drawnow;
end


