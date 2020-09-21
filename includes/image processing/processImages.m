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
function processImages(hObject, eventdata, handles)
disp(['=========== Image processing ===========']);
ticValueAll = displayTime;
params = load(fullfile(handles.settings.directory, 'parameters.mat'));
params = params.params;

range = str2num(params.action_imageRange);

files = handles.settings.lists.files_tif;

range_new = intersect(range, 1:numel(files));
if numel(range) ~= numel(range_new)
    fprintf('NOTE: Image range was adapted to [%d, %d]\n', min(range_new), max(range_new));
end
range = range_new;

if ~exist(fullfile(handles.settings.directory, 'data'), 'dir')
    mkdir(fullfile(handles.settings.directory, 'data'));
end

if params.imageRegistration && params.fixedOutputSize && isempty(params.registrationReferenceCropping)
    uiwait(msgbox('Please setup a reference frame crop range to proceed.', 'Please note', 'help', 'modal'));
    return;
end

enableCancelButton(handles);
prevData = [];

if params.speedUpSSD
    if ~exist(params.tempFolder, 'dir')
        uiwait(msgbox('Temp-directory is not a valid directory!', 'Error', 'error', 'modal'));
        error('Please specify a valid temp-directory!');
    end
    
    
    temp_directory = params.tempFolder;
    inputFolderStructure = strsplit(handles.settings.directory, filesep);
    temp_directory_fullPath = fullfile(temp_directory, inputFolderStructure{end-1}, inputFolderStructure{end});
    
    if ~exist(temp_directory_fullPath, 'dir')
        mkdir(fullfile(temp_directory_fullPath, 'img'));
        mkdir(fullfile(temp_directory_fullPath, 'raw'));
    end
    
    
    
    displayStatus(handles,['Copying images into temp-folder ...'], 'blue');
    fprintf('-> copying images into temp-folder [in "%s"]\n', temp_directory_fullPath);
    
    
    count = 1;
    for i = 1:range(end)
        if ~exist(fullfile(temp_directory_fullPath, 'raw', files(i).name))
            
            F_raw(count) = parfeval(@copyfile,1,fullfile(handles.settings.directory, files(i).name), fullfile(temp_directory_fullPath, 'raw', files(i).name));
            count = count + 1;
        end
    end
    
    params.temp_directory_fullPath = temp_directory_fullPath;
    params.inputDirectory = fullfile(temp_directory_fullPath, 'raw');
    imagePreProcessingDone = 0;
    
    if exist('F_raw')
        wait(F_raw);
    end
end



for f_ind = 1:numel(range)
    try
        
        f = range(f_ind);
        
        
        try
            handles.java.files_jtable.changeSelection(f-1, 0, false, false);
        end
        
        ticValueImage = displayTime;
        disp(['=========== Processing image ', num2str(f), ' of ', num2str(length(files)), ' ===========']);
        
        updateWaitbar(handles, (f-range(1))/(1+range(end)-range(1))+0.01);
        
        
        
        if params.speedUpSSD
            if ~imagePreProcessingDone
                ticValue = displayTime;
                fprintf(' - Preparing images on SSD [in "%s"]', temp_directory_fullPath);
                h = ProgressBar(numel(range));
                parfor i = 1:numel(range)
                    f_par = range(i);
                    
                    if ~exist(fullfile(temp_directory_fullPath, 'img', ['img_', num2str(f_par), '.mat']), 'file')
                        
                        imagePreProcessing(hObject, [], handles, f_par, params, range, 1);
                    end
                    h.progress;
                end
                h.stop;
                imgFiles = dir(fullfile(temp_directory_fullPath, 'img', 'img*.mat'));
                fprintf('      [generated data: %.1f Gb]', sum([imgFiles.bytes])/1e9)
                ticValue = displayTime(ticValue);
                imagePreProcessingDone = 1;
            end
            
            
            
            ticValue = displayTime;
            displayStatus(handles,['Loading image ', num2str(f), ' of ', num2str(length(files)), '...'], 'blue');
            fprintf(' - loading image "%s"', files(f).name);
            img = load(fullfile(temp_directory_fullPath, 'img', ['img_', num2str(f), '.mat']));
            imgfilter = img.img;
            
            img.params.I_base_perStack = params.I_base_perStack;
            params = img.params;
            
            displayTime(ticValue);
        else
            params.inputDirectory = handles.settings.directory;
            
            
            [imgfilter, status, params, thresh] = imagePreProcessing(hObject, eventdata, handles, f, params, range);
            if ~status
                break;
            end
        end
        
        
        
        
        
        
        metadata_filename = fullfile(handles.settings.directory, [files(f).name(1:end-4), '_metadata.mat']);
        metadata = load(metadata_filename);
        
        if params.scaleUp
            metadata.data.scaling.dxy = metadata.data.scaling.dxy/params.scaleFactor;
            metadata.data.scaling.dz = metadata.data.scaling.dxy; 
        end
        
        params.scaling_dxy = metadata.data.scaling.dxy * 1000;
        params.scaling_dz = metadata.data.scaling.dz * 1000;   
    
        try
            params.I_base = metadata.data.I_base;
        end
        
        if params.exportVTKafterEachProcessingStep
            saveIntermediateSteps = 1;
            fprintf(' - saving intermediated processing results\n');
            imwrite3D(imgfilter, fullfile(handles.settings.directory, 'data', [files(f).name(1:end-4), '_filtered.tif']));
        else
            saveIntermediateSteps = 0;
        end
        
        
        updateWaitbar(handles, (f+0.4-range(1))/(1+range(end)-range(1)));
        switch params.segmentationMethod
        
            case 1
            
            [status, imgfilter_edge_filled] = ...
                simpleThresholding(imgfilter, params, thresh);
        
            otherwise
                error('Segmentation Method not implemented yet')
        end
        
        
        if ~exist('regMax', 'var')
            regMax = false(size(imgfilter));
        end

        if ~status
            break;
        end
        
        
        
        
        if params.exportVTKafterEachProcessingStep
            fprintf(' - saving intermediated processing results\n');
            imwrite3D(imgfilter_edge_filled, fullfile(handles.settings.directory, 'data', [files(f).name(1:end-4), '_binary.tif']));
        end
        
        
        displayStatus(handles, 'segmentation...', 'blue', 'add');
        updateWaitbar(handles, (f+0.6-range(1))/(1+range(end)-range(1)));
        filebase = fullfile(handles.settings.directory, 'data', files(f).name(1:end-4));
        
        
        [prevData.objects, status] = objectDeclumping(handles, imgfilter, imgfilter_edge_filled, regMax, params, filebase, prevData, f, metadata);
        
        if params.exportVTKafterEachProcessingStep
            fprintf(' - saving intermediated processing results\n');
            imwrite3D(labelmatrix(prevData.objects), fullfile(handles.settings.directory, 'data', [files(f).name(1:end-4), '_segmented.tif']));
        end
        
        if ~status
            break;
        end
        
        displayStatus(handles, 'Done', 'blue', 'add');
        
        fprintf('-> total elapsed time per image')
        displayTime(ticValueImage);
        
        
        if params.stopProcessingNCellsMax
            if prevData.objects.NumObjects > params.NCellsMax
                fprintf('-> max number of cells reached (Nmax = %d)-> stopping segmentation.\n', params.NCellsMax);
                break;
            end
        end
    catch err
        warning('backtrace', 'off')
        fprintf('\n');
        warning(err.message);
        warning('backtrace', 'on')
    end
end


updateWaitbar(handles, 0);
fprintf('-> total elapsed time')
displayTime(ticValueAll);


