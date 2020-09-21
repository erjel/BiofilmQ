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
function moveImageToChannel(path, name, originalChannel, newChannel)


    pathToDeconvolution = fullfile(path, 'deconvolved images');
    originalName = strrep(name, '_cmle', '');

    
    new = num2str(newChannel);
    if isnan(originalChannel)
        chStart = strfind(originalName, '_frame');
        newName = [originalName(1:chStart-1), '_ch', new, originalName(chStart:end)];
        originalName = lower([originalName(1:chStart-1), '_ch1', originalName(chStart:end)]);
        originalChannel = 1;
    else
        chStart = strfind(originalName, 'ch');
        underScores = strfind(originalName, '_');
        chEnd = underScores(find((underScores - chStart)>0, 1))-1;
        newName = [originalName(1:chStart+1), new, originalName(chEnd+1:end)];
    end
    
    
    
    
    try
        metadata = load(fullfile(path, strrep(originalName, '.tif', '_metadata.mat')));
        data = metadata.data;
        data.originalChannel = originalChannel;
        save(fullfile(path, strrep(newName, '.tif', '_metadata.mat')), 'data');
    catch
       fprintf('-  metadata could not be loaded. Skipping file');
       return;
    end
    
    
    im = imread3D(fullfile(pathToDeconvolution, name));
    im(:,:,2:end+1) = im;
    proj = squeeze(sum(im, 3));
    im(:,:,1) = proj/max(proj(:))*(2^16-1);
    
    
    imwrite3D(im, fullfile(path, newName));
    delete(fullfile(pathToDeconvolution, name));
    


end




