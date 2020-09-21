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
classdef ( Hidden, Sealed ) FigureObserver < handle
    
    
    
    
    
    
    
    
    properties( SetAccess = private )
        Subject 
        Figure 
    end
    
    properties( Access = private )
        PreSetListeners 
        PostSetListeners 
        OldFigure = gobjects( 0 ) 
    end
    
    events( NotifyAccess = private )
        FigureChanged
    end
    
    methods
        
        function obj = FigureObserver( subject )
            
            
            
            
            
            
            validateattributes( subject, {'matlab.graphics.Graphics'}, ...
                {'scalar'}, '', 'subject' )
            
            
            obj.Subject = subject;
            
            
            obj.update()
            
        end 
        
    end 
    
    methods( Access = private )
        
        function update( obj )
            
            
            
            obj.PreSetListeners = event.proplistener.empty( [1 0] ); 
            obj.PostSetListeners = event.proplistener.empty( [1 0] ); 
            o = obj.Subject;
            while ~isempty( o ) && ~isa( o, 'matlab.ui.Figure' )
                obj.PreSetListeners(end+1) = event.proplistener( o, ...
                    findprop( o, 'Parent' ), 'PreSet', @obj.onParentPreSet );
                obj.PostSetListeners(end+1) = event.proplistener( o, ...
                    findprop( o, 'Parent' ), 'PostSet', @obj.onParentPostSet );
                o = o.Parent;
            end
            
            
            obj.Figure = o;
            
        end 
        
        function onParentPreSet( obj, ~, ~ )
            
            
            
            obj.OldFigure = obj.Figure;
            
        end 
        
        function onParentPostSet( obj, ~, ~ )
            
            
            
            obj.update()
            
            
            oldFigure = obj.OldFigure;
            newFigure = obj.Figure;
            if ~isequal( oldFigure, newFigure )
                notify( obj, 'FigureChanged', ...
                    uix.FigureData( oldFigure, newFigure ) )
            end
            
            
            obj.OldFigure = gobjects( 0 );
            
        end 
        
    end 
    
end 


