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
classdef Box < uix.Container & uix.mixin.Container
    
    
    
    
    
    
    
    
    properties( Access = public, Dependent, AbortSet )
        Spacing = 0 
    end
    
    properties( Access = protected )
        Spacing_ = 0 
    end
    
    methods
        
        function value = get.Spacing( obj )
            
            value = obj.Spacing_;
            
        end 
        
        function set.Spacing( obj, value )
            
            
            assert( isa( value, 'double' ) && isscalar( value ) && ...
                isreal( value ) && ~isinf( value ) && ...
                ~isnan( value ) && value >= 0, ...
                'uix:InvalidPropertyValue', ...
                'Property ''Spacing'' must be a non-negative scalar.' )
            
            
            obj.Spacing_ = value;
            
            
            obj.Dirty = true;
            
        end 
        
    end 
    
end 


