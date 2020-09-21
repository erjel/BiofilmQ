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
classdef ButtonBox < uix.Box
    
    
    
    
    
    
    
    properties( Access = public, Dependent, AbortSet )
        ButtonSize 
        HorizontalAlignment 
        VerticalAlignment 
    end
    
    properties( Access = protected )
        ButtonSize_ = [60 20] 
        HorizontalAlignment_ = 'center' 
        VerticalAlignment_ = 'middle' 
    end
    
    methods
        
        function value = get.ButtonSize( obj )
            
            value = obj.ButtonSize_;
            
        end 
        
        function set.ButtonSize( obj, value )
            
            
            assert( isa( value, 'double' ), 'uix:InvalidPropertyValue', ...
                'Property ''ButtonSize'' must be of type double.' )
            assert( isequal( size( value ), [1 2] ), ...
                'uix:InvalidPropertyValue', ...
                'Size of property ''ButtonSize'' must by 1-by-2.' )
            assert( all( isreal( value ) ) && ~any( isinf( value ) ) && ...
                ~any( isnan( value ) ) && ~any( value <= 0 ), ...
                'uix:InvalidPropertyValue', ...
                'Elements of property ''ButtonSize'' must be real, finite and positive.' )
            
            
            obj.ButtonSize_ = value;
            
            
            obj.Dirty = true;
            
        end 
        
        function value = get.HorizontalAlignment( obj )
            
            value = obj.HorizontalAlignment_;
            
        end 
        
        function set.HorizontalAlignment( obj, value )
            
            
            assert( ischar( value ), 'uix:InvalidPropertyValue', ...
                'Property ''HorizontalAlignment'' must be a string.' )
            assert( any( strcmp( value, {'left';'center';'right'} ) ), ...
                'Property ''HorizontalAlignment'' must be ''left'', ''center'' or ''right''.' )
            
            
            obj.HorizontalAlignment_ = value;
            
            
            obj.Dirty = true;
            
        end 
        
        function value = get.VerticalAlignment( obj )
            
            value = obj.VerticalAlignment_;
            
        end 
        
        function set.VerticalAlignment( obj, value )
            
            
            assert( ischar( value ), 'uix:InvalidPropertyValue', ...
                'Property ''VerticalAlignment'' must be a string.' )
            assert( any( strcmp( value, {'top';'middle';'bottom'} ) ), ...
                'Property ''VerticalAlignment'' must be ''top'', ''middle'' or ''bottom''.' )
            
            
            obj.VerticalAlignment_ = value;
            
            
            obj.Dirty = true;
            
        end 
        
    end 
    
end 


