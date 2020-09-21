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
function pSizes = calcPixelSizes( pTotal, mSizes, pMinima, pPadding, pSpacing )


pSizes = NaN( size( mSizes ) ); 
n = numel( mSizes ); 

a = mSizes >= 0; 
pSizes(a) = max( mSizes(a), pMinima(a) );

while true
    
    u = isnan( pSizes ); 
    pUnsolvedTotal = pTotal - max( (n-1), 0 ) * pSpacing ...
        - 2 * sign( n ) * pPadding - sum( pSizes(~u) );
    pUnsolvedSizes = mSizes(u) / sum( mSizes(u) ) * pUnsolvedTotal;
    pUnsolvedMinima = pMinima(u);
    s = pUnsolvedSizes < pUnsolvedMinima; 
    if any( s )
        pUnsolvedSizes(s) = pUnsolvedMinima(s);
        pUnsolvedSizes(~s) = NaN;
        pSizes(u) = pUnsolvedSizes;
        
    else
        pSizes(u) = pUnsolvedSizes;
        break 
    end
    
end

end 


