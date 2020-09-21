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
function exportData(hObject, eventdata, handles, type)
ticValueAll = displayTime;

range = str2num(get(handles.uicontrols.edit.action_imageRange, 'String'));

params = load(fullfile(handles.settings.directory, 'parameters.mat'));
params = params.params;

custom_fields_objects = params.cellParametersStoreVTK(:,1);
selected = [params.cellParametersStoreVTK{:,2}];
custom_fields_objects = custom_fields_objects(selected);

if isempty(custom_fields_objects)
    uiwait(msgbox('Please select a parameter for export!', 'Please note', 'help', 'modal'));
    return;
end



sprintf('=========== Exporting to %s ===========', upper(type));


files = handles.settings.lists.files_cells;

fileRange = find(cellfun(@isempty, strfind({files.name}, 'missing')));

range_new = intersect(range, fileRange);

range_new = assembleImageRange(range_new);

if numel(range) ~= numel(str2num(range_new))
    warning('off','backtrace')
    warning('Image range was adapted to [%s]', range_new);
    warning('on','backtrace')
end
range = str2num(range_new);


for f = range
    
    try
        handles.java.files_jtable.changeSelection(f-1, 0, false, false);
    end
    
    ticValueImage = displayTime;
    disp(['=========== Processing image ', num2str(f), ' of ', num2str(length(files)), ' ===========']);
    
    updateWaitbar(handles, (f-range(1))/(1+range(end)-range(1)));
    
    
    displayStatus(handles,['Exporting data for file', num2str(f), ' of ', num2str(length(files)), '...'], 'blue');
    
    filename = fullfile(handles.settings.directory, 'data', files(f).name);
    objects = loadObjects(filename, {'stats', 'globalMeasurements', 'metadata'});
    
    
    displayStatus(handles, ['saving ',lower(type),'-file...'], 'blue', 'add');
    updateWaitbar(handles, (f+0.6-range(1))/(1+range(end)-range(1)));
    
    index = strfind(files(f).name(1:end-4), 'Nz');

    fprintf(' - saving %s-file', lower(type));
    
    if params.forceVTKSeries
        filename = ['frame_',num2str(f, '%06d'), '.', lower(type)];
    else
        filename = [files(f).name(1:index-2), '.', lower(type)];
    end
    
    switch lower(type)
        case 'fcs'
            handles = exportFCS(handles, objects, params, custom_fields_objects, filename);
        case 'csv'
            objects = writeCSV(handles, objects, custom_fields_objects, params, filename);
    end
    
    displayStatus(handles, 'Done', 'blue', 'add');
    
    fprintf('-> total elapsed time per image')
    displayTime(ticValueImage);
    
    if checkCancelButton(handles)
        return;
    end
end

if isfield(handles.settings, 'showedFCSError')
    handles.settings.showedFCSError = false;
end

if params.sendEmail
    email_to = get(handles.uicontrols.edit.email_to, 'String');
    email_from = get(handles.uicontrols.edit.email_from, 'String');
    email_smtp = get(handles.uicontrols.edit.email_smtp, 'String');
    
    setpref('Internet','E_mail',email_from);
    setpref('Internet','SMTP_Server',email_smtp);
    
    sendmail(email_to,[sprintf('[Biofilm Toolbox] %s export finished: "', upper(type)), handles.settings.directory, '"']', ...
        [sprintf('%s export finished of "', upper(type)), handles.settings.directory, '" finished (Range: ', num2str(range(1)), ':', num2str(range(end)), ').', ]);
end

updateWaitbar(handles, 0);
fprintf('-> total elapsed time')
displayTime(ticValueAll);



