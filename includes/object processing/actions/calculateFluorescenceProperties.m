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
function objects = calculateFluorescenceProperties(handles, objects, params, filename, options)
opts = params.intensity_tasks;

if isempty(opts)
    fprintf('  -> No tasks selected!\n');
    return;
end

opts = opts([opts{:,5}], :);

if isempty(opts)
    fprintf('  -> No tasks are active!\n');
    return;
end
fprintf('\n');  

binaryData = [opts{:,6}]';

personOrManders = cellfun(@(x) ~isempty(strfind(lower(x), 'mander')) || ~isempty(strfind(lower(x), 'pearson')) || ~isempty(strfind(lower(x), 'overlap')), opts(:,1));
ch_num_cell = cellfun(@(x) str2num(strrep(getChannelName(x), ' & ', ', ')), opts(~binaryData | personOrManders,3), 'UniformOutput', false);

ch_available = unique([ch_num_cell{:}]);

if any(ch_available == params.channel)
    ch_available = [params.channel setdiff(ch_available, params.channel)];
end

ch_binary_num_cell = cellfun(@(x) str2num(strrep(x, ' & ', ', ')), opts(binaryData,3), 'UniformOutput', false);
ch_binary_available = unique([ch_binary_num_cell{:}]);

tryParentLink = 0;
if ~isempty(ch_available)
[img_processed, background, ~, tryParentLink, params, metadata] ...
    = getImageFromRaw(handles, objects, params, filename, ch_available);
end   

img_processed_noNoise = cell(max(ch_available), 1);
img_noBG = cell(max(ch_available), 1);
img_corr = cell(max(ch_available), 1);
obj = cell(max(ch_available), 1);
obj_nonMerged = cell(max(ch_available), 1);

obj{params.channel} = objects;

for task = 1:size(opts, 1)
    displayStatus(handles, sprintf('task #%d...', task), 'blue', 'add');
    fprintf(' - calculating "%s" [range: %s, channel: %s]\n', opts{task,1}, opts{task,2}, opts{task,3});
    
    
    ch_task = str2num(strrep(getChannelName(opts{task,3}), ' & ', ', '));
    
    
    try
        range = str2num(opts{task,2});
    catch
        range = [];
    end
    
    if ~opts{task,6} || personOrManders(task) 
        
        img = img_processed;
        if opts{task, 4}
            fprintf('     removing noise ');
            for ch_noise = ch_task
                fprintf(' ch %d', ch_noise);
                if isempty(img_processed_noNoise{ch_noise})
                    img_processed_noNoise{ch_noise} = convolveBySlice(img_processed{ch_noise}, params, 1); 
                else
                    fprintf(' (already done)');
                end
                img{ch_noise} = img_processed_noNoise{ch_noise};
            end

            fprintf('\n');
        end
    end
    
    if strcmpi(opts{task,1}, 'mean intensity per object')
        [objects, img_noBG] = calculateMeanIntensityPerObject(objects, img, ch_task, background, img_noBG);
        
    elseif strcmpi(opts{task,1}, 'integrated intensity per object')
        [objects, img_noBG] = calculateIntegratedIntensityPerObject(objects, img, ch_task, background, img_noBG);
        
    elseif strfind(lower(opts{task,1}), 'mean intensity ratio')
        [objects, img_noBG] = calculateFluorescenceRatio(objects, img, ch_task, background, img_noBG );
        
    elseif strfind(lower(opts{task,1}), 'integrated intensity ratio')
        [objects, img_noBG] = calculateIntegratedFluorescenceRatio(objects, img, ch_task, background, img_noBG );
        
        
    elseif strfind(lower(opts{task,1}), 'mean intensity per object-shell')
        [objects, img_noBG, img_corr] = calculateMeanIntensityPerObjectShell(objects, img, ch_task, background,  range, img_noBG, img_corr);

    elseif strfind(lower(opts{task,1}), 'integrated intensity per object-shell')
        [objects, img_noBG, img_corr] = calculateIntegratedIntensityPerObjectShell(objects, img, ch_task, background, range, img_noBG, img_corr);

    elseif  ~isempty(strfind(lower(opts{task,1}), 'vtk'))
        visualizeExtracellularFluorophores(objects, img, ch_task, opts, task, handles, filename, range);
        
    elseif strfind(lower(opts{task,1}), 'pearson')
        [objects] = calculatePearsonCorrelation(objects, img, ch_task, opts, task, range, params);
        
    elseif strfind(lower(opts{task,1}), 'mander')
        [objects, obj] = calculateMandersCorrelation(objects, img, ch_task, opts, task, handles, filename, obj, range, params);
        
    elseif strfind(lower(opts{task,1}), 'autocorrelation')
        [objects, obj] = calculateAutocorrelation(objects, filename, handles, obj, ch_task, params);
        
    elseif strfind(lower(opts{task,1}), 'density correlation of binary data')
        [objects, obj_nonMerged] = calculateDensityCorrelationBinary(objects, obj_nonMerged, ch_task, handles, filename, range);
        
    elseif strfind(lower(opts{task,1}), 'number of fluorescence foci')
        objects = calculateNumberOfFluorescenceFoci(objects, img, ch_task, range);
        
    elseif strfind(lower(opts{task,1}), '3d overlap between channels')
        objects = calculate3dOverlap(objects, img, ch_task, opts, task, handles, filename, obj);
        
    elseif strfind(lower(opts{task,1}), 'haralick')
        objects = calculateHaralickTextureFeatures(objects, img, ch_task, range);
        
    else
        warning(sprintf('The selected task "%s" is not valid', opts(task,1)));
        
    end
end



if tryParentLink
    fprintf(' - Since we have a skipped frame in the channel information: try to assign parent values ...\n');
    if isfield(objects.stats, 'Track_Parent')
        fprintf(' - copying the intensity values of the parent cells existing in the previous frame\n');
        fileIndex = find( ...
                cellfun(@(x) ~isempty(x), ...
                    cellfun(@(x) strfind(x, filename), {handles.settings.lists.files_tif.name}, 'UniformOutput', false)));
        prevFrame = fileIndex-1;
        
        
        filePrev = handles.settings.lists.files_cells(prevFrame).name;
        
        objFileName = fullfile(handles.settings.directory, 'data', filePrev);
        fprintf(' - loading previous cell objects [%s] for comparison', filePrev);
        prevData = struct('objects', loadObjects(objFileName, 'stats'));
        
        
        fnames = fieldnames(prevData.objects.stats);
        idx = [find(cellfun(@(x) ~isempty(x), cellfun(@(x) strfind(lower(x), 'intensity'), fnames, 'UniformOutput', false)))...
            find(cellfun(@(x) ~isempty(x), cellfun(@(x) strfind(lower(x), 'correlation'), fnames, 'UniformOutput', false)))...
            find(cellfun(@(x) ~isempty(x), cellfun(@(x) strfind(lower(x), 'foci'), fnames, 'UniformOutput', false)))];
        
        for i = 1:objects.NumObjects
            
            if ~isnan(objects.stats(i).Track_Parent) && objects.stats(i).Track_Parent
                for fn = 1:numel(idx)
                    objects.stats(i).(fnames{idx(fn)}) = prevData.objects.stats(objects.stats(i).Track_Parent).(fnames{idx(fn)});
                end
            end
        end
    else
        fprintf('    -> considered tracking cells first!');
    end
end





