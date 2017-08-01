function [pmdOutputStruct] = pmd_generate_track_trend_reports(pmdScienceObject, pmdOutputStruct, pmdTempStruct)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function [pmdOutputStruct] = pmd_generate_track_trend_reports(pmdScienceObject, pmdOutputStruct, pmdTempStruct)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% This fuction generates track and trend report of PPA metric time series.
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

% Get the fixed bounds and new sample times from the input PPA science object.
parameters = pmdScienceObject.pmdModuleParameters;

% Get the cadence times for the metrics
cadenceTimestamps    = pmdScienceObject.cadenceTimes.midTimestamps;
cadenceGapIndicators = pmdScienceObject.cadenceTimes.gapIndicators;

% Get the metric time series data from input struct for the given mod/out. 
tsData    = pmdScienceObject.inputTsData;

% Get the metric time series data generted within PMD.
tsOutData = pmdOutputStruct.outputTsData;


figure(5)
pmd_plot_track_trend_summary(pmdOutputStruct.report, 'trackAlertLevel', ...
    ['PMD Track Report   Module: ' num2str(pmdScienceObject.ccdModule) ' Output: ' num2str(pmdScienceObject.ccdOutput)]);
figure(6)
pmd_plot_track_trend_summary(pmdOutputStruct.report, 'trendAlertLevel', ...
    ['PMD Trend Report   Module: ' num2str(pmdScienceObject.ccdModule) ' Output: ' num2str(pmdScienceObject.ccdOutput)]);

figure(11)
subplot(4,3,1)
pmd_plot_time_series_metrics(tsData,    pmdTempStruct, parameters, cadenceTimestamps, cadenceGapIndicators, 'blackLevel'         );
subplot(4,3,2)
pmd_plot_time_series_metrics(tsData,    pmdTempStruct, parameters, cadenceTimestamps, cadenceGapIndicators, 'smearLevel'         );
subplot(4,3,3)
pmd_plot_time_series_metrics(tsData,    pmdTempStruct, parameters, cadenceTimestamps, cadenceGapIndicators, 'darkCurrent'        );
subplot(4,3,4)
pmd_plot_time_series_metrics(tsData,    pmdTempStruct, parameters, cadenceTimestamps, cadenceGapIndicators, 'brightness'         );
subplot(4,3,5)
pmd_plot_time_series_metrics(tsData,    pmdTempStruct, parameters, cadenceTimestamps, cadenceGapIndicators, 'encircledEnergy'    );
subplot(4,3,6)
pmd_plot_time_series_metrics(tsOutData, pmdTempStruct, parameters, cadenceTimestamps, cadenceGapIndicators, 'backgroundLevel'    );
subplot(4,3,7)
pmd_plot_time_series_metrics(tsOutData, pmdTempStruct, parameters, cadenceTimestamps, cadenceGapIndicators, 'centroidsMeanRow'   );
subplot(4,3,8)
pmd_plot_time_series_metrics(tsOutData, pmdTempStruct, parameters, cadenceTimestamps, cadenceGapIndicators, 'centroidsMeanColumn');
subplot(4,3,9)
pmd_plot_time_series_metrics(tsOutData, pmdTempStruct, parameters, cadenceTimestamps, cadenceGapIndicators, 'plateScale'         );
subplot(4,3,10)
pmd_plot_time_series_metrics(tsData,    pmdTempStruct, parameters, cadenceTimestamps, cadenceGapIndicators, 'theoreticalCompressionEfficiency', 'compression');
subplot(4,3,11)
pmd_plot_time_series_metrics(tsData,    pmdTempStruct, parameters, cadenceTimestamps, cadenceGapIndicators, 'achievedCompressionEfficiency',    'compression');

figure(12)
for iLdeUndershoot = 1:min(3,length(tsData.ldeUndershoot))
    subplot(4,3,iLdeUndershoot)
    pmd_plot_metrics_array(tsData,    pmdTempStruct, parameters, cadenceTimestamps, cadenceGapIndicators, iLdeUndershoot, 'ldeUndershoot');
end
for iTwoDBlack = 1:min(6,length(tsData.twoDBlack))
    subplot(4,3,3+iTwoDBlack)
    pmd_plot_metrics_array(tsData,    pmdTempStruct, parameters, cadenceTimestamps, cadenceGapIndicators, iTwoDBlack,     'twoDBlack'    );
end

figure(13)
subplot(4,3,1)
pmd_plot_cosmic_ray_metrics(tsData, pmdTempStruct, parameters, cadenceTimestamps, cadenceGapIndicators, 'black',         'hitRate'       );
subplot(4,3,2)
pmd_plot_cosmic_ray_metrics(tsData, pmdTempStruct, parameters, cadenceTimestamps, cadenceGapIndicators, 'black',         'meanEnergy'    );
subplot(4,3,3)
pmd_plot_cosmic_ray_metrics(tsData, pmdTempStruct, parameters, cadenceTimestamps, cadenceGapIndicators, 'black',         'energyVariance');
subplot(4,3,4)
pmd_plot_cosmic_ray_metrics(tsData, pmdTempStruct, parameters, cadenceTimestamps, cadenceGapIndicators, 'maskedSmear',   'hitRate'       );
subplot(4,3,5)
pmd_plot_cosmic_ray_metrics(tsData, pmdTempStruct, parameters, cadenceTimestamps, cadenceGapIndicators, 'maskedSmear',   'meanEnergy'    );
subplot(4,3,6)
pmd_plot_cosmic_ray_metrics(tsData, pmdTempStruct, parameters, cadenceTimestamps, cadenceGapIndicators, 'maskedSmear',   'energyVariance');
subplot(4,3,7)
pmd_plot_cosmic_ray_metrics(tsData, pmdTempStruct, parameters, cadenceTimestamps, cadenceGapIndicators, 'virtualSmear',  'hitRate'       );
subplot(4,3,8)
pmd_plot_cosmic_ray_metrics(tsData, pmdTempStruct, parameters, cadenceTimestamps, cadenceGapIndicators, 'virtualSmear',  'meanEnergy'    );
subplot(4,3,9)
pmd_plot_cosmic_ray_metrics(tsData, pmdTempStruct, parameters, cadenceTimestamps, cadenceGapIndicators, 'virtualSmear',  'energyVariance');

figure(14)
subplot(4,3,1)
pmd_plot_cosmic_ray_metrics(tsData, pmdTempStruct, parameters, cadenceTimestamps, cadenceGapIndicators, 'targetStar',    'hitRate'       );
subplot(4,3,2)
pmd_plot_cosmic_ray_metrics(tsData, pmdTempStruct, parameters, cadenceTimestamps, cadenceGapIndicators, 'targetStar',    'meanEnergy'    );
subplot(4,3,3)
pmd_plot_cosmic_ray_metrics(tsData, pmdTempStruct, parameters, cadenceTimestamps, cadenceGapIndicators, 'targetStar',    'energyVariance');
subplot(4,3,4)
pmd_plot_cosmic_ray_metrics(tsData, pmdTempStruct, parameters, cadenceTimestamps, cadenceGapIndicators, 'background',    'hitRate'       );
subplot(4,3,5)
pmd_plot_cosmic_ray_metrics(tsData, pmdTempStruct, parameters, cadenceTimestamps, cadenceGapIndicators, 'background',    'meanEnergy'    );
subplot(4,3,6)
pmd_plot_cosmic_ray_metrics(tsData, pmdTempStruct, parameters, cadenceTimestamps, cadenceGapIndicators, 'background',    'energyVariance');

cdppString = 'cdppMeasured';
figure(15)
subplot(4,3,1)
pmd_plot_cdpp_metrics(tsOutData, pmdTempStruct, parameters, cadenceTimestamps, cadenceGapIndicators, cdppString, 'mag9',  'threeHour' );
subplot(4,3,2)
pmd_plot_cdpp_metrics(tsOutData, pmdTempStruct, parameters, cadenceTimestamps, cadenceGapIndicators, cdppString, 'mag9',  'sixHour'   );
subplot(4,3,3)
pmd_plot_cdpp_metrics(tsOutData, pmdTempStruct, parameters, cadenceTimestamps, cadenceGapIndicators, cdppString, 'mag9',  'twelveHour');
subplot(4,3,4)
pmd_plot_cdpp_metrics(tsOutData, pmdTempStruct, parameters, cadenceTimestamps, cadenceGapIndicators, cdppString, 'mag10', 'threeHour' );
subplot(4,3,5)
pmd_plot_cdpp_metrics(tsOutData, pmdTempStruct, parameters, cadenceTimestamps, cadenceGapIndicators, cdppString, 'mag10', 'sixHour'   );
subplot(4,3,6)
pmd_plot_cdpp_metrics(tsOutData, pmdTempStruct, parameters, cadenceTimestamps, cadenceGapIndicators, cdppString, 'mag10', 'twelveHour');
subplot(4,3,7)
pmd_plot_cdpp_metrics(tsOutData, pmdTempStruct, parameters, cadenceTimestamps, cadenceGapIndicators, cdppString, 'mag11', 'threeHour' );
subplot(4,3,8)
pmd_plot_cdpp_metrics(tsOutData, pmdTempStruct, parameters, cadenceTimestamps, cadenceGapIndicators, cdppString, 'mag11', 'sixHour'   );
subplot(4,3,9)
pmd_plot_cdpp_metrics(tsOutData, pmdTempStruct, parameters, cadenceTimestamps, cadenceGapIndicators, cdppString, 'mag11', 'twelveHour');
subplot(4,3,10)
pmd_plot_cdpp_metrics(tsOutData, pmdTempStruct, parameters, cadenceTimestamps, cadenceGapIndicators, cdppString, 'mag12', 'threeHour' );
subplot(4,3,11)
pmd_plot_cdpp_metrics(tsOutData, pmdTempStruct, parameters, cadenceTimestamps, cadenceGapIndicators, cdppString, 'mag12', 'sixHour'   );
subplot(4,3,12)
pmd_plot_cdpp_metrics(tsOutData, pmdTempStruct, parameters, cadenceTimestamps, cadenceGapIndicators, cdppString, 'mag12', 'twelveHour');

figure(16)
subplot(4,3,1)
pmd_plot_cdpp_metrics(tsOutData, pmdTempStruct, parameters, cadenceTimestamps, cadenceGapIndicators, cdppString, 'mag13', 'threeHour' );
subplot(4,3,2)
pmd_plot_cdpp_metrics(tsOutData, pmdTempStruct, parameters, cadenceTimestamps, cadenceGapIndicators, cdppString, 'mag13', 'sixHour'   );
subplot(4,3,3)
pmd_plot_cdpp_metrics(tsOutData, pmdTempStruct, parameters, cadenceTimestamps, cadenceGapIndicators, cdppString, 'mag13', 'twelveHour');
subplot(4,3,4)
pmd_plot_cdpp_metrics(tsOutData, pmdTempStruct, parameters, cadenceTimestamps, cadenceGapIndicators, cdppString, 'mag14', 'threeHour' );
subplot(4,3,5)
pmd_plot_cdpp_metrics(tsOutData, pmdTempStruct, parameters, cadenceTimestamps, cadenceGapIndicators, cdppString, 'mag14', 'sixHour'   );
subplot(4,3,6)
pmd_plot_cdpp_metrics(tsOutData, pmdTempStruct, parameters, cadenceTimestamps, cadenceGapIndicators, cdppString, 'mag14', 'twelveHour');
subplot(4,3,7)
pmd_plot_cdpp_metrics(tsOutData, pmdTempStruct, parameters, cadenceTimestamps, cadenceGapIndicators, cdppString, 'mag15', 'threeHour' );
subplot(4,3,8)
pmd_plot_cdpp_metrics(tsOutData, pmdTempStruct, parameters, cadenceTimestamps, cadenceGapIndicators, cdppString, 'mag15', 'sixHour'   );
subplot(4,3,9)
pmd_plot_cdpp_metrics(tsOutData, pmdTempStruct, parameters, cadenceTimestamps, cadenceGapIndicators, cdppString, 'mag15', 'twelveHour');

cdppString = 'cdppExpected';
figure(17)
subplot(4,3,1)
pmd_plot_cdpp_metrics(tsOutData, pmdTempStruct, parameters, cadenceTimestamps, cadenceGapIndicators, cdppString, 'mag9',  'threeHour' );
subplot(4,3,2)
pmd_plot_cdpp_metrics(tsOutData, pmdTempStruct, parameters, cadenceTimestamps, cadenceGapIndicators, cdppString, 'mag9',  'sixHour'   );
subplot(4,3,3)
pmd_plot_cdpp_metrics(tsOutData, pmdTempStruct, parameters, cadenceTimestamps, cadenceGapIndicators, cdppString, 'mag9',  'twelveHour');
subplot(4,3,4)
pmd_plot_cdpp_metrics(tsOutData, pmdTempStruct, parameters, cadenceTimestamps, cadenceGapIndicators, cdppString, 'mag10', 'threeHour' );
subplot(4,3,5)
pmd_plot_cdpp_metrics(tsOutData, pmdTempStruct, parameters, cadenceTimestamps, cadenceGapIndicators, cdppString, 'mag10', 'sixHour'   );
subplot(4,3,6)
pmd_plot_cdpp_metrics(tsOutData, pmdTempStruct, parameters, cadenceTimestamps, cadenceGapIndicators, cdppString, 'mag10', 'twelveHour');
subplot(4,3,7)
pmd_plot_cdpp_metrics(tsOutData, pmdTempStruct, parameters, cadenceTimestamps, cadenceGapIndicators, cdppString, 'mag11', 'threeHour' );
subplot(4,3,8)
pmd_plot_cdpp_metrics(tsOutData, pmdTempStruct, parameters, cadenceTimestamps, cadenceGapIndicators, cdppString, 'mag11', 'sixHour'   );
subplot(4,3,9)
pmd_plot_cdpp_metrics(tsOutData, pmdTempStruct, parameters, cadenceTimestamps, cadenceGapIndicators, cdppString, 'mag11', 'twelveHour');
subplot(4,3,10)
pmd_plot_cdpp_metrics(tsOutData, pmdTempStruct, parameters, cadenceTimestamps, cadenceGapIndicators, cdppString, 'mag12', 'threeHour' );
subplot(4,3,11)
pmd_plot_cdpp_metrics(tsOutData, pmdTempStruct, parameters, cadenceTimestamps, cadenceGapIndicators, cdppString, 'mag12', 'sixHour'   );
subplot(4,3,12)
pmd_plot_cdpp_metrics(tsOutData, pmdTempStruct, parameters, cadenceTimestamps, cadenceGapIndicators, cdppString, 'mag12', 'twelveHour');

figure(18)
subplot(4,3,1)
pmd_plot_cdpp_metrics(tsOutData, pmdTempStruct, parameters, cadenceTimestamps, cadenceGapIndicators, cdppString, 'mag13', 'threeHour' );
subplot(4,3,2)
pmd_plot_cdpp_metrics(tsOutData, pmdTempStruct, parameters, cadenceTimestamps, cadenceGapIndicators, cdppString, 'mag13', 'sixHour'   );
subplot(4,3,3)
pmd_plot_cdpp_metrics(tsOutData, pmdTempStruct, parameters, cadenceTimestamps, cadenceGapIndicators, cdppString, 'mag13', 'twelveHour');
subplot(4,3,4)
pmd_plot_cdpp_metrics(tsOutData, pmdTempStruct, parameters, cadenceTimestamps, cadenceGapIndicators, cdppString, 'mag14', 'threeHour' );
subplot(4,3,5)
pmd_plot_cdpp_metrics(tsOutData, pmdTempStruct, parameters, cadenceTimestamps, cadenceGapIndicators, cdppString, 'mag14', 'sixHour'   );
subplot(4,3,6)
pmd_plot_cdpp_metrics(tsOutData, pmdTempStruct, parameters, cadenceTimestamps, cadenceGapIndicators, cdppString, 'mag14', 'twelveHour');
subplot(4,3,7)
pmd_plot_cdpp_metrics(tsOutData, pmdTempStruct, parameters, cadenceTimestamps, cadenceGapIndicators, cdppString, 'mag15', 'threeHour' );
subplot(4,3,8)
pmd_plot_cdpp_metrics(tsOutData, pmdTempStruct, parameters, cadenceTimestamps, cadenceGapIndicators, cdppString, 'mag15', 'sixHour'   );
subplot(4,3,9)
pmd_plot_cdpp_metrics(tsOutData, pmdTempStruct, parameters, cadenceTimestamps, cadenceGapIndicators, cdppString, 'mag15', 'twelveHour');

cdppString = 'cdppRatio';
figure(19)
subplot(4,3,1)
pmd_plot_cdpp_metrics(tsOutData, pmdTempStruct, parameters, cadenceTimestamps, cadenceGapIndicators, cdppString, 'mag9',  'threeHour' );
subplot(4,3,2)
pmd_plot_cdpp_metrics(tsOutData, pmdTempStruct, parameters, cadenceTimestamps, cadenceGapIndicators, cdppString, 'mag9',  'sixHour'   );
subplot(4,3,3)
pmd_plot_cdpp_metrics(tsOutData, pmdTempStruct, parameters, cadenceTimestamps, cadenceGapIndicators, cdppString, 'mag9',  'twelveHour');
subplot(4,3,4)
pmd_plot_cdpp_metrics(tsOutData, pmdTempStruct, parameters, cadenceTimestamps, cadenceGapIndicators, cdppString, 'mag10', 'threeHour' );
subplot(4,3,5)
pmd_plot_cdpp_metrics(tsOutData, pmdTempStruct, parameters, cadenceTimestamps, cadenceGapIndicators, cdppString, 'mag10', 'sixHour'   );
subplot(4,3,6)
pmd_plot_cdpp_metrics(tsOutData, pmdTempStruct, parameters, cadenceTimestamps, cadenceGapIndicators, cdppString, 'mag10', 'twelveHour');
subplot(4,3,7)
pmd_plot_cdpp_metrics(tsOutData, pmdTempStruct, parameters, cadenceTimestamps, cadenceGapIndicators, cdppString, 'mag11', 'threeHour' );
subplot(4,3,8)
pmd_plot_cdpp_metrics(tsOutData, pmdTempStruct, parameters, cadenceTimestamps, cadenceGapIndicators, cdppString, 'mag11', 'sixHour'   );
subplot(4,3,9)
pmd_plot_cdpp_metrics(tsOutData, pmdTempStruct, parameters, cadenceTimestamps, cadenceGapIndicators, cdppString, 'mag11', 'twelveHour');
subplot(4,3,10)
pmd_plot_cdpp_metrics(tsOutData, pmdTempStruct, parameters, cadenceTimestamps, cadenceGapIndicators, cdppString, 'mag12', 'threeHour' );
subplot(4,3,11)
pmd_plot_cdpp_metrics(tsOutData, pmdTempStruct, parameters, cadenceTimestamps, cadenceGapIndicators, cdppString, 'mag12', 'sixHour'   );
subplot(4,3,12)
pmd_plot_cdpp_metrics(tsOutData, pmdTempStruct, parameters, cadenceTimestamps, cadenceGapIndicators, cdppString, 'mag12', 'twelveHour');

figure(20)
subplot(4,3,1)
pmd_plot_cdpp_metrics(tsOutData, pmdTempStruct, parameters, cadenceTimestamps, cadenceGapIndicators, cdppString, 'mag13', 'threeHour' );
subplot(4,3,2)
pmd_plot_cdpp_metrics(tsOutData, pmdTempStruct, parameters, cadenceTimestamps, cadenceGapIndicators, cdppString, 'mag13', 'sixHour'   );
subplot(4,3,3)
pmd_plot_cdpp_metrics(tsOutData, pmdTempStruct, parameters, cadenceTimestamps, cadenceGapIndicators, cdppString, 'mag13', 'twelveHour');
subplot(4,3,4)
pmd_plot_cdpp_metrics(tsOutData, pmdTempStruct, parameters, cadenceTimestamps, cadenceGapIndicators, cdppString, 'mag14', 'threeHour' );
subplot(4,3,5)
pmd_plot_cdpp_metrics(tsOutData, pmdTempStruct, parameters, cadenceTimestamps, cadenceGapIndicators, cdppString, 'mag14', 'sixHour'   );
subplot(4,3,6)
pmd_plot_cdpp_metrics(tsOutData, pmdTempStruct, parameters, cadenceTimestamps, cadenceGapIndicators, cdppString, 'mag14', 'twelveHour');
subplot(4,3,7)
pmd_plot_cdpp_metrics(tsOutData, pmdTempStruct, parameters, cadenceTimestamps, cadenceGapIndicators, cdppString, 'mag15', 'threeHour' );
subplot(4,3,8)
pmd_plot_cdpp_metrics(tsOutData, pmdTempStruct, parameters, cadenceTimestamps, cadenceGapIndicators, cdppString, 'mag15', 'sixHour'   );
subplot(4,3,9)
pmd_plot_cdpp_metrics(tsOutData, pmdTempStruct, parameters, cadenceTimestamps, cadenceGapIndicators, cdppString, 'mag15', 'twelveHour');

return

