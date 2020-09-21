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
function updateWaitbar(handles, value)
try
    if ~value
        disableCancelButton(handles)
    end
    
    delete(get(handles.axes.axes_status, 'Children'));
    h = area(handles.axes.axes_status, [0 value], [1 1]);
    h.FaceColor = [0.929,  0.694,  0.125];
    set(handles.axes.axes_status, 'XLim', [0 1], 'YLim', [0 1], 'XTick', [], 'YTick', []);
    drawnow;
end


