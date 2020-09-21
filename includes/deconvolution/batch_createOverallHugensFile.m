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
function fileName = batch_createOverallHugensFile(input_folder, output_folder, params, folders)

folders = obtainFolders(input_folder, 'foldersToProcess', folders);

files = [];
isdecon = @(x) isempty(strfind(x, '_cmle'));
for i = 1:numel(folders)
    if exist(fullfile(folders{i}, 'deconvolved images'))
        files_temp = dir(fullfile(folders{i}, 'deconvolved images', '*.tif'));
        
        if ~isempty(files_temp)
            
            if length(files_temp)>1
                files_decon = arrayfun(isdecon,{files_temp.name});
                files_temp(files_decon) = [];
            
            
            else
                if ~isempty(strfind(files_temp.name, '_cmle'))
                    files_temp(files_decon) = [];
                end
            end
            
            
            valid_files = true(numel(files_temp), 1);
            for j = 1:numel(files_temp)
                if exist(fullfile(files_temp(j).folder, [files_temp(j).name(1:end-4), '_cmle.tif']), 'file')
                    valid_files(j) = false;
                    
                    
                    
                end
            end
            files_temp = files_temp(valid_files);
            
            if ~isempty(files_temp)
               files = vertcat(files, files_temp); 
            end
        end
        
    end
end

if ~exist(output_folder, 'dir')
    mkdir(output_folder);
end
fileName = generateHuygensBatchFile(files, output_folder, params);


