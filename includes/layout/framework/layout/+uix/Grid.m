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
classdef Grid < uix.Box
    
    
    
    
    
    
    
    
    
    
    
    
    properties( Access = public, Dependent, AbortSet )
        Widths 
        MinimumWidths 
        Heights 
        MinimumHeights 
    end
    
    properties( Access = protected )
        Widths_ = zeros( [0 1] ) 
        MinimumWidths_ = zeros( [0 1] ) 
        Heights_ = zeros( [0 1] ) 
        MinimumHeights_ = zeros( [0 1] ) 
    end
    
    methods
        
        function obj = Grid( varargin )
            
            
            
            
            
            
            
            
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
            n = numel( obj.Contents_ );
            b = numel( obj.Widths_ );
            q = numel( obj.Heights_ );
            c = numel( value );
            r = ceil( n / c );
            if c < min( [1 n] )
                error( 'uix:InvalidPropertyValue' , ...
                    'Property ''Widths'' must be non-empty for non-empty contents.' )
            elseif ceil( n / r ) < c
                error( 'uix:InvalidPropertyValue' , ...
                    'Size of property ''Widths'' must not lead to empty columns.' )
            elseif c > n
                error( 'uix:InvalidPropertyValue' , ...
                    'Size of property ''Widths'' must be no larger than size of contents.' )
            end
            
            
            obj.Widths_ = value;
            if c < b 
                obj.MinimumWidths_(c+1:end,:) = [];
                if r > q 
                    obj.Heights_(end+1:r,:) = -1;
                    obj.MinimumHeights_(end+1:r,:) = 1;
                end
            elseif c > b 
                obj.MinimumWidths_(end+1:c,:) = -1;
                if r < q 
                    obj.Heights_(r+1:end,:) = [];
                    obj.MinimumHeights_(r+1:end,:) = [];
                end
            end
            
            
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
            n = numel( obj.Contents_ );
            b = numel( obj.Widths_ );
            q = numel( obj.Heights_ );
            r = numel( value );
            c = ceil( n / r );
            if r < min( [1 n] )
                error( 'uix:InvalidPropertyValue' , ...
                    'Property ''Heights'' must be non-empty for non-empty contents.' )
            elseif r > n
                error( 'uix:InvalidPropertyValue' , ...
                    'Size of property ''Heights'' must be no larger than size of contents.' )
            end
            
            
            obj.Heights_ = value;
            if r < q 
                obj.MinimumHeights_(r+1:end,:) = [];
                if c > b 
                    obj.Widths_(end+1:c,:) = -1;
                    obj.MinimumWidths_(end+1:c,:) = 1;
                end
            elseif r > q 
                obj.MinimumHeights_(end+1:r,:) = 1;
                if c < b 
                    obj.Widths_(c+1:end,:) = [];
                    obj.MinimumWidths_(c+1:end,:) = [];
                end
            end
            
            
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
            widths = obj.Widths_;
            minimumWidths = obj.MinimumWidths_;
            heights = obj.Heights_;
            minimumHeights = obj.MinimumHeights_;
            padding = obj.Padding_;
            spacing = obj.Spacing_;
            c = numel( widths );
            r = numel( heights );
            n = numel( obj.Contents_ );
            xSizes = uix.calcPixelSizes( bounds(3), widths, ...
                minimumWidths, padding, spacing );
            xPositions = [cumsum( [0; xSizes(1:end-1,:)] ) + padding + ...
                spacing * transpose( 0:c-1 ) + 1, xSizes];
            ySizes = uix.calcPixelSizes( bounds(4), heights, ...
                minimumHeights, padding, spacing );
            yPositions = [bounds(4) - cumsum( ySizes ) - padding - ...
                spacing * transpose( 0:r-1 ) + 1, ySizes];
            [iy, ix] = ind2sub( [r c], transpose( 1:n ) );
            positions = [xPositions(ix,1), yPositions(iy,1), ...
                xPositions(ix,2), yPositions(iy,2)];
            
            
            children = obj.Contents_;
            for ii = 1:numel( children )
                uix.setPosition( children(ii), positions(ii,:), 'pixels' )
            end
            
        end 
        
        function addChild( obj, child )
            
            
            
            
            
            n = numel( obj.Contents_ );
            c = numel( obj.Widths_ );
            r = numel( obj.Heights_ );
            if n == 0
                obj.Widths_(end+1,:) = -1;
                obj.MinimumWidths_(end+1,:) = 1;
                obj.Heights_(end+1,:) = -1;
                obj.MinimumHeights_(end+1,:) = 1;
            elseif ceil( (n+1)/r ) > c
                obj.Widths_(end+1,:) = -1;
                obj.MinimumWidths_(end+1,:) = 1;
            end
            
            
            addChild@uix.Box( obj, child )
            
        end 
        
        function removeChild( obj, child )
            
            
            
            
            
            n = numel( obj.Contents_ );
            c = numel( obj.Widths_ );
            r = numel( obj.Heights_ );
            if n == 1
                obj.Widths_(end,:) = [];
                obj.MinimumWidths_(end,:) = [];
                obj.Heights_(end,:) = [];
                obj.MinimumHeights_(end,:) = [];
            elseif c == 1
                obj.Heights_(end,:) = [];
                obj.MinimumHeights_(end,:) = [];
            elseif ceil( (n-1)/r ) < c
                obj.Widths_(end,:) = [];
                obj.MinimumWidths_(end,:) = [];
            end
            
            
            removeChild@uix.Box( obj, child )
            
        end 
        
    end 
    
end 


