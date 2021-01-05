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
function [img_processed, background, img_raw, tryParentLink, params, metadata] ...
    = getImageFromRaw(handles, objects, params, filename, ch_available)

    img_raw = cell(max(ch_available), 1);
    img_processed = cell(max(ch_available), 1);
    background = zeros(max(ch_available), 1);
    
    
    if isfield(objects, 'ImageContentFrame')
        imSize = [objects.ImageContentFrame(2)-objects.ImageContentFrame(1)+1,...
            objects.ImageContentFrame(4)-objects.ImageContentFrame(3)+1,...
            objects.ImageSize(3)];
    else
        imSize = objects.ImageSize;
    end
    
    if numel(imSize) == 2
        imSize(3) = 1;
    end
    
    
    
    tryParentLink = 0;
    for ch = ch_available
        fprintf(' - preparing image ch %d\n', ch);
        
        
        if ch ~= params.channel
            filename_currentCh = strrep(filename, sprintf('_ch%d', params.channel), sprintf('_ch%d', ch));
        else
            filename_currentCh = filename; 
        end
        
        
        try
            params = objects.params;
        end
        metadata = load(fullfile(handles.settings.directory, [filename_currentCh(1:end-4), '_metadata.mat']));
        
        
        if ~isfield(params, 'cropRangeAfterRegistration')
            params.cropRangeAfterRegistration = [];
        end
        
        if ~isfield(metadata.data, 'scaling')
            disp(' - WARNING: Scaling not stored in metadata!');
            metadata.data.scaling.dxy = params.scaling_dxy;
            metadata.data.scaling.dz = params.scaling_dz;
        else
            metadata.data.scaling.dxy = metadata.data.scaling.dxy*1000;
            metadata.data.scaling.dz = metadata.data.scaling.dz*1000;
        end
        
        
        displayStatus(handles,['Loading image ',filename_currentCh,'...'], 'blue');
        fprintf(' - loading image [%s]', filename_currentCh);
        img_raw{ch} = imread3D(fullfile(handles.settings.directory, filename_currentCh), params);
        
        
        if ch ~= params.channel 
            
            filename_2ndCh_prev = filename_currentCh;            
            
            while size(img_raw{ch}, 1) == 1 && isfield(metadata.data, 'frameSkipped')
                
                frameInd = strfind(filename_2ndCh_prev, '_frame');
                currentFrame = str2num(filename_2ndCh_prev(frameInd+6:frameInd+11))-1;
                fprintf('    - image in %d not aquired, loading previous frame (#%d) instead', ch, currentFrame)
                
                filename_2ndCh_prev = strrep(filename_currentCh, filename_currentCh(frameInd+6:frameInd+11), num2str(currentFrame, '%06d'));
                
                filePrev = dir(fullfile(handles.settings.directory, [filename_2ndCh_prev(1:frameInd+11), '*.tif']));
                img_raw{ch} = imread3D(fullfile(handles.settings.directory, filePrev(1).name), params);
                
                tryParentLink = 1;
            end
        end
        
        
        img_raw{ch} = img_raw{ch}(:,:,2:end);
        
        background(ch) = double(prctile(img_raw{ch}(:), 30));
        fprintf('     background: %d\n', background(ch)); 
        
        
        if size(img_raw{ch}, 3) == 1 && params.segmentationMethod == 2
            img_raw{ch}(:, :, 2:5) = repmat(img_raw{ch}(:,:,1), 1, 1, 4);
        end
        
        
        if params.imageRegistration
            try
                if numel(size(img_raw{ch}))==2
                    img_raw{ch} = performImageAlignment2D(img_raw{ch}, metadata);
                else
                    img_raw{ch} = performImageAlignment3D(img_raw{ch}, metadata);
                end
            catch
                uiwait(msgbox('Image is not registered! Cannot continue.', 'Error', 'error'));
                displayStatus(handles, 'Processing cancelled!', 'red');
                updateWaitbar(handles, 0);
                set(handles.uicontrols.pushbutton.pushbutton_cancel, 'UserData', 0);
                return;
            end
        end
        
        
        if isfield(params, 'invertStack')
            if params.invertStack && imSize(3) > 1
                img_raw{ch} = img_raw{ch}(:,:,size(img_raw{ch},3):-1:1);
            end
        end
        
        
        if ~params.imageRegistration
            if ~isempty(params.cropRange)
                img_raw{ch} = img_raw{ch}(params.cropRange(2):params.cropRange(2)+params.cropRange(4), ...
                    params.cropRange(1):params.cropRange(1)+params.cropRange(3),:);
            end
        else
            if ~isempty(params.cropRangeAfterRegistration)
                
                img_raw{ch} = img_raw{ch}(...
                    params.cropRangeAfterRegistration(2) ...
                    : params.cropRangeAfterRegistration(2)+params.cropRangeAfterRegistration(4), ...
                    params.cropRangeAfterRegistration(1) ...
                    : params.cropRangeAfterRegistration(1)+params.cropRangeAfterRegistration(3),...
                    :);
            end
        end
        
        
        displayStatus(handles, 'processing...', 'blue', 'add');
        
        
        if imSize(3) > 1
            
            dxy = metadata.data.scaling.dxy;  
            dz = metadata.data.scaling.dz; 
            img_processed{ch} = zInterpolation(img_raw{ch}, dxy, dz, params, 1);

            
            if params.rotateImage
                img_processed{ch}  = rotateBiofilmImg(img_processed{ch}, params);
            end

            
            if params.removeBottomSlices && params.removeBottomSlices < size(img_processed{ch}, 3)
                img_processed{ch}(:,:,1:params.removeBottomSlices) = [];
            end
        else
            img_processed{ch} = img_raw{ch};
        end
        
        
        if size(img_processed{ch}, 3) < imSize(3)
            img_processed{ch} = padarray(img_processed{ch}, [0 0 imSize(3)-size(img_processed{ch}, 3)], 'replicate', 'post');
            fprintf('       - enlarging image\n');
        end
        if size(img_processed{ch}, 3) > imSize(3)
            img_processed{ch} = img_processed{ch}(:,:, 1:imSize(3));
            fprintf('       - shrinking image\n');
        end
              
        
        if params.fixedOutputSize && params.imageRegistration
            img_processed{ch} = applyReferencePadding(params, img_processed{ch});
        end
    end


