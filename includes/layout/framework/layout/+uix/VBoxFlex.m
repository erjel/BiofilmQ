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
classdef VBoxFlex < uix.VBox & uix.mixin.Flex
    
    
    
    
    
    
    
    
    
    
    
    
    
    properties( Access = public, Dependent, AbortSet )
        DividerMarkings 
    end
    
    properties( Access = private )
        RowDividers = uix.Divider.empty( [0 1] ) 
        FrontDivider 
        DividerMarkings_ = 'on' 
        MousePressListener = event.listener.empty( [0 0] ) 
        MouseReleaseListener = event.listener.empty( [0 0] ) 
        MouseMotionListener = event.listener.empty( [0 0] ) 
        ActiveDivider = 0 
        ActiveDividerPosition = [NaN NaN NaN NaN] 
        MousePressLocation = [NaN NaN] 
        BackgroundColorListener 
    end
    
    methods
        
        function obj = VBoxFlex( varargin )
            
            
            
            
            
            
            
            
            frontDivider = uix.Divider( 'Parent', obj, ...
                'Orientation', 'horizontal', ...
                'BackgroundColor', obj.BackgroundColor * 0.75, ...
                'Visible', 'off' );
            
            
            backgroundColorListener = event.proplistener( obj, ...
                findprop( obj, 'BackgroundColor' ), 'PostSet', ...
                @obj.onBackgroundColorChange );
            
            
            obj.FrontDivider = frontDivider;
            obj.BackgroundColorListener = backgroundColorListener;
            
            
            obj.Spacing = 5;
            
            
            try
                uix.set( obj, varargin{:} )
            catch e
                delete( obj )
                e.throwAsCaller()
            end
            
        end 
        
    end 
    
    methods
        
        function value = get.DividerMarkings( obj )
            
            value = obj.DividerMarkings_;
            
        end 
        
        function set.DividerMarkings( obj, value )
            
            
            assert( ischar( value ) && any( strcmp( value, {'on','off'} ) ), ...
                'uix:InvalidArgument', ...
                'Property ''DividerMarkings'' must be ''on'' or ''off'.' )
            
            
            obj.DividerMarkings_ = value;
            
            
            obj.Dirty = true;
            
        end 
        
    end 
    
    methods( Access = protected )
        
        function onMousePress( obj, source, eventData )
            
            
            
            loc = find( obj.RowDividers.isMouseOver( eventData ) );
            if isempty( loc ), return, end
            
            
            divider = obj.RowDividers(loc);
            obj.ActiveDivider = loc;
            obj.ActiveDividerPosition = divider.Position;
            root = groot();
            obj.MousePressLocation = root.PointerLocation;
            
            
            obj.updateMousePointer( source, eventData );
            
            
            frontDivider = obj.FrontDivider;
            frontDivider.Position = divider.Position;
            divider.Visible = 'off';
            frontDivider.Parent = [];
            frontDivider.Parent = obj;
            frontDivider.Visible = 'on';
            
        end 
        
        function onMouseRelease( obj, ~, ~ )
            
            
            
            loc = obj.ActiveDivider;
            if loc > 0
                root = groot();
                delta = root.PointerLocation(2) - obj.MousePressLocation(2);
                ih = loc;
                jh = loc + 1;
                ic = loc;
                jc = loc + 1;
                divider = obj.RowDividers(loc);
                contents = obj.Contents_;
                ip = uix.getPosition( contents(ic), 'pixels' );
                jp = uix.getPosition( contents(jc), 'pixels' );
                oldPixelHeights = [ip(4); jp(4)];
                minimumHeights = obj.MinimumHeights_(ih:jh,:);
                if delta < 0 
                    delta = max( delta, minimumHeights(2) - oldPixelHeights(2) );
                else 
                    delta = min( delta, oldPixelHeights(1) - minimumHeights(1) );
                end
                oldHeights = obj.Heights_(loc:loc+1);
                newPixelHeights = oldPixelHeights - delta * [1;-1];
                if oldHeights(1) < 0 && oldHeights(2) < 0 
                    newHeights = oldHeights .* newPixelHeights ./ oldPixelHeights;
                elseif oldHeights(1) < 0 && oldHeights(2) >= 0 
                    newHeights = [oldHeights(1) * newPixelHeights(1) / ...
                        oldPixelHeights(1); newPixelHeights(2)];
                elseif oldHeights(1) >= 0 && oldHeights(2) < 0 
                    newHeights = [newPixelHeights(1); oldHeights(2) * ...
                        newPixelHeights(2) / oldPixelHeights(2)];
                else 
                    newHeights = newPixelHeights;
                end
                obj.Heights_(loc:loc+1) = newHeights;
            else
                return
            end
            
            
            obj.FrontDivider.Visible = 'off';
            divider.Visible = 'on';
            
            
            obj.ActiveDivider = 0;
            obj.ActiveDividerPosition = [NaN NaN NaN NaN];
            obj.MousePressLocation = [NaN NaN];
            
            
            obj.Dirty = true;
            
        end 
        
        function onMouseMotion( obj, source, eventData )
            
            
            loc = obj.ActiveDivider;
            if loc == 0 
                obj.updateMousePointer( source, eventData );
            else 
                root = groot();
                delta = root.PointerLocation(2) - obj.MousePressLocation(2);
                ih = loc;
                jh = loc + 1;
                ic = loc;
                jc = loc + 1;
                contents = obj.Contents_;
                ip = uix.getPosition( contents(ic), 'pixels' );
                jp = uix.getPosition( contents(jc), 'pixels' );
                oldPixelHeights = [ip(4); jp(4)];
                minimumHeights = obj.MinimumHeights_(ih:jh,:);
                if delta < 0 
                    delta = max( delta, minimumHeights(2) - oldPixelHeights(2) );
                else 
                    delta = min( delta, oldPixelHeights(1) - minimumHeights(1) );
                end
                obj.FrontDivider.Position = ...
                    obj.ActiveDividerPosition + [0 delta 0 0];
            end
            
        end 
        
        function onBackgroundColorChange( obj, ~, ~ )
            
            
            backgroundColor = obj.BackgroundColor;
            highlightColor = min( [backgroundColor / 0.75; 1 1 1] );
            shadowColor = max( [backgroundColor * 0.75; 0 0 0] );
            rowDividers = obj.RowDividers;
            for ii = 1:numel( rowDividers )
                rowDivider = rowDividers(ii);
                rowDivider.BackgroundColor = backgroundColor;
                rowDivider.HighlightColor = highlightColor;
                rowDivider.ShadowColor = shadowColor;
            end
            frontDivider = obj.FrontDivider;
            frontDivider.BackgroundColor = shadowColor;
            
        end 
        
    end 
    
    methods( Access = protected )
        
        function redraw( obj )
            
            
            
            
            
            redraw@uix.VBox( obj )
            
            
            q = numel( obj.RowDividers ); 
            r = max( [numel( obj.Heights_ )-1 0] ); 
            if q < r 
                for ii = q+1:r
                    divider = uix.Divider( 'Parent', obj, ...
                        'Orientation', 'horizontal', ...
                        'BackgroundColor', obj.BackgroundColor );
                    obj.RowDividers(ii,:) = divider;
                end
            elseif q > r 
                
                delete( obj.RowDividers(r+1:q,:) )
                obj.RowDividers(r+1:q,:) = [];
                
                if r == 0 && strcmp( obj.Pointer, 'top' )
                    obj.unsetPointer()
                end
            end
            
            
            bounds = hgconvertunits( ancestor( obj, 'figure' ), ...
                [0 0 1 1], 'normalized', 'pixels', obj );
            
            
            heights = obj.Heights_;
            minimumHeights = obj.MinimumHeights_;
            padding = obj.Padding_;
            spacing = obj.Spacing_;
            
            
            xRowPositions = [padding + 1, max( bounds(3) - 2 * padding, 1 )];
            xRowPositions = repmat( xRowPositions, [r 1] );
            yRowSizes = uix.calcPixelSizes( bounds(4), heights, ...
                minimumHeights, padding, spacing );
            yRowPositions = [bounds(4) - cumsum( yRowSizes(1:r,:) ) - padding - ...
                spacing * transpose( 1:r ) + 1, repmat( spacing, [r 1] )];
            rowPositions = [xRowPositions(:,1), yRowPositions(:,1), ...
                xRowPositions(:,2), yRowPositions(:,2)];
            
            
            for ii = 1:r
                rowDivider = obj.RowDividers(ii);
                rowDivider.Position = rowPositions(ii,:);
                switch obj.DividerMarkings_
                    case 'on'
                        rowDivider.Markings = rowPositions(ii,3)/2;
                    case 'off'
                        rowDivider.Markings = zeros( [0 1] );
                end
            end
            
        end 
        
        function reparent( obj, oldFigure, newFigure )
            
            
            
            
            
            
            if isempty( newFigure )
                mousePressListener = event.listener.empty( [0 0] );
                mouseReleaseListener = event.listener.empty( [0 0] );
                mouseMotionListener = event.listener.empty( [0 0] );
            else
                mousePressListener = event.listener( newFigure, ...
                    'WindowMousePress', @obj.onMousePress );
                mouseReleaseListener = event.listener( newFigure, ...
                    'WindowMouseRelease', @obj.onMouseRelease );
                mouseMotionListener = event.listener( newFigure, ...
                    'WindowMouseMotion', @obj.onMouseMotion );
            end
            obj.MousePressListener = mousePressListener;
            obj.MouseReleaseListener = mouseReleaseListener;
            obj.MouseMotionListener = mouseMotionListener;
            
            
            reparent@uix.VBox( obj, oldFigure, newFigure )
            
            
            if ~isempty( oldFigure ) && ~strcmp( obj.Pointer, 'unset' )
                obj.unsetPointer()
            end
            
        end 
        
    end 
    
    methods( Access = protected )
        
        function updateMousePointer ( obj, source, eventData  )
            
            oldPointer = obj.Pointer;
            if any( obj.RowDividers.isMouseOver( eventData ) )
                newPointer = 'top';
            else
                newPointer = 'unset';
            end
            switch newPointer
                case oldPointer 
                    
                case 'unset' 
                    obj.unsetPointer()
                otherwise 
                    obj.setPointer( source, newPointer )
            end
            
        end 
        
    end 
    
end 


