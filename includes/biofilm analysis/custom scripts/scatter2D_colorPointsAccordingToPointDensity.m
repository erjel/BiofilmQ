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


xLimits = h_ax.XLim;
yLimits = h_ax.YLim;

xScale = h_ax.XScale;
yScale = h_ax.YScale;

xData = [];
yData = [];

for i = 1:numel(h_ax.Children)
    xData = [xData, h_ax.Children(i).XData];
    yData = [yData, h_ax.Children(i).YData];
end

MarkerEdgeColor = 'none';
Marker = h_ax.Children(1).Marker;
SizeData = h_ax.Children(1).SizeData;

delete(h_ax.Children);
[C, M] = scatImage(xData, yData, 'Nbins', 20, 'xlim', xLimits,...
    'ylim', yLimits, 'smoothFactor', 15, 'xScale', xScale, 'yScale', yScale, ...
    'plotContourLines', true);

scatter(h_ax, xData, yData, SizeData, C, Marker, 'filled');
cb = colorbar(h_ax);
cb.Label.String = 'Counts';

uistack(M); 


