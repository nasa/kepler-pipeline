function [aicFPEResultsStruct] = aic_fpe(modelOrderAR, maxAROrder,nLength,gapPercentage)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function [aicFPEResultsStruct] = aic_fpe(modelOrderAR, maxAROrder,nLength,gapPercentage)
%
% This function implements the Akaike's AR Model selection based on the Final
% Prediction Error
%
% Reference: Peter J. Brockwell and Richard A. Davis, "Introduction to Time
% Series and Forecasting ", Springer, 2002 pages 170 -171
%
% The FPE criterion was developed by Akaike (1969) to select the
% appropriate order p of an AR process to fit a time series[x1, x2, ..xn].
% Instead of trying to choose p to make the estimated white noise variance
% as small as possible, the idea is to choose the model for {Xn} in such a
% way as to minimize the one-step MSE when the model fitted to {Xn} is used
% to predict an independent realization {Yn} of the same process that
% generated {Xn}.
%
% Inputs:
%       modelOrderAR - choose AR model order for the input
%       maxAROrder - maximum AR model order that an independent realization
%                    will be fitted with
%       nLength - length of the input time series to be generated
%       gapPercentage - percentage of missing samples to be introduced in the time
%       series, valid range is 0 < gapPercentage <100.
%
%
% Output:
%       The output 'aicFPEResultsStruct' is a structure (or an array of struct if
%       gapPercentage > 0) containing the following fields:
%       modelOrderDeducedFromFPE - model order based on minimum mean FPE
%       FPE - final mean square one step prediction error
%       arCoefficients  - AR process coefficients
%       inputTimeSeries - internally created as the output of an AR
%                         process with coefficients 'arCoefficients'
%                         driven by white noise.
%       missingSamplesIndex - an array containing indices of missing samples
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% 
% Copyright 2017 United States Government as represented by the
% Administrator of the National Aeronautics and Space Administration.
% All Rights Reserved.
% 
% NASA acknowledges the SETI Institute's primary role in authoring and
% producing the Kepler Data Processing Pipeline under Cooperative
% Agreement Nos. NNA04CC63A, NNX07AD96A, NNX07AD98A, NNX11AI13A,
% NNX11AI14A, NNX13AD01A & NNX13AD16A.
% 
% This file is available under the terms of the NASA Open Source Agreement
% (NOSA). You should have received a copy of this agreement with the
% Kepler source code; see the file NASA-OPEN-SOURCE-AGREEMENT.doc.
% 
% No Warranty: THE SUBJECT SOFTWARE IS PROVIDED "AS IS" WITHOUT ANY
% WARRANTY OF ANY KIND, EITHER EXPRESSED, IMPLIED, OR STATUTORY,
% INCLUDING, BUT NOT LIMITED TO, ANY WARRANTY THAT THE SUBJECT SOFTWARE
% WILL CONFORM TO SPECIFICATIONS, ANY IMPLIED WARRANTIES OF
% MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, OR FREEDOM FROM
% INFRINGEMENT, ANY WARRANTY THAT THE SUBJECT SOFTWARE WILL BE ERROR
% FREE, OR ANY WARRANTY THAT DOCUMENTATION, IF PROVIDED, WILL CONFORM
% TO THE SUBJECT SOFTWARE. THIS AGREEMENT DOES NOT, IN ANY MANNER,
% CONSTITUTE AN ENDORSEMENT BY GOVERNMENT AGENCY OR ANY PRIOR RECIPIENT
% OF ANY RESULTS, RESULTING DESIGNS, HARDWARE, SOFTWARE PRODUCTS OR ANY
% OTHER APPLICATIONS RESULTING FROM USE OF THE SUBJECT SOFTWARE.
% FURTHER, GOVERNMENT AGENCY DISCLAIMS ALL WARRANTIES AND LIABILITIES
% REGARDING THIRD-PARTY SOFTWARE, IF PRESENT IN THE ORIGINAL SOFTWARE,
% AND DISTRIBUTES IT "AS IS."
% 
% Waiver and Indemnity: RECIPIENT AGREES TO WAIVE ANY AND ALL CLAIMS
% AGAINST THE UNITED STATES GOVERNMENT, ITS CONTRACTORS AND
% SUBCONTRACTORS, AS WELL AS ANY PRIOR RECIPIENT. IF RECIPIENT'S USE OF
% THE SUBJECT SOFTWARE RESULTS IN ANY LIABILITIES, DEMANDS, DAMAGES,
% EXPENSES OR LOSSES ARISING FROM SUCH USE, INCLUDING ANY DAMAGES FROM
% PRODUCTS BASED ON, OR RESULTING FROM, RECIPIENT'S USE OF THE SUBJECT
% SOFTWARE, RECIPIENT SHALL INDEMNIFY AND HOLD HARMLESS THE UNITED
% STATES GOVERNMENT, ITS CONTRACTORS AND SUBCONTRACTORS, AS WELL AS ANY
% PRIOR RECIPIENT, TO THE EXTENT PERMITTED BY LAW. RECIPIENT'S SOLE
% REMEDY FOR ANY SUCH MATTER SHALL BE THE IMMEDIATE, UNILATERAL
% TERMINATION OF THIS AGREEMENT.
%


clc;
close all;
%-------------------------------------------------------------------------
% Step 1
% First, create the signal data as the output of an autoregressive process
% driven by white noise. Use the middle samples of the AR process output
% to avoid start-up transients:
%-------------------------------------------------------------------------

% randn('state',0); % can turn this off

% generate unit variance white noise sequence which will be filtered by an
% AR process
noise = random('norm', 0, 1, nLength*5,1);  % random numbers Y from a two-parameter family of distribution('normal')
noise = chi2rnd(5, nLength*5,1);  % random numbers Y from a two-parameter family of distribution('normal')


% get AR coefficients through reflection coefficients
while true
    g = random('unif', -1, 1,modelOrderAR,1); % |g| < 1, hence stability of the filter is guaranteed

    % make sure none of the g's are equal to 0 or 1
    if( (~any(abs(g) >= 1)) && (~any(abs(g) == 0)) )
        break;
    end;
end;
arCoefficients = gtoa(g);

% filter white noise through the AR filter
inputTimeSeries = filter(1,arCoefficients,noise); % synatx for 'filter' is correct, AR filter appears as the second parameter

midPoint = fix(length(inputTimeSeries)/2);
inputTimeSeries = inputTimeSeries(midPoint:midPoint+nLength-1);
inputTimeSeries = inputTimeSeries - mean(inputTimeSeries);


%-------------------------------------------------------------------------
% Step 2
% Compute FPE
%-------------------------------------------------------------------------

nLength = length(inputTimeSeries);

FPE = zeros(maxAROrder,1);


if(gapPercentage > 0)
    missingSamplesIndex = unidrnd(nLength,fix(nLength*gapPercentage/100),1);
    inputTimeSeriesWithGaps = inputTimeSeries;
    inputTimeSeriesWithGaps(missingSamplesIndex) = 0;
    FPEforTimeSeriesWithGaps = zeros(maxAROrder,1);
else
    missingSamplesIndex = [];
end;


for p = 1:maxAROrder


    %   ARBURG   AR parameter estimation via Burg method.
    %   A = ARBURG(X,ORDER) returns the polynomial A corresponding to the AR
    %   parametric signal model estimate of vector X using Burg's method.
    %   ORDER is the model order of the AR system.
    %
    %   [A,E] = ARBURG(...) returns the final prediction error E (the variance
    %   estimate of the white noise input to the AR model).


    [a,e] = arburg(inputTimeSeries,p);

    FPE(p) = e*(nLength+p)/(nLength-p);

    if(~isempty(missingSamplesIndex))


        [a1,e1] = arburg(inputTimeSeriesWithGaps,p);

        FPEforTimeSeriesWithGaps(p) = e1*(nLength+p)/(nLength-p);

    end;



end;
close all;
[val, modelOrderDeducedFromFPE] = min(FPE);
plot(FPE, 'm.-');
hold on;
h1 = plot(FPE, 'mo-');
xlabel('AR model order');
ylabel('FPE');

aicFPEResultsStruct(1).modelOrderDeducedFromFPE = modelOrderDeducedFromFPE;
aicFPEResultsStruct(1).arCoefficients = arCoefficients;
aicFPEResultsStruct(1).inputTimeSeries = inputTimeSeries;
aicFPEResultsStruct(1).FPE = FPE;
aicFPEResultsStruct(1).missingSamplesIndex = [];
fprintf('---------------------\n');
fprintf('AR model order in the input time series  %d\n', modelOrderAR);
fprintf('AR model order based on minimum FPE in the complete time series %d\n', modelOrderDeducedFromFPE);


if(~isempty(missingSamplesIndex) > 0)
    [val, modelOrderDeducedFromFPE] = min(FPEforTimeSeriesWithGaps);

    hold on;
    h2 = plot(FPEforTimeSeriesWithGaps, 'kp-');
    
    legend([h1 h2], {'complete time series', 'time series  with gaps'});
    aicFPEResultsStruct(2).modelOrderDeducedFromFPE = modelOrderDeducedFromFPE;
    aicFPEResultsStruct(2).arCoefficients = arCoefficients;
    aicFPEResultsStruct(2).inputTimeSeries = inputTimeSeriesWithGaps;
    aicFPEResultsStruct(2).FPE = FPEforTimeSeriesWithGaps;
    aicFPEResultsStruct(2).missingSamplesIndex = missingSamplesIndex;
    fprintf('AR model order based on minimum FPE in the time series with gaps %d\n', modelOrderDeducedFromFPE);
else
    legend(h1 , {'complete time series'});

end;




fprintf('---------------------\n');

return;

