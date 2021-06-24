function dataExport_seg_export_Callback(hObject, eventdata, handles)

    seg_data_files = handles.settings.lists.files_cells;
   
    name_matches_placeholder = regexp( ...
        {seg_data_files.name}, ...
        '^missing_ch\d+$', 'once');
    
    is_segmented_frame = cellfun(@isempty, name_matches_placeholder);
    
    segmented_frames = find(is_segmented_frame);
    selected_frames = str2num(handles.uicontrols.edit.action_imageRange.String);
    
    valid_frames = intersect(segmented_frames, selected_frames);
    
    output_folder = fullfile(handles.settings.directory, 'data', 'seg_output');
    
    if ~isfolder(output_folder)
        mkdir(output_folder)
    end

    for frame = valid_frames
        filename = seg_data_files(frame).name;
        filepath = fullfile(seg_data_files(frame).folder, filename);
        objects = load(filepath);
        w = labelmatrix(objects);
        
        output_name = strrep(filename, '_data.mat', '.tif');
        imwrite3D(w, fullfile(output_folder, output_name));
    end

end

