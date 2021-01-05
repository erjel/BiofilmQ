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
function [objects, obj] = calculateAutocorrelation(objects, filename, handles, obj, ch_task, params)

        filename_ch1 = fullfile(handles.settings.directory, 'data', [filename(1:end-4), '_data.mat']);

        if isempty(obj{ch_task(1)})
            filename = strrep(filename_ch1, sprintf('_ch%d', params.channel), sprintf('_ch%d', ch_task(1)));
            obj{ch_task(1)} = loadObjects(filename);
        end
        
        paramsAutoCorr = struct('scaling', obj{ch_task(1)}.params.scaling_dxy/1000, 'scaleFactor', 0.5, 'dr', 1, 'dilation', 0, 'fullFrame', 0);
        
        [zero3D, zero2D, zero2D_Substrate, rVec, autocorr3D_mean, autocorr2D_mean, autocorr2D_substrate, ~, ~] = calculateAutocorrelation3D(labelmatrix(obj{ch_task(1)})>0, paramsAutoCorr);
        correlationLength3D = 2*returnCorrelationLength(rVec, autocorr3D_mean);
        correlationLength2D = 2*returnCorrelationLength(rVec, autocorr2D_mean);
        correlationLength2D_Substrate = 2*returnCorrelationLength(rVec, autocorr2D_substrate);
        
        objects.globalMeasurements.(sprintf('Biofilm_AutoCorrelation_CorrelationFcn_ch%d', ch_task(1))).rVec = rVec(1:end-1)';
        objects.globalMeasurements.(sprintf('Biofilm_AutoCorrelation_CorrelationFcn_ch%d', ch_task(1))).autocorr3D_mean = autocorr3D_mean;
        objects.globalMeasurements.(sprintf('Biofilm_AutoCorrelation_CorrelationFcn_ch%d', ch_task(1))).autocorr2D_mean = autocorr2D_mean;
        objects.globalMeasurements.(sprintf('Biofilm_AutoCorrelation_CorrelationFcn_ch%d', ch_task(1))).autocorr2D_substrate = autocorr2D_substrate;
        
        objects.globalMeasurements.(sprintf('Biofilm_AutoCorrelation_CorrelationLength2D_ch%d', ch_task(1))) = correlationLength2D;
        objects.globalMeasurements.(sprintf('Biofilm_AutoCorrelation_CorrelationLength2D_Substrate_ch%d', ch_task(1))) = correlationLength2D_Substrate;
        objects.globalMeasurements.(sprintf('Biofilm_AutoCorrelation_CorrelationLength3D_ch%d', ch_task(1))) = correlationLength3D;
        objects.globalMeasurements.(sprintf('Biofilm_AutoCorrelation_Zero3D_ch%d', ch_task(1))) = zero3D;
        objects.globalMeasurements.(sprintf('Biofilm_AutoCorrelation_Zero2D_ch%d', ch_task(1))) = zero2D;
        objects.globalMeasurements.(sprintf('Biofilm_AutoCorrelation_Zero2D_Substrate_ch%d', ch_task(1))) = zero2D_Substrate;
end


