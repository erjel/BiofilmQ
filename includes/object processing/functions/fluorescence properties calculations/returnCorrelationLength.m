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
function [x_half, y_half] = returnCorrelationLength(x, y)

if isnan(y)
    x_half = NaN;
    y_half = NaN;
    return;
end

try
    xInd = [find(y<y(1)/2, 1)-1 find(y<y(1)/2, 1)];

    
    a = (y(xInd(2))-y(xInd(1)))/(x(xInd(2))-x(xInd(1)));
    b = y(xInd(1)) - a*x(xInd(1));

    x_half = (y(1)/2-b)/a;
    y_half = a*x_half+b;
catch
    warning('backtrace', 'off');
    warning('Cannot find point of inflection of ACF');
    warning('backtrace', 'on');
    x_half = NaN;
    y_half = NaN;
end


