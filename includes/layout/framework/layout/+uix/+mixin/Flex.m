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
classdef Flex < handle
    
    
    
    
    
    
    
    
    properties( GetAccess = protected, SetAccess = private )
        Pointer = 'unset' 
    end
    
    properties( Access = private )
        Figure = gobjects( 0 ); 
        Token = -1 
    end
    
    methods
        
        function delete( obj )
            
            
            
            if ~strcmp( obj.Pointer, 'unset' )
                obj.unsetPointer()
            end
            
        end 
        
    end 
    
    methods( Access = protected )
        
        function setPointer( obj, figure, pointer )
            
            
            
            
            
            if obj.Token ~= -1
                obj.unsetPointer()
            end
            
            
            obj.Token = uix.PointerManager.setPointer( figure, pointer );
            obj.Figure = figure;
            obj.Pointer = pointer;
            
        end 
        
        function unsetPointer( obj )
            
            
            
            
            
            assert( obj.Token ~= -1, 'uix:InvalidOperation', ...
                'Pointer is already unset.' )
            
            
            uix.PointerManager.unsetPointer( obj.Figure, obj.Token );
            obj.Figure = gobjects( 0 );
            obj.Pointer = 'unset';
            obj.Token = -1;
            
        end 
        
    end 
    
end 


