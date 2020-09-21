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
function imwrite3D(f, filename_out, fmt, silent)

if nargin < 3
    f=uint16(f); 
else
    if isempty(fmt)
        f=uint16(f);
    else
        switch fmt
            case 'uint8'
                f=uint8(f);
            case 'logical'
                f=logical(f);
        end
    end
end

if nargin < 4
    silent = 0;
end

if ~silent
    ticValue = displayTime;
    textprogressbar('      ');
end

try
    saveastiff(f, filename_out);
catch
    
    z = size(f,3);
    slice1=f(:,:,1);
    
    imwrite(slice1,filename_out);
    
    if ~silent
        textprogressbar(1);
    end
    
    
    try
        
        for i = 2:z
            slice=f(:,:,i);
            
            imwrite(slice,filename_out,'WriteMode','append');
            
            if ~mod(i,10) && ~silent
                textprogressbar(i/z*100);
            end
        end
        
    catch
        if ~silent
            textprogressbar(100);
            textprogressbar(' Failed. \n');
        end
        
        try
            fprintf('         -> error writing file, trying again');
            for i = 2:z
                slice=f(:,:,i);
                
                imwrite(slice,filename_out,'WriteMode','append');
                
                if ~mod(i,10)
                    textprogressbar(i/z*100);
                end
            end
            
        catch
            textprogressbar(100);
            textprogressbar(' Failed. \n');
            
            warning('         -> file could not be written!');
        end
        
    end
end

if ~silent
    textprogressbar(100);
    textprogressbar(' Done.');
    displayTime(ticValue);
end







