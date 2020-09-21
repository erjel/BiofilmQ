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
classdef VBox < uix.Box
    
    
    
    
    
    
    
    
    
    
    
    
    properties( Access = public, Dependent, AbortSet )
        Heights 
        MinimumHeights 
    end
    
    properties( Access = protected )
        Heights_ = zeros( [0 1] ) 
        MinimumHeights_ = zeros( [0 1] ) 
    end
    
    methods
        
        function obj = VBox( varargin )
            
            
            
            
            
            
            
            
            try
                uix.set( obj, varargin{:} )
            catch e
                delete( obj )
                e.throwAsCaller()
            end
            
        end 
        
    end 
    
    methods
        
        function value = get.Heights( obj )
            
            value = obj.Heights_;
            
        end 
        
        function set.Heights( obj, value )
            
            
            if isrow( value )
                value = transpose( value );
            end
            
            
            assert( isa( value, 'double' ), 'uix:InvalidPropertyValue', ...
                'Property ''Heights'' must be of type double.' )
            assert( all( isreal( value ) ) && ~any( isinf( value ) ) && ...
                ~any( isnan( value ) ), 'uix:InvalidPropertyValue', ...
                'Elements of property ''Heights'' must be real and finite.' )
            assert( isequal( size( value ), size( obj.Contents_ ) ), ...
                'uix:InvalidPropertyValue', ...
                'Size of property ''Heights'' must match size of contents.' )
            
            
            obj.Heights_ = value;
            
            
            obj.Dirty = true;
            
        end 
        
        function value = get.MinimumHeights( obj )
            
            value = obj.MinimumHeights_;
            
        end 
        
        function set.MinimumHeights( obj, value )
            
            
            if isrow( value )
                value = transpose( value );
            end
            
            
            assert( isa( value, 'double' ), 'uix:InvalidPropertyValue', ...
                'Property ''MinimumHeights'' must be of type double.' )
            assert( all( isreal( value ) ) && ~any( isinf( value ) ) && ...
                all( value >= 0 ), 'uix:InvalidPropertyValue', ...
                'Elements of property ''MinimumHeights'' must be non-negative.' )
            assert( isequal( size( value ), size( obj.Heights_ ) ), ...
                'uix:InvalidPropertyValue', ...
                'Size of property ''MinimumHeights'' must match size of contents.' )
            
            
            obj.MinimumHeights_ = value;
            
            
            obj.Dirty = true;
            
        end 
        
    end 
    
    methods( Access = protected )
        
        function redraw( obj )
            
            
            
            
            
            bounds = hgconvertunits( ancestor( obj, 'figure' ), ...
                [0 0 1 1], 'normalized', 'pixels', obj );
            heights = obj.Heights_;
            minimumHeights = obj.MinimumHeights_;
            padding = obj.Padding_;
            spacing = obj.Spacing_;
            r = numel( heights );
            xPositions = [padding + 1, max( bounds(3) - 2 * padding, 1 )];
            xPositions = repmat( xPositions, [r 1] );
            ySizes = uix.calcPixelSizes( bounds(4), heights, ...
                minimumHeights, padding, spacing );
            yPositions = [bounds(4) - cumsum( ySizes ) - padding - ...
                spacing * transpose( 0:r-1 ) + 1, ySizes];
            positions = [xPositions(:,1), yPositions(:,1), ...
                xPositions(:,2), yPositions(:,2)];
            
            
            children = obj.Contents_;
            for ii = 1:numel( children )
                uix.setPosition( children(ii), positions(ii,:), 'pixels' )
            end
            
        end 
        
        function addChild( obj, child )
            
            
            
            
            
            obj.Heights_(end+1,:) = -1;
            obj.MinimumHeights_(end+1,:) = 1;
            
            
            addChild@uix.Box( obj, child )
            
        end 
        
        function removeChild( obj, child )
            
            
            
            
            
            tf = obj.Contents_ == child;
            obj.Heights_(tf,:) = [];
            obj.MinimumHeights_(tf,:) = [];
            
            
            removeChild@uix.Box( obj, child )
            
        end 
        
        function reorder( obj, indices )
            
            
            
            
            
            
            obj.Heights_ = obj.Heights_(indices,:);
            obj.MinimumHeights_ = obj.MinimumHeights_(indices,:);
            
            
            reorder@uix.Box( obj, indices )
            
        end 
        
    end 
    
end 


