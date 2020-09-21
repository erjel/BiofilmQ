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
function handles = loadAnalysisPanel(handles)

loadedContent = biofilmAnalysis('Visible', 'off');

handles_analysis = guidata(loadedContent);

handles_analysis.layout.tabs.analysisTabs = uitabgroup('Parent', handles_analysis.layout.uipanels.uipanel_biofilmAnalysis,  'TabLocation', 'top', 'units', 'characters', 'Position', get(handles_analysis.layout.uipanels.uipanel_analysisContent, 'Position'));
delete(handles_analysis.layout.uipanels.uipanel_analysisContent)

handles_analysis = populateTabs(handles_analysis, 'uipanel_plotting','analysisTabs');
handles.handles_analysis = handles_analysis;


handles.layout.uipanels.uipanel_analysis_analysisTabs.Units = 'normalized';
handles = restylePanel(handles, handles_analysis.layout.uipanels.uipanel_biofilmAnalysis, [0.7490 0.902 1], handles.layout.tabs.visualization, handles.layout.uipanels.uipanel_analysis_analysisTabs.Position);
delete(handles.layout.uipanels.uipanel_analysis_analysisTabs);

handles.handles_analysis = handles_analysis;

handles = replaceUIPanel(handles, 'uipanel_biofilmAnalysis');
handles = replaceUIPanel(handles, 'uipanel_plotting');
handles = loadAdditionalModules_Visualization(handles);



delete(loadedContent);


