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
function cdata = loadIcon( filename, bgcol )


narginchk( 1, 2 )
if nargin < 2
    bgcol = get( 0, 'DefaultUIControlBackgroundColor' );
end

thisDir = fileparts( mfilename( 'fullpath' ) );
iconDir = fullfile( thisDir, 'Resources' );
if exist( filename, 'file' )
    [cdata, map, alpha] = imread( filename );
elseif exist( fullfile( iconDir, filename ), 'file' )
    [cdata, map, alpha] = imread( fullfile( iconDir, filename ) );
else
    error( 'uix:FileNotFound', 'Cannot open file ''%s''.', filename )
end

if ~isempty( map )
    cdata = ind2rgb( cdata, map );
end

cdata = convertToDouble( cdata );

[rows, cols, ~] = size( cdata );
if ~isempty( alpha )
    
    
    alpha = convertToDouble( alpha );
    f = find( alpha==0 );
    if ~isempty( f )
        cdata(f) = NaN;
        cdata(f + rows*cols) = NaN;
        cdata(f + 2*rows*cols) = NaN;
    end
    
    f = find( alpha(:)>0 & alpha(:)<1 );
    if ~isempty(f)
        cdata(f) = cdata(f).*alpha(f) + bgcol(1)*(1-alpha(f));
        cdata(f + rows*cols) = cdata(f + rows*cols).*alpha(f) + bgcol(2)*(1-alpha(f));
        cdata(f + 2*rows*cols) = cdata(f + 2*rows*cols).*alpha(f) + bgcol(3)*(1-alpha(f));
    end
    
else
    
    
    f = find( cdata(:,:,1)==0 & cdata(:,:,2)==1 & cdata(:,:,3)==0 );
    cdata(f) = NaN;
    cdata(f + rows*cols) = NaN;
    cdata(f + 2*rows*cols) = NaN;
    
end

end 


function cdata = convertToDouble( cdata )

switch lower( class( cdata ) )
    case 'double'
        
    case 'single'
        cdata = double( cdata );
    case 'uint8'
        cdata = double( cdata ) / 255;
    case 'uint16'
        cdata = double( cdata ) / 65535;
    case 'int8'
        cdata = ( double( cdata ) + 128 ) / 255;
    case 'int16'
        cdata = ( double( cdata ) + 32768 ) / 65535;
    otherwise
        error( 'uix:InvalidArgument', ...
            'Image data of type ''%s'' is not supported.', class( cdata ) )
end

end 


