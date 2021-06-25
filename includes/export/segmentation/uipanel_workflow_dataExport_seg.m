% Copyright (c) 2021 Eric Jelli (GitHub: @erjel)
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

function p = uipanel_workflow_dataExport_seg(handles)

    test = false;
    
    padding = 8;
    spacing = 8;
    objectHeight = 22;
    
    p = uipanel('Title', 'Segmentation (TIF-files)');
    
    if test
        f = figure(1);
        p.Parent = f;
    else
        p.Parent = handles.mainFig;
    end
   
    %% Elements
    handles.uicontrols.pushbutton.pushbutton_dataExport_seg_export = ...
        uicontrol( ...
        'Tag', 'dataExport_seg_export_pushbutton', ...
        'Style', 'pushbutton', ...
        'String', 'Export', ...
        'FontSize', 10 ...
    );
    
    handles.uicontrols.text.text_workflow_dataExport_seg_descr = ...
        uicontrol( ...
        'Tag', 'dataExport_seg_descr', ...
        'Style', 'text', ...
        'String', 'Object segmentations can be exported into the TIF-format', ...
        'FontAngle', 'italic', ...
        'HorizontalAlignment', 'left' ...
    );

    %% Layout
    h = uix.HBox('Parent', p);
    handles.uicontrols.text.text_workflow_dataExport_seg_descr.Parent = h;
    h_button = uix.HButtonBox('Parent', h, 'Spacing', spacing, 'HorizontalAlignment', 'right', 'VerticalAlignment', 'top', 'ButtonSize', [150 objectHeight]);
    handles.uicontrols.pushbutton.pushbutton_dataExport_seg_export.Parent = h_button;
    


    %% Callbacks
    handles.uicontrols.pushbutton.pushbutton_dataExport_seg_export.Callback = ...
        @(hObject, eventdata) dataExport_seg_export_Callback(hObject, eventdata, guidata(handles.mainFig)); 
end