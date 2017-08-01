function test_pdq_track_trend_sinusoid
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Test PDQ tracking and trending with Gaussian random time series and
% a sinusoidal trend.
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


% Load existing PDQ input structure.
dir = 'C:\path\to\pdq-trackTrend\';
load([dir, 'pdqInputStruct.mat']);

% Set up necessary tracking and trending module parameters.
pdqInputStruct.pdqConfiguration.exponentialSmoothingFactor = 0.2;
pdqInputStruct.pdqConfiguration.adaptiveBoundsXFactor = 3.0;
pdqInputStruct.pdqConfiguration.minTrendFitSampleCount = 4.0;
pdqInputStruct.pdqConfiguration.trendFitTime = 6.0;
pdqInputStruct.pdqConfiguration.horizonTime = 7.0;
pdqInputStruct.pdqConfiguration.debugLevel = 1;

% Instantiate class object.
pdqScienceObject = pdqScienceClass(pdqInputStruct);

% Set up random time series with linear trend. There are 100 cadences at
% one day intervals.
nCadences = 100;

randn('state', 0);
mu = 0;
sigma = 1;
amplitude = 4;
period = 30;
offset = -pi/6;

metricTs.values = mu + sigma*randn([nCadences, 1]);
metricTs.uncertainties = sigma*ones([nCadences, 1]);
metricTs.gapIndicators = false([nCadences, 1]);

metricTs.values = metricTs.values + amplitude*sin(2*pi*(1:nCadences)'/period + offset);

% Set up other create_report inputs.
fixedLowerBound = -15;
fixedUpperBound = 15;

metricName = 'Sinusoidal Trend (1)';
metricUnits = 'Sigma';

cadenceTimes = 55554 + (1 : nCadences)';
newSampleTimes = cadenceTimes;

close all;

% Create the metric tracking and trending report.
[metricReport] = create_report(pdqScienceObject, metricTs, fixedLowerBound, ...
    fixedUpperBound, metricName, metricUnits, cadenceTimes, newSampleTimes);

% Set up inputs for second call.
period = 90;
offset = -pi/6;

metricTs.values = mu + sigma*randn([nCadences, 1]);
metricTs.uncertainties = sigma*ones([nCadences, 1]);
metricTs.gapIndicators = false([nCadences, 1]);

metricTs.values = metricTs.values + amplitude*sin(2*pi*(1:nCadences)'/period + offset);

metricName = 'Sinusoidal Trend (2)';

% Create the metric tracking and trending report.
[metricReport] = create_report(pdqScienceObject, metricTs, fixedLowerBound, ...
    fixedUpperBound, metricName, metricUnits, cadenceTimes, newSampleTimes);

% Return
return
