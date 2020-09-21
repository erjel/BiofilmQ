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
function varargout = tracking( varargin )



persistent STATE USERNAME DOMAIN LANGUAGE CLIENT MATLAB OS
if isempty( STATE )
    STATE = getpref( 'Tracking', 'State', 'on' );
    if strcmp( STATE, 'snooze' ) 
        setpref( 'Tracking', 'State', 'on' )
        STATE = 'on';
    end
    if ispref( 'Tracking', 'Date' ) 
        rmpref( 'Tracking', 'Date' )
    end
    USERNAME = getenv( 'USERNAME' );
    reset()
end 

switch nargin
    case 1
        switch varargin{1}
            case {'on','off'}
                STATE = varargin{1};
                setpref( 'Tracking', 'State', varargin{1} ) 
            case 'spoof'
                spoof()
            case 'reset'
                reset()
            case 'query'
                varargout{1} = STATE;
                varargout{2} = query();
            otherwise
                error( 'tracking:InvalidArgument', ...
                    'Valid options are ''on'', ''off'' and ''query''.' )
        end
    case 3
        switch nargout
            case 0
                if strcmp( STATE, 'off' ), return, end
                uri = 'https://www.google-analytics.com/collect';
                track( uri, varargin{:} );
            case 1
                uri = 'https://www.google-analytics.com/debug/collect';
                varargout{1} = track( uri, varargin{:} );
            otherwise
                nargoutchk( 0, 1 )
        end
    otherwise
        narginchk( 3, 3 )
end 

    function reset()
        
        
        DOMAIN = lower( getenv( 'USERDOMAIN' ) );
        LANGUAGE = char( java.util.Locale.getDefault() );
        CLIENT = getpref( 'Tracking', 'Client', uuid() );
        MATLAB = matlab();
        OS = os();
        
    end 

    function spoof()
        
        
        DOMAIN = randomDomain();
        LANGUAGE = randomLanguage();
        CLIENT = randomClient();
        MATLAB = randomMatlab();
        OS = randomOs();
        
    end 

    function s = query()
        
        
        s.Username = USERNAME;
        s.Domain = DOMAIN;
        s.Language = LANGUAGE;
        s.Client = CLIENT;
        s.Matlab = MATLAB;
        s.Os = OS;
        
    end 

    function varargout = track( uri, p, v, s )
        
        
        a = sprintf( '%s/%s (%s)', MATLAB, v, OS );
        if isdeployed()
            ds = 'deployed';
        elseif strcmp( DOMAIN, 'mathworks' )
            ds = DOMAIN;
        else
            ds = 'unknown';
        end
        pv = {'v', '1', 'tid', p, 'ua', escape( a ), 'ul', LANGUAGE, ...
            'cid', CLIENT, 'ht', 'pageview', ...
            'dp', sprintf( '/%s', s ), 'ds', ds};
        [varargout{1:nargout}] = urlread( uri, 'Post', pv );
        
    end 

end 

function s = randomDomain()

switch randi( 4 )
    case 1
        s = 'mathworks';
    otherwise
        s = hash( uuid() );
end

end 

function s = randomLanguage()

lo = java.util.Locale.getAvailableLocales();
s = char( lo(randi( numel( lo ) )) );

end 

function s = randomClient()

s = uuid();

end 

function s = matlab()

v = ver( 'MATLAB' );
s = v.Release;
s(s=='('|s==')') = [];

end 

function s = randomMatlab()

releases = {'R2014b' 'R2015a' 'R2015b' 'R2016a' 'R2016b'};
s = releases{randi( numel( releases ) )};

end 

function s = os()

if ispc()
    s = sprintf( 'Windows NT %s', ...
        char( java.lang.System.getProperty( 'os.version' ) ) );
elseif isunix()
    s = 'Linux x86_64';
elseif ismac()
    s = sprintf( 'Macintosh; Intel OS X %s', ...
        strrep( char( java.lang.System.getProperty( 'os.version' ) ), ' ', '_' ) );
else
    s = 'unknown';
end

end 

function s = randomOs()

switch randi( 3 )
    case 1
        versions = [5.1 5.2 6 6.1 6.2 6.3 10];
        s = sprintf( 'Windows NT %.1f', ...
            versions(randi( numel( versions ) )) );
    case 2
        s = 'Linux x86_64';
    case 3
        s = sprintf( 'Macintosh; Intel OS X 10_%d', ...
            randi( [10 12] ) );
end

end 

function s = escape( s )

s = char( java.net.URLEncoder.encode( s, 'UTF-8' ) );

end 

function h = hash( s )

persistent MD5
if isempty( MD5 )
    MD5 = java.security.MessageDigest.getInstance( 'MD5' );
end

MD5.update( uint8( s(:) ) );
h = typecast( MD5.digest, 'uint8' );
h = dec2hex( h )';
h = lower( h(:) )';

end 

function s = uuid()

s = char( java.util.UUID.randomUUID() );

end 


