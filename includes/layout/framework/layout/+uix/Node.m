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
classdef ( Hidden ) Node < dynamicprops
    
    
    
    
    
    
    
    
    
    
    properties( SetAccess = private )
        Object 
        Children = uix.Node.empty( [0 1] ) 
    end
    
    properties( Access = private )
        ChildListeners = event.listener.empty( [0 1] ) 
    end
    
    methods
        
        function obj = Node( object )
            
            
            
            
            
            assert( isa( object, 'handle' ) && ...
                isequal( size( object ), [1 1] ) && isvalid( object ), ...
                'uix:InvalidArgument', 'Object must be a handle.' )
            
            
            obj.Object = object;
            
        end 
        
    end 
    
    methods
        
        function addChild( obj, child )
            
            
            
            
            
            assert( isa( child, 'uix.Node' ) && ...
                isequal( size( child ), [1 1] ), ...
                'uix:InvalidArgument', 'Invalid node.' )
            
            
            childListener = event.listener( child, ...
                'ObjectBeingDestroyed', @obj.onChildDeleted );
            obj.Children(end+1,:) = child;
            obj.ChildListeners(end+1,:) = childListener;
            
        end 
        
        function removeChild( obj, child )
            
            
            
            
            
            
            assert( isa( child, 'uix.Node' ) && ...
                isequal( size( child ), [1 1] ), ...
                'uix:InvalidArgument', 'Invalid node.' )
            assert( ismember( child, obj.Children ), ...
                'uix:ItemNotFound', 'Node not found.' )
            
            
            tf = child == obj.Children;
            obj.Children(tf,:) = [];
            obj.ChildListeners(tf,:) = [];
            
        end 
        
    end 
    
    methods( Access = private )
        
        function onChildDeleted( obj, source, ~ )
            
            
            
            obj.removeChild( source )
            
        end 
        
    end 
    
end 


