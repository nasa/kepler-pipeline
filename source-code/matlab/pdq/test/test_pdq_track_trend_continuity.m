function test_pdq_track_trend_continuity
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Test PDQ tracking and trending with Gaussian random time series and
% steps. Test of continuity from contact to contact.
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

% Set up random time series with steps. There are 100 cadences at
% one day intervals.
nCadences = 100;

randn('state', 0);
mu = 0;
sigma = 1;

metricTs.values = mu + sigma*randn([nCadences, 1]);
metricTs.uncertainties = sigma*ones([nCadences, 1]);
metricTs.gapIndicators = false([nCadences, 1]);

metricTs.values(26:50) = metricTs.values(26:50) + 4*sigma;
metricTs.values(51:75) = metricTs.values(51:75) - 4*sigma;
metricTs.values(76:100) = metricTs.values(76:100) + 8*sigma;

% Set up other create_report inputs.
fixedLowerBound = -15;
fixedUpperBound = 15;

cadenceTimes = 55554 + (1 : nCadences)';

% Trim metric time series.
metricTs0.values = metricTs.values(1:60);
metricTs0.uncertainties = metricTs.uncertainties(1:60);
metricTs0.gapIndicators = metricTs.gapIndicators(1:60);

metricName0 = 'Continuity (1)';
metricUnits = 'Sigma';

cadenceTimes0 = cadenceTimes(1:60);
newSampleTimes0 = cadenceTimes0;

close all;

% Create the metric tracking and trending report.
[metricReport0] = create_report(pdqScienceObject, metricTs0, fixedLowerBound, ...
    fixedUpperBound, metricName0, metricUnits, cadenceTimes0, newSampleTimes0);

% Set up inputs for second call.
metricName = 'Continuity (2)';
newSampleTimes = cadenceTimes(61:100);

% Create the metric tracking and trending report.
[metricReport] = create_report(pdqScienceObject, metricTs, fixedLowerBound, ...
    fixedUpperBound, metricName, metricUnits, cadenceTimes, newSampleTimes);

% Return
return
