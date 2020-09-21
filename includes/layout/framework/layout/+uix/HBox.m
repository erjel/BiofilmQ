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
classdef HBox < uix.Box
    
    
    
    
    
    
    
    
    
    
    
    
    properties( Access = public, Dependent, AbortSet )
        Widths 
        MinimumWidths 
    end
    
    properties( Access = protected )
        Widths_ = zeros( [0 1] ) 
        MinimumWidths_ = zeros( [0 1] ) 
    end
    
    methods
        
        function obj = HBox( varargin )
            
            
            
            
            
            
            
            
            try
                uix.set( obj, varargin{:} )
            catch e
                delete( obj )
                e.throwAsCaller()
            end
            
        end 
        
    end 
    
    methods
        
        function value = get.Widths( obj )
            
            value = obj.Widths_;
            
        end 
        
        function set.Widths( obj, value )
            
            
            if isrow( value )
                value = transpose( value );
            end
            
            
            assert( isa( value, 'double' ), 'uix:InvalidPropertyValue', ...
                'Property ''Widths'' must be of type double.' )
            assert( all( isreal( value ) ) && ~any( isinf( value ) ) && ...
                ~any( isnan( value ) ), 'uix:InvalidPropertyValue', ...
                'Elements of property ''Widths'' must be real and finite.' )
            assert( isequal( size( value ), size( obj.Contents_ ) ), ...
                'uix:InvalidPropertyValue', ...
                'Size of property ''Widths'' must match size of contents.' )
            
            
            obj.Widths_ = value;
            
            
            obj.Dirty = true;
            
        end 
        
        function value = get.MinimumWidths( obj )
            
            value = obj.MinimumWidths_;
            
        end 
        
        function set.MinimumWidths( obj, value )
            
            
            if isrow( value )
                value = transpose( value );
            end
            
            
            assert( isa( value, 'double' ), 'uix:InvalidPropertyValue', ...
                'Property ''MinimumWidths'' must be of type double.' )
            assert( all( isreal( value ) ) && ~any( isinf( value ) ) && ...
                all( value >= 0 ), 'uix:InvalidPropertyValue', ...
                'Elements of property ''MinimumWidths'' must be non-negative.' )
            assert( isequal( size( value ), size( obj.Widths_ ) ), ...
                'uix:InvalidPropertyValue', ...
                'Size of property ''MinimumWidths'' must match size of contents.' )
            
            
            obj.MinimumWidths_ = value;
            
            
            obj.Dirty = true;
            
        end 
        
    end 
    
    methods( Access = protected )
        
        function redraw( obj )
            
            
            
            
            
            bounds = hgconvertunits( ancestor( obj, 'figure' ), ...
                [0 0 1 1], 'normalized', 'pixels', obj );
            widths = obj.Widths_;
            minimumWidths = obj.MinimumWidths_;
            padding = obj.Padding_;
            spacing = obj.Spacing_;
            c = numel( widths );
            xSizes = uix.calcPixelSizes( bounds(3), widths, ...
                minimumWidths, padding, spacing );
            xPositions = [cumsum( [0; xSizes(1:c-1,:)] ) + padding + ...
                spacing * transpose( 0:c-1 ) + 1, xSizes];
            yPositions = [padding + 1, max( bounds(4) - 2 * padding, 1 )];
            yPositions = repmat( yPositions, [c 1] );
            positions = [xPositions(:,1), yPositions(:,1), ...
                xPositions(:,2), yPositions(:,2)];
            
            
            children = obj.Contents_;
            for ii = 1:numel( children )
                uix.setPosition( children(ii), positions(ii,:), 'pixels' )
            end
            
        end 
        
        function addChild( obj, child )
            
            
            
            
            
            obj.Widths_(end+1,:) = -1;
            obj.MinimumWidths_(end+1,:) = 1;
            
            
            addChild@uix.Box( obj, child )
            
        end 
        
        function removeChild( obj, child )
            
            
            
            
            
            tf = obj.Contents_ == child;
            obj.Widths_(tf,:) = [];
            obj.MinimumWidths_(tf,:) = [];
            
            
            removeChild@uix.Box( obj, child )
            
        end 
        
        function reorder( obj, indices )
            
            
            
            
            
            
            obj.Widths_ = obj.Widths_(indices,:);
            obj.MinimumWidths_ = obj.MinimumWidths_(indices,:);
            
            
            reorder@uix.Box( obj, indices )
            
        end 
        
    end 
    
end 


