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
function objects = calculateParameterCombination(handles, objects, params)

ticValue = displayTime;

filterExpr = params.edit_parameterCombination_formula;
newName = params.edit_parameterCombination_newParamName;

formulaRaw = filterExpr;
try
    fields = extractBetween(formulaRaw,'{','}');
catch
    fields = regexp(formulaRaw, '{.*?}', 'match');
    fields = cellfun(@(x) x(2:end-1), fields, 'UniformOutput', false);
end
formula = formulaRaw;
if ~isempty(fields)
    
    formula = strrep(formula, '/', './');
    formula = strrep(formula, '*', '.*');
    formula = strrep(formula, '^', '.^');
    for i = 1:numel(fields)
        formula = strrep(formula, ['{', fields{i}, '}'], sprintf('[objects.stats.%s]', fields{i}));
    end
else
    formula = formulaRaw;
end

eval(sprintf('result = %s;', formula));

result = num2cell(double(result));
[objects.stats.(sprintf('%s', newName))] = result{:};



displayTime(ticValue);


