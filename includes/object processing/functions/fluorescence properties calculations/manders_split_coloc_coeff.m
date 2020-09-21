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
function [m1, m2]=manders_split_coloc_coeff(ch1, ch2)

numerator1 = ch1(:).*(ch2(:)>0);
numerator2 = ch2(:).*(ch1(:)>0);

numerator1 = sum(numerator1(:));
numerator2 = sum(numerator2(:));

denominator1 = sum(ch1(:));
denominator2 = sum(ch2(:));

if denominator1
    m1 = numerator1/denominator1;
else
    m1 = 0;
end
if denominator2
    m2 = numerator2/denominator2;
else
    m2 = 0;
end




