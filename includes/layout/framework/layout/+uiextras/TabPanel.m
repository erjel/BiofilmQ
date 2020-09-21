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
classdef TabPanel < uix.TabPanel
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    properties( Hidden, Access = public, Dependent )
        Callback
    end
    
    properties( Access = private )
        Callback_ = '' 
    end
    
    properties( Hidden, Access = public, Dependent )
        Enable 
        SelectedChild
        TabEnable
        TabNames
        TabPosition
        TabSize
    end
    
    properties( Access = private )
        SelectionChangedListener 
    end
    
    methods
        
        function obj = TabPanel( varargin )
            
            
            obj@uix.TabPanel( varargin{:} )
            
            
            if ~ismember( 'Parent', varargin(1:2:end) )
                obj.Parent = gcf();
            end
            
            
            selectionChangedListener = event.listener( obj, ...
                'SelectionChanged', @obj.onSelectionChanged );
            
            
            obj.SelectionChangedListener = selectionChangedListener;
            
        end 
        
    end 
    
    methods
        
        function value = get.Enable( ~ )
            
            
            
            
            
            
            value = 'on';
            
        end 
        
        function set.Enable( ~, value )
            
            
            assert( ischar( value ) && any( strcmp( value, {'on','off'} ) ), ...
                'uiextras:InvalidPropertyValue', ...
                'Property ''Enable'' must be ''on'' or ''off''.' )
            
            
            
            
            
        end 
        
        function value = get.Callback( obj )
            
            
            value = obj.Callback_;
            
        end 
        
        function set.Callback( obj, value )
            
            
            if ischar( value ) 
                
            elseif isa( value, 'function_handle' ) && ...
                    isequal( size( value ), [1 1] ) 
                
            elseif iscell( value ) && ndims( value ) == 2 && ...
                    size( value, 1 ) == 1 && size( value, 2 ) > 0 && ...
                    isa( value{1}, 'function_handle' ) && ...
                    isequal( size( value{1} ), [1 1] ) 
                
            else
                error( 'uiextras:InvalidPropertyValue', ...
                    'Property ''Callback'' must be a valid callback.' )
            end
            
            
            obj.Callback_ = value;
            
        end 
        
        function value = get.SelectedChild( obj )
            
            
            value = obj.Selection;
            
        end 
        
        function set.SelectedChild( obj, value )
            
            
            obj.Selection = value;
            
        end 
        
        function value = get.TabEnable( obj )
            
            
            value = transpose( obj.TabEnables );
            
        end 
        
        function set.TabEnable( obj, value )
            
            
            obj.TabEnables = value;
            
        end 
        
        function value = get.TabNames( obj )
            
            
            value = transpose( obj.TabTitles );
            
        end 
        
        function set.TabNames( obj, value )
            
            
            obj.TabTitles = value;
            
        end 
        
        function value = get.TabPosition( obj )
            
            
            value = obj.TabLocation;
            
        end 
        
        function set.TabPosition( obj, value )
            
            
            obj.TabLocation = value;
            
        end 
        
        function value = get.TabSize( obj )
            
            
            value = obj.TabWidth;
            
        end 
        
        function set.TabSize( obj, value )
            
            
            obj.TabWidth = value;
            
        end 
        
    end 
    
    methods( Access = private )
        
        function onSelectionChanged( obj, source, eventData )
            
            
            oldEventData = struct( 'Source', eventData.Source, ...
                'PreviousChild', eventData.OldValue, ...
                'SelectedChild', eventData.NewValue );
            
            
            callback = obj.Callback_;
            if ischar( callback ) && isequal( callback, '' )
                
            elseif ischar( callback )
                feval( callback, source, oldEventData )
            elseif isa( callback, 'function_handle' )
                callback( source, oldEventData )
            elseif iscell( callback )
                feval( callback{1}, source, oldEventData, callback{2:end} )
            end
            
        end 
        
    end 
    
end 


