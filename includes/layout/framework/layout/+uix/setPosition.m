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
function setPosition( o, p, u )


if ~isempty( findprop( o, 'Units' ) )
    o.Units = u;
else
    assert( strcmp( u, 'pixels' ), 'uix:InvalidOperation', ...
        'Objects without property ''Units'' have units of ''pixels''.' )
end

if ~isempty( findprop( o, 'ActivePositionProperty' ) )
    switch o.ActivePositionProperty
        case 'position'
            o.Position = p;
        case 'outerposition'
            o.OuterPosition = p;
        otherwise
            error( 'uix:InvalidState', ...
                'Unknown value ''%s'' for property ''ActivePositionProperty'' of %s.', ...
                o.ActivePositionProperty, class( o ) )
    end
else
    o.Position = p;
end

end 


