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
function [label, unit, range, legendStr] = returnUnitLabel(fieldName, biofilmData, database, rangeMethod, returnTrueLimits)
legendStr = '';

fieldName_ori = fieldName;

if nargin > 1 && ~isfield(biofilmData, 'data')
    biofilmData = struct('data', biofilmData);
end

if nargin < 3
    database = 'stats';
end

if nargin < 5
    returnTrueLimits = 0;
end

if nargin < 4
    rangeMethod = 1;
end

range = [];
label = strrep(fieldName, '_', ' ');
unit = 'a.u.';
rangeLabel = '';

if strcmp(fieldName, 'Time')
    label = 'Time';
    unit = 'h';
end
if strcmp(fieldName, 'Channel')
    label = 'Merged from channel #';
    unit = '';
end
if strcmp(fieldName, 'Cell_Number')
    label = 'N_{cells}';
    unit = '';
    range = [1 5000];
end
if strcmp(fieldName, 'Frame')
    label = 'Frame';
    unit = '';
end
if strcmp(fieldName, 'Centroid')
    label = 'Centroid';
    unit = 'vox';
end
if ~isempty(strfind(fieldName, 'CenterCoord'))
    label = 'Cube center coord';
    unit = 'vox';
end
if strcmp(fieldName, 'CentroidCoordinate_x') || strcmp(fieldName, 'x')
    label = 'x';
    unit = 'vox';
end
if strcmp(fieldName, 'CentroidCoordinate_y') || strcmp(fieldName, 'y')
    label = 'y';
    unit = 'vox';
end
if strcmp(fieldName, 'CentroidCoordinate_z') || strcmp(fieldName, 'z')
    label = 'z';
    unit = 'vox';
end
if strcmp(fieldName, 'Distance_FromSubstrate')
    label = 'd_z';
    unit = '\mum';
end

if strcmp(fieldName, 'Track_ID')
    label = 'Track ID';
    unit = '';
end
if strcmp(fieldName, 'Track_Grandparent')
    label = 'Grandparent ID';
    unit = '';
end
if strcmp(fieldName, 'Track_Parent')
    label = 'Parent ID';
    unit = '';
end
if strcmp(fieldName, 'Track_GrowthRate')
    label = 'Growth rate';
    unit = '\mum^3min^{-1}';
    range = [-0.02 0.02];
end
if strcmp(fieldName, 'Track_Velocity')
    label = 'v';
    unit = '\mums^{-1}';
end
if ~isempty(strfind(fieldName, 'Shape_Volume'))
    label = 'V';
    unit = '\mum^3';
    range = [0 2];
end
if ~isempty(strfind(fieldName, 'BoundingBox'))
    label = 'Bounding box';
    unit = 'vox';
end

if ~isempty(strfind(fieldName, 'MinBoundBox_Length'))
    label = 'Object length';
    unit = '\mum';
end
if ~isempty(strfind(fieldName, 'MinBoundBox_Height'))
    label = 'Object height';
    unit = '\mum';
end
if ~isempty(strfind(fieldName, 'MinBoundBox_Width'))
    label = 'Object width';
    unit = '\mum';
end
if ~isempty(strfind(fieldName, 'Orientation_Matrix'))
    label = 'Eigenvectors';
    unit = '';
end
if ~isempty(strfind(fieldName, 'Shape_Length'))
    label = 'Cell length';
    unit = '\mum';
    range = [1 3];
end
if ~isempty(strfind(fieldName, 'Shape_Width'))
    label = 'Cell width';
    unit = '\mum';
    range = [0.5 1];
end
if ~isempty(strfind(fieldName, 'Shape_Height'))
    label = 'Cell height';
    unit = '\mum';
    range = [0.5 1];
end
if ~isempty(strfind(fieldName, 'Shape_AspectRatio_LengthToWidth'))
    label = 'Cell length/width';
    unit = '';
    range = [0 4];
end
if ~isempty(strfind(fieldName, 'Shape_AspectRatio_HeightToWidth'))
    label = 'Cell height/width';
    unit = '';
    range = [0 2];
end
if ~isempty(strfind(fieldName, 'Biofilm_AspectRatio_HeightToLength'))
    label = 'Biofilm height/length';
    unit = '';
    range = [0 2];
end
if ~isempty(strfind(fieldName, 'Biofilm_AspectRatioGlobal_HeightToWidth'))
    label = 'Biofilm height/width';
    unit = '';
    range = [0 2];
end
if ~isempty(strfind(fieldName, 'Biofilm_AspectRatioGlobal_LengthToWidth'))
    label = 'Biofilm length/width';
    unit = '';
    range = [0 2];
end
if ~isempty(strfind(fieldName, 'Biofilm_BaseEccentricity'))
    label = 'Biofilm substrate eccentricity';
    unit = '';
    range = [0 1];
end
if ~isempty(strfind(fieldName, 'Biofilm_BaseArea'))
    label = 'Biofilm substrate area';
    unit = '\mum^2';
end
if ~isempty(strfind(fieldName, 'Biofilm_Height'))
    label = 'Height_{biofilm}';
    unit = '\mum';
end
if ~isempty(strfind(fieldName, 'Biofilm_Width'))
    label = 'Width_{biofilm}';
    unit = '\mum';
end
if ~isempty(strfind(fieldName, 'Biofilm_Length'))
    label = 'Length_{biofilm}';
    unit = '\mum';
end
if ~isempty(strfind(fieldName, 'Biofilm_Volume'))
    label = 'V_{biofilm}';
    unit = '\mum^3';
end
if ~isempty(strfind(fieldName, 'Biofilm_MeanThickness'))
    label = '\langleThickness_{biofilm}\rangle';
    unit = '\mum^2';
end
if ~isempty(strfind(fieldName, 'Biofilm_OuterSurface'))
    label = 'A_{biofilm}';
    unit = '\mum^2';
end
if ~isempty(strfind(fieldName, 'Alignment_Flow'))
    label = 'Angle({\bfcell}, {\bfflow})';
    unit = 'rad';
    range = [0+0.2 pi/2-0.2];
end
if ~isempty(strfind(fieldName, 'Alignment_Zaxis'))
    label = 'Angle({\bfcell}, {\bfz})';
    unit = 'rad';
    range = [0+0.2 pi/2-0.2];
end
if ~isempty(strfind(fieldName, 'Alignment_Radial'))
    label = 'Angle({\bfcell}, {\bfr})';
    unit = 'rad';
    range = [0+0.2 pi/2-0.2];
end
if ~isempty(strfind(fieldName, 'Convexity'))
    label = 'Convexity';
    unit = '';
    range = [0.5 1];
end
if ~isempty(strfind(fieldName, 'Cube_Surface'))
    label = 'A_{cube}';
    unit = '\mum^2';
end
if ~isempty(strfind(fieldName, 'Cube_ClassChannel'))
    label = '1: chA, 2: chB, 3: overlapping';
    unit = '';
    range = [1 3];
end
if ~isempty(strfind(fieldName, 'Cube_Overlap3D'))
    [rangeLabel, ch] = addRangeLabel(fieldName);
    label = sprintf('Overlap after merging (ch %d and ch %d)', ch(1), ch(2));
    unit = '%';
end
if ~isempty(strfind(fieldName, 'Cube_Surface'))
    label = 'A_{cube}';
    unit = '\mum^2';
end
if ~isempty(strfind(fieldName, 'Cube_VolumeFraction'))
    label = 'A_{cube}/A_{0}';
    unit = '';
end
if ~isempty(strfind(fieldName, 'Grid_ID'))
    label = 'Grid ID';
    unit = '';
end
if ~isempty(strfind(fieldName, 'Surface_LocalRoughness'))
    label = 'Local surface roughness';
    unit = '\mum^{-1}';
    rangeLabel = addRangeLabel(fieldName, 'vox');
end
if ~isempty(strfind(fieldName, 'Surface_LocalThickness'))
    label = 'Local thickness';
    unit = '\mum';
end
if ~isempty(strfind(fieldName, 'Surface_PerSubstrateArea'))
    label = 'A/A_{substrate}';
    unit = '';
end
if ~isempty(strfind(fieldName, 'Haralick'))
    idx1 = strfind(fieldName, 'Haralick_');
    idx2 = strfind(fieldName, '_range');
    label = sprintf('Texture_{%s}', fieldName(idx1+9:idx2-1));
    unit = '';
    rangeLabel = addRangeLabel(fieldName, 'vox');
end
if ~isempty(strfind(fieldName, 'Distance_ToBiofilmCenterOfMass'))
    label = 'd_{CM}';
    unit = '\mum';
    range = [0 40];
end
if ~isempty(strfind(fieldName, 'Distance_ToBiofilmCenterAtSubstrate'))
    label = 'd_{center}';
    unit = '\mum';
    range = [0 40];
end
if ~isempty(strfind(fieldName, 'Distance_ToNearestNeighbor'))
    if ~isempty(strfind(fieldName, 'ch'))
        [~, ch] = addRangeLabel(fieldName);
        label = sprintf('d_{nearest neighbor} (in ch %d)', ch);
    else
        label = 'd_{nearest neighbor}';
    end
    unit = '\mum';
    range = [0.8 2];
    rangeLabel = addRangeLabel(fieldName, [], {'ch', 'vox', 'openSide', ''});
end
if ~isempty(strfind(fieldName, 'Distance_InterCellSpacing_Mean'))
    label = 'Inter-cell-spacing';
    unit = '\mum';
    range = [1 7];
    rangeLabel = addRangeLabel(fieldName, 'vox', 'screen. range');
end
if ~isempty(strfind(fieldName, 'Distance_InterCellSpacing_Min'))
    label = 'Min. inter-cell-spacing';
    unit = '\mum';
    range = [1 7];
    rangeLabel = addRangeLabel(fieldName, 'vox', 'screen. range');
end
if ~isempty(strfind(fieldName, 'Distance_InterCellSpacing_Variance'))
    label = 'Inter-cell-spacing variance';
    unit = '\mum';
    range = [0 2];
    rangeLabel = addRangeLabel(fieldName, 'vox', 'screen. range');
end
if ~isempty(strfind(fieldName, 'Distance_ToSurface'))
    label = 'd_{surface}';
    unit = '\mum';
    range = [0 20];
    rangeLabel = addRangeLabel(fieldName, [], {'resolution', 'vox'});
end
if ~isempty(strfind(fieldName, 'Distance_ToSurfaceSideOnly'))
    label = 'd_{surface}';
    unit = '\mum';
    range = [0 20];
    rangeLabel = addRangeLabel(fieldName, [], {'resolution', 'vox', 'openSide', ''});
end
if ~isempty(strfind(fieldName, 'Distance_ToObject'))
    label = 'd_{object}';
    unit = '\mum';
    range = [0 20];
    rangeLabel = addRangeLabel(fieldName, [], {'id', ''});
end
if ~isempty(strfind(fieldName, 'Architecture_NematicOrderParameter'))
    label = 'S';
    unit = '\mum';
    range = [0 0.6];
    rangeLabel = addRangeLabel(fieldName, 'vox');
end
if ~isempty(strfind(fieldName, 'Architecture_LocalNumberDensity'))
    label = '\rho_{cells}';
    unit = 'cells\cdot\mum^{-3}';
    range = [0 1000];
    rangeLabel = addRangeLabel(fieldName, 'vox');
end
if ~isempty(strfind(fieldName, 'Architecture_LocalDensity'))
    label = '\rho_{cells}';
    unit = 'biovolume\cdot\mum^{-3}';
    range = [0 0.3];
    rangeLabel = addRangeLabel(fieldName, 'vox');
end
if ~isempty(strfind(fieldName, 'Architecture_UnitCellSize'))
    label = 'Unit cell size';
    unit = '\mum^3';
end
if ~isempty(strfind(fieldName, 'Architecture_LocalSubstrateArea'))
    label = 'A_{substrate}';
    unit = '\mum^2';
end
if ~isempty(strfind(fieldName, 'Intensity_Mean'))
    [rangeLabel, ch] = addRangeLabel(fieldName);
    label = sprintf('\\langleI_{ch%d}\\rangle', ch);
    unit = 'a.u.';
end
if ~isempty(strfind(fieldName, 'Intensity_Ratio'))
    [rangeLabel, ch] = addRangeLabel(fieldName);
    label = sprintf('\\langleI_{ch%d}/I_{ch%d}\\rangle', ch(1), ch(2));
    unit = 'a.u.';
end
if ~isempty(strfind(fieldName, 'Intensity_Shells_Mean'))
    [rangeLabel, ch] = addRangeLabel(fieldName);
    label = sprintf('\\langleI_{shell, ch%d}\\rangle', ch);
    unit = 'a.u.';
end
if ~isempty(strfind(fieldName, 'Correlation_Pearson'))
    [rangeLabel, ch] = addRangeLabel(fieldName, 'vox');
    label = sprintf('Pearson coefficient ch%d & ch%d', ch(1), ch(2));
    unit = '';
    range = [-1 1];
end
if ~isempty(strfind(fieldName, 'Correlation_Manders'))
    [rangeLabel, ch] = addRangeLabel(fieldName, 'vox');
    label = sprintf('Manders coefficient ch%d & ch%d', ch(1), ch(2));
    unit = '';
    range = [0 1];
end
if ~isempty(strfind(fieldName, 'Correlation_MandersSplit'))
    [rangeLabel, ch] = addRangeLabel(fieldName, 'vox');
    label = sprintf('Manders split coefficient ch%d & ch%d', ch(1), ch(2));
    unit = '';
    range = [0 1];
end
if ~isempty(strfind(fieldName, 'Correlation_AutoCorrelation_CorrelationLength'))
    [rangeLabel, ch] = addRangeLabel(fieldName, '');
    label = sprintf('3D correlation length ch%d', ch);
    unit = '\mum';
end
if ~isempty(strfind(fieldName, 'Correlation_AutoCorrelation_Zero3D'))
    [rangeLabel, ch] = addRangeLabel(fieldName, '');
    label = sprintf('3D correlation length (zero crossing) ch%d', ch);
    unit = '\mum';
end
if ~isempty(strfind(fieldName, 'Correlation_AutoCorrelation_Zero2D'))
    [rangeLabel, ch] = addRangeLabel(fieldName, '');
    label = sprintf('2D correlation length (zero crossing) ch%d', ch);
    unit = '\mum';
end
if ~isempty(strfind(fieldName, 'Correlation_DensityCorrelation'))
    [rangeLabel, ch] = addRangeLabel(fieldName, 'vox');
    label = sprintf('Density correlation ch%d & ch%d', ch(1), ch(2));
    unit = '';
end
if ~isempty(strfind(fieldName, 'Correlation_DensityCorrelation_binary'))
    [rangeLabel, ch] = addRangeLabel(fieldName, 'vox');
    label = sprintf('Binary density correlation ch%d & ch%d', ch(1), ch(2));
    unit = '';
end
if ~isempty(strfind(fieldName, 'Foci_Number'))
    [rangeLabel, ch] = addRangeLabel(fieldName, 'vox');
    label = sprintf('N_{foci, ch%d}', ch);
    unit = '';
end
if ~isempty(strfind(fieldName, 'Biofilm_Overlap'))
    [~, ch] = addRangeLabel(fieldName);
    label = sprintf('Overlap ch%d & ch%d', ch(1), ch(2));
    unit = '\mum^3';
end
if ~isempty(strfind(fieldName, 'Biofilm_OverlapFraction'))
    [~, ch] = addRangeLabel(fieldName);
    label = sprintf('Overlap fraction ch%d & ch%d', ch(1), ch(2));
    range = [0 1];
    unit = '';
end
if ~isempty(strfind(fieldName, 'Foci_Number'))
    [rangeLabel, ch] = addRangeLabel(fieldName, 'vox');
    label = sprintf('N_{foci, ch%d}', ch);
    unit = '';
end
if ~isempty(strfind(fieldName, 'NodesPerBranch'))
    label = 'N_{nodes}';
    unit = '';
end
if ~isempty(strfind(fieldName, 'NodesPerBranch'))
    label = 'N_{nodes} per branch';
    unit = '';
end
if ~isempty(strfind(fieldName, 'Nodes_Number'))
    label = 'N_{nodes, total}';
    unit = '';
end
if ~isempty(strfind(fieldName, 'BranchLength'))
    label = 'Branch length';
    unit = '\mum';
end
if ~isempty(strfind(fieldName, 'Branches_Number'))
    label = 'N_{branches, total}';
    unit = '';
end
if ~isempty(strfind(fieldName, 'RelativeAbundance'))
    [rangeLabel, ch] = addRangeLabel(fieldName, '');
    label = sprintf('Relative biomass abundance (ch %d)', ch);
    unit = '%';
end

if strcmp(database, 'globalMeasurements')
    averagingFields = {'mean', 'median', 'max', 'min', 'std', 'std', 'p25', 'p75'}; 
    for aF = 1:numel(averagingFields)
        if ~isempty(strfind(fieldName, ['_', averagingFields{aF}]))
            label = sprintf('%s_{%s}', label, averagingFields{aF});
        end
    end
end


label = [label, rangeLabel];
legendStr = sprintf('%s (%s)', label, unit);

if returnTrueLimits
    range = [];
end

if nargin > 1
    if isempty(range)
        
        
        Ncells = zeros(1, numel(biofilmData.data));
        for i = 1:numel(biofilmData.data)
            Ncells(i) = numel([biofilmData.data(i).(database)]);
        end
        dataValues = zeros(1, sum(Ncells));
        NcellsCum = cumsum([1 Ncells]);
        for i = 1:numel(biofilmData.data)
            try
                warning('off')
                dataValues(NcellsCum(i):NcellsCum(i+1)-1) = [biofilmData.data(i).(database).(fieldName_ori)];
                warning('on')
            catch
                
                
                
                
            end
        end
        
        switch rangeMethod
            case 1
                range = [prctile(dataValues, 1) prctile(dataValues, 99)];
            case 2
                range = [min(dataValues) max(dataValues)];
        end
    end
    
    if strcmpi(fieldName, 'time')
        range = range + biofilmData.timeShift/60/60;
    end
    
    if range(1) == 0 && range(2) == 0
        range = [range(1)-1 range(1)+1];
    end
end

if ~isempty(unit)
    unit = sprintf('(%s)', unit);
end




