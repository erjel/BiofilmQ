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
function renderBiofilmThumbnail(handles, objects)

h_ax = handles.axes.axes_analysis_overview;

centroid = [objects.stats.Centroid];
y = centroid(1:3:end);
x = centroid(2:3:end);
z = centroid(3:3:end);

res = 50;
X = -2*res:res:objects.ImageSize(1)+2*res;
Y = -2*res:res:objects.ImageSize(2)+2*res;

if numel(objects.ImageSize) == 2
    objects.ImageSize(3) = 1;
end

Z = 0:res:objects.ImageSize(3)+2*res;

im = zeros(numel(X)-1, numel(Y)-1, numel(Z)-1);

for i = 1:numel(Z)-1
    ind = find(Z(i)<=z & z<=Z(i+1));
    try
        im(:,:,i) = histcounts2(x(ind)', y(ind)', X', Y');
    catch
        x_temp = x(ind);
        y_temp = y(ind);
        for idx = 1:numel(x_temp)
            x_ind = find(X > x_temp(idx), 1);
            y_ind = find(Y > y_temp(idx), 1);
            im(x_ind, y_ind, i) = im(x_ind, y_ind, i) + 1;
        end
    end
end

[Xmask, Ymask, Zmask] = meshgrid(Y(1:end-1),X(1:end-1),Z(1:end-1));
M = isosurface(Xmask,Ymask, Zmask, im, 0.5);
delete(get(h_ax, 'children'));
set(h_ax, 'NextPlot', 'add');
patch(M, 'FaceColor', [0.1 0.1 0.7], 'EdgeColor', [0.5 0.5 0.5], 'EdgeAlpha', 0.3, 'Tag', 'biofilm', 'FaceLighting', 'gouraud', 'AmbientStrength', 0.5, 'SpecularStrength', 0.2, 'FaceAlpha', 0.15, 'Parent', h_ax);


xlim(h_ax, [min(X) max(X)]);
ylim(h_ax, [min(Y) max(Y)]);
xlabel(h_ax, '');
ylabel(h_ax, '');
zlabel(h_ax, '');

box(h_ax, 'off');

view(h_ax, 45,45);

handles.layout.boxPanels.analysis_biofilmPreviewBoxPanel.Title = sprintf('Biofilm preview (%s)', objects.Filename);



