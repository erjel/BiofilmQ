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
classdef ScrollingPanel < uix.Container & uix.mixin.Panel
    
    
    
    
    
    
    
    
    
    
    
    
    
    properties( Dependent )
        Heights 
        MinimumHeights 
        VerticalOffsets 
        VerticalSteps 
        Widths 
        MinimumWidths 
        HorizontalOffsets 
        HorizontalSteps 
        MouseWheelEnabled 
    end
    
    properties( Access = protected )
        Heights_ = zeros( [0 1] ) 
        MinimumHeights_ = zeros( [0 1] ) 
        Widths_ = zeros( [0 1] ) 
        MinimumWidths_ = zeros( [0 1] ) 
        HorizontalSliders = matlab.ui.control.UIControl.empty( [0 1] ) 
        VerticalSliders = matlab.ui.control.UIControl.empty( [0 1] ) 
        BlankingPlates = matlab.ui.control.UIControl.empty( [0 1] ) 
        HorizontalSteps_ = zeros( [0 1] ) 
        VerticalSteps_ = zeros( [0 1] ) 
    end
    
    properties( Access = private )
        MouseWheelListener = [] 
        MouseWheelEnabled_ = 'on' 
        ScrollingListener = [] 
        ScrolledListener = [] 
    end
    
    properties( Constant, Access = protected )
        SliderSize = 20 
        SliderStep = 10 
    end
    
    events( NotifyAccess = private )
        Scrolling
        Scrolled
    end
    
    methods
        
        function obj = ScrollingPanel( varargin )
            
            
            
            
            
            
            
            
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
        
        function value = get.VerticalOffsets( obj )
            
            sliders = obj.VerticalSliders;
            if isempty( sliders )
                value = zeros( size( sliders ) );
            else
                value = -vertcat( sliders.Value ) - 1;
                value(value<0) = 0;
            end
            
        end 
        
        function set.VerticalOffsets( obj, value )
            
            
            assert( isa( value, 'double' ), 'uix:InvalidPropertyValue', ...
                'Property ''VerticalOffsets'' must be of type double.' )
            assert( all( isreal( value ) ) && ~any( isinf( value ) ) && ...
                ~any( isnan( value ) ), 'uix:InvalidPropertyValue', ...
                'Elements of property ''VerticalOffsets'' must be real and finite.' )
            assert( isequal( size( value ), size( obj.Contents_ ) ), ...
                'uix:InvalidPropertyValue', ...
                'Size of property ''VerticalOffsets'' must match size of contents.' )
            
            
            sliders = obj.VerticalSliders;
            for ii = 1:numel( sliders )
                sliders(ii).Value = -value(ii) - 1;
            end
            
            
            obj.Dirty = true;
            
        end 
        
        function value = get.VerticalSteps( obj )
            
            value = obj.VerticalSteps_;
            
        end 
        
        function set.VerticalSteps( obj, value )
            
            
            if isrow( value )
                value = transpose( value );
            end
            
            
            assert( isa( value, 'double' ), 'uix:InvalidPropertyValue', ...
                'Property ''VerticalSteps'' must be of type double.' )
            assert( all( isreal( value ) ) && ~any( isinf( value ) ) && ...
                ~any( isnan( value ) ) && all( value > 0 ), ...
                'uix:InvalidPropertyValue', ...
                'Elements of property ''VerticalSteps'' must be real, finite and positive.' )
            assert( isequal( size( value ), size( obj.Contents_ ) ), ...
                'uix:InvalidPropertyValue', ...
                'Size of property ''VerticalSteps'' must match size of contents.' )
            
            
            obj.VerticalSteps_ = value;
            
            
            obj.Dirty = true;
            
        end 
        
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
        
        function value = get.HorizontalOffsets( obj )
            
            sliders = obj.HorizontalSliders;
            if isempty( sliders )
                value = zeros( size( sliders ) );
            else
                value = vertcat( sliders.Value );
                value(value<0) = 0;
            end
            
        end 
        
        function set.HorizontalOffsets( obj, value )
            
            
            assert( isa( value, 'double' ), 'uix:InvalidPropertyValue', ...
                'Property ''HorizontalOffsets'' must be of type double.' )
            assert( all( isreal( value ) ) && ~any( isinf( value ) ) && ...
                ~any( isnan( value ) ), 'uix:InvalidPropertyValue', ...
                'Elements of property ''HorizontalOffsets'' must be real and finite.' )
            assert( isequal( size( value ), size( obj.Contents_ ) ), ...
                'uix:InvalidPropertyValue', ...
                'Size of property ''HorizontalOffsets'' must match size of contents.' )
            
            
            sliders = obj.HorizontalSliders;
            for ii = 1:numel( sliders )
                sliders(ii).Value = value(ii);
            end
            
            
            obj.Dirty = true;
            
        end 
        
        function value = get.HorizontalSteps( obj )
            
            value = obj.HorizontalSteps_;
            
        end 
        
        function set.HorizontalSteps( obj, value )
            
            
            if isrow( value )
                value = transpose( value );
            end
            
            
            assert( isa( value, 'double' ), 'uix:InvalidPropertyValue', ...
                'Property ''HorizontalSteps'' must be of type double.' )
            assert( all( isreal( value ) ) && ~any( isinf( value ) ) && ...
                ~any( isnan( value ) ) && all( value > 0 ), ...
                'uix:InvalidPropertyValue', ...
                'Elements of property ''HorizontalSteps'' must be real, finite and positive.' )
            assert( isequal( size( value ), size( obj.Contents_ ) ), ...
                'uix:InvalidPropertyValue', ...
                'Size of property ''HorizontalSteps'' must match size of contents.' )
            
            
            obj.HorizontalSteps_ = value;
            
            
            obj.Dirty = true;
            
        end 
        
        function value = get.MouseWheelEnabled( obj )
            
            value = obj.MouseWheelEnabled_;
            
        end 
        
        function set.MouseWheelEnabled( obj, value )
            
            assert( ischar( value ) && any( strcmp( value, {'on','off'} ) ), ...
                'uix:InvalidArgument', ...
                'Property ''MouseWheelEnabled'' must ''on'' or ''off''.' )
            listener = obj.MouseWheelListener;
            if ~isempty( listener )
                listener.Enabled = strcmp( value, 'on' );
            end
            obj.MouseWheelEnabled_ = value;
            
        end 
        
    end 
    
    methods( Access = protected )
        
        function redraw( obj )
            
            
            
            selection = obj.Selection_;
            if selection == 0, return, end
            
            
            contentsWidth = obj.Widths_(selection);
            minimumWidth = obj.MinimumWidths_(selection);
            contentsHeight = obj.Heights_(selection);
            minimumHeight = obj.MinimumHeights_(selection);
            
            
            child = obj.Contents_(selection);
            vSlider = obj.VerticalSliders(selection);
            hSlider = obj.HorizontalSliders(selection);
            plate = obj.BlankingPlates(selection);
            
            
            bounds = hgconvertunits( ancestor( obj, 'figure' ), ...
                [0 0 1 1], 'normalized', 'pixels', obj );
            width = bounds(3);
            height = bounds(4);
            sliderSize = obj.SliderSize; 
            vSliderWidth = sliderSize * ...
                (contentsHeight > height | ...
                minimumHeight > height); 
            hSliderHeight = sliderSize * ...
                (contentsWidth > width - vSliderWidth | ...
                minimumWidth > width - vSliderWidth);
            vSliderWidth = sliderSize * ...
                (contentsHeight > height - hSliderHeight | ...
                minimumHeight > height - hSliderHeight); 
            vSliderWidth = min( vSliderWidth, width ); 
            hSliderHeight = min( hSliderHeight, height ); 
            vSliderHeight = height - hSliderHeight;
            hSliderWidth = width - vSliderWidth;
            widths = uix.calcPixelSizes( width, ...
                [contentsWidth;vSliderWidth], ...
                [minimumWidth;vSliderWidth], 0, 0 );
            contentsWidth = widths(1); 
            heights = uix.calcPixelSizes( height, ...
                [contentsHeight;hSliderHeight], ...
                [minimumHeight;hSliderHeight], 0, 0 );
            contentsHeight = heights(1); 
            
            
            contentsPosition = [1 1+hSliderHeight+vSliderHeight-contentsHeight contentsWidth contentsHeight];
            vSliderPosition = [1+hSliderWidth 1+hSliderHeight vSliderWidth vSliderHeight];
            hSliderPosition = [1 1 hSliderWidth hSliderHeight];
            platePosition = [1+hSliderWidth 1 vSliderWidth hSliderHeight];
            
            
            if vSliderWidth == 0 || vSliderHeight == 0 || vSliderHeight <= vSliderWidth
                
                set( vSlider, 'Style', 'text', 'Enable', 'inactive', ...
                    'Position', vSliderPosition, ...
                    'Min', 0, 'Max', 1, 'Value', 1 )
            else
                
                vSliderMin = 0;
                vSliderMax = contentsHeight - vSliderHeight;
                vSliderValue = -vSlider.Value; 
                vSliderValue = max( vSliderValue, vSliderMin ); 
                vSliderValue = min( vSliderValue, vSliderMax ); 
                vStep = obj.VerticalSteps_(selection);
                vSliderStep(1) = min( vStep / vSliderMax, 1 );
                vSliderStep(2) = max( vSliderHeight / vSliderMax, vSliderStep(1) );
                contentsPosition(2) = contentsPosition(2) + vSliderValue;
                
                set( vSlider, 'Style', 'slider', 'Enable', 'on', ...
                    'Position', vSliderPosition, ...
                    'Min', -vSliderMax, 'Max', -vSliderMin, ...
                    'Value', -vSliderValue, 'SliderStep', vSliderStep )
            end
            
            
            if hSliderHeight == 0 || hSliderWidth == 0 || hSliderWidth <= hSliderHeight
                
                set( hSlider, 'Style', 'text', 'Enable', 'inactive', ...
                    'Position', hSliderPosition, ...
                    'Min', -1, 'Max', 0, 'Value', -1 )
            else
                
                hSliderMin = 0;
                hSliderMax = contentsWidth - hSliderWidth;
                hSliderValue = hSlider.Value; 
                hSliderValue = max( hSliderValue, hSliderMin ); 
                hSliderValue = min( hSliderValue, hSliderMax ); 
                hStep = obj.HorizontalSteps_(selection);
                hSliderStep(1) = min( hStep / hSliderMax, 1 );
                hSliderStep(2) = max( hSliderWidth / hSliderMax, hSliderStep(1) );
                contentsPosition(1) = contentsPosition(1) - hSliderValue;
                
                set( hSlider, 'Style', 'slider', 'Enable', 'on', ...
                    'Position', hSliderPosition, ...
                    'Min', hSliderMin, 'Max', hSliderMax, ...
                    'Value', hSliderValue, 'SliderStep', hSliderStep )
            end
            
            
            uix.setPosition( child, contentsPosition, 'pixels' )
            set( plate, 'Position', platePosition )
            
        end 
        
        function addChild( obj, child )
            
            
            
            
            
            obj.Widths_(end+1,:) = -1;
            obj.MinimumWidths_(end+1,:) = 1;
            obj.Heights_(end+1,:) = -1;
            obj.MinimumHeights_(end+1,:) = 1;
            obj.VerticalSliders(end+1,:) = uicontrol( ...
                'Internal', true, 'Parent', obj, 'Units', 'pixels', ...
                'Style', 'slider' );
            obj.HorizontalSliders(end+1,:) = uicontrol( ...
                'Internal', true, 'Parent', obj, 'Units', 'pixels', ...
                'Style', 'slider' );
            obj.BlankingPlates(end+1,:) = uicontrol( ...
                'Internal', true, 'Parent', obj, 'Units', 'pixels', ...
                'Style', 'text', 'Enable', 'inactive' );
            obj.VerticalSteps_(end+1,:) = obj.SliderStep;
            obj.HorizontalSteps_(end+1,:) = obj.SliderStep;
            obj.updateSliderListeners()
            
            
            addChild@uix.mixin.Panel( obj, child )
            
        end 
        
        function removeChild( obj, child )
            
            
            
            
            
            tf = obj.Contents_ == child;
            obj.Widths_(tf,:) = [];
            obj.MinimumWidths_(tf,:) = [];
            obj.Heights_(tf,:) = [];
            obj.MinimumHeights_(tf,:) = [];
            obj.VerticalSliders(tf,:) = [];
            obj.HorizontalSliders(tf,:) = [];
            obj.BlankingPlates(tf,:) = [];
            obj.VerticalSteps_(tf,:) = [];
            obj.HorizontalSteps_(tf,:) = [];
            obj.updateSliderListeners()
            
            
            removeChild@uix.mixin.Panel( obj, child )
            
        end 
        
        function reparent( obj, ~, newFigure )
            
            
            
            
            
            if isempty( newFigure )
                obj.MouseWheelListener = [];
            else
                listener = event.listener( newFigure, ...
                    'WindowScrollWheel', @obj.onMouseScrolled );
                listener.Enabled = strcmp( obj.MouseWheelEnabled_, 'on' );
                obj.MouseWheelListener = listener;
            end
            
        end 
        
        function reorder( obj, indices )
            
            
            
            
            
            
            obj.Widths_ = obj.Widths_(indices,:);
            obj.MinimumWidths_ = obj.MinimumWidths_(indices,:);
            obj.Heights_ = obj.Heights_(indices,:);
            obj.MinimumHeights_ = obj.MinimumWidths_(indices,:);
            obj.VerticalSliders = obj.VerticalSliders(indices,:);
            obj.HorizontalSliders = obj.HorizontalSliders(indices,:);
            obj.BlankingPlates = obj.BlankingPlates(indices,:);
            obj.VerticalSteps_ = obj.VerticalSteps_(indices,:);
            obj.HorizontalSteps_ = obj.HorizontalSteps_(indices,:);
            
            
            reorder@uix.mixin.Panel( obj, indices )
            
        end 
        
        function showSelection( obj )
            
            
            
            
            
            
            showSelection@uix.mixin.Panel( obj )
            
            
            selection = obj.Selection_;
            for ii = 1:numel( obj.Contents_ )
                if ii == selection
                    obj.VerticalSliders(ii).Visible = 'on';
                    obj.HorizontalSliders(ii).Visible = 'on';
                    obj.BlankingPlates(ii).Visible = 'on';
                else
                    obj.VerticalSliders(ii).Visible = 'off';
                    obj.HorizontalSliders(ii).Visible = 'off';
                    obj.BlankingPlates(ii).Visible = 'off';
                end
            end
            
        end 
        
    end 
    
    methods( Access = private )
        
        function onSliderScrolling( obj, ~, ~ )
            
            
            
            obj.Dirty = true;
            
            
            notify( obj, 'Scrolling' )
            
        end 
        
        function onSliderScrolled( obj, ~, ~ )
            
            
            
            obj.Dirty = true;
            
            
            notify( obj, 'Scrolled' )
            
        end 
        
        function onMouseScrolled( obj, ~, eventData )
            
            
            sel = obj.Selection_;
            if sel == 0
                return
            else
                
                pp = getpixelposition( obj, true );
                f = ancestor( obj, 'figure' );
                cp = f.CurrentPoint;
                
                if cp(1) < pp(1) || cp(1) > pp(1) + pp(3) || ...
                        cp(2) < pp(2) || cp(2) > pp(2) + pp(4), return, end
                
                if strcmp( obj.VerticalSliders(sel).Enable, 'on' ) 
                    delta = eventData.VerticalScrollCount * ...
                        eventData.VerticalScrollAmount * obj.VerticalSteps(sel);
                    obj.VerticalOffsets(sel) = obj.VerticalOffsets(sel) + delta;
                elseif strcmp( obj.HorizontalSliders(sel).Enable, 'on' ) 
                    delta = eventData.VerticalScrollCount * ...
                        eventData.VerticalScrollAmount * obj.HorizontalSteps(sel);
                    obj.HorizontalOffsets(sel) = obj.HorizontalOffsets(sel) + delta;
                end
                
                notify( obj, 'Scrolled' )
            end
            
        end 
        
    end 
    
    methods( Access = private )
        
        function updateSliderListeners( obj )
            
            
            if isempty( obj.VerticalSliders )
                obj.ScrollingListener = [];
                obj.ScrolledListener = [];
            else
                obj.ScrollingListener = event.listener( ...
                    [obj.VerticalSliders; obj.HorizontalSliders], ...
                    'ContinuousValueChange', @obj.onSliderScrolling );
                obj.ScrolledListener = event.listener( ...
                    [obj.VerticalSliders; obj.HorizontalSliders], ...
                    'Action', @obj.onSliderScrolled );
            end
            
        end 
        
    end 
    
end 


