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
classdef BoxPanel < uix.Panel & uix.mixin.Panel
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    properties( Dependent )
        TitleColor 
        Minimized 
        MinimizeFcn 
        Docked 
        DockFcn 
        HelpFcn 
        CloseRequestFcn 
    end
    
    properties( Dependent, SetAccess = private )
        TitleHeight 
    end
    
    properties( Access = private )
        TitleBox 
        TitleText 
        EmptyTitle = '' 
        TitleAccess = 'public' 
        TitleHeight_ = -1 
        MinimizeButton 
        DockButton 
        HelpButton 
        CloseButton 
        Docked_ = true 
        Minimized_ = false 
    end
    
    properties( Constant, Access = private )
        NullTitle = char.empty( [2 0] ) 
        BlankTitle = ' ' 
    end
    
    properties
        MaximizeTooltipString = 'Expand this panel' 
        MinimizeTooltipString = 'Collapse this panel' 
        UndockTooltipString = 'Undock this panel' 
        DockTooltipString = 'Dock this panel' 
        HelpTooltipString = 'Get help on this panel' 
        CloseTooltipString = 'Close this panel' 
    end
    
    methods
        
        function obj = BoxPanel( varargin )
            
            
            
            
            
            
            
            
            foregroundColor = [1 1 1];
            backgroundColor = [0.05 0.25 0.5];
            
            
            obj.ForegroundColor = foregroundColor;
            
            
            titleBox = uix.HBox( 'Internal', true, 'Parent', obj, ...
                'Units', 'pixels', 'BackgroundColor', backgroundColor );
            titleText = uix.Text( 'Parent', titleBox, ...
                'ForegroundColor', foregroundColor, ...
                'BackgroundColor', backgroundColor, ...
                'String', obj.BlankTitle, 'HorizontalAlignment', 'left' );
            
            
            minimizeButton = uix.Text( ...
                'ForegroundColor', foregroundColor, ...
                'BackgroundColor', backgroundColor, ...
                'FontWeight', 'bold', 'Enable', 'on' );
            dockButton = uix.Text( ...
                'ForegroundColor', foregroundColor, ...
                'BackgroundColor', backgroundColor, ...
                'FontWeight', 'bold', 'Enable', 'on' );
            helpButton = uix.Text( ...
                'ForegroundColor', foregroundColor, ...
                'BackgroundColor', backgroundColor, ...
                'FontWeight', 'bold', 'String', '?', ...
                'TooltipString', obj.HelpTooltipString, 'Enable', 'on' );
            closeButton = uix.Text( ...
                'ForegroundColor', foregroundColor, ...
                'BackgroundColor', backgroundColor, ...
                'FontWeight', 'bold', 'String', char( 215 ), ...
                'TooltipString', obj.CloseTooltipString, 'Enable', 'on' );
            
            
            obj.Title = obj.NullTitle;
            obj.TitleBox = titleBox;
            obj.TitleText = titleText;
            obj.MinimizeButton = minimizeButton;
            obj.DockButton = dockButton;
            obj.HelpButton = helpButton;
            obj.CloseButton = closeButton;
            
            
            addlistener( obj, 'BorderWidth', 'PostSet', ...
                @obj.onBorderWidthChanged );
            addlistener( obj, 'BorderType', 'PostSet', ...
                @obj.onBorderTypeChanged );
            addlistener( obj, 'FontAngle', 'PostSet', ...
                @obj.onFontAngleChanged );
            addlistener( obj, 'FontName', 'PostSet', ...
                @obj.onFontNameChanged );
            addlistener( obj, 'FontSize', 'PostSet', ...
                @obj.onFontSizeChanged );
            addlistener( obj, 'FontUnits', 'PostSet', ...
                @obj.onFontUnitsChanged );
            addlistener( obj, 'FontWeight', 'PostSet', ...
                @obj.onFontWeightChanged );
            addlistener( obj, 'ForegroundColor', 'PostSet', ...
                @obj.onForegroundColorChanged );
            addlistener( obj, 'Title', 'PreGet', ...
                @obj.onTitleReturning );
            addlistener( obj, 'Title', 'PostGet', ...
                @obj.onTitleReturned );
            addlistener( obj, 'Title', 'PostSet', ...
                @obj.onTitleChanged );
            
            
            obj.redrawButtons()
            
            
            try
                uix.set( obj, varargin{:} )
            catch e
                delete( obj )
                e.throwAsCaller()
            end
            
        end 
        
    end 
    
    methods
        
        function value = get.TitleColor( obj )
            
            value = obj.TitleBox.BackgroundColor;
            
        end 
        
        function set.TitleColor( obj, value )
            
            
            obj.TitleBox.BackgroundColor = value;
            obj.TitleText.BackgroundColor = value;
            obj.MinimizeButton.BackgroundColor = value;
            obj.DockButton.BackgroundColor = value;
            obj.HelpButton.BackgroundColor = value;
            obj.CloseButton.BackgroundColor = value;
            
        end 
        
        function value = get.CloseRequestFcn( obj )
            
            value = obj.CloseButton.Callback;
            
        end 
        
        function set.CloseRequestFcn( obj, value )
            
            
            obj.CloseButton.Callback = value;
            
            
            obj.redrawButtons()
            
        end 
        
        function value = get.DockFcn( obj )
            
            value = obj.DockButton.Callback;
            
        end 
        
        function set.DockFcn( obj, value )
            
            
            obj.DockButton.Callback = value;
            
            
            obj.redrawButtons()
            
        end 
        
        function value = get.HelpFcn( obj )
            
            value = obj.HelpButton.Callback;
            
        end 
        
        function set.HelpFcn( obj, value )
            
            
            obj.HelpButton.Callback = value;
            
            
            obj.redrawButtons()
            
        end 
        
        function value = get.MinimizeFcn( obj )
            
            value = obj.MinimizeButton.Callback;
            
        end 
        
        function set.MinimizeFcn( obj, value )
            
            
            obj.MinimizeButton.Callback = value;
            obj.TitleText.Callback = value;
            if isempty( value )
                obj.TitleText.Enable = 'inactive';
            else
                obj.TitleText.Enable = 'on';
            end
            
            
            obj.redrawButtons()
            
        end 
        
        function value = get.Docked( obj )
            
            value = obj.Docked_;
            
        end 
        
        function set.Docked( obj, value )
            
            
            assert( islogical( value ) && isequal( size( value ), [1 1] ), ...
                'uix:InvalidPropertyValue', ...
                'Property ''Docked'' must be true or false.' )
            
            
            obj.Docked_ = value;
            
            
            obj.redrawButtons()
            
        end 
        
        function value = get.Minimized( obj )
            
            value = obj.Minimized_;
            
        end 
        
        function set.Minimized( obj, value )
            
            
            assert( islogical( value ) && isequal( size( value ), [1 1] ), ...
                'uix:InvalidPropertyValue', ...
                'Property ''Minimized'' must be true or false.' )
            
            
            obj.Minimized_ = value;
            
            
            obj.showSelection()
            
            
            obj.Dirty = true;
            
        end 
        
        function value = get.TitleHeight( obj )
            
            value = obj.TitleBox.Position(4);
            
        end 
        
        function set.MaximizeTooltipString( obj, value )
            
            
            assert( ischar( value ), ...
                'uix:InvalidPropertyValue', ...
                'Property ''MaximizeTooltipString'' must be a string.' )
            
            
            obj.MaximizeTooltipString = value;
            
            
            obj.redrawButtons()
            
        end 
        
        function set.MinimizeTooltipString( obj, value )
            
            
            assert( ischar( value ), ...
                'uix:InvalidPropertyValue', ...
                'Property ''MinimizeTooltipString'' must be a string.' )
            
            
            obj.MinimizeTooltipString = value;
            
            
            obj.redrawButtons()
            
        end 
        
        function set.UndockTooltipString( obj, value )
            
            
            assert( ischar( value ), ...
                'uix:InvalidPropertyValue', ...
                'Property ''UndockTooltipString'' must be a string.' )
            
            
            obj.UndockTooltipString = value;
            
            
            obj.redrawButtons()
            
        end 
        
        function set.DockTooltipString( obj, value )
            
            
            assert( ischar( value ), ...
                'uix:InvalidPropertyValue', ...
                'Property ''DockTooltipString'' must be a string.' )
            
            
            obj.DockTooltipString = value;
            
            
            obj.redrawButtons()
            
        end 
        
        function set.HelpTooltipString( obj, value )
            
            
            assert( ischar( value ), ...
                'uix:InvalidPropertyValue', ...
                'Property ''HelpTooltipString'' must be a string.' )
            
            
            obj.HelpTooltipString = value;
            
            
            obj.redrawButtons()
            
        end 
        
        function set.CloseTooltipString( obj, value )
            
            
            assert( ischar( value ), ...
                'uix:InvalidPropertyValue', ...
                'Property ''CloseTooltipString'' must be a string.' )
            
            obj.CloseTooltipString = value;
            
            
            obj.redrawButtons()
            
        end 
        
    end 
    
    methods( Access = private )
        
        function onBorderWidthChanged( obj, ~, ~ )
            
            
            obj.Dirty = true;
            
        end 
        
        function onBorderTypeChanged( obj, ~, ~ )
            
            
            obj.Dirty = true;
            
        end 
        
        function onFontAngleChanged( obj, ~, ~ )
            
            obj.TitleText.FontAngle = obj.FontAngle;
            
        end 
        
        function onFontNameChanged( obj, ~, ~ )
            
            
            obj.TitleText.FontName = obj.FontName;
            
            
            obj.TitleHeight_ = -1;
            obj.Dirty = true;
            
        end 
        
        function onFontSizeChanged( obj, ~, ~ )
            
            
            fontSize = obj.FontSize;
            obj.TitleText.FontSize = fontSize;
            obj.HelpButton.FontSize = fontSize;
            obj.CloseButton.FontSize = fontSize;
            obj.DockButton.FontSize = fontSize;
            obj.MinimizeButton.FontSize = fontSize;
            
            
            obj.TitleHeight_ = -1;
            obj.Dirty = true;
            
        end 
        
        function onFontUnitsChanged( obj, ~, ~ )
            
            fontUnits = obj.FontUnits;
            obj.TitleText.FontUnits = fontUnits;
            obj.HelpButton.FontUnits = fontUnits;
            obj.CloseButton.FontUnits = fontUnits;
            obj.DockButton.FontUnits = fontUnits;
            obj.MinimizeButton.FontUnits = fontUnits;
            
        end 
        
        function onFontWeightChanged( obj, ~, ~ )
            
            obj.TitleText.FontWeight = obj.FontWeight;
            
        end 
        
        function onForegroundColorChanged( obj, ~, ~ )
            
            foregroundColor = obj.ForegroundColor;
            obj.TitleText.ForegroundColor = foregroundColor;
            obj.MinimizeButton.ForegroundColor = foregroundColor;
            obj.DockButton.ForegroundColor = foregroundColor;
            obj.HelpButton.ForegroundColor = foregroundColor;
            obj.CloseButton.ForegroundColor = foregroundColor;
            
        end 
        
        function onTitleReturning( obj, ~, ~ )
            
            if strcmp( obj.TitleAccess, 'public' )
                
                obj.TitleAccess = 'private'; 
                if ischar( obj.EmptyTitle )
                    obj.Title = obj.EmptyTitle;
                else
                    obj.Title = obj.TitleText.String;
                end
                
            end
            
        end 
        
        function onTitleReturned( obj, ~, ~ )
            
            obj.Title = obj.NullTitle; 
            obj.TitleAccess = 'public'; 
            
        end 
        
        function onTitleChanged( obj, ~, ~ )
            
            if strcmp( obj.TitleAccess, 'public' )
                
                
                obj.TitleAccess = 'private'; 
                title = obj.Title;
                if isempty( title )
                    obj.EmptyTitle = title; 
                    obj.TitleText.String = obj.BlankTitle; 
                else
                    obj.EmptyTitle = []; 
                    obj.TitleText.String = title; 
                end
                obj.Title = obj.NullTitle; 
                obj.TitleAccess = 'public'; 
                
                
                obj.TitleHeight_ = -1;
                obj.Dirty = true;
                
            end
            
        end 
        
    end 
    
    methods( Access = protected )
        
        function redraw( obj )
            
            
            
            
            
            
            
            bounds = hgconvertunits( ancestor( obj, 'figure' ), ...
                [0 0 1 1], 'normalized', 'pixels', obj );
            tX = 1;
            tW = max( bounds(3), 1 );
            tH = obj.TitleHeight_; 
            if tH == -1 
                tH = ceil( obj.TitleText.Extent(4) );
                obj.TitleHeight_ = tH; 
            end
            tY = 1 + bounds(4) - tH;
            p = obj.Padding_;
            cX = 1 + p;
            cW = max( bounds(3) - 2 * p, 1 );
            cH = max( bounds(4) - tH - 2 * p, 1 );
            cY = tY - p - cH;
            contentsPosition = [cX cY cW cH];
            
            
            selection = obj.Selection_;
            if selection ~= 0
                uix.setPosition( obj.Contents_(selection), contentsPosition, 'pixels' )
            end
            obj.TitleBox.Position = [tX tY tW tH];
            obj.redrawButtons()
            
        end 
        
        function showSelection( obj )
            
            
            
            
            
            
            showSelection@uix.mixin.Panel( obj )
            
            
            selection = obj.Selection_;
            if selection ~= 0 && obj.Minimized_
                child = obj.Contents_(selection);
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
    
    methods( Access = private )
        
        function redrawButtons( obj )
            
            
            
            
            
            
            
            
            box = obj.TitleBox;
            titleText = obj.TitleText;
            minimizeButton = obj.MinimizeButton;
            dockButton = obj.DockButton;
            helpButton = obj.HelpButton;
            closeButton = obj.CloseButton;
            
            
            titleText.Parent = [];
            minimizeButton.Parent = [];
            dockButton.Parent = [];
            helpButton.Parent = [];
            closeButton.Parent = [];
            
            
            titleText.Parent = box;
            minimize = ~isempty( obj.MinimizeFcn );
            if minimize
                minimizeButton.Parent = box;
                box.Widths(end) = minimizeButton.Extent(3);
            end
            dock = ~isempty( obj.DockFcn );
            if dock
                dockButton.Parent = box;
                box.Widths(end) = dockButton.Extent(3);
            end
            help = ~isempty( obj.HelpFcn );
            if help
                helpButton.Parent = box;
                helpButton.TooltipString = obj.HelpTooltipString;
                box.Widths(end) = helpButton.Extent(3);
            end
            close = ~isempty( obj.CloseRequestFcn );
            if close
                closeButton.Parent = box;
                closeButton.TooltipString = obj.CloseTooltipString;
                box.Widths(end) = closeButton.Extent(3);
            end
            
            
            if obj.Minimized_
                minimizeButton.String = char( 9662 );
                minimizeButton.TooltipString = obj.MaximizeTooltipString;
            else
                minimizeButton.String = char( 9652 );
                minimizeButton.TooltipString = obj.MinimizeTooltipString;
            end
            if obj.Docked_
                dockButton.String = char( 8599 );
                dockButton.TooltipString = obj.UndockTooltipString;
            else
                dockButton.String = char( 8600 );
                dockButton.TooltipString = obj.DockTooltipString;
            end
            
        end 
        
    end 
    
end 


