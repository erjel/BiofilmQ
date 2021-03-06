function [fitresult, gof] = smoothCellNumber(x, cellNumber)
%CREATEFIT(X,CELLNUMBER)
%  Create a fit.
%
%  Data for 'untitled fit 1' fit:
%      X Input : x
%      Y Output: cellNumber
%  Output:
%      fitresult : a fit object representing the fit.
%      gof : structure with goodness-of fit info.
%
%  See also FIT, CFIT, SFIT.

%  Auto-generated by MATLAB on 24-Jan-2017 14:36:52


%% Fit: 'untitled fit 1'.
[xData, yData] = prepareCurveData( x, cellNumber );

% Set up fittype and options.
ft = fittype( 'smoothingspline' );
opts = fitoptions( 'Method', 'SmoothingSpline' );
opts.SmoothingParam = 0.2;

% Fit model to data.
[fitresult, gof] = fit( xData, yData, ft, opts );
