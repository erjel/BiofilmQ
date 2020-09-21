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
cd(fileparts(which('BiofilmQ')));

range = 1:numel(folders);

handles = handles.handles_GUI;
hObject = handles.mainFig;

for i = range
    if isdir(fullfile(folders{i}))
        fprintf('Processing folder %s\n', folders{i});
        
        files = dir(fullfile(folders{i}, 'data', '*_data.mat'));
        saveDirectory = fullfile(folders{i}, 'data');
        
        
        
        
        
        
        
        for j = 1:length(files)
            results = load(fullfile(files(j).folder,files(j).name));
            try
                
                if ~isempty(results.globalMeasurements.base_ellipse_width) && ~isempty(results.globalMeasurements.base_ellipse_length)
                    results.globalMeasurements.aspectRatioGlobal_heightToWidth = results.globalMeasurements.base_height/results.globalMeasurements.base_ellipse_width;
                    results.globalMeasurements.aspectRatioGlobal_heightToLength = results.globalMeasurements.base_height/results.globalMeasurements.base_ellipse_length;
                    results.globalMeasurements.aspectRatioGlobal_lengthToWidth = results.globalMeasurements.base_ellipse_length/results.globalMeasurements.base_ellipse_width;
                else
                    results.globalMeasurements.aspectRatioGlobal_heightToWidth = results.globalMeasurements.base_height/results.globalMeasurements.base_width;
                    results.globalMeasurements.aspectRatioGlobal_heightToLength = results.globalMeasurements.base_height/results.globalMeasurements.base_length;
                    results.globalMeasurements.aspectRatioGlobal_lengthToWidth = results.globalMeasurements.base_length/results.globalMeasurements.base_width;
                end
                
                saveObjects(fullfile(saveDirectory, files(j).name), results);
            end
        end
        
    end
end


