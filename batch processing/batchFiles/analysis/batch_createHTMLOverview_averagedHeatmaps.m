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
if isempty(folders)
    uiwait(msgbox('No folders selected.', 'Please note', 'help', 'modal'));
    return;
end

params = [];
default_outputDirectory = strsplit(folders{1}, filesep);
try
    params.default_outputDirectory = fullfile(fullfile(default_outputDirectory{1:end-2}), 'html-overview');
catch
    params.default_outputDirectory = fullfile(default_outputDirectory{1}, 'html-overview');
end

prompt = {'Enter output directory', 'Overwrite images (yes=1, no=0)? If disabled only the html-file will be (re-)generated', 'Enable zoom on mouse-hover', 'Heatmaps to include'};
title = 'Generate HTML overview';
dims = [1 70];
definput = {params.default_outputDirectory, '1', '1', 'mean, std'};
answer = inputdlg(prompt,title,dims,definput);
if isempty(answer)
    return;
end
params.outputDirectory = answer{1};
params.copyImages = str2num(answer{2});
params.zoom = str2num(answer{3});
params.heatmapTypes = answer{4};

conditions = cell(1, numel(folders));
conditionFolders = cell(1, numel(folders));
for i = 1:numel(folders)
    path = strsplit(folders{i}, filesep);
    conditions{i} = path{end-1};
    conditionFolders{i} = fullfile(path{1:end-1});
end
[conditions, idx] = unique(conditions);
conditions = conditions';

h = figure('Name', 'Look-up table for folders');
addIcon(h);
g = uix.Grid('Parent', h, 'Padding', 5, 'Spacing', 5);
uicontrol('Parent', g, 'Style', 'text', 'String', 'Here you can change how the folders shall appear in the HTML table:','HorizontalAlignment', 'left')
uicontrol('Parent', g, 'Style', 'text', 'String', {'You can use HTML-tags:', 'Superscript: <sup></sup>', 'Subscript: <sub></sub>', 'Bold: <b></b>', 'Italic: <i></i>', 'Greek delta: \Delta'},'HorizontalAlignment', 'left')
table_h = uitable('Parent', g, 'Data', [conditions, conditions], 'ColumnName', {'Folder', 'Appearance in HTML file'}, 'ColumnEditable', [false, true], 'ColumnWidth', {h.Position(3)/2-20 h.Position(3)/2-20});
bg = uix.HButtonBox('Parent', g, 'Spacing', 10);
h_next = uicontrol('Parent', bg, 'Style', 'pushbutton', 'String', 'Continue', 'Callback', {@generateHTML, conditionFolders(idx), params});
g.Widths = [-1];
g.Heights = [20 80 -1 20];

function generateHTML(hObject, ~, folders, params)
f = ancestor(hObject, 'figure', 'toplevel');
table_h = findobj(f, 'Type', 'uitable');
conditions = table_h.Data(:,2);
experiments = table_h.Data(:,1);
delete(f);

outputDirectory = params.outputDirectory;

if ~exist(outputDirectory, 'dir')
    mkdir(outputDirectory);
end

conditions = strrep(conditions, '\mu', '&#956;');
conditions = strrep(conditions, '\Delta', '&#916;');

types = strtrim(strsplit(params.heatmapTypes, ','));

for type = 1:numel(types)
    fprintf('Processing type "%s"\n', types{type});
    htmlCode = ['<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">',...
        '<html xmlns="http://www.w3.org/1999/xhtml">',...
        '<head>',...
        '<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />',...
        ['<title>Overview: ',types{type},'</title>'],...
        '<style type="text/css">',...
        '   p { margin-top: 0; margin-bottom: 0; font-family: "Arial";}'];
    
    if params.zoom
        htmlCode = [htmlCode, '.zoom {',...
        'transition: transform .2s; /* Animation */',...
        'background-color: white;',...
        '}',...
        '.zoom:hover {',...
        'transform: scale(2);',...
        '}'];
    end
    
    htmlCode = [htmlCode, '</style>',...
        '</head>',...
        '<body>'];
    
    
    imageThumbs_firstFolder = dir(fullfile(folders{1}, 'averaged_heatmaps', ['*_',types{type},'.png']));
    F_resizer = parallel.FevalFuture;
    
    for i = 1:numel(conditions)
        fprintf(' - Processing folder "%s"\n', experiments{i});
        if exist(fullfile(folders{i}, 'averaged_heatmaps'), 'dir')
            if mod(i,2)
                tdColor = '5ec2dd';
            else
                tdColor = 'dbdbdb';
            end
            
            htmlCode = [htmlCode, '<table width="100" cellspacing="0" cellpadding="0" style="border: 1px solid  #',tdColor,';">'...
                ' <tr>'...
                '  <td>'...
                '<table width="100" cellpadding="5" cellspacing="0" >',...
                '<tr>'...
                '  <td colspan="',num2str(numel(imageThumbs_firstFolder)),'" bgcolor="#',tdColor,'"><p style="font-size:18px"><strong>',strrep(conditions{i}, ' ', '&nbsp;'),'</strong></p><p style="font-size:18px">(',strrep(experiments{i}, ' ', '&nbsp;'),')</p></td>'...
                '</tr>'];
            
            
            htmlCode = [htmlCode, '<tr>'...
                '  <td colspan="',num2str(numel(imageThumbs_firstFolder)),'"><p style="font-size:10px"><i>Averaged Heatmaps (',types{type},')</i></p></td>'...
                '</tr>'...
                '<tr>'];
            
            imageThumbs = dir(fullfile(folders{i}, 'averaged_heatmaps', ['*_',types{type},'.png']));
            
            imageDescribtion = [];
            for k = 1:numel(imageThumbs)
                imageDescribtion{k} = strrep(imageThumbs(k).name, 'stats2', 'cubes:');
                imageDescribtion{k} = strrep(imageDescribtion{k}, 'stats', '');
                imageDescribtion{k} = strrep(imageDescribtion{k}, 'inverted', '(inv)');
                imageDescribtion{k} = strrep(imageDescribtion{k}, '.png', '');
                imageDescribtion{k} = strrep(imageDescribtion{k}, 'mean', '');
                imageDescribtion{k} = strrep(imageDescribtion{k}, 'heatmap', '');
                imageDescribtion{k} = strrep(imageDescribtion{k}, 'averaged', '');
                idx = strfind(imageDescribtion{k}, '_N');
                try
                    imageDescribtion{k} = [strtrim(imageDescribtion{k}(1:idx(end)-1)), ' N=', imageDescribtion{k}(idx(end)+2)];
                end
                imageDescribtion{k} = strtrim(strrep(imageDescribtion{k}, '_', ' '));
            end
            
            
            imageThumbs_display = {imageThumbs_firstFolder.name};
            deleteThumbs = zeros(1, numel(imageThumbs));
            
            for f = 1:numel(imageThumbs_display)
                idx = strfind(imageThumbs_display{f}, 'averaged');
                imageThumbs_display{f} = imageThumbs_display{f}(1:idx-1);
            end
            
            strippedThumbFilenames = [];
            for f = 1:numel(imageThumbs)
                idx = strfind(imageThumbs(f).name, 'averaged');
                strippedThumbFilenames{f} = imageThumbs(f).name(1:idx-1);
            end
            
            
            for k = 1:numel(imageThumbs)
                if isempty(intersect(strippedThumbFilenames, imageThumbs_display))
                    deleteThumbs(k) = 1;
                end
            end
            imageThumbs = imageThumbs(~deleteThumbs);
            imageDescribtion = imageDescribtion(~deleteThumbs);
            
            if ~exist(fullfile(outputDirectory, 'data', experiments{i}, 'averaged_heatmaps'), 'dir')
                mkdir(fullfile(outputDirectory, 'data', experiments{i}, 'averaged_heatmaps'));
            end

            
            
            for k = 1:numel(imageThumbs)
                imageFullPath = fullfile(folders{i}, 'averaged_heatmaps', imageThumbs(k).name);
                outputFolderFull = fullfile(outputDirectory, 'data', experiments{i}, 'averaged_heatmaps');
                newPath = fullfile(outputFolderFull, imageThumbs(k).name);
                imageLink = fullfile('data', experiments{i}, 'averaged_heatmaps', imageThumbs(k).name);
                imageLink_small = fullfile('data', experiments{i}, 'averaged_heatmaps', ['small_', imageThumbs(k).name]);
                
                if params.copyImages
                    
                    F_resizer(end+1) = parfeval(@copyfile,0,imageFullPath, newPath);
                    F_resizer(end+1) = parfeval(@resizeImage,0,imageThumbs(k), outputFolderFull, 0.15);
                end
                
                htmlCode = [htmlCode, '<td><div class="zoom"><a href="',imageLink,'" target="_new"><img src="',imageLink_small,'" width="300" align="middle" title="',conditions{i},'"/></a></div></td>'];
            end
            
            htmlCode = [htmlCode, '</tr>'];
            
            
            htmlCode = [htmlCode, '<tr>'];
            
            
            for k = 1:numel(imageThumbs)
                htmlCode = [htmlCode, '<td align="center"><p style="font-size:10px"><div class="zoom">',imageDescribtion{k},'</div></p></td>'];
            end
            htmlCode = [htmlCode, '</tr>'];
            
            htmlCode = [htmlCode, '</table>'...
                '</td>'...
                '  </tr>'...
                '</table>',...
                '<br>'];
            
        else
            fprintf('No data found for condition "%s"\n', conditions{i});
        end
    end
    htmlCode = [htmlCode, '</body>',...
        '</html>'];
    
    
    fileID = fopen(fullfile(outputDirectory, ['overview_averaged_',types{type},'.html']),'w');
    fprintf(fileID,'%s', htmlCode);
    fclose(fileID);
end

fprintf('Output file(s) created in: "%s"\n', outputDirectory);
if params.copyImages
    fprintf('Resizing in progress (%d images), please wait\n', numel(F_resizer));
    textprogressbar('      ');
    while 1
        pause(1)
        textprogressbar(sum(cellfun(@(x) ~isempty(x), strfind({F_resizer.State}, 'finished')))/(numel(F_resizer)-1)*100);
        if sum(cellfun(@(x) ~isempty(x), strfind({F_resizer.State}, 'finished'))) == (numel(F_resizer)-1)
            break;
        end
    end
end
textprogressbar(100);
textprogressbar(' Done.');

end

function resizeImage(file, outputFolder, thumbnailSize)
im = imread(fullfile(file.folder, file.name));
imwrite(imresize(im, 2*thumbnailSize), fullfile(outputFolder, ['small_', file.name(1:end-4), '.png']));
end



