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
function objects = averageObjectParameters(objects, silent)

if nargin < 2
    silent = 0;
end

if ~silent
    ticValue = displayTime;
end

fprintf(' - averaging parameters');

fNames = fieldnames(objects.stats);
fNames = setdiff(fNames, {'IsRelatedToFounderCells', 'Surface_LocalThickness'});

if ~isfield(objects, 'globalMeasurements')
    objects.globalMeasurements = [];
end


if isfield(objects.stats, 'Distance_ToBiofilmCenterAtSubstrate')
    d_CM = [objects.stats.Distance_ToBiofilmCenterAtSubstrate];
    
    if isfield(objects.stats, 'IsRelatedToFounderCells')
        IsRelatedToFounderCells = [objects.stats.IsRelatedToFounderCells];
        d_CM = d_CM(IsRelatedToFounderCells);
    else
        fprintf('    - field [IsRelatedToFounderCells] not found. Averaging will be performed on all cells'); 
    end
    
    dCM_max = prctile(d_CM, 90);
    coreIDs = d_CM < dCM_max/2;
    shellIDs = d_CM > dCM_max/2;
else
   fprintf('    - skipping calculation of core and shell resolved parameters (reason: field [Distance_ToBiofilmCenterAtSubstrate] not existing)');
end

for i = 1:numel(fNames)
    field = fNames{i};
    
    if isfield(objects.stats, 'IsRelatedToFounderCells')
        data = {objects.stats(IsRelatedToFounderCells).(field)};
        biomass = {objects.stats(IsRelatedToFounderCells).Shape_Volume};
    else
        data = {objects.stats.(field)};
        try
            biomass = {objects.stats.Shape_Volume};
        catch err
            if strcmp(err.identifier, 'MATLAB:nonExistentField')
                
                
                biomass = {objects.stats.Volume};
            else
                rethrow(err)
            end
        end
    end
    if max(cellfun(@numel, data)) == 1 && min(cellfun(@numel, data)) == 1
        data = [data{:}];
        biomass = [biomass{:}];
        nans = isnan(data);
        
        
        
        objects.globalMeasurements.(sprintf('%s_mean', field)) = nanmean(data);
        objects.globalMeasurements.(sprintf('%s_mean_biomass', field)) = nansum(data.*biomass)/sum(biomass(~nans));
        objects.globalMeasurements.(sprintf('%s_std', field)) = nanstd(data);
        m = objects.globalMeasurements.(sprintf('%s_mean_biomass', field));
        objects.globalMeasurements.(sprintf('%s_std_biomass', field)) = sqrt(nansum(((data-m).^2).*biomass)/sum(biomass(~nans)));
        objects.globalMeasurements.(sprintf('%s_median', field)) = nanmedian(data);
        objects.globalMeasurements.(sprintf('%s_p25', field)) = prctile(data, 25);
        objects.globalMeasurements.(sprintf('%s_p75', field)) = prctile(data, 75);
        objects.globalMeasurements.(sprintf('%s_min', field)) = min(data);
        objects.globalMeasurements.(sprintf('%s_max', field)) = max(data);
        
        if isfield(objects.stats,  'Distance_ToBiofilmCenterAtSubstrate')&& ~isempty(shellIDs) && ~isempty(coreIDs)
            
            objects.globalMeasurements.(sprintf('%s_core_mean', field)) = nanmean(data(coreIDs));
            objects.globalMeasurements.(sprintf('%s_core_mean_biomass', field)) = nansum(data(coreIDs).*biomass(coreIDs))/sum(biomass(~nans & coreIDs));
            objects.globalMeasurements.(sprintf('%s_core_std', field)) = nanstd(data(coreIDs));
            m = objects.globalMeasurements.(sprintf('%s_core_mean_biomass', field));
            objects.globalMeasurements.(sprintf('%s_core_std_biomass', field)) = sqrt(nansum(((data(coreIDs)-m).^2).*biomass(coreIDs))/sum(biomass(~nans & coreIDs)));
            objects.globalMeasurements.(sprintf('%s_core_median', field)) = nanmedian(data(coreIDs));
            objects.globalMeasurements.(sprintf('%s_core_p25', field)) = prctile(data(coreIDs), 25);
            objects.globalMeasurements.(sprintf('%s_core_p75', field)) = prctile(data(coreIDs), 75);
            objects.globalMeasurements.(sprintf('%s_core_min', field)) = min(data(coreIDs));
            objects.globalMeasurements.(sprintf('%s_core_max', field)) = max(data(coreIDs));
            
            objects.globalMeasurements.(sprintf('%s_shell_mean', field)) = nanmean(data(shellIDs));
            objects.globalMeasurements.(sprintf('%s_shell_mean_biomass', field)) = nansum(data(shellIDs).*biomass(shellIDs))/sum(biomass(~nans & shellIDs));
            objects.globalMeasurements.(sprintf('%s_shell_std', field)) = nanstd(data(shellIDs));
            m = objects.globalMeasurements.(sprintf('%s_shell_mean_biomass', field));
            objects.globalMeasurements.(sprintf('%s_shell_std_biomass', field)) = sqrt(nansum(((data(shellIDs)-m).^2).*biomass(shellIDs))/sum(biomass(~nans & shellIDs)));
            objects.globalMeasurements.(sprintf('%s_shell_median', field)) = nanmedian(data(shellIDs));
            objects.globalMeasurements.(sprintf('%s_shell_p25', field)) = prctile(data(shellIDs), 25);
            objects.globalMeasurements.(sprintf('%s_shell_p75', field)) = prctile(data(shellIDs), 75);
            objects.globalMeasurements.(sprintf('%s_shell_min', field)) = min(data(shellIDs));
            objects.globalMeasurements.(sprintf('%s_shell_max', field)) = max(data(shellIDs));
        end
    end
end

if ~silent
    displayTime(ticValue);
end



