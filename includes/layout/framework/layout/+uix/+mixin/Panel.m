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
classdef Panel < uix.mixin.Container
    
    
    
    
    
    
    
    
    properties( Access = public, Dependent, AbortSet )
        Selection 
    end
    
    properties( Access = protected )
        Selection_ = 0 
    end
    
    properties( Access = protected )
        G1218142 = false 
    end
    
    events( NotifyAccess = protected )
        SelectionChanged 
    end
    
    methods
        
        function value = get.Selection( obj )
            
            value = obj.Selection_;
            
        end 
        
        function set.Selection( obj, value )
            
            
            assert( isa( value, 'double' ), 'uix:InvalidPropertyValue', ...
                'Property ''Selection'' must be of type double.' )
            assert( isequal( size( value ), [1 1] ), ...
                'uix:InvalidPropertyValue', ...
                'Property ''Selection'' must be scalar.' )
            assert( isreal( value ) && rem( value, 1 ) == 0, ...
                'uix:InvalidPropertyValue', ...
                'Property ''Selection'' must be an integer.' )
            n = numel( obj.Contents_ );
            if n == 0
                assert( value == 0, 'uix:InvalidPropertyValue', ...
                    'Property ''Selection'' must be 0 for a container with no children.' )
            else
                assert( value >= 1 && value <= n, 'uix:InvalidPropertyValue', ...
                    'Property ''Selection'' must be between 1 and the number of children.' )
            end
            
            
            oldSelection = obj.Selection_;
            newSelection = value;
            obj.Selection_ = newSelection;
            
            
            obj.showSelection()
            
            
            obj.Dirty = true;
            
            
            notify( obj, 'SelectionChanged', ...
                uix.SelectionData( oldSelection, newSelection ) )
            
        end 
        
    end 
    
    methods( Access = protected )
        
        function addChild( obj, child )
            
            
            if verLessThan( 'MATLAB', '8.5' ) && strcmp( child.Visible, 'off' )
                obj.G1218142 = true;
            end
            
            
            oldSelection = obj.Selection_;
            newSelection = numel( obj.Contents_ ) + 1;
            obj.Selection_ = newSelection;
            
            
            addChild@uix.mixin.Container( obj, child )
            
            
            obj.showSelection()
            
            
            obj.notify( 'SelectionChanged', ...
                uix.SelectionData( oldSelection, newSelection ) )
            
        end 
        
        function removeChild( obj, child )
            
            
            contents = obj.Contents_;
            index = find( contents == child );
            oldSelection = obj.Selection_;
            if index < oldSelection
                newSelection = oldSelection - 1;
            elseif index == oldSelection
                newSelection = min( oldSelection, numel( contents ) - 1 );
            else 
                newSelection = oldSelection;
            end
            obj.Selection_ = newSelection;
            
            
            removeChild@uix.mixin.Container( obj, child )
            
            
            obj.showSelection()
            
            
            if oldSelection ~= newSelection
                obj.notify( 'SelectionChanged', ...
                    uix.SelectionData( oldSelection, newSelection ) )
            end
            
        end 
        
        function reorder( obj, indices )
            
            
            
            
            
            
            selection = obj.Selection_;
            if selection ~= 0
                obj.Selection_ = find( indices == selection );
            end
            
            
            reorder@uix.mixin.Container( obj, indices )
            
        end 
        
        function showSelection( obj )
            
            
            
            
            
            
            selection = obj.Selection_;
            children = obj.Contents_;
            for ii = 1:numel( children )
                child = children(ii);
                if ii == selection
                    if obj.G1218142
                        warning( 'uix:G1218142', ...
                            'Selected child of %s is not visible due to bug G1218142.  The child will become visible at the next redraw.', ...
                            class( obj ) )
                        obj.G1218142 = false;
                    else
                        child.Visible = 'on';
                    end
                    if isa( child, 'matlab.graphics.axis.Axes' )
                        child.ContentsVisible = 'on';
                    end
                else
                    child.Visible = 'off';
                    if isa( child, 'matlab.graphics.axis.Axes' )
                        child.ContentsVisible = 'off';
                    end
                    
                    margin = 1000;
                    if isa( child, 'matlab.graphics.axis.Axes' ) ...
                            && strcmp(child.ActivePositionProperty, 'outerposition' )
                        child.OuterPosition(1) = -child.OuterPosition(3)-margin;
                    else
                        child.Position(1) = -child.Position(3)-margin;
                    end
                end
            end
            
        end 
        
    end 
    
end 


