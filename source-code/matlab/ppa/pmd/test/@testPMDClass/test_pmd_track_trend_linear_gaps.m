function self = test_pmd_track_trend_linear_gaps(self)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Test PMD tracking and trending with Gaussian random time series and
% linear trend.
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

clear pmdInputStruct;
clear pmdScienceClass;

fprintf('\nTest PMD: track and trend linear with gaps\n');

messageOut = 'Test failed - The retrieved data and the expected data are not identical!';

% Set up necessary tracking and trending module parameters.
parameters.minTrendFitSampleCount    = 4.0;
parameters.initialAverageSampleCount = 10;
parameters.trendFitTime              = 6.0;
parameters.horizonTime               = 20.0;
parameters.alertTime                 = 20;
parameters.debugLevel                = 1;

% Set up random time series with linear trend. There are 100 cadences at
% one day intervals.
nCadences = 1440;

randn('state', 0);
mu = 0;
sigma = 1;

cadenceTimes            = (1 : nCadences)'*(1/48);
cadenceGapIndicators    = false(size(cadenceTimes));

metricTs.values         = mu + sigma*randn([nCadences, 1]);
metricTs.uncertainties  = sigma*ones([nCadences, 1]);
metricTs.gapIndicators  = false([nCadences, 1]);

metricTs.values = metricTs.values + 1*cadenceTimes;
metricTs.gapIndicators(301: 500) = true([200, 1]);
metricTs.gapIndicators(801:1000) = true([200, 1]);

% Set up other create_report inputs.
smoothingFactor =  0.2;
fixedLowerBound = -40;
fixedUpperBound =  40;
adaptiveXFactor =  3.0;

metricName = 'Linear Trend';


ccdModule = 2;
ccdOutput = 1;

% Create the metric tracking and trending report.
figure;
[metricReport] = ppa_create_report(parameters, metricTs, smoothingFactor, fixedLowerBound, ...
     fixedUpperBound, adaptiveXFactor, metricName, cadenceTimes, cadenceGapIndicators, ccdModule, ccdOutput);

crossingTime = metricReport.fixedBoundsReport.crossingTime;
if ( (crossingTime < 38) || (crossingTime >42) )
     assert_equals(1, 0, messageOut);
end

close all;

% Return
return
