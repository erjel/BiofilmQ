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
function threshold = getBEM_threshold(image, params)

minVal = prctile(image(:),0.001);
maxVal = prctile(image(:),99.999);

thresholdSensitivity = params.thresholdSensitivity;
slopeThresh = thresholdSensitivity^2;

bv = zeros(256,1);
thresh = linspace(minVal, maxVal, 256); 
tic;
for j = 1:256
   bv(j) = sum(image(:)> thresh(j)); 
end 
toc;

try
    
    ft = fittype('a*x^b+c');
    fittedCurve = fit(thresh', bv, ft, 'Startpoint', [3.2*10^6, -0.15, -1.3*10^6]);
    a = fittedCurve.a;
    b = fittedCurve.b;

    range = maxVal-minVal;
    dt = range/255;

    
    func = @(x) b*a*x^(b-1);
    c = 1;
    val = (func(thresh(c)+dt)-func(thresh(c)))/func(thresh(c));
    
    
    
    while abs(val)>slopeThresh && c<255
        c = c+1;
        val = (func(thresh(c)+dt)-func(thresh(c)))/func(thresh(c));
    end

catch exception
    
    fprintf('\n Warning: Fitting during BEM threshold determination failed. Using numerical approximations instead.');
    range = maxVal-minVal;
    dt = range/255;
    val = (deriv(bv, 2, dt)- deriv(bv, 1, dt))/deriv(bv, 1, dt);
    c = 1;
    while abs(val)>slopeThresh && c<255
        c = c+1;
        val = (deriv(bv, c+1, dt)- deriv(bv, c, dt))/deriv(bv, c, dt);
    end 
end

if c == 255
    msgbox('Thresholding by BEM did not converge. Please use another algorithm or determine the threshold manually.', 'Warning', 'warn');
end

threshold = thresh(c)
disp(c);

    function d = deriv(f, index, delta)
        if index == 1 
            d = (f(index+1)-f(index))/delta;
        elseif index ==length(f)
            d = (f(index)-f(index-1))/delta;
        else
            d = (f(index+1)-2*f(index)-f(index-1))/(2*delta);
        end
    end
end




