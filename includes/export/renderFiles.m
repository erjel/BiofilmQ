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
function renderFiles(hObject, eventdata, handles)
disp(['=========== Rendering files in paraview ===========']);
ticValueAll = displayTime;

range = str2num(get(handles.uicontrols.edit.action_imageRange, 'String'));

params = load(fullfile(handles.settings.directory, 'parameters.mat'));
params = params.params;

if params.reducePolygons
    resolution = params.reducePolygonsTo;
else
    resolution = 1;
end

files = handles.settings.lists.files_cells;
range_new = intersect(range, 1:numel(files));
if numel(range) ~= numel(range_new)
    fprintf('NOTE: Image range was adapted to [%d, %d]\n', min(range_new), max(range_new));
end
range = range_new;
      
pathParaview = handles.uicontrols.edit.renderParaview_path.String;
renderParameter = handles.uicontrols.popupmenu.renderParaview_parameter.String{handles.uicontrols.popupmenu.renderParaview_parameter.Value};
removeZOffset = handles.uicontrols.checkbox.renderParaview_removeZOffset.String;
makeRendering(objects, fullfile(handles.settings.directory, 'data', filenameVTK), pathParaview, renderParameter, removeZOffset);

if params.sendEmail
    email_to = get(handles.uicontrols.edit.email_to, 'String');
    email_from = get(handles.uicontrols.edit.email_from, 'String');
    email_smtp = get(handles.uicontrols.edit.email_smtp, 'String');
    
    setpref('Internet','E_mail',email_from);
    setpref('Internet','SMTP_Server',email_smtp);
    
    sendmail(email_to,['[Biofilm Toolbox] Cell visualization finished: "', handles.settings.directory, '"']', ...
        ['Cell visualization of "', handles.settings.directory, '" finished (Range: ', num2str(range(1)), ':', num2str(range(end)), ').', ]);
end

updateWaitbar(handles, 0);
fprintf('-> total elapsed time')
displayTime(ticValueAll);



