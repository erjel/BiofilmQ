function dataExport_seg_export_Callback(hObject, eventdata, handles)
    %% Export start boilerplate
    ticValueAll = displayTime;
    toggleBusyPointer(handles, true)
    fprintf('=========== Exporting to TIF ===========\n');

    %%
    seg_data_files = handles.settings.lists.files_cells;
   
    name_matches_placeholder = regexp( ...
        {seg_data_files.name}, ...
        '^missing_ch\d+$', 'once');
    
    is_segmented_frame = cellfun(@isempty, name_matches_placeholder);
    
    segmented_frames = find(is_segmented_frame);
    selected_frames_str = handles.uicontrols.edit.action_imageRange.String;
    selected_frames = str2num(selected_frames_str);
    
    valid_frames = intersect(segmented_frames, selected_frames);
    
    output_folder = fullfile(handles.settings.directory, 'data', 'seg_output');
    
    
    if ~isfolder(output_folder)
        mkdir(output_folder)
    end
    fprintf('Output folder: %s\n', output_folder);
    
    n_frames = numel(valid_frames);
    for i = 1:n_frames
        frame = valid_frames(i);
        
        %% File operation boilerplate
        handles.java.files_jtable.changeSelection(frame-1, 0, false, false);
            
        ticValueImage = displayTime;
        fprintf('Image %d of %d (Frame %d): ', ...
            i, n_frames, frame);
    
        updateWaitbar(handles, i/(1+n_frames));
        
        %% 
        filename = seg_data_files(frame).name;
        filepath = fullfile(seg_data_files(frame).folder, filename);
        objects = load(filepath);
        
        w = labelmatrix(objects);
        
        %% More file operation boilerplate
        displayStatus(handles, 'saving TIF-file...', 'blue', 'add');
        updateWaitbar(handles, (i+0.6)/(1+n_frames));
        
        %%
        output_name = strrep(filename, '_data.mat', '.tif');
        imwrite3D(w, fullfile(output_folder, output_name), [], true);
        
        %% End file operation boilerplate
        displayStatus(handles, 'Done', 'blue', 'add');
        fprintf('-> total elapsed time per image')
        displayTime(ticValueImage);

        if checkCancelButton(handles)
            return;
        end
    end
    
    %% Export start boilerplate
    updateWaitbar(handles, 0);
    fprintf('-> total elapsed time')
    displayTime(ticValueAll);
    
    toggleBusyPointer(handles, false)
end

