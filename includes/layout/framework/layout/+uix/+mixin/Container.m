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
classdef Container < handle
    
    
    
    
    
    
    
    
    properties( Dependent, Access = public )
        Contents 
    end
    
    properties( Access = public, Dependent, AbortSet )
        Padding 
    end
    
    properties( Access = protected )
        Contents_ = gobjects( [0 1] ) 
        Padding_ = 0 
    end
    
    properties( Dependent, Access = protected )
        Dirty 
    end
    
    properties( Access = private )
        Dirty_ = false 
        FigureObserver 
        FigureListener 
        ChildObserver 
        ChildAddedListener 
        ChildRemovedListener 
        SizeChangedListener 
        ActivePositionPropertyListeners = cell( [0 1] ) 
    end
    
    methods
        
        function obj = Container()
            
            
            
            
            
            figureObserver = uix.FigureObserver( obj );
            figureListener = event.listener( figureObserver, ...
                'FigureChanged', @obj.onFigureChanged );
            childObserver = uix.ChildObserver( obj );
            childAddedListener = event.listener( ...
                childObserver, 'ChildAdded', @obj.onChildAdded );
            childRemovedListener = event.listener( ...
                childObserver, 'ChildRemoved', @obj.onChildRemoved );
            sizeChangedListener = event.listener( ...
                obj, 'SizeChanged', @obj.onSizeChanged );
            
            
            obj.FigureObserver = figureObserver;
            obj.FigureListener = figureListener;
            obj.ChildObserver = childObserver;
            obj.ChildAddedListener = childAddedListener;
            obj.ChildRemovedListener = childRemovedListener;
            obj.SizeChangedListener = sizeChangedListener;
            
            
            obj.track()
            
        end 
        
    end 
    
    methods
        
        function value = get.Contents( obj )
            
            value = obj.Contents_;
            
        end 
        
        function set.Contents( obj, value )
            
            
            if isrow( value )
                value = transpose( value );
            end
            
            
            [tf, indices] = ismember( value, obj.Contents_ );
            assert( isequal( size( obj.Contents_ ), size( value ) ) && ...
                numel( value ) == numel( unique( value ) ) && all( tf ), ...
                'uix:InvalidOperation', ...
                'Property ''Contents'' may only be set to a permutation of itself.' )
            
            
            obj.reorder( indices )
            
        end 
        
        function value = get.Padding( obj )
            
            value = obj.Padding_;
            
        end 
        
        function set.Padding( obj, value )
            
            
            assert( isa( value, 'double' ) && isscalar( value ) && ...
                isreal( value ) && ~isinf( value ) && ...
                ~isnan( value ) && value >= 0, ...
                'uix:InvalidPropertyValue', ...
                'Property ''Padding'' must be a non-negative scalar.' )
            
            
            obj.Padding_ = value;
            
            
            obj.Dirty = true;
            
        end 
        
        function value = get.Dirty( obj )
            
            value = obj.Dirty_;
            
        end 
        
        function set.Dirty( obj, value )
            
            if value
                if obj.isDrawable() 
                    obj.redraw() 
                else 
                    obj.Dirty_ = true; 
                end
            end
            
        end 
        
    end 
    
    methods( Access = private, Sealed )
        
        function onFigureChanged( obj, ~, eventData )
            
            
            
            obj.reparent( eventData.OldFigure, eventData.NewFigure )
            
            
            if obj.Dirty_ && obj.isDrawable()
                obj.redraw()
                obj.Dirty_ = false;
            end
            
        end 
        
        function onChildAdded( obj, ~, eventData )
            
            
            
            obj.addChild( eventData.Child )
            
        end 
        
        function onChildRemoved( obj, ~, eventData )
            
            
            
            if strcmp( obj.BeingDeleted, 'on' ), return, end
            
            
            obj.removeChild( eventData.Child )
            
        end 
        
        function onSizeChanged( obj, ~, ~ )
            
            
            
            obj.Dirty = true;
            
        end 
        
        function onActivePositionPropertyChanged( obj, ~, ~ )
            
            
            
            obj.Dirty = true;
            
        end 
        
    end 
    
    methods( Abstract, Access = protected )
        
        redraw( obj )
        
    end 
    
    methods( Access = protected )
        
        function addChild( obj, child )
            
            
            
            
            
            obj.Contents_(end+1,:) = child;
            
            
            if isa( child, 'matlab.graphics.axis.Axes' )
                obj.ActivePositionPropertyListeners{end+1,:} = ...
                    event.proplistener( child, ...
                    findprop( child, 'ActivePositionProperty' ), ...
                    'PostSet', @obj.onActivePositionPropertyChanged );
            else
                obj.ActivePositionPropertyListeners{end+1,:} = [];
            end
            
            
            obj.Dirty = true;
            
        end 
        
        function removeChild( obj, child )
            
            
            
            
            
            contents = obj.Contents_;
            tf = contents == child;
            obj.Contents_(tf,:) = [];
            
            
            obj.ActivePositionPropertyListeners(tf,:) = [];
            
            
            obj.Dirty = true;
            
        end 
        
        function reparent( obj, oldFigure, newFigure ) 
            
            
            
            
            
        end 
        
        function reorder( obj, indices )
            
            
            
            
            
            
            obj.Contents_ = obj.Contents_(indices,:);
            
            
            obj.ActivePositionPropertyListeners = ...
                obj.ActivePositionPropertyListeners(indices,:);
            
            
            obj.Dirty = true;
            
        end 
        
        function tf = isDrawable( obj )
            
            
            
            
            
            
            tf = ~isempty( obj.FigureObserver.Figure );
            
        end 
        
        function track( obj )
            
            
            persistent TRACKED 
            if isempty( TRACKED )
                v = ver( 'layout' );
                try 
                    uix.tracking( 'UA-82270656-2', v(1).Version, class( obj ) )
                end
                TRACKED = true;
            end
            
        end 
        
    end 
    
end 


