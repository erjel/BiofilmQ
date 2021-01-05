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
function registerImages(hObject, eventdata, handles)

disp(['=========== Image registration ===========']);
params = load(fullfile(handles.settings.directory, 'parameters.mat'));
params = params.params;

referenceFrame = params.registrationReferenceFrame;

range = str2num(get(handles.uicontrols.edit.action_imageRange, 'String'));
colors = colormap(parula(numel(range)));

range(find(range==referenceFrame)) = [];

rangInd = find(range<referenceFrame);

if numel(range) == 1
    range = [referenceFrame, range];
else
    if min(range) < referenceFrame
        range = [referenceFrame, range(rangInd(end)+1:end), referenceFrame, range(sort(rangInd, 'Descend'))];
    else
        range = [referenceFrame, range];
    end
end

scale = 1;

files = handles.settings.lists.files_tif;

if referenceFrame < 1 || referenceFrame > numel(files)
    uiwait(msgbox(sprintf('Reference frame with index #%d is not existing!', referenceFrame), 'Cancelling...', 'error'));
    return;
end

[~, inputFolder] = fileparts(get(handles.uicontrols.edit.inputFolder, 'String'));
h = figure('Name', sprintf('Registration: %s', inputFolder));
h_ax = axes('Parent', h);

plot3(h_ax, 0,0,0, 'o');
set(h_ax, 'NextPlot', 'add');
xlabel('x (px)'); ylabel('y (px)'); zlabel('z (px)');
title(sprintf('Translation of %s', inputFolder),  'Interpreter', 'none');






[optimizer, metric] = imregconfig('monomodal');

translations = [];

slicesRead = 40;

enableCancelButton(handles);

for j = 1:numel(range)
    f = range(j);
    handles.java.files_jtable.changeSelection(f-1, 0, false, false);
    
    disp(['=========== Processing image ', num2str(f), ' of ', num2str(length(files)), ' ===========']);
    
    updateWaitbar(handles, (j+0.1-1)/(numel(range)));
    
    
    metadata = load(fullfile(handles.settings.directory, [files(f).name(1:end-4), '_metadata.mat']));
    
    
    displayStatus(handles,['Loading image ', num2str(f), ' of ', num2str(length(files)), '...'], 'blue');
    
    if f ~= referenceFrame
        img_fixed = img_moving;
        img_fixed_zx = img_zx;
        img_fixed_zy = img_zy;
    end
    
    
    
    
    
    
    img_moving_stack = [];
    for i = 2:slicesRead
        try
            img_moving_stack(:,:,i-1) = imread(fullfile(handles.settings.directory, files(f).name), i);
            
        catch
            break;
        end
    end
    
    
    img_moving = imread(fullfile(handles.settings.directory, files(f).name), 1);
    
       
    
    if f == referenceFrame
        
        
        
        
        img_zx = squeeze(sum(img_moving_stack,2));
        img_zy = squeeze(sum(img_moving_stack,1));
        
        
    end
    
    
    
    
    
    
    
    
    
    
    
    if f ~= referenceFrame
        
        displayStatus(handles,['registering...'], 'blue', 'add');
        fprintf(' - registering images, along xy');
        ticValue = displayTime;
        imshowpair(img_fixed,img_moving, 'Parent',handles.axes.axes_preview);
        text(1,1, ' registration: along xy', 'Parent', handles.axes.axes_preview, 'VerticalAlignment', 'top', 'Color', 'r');
        drawnow;
        
        switch params.registrationMethod
            case 1
                fprintf(' [method: full correlation]');
                
                usfac = 10;
                output = dftregistration(fft2(single(img_fixed)),fft2(single(img_moving)),usfac);
                
                tform_xy = affine2d;
                tform_xy.T(3,1:2) = [output(4), output(3)];
                
            case 2
                fprintf(' [method: MeanSquares]');
                tform_xy = imregtform(img_moving, img_fixed, 'translation', optimizer, metric);
        end
        
        
        
        tform = affine3d;
        tform.T(4,1:2) = tform_xy.T(3,1:2) + translations(range(j-1),1:2);
        tform.T(4,3) = 0;
        metadata.data.registration = tform;
        ticValue = displayTime(ticValue);
        
        updateWaitbar(handles, (j+0.4-1)/(numel(range)));
        
        if params.alignZ
            
            ticValue = displayTime;
            
            img_moving_stack_aligned = performImageAlignment2D(img_moving_stack, metadata, 'linear', 0);
           
            
            sZ = size(img_moving_stack_aligned,3);

            img_zx = squeeze(sum(img_moving_stack_aligned,2));
            img_zy = squeeze(sum(img_moving_stack_aligned,1));
            
            
            minZ = min([size(img_zx, 2) size(img_fixed_zx, 2)]);
            
            
            img_zx_corr = img_zx(:,1:minZ);
            img_fixed_zx_corr = img_fixed_zx(:,1:minZ);
            
            img_zy_corr = img_zy(:,1:minZ);
            img_fixed_zy_corr = img_fixed_zy(:,1:minZ);
            
            fprintf('                       along zx');
            try
                imshowpair(img_fixed_zx,img_zx, 'Parent',handles.axes.axes_preview);
                axis(handles.axes.axes_preview, 'square')
                text(1,1, ' registration: along zx', 'Parent', handles.axes.axes_preview, 'VerticalAlignment', 'top', 'Color', 'r');
                drawnow;

                usfac = 100;
                output = dftregistration(fft2(single(img_fixed_zx_corr)),fft2(single(img_zx_corr)),usfac);
                
                tform_zx = affine2d;
                tform_zx.T(3,1:2) = [output(4), 0];
                
                
                
                
                
                
                if tform_zx.T(3,1) > 4
                    fprintf(' (cannot be determined)');
                    tform_zx.T(3,1) = 4;
                end
                if tform_zx.T(3,1) < -4
                    fprintf(' (cannot be determined)');
                    tform_zx.T(3,1) = -4;
                end
                
                
            catch
                tform_zx = affine2d;
            end
            
            
            updateWaitbar(handles, (j+0.6-1)/(numel(range)));
            
            fprintf(', along zy');
            try
                imshowpair(img_fixed_zy,img_zy, 'Parent',handles.axes.axes_preview);
                axis(handles.axes.axes_preview, 'square')
                text(1,1, ' registration: along zy', 'Parent', handles.axes.axes_preview, 'VerticalAlignment', 'top', 'Color', 'r');
                drawnow;

                usfac = 100;
                output = dftregistration(fft2(single(img_fixed_zy_corr)),fft2(single(img_zy_corr)),usfac);
                
                tform_zy = affine2d;
                tform_zy.T(3,1:2) = [output(4), 0];
                
                if tform_zy.T(3,1) > 4 
                    fprintf(' (cannot be determined)');
                    tform_zy.T(3,1) = 4;
                end
                if tform_zy.T(3,1) < -4
                    fprintf(' (cannot be determined)');
                    tform_zy.T(3,1) = -4;
                end
                
            catch
                tform_zy = affine2d;
            end
            ticValue = displayTime(ticValue);
            
        else
            tform_zx = affine2d;
            tform_zy = affine2d;
        end
        
        tform = affine3d;
        tform.T(4,1:2) = tform_xy.T(3,1:2) + translations(range(j-1),1:2);
        tform.T(4,3) = mean([tform_zx.T(3,1), tform_zy.T(3,1)]) + translations(range(j-1),3);
        
        fprintf('    - translation: [x=%0.2f, y=%0.2f, z=%0.2f (%0.2f/%0.2f)]', tform.T(4,1), tform.T(4,2),...
            tform.T(4,3), tform_zx.T(3,1), tform_zy.T(3,1));
        
        if abs(tform.T(4,3)) > 3
            fprintf('    -> strong shift in z-direction!');
        end
        
        if tform.T(4,3) < -4
            tform.T(4,3) = -4;
            fprintf(' Limit negative shift to %0.2f', tform.T(4,3));
        end
        
        
        
        tform.T(4,3) = tform.T(4,3)*0.8;
        fprintf('    -> adjusted z-value to %0.2f', tform.T(4,3));
        
        
        
        metadata.data.registration = tform;
        translations(f,:) = tform.T(4,:);
        
    else
        fprintf(' - reference image [position fixed]');
        
        if params.continueRegistration
            if isfield(metadata.data, 'registration')
                fprintf(' -> continuing registration\n');
                fprintf('    - translation: [x=%0.2f, y=%0.2f, z=%0.2f]', metadata.data.registration.T(4,1), metadata.data.registration.T(4,2),...
            metadata.data.registration.T(4,3));
                translations(f,:) = metadata.data.registration.T(4,:);
            end
        else
            metadata.data.registration = affine3d;
            translations(f,:) = [0 0 0 1];
        end
    end
    
    if j > 1
        if ~isvalid(h_ax)
            h = figure('Name', sprintf('Registration: %s', inputFolder));
            h_ax = axes('Parent', h);
            set(h_ax, 'NextPlot', 'add');
            xlabel('x / px'); ylabel('y / px'); zlabel('z / px');
        end
        try
            plot3(h_ax, [translations(range(j-1),1) translations(range(j),1)], [translations(range(j-1),2) translations(range(j),2)],...
                [translations(range(j-1),3) translations(range(j),3)], 'Color', colors(j,:), 'LineWidth', 2);
            title(sprintf('Translation of %s (frame %d)', inputFolder, f), 'Interpreter', 'none');
        end
    end
    
    
    updateWaitbar(handles, (j+0.8-1)/(numel(range)));
    
    fprintf('\n - saving data -> (main: ch%d)', params.channel);
    displayStatus(handles,['saving data...'], 'blue', 'add');
    data = metadata.data;
    save(fullfile(handles.settings.directory, [files(f).name(1:end-4), '_metadata.mat']), 'data');
    
    channelData = get(handles.uicontrols.popupmenu.channel, 'String');
    
    if numel(channelData) > 1
        if ~isfield(metadata.data, 'registration')
            delete(h);
            uiwait(msgbox('Cannot continue existing registration! First image of sequence is not registered!', 'Error', 'Error', 'modal'));
            break;
        end
        reg = metadata.data.registration;
        currentChannel = cellfun(@(x) strcmp(getChannelName(x), num2str(params.channel)), channelData);
        ch_toProcess = find(~currentChannel);
        for c = 1:numel(ch_toProcess)
            fprintf(', (ch%d)', ch_toProcess(c));
            filename_ch = fullfile(handles.settings.directory, ...
                strrep([files(f).name(1:end-4), '_metadata.mat'], ['ch', getChannelName(channelData{currentChannel})], ['ch', getChannelName(channelData{ch_toProcess(c)})]));
            
            data = load(filename_ch);
            data = data.data;
            data.registration = reg;
            
            save(filename_ch, 'data');
        end
    end
    displayStatus(handles, 'Done', 'black', 'add');
    fprintf('\n');
    
    if checkCancelButton(handles)
        break;
    end
      
    
end

try
    h_ax.Title.String = {h_ax.Title.String, ' (Registration finished. This window may now be closed)'};
end

if params.sendEmail
    email_to = get(handles.uicontrols.edit.email_to, 'String');
    email_from = get(handles.uicontrols.edit.email_from, 'String');
    email_smtp = get(handles.uicontrols.edit.email_smtp, 'String');
    
    setpref('Internet','E_mail',email_from);
    setpref('Internet','SMTP_Server',email_smtp);
    
    sendmail(email_to,['[Biofilm Toolbox] Image registration finished: "', handles.settings.directory, '"']', ...
        ['Image registration of "', handles.settings.directory, '" finished (Range: ', num2str(range(1)), ':', num2str(range(end)), ').', ]);
end

updateWaitbar(handles, 0);
disp('Done');




