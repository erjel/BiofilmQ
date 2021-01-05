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
function imgfilter = registerAndCropImage(imgfilter, params, metadata)


if params.declumpingMethod~=3
   method = 'linear'; 
else
    method = 'nearest';
end

if params.imageRegistration
    try
        if size(imgfilter, 3) == 1
            imgfilter = performImageAlignment2D(imgfilter, metadata, method, 1);
        else
            imgfilter = performImageAlignment3D(imgfilter, metadata, method, 1);
        end
    catch
        disp(['Image is not registered!']);
        uiwait(msgbox(' - WARNING: Image is not registered! Cannot continue.', 'Error', 'error', 'modal'));
        displayStatus(handles, 'Processing cancelled!', 'red');
        return;
    end
end

if ~isempty(params.cropRange)
    params.cropRangeAfterRegistration = params.cropRange;
    
    if params.imageRegistration
        correctCropRange = 0;
        
        params.cropRangeAfterRegistration(1:2) = params.cropRange(1:2);
        
        
        
        if params.fixedOutputSize
            if params.cropRangeAfterRegistration(1) < params.registrationReferenceCropping(1)
                params.cropRangeAfterRegistration(1) = params.registrationReferenceCropping(1);
                correctCropRange = 1;
            end
            if params.cropRangeAfterRegistration(2) < params.registrationReferenceCropping(2)
                params.cropRangeAfterRegistration(2) = params.registrationReferenceCropping(2);
                correctCropRange = 1;
            end
            if params.cropRangeAfterRegistration(1) + params.cropRange(3) > params.registrationReferenceCropping(1) + params.registrationReferenceCropping(3)
                params.cropRangeAfterRegistration(3) = params.registrationReferenceCropping(1)+params.registrationReferenceCropping(3)-params.cropRange(1);
                correctCropRange = 1;
            end
            if params.cropRangeAfterRegistration(2) + params.cropRange(4) > params.registrationReferenceCropping(2) + params.registrationReferenceCropping(4)
                params.cropRangeAfterRegistration(4) = params.registrationReferenceCropping(2)+params.registrationReferenceCropping(4)-params.cropRange(2);
                correctCropRange = 1;
            end
        end
       
        if params.cropRange(3)+params.cropRangeAfterRegistration(1) > size(imgfilter,2)
            params.cropRangeAfterRegistration(3) = size(imgfilter,1)-params.cropRangeAfterRegistration(1);
            correctCropRange = 1;
        end
        
        if params.cropRange(4)+params.cropRangeAfterRegistration(2) > size(imgfilter,1)
            params.cropRangeAfterRegistration(4) = size(imgfilter,1)-params.cropRangeAfterRegistration(2);
            correctCropRange = 1;
        end
        
        if correctCropRange
            fprintf(' -> WARNING: crop range was confined by image border or crop range of reference frame to [%d %d %d %d]\n',  params.cropRangeAfterRegistration)
        end
    else
        
    end
    
    imgfilter = imgfilter(params.cropRangeAfterRegistration(2):params.cropRangeAfterRegistration(2)+params.cropRangeAfterRegistration(4), ...
        params.cropRangeAfterRegistration(1):params.cropRangeAfterRegistration(1)+params.cropRangeAfterRegistration(3),:);
else
    if params.imageRegistration && params.fixedOutputSize && ~isempty(params.registrationReferenceCropping)
        params.cropRange = params.registrationReferenceCropping;
        params.cropRangeAfterRegistration = params.cropRange;
        fprintf(' -> WARNING: crop range was confined by crop range of reference frame to [%d %d %d %d]\n',  params.cropRangeAfterRegistration)
        
        imgfilter = imgfilter(params.cropRangeAfterRegistration(2):params.cropRangeAfterRegistration(2)+params.cropRangeAfterRegistration(4), ...
            params.cropRangeAfterRegistration(1):params.cropRangeAfterRegistration(1)+params.cropRangeAfterRegistration(3),:);
    end
end

end




