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
classdef TabPanel < uix.Container & uix.mixin.Panel
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    properties( Access = public, Dependent, AbortSet )
        FontAngle 
        FontName 
        FontSize 
        FontWeight 
        FontUnits 
        ForegroundColor 
        HighlightColor 
        ShadowColor 
    end
    
    properties
        SelectionChangedFcn = '' 
    end
    
    properties( Access = public, Dependent, AbortSet )
        TabEnables 
        TabLocation 
        TabTitles 
        TabContextMenus 
        TabWidth 
    end
    
    properties( Access = private )
        FontAngle_ = get( 0, 'DefaultUicontrolFontAngle' ) 
        FontName_ = get( 0, 'DefaultUicontrolFontName' ) 
        FontSize_ = get( 0, 'DefaultUicontrolFontSize' ) 
        FontWeight_ = get( 0, 'DefaultUicontrolFontWeight' ) 
        FontUnits_ = get( 0, 'DefaultUicontrolFontUnits' ) 
        ForegroundColor_ = get( 0, 'DefaultUicontrolForegroundColor' ) 
        HighlightColor_ = [1 1 1] 
        ShadowColor_ = [0.7 0.7 0.7] 
        ParentBackgroundColor = get( 0, 'DefaultUicontrolForegroundColor' ) 
        Tabs = gobjects( [0 1] ) 
        TabListeners = event.listener.empty( [0 1] ) 
        TabLocation_ = 'top' 
        TabHeight = -1 
        TabWidth_ = 50 
        Dividers 
        BackgroundColorListener 
        SelectionChangedListener 
        ParentListener 
        ParentBackgroundColorListener 
    end
    
    properties( Access = private, Constant )
        FontNames = listfonts() 
        DividerMask = uix.TabPanel.getDividerMask() 
        DividerWidth = 8 
        TabMinimumHeight = 9 
        Tint = 0.85 
    end
    
    methods
        
        function obj = TabPanel( varargin )
            
            
            
            
            
            
            
            
            dividers = matlab.ui.control.UIControl( 'Internal', true, ...
                'Parent', obj, 'Units', 'pixels', 'Style', 'checkbox',...
                'Tag', 'TabPanelDividers' );
            
            
            backgroundColorListener = event.proplistener( obj, ...
                findprop( obj, 'BackgroundColor' ), 'PostSet', ...
                @obj.onBackgroundColorChange );
            selectionChangedListener = event.listener( obj, ...
                'SelectionChanged', @obj.onSelectionChanged );
            parentListener = event.proplistener( obj, ...
                findprop( obj, 'Parent' ), 'PostSet', ...
                @obj.onParentChanged );
            
            
            obj.Dividers = dividers;
            obj.BackgroundColorListener = backgroundColorListener;
            obj.SelectionChangedListener = selectionChangedListener;
            obj.ParentListener = parentListener;
            
            
            try
                uix.set( obj, varargin{:} )
            catch e
                delete( obj )
                e.throwAsCaller()
            end
            
        end 
        
    end 
    
    methods
        
        function value = get.FontAngle( obj )
            
            value = obj.FontAngle_;
            
        end 
        
        function set.FontAngle( obj, value )
            
            
            assert( ischar( value ) && any( strcmp( value, {'normal','italic','oblique'} ) ), ...
                'uix:InvalidPropertyValue', ...
                'Property ''FontAngle'' must be ''normal'', ''italic'' or ''oblique''.' )
            
            
            obj.FontAngle_ = value;
            
            
            tabs = obj.Tabs;
            n = numel( tabs );
            for ii = 1:n
                tab = tabs(ii);
                tab.FontAngle = value;
            end
            
            
            obj.TabHeight = -1;
            obj.Dirty = true;
            
        end 
        
        function value = get.FontName( obj )
            
            value = obj.FontName_;
            
        end 
        
        function set.FontName( obj, value )
            
            
            assert( ischar( value ) && any( strcmp( value, obj.FontNames ) ), ...
                'uix:InvalidPropertyValue', ...
                'Property ''FontName'' must be a valid font name.' )
            
            
            obj.FontName_ = value;
            
            
            tabs = obj.Tabs;
            n = numel( tabs );
            for ii = 1:n
                tab = tabs(ii);
                tab.FontName = value;
            end
            
            
            obj.TabHeight = -1;
            obj.Dirty = true;
            
        end 
        
        function value = get.FontSize( obj )
            
            value = obj.FontSize_;
            
        end 
        
        function set.FontSize( obj, value )
            
            
            assert( isa( value, 'double' ) && isscalar( value ) && ...
                isreal( value ) && ~isinf( value ) && ...
                ~isnan( value ) && value > 0, ...
                'uix:InvalidPropertyValue', ...
                'Property ''FontSize'' must be a positive scalar.' )
            
            
            obj.FontSize_ = value;
            
            
            tabs = obj.Tabs;
            n = numel( tabs );
            for ii = 1:n
                tab = tabs(ii);
                tab.FontSize = value;
            end
            
            
            obj.TabHeight = -1;
            obj.Dirty = true;
            
        end 
        
        function value = get.FontWeight( obj )
            
            value = obj.FontWeight_;
            
        end 
        
        function set.FontWeight( obj, value )
            
            
            assert( ischar( value ) && any( strcmp( value, {'normal','bold'} ) ), ...
                'uix:InvalidPropertyValue', ...
                'Property ''FontWeight'' must be ''normal'' or ''bold''.' )
            
            
            obj.FontWeight_ = value;
            
            
            tabs = obj.Tabs;
            n = numel( tabs );
            for ii = 1:n
                tab = tabs(ii);
                tab.FontWeight = value;
            end
            
            
            obj.TabHeight = -1;
            obj.Dirty = true;
            
        end 
        
        function value = get.FontUnits( obj )
            
            value = obj.FontUnits_;
            
        end 
        
        function set.FontUnits( obj, value )
            
            
            assert( ischar( value ) && ...
                any( strcmp( value, {'inches','centimeters','points','pixels'} ) ), ...
                'uix:InvalidPropertyValue', ...
                'Property ''FontUnits'' must be ''inches'', ''centimeters'', ''points'' or ''pixels''.' )
            
            
            oldUnits = obj.FontUnits_;
            oldSize = obj.FontSize_;
            newUnits = value;
            newSize = oldSize * convert( oldUnits ) / convert( newUnits );
            
            
            obj.FontSize_ = newSize;
            obj.FontUnits_ = newUnits;
            
            
            tabs = obj.Tabs;
            n = numel( tabs );
            for ii = 1:n
                tab = tabs(ii);
                tab.FontUnits = newUnits;
            end
            
            
            obj.TabHeight = -1;
            obj.Dirty = true;
            
            function factor = convert( units )
                
                
                
                
                
                
                persistent SCREEN_PIXELS_PER_INCH
                if isequal( SCREEN_PIXELS_PER_INCH, [] ) 
                    SCREEN_PIXELS_PER_INCH = get( 0, 'ScreenPixelsPerInch' );
                end
                
                switch units
                    case 'inches'
                        factor = 72;
                    case 'centimeters'
                        factor = 72 / 2.54;
                    case 'points'
                        factor = 1;
                    case 'pixels'
                        factor = 72 / SCREEN_PIXELS_PER_INCH;
                end
                
            end 
            
        end 
        
        function value = get.ForegroundColor( obj )
            
            value = obj.ForegroundColor_;
            
        end 
        
        function set.ForegroundColor( obj, value )
            
            
            assert( isnumeric( value ) && isequal( size( value ), [1 3] ) && ...
                all( isreal( value ) ) && all( value >= 0 ) && all( value <= 1 ), ...
                'uix:InvalidPropertyValue', ...
                'Property ''ForegroundColor'' must be an RGB triple.' )
            
            
            obj.ForegroundColor_ = value;
            
            
            tabs = obj.Tabs;
            n = numel( tabs );
            for ii = 1:n
                tab = tabs(ii);
                tab.ForegroundColor = value;
            end
            
        end 
        
        function value = get.HighlightColor( obj )
            
            value = obj.HighlightColor_;
            
        end 
        
        function set.HighlightColor( obj, value )
            
            
            assert( isnumeric( value ) && isequal( size( value ), [1 3] ) && ...
                all( isreal( value ) ) && all( value >= 0 ) && all( value <= 1 ), ...
                'uix:InvalidPropertyValue', ...
                'Property ''HighlightColor'' must be an RGB triple.' )
            
            
            obj.HighlightColor_ = value;
            
            
            obj.Dirty = true;
            
        end 
        
        function set.SelectionChangedFcn( obj, value )
            
            
            if ischar( value ) 
                
            elseif isa( value, 'function_handle' ) && ...
                    isequal( size( value ), [1 1] ) 
                
            elseif iscell( value ) && ndims( value ) == 2 && ...
                    size( value, 1 ) == 1 && size( value, 2 ) > 0 && ...
                    isa( value{1}, 'function_handle' ) && ...
                    isequal( size( value{1} ), [1 1] ) 
                
            else
                error( 'uix:InvalidPropertyValue', ...
                    'Property ''SelectionChangedFcn'' must be a valid callback.' )
            end
            
            
            obj.SelectionChangedFcn = value;
            
        end 
        
        function value = get.ShadowColor( obj )
            
            value = obj.ShadowColor_;
            
        end 
        
        function set.ShadowColor( obj, value )
            
            
            assert( isnumeric( value ) && isequal( size( value ), [1 3] ) && ...
                all( isreal( value ) ) && all( value >= 0 ) && all( value <= 1 ), ...
                'uix:InvalidPropertyValue', ...
                'Property ''ShadowColor'' must be an RGB triple.' )
            
            
            obj.ShadowColor_ = value;
            
            
            obj.Dirty = true;
            
        end 
        
        function value = get.TabEnables( obj )
            
            value = get( obj.Tabs, {'Enable'} );
            value(strcmp( value, 'inactive' )) = {'on'};
            
        end 
        
        function set.TabEnables( obj, value )
            
            
            if isrow( value )
                value = transpose( value );
            end
            
            
            tabs = obj.Tabs;
            tabListeners = obj.TabListeners;
            
            
            assert( iscellstr( value ) && ...
                isequal( size( value ), size( tabs ) ) && ...
                all( strcmp( value, 'on' ) | strcmp( value, 'off' ) ), ...
                'uix:InvalidPropertyValue', ...
                'Property ''TabEnables'' should be a cell array of strings ''on'' or ''off'', one per tab.' )
            
            
            tf = strcmp( value, 'on' );
            value(tf) = {'inactive'};
            for ii = 1:numel( tabs )
                tabs(ii).Enable = value{ii};
                tabListeners(ii).Enabled = tf(ii);
            end
            
            
            obj.showSelection()
            
            
            obj.Dirty = true;
            
        end 
        
        function value = get.TabLocation( obj )
            
            value = obj.TabLocation_;
            
        end 
        
        function set.TabLocation( obj, value )
            
            
            assert( ischar( value ) && ...
                any( strcmp( value, {'top','bottom'} ) ), ...
                'uix:InvalidPropertyValue', ...
                'Property ''TabLocation'' should be ''top'' or ''bottom''.' )
            
            
            obj.TabLocation_ = value;
            
            
            obj.Dirty = true;
            
        end 
        
        function value = get.TabTitles( obj )
            
            value = get( obj.Tabs, {'String'} );
            
        end 
        
        function set.TabTitles( obj, value )
            
            
            if isrow( value )
                value = transpose( value );
            end
            
            
            tabs = obj.Tabs;
            
            
            assert( iscellstr( value ) && ...
                isequal( size( value ), size( tabs ) ), ...
                'uix:InvalidPropertyValue', ...
                'Property ''TabTitles'' should be a cell array of strings, one per tab.' )
            
            
            n = numel( tabs );
            for ii = 1:n
                tabs(ii).String = value{ii};
            end
            
            
            obj.TabHeight = -1;
            obj.Dirty = true;
            
        end 
        
        function value = get.TabContextMenus( obj )
            
            tabs = obj.Tabs;
            n = numel( tabs );
            value = cell( [n 1] );
            for ii = 1:n
                value{ii} = tabs(ii).UIContextMenu;
            end
            
        end 
        
        function set.TabContextMenus( obj, value )
            
            tabs = obj.Tabs;
            n = numel( tabs );
            for ii = 1:n
                tabs(ii).UIContextMenu = value{ii};
            end
            
        end 
        
        function value = get.TabWidth( obj )
            
            value = obj.TabWidth_;
            
        end 
        
        function set.TabWidth( obj, value )
            
            
            assert( isa( value, 'double' ) && isscalar( value ) && ...
                isreal( value ) && ~isinf( value ) && ...
                ~isnan( value ) && value ~= 0, ...
                'uix:InvalidPropertyValue', ...
                'Property ''TabWidth'' must be a non-zero scalar.' )
            
            
            obj.TabWidth_ = value;
            
            
            obj.Dirty = true;
            
        end 
        
    end 
    
    methods( Access = protected )
        
        function redraw( obj )
            
            
            bounds = hgconvertunits( ancestor( obj, 'figure' ), ...
                [0 0 1 1], 'normalized', 'pixels', obj );
            w = ceil( bounds(1) + bounds(3) ) - floor( bounds(1) ); 
            h = ceil( bounds(2) + bounds(4) ) - floor( bounds(2) ); 
            p = obj.Padding_; 
            tabs = obj.Tabs;
            n = numel( tabs ); 
            tH = obj.TabHeight; 
            if tH == -1 
                if n > 0
                    cTabExtents = get( tabs, {'Extent'} );
                    tabExtents = vertcat( cTabExtents{:} );
                    tH = max( tabExtents(:,4) );
                end
                tH = max( tH, obj.TabMinimumHeight ); 
                tH = ceil( tH ); 
                obj.TabHeight = tH; 
            end
            cH = max( [h - 2 * p - tH, 1] ); 
            switch obj.TabLocation_
                case 'top'
                    cY = 1 + p; 
                    tY = cY + cH + p; 
                case 'bottom'
                    tY = 1; 
                    cY = tY + tH + p; 
            end
            cX = 1 + p; 
            cW = max( [w - 2 * p, 1] ); 
            tW = obj.TabWidth_; 
            dW = obj.DividerWidth; 
            if tW < 0 && n > 0 
                tW = max( ( w - (n+1) * dW ) / n, 1 );
            end
            tW = ceil( tW ); 
            for ii = 1:n
                tabs(ii).Position = [1 + (ii-1) * tW + ii * dW, tY, tW, tH];
            end
            obj.Dividers.Position = [0 tY w+1 tH];
            contentsPosition = [cX cY cW cH];
            
            
            obj.redrawTabs()
            
            
            selection = obj.Selection_;
            if selection ~= 0 && strcmp( obj.TabEnables{selection}, 'on' )
                uix.setPosition( obj.Contents_(selection), contentsPosition, 'pixels' )
            end
            
        end 
        
        function addChild( obj, child )
            
            
            
            
            
            n = numel( obj.Tabs );
            tab = matlab.ui.control.UIControl( 'Internal', true, ...
                'Parent', obj, 'Style', 'text', 'Enable', 'inactive', ...
                'Units', 'pixels', 'FontUnits', obj.FontUnits_, ...
                'FontSize', obj.FontSize_, 'FontName', obj.FontName_, ...
                'FontAngle', obj.FontAngle_, 'FontWeight', obj.FontWeight_, ...
                'ForegroundColor', obj.ForegroundColor_, ...
                'String', sprintf( 'Page %d', n + 1 ) );
            tabListener = event.listener( tab, 'ButtonDown', @obj.onTabClicked );
            obj.Tabs(n+1,:) = tab;
            obj.TabListeners(n+1,:) = tabListener;
            
            
            obj.TabHeight = -1;
            
            
            if verLessThan( 'MATLAB', '8.5' ) && strcmp( child.Visible, 'off' )
                obj.G1218142 = true;
            end
            
            
            oldSelection = obj.Selection_;
            if numel( obj.Contents_ ) == 0
                newSelection = 1;
                obj.Selection_ = newSelection;
            else
                newSelection = oldSelection;
            end
            
            
            addChild@uix.mixin.Container( obj, child )
            
            
            obj.showSelection()
            
            
            if oldSelection ~= newSelection
                obj.notify( 'SelectionChanged', ...
                    uix.SelectionData( oldSelection, newSelection ) )
            end
            
        end 
        
        function removeChild( obj, child )
            
            
            
            
            
            contents = obj.Contents_;
            index = find( contents == child );
            
            
            delete( obj.Tabs(index) )
            obj.Tabs(index,:) = [];
            obj.TabListeners(index,:) = [];
            
            
            removeChild@uix.mixin.Panel( obj, child )
            
        end 
        
        function reorder( obj, indices )
            
            
            
            
            
            
            obj.Tabs = obj.Tabs(indices,:);
            obj.TabListeners = obj.TabListeners(indices,:);
            
            
            reorder@uix.mixin.Panel( obj, indices )
            
        end 
        
        function reparent( obj, oldFigure, newFigure )
            
            
            
            
            
            if ~isequal( oldFigure, newFigure )
                contextMenus = obj.TabContextMenus;
                for ii = 1:numel( contextMenus )
                    contextMenu = contextMenus{ii};
                    if ~isempty( contextMenu )
                        contextMenu.Parent = newFigure;
                    end
                end
            end
            
            
            reparent@uix.mixin.Panel( obj, oldFigure, newFigure )
            
        end 
        
        function showSelection( obj )
            
            
            
            
            
            
            showSelection@uix.mixin.Panel( obj )
            
            
            selection = obj.Selection_;
            if selection ~= 0 && strcmp( obj.TabEnables{selection}, 'off' )
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
        
        function redrawTabs( obj )
            
            
            
            
            
            selection = obj.Selection_;
            tabs = obj.Tabs;
            t = numel( tabs );
            dividers = obj.Dividers;
            
            
            if t == 0
                dividers.Visible = 'off'; 
                return
            end
            
            
            backgroundColor = obj.BackgroundColor;
            for ii = 1:t
                tab = tabs(ii);
                if ii == selection
                    tab.BackgroundColor = backgroundColor;
                else
                    tab.BackgroundColor = obj.Tint * backgroundColor;
                end
            end
            
            
            d = t + 1;
            dividerNames = repmat( 'F', [d 2] ); 
            dividerNames(1,1) = 'E'; 
            dividerNames(end,2) = 'E'; 
            if selection ~= 0
                dividerNames(selection,2) = 'T'; 
                dividerNames(selection+1,1) = 'T'; 
            end
            tH = obj.TabHeight;
            assert( tH >= obj.TabMinimumHeight, 'uix:InvalidState', ...
                'Cannot redraw tabs with invalid TabHeight.' )
            tW = obj.Tabs(1).Position(3);
            dW = obj.DividerWidth;
            allCData = zeros( [tH 0 3] ); 
            map = [obj.ShadowColor; obj.BackgroundColor; ...
                obj.Tint * obj.BackgroundColor; obj.HighlightColor;...
                obj.ParentBackgroundColor];
            for ii = 1:d
                
                iMask = obj.DividerMask.( dividerNames(ii,:) );
                
                iData = repmat( iMask(5,:), [tH 1] );
                iData(1:4,:) = iMask(1:4,:);
                iData(end-3:end,:) = iMask(end-3:end,:);
                
                cData = ind2rgb( iData+1, map );
                
                switch obj.TabLocation_
                    case 'bottom'
                        cData = flipud( cData );
                end
                
                allCData(1:tH,(ii-1)*(dW+tW)+(1:dW),:) = cData; 
                if ii > 1 
                    allCData(1:tH,(ii-1)*(dW+tW),:) = cData(:,1,:);
                end
                if ii < d 
                    allCData(1:tH,(ii-1)*(dW+tW)+dW+1,:) = cData(:,end,:);
                end
            end
            dividers.CData = allCData; 
            dividers.BackgroundColor = obj.ParentBackgroundColor;
            dividers.Visible = 'on'; 
            
        end 
        
    end 
    
    methods( Access = private )
        
        function onTabClicked( obj, source, ~ )
            
            
            oldSelection = obj.Selection_;
            newSelection = find( source == obj.Tabs );
            if oldSelection == newSelection, return, end 
            obj.Selection_ = newSelection;
            
            
            obj.showSelection()
            
            
            obj.Dirty = true;
            
            
            obj.notify( 'SelectionChanged', ...
                uix.SelectionData( oldSelection, newSelection ) )
            
        end 
        
        function onBackgroundColorChange( obj, ~, ~ )
            
            
            obj.Dirty = true;
            
        end 
        
        function onSelectionChanged( obj, source, eventData )
            
            
            callback = obj.SelectionChangedFcn;
            if ischar( callback ) && isequal( callback, '' )
                
            elseif ischar( callback )
                feval( callback, source, eventData )
            elseif isa( callback, 'function_handle' )
                callback( source, eventData )
            elseif iscell( callback )
                feval( callback{1}, source, eventData, callback{2:end} )
            end
            
        end 
        
        function onParentChanged( obj, ~, ~ )
            
            
            if isprop( obj.Parent, 'BackgroundColor' )
                prop = 'BackgroundColor';
            elseif isprop( obj.Parent, 'Color' )
                prop = 'Color';
            else
                prop = [];
            end
            
            if ~isempty( prop )
                obj.ParentBackgroundColorListener = event.proplistener( obj.Parent, ...
                    findprop( obj.Parent, prop ), 'PostSet', ...
                    @( src, evt ) obj.updateParentBackgroundColor( prop ) );
            else
                obj.ParentBackgroundColorListener = [];
            end
            
            obj.updateParentBackgroundColor( prop );
            
        end 
        
        function updateParentBackgroundColor( obj, prop )
            
            if isempty( prop )
                obj.ParentBackgroundColor = obj.BackgroundColor;
            else
                obj.ParentBackgroundColor = obj.Parent.(prop);
            end
            
            
            obj.Dirty = true;
            
        end
        
    end 
    
    methods( Access = private, Static )
        
        function mask = getDividerMask()
            
            
            
            
            
            
            mask.EF = indexColor( uix.loadIcon( 'tab_NoEdge_NotSelected.png' ) );
            mask.ET = indexColor( uix.loadIcon( 'tab_NoEdge_Selected.png' ) );
            mask.FE = indexColor( uix.loadIcon( 'tab_NotSelected_NoEdge.png' ) );
            mask.FF = indexColor( uix.loadIcon( 'tab_NotSelected_NotSelected.png' ) );
            mask.FT = indexColor( uix.loadIcon( 'tab_NotSelected_Selected.png' ) );
            mask.TE = indexColor( uix.loadIcon( 'tab_Selected_NoEdge.png' ) );
            mask.TF = indexColor( uix.loadIcon( 'tab_Selected_NotSelected.png' ) );
            
            function mask = indexColor( rgbMap )
                
                
                
                
                
                
                
                
                
                mask = nan( size( rgbMap, 1 ),size( rgbMap, 2 ) );
                
                colorIndex = isColor( rgbMap, [0 0 0] );
                mask(colorIndex) = 0;
                
                colorIndex = isColor( rgbMap, [1 0 0] );
                mask(colorIndex) = 1;
                
                colorIndex = isColor( rgbMap, [1 1 0] );
                mask(colorIndex) = 2;
                
                colorIndex = isColor( rgbMap, [1 1 1] );
                mask(colorIndex) = 3;
                
                colorIndex = isColor( rgbMap, [0 0 1] );
                mask(colorIndex) = 4;
                
                function boolMap = isColor( map, color )
                    
                    boolMap = all( bsxfun( @eq, map, permute( color, [1 3 2] ) ), 3 );
                end
            end
            
        end 
        
    end 
    
end 


