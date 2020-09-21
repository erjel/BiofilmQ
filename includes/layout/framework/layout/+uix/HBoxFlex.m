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
classdef HBoxFlex < uix.HBox & uix.mixin.Flex
    
    
    
    
    
    
    
    
    
    
    
    
    
    properties( Access = public, Dependent, AbortSet )
        DividerMarkings 
    end
    
    properties( Access = private )
        ColumnDividers = uix.Divider.empty( [0 1] ) 
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
        
        function obj = HBoxFlex( varargin )
            
            
            
            
            
            
            
            
            frontDivider = uix.Divider( 'Parent', obj, ...
                'Orientation', 'vertical', ...
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
            
            
            
            loc = find( obj.ColumnDividers.isMouseOver( eventData ) );
            if isempty( loc ), return, end
            
            
            divider = obj.ColumnDividers(loc);
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
                delta = root.PointerLocation(1) - obj.MousePressLocation(1);
                iw = loc;
                jw = loc + 1;
                ic = loc;
                jc = loc + 1;
                divider = obj.ColumnDividers(loc);
                contents = obj.Contents_;
                ip = uix.getPosition( contents(ic), 'pixels' );
                jp = uix.getPosition( contents(jc), 'pixels' );
                oldPixelWidths = [ip(3); jp(3)];
                minimumWidths = obj.MinimumWidths_(iw:jw,:);
                if delta < 0 
                    delta = max( delta, minimumWidths(1) - oldPixelWidths(1) );
                else 
                    delta = min( delta, oldPixelWidths(2) - minimumWidths(2) );
                end
                oldWidths = obj.Widths_(iw:jw);
                newPixelWidths = oldPixelWidths + delta * [1;-1];
                if oldWidths(1) < 0 && oldWidths(2) < 0 
                    newWidths = oldWidths .* newPixelWidths ./ oldPixelWidths;
                elseif oldWidths(1) < 0 && oldWidths(2) >= 0 
                    newWidths = [oldWidths(1) * newPixelWidths(1) / ...
                        oldPixelWidths(1); newPixelWidths(2)];
                elseif oldWidths(1) >= 0 && oldWidths(2) < 0 
                    newWidths = [newPixelWidths(1); oldWidths(2) * ...
                        newPixelWidths(2) / oldPixelWidths(2)];
                else 
                    newWidths = newPixelWidths;
                end
                obj.Widths_(iw:jw) = newWidths;
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
                delta = root.PointerLocation(1) - obj.MousePressLocation(1);
                iw = loc;
                jw = loc + 1;
                ic = loc;
                jc = loc + 1;
                contents = obj.Contents_;
                ip = uix.getPosition( contents(ic), 'pixels' );
                jp = uix.getPosition( contents(jc), 'pixels' );
                oldPixelWidths = [ip(3); jp(3)];
                minimumWidths = obj.MinimumWidths_(iw:jw,:);
                if delta < 0 
                    delta = max( delta, minimumWidths(1) - oldPixelWidths(1) );
                else 
                    delta = min( delta, oldPixelWidths(2) - minimumWidths(2) );
                end
                obj.FrontDivider.Position = ...
                    obj.ActiveDividerPosition + [delta 0 0 0];
            end
            
        end 
        
        function onBackgroundColorChange( obj, ~, ~ )
            
            
            backgroundColor = obj.BackgroundColor;
            highlightColor = min( [backgroundColor / 0.75; 1 1 1] );
            shadowColor = max( [backgroundColor * 0.75; 0 0 0] );
            columnDividers = obj.ColumnDividers;
            for jj = 1:numel( columnDividers )
                columnDivider = columnDividers(jj);
                columnDivider.BackgroundColor = backgroundColor;
                columnDivider.HighlightColor = highlightColor;
                columnDivider.ShadowColor = shadowColor;
            end
            frontDivider = obj.FrontDivider;
            frontDivider.BackgroundColor = shadowColor;
            
        end 
        
    end 
    
    methods( Access = protected )
        
        function redraw( obj )
            
            
            
            
            
            redraw@uix.HBox( obj )
            
            
            b = numel( obj.ColumnDividers ); 
            c = max( [numel( obj.Widths_ )-1 0] ); 
            if b < c 
                for ii = b+1:c
                    divider = uix.Divider( 'Parent', obj, ...
                        'Orientation', 'vertical', ...
                        'BackgroundColor', obj.BackgroundColor );
                    obj.ColumnDividers(ii,:) = divider;
                end
            elseif b > c 
                
                delete( obj.ColumnDividers(c+1:b,:) )
                obj.ColumnDividers(c+1:b,:) = [];
                
                if c == 0 && strcmp( obj.Pointer, 'left' )
                    obj.unsetPointer()
                end
            end
            
            
            bounds = hgconvertunits( ancestor( obj, 'figure' ), ...
                [0 0 1 1], 'normalized', 'pixels', obj );
            
            
            widths = obj.Widths_;
            minimumWidths = obj.MinimumWidths_;
            padding = obj.Padding_;
            spacing = obj.Spacing_;
            
            
            xColumnSizes = uix.calcPixelSizes( bounds(3), widths, ...
                minimumWidths, padding, spacing );
            xColumnPositions = [cumsum( xColumnSizes(1:c,:) ) + padding + ...
                spacing * transpose( 0:c-1 ) + 1, repmat( spacing, [c 1] )];
            yColumnPositions = [padding + 1, max( bounds(4) - 2 * padding, 1 )];
            yColumnPositions = repmat( yColumnPositions, [c 1] );
            columnPositions = [xColumnPositions(:,1), yColumnPositions(:,1), ...
                xColumnPositions(:,2), yColumnPositions(:,2)];
            
            
            for ii = 1:c
                columnDivider = obj.ColumnDividers(ii);
                columnDivider.Position = columnPositions(ii,:);
                switch obj.DividerMarkings_
                    case 'on'
                        columnDivider.Markings = columnPositions(ii,4)/2;
                    case 'off'
                        columnDivider.Markings = zeros( [0 1] );
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
            
            
            reparent@uix.HBox( obj, oldFigure, newFigure )
            
            
            if ~isempty( oldFigure ) && ~strcmp( obj.Pointer, 'unset' )
                obj.unsetPointer()
            end
            
        end 
        
    end 
    
    methods( Access = protected )
        
        function updateMousePointer ( obj, source, eventData  )
            
            oldPointer = obj.Pointer;
            if any( obj.ColumnDividers.isMouseOver( eventData ) )
                newPointer = 'left';
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


