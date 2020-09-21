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
function handles = correctFrameNumbering(handles)
displayStatus(handles, 'Correct frame numbering...', 'black');

input_folder = fullfile(handles.settings.directory, '..');

enableCancelButton(handles);

subfolders = dir(fullfile(input_folder, 'Pos*'));

mkdir(fullfile(input_folder, 'corrected'));

for i = 1:numel(subfolders)
    
    mkdir(fullfile(input_folder, 'corrected', subfolders(i).name));
    
    if ~isempty(dir(fullfile(input_folder, subfolders(1).name, '*ch1*tif')))
        
        ch1_files = dir(fullfile(input_folder, subfolders(i).name, '*ch1*tif'));
        
        [~, ch1_files_sorted_ind] = sort([ch1_files.datenum]);
        for j = 1:numel(ch1_files_sorted_ind)
            file = ch1_files(ch1_files_sorted_ind(j)).name;
            
            ind1 = strfind(file, 'frame');
            file(ind1+5:ind1+10) = num2str(j, '%.6d');
            
            copyfile(fullfile(input_folder, subfolders(i).name, ch1_files(ch1_files_sorted_ind(j)).name), ...
                fullfile(input_folder, 'corrected', subfolders(i).name, file));
            copyfile(fullfile(input_folder, subfolders(i).name, [ch1_files(ch1_files_sorted_ind(j)).name(1:end-4), '_metadata.mat']), ...
                fullfile(input_folder, 'corrected', subfolders(i).name, [file(1:end-4), '_metadata.mat']));
            
            updateWaitbar(handles, (i-1)/numel(subfolders)+j/numel(ch1_files_sorted_ind)*1/numel(subfolders)*0.3)
            if checkCancelButton(handles)
                return;
            end
        end
        
        
        ch2_files = dir(fullfile(input_folder, subfolders(i).name, '*ch2*tif'));
        
        [~, ch2_files_sorted_ind] = sort([ch2_files.datenum]);
        for j = 1:numel(ch2_files_sorted_ind)
            file = ch2_files(ch2_files_sorted_ind(j)).name;
            
            ind1 = strfind(file, 'frame');
            file(ind1+5:ind1+10) = num2str(j, '%.6d');
            
            copyfile(fullfile(input_folder, subfolders(i).name, ch2_files(ch2_files_sorted_ind(j)).name), ...
                fullfile(input_folder, 'corrected', subfolders(i).name, file));
            copyfile(fullfile(input_folder, subfolders(i).name, [ch2_files(ch2_files_sorted_ind(j)).name(1:end-4), '_metadata.mat']), ...
                fullfile(input_folder, 'corrected', subfolders(i).name, [file(1:end-4), '_metadata.mat']));
            
            updateWaitbar(handles, (i-1)/numel(subfolders)+j/numel(ch1_files_sorted_ind)*1/numel(subfolders)*0.3 + 0.3/numel(subfolders))
            if checkCancelButton(handles)
                return;
            end
            
        end
        
        try
            ch3_files = dir(fullfile(input_folder, subfolders(i).name, '*ch3*tif'));
            
            [~, ch3_files_sorted_ind] = sort([ch3_files.datenum]);
            for j = 1:numel(ch3_files_sorted_ind)
                file = ch3_files(ch3_files_sorted_ind(j)).name;
                
                ind1 = strfind(file, 'frame');
                file(ind1+5:ind1+10) = num2str(j, '%.6d');
                
                copyfile(fullfile(input_folder, subfolders(i).name, ch3_files(ch3_files_sorted_ind(j)).name), ...
                    fullfile(input_folder, 'corrected', subfolders(i).name, file));
                copyfile(fullfile(input_folder, subfolders(i).name, [ch3_files(ch3_files_sorted_ind(j)).name(1:end-4), '_metadata.mat']), ...
                    fullfile(input_folder, 'corrected', subfolders(i).name, [file(1:end-4), '_metadata.mat']));
                
                updateWaitbar(handles, (i-1)/numel(subfolders)+j/numel(ch1_files_sorted_ind)*1/numel(subfolders)*0.3 + 0.6/numel(subfolders))
                if checkCancelButton(handles)
                    return;
                end
                
            end
        end
        
    else
        
        ch1_files = dir(fullfile(input_folder, subfolders(i).name, '*.tif'));
        
        if ~isempty(ch1_files)
            
            [~, ch1_files_sorted_ind] = sort([ch1_files.datenum]);
            for j = 1:numel(ch1_files_sorted_ind)
                file = ch1_files(ch1_files_sorted_ind(j)).name;
                
                ind1 = strfind(file, 'frame');
                file(ind1+5:ind1+10) = num2str(j, '%.6d');
                file = strrep(file, '_2.tif', '.tif');
                file = strrep(file, '_2_metadata.mat', '_metadata.mat');
                
                try
                    copyfile(fullfile(input_folder, subfolders(i).name, ch1_files(ch1_files_sorted_ind(j)).name), ...
                        fullfile(input_folder, 'corrected', subfolders(i).name, file));
                    
                    try
                        copyfile(fullfile(input_folder, subfolders(i).name, [ch1_files(ch1_files_sorted_ind(j)).name(1:end-4), '_metadata.mat']), ...
                            fullfile(input_folder, 'corrected', subfolders(i).name, [file(1:end-4), '_metadata.mat']));
                    catch
                        copyfile(fullfile(input_folder, subfolders(i).name, [ch1_files(ch1_files_sorted_ind(j)).name(1:end-6), '_metadata_2.mat']), ...
                            fullfile(input_folder, 'corrected', subfolders(i).name, [file(1:end-4), '_metadata.mat']));
                    end
                catch err
                    warning(err.message)
                end
                updateWaitbar(handles, (i-1)/numel(subfolders)+j/numel(ch1_files_sorted_ind)*1/numel(subfolders))
                if checkCancelButton(handles)
                    return;
                end
            end
            
        end
    end
    
    if checkCancelButton(handles)
        return;
    end
end

uiwait(msgbox(['Corrected files have been copied into "', fullfile(input_folder, 'corrected'), '"'], 'Information', 'help'))

updateWaitbar(handles, 0)
displayStatus(handles, 'Done', 'black', 'add');



