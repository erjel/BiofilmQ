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
classdef VButtonBox < uix.ButtonBox
    
    
    
    
    
    
    
    
    
    
    
    
    
    methods
        
        function obj = VButtonBox( varargin )
            
            
            
            
            
            
            
            
            try
                uix.set( obj, varargin{:} )
            catch e
                delete( obj )
                e.throwAsCaller()
            end
            
        end 
        
    end 
    
    methods( Access = protected )
        
        function redraw( obj )
            
            
            bounds = hgconvertunits( ancestor( obj, 'figure' ), ...
                [0 0 1 1], 'normalized', 'pixels', obj );
            buttonSize = obj.ButtonSize_;
            padding = obj.Padding_;
            spacing = obj.Spacing_;
            r = numel( obj.Contents_ );
            if 2 * padding + buttonSize(1) > bounds(3)
                xSizes = repmat( uix.calcPixelSizes( bounds(3), -1, 1, ...
                    padding, spacing ), [r 1] ); 
            else
                xSizes = repmat( buttonSize(1), [r 1] );
            end
            switch obj.HorizontalAlignment
                case 'left'
                    xPositions = [repmat( padding, [r 1] ) + 1, xSizes];
                case 'center'
                    xPositions = [(bounds(3) - xSizes) / 2 + 1, xSizes];
                case 'right'
                    xPositions = [bounds(3) - xSizes - padding + 1, xSizes];
            end
            if 2 * padding + (r-1) * spacing + r * buttonSize(2) > bounds(4)
                ySizes = uix.calcPixelSizes( bounds(4), -ones( [r 1] ), ...
                    ones( [r 1] ), padding, spacing ); 
            else
                ySizes = repmat( buttonSize(2), [r 1] );
            end
            switch obj.VerticalAlignment
                case 'top'
                    yPositions = [bounds(4) - padding - cumsum( ySizes ) - ...
                        spacing * transpose( 0:r-1 ) + 1, ySizes];
                case 'middle'
                    yPositions = [bounds(4) / 2  + sum( ySizes ) / 2  + ...
                        spacing * (r-1) / 2 - cumsum( ySizes ) - ...
                        spacing * transpose( 0:r-1 ) + 1, ySizes];
                case 'bottom'
                    yPositions = [sum( ySizes ) + spacing * (r-1) - ...
                        cumsum( ySizes ) - spacing * transpose( 0:r-1 ) + ...
                        padding + 1, ySizes];
            end
            positions = [xPositions(:,1), yPositions(:,1), ...
                xPositions(:,2), yPositions(:,2)];
            
            
            children = obj.Contents_;
            for ii = 1:numel( children )
                uix.setPosition( children(ii), positions(ii,:), 'pixels' )
            end
            
        end 
        
    end 
    
end 


