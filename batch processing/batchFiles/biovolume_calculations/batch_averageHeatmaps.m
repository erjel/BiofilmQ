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

prompt = {'Overwrite existing averaged heatmaps (1=yes, 0=no)?','Enter required datapoints per tile:', 'What shall the heatmaps filenames have in common?'};
title = 'Average heatmaps';
dims = [1 70];
definput = {'1','2', '*Time*'};
answer = inputdlg(prompt,title,dims,definput);
if isempty(answer)
    return;
end

requiredDataPoints = str2num(answer{2});

overwriteFiles = str2num(answer{1});

fileFilter = answer{3};

parentFolders = cell(numel(folders), 1);
for i = 1:numel(folders)
    folderParts = strsplit(folders{i}, filesep);
    parentFolders{i} = folderParts{end-1};
end
parentFolders = unique(parentFolders);
parentFolders_withoutDate = parentFolders;
for i = 1:numel(parentFolders_withoutDate)
    whiteSpaceInd = strfind(parentFolders_withoutDate{i}, ' ');
    parentFolders_withoutDate{i} = parentFolders_withoutDate{i}(whiteSpaceInd+1:end);
end
[parentFolders_withoutDate, ind] = sort_nat(parentFolders_withoutDate);
parentFolders = parentFolders(ind);


for i = 1:numel(parentFolders)
    fprintf('Working in folder "%s"\n', parentFolders{i});
    folderToAverageOver = [];
    for j = 1:numel(folders)
        if ~isempty(strfind(folders{j}, parentFolders{i}))
            if exist(fullfile(folders{j}, 'data', 'evaluation'), 'dir')
                folderToAverageOver(end+1) = j;
            end
        end
    end
    
    
    
    
    heatmapFiles = dir(fullfile(folders{folderToAverageOver(1)}, 'data', 'evaluation', sprintf('%s.mat', fileFilter)));
    
    fprintf(' - found %d different heatmaps, average over %d folder(s)\n', numel(heatmapFiles), numel(folderToAverageOver));
    
    
    for j = 1:numel(heatmapFiles)
        fprintf('  - heatmap %d\n', j);
        
        referenceHeatmapFilename = heatmapFiles(j).name;
        
        folderParts = strsplit(folders{folderToAverageOver(1)}, filesep);
        output_dir = fullfile(folderParts{1:end-1}, 'averaged_heatmaps');
        output_filename_test = dir(fullfile(output_dir, [referenceHeatmapFilename(1:end-4), '_averaged_N*']));
        
        if ~overwriteFiles && ~isempty(output_filename_test)
            fprintf('     - file already exists\n');
            continue;
        end
        
        
        heatmap = load(fullfile(folders{folderToAverageOver(1)}, 'data', 'evaluation', referenceHeatmapFilename));
        X = heatmap.X;
        Y = heatmap.Y;
        
        
        h = open(fullfile(folders{folderToAverageOver(1)}, 'data', 'evaluation', [referenceHeatmapFilename(1:end-12), '.fig']));
        h_ax = findobj(h.Children, 'type', 'axes');
        surface_h = findobj(h_ax, 'type', 'surface');
        
        heatmap_stack = heatmap.heatmapMatrix;
        
        for k = 2:numel(folderToAverageOver)
            try
                heatmap = load(fullfile(folders{folderToAverageOver(k)}, 'data', 'evaluation', referenceHeatmapFilename));
                heatmap_stack(:,:,end+1) = heatmap.heatmapMatrix;
            catch
                fprintf('    - heatmap "%s" not present in "%s"\n', referenceHeatmapFilename, folders{folderToAverageOver(k)});
            end
        end
        
        
        N_datapoints = sum(~isnan(heatmap_stack), 3);
        N_datapoints = sum(heatmap_stack~=0, 3);
        
        
        heatmap_mean = nanmean(heatmap_stack,3);
        heatmap_std = nanstd(heatmap_stack,[],3);
        heatmap_N = nansum(~isnan(heatmap_stack),3); 
        
        heatmap_mean(N_datapoints < requiredDataPoints) = NaN;
        heatmap_std(N_datapoints < requiredDataPoints) = NaN;
        
        N = size(heatmap_stack, 3);
        
        output_filename = fullfile(output_dir, [referenceHeatmapFilename(1:end-4), '_averaged_N', num2str(N)]);
        
        if ~exist(output_dir)
            mkdir(output_dir);
        end
        
        save([output_filename, '.mat'], 'heatmap_mean', 'heatmap_std', 'N', 'X', 'Y', 'heatmap_stack');
        
        
        
        surface_h.CData = heatmap_mean;
        
        savefig(h, [output_filename, '_mean.fig']);
        print(h, '-dpng','-r300',[output_filename, '_mean.png']);
        print(h, '-depsc','-r300', '-painters' ,[output_filename, '_mean.eps']);
        print(h, '-dsvg','-r300', '-painters' ,[output_filename, '_mean.svg']);
        
        
        surface_h.CData = heatmap_std;
        
        savefig(h, [output_filename, '_std.fig']);
        print(h, '-dpng','-r300',[output_filename, '_std.png']);
        print(h, '-depsc','-r300', '-painters' ,[output_filename, '_std.eps']);
        
        
        surface_h.CData = heatmap_N;
        surface_h.Parent.CLim = [0 N];
        surface_h.Parent.Colorbar.Label.String = 'N_{datapoints}';
        savefig(h, [output_filename, '_N.fig']);
        print(h, '-dpng','-r300',[output_filename, '_N.png']);
        print(h, '-depsc','-r300', '-painters' ,[output_filename, '_N.eps']);
        
        delete(h);
    end
end




