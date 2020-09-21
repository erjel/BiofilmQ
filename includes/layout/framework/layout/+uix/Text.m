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
classdef ( Hidden ) Text < matlab.mixin.SetGet
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    properties( Dependent )
        BackgroundColor
    end
    
    properties( Dependent, SetAccess = private )
        BeingDeleted
    end
    
    properties( Dependent )
        Callback
        DeleteFcn
        Enable
    end
    
    properties( Dependent, SetAccess = private )
        Extent
    end
    
    properties( Dependent )
        FontAngle
        FontName
        FontSize
        FontUnits
        FontWeight
        ForegroundColor
        HandleVisibility
        HorizontalAlignment
        Parent
        Position
        String
        Tag
        TooltipString
    end
    
    properties( Dependent, SetAccess = private )
        Type
    end
    
    properties( Dependent )
        UIContextMenu
        Units
        UserData
        VerticalAlignment
        Visible
    end
    
    properties( Access = private )
        Container 
        Checkbox 
        Screen 
        VerticalAlignment_ = 'top' 
        Dirty = false 
        FigureObserver 
        FigureListener 
    end
    
    properties( Constant, Access = private )
        Margin = checkBoxLabelOffset() 
    end
    
    methods
        
        function obj = Text( varargin )
            
            
            
            
            
            
            container = uicontainer( 'Parent', [], ...
                'Units', get( 0, 'DefaultUicontrolUnits' ), ...
                'Position', get( 0, 'DefaultUicontrolPosition' ), ...
                'SizeChangedFcn', @obj.onResized );
            checkbox = uicontrol( 'Parent', container, ...
                'HandleVisibility', 'off', ...
                'Style', 'checkbox', 'Units', 'pixels', ...
                'HorizontalAlignment', 'center', ...
                'Enable', 'inactive' );
            screen = uicontrol( 'Parent', container, ...
                'HandleVisibility', 'off', ...
                'Style', 'text', 'Units', 'pixels' );
            
            
            figureObserver = uix.FigureObserver( container );
            figureListener = event.listener( figureObserver, ...
                'FigureChanged', @obj.onFigureChanged );
            
            
            obj.Container = container;
            obj.Checkbox = checkbox;
            obj.Screen = screen;
            obj.FigureObserver = figureObserver;
            obj.FigureListener = figureListener;
            
            
            try
                uix.set( obj, varargin{:} )
            catch e
                delete( obj )
                e.throwAsCaller()
            end
            
        end 
        
        function delete( obj )
            
            
            delete( obj.Container )
            
        end 
        
    end 
    
    methods
        
        function value = get.BackgroundColor( obj )
            
            value = obj.Checkbox.BackgroundColor;
            
        end 
        
        function set.BackgroundColor( obj, value )
            
            obj.Container.BackgroundColor = value;
            obj.Checkbox.BackgroundColor = value;
            obj.Screen.BackgroundColor = value;
            
        end 
        
        function value = get.BeingDeleted( obj )
            
            value = obj.Checkbox.BeingDeleted;
            
        end 
        
        function value = get.Callback( obj )
            
            value = obj.Checkbox.Callback;
            
        end 
        
        function set.Callback( obj, value )
            
            obj.Checkbox.Callback = value;
            
        end 
        
        function value = get.DeleteFcn( obj )
            
            value = obj.Checkbox.DeleteFcn;
            
        end 
        
        function set.DeleteFcn( obj, value )
            
            obj.Checkbox.DeleteFcn = value;
            
        end 
        
        function value = get.Enable( obj )
            
            value = obj.Checkbox.Enable;
            
        end 
        
        function set.Enable( obj, value )
            
            obj.Checkbox.Enable = value;
            
        end 
        
        function value = get.Extent( obj )
            
            value = obj.Checkbox.Extent;
            
        end 
        
        function value = get.FontAngle( obj )
            
            value = obj.Checkbox.FontAngle;
            
        end 
        
        function set.FontAngle( obj, value )
            
            
            obj.Checkbox.FontAngle = value;
            
            
            obj.setDirty()
            
        end 
        
        function value = get.FontName( obj )
            
            value = obj.Checkbox.FontName;
            
        end 
        
        function set.FontName( obj, value )
            
            
            obj.Checkbox.FontName = value;
            
            
            obj.setDirty()
            
        end 
        
        function value = get.FontSize( obj )
            
            value = obj.Checkbox.FontSize;
            
        end 
        
        function set.FontSize( obj, value )
            
            
            obj.Checkbox.FontSize = value;
            
            
            obj.setDirty()
            
        end 
        
        function value = get.FontUnits( obj )
            
            value = obj.Checkbox.FontUnits;
            
        end 
        
        function set.FontUnits( obj, value )
            
            obj.Checkbox.FontUnits = value;
            
        end 
        
        function value = get.FontWeight( obj )
            
            value = obj.Checkbox.FontWeight;
            
        end 
        
        function set.FontWeight( obj, value )
            
            
            obj.Checkbox.FontWeight = value;
            
            
            obj.setDirty()
            
        end 
        
        function value = get.ForegroundColor( obj )
            
            value = obj.Checkbox.ForegroundColor;
            
        end 
        
        function set.ForegroundColor( obj, value )
            
            obj.Checkbox.ForegroundColor = value;
            
        end 
        
        function value = get.HandleVisibility( obj )
            
            value = obj.Container.HandleVisibility;
            
        end 
        
        function set.HandleVisibility( obj, value )
            
            obj.Container.HandleVisibility = value;
            
        end 
        
        function value = get.HorizontalAlignment( obj )
            
            value = obj.Checkbox.HorizontalAlignment;
            
        end 
        
        function set.HorizontalAlignment( obj, value )
            
            
            obj.Checkbox.HorizontalAlignment = value;
            
            
            obj.setDirty()
            
        end 
        
        function value = get.Parent( obj )
            
            value = obj.Container.Parent;
            
        end 
        
        function set.Parent( obj, value )
            
            obj.Container.Parent = value;
            
        end 
        
        function value = get.Position( obj )
            
            value = obj.Container.Position;
            
        end 
        
        function set.Position( obj, value )
            
            obj.Container.Position = value;
            
        end 
        
        function value = get.String( obj )
            
            value = obj.Checkbox.String;
            
        end 
        
        function set.String( obj, value )
            
            
            obj.Checkbox.String = value;
            
            
            obj.setDirty()
            
        end 
        
        function value = get.Tag( obj )
            
            value = obj.Checkbox.Tag;
            
        end 
        
        function set.Tag( obj, value )
            
            obj.Checkbox.Tag = value;
            
        end 
        
        function value = get.TooltipString( obj )
            
            value = obj.Checkbox.TooltipString;
            
        end 
        
        function set.TooltipString( obj, value )
            
            obj.Checkbox.TooltipString = value;
            
        end 
        
        function value = get.Type( obj )
            
            value = obj.Checkbox.Type;
            
        end 
        
        function value = get.UIContextMenu( obj )
            
            value = obj.Checkbox.UIContextMenu;
            
        end 
        
        function set.UIContextMenu( obj, value )
            
            obj.Checkbox.UIContextMenu = value;
            
        end 
        
        function value = get.Units( obj )
            
            value = obj.Container.Units;
            
        end 
        
        function set.Units( obj, value )
            
            obj.Container.Units = value;
            
        end 
        
        function value = get.UserData( obj )
            
            value = obj.Checkbox.UserData;
            
        end 
        
        function set.UserData( obj, value )
            
            obj.Checkbox.UserData = value;
            
        end 
        
        function value = get.VerticalAlignment( obj )
            
            value = obj.VerticalAlignment_;
            
        end 
        
        function set.VerticalAlignment( obj, value )
            
            
            assert( ischar( value ) && ...
                any( strcmp( value, {'top','middle','bottom'} ) ), ...
                'uix:InvalidPropertyValue', ...
                'Property ''VerticalAlignment'' must be ''top'', ''middle'' or ''bottom''.' )
            
            
            obj.VerticalAlignment_ = value;
            
            
            obj.setDirty()
            
        end 
        
        function value = get.Visible( obj )
            
            value = obj.Container.Visible;
            
        end 
        
        function set.Visible( obj, value )
            
            obj.Container.Visible = value;
            
        end 
        
    end 
    
    methods( Access = private )
        
        function onResized( obj, ~, ~ )
            
            
            
            obj.redraw()
            
        end 
        
        function onFigureChanged( obj, ~, eventData )
            
            
            if isempty( eventData.OldFigure ) && ...
                    ~isempty( eventData.NewFigure ) && obj.Dirty
                obj.redraw()
            end
            
        end 
        
    end 
    
    methods( Access = private )
        
        function setDirty( obj )
            
            
            
            
            
            
            if isempty( obj.FigureObserver.Figure )
                obj.Dirty = true; 
            else
                obj.Dirty = false; 
                obj.redraw() 
            end
            
        end 
        
        function redraw( obj )
            
            
            
            
            
            
            
            c = obj.Container;
            b = obj.Checkbox;
            s = obj.Screen;
            bo = hgconvertunits( ancestor( obj, 'figure' ), ...
                [0 0 1 1], 'normalized', 'pixels', c ); 
            m = obj.Margin;
            e = b.Extent;
            switch b.HorizontalAlignment
                case 'left'
                    x = 1 - m;
                case 'center'
                    x = 1 + bo(3)/2 - e(3)/2 - m;
                case 'right'
                    x = 1 + bo(3) - e(3) - m;
            end
            w = e(3) + m;
            switch obj.VerticalAlignment_
                case 'top'
                    y = 1 + bo(4) - e(4);
                case 'middle'
                    y = 1 + bo(4)/2 - e(4)/2;
                case 'bottom'
                    y = 1;
            end
            h = e(4);
            b.Position = [x y w h];
            s.Position = [x y m h];
            
        end 
        
    end 
    
end 

function o = checkBoxLabelOffset()

if ismac
    o = 20;
else
    if verLessThan( 'MATLAB', '8.6' ) 
        o = 18;
    else
        o = 16;
    end
end

end 


