function p = uipanel_workflow_dataExport_seg(handles)

    test = true;
    
    padding = 8;
    spacing = 8;
    objectHeight = 22;
    
    p = uipanel('Title', 'Export Segmentation (tif)');
    
    if test
        f = figure(1);
        p.Parent = f;
    end
   
    %% Elements
    handles.uicontrols.pushbutton.dataExport_seg_export = ...
        uicontrol( ...
        'Tag', 'dataExport_seg_export_pushbutton', ...
        'Style', 'pushbutton', ...
        'String', 'Export' ...
        );

    %% Layout        
    v1 = uix.VBox('Parent', p, 'Padding', 0, 'Spacing', spacing);
        v1_h1 = uix.HBox('Parent', v1, 'Padding', 0, 'Spacing', spacing);
            uix.VBox('Parent', v1_h1, 'Tag', 'EmptyPlaceholder');
            handles.uicontrols.pushbutton.dataExport_seg_export.Parent = v1_h1;

        v1_h1.Widths = [-1, 150];
    v1.Heights =  0.85*objectHeight*ones(numel(v1.Children));

    %% Callbacks
    handles.uicontrols.pushbutton.dataExport_seg_export.Callback = ...
        @(hObject, eventdata) dataExport_seg_export_Callback(hObject, eventdata, guidata(handles.mainFig)); 
end