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

cd(fileparts(which('BiofilmQ')));

range = 1:numel(folders);

handles = handles.handles_GUI;
hObject = handles.mainFig;
evendata = [];

for i = range
    if isfolder(folders{i})
        
        set(handles.uicontrols.edit.inputFolder, 'String', folders{i});
        
        
        BiofilmQ('pushbutton_refreshFolder_Callback', handles.uicontrols.pushbutton.pushbutton_refreshFolder, eventdata, guidata(hObject))
        
        
        biofilmAnalysis('pushbutton_load_Callback', handles.handles_analysis.uicontrols.pushbutton.pushbutton_load, eventdata, guidata(hObject));
        
        
        handles = guidata(hObject); 
        
        
        set(handles.handles_analysis.uicontrols.edit.edit_binsX, 'String', '4');
        set(handles.handles_analysis.uicontrols.edit.edit_binsY, 'String', '40');
        
        
        set(handles.handles_analysis.uicontrols.popupmenu.popupmenu_database, 'Value', 1);
        
        set(handles.handles_analysis.uicontrols.popupmenu.popupmenu_plotType, 'Value', 1);
        
        set(handles.handles_analysis.uicontrols.popupmenu.popupmenu_averaging, 'Value', 1);
      
        
        
        biofilmAnalysis('pushbutton_addField_Callback', handles.handles_analysis.uicontrols.pushbutton.pushbutton_addField_xaxis, eventdata, handles, 1, 'Frame')
        biofilmAnalysis('pushbutton_addField_Callback', handles.handles_analysis.uicontrols.pushbutton.pushbutton_addField_yaxis, eventdata, handles, 2, 'Distance_FromSubstrate')
        biofilmAnalysis('pushbutton_addField_Callback', handles.handles_analysis.uicontrols.pushbutton.pushbutton_addField_coloraxis, eventdata, handles, 4, 'Skeleton_NodesPerBranch')
        
        biofilmAnalysis('pushbutton_kymograph_plot_Callback',handles.handles_analysis.uicontrols.pushbutton.pushbutton_kymograph_plot,eventdata,guidata(hObject))
        delete(gcf)
    end
end




