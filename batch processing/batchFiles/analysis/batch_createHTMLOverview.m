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
try
    params.default_outputDirectory = fullfile(fileparts(fileparts(folders{1})), 'html-overview');
catch err
    rethrow(err);
    
end

prompt = {'Enter output directory', 'Overwrite images (yes=1, no=0)? If disabled only the html-file will be (re-)generated', 'Number of image tiles per experiment', 'Enable zoom on mouse-hover'};
title = 'Generate HTML overview';
dims = [1 70];
definput = {params.default_outputDirectory, '1', '5', '1'};
answer = inputdlg(prompt,title,dims,definput);
if isempty(answer)
    return;
end
params.outputDirectory = answer{1};
params.copyImages = str2num(answer{2});
params.NTiles = str2num(answer{3});
params.zoom = str2num(answer{4});

conditions = cell(1, numel(folders));
conditionFolders = cell(1, numel(folders));
for i = 1:numel(folders)
    conditionFolders{i} = fileparts(folders{i});
    [~, conditions{i}] = fileparts(conditionFolders{i});
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
h_next = uicontrol('Parent', bg, 'Style', 'pushbutton', 'String', 'Continue', 'Callback', {@generateHTML, conditionFolders(idx), folders, params});
g.Widths = [-1];
g.Heights = [20 80 -1 20];

function generateHTML(hObject, ~, conditionFolders, folders, params)
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


dataFolders = [];
for i = 1:numel(conditionFolders)
    experiments_subFolders_temp = [];
    
    if iscell(conditionFolders{i})
        for e = 1:numel(conditionFolders{i})
            experiments_subFolders_temp = dir(fullfile(conditionFolders{i}{e}, '*'));
            if e == 1
                experiments_subFolders = experiments_subFolders_temp;
            else
                experiments_subFolders = [experiments_subFolders; experiments_subFolders_temp];
            end
        end
    else
        experiments_subFolders = dir(fullfile(conditionFolders{i}, '*'));
    end
    deleteFolder = false(1, numel(experiments_subFolders));
    for f = 1:numel(experiments_subFolders)
        if ~sum(cellfun(@(x) ~isempty(x), strfind(folders, fullfile(experiments_subFolders(f).folder, experiments_subFolders(f).name))))
            deleteFolder(f) = true;
        end
    end
    experiments_subFolders(deleteFolder) = [];
    
    subFolder_count = 1;
    for j = 1:numel(experiments_subFolders)
        if exist(fullfile(experiments_subFolders(j).folder, experiments_subFolders(j).name, 'data'), 'dir')
            dataFolders(i).name{subFolder_count} = experiments_subFolders(j).name;
            dataFolders(i).folder{subFolder_count} = experiments_subFolders(j).folder;
            subFolder_count = subFolder_count + 1;
        end
    end
end


htmlCode = ['<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">',...
    '<html xmlns="http://www.w3.org/1999/xhtml">',...
    '<head>',...
    '<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />',...
    '<title>Overview</title>',...
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
    
NImageTiles = params.NTiles;

imageThumbs_firstFolder = dir(fullfile(folders{1}, 'data', 'evaluation', '*.png'));

F_resizer = parallel.FevalFuture;

for i = 1:numel(conditions)
    fprintf('Processing folder "%s"\n', experiments{i});
    if i <= numel(dataFolders) && ~isempty(dataFolders(i).name)
        
        if mod(i,2)
            tdColor = '5ec2dd';
        else
            tdColor = 'dbdbdb';
        end
        
        if iscell(experiments{i})
            expDescription = '';
            for e = 1:numel(experiments{i})
                if e == 1
                    expDescription = strrep(experiments{i}{e}, ' ', '&nbsp;');
                else
                    expDescription = [expDescription, ' & ', strrep(experiments{i}{e}, ' ', '&nbsp;')];
                end
            end
        else
            expDescription = strrep(experiments{i}, ' ', '&nbsp;');
        end
        
        htmlCode = [htmlCode, '<table width="100" cellspacing="0" cellpadding="0" style="border: 1px solid  #',tdColor,';">'...
            ' <tr>'...
            '  <td>'...
            '<table width="100" cellpadding="5" cellspacing="0" >',...
            '<tr>'...
            '  <td colspan="',num2str(numel(imageThumbs_firstFolder)+NImageTiles+1),'" bgcolor="#',tdColor,'"><p style="font-size:18px"><strong>',strrep(conditions{i}, ' ', '&nbsp;'),'</strong></p><p style="font-size:10px">(Ref: ',expDescription,')</p></td>'...
            '</tr>'];
        
        for j = 1:numel(dataFolders(i).name)
            
            try
                txtFullPath = fullfile(dataFolders(i).folder{j}, dataFolders(i).name{j}, 'data', 'txt_output', 'data.zip');
                newPath = fullfile(outputDirectory, 'data', experiments{i}, dataFolders(i).name{j}, [experiments{i}, '_', dataFolders(i).name{j}, '_data.zip']);
                txtLink = fullfile('data', experiments{i}, dataFolders(i).name{j}, [experiments{i}, '_', dataFolders(i).name{j}, '_data.zip']);
                if copyImages
                    
                    F_resizer(end+1) = parfeval(@copyfile,0,txtFullPath, newPath);
                end
                sizeData = dir(txtFullPath);
                sizeData = sizeData.bytes/1024/1024;
                htmlCodeDownloadLink = [', <a href="',txtLink,'" target="_new">',sprintf('Download (%.1f Mb)', sizeData),'</a>'];
            catch
                htmlCodeDownloadLink = '';
            end
            
            biofilmPos = strsplit(dataFolders(i).name{j}, filesep);
            
            biofilmPosStr = ['Biofilm&nbsp;',num2str(j),'&nbsp;(',biofilmPos{end},')'];
            
            htmlCode = [htmlCode, '<tr>'...
                '  <td colspan="',num2str(numel(imageThumbs_firstFolder)),'"><p style="font-size:10px"><i>',biofilmPosStr, htmlCodeDownloadLink,'</i></p></td>'...
                '</tr>'...
                '<tr>'];
            
            imageThumbs = dir(fullfile(dataFolders(i).folder{j}, dataFolders(i).name{j}, 'data', 'evaluation', '*.png'));
                    
            imageDescribtion = [];
            for k = 1:numel(imageThumbs)
                imageDescribtion{k} = strtrim(strrep(imageThumbs(k).name(1:end-4), '_', ' '));
            end
            
            if ~exist(fullfile(outputDirectory, 'data', experiments{i}, dataFolders(i).name{j}))
                mkdir(fullfile(outputDirectory, 'data', experiments{i}, dataFolders(i).name{j}));
            end
            
            
            tif_files = dir(fullfile(dataFolders(i).folder{j}, dataFolders(i).name{j}, '*.tif'));
            imageIDs = round(linspace(1, numel(tif_files), NImageTiles));
            
            for l = 1:numel(imageIDs)
                imageFullPath = fullfile(dataFolders(i).folder{j}, dataFolders(i).name{j}, tif_files(imageIDs(l)).name);
                outputFolderFull = fullfile(outputDirectory, 'data', experiments{i}, dataFolders(i).name{j});
                newPath = fullfile(outputFolderFull, [tif_files(imageIDs(l)).name(1:end-4), '.png']);
                imageLink = fullfile('data', experiments{i}, dataFolders(i).name{j}, [tif_files(imageIDs(l)).name(1:end-4), '.png']);
                imageLink_small = fullfile('data', experiments{i}, dataFolders(i).name{j}, ['small_', tif_files(imageIDs(l)).name(1:end-4), '.png']);
                
                if params.copyImages
                    
                    im = double(imread(imageFullPath));
                    im = im-prctile(im(:), 10);
                    im(im<0) = 0;
                    if l < 3
                        im = im/prctile(im(:), 99.95);
                    else
                        im = im/prctile(im(:), 99.5);
                    end
                    im(im>1) = 1;
                    imRGB = ones(size(im, 1), size(im, 2), 3);
                    imRGB(:,:,2) = 255*im;
                    imwrite(uint8(imRGB), newPath);
                    
                    F_resizer(end+1) = parfeval(@resizeImage,0, [tif_files(imageIDs(l)).name(1:end-4), '.png'], ['small_', tif_files(imageIDs(l)).name(1:end-4), '.png'], outputFolderFull, 0.15);
                end
                
                htmlCode = [htmlCode, '<td><div class="zoom"><a href="',imageLink,'" target="_new"><img src="',imageLink_small,'" height="100" align="middle" title="',dataFolders(i).name{j},' - thumbnail #',num2str(l),'"/></a></div></td>'];
                
            end
            
            
            movieFiles = dir(fullfile(dataFolders(i).folder{j}, dataFolders(i).name{j}, 'data', 'animation', '*.mp4'));
            htmlCode = [htmlCode, '<td align="center" valign="middle">'];
            for m = 1:numel(movieFiles)
                try
                    imageFullPath = fullfile(movieFiles(m).folder, movieFiles(m).name);
                    newPath = fullfile(outputDirectory, 'data', experiments{i}, dataFolders(i).name{j}, [dataFolders(i).name{j}, '_movie.mp4']);
                    imageLink = fullfile('data', experiments{i}, dataFolders(i).name{j}, [dataFolders(i).name{j}, '_movie.mp4']);
                    ind = strfind(movieFiles(m).name, '_');
                    movieDisplayName = movieFiles(m).name(ind(1)+1:end-4);
                    
                    if params.copyImages
                        F_resizer(end+1) = parfeval(@copyfile,0,imageFullPath, newPath);
                    end
                    htmlCode = [htmlCode, '<p style="font-size:12px"><a href="',imageLink,'" target="_new">Play</a></p>'];
                catch
                    htmlCode = [htmlCode, '<p style="font-size:12px"></p>'];
                end
            end
            htmlCode = [htmlCode, '</td>'];
            
            
            for k = 1:numel(imageThumbs)
                try
                    imageFullPath = fullfile(dataFolders(i).folder{j}, dataFolders(i).name{j}, 'data', 'evaluation', imageThumbs(k).name);
                    filename = [lower(strrep(imageDescribtion{k}, ' ', '_')), '.png'];
                    outputFolderFull = fullfile(outputDirectory, 'data', experiments{i}, dataFolders(i).name{j});
                    newPath = fullfile(outputFolderFull, [dataFolders(i).name{j}, '_', filename]);
                    imageLink = fullfile('data', experiments{i}, dataFolders(i).name{j}, [dataFolders(i).name{j}, '_', filename]);
                    imageLink_small = fullfile('data', experiments{i}, dataFolders(i).name{j}, ['small_', dataFolders(i).name{j}, '_', filename]);
                    
                    if params.copyImages
                        
                        F_resizer(end+1) = parfeval(@copyfile,0,imageFullPath, newPath);
                        F_resizer(end+1) = parfeval(@resizeImage,0, imageThumbs(k), ['small_', dataFolders(i).name{j}, '_', filename], outputFolderFull, 0.15);
                    end
                    
                    htmlCode = [htmlCode, '<td><div class="zoom"><a href="',imageLink,'" target="_new"><img src="',imageLink_small,'" height="100" align="middle" title="',conditions{i},' - ',imageDescribtion{k},'"/></a></div></td>'];
                catch
                    htmlCode = [htmlCode, '<td></td>'];
                end
            end
            htmlCode = [htmlCode, '</tr>'];
        end
        
        
        htmlCode = [htmlCode, '<tr>'];
        
        
        for l = 1:numel(imageIDs)
            htmlCode = [htmlCode, '<td align="center"><div class="zoom"><p style="font-size:10px"><strong>Timepoint #',num2str(l),'</strong></p></div></td>'];
        end
        
        
        htmlCode = [htmlCode, '<td align="center"><div class="zoom"><p style="font-size:10px"><strong>Movie</strong></p></div></td>'];
        
        
        for k = 1:numel(imageThumbs)
            htmlCode = [htmlCode, '<td align="center"><div class="zoom"><p style="font-size:10px"><strong>',imageDescribtion{k},'</strong></p></div></td>'];
        end
        htmlCode = [htmlCode, '</tr>'];
        
        htmlCode = [htmlCode, '</table>'...
            '</td>'...
            '  </tr>'...
            '</table>',...
            '<br>'];
        
    else
        fprintf('No data-folders found for condition "%s"\n', conditions{i});
    end
end
htmlCode = [htmlCode, '</body>',...
    '</html>'];


fileID = fopen(fullfile(outputDirectory, sprintf('overview.html')),'w');
fprintf(fileID,'%s', htmlCode);
fclose(fileID);



fprintf('Output file(s) created in: "%s"\n', outputDirectory);
if params.copyImages
    fprintf('Resizing in progress (%d images), please wait\n', numel(F_resizer));
    textprogressbar('      ');
    while 1
        pause(1)
        textprogressbar(sum(cellfun(@(x) ~isempty(x), strfind({F_resizer.State}, 'finished')))/numel(F_resizer)*100);
        if sum(cellfun(@(x) ~isempty(x), strfind({F_resizer.State}, 'finished'))) == (numel(F_resizer)-1)
            break;
        end
    end
end
textprogressbar(100);
textprogressbar(' Done.');

end

function resizeImage(file, outputFilename, outputFolder, thumbnailSize)
if isstruct(file)
    im = imread(fullfile(file.folder, file.name));
else
    im = imread(fullfile(outputFolder, file));
end
imwrite(imresize(im, 2*thumbnailSize), fullfile(outputFolder, outputFilename));
end




