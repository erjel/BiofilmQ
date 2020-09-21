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
classdef ( Hidden, Sealed ) PointerManager < handle
    
    
    
    
    
    properties( SetAccess = private )
        Figure 
    end
    
    properties( Access = private )
        Tokens 
        Pointers 
        NextToken 
        PointerListener 
    end
    
    methods( Access = private )
        
        function obj = PointerManager( figure )
            
            
            
            
            
            obj.Figure = figure;
            obj.Tokens = 0;
            obj.Pointers = {figure.Pointer};
            obj.NextToken = 1;
            obj.PointerListener = event.proplistener( figure, ...
                findprop( figure, 'Pointer' ), 'PostSet', ...
                @obj.onPointerChanged );
            
        end 
        
    end 
    
    methods( Access = private )
        
        function doSetPointer( obj, token, pointer )
            
            
            
            
            
            tf = obj.Tokens == token;
            obj.Tokens(tf) = [];
            obj.Pointers(tf) = [];
            
            
            obj.Tokens(end+1) = token;
            obj.Pointers{end+1} = pointer;
            
            
            obj.PointerListener.Enabled = false;
            obj.Figure.Pointer = pointer;
            obj.PointerListener.Enabled = true;
            
        end 
        
        function doUnsetPointer( obj, token )
            
            
            
            
            
            tf = obj.Tokens == token;
            obj.Tokens(tf) = [];
            obj.Pointers(tf) = [];
            
            
            obj.PointerListener.Enabled = false;
            obj.Figure.Pointer = obj.Pointers{end};
            obj.PointerListener.Enabled = true;
            
        end 
        
    end 
    
    methods
        
        function onPointerChanged( obj, ~, ~ )
            
            
            
            obj.doSetPointer( 0, obj.Figure.Pointer )
            
        end 
        
    end 
    
    methods( Static )
        
        function token = setPointer( figure, pointer )
            
            
            
            
            
            
            
            obj = uix.PointerManager.getInstance( figure );
            
            
            token = obj.NextToken;
            
            
            obj.doSetPointer( token, pointer )
            
            
            obj.NextToken = token + 1;
            
        end 
        
        function unsetPointer( figure, token )
            
            
            
            
            
            
            validateattributes( token, {'numeric'}, {'scalar','integer','>',0} )
            
            
            obj = uix.PointerManager.getInstance( figure );
            
            
            obj.doUnsetPointer( token )
            
        end 
        
        function obj = getInstance( figure )
            
            
            
            
            
            
            name = 'UIxPointerManager';
            if isprop( figure, name ) 
                obj = figure.( name );
            else 
                obj = uix.PointerManager( figure );
                p = addprop( figure, name );
                p.Hidden = true;
                figure.( name ) = obj;
            end
            
        end 
        
    end 
    
end 


