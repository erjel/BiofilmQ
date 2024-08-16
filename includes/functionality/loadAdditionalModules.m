function handles = loadAdditionalModules(handles)
if isdeployed
    addModules = dir(fullfile(handles.settings.pathGUI, '..', 'includes', 'additional modules'));
else
    addModules = dir(fullfile(handles.settings.pathGUI, 'includes', 'additional modules'));
end

addModules = addModules(setdiff(find([addModules.isdir]), [1, 2]));

modules = {...
    'cell tracking', ...
    'ellipse representation', ...
    'single cell properties', ...
    'single cell segmentation', ... % experimental
    'image series curation', ... % experimental
    'huygens deconvolution', ... % experimental
    'simulations', ... % experimental
    'thresholding by slice', ... % experimental
};

fprintf('\n');
for i = 1:numel(addModules)
    if any(cellfun(@(x) strcmp(x,addModules(i).name), modules))
        fprintf('Enabling additional module "%s"\n', addModules(i).name);
        eval(sprintf('handles = enable_%s(handles);', strrep(addModules(i).name, ' ', '_')));
    end
end

if isdeployed
    for i = 1:numel(modules)
        try
            fprintf('Enabling additional module "%s"\n', modules{i});
            eval(sprintf('handles = enable_%s(handles);', strrep(modules{i}, ' ', '_')));
        catch
            fprintf(['Module not found: ', modules{i}]);
        end
    end
end
    