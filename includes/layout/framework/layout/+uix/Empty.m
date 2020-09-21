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
function obj = Empty( varargin )


obj = matlab.ui.container.internal.UIContainer( 'Tag', 'empty', varargin{:} );

p = addprop( obj, 'ParentListener' );
p.Hidden = true;

obj.ParentListener = event.proplistener( obj, ...
    findprop( obj, 'Parent' ), 'PostSet', @(~,~)onParentChanged(obj) );

p = addprop( obj, 'ParentColorListener' );
p.Hidden = true;

updateColor( obj )
updateListener( obj )

end 

function onParentChanged( obj )

updateColor( obj )
updateListener( obj )

end 

function onParentColorChanged( obj )

updateColor( obj )

end 

function name = getColorProperty( obj )

names = {'Color','BackgroundColor'}; 
for ii = 1:numel( names ) 
    name = names{ii};
    if isprop( obj, name )
        return
    end
end
error( 'Cannot find color property for %s.', class( obj ) )

end 

function updateColor( obj )

parent = obj.Parent;
if isempty( parent ), return, end
property = getColorProperty( parent );
color = parent.( property );
try
    obj.BackgroundColor = color;
catch e
    warning( e.identifier, e.message ) 
end

end 

function updateListener( obj )

parent = obj.Parent;
if isempty( parent )
    obj.ParentColorListener = [];
else
    property = getColorProperty( parent );
    obj.ParentColorListener = event.proplistener( parent, ...
        findprop( parent, property ), 'PostSet', ...
        @(~,~)onParentColorChanged(obj) );
end

end 


