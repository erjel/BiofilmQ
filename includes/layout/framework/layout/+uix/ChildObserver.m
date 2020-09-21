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
classdef ( Hidden, Sealed ) ChildObserver < handle
    
    
    
    
    
    
    
    
    
    
    
    properties( Access = private )
        Root 
    end
    
    events( NotifyAccess = private )
        ChildAdded 
        ChildRemoved 
    end
    
    methods
        
        function obj = ChildObserver( oRoot )
            
            
            
            
            
            
            
            
            assert( ispositionable( oRoot ) && ...
                isequal( size( oRoot ), [1 1] ), 'uix.InvalidArgument', ...
                'Object must be a graphics object.' )
            
            
            nRoot = uix.Node( oRoot );
            childAddedListener = event.listener( oRoot, ...
                'ObjectChildAdded', ...
                @(~,e)obj.addChild(nRoot,e.Child) );
            childAddedListener.Recursive = true;
            nRoot.addprop( 'ChildAddedListener' );
            nRoot.ChildAddedListener = childAddedListener;
            childRemovedListener = event.listener( oRoot, ...
                'ObjectChildRemoved', ...
                @(~,e)obj.removeChild(nRoot,e.Child) );
            childRemovedListener.Recursive = true;
            nRoot.addprop( 'ChildRemovedListener' );
            nRoot.ChildRemovedListener = childRemovedListener;
            
            
            oChildren = hgGetTrueChildren( oRoot );
            for ii = 1:numel( oChildren )
                obj.addChild( nRoot, oChildren(ii) )
            end
            
            
            obj.Root = nRoot;
            
        end 
        
    end 
    
    methods( Access = private )
        
        function addChild( obj, nParent, oChild )
            
            
            
            
            
            
            
            
            
            nChild = uix.Node( oChild );
            nParent.addChild( nChild )
            positionable = ispositionable( oChild );
            if positionable == true
                
                internalPreSetListener = event.proplistener( oChild, ...
                    findprop( oChild, 'Internal' ), 'PreSet', ...
                    @(~,~)obj.preSetInternal(nChild) );
                nChild.addprop( 'InternalPreSetListener' );
                nChild.InternalPreSetListener = internalPreSetListener;
                
                internalPostSetListener = event.proplistener( oChild, ...
                    findprop( oChild, 'Internal' ), 'PostSet', ...
                    @(~,~)obj.postSetInternal(nChild) );
                nChild.addprop( 'InternalPostSetListener' );
                nChild.InternalPostSetListener = internalPostSetListener;
            else
                
                childAddedListener = event.listener( oChild, ...
                    'ObjectChildAdded', ...
                    @(~,e)obj.addChild(nChild,e.Child) );
                nChild.addprop( 'ChildAddedListener' );
                nChild.ChildAddedListener = childAddedListener;
                
                childRemovedListener = event.listener( oChild, ...
                    'ObjectChildRemoved', ...
                    @(~,e)obj.removeChild(nChild,e.Child) );
                nChild.addprop( 'ChildRemovedListener' );
                nChild.ChildRemovedListener = childRemovedListener;
            end
            
            
            if positionable == true && oChild.Internal == false
                notify( obj, 'ChildAdded', uix.ChildEvent( oChild ) )
            end
            
            
            if positionable == false && isblacklisted( oChild ) == false
                oGrandchildren = hgGetTrueChildren( oChild );
                for ii = 1:numel( oGrandchildren )
                    obj.addChild( nChild, oGrandchildren(ii) )
                end
            end
            
        end 
        
        function removeChild( obj, nParent, oChild )
            
            
            
            
            
            
            
            
            nChildren = nParent.Children;
            tf = oChild == [nChildren.Object];
            nChild = nChildren(tf);
            
            
            notifyChildRemoved( nChild )
            
            
            delete( nChild )
            
            function notifyChildRemoved( nc )
                
                
                ngc = nc.Children;
                for ii = 1:numel( ngc )
                    notifyChildRemoved( ngc(ii) )
                end
                
                
                oc = nc.Object;
                if ispositionable( oc ) == true && oc.Internal == false
                    notify( obj, 'ChildRemoved', uix.ChildEvent( oc ) )
                end
                
            end 
            
        end 
        
        function preSetInternal( ~, nChild )
            
            
            
            
            
            
            
            oldInternal = nChild.Object.Internal;
            nChild.addprop( 'OldInternal' );
            nChild.OldInternal = oldInternal;
            
        end 
        
        function postSetInternal( obj, nChild )
            
            
            
            
            
            
            
            
            oChild = nChild.Object;
            newInternal = oChild.Internal;
            oldInternal = nChild.OldInternal;
            
            
            delete( findprop( nChild, 'OldInternal' ) )
            
            
            switch newInternal
                case oldInternal 
                    
                case true 
                    notify( obj, 'ChildRemoved', uix.ChildEvent( oChild ) )
                case false 
                    notify( obj, 'ChildAdded', uix.ChildEvent( oChild ) )
            end
            
        end 
        
    end 
    
end 

function tf = ispositionable( o )

p = findprop( o, 'Position' );
tf = isgraphics( o ) && ~isempty( p ) && ...
    isequal( p.GetAccess, 'public' ) && ...
    isequal( p.SetAccess, 'public' ) && ...
    isequal( size( o.Position ), [1 4] );

end 

function tf = isblacklisted( o )

tf = isa( o, 'matlab.ui.container.Menu' ) || ...
    isa( o, 'matlab.ui.container.Toolbar' ) || ...
    isa( o, 'matlab.graphics.shape.internal.AnnotationPane' );

end 


