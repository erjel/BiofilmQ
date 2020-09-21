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
function Rr=pearson_coeff(ch1, ch2)

mean1 = mean(ch1(:));
mean2 = mean(ch2(:));

numerator = sum(sum(sum((ch1-mean1).*(ch2-mean2))));
denominator = sqrt(sum(sum(sum(power((ch1-mean1),2)))).*sum(sum(sum(power((ch2-mean2),2)))));

Rr = numerator/denominator;


