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
field = 'Shape_Volume';
channels = [2 3];
errorbars = 'std'; 
legendStr = {'n16', 'cwd112'};
extractTimeInBetween = {'T_', 'hrs'};

times = [];
dataAll = [];
for i = 1:numel(folders)
    
    folder = folders{i};
    
    files = dir(fullfile(folder, 'data', '*_data.mat'));
    [~, sortIdx] = sort_nat({files.name});
    files = files(sortIdx);
    
    
    for ch = 1:numel(channels)
        validFilesIdx = contains({files.name}, ['_ch', num2str(channels(ch))]);
        validFiles = files(validFilesIdx);
        
        for f = 1:numel(validFiles)
            file = fullfile(folder, 'data', validFiles(f).name);
            
            time = extractBetween(validFiles(f).name, extractTimeInBetween{1}, extractTimeInBetween{2});
            time = str2num(time{1});
            
            objects = loadObjects(file, 'stats');
            data = [objects.stats.(field)];
            
            times{i}{ch, f} = time;
            dataAll{i}{ch, f} = data;
        end
        
    end 
end


dataAll_sum = [];
for i = 1:numel(folders)
    dataAll_sum(:,:,i) = cellfun(@sum, dataAll{i});
end

data_mean = mean(dataAll_sum, 3);
data_std = std(dataAll_sum, [], 3);
data_stdErr = std(dataAll_sum, [], 3)./sqrt(numel(folders));

timepoints = cell2mat(times{1}(1,:));

h = figure('Name', field); 
h_ax = axes('Parent', h, 'Nextplot', 'add');

switch errorbars
    case 'std'
        err = data_std;
    case 'stdErr'
        err = data_stdErr;
end

for ch = 1:numel(channels)
    errorbar(h_ax, timepoints, data_mean(ch, :), err(ch, :));
end

legend(h_ax, legendStr, 'Location', 'northwest');
box(h_ax, 'on');
xlabel('Time (h)');
ylabel('Biomass (\mum^3)');

h.Units = 'centimeters';
h.PaperPosition = [0, 0, 8, 8];

set(h.Children, 'FontSize', 16)
set(findobj(h, 'Type', 'Line'), 'LineWidth', 1)

print(h, fullfile(inputFolder, [field, '.eps']), '-depsc', '-r300')
print(h, fullfile(inputFolder, [field, '.png']), '-dpng', '-r300')



