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
classdef ( Hidden ) Divider < matlab.mixin.SetGet
    
    
    
    
    
    
    
    
    
    
    properties( Dependent )
        Parent 
        Units 
        Position 
        Visible 
        BackgroundColor 
        HighlightColor 
        ShadowColor 
        Orientation 
        Markings 
    end
    
    properties( Access = private )
        Control 
        BackgroundColor_ = get( 0, 'DefaultUicontrolBackgroundColor' ) 
        HighlightColor_ = [1 1 1] 
        ShadowColor_ = [0.7 0.7 0.7] 
        Orientation_ = 'vertical' 
        Markings_ = zeros( [0 1] ) 
        SizeChangedListener 
    end
    
    methods
        
        function obj = Divider( varargin )
            
            
            
            
            
            
            
            
            control = matlab.ui.control.UIControl( ...
                'Style', 'checkbox', 'Internal', true, ...
                'Enable', 'inactive', 'DeleteFcn', @obj.onDeleted,...
                'Tag', 'uix.Divider' );
            
            
            obj.Control = control;
            
            
            try
                uix.set( obj, varargin{:} )
            catch e
                delete( obj )
                e.throwAsCaller()
            end
            
            
            obj.update()
            
            
            sizeChangedListener = event.listener( control, 'SizeChanged', ...
                @obj.onSizeChanged );
            
            
            obj.SizeChangedListener = sizeChangedListener;
            
        end 
        
        function delete( obj )
            
            
            control = obj.Control;
            if isgraphics( control ) && strcmp( control.BeingDeleted, 'off' )
                delete( control )
            end
            
        end 
        
    end 
    
    methods
        
        function value = get.Parent( obj )
            
            value = obj.Control.Parent;
            
        end 
        
        function set.Parent( obj, value )
            
            obj.Control.Parent = value;
            
        end 
        
        function value = get.Units( obj )
            
            value = obj.Control.Units;
            
        end 
        
        function set.Units( obj, value )
            
            obj.Control.Units = value;
            
        end 
        
        function value = get.Position( obj )
            
            value = obj.Control.Position;
            
        end 
        
        function set.Position( obj, value )
            
            obj.Control.Position = value;
            
        end 
        
        function value = get.Visible( obj )
            
            value = obj.Control.Visible;
            
        end 
        
        function set.Visible( obj, value )
            
            obj.Control.Visible = value;
            
        end 
        
        function value = get.BackgroundColor( obj )
            
            value = obj.BackgroundColor_;
            
        end 
        
        function set.BackgroundColor( obj, value )
            
            
            assert( isa( value, 'double' ) && ...
                isequal( size( value ), [1 3] ) && ...
                all( value >= 0 ) && all( value <= 1 ), ...
                'uix:InvalidArgument', ...
                'Property ''BackgroundColor'' must be a valid colorspec.' )
            
            
            obj.BackgroundColor_ = value;
            
            
            obj.update()
            
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
            
            
            obj.update()
            
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
            
            
            obj.update()
            
        end 
        
        function value = get.Orientation( obj )
            
            value = obj.Orientation_;
            
        end 
        
        function set.Orientation( obj, value )
            
            
            assert( ischar( value ) && ismember( value, ...
                {'horizontal','vertical'} ) )
            
            
            obj.Orientation_ = value;
            
            
            obj.update()
            
        end 
        
        function value = get.Markings( obj )
            
            value = obj.Markings_;
            
        end 
        
        function set.Markings( obj, value )
            
            
            assert( isa( value, 'double' ) && ndims( value ) == 2 && ...
                size( value, 2 ) == 1 && all( isreal( value ) ) && ...
                all( ~isinf( value ) ) && all( ~isnan( value ) ) && ...
                all( value > 0 ), 'uix:InvalidPropertyValue', ...
                'Property ''Markings'' must be a vector of positive values.' ) 
            
            
            obj.Markings_ = value;
            
            
            obj.update()
            
        end 
        
    end 
    
    methods
        
        function tf = isMouseOver( obj, eventData )
            
            
            
            
            
            
            
            
            
            tf = isvalid( obj ); 
            for ii = 1:numel( obj )
                tf(ii) = tf(ii) && obj(ii).Control == eventData.HitObject;
            end
            
        end 
        
    end 
    
    methods( Access = private )
        
        function onDeleted( obj, ~, ~ )
            
            
            
            obj.delete()
            
        end 
        
        function onSizeChanged( obj, ~, ~ )
            
            
            
            obj.update()
            
        end 
        
    end 
    
    methods( Access = private )
        
        function update( obj )
            
            
            
            
            
            control = obj.Control;
            position = control.Position;
            backgroundColor = obj.BackgroundColor;
            highlightColor = obj.HighlightColor;
            shadowColor = obj.ShadowColor;
            orientation = obj.Orientation;
            markings = obj.Markings;
            
            
            mask = zeros( floor( position([4 3]) ) - [1 1] ); 
            switch orientation
                case 'vertical'
                    markings(markings < 4) = [];
                    markings(markings > position(4)-6) = [];
                    for ii = 1:numel( markings )
                        marking = markings(ii);
                        mask(floor( marking ) + [-3 0 3],1:end-1) = 1;
                        mask(floor( marking ) + [-2 1 4],1:end-1) = 2;
                    end
                case 'horizontal'
                    markings(markings < 4) = [];
                    markings(markings > position(3)-6) = [];
                    for ii = 1:numel( markings )
                        marking = markings(ii);
                        mask(2:end,floor( marking ) + [-3 0 3]) = 1;
                        mask(2:end,floor( marking ) + [-2 1 4]) = 2;
                    end
            end
            
            
            cData1 = repmat( backgroundColor(1), size( mask ) );
            cData1(mask==1) = highlightColor(1);
            cData1(mask==2) = shadowColor(1);
            cData2 = repmat( backgroundColor(2), size( mask ) );
            cData2(mask==1) = highlightColor(2);
            cData2(mask==2) = shadowColor(2);
            cData3 = repmat( backgroundColor(3), size( mask ) );
            cData3(mask==1) = highlightColor(3);
            cData3(mask==2) = shadowColor(3);
            cData = cat( 3, cData1, cData2, cData3 );
            
            
            control.ForegroundColor = backgroundColor;
            control.BackgroundColor = backgroundColor;
            control.CData = cData;
            
        end 
        
    end 
    
end 


