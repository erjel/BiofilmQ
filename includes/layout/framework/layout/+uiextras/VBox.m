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
classdef VBox < uix.VBox
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    properties( Hidden, Access = public, Dependent )
        Enable 
        Sizes
        MinimumSizes
    end
    
    methods
        
        function obj = VBox( varargin )
            
            
            obj@uix.VBox( varargin{:} )
            
            
            if ~ismember( 'Parent', varargin(1:2:end) )
                obj.Parent = gcf();
            end
            
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
        
        function value = get.Sizes( obj )
            
            
            value = transpose( obj.Heights );
            
        end 
        
        function set.Sizes( obj, value )
            
            
            obj.Heights = value;
            
        end 
        
        function value = get.MinimumSizes( obj )
            
            
            value = transpose( obj.MinimumHeights );
            
        end 
        
        function set.MinimumSizes( obj, value )
            
            
            obj.MinimumHeights = value;
            
        end 
        
    end 
    
end 


