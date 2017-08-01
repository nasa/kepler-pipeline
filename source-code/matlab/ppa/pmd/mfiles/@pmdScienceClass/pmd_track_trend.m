function [pmdOutputStruct, pmdTempStruct] = pmd_track_trend(pmdScienceObject, pmdOutputStruct, pmdTempStruct)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function [pmdOutputStruct, pmdTempStruct] = pmd_track_trend(pmdScienceObject, pmdOutputStruct, pmdTempStruct)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Perform track and trend for PPA metrics. Smoothing factor and fixed bounds
% for checking against each metric time series are provided through the 
% pmdModuleParameters structure in pmdInputStruct.
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
% Reports for each of the pmd metrics will be appended to the main report.
tsData    = pmdScienceObject.inputTsData;

% Get the metric time series data generted within PMD.
tsOutData = pmdOutputStruct.outputTsData;

% Get {module, output} pair and write to report sturucture for output
ccdModule = pmdScienceObject.ccdModule;
ccdOutput = pmdScienceObject.ccdOutput;

[pmdOutputStruct, pmdTempStruct] = pmd_track_trend_time_series_metrics(tsData,  pmdOutputStruct, pmdTempStruct, ...
    parameters, cadenceTimestamps, cadenceGapIndicators, ccdModule, ccdOutput, 'blackLevel');

[pmdOutputStruct, pmdTempStruct] = pmd_track_trend_time_series_metrics(tsData,  pmdOutputStruct, pmdTempStruct, ...
    parameters, cadenceTimestamps, cadenceGapIndicators, ccdModule, ccdOutput, 'smearLevel');

[pmdOutputStruct, pmdTempStruct] = pmd_track_trend_time_series_metrics(tsData,  pmdOutputStruct, pmdTempStruct, ...
    parameters, cadenceTimestamps, cadenceGapIndicators, ccdModule, ccdOutput, 'darkCurrent');

for iTwoDBlack = 1:length(tsData.twoDBlack)
    [pmdOutputStruct, pmdTempStruct] = pmd_track_trend_metrics_array(tsData,  pmdOutputStruct, pmdTempStruct, ...
        parameters, cadenceTimestamps, cadenceGapIndicators, ccdModule, ccdOutput, iTwoDBlack,      'twoDBlack'     );
end
for iLdeUndershoot = 1:length(tsData.ldeUndershoot)
    [pmdOutputStruct, pmdTempStruct] = pmd_track_trend_metrics_array(tsData,  pmdOutputStruct, pmdTempStruct, ...
        parameters, cadenceTimestamps, cadenceGapIndicators, ccdModule, ccdOutput, iLdeUndershoot,  'ldeUndershoot' );
end

[pmdOutputStruct, pmdTempStruct] = pmd_track_trend_time_series_metrics(tsData,  pmdOutputStruct, pmdTempStruct, ...
    parameters, cadenceTimestamps, cadenceGapIndicators, ccdModule, ccdOutput, 'theoreticalCompressionEfficiency', 'compression');

[pmdOutputStruct, pmdTempStruct] = pmd_track_trend_time_series_metrics(tsData,  pmdOutputStruct, pmdTempStruct, ...
    parameters, cadenceTimestamps, cadenceGapIndicators, ccdModule, ccdOutput, 'achievedCompressionEfficiency',    'compression');

crFieldString = {'hitRate', 'meanEnergy', 'energyVariance', 'energySkewness', 'energyKurtosis'};
if ( ~tsData.blackCosmicRayMetrics.empty )
    for iCrField = 1:length(crFieldString)
        [pmdOutputStruct, pmdTempStruct] = pmd_track_trend_cosmic_ray_metrics(tsData,  pmdOutputStruct, pmdTempStruct, ...
            parameters, cadenceTimestamps, cadenceGapIndicators, ccdModule, ccdOutput, 'black',        crFieldString{iCrField});
    end
end
if ( ~tsData.maskedSmearCosmicRayMetrics.empty )
    for iCrField = 1:length(crFieldString)
        [pmdOutputStruct, pmdTempStruct] = pmd_track_trend_cosmic_ray_metrics(tsData,  pmdOutputStruct, pmdTempStruct, ...
            parameters, cadenceTimestamps, cadenceGapIndicators, ccdModule, ccdOutput, 'maskedSmear',  crFieldString{iCrField});
    end
end
if ( ~tsData.virtualSmearCosmicRayMetrics.empty )
    for iCrField = 1:length(crFieldString)
        [pmdOutputStruct, pmdTempStruct] = pmd_track_trend_cosmic_ray_metrics(tsData,  pmdOutputStruct, pmdTempStruct, ...
            parameters, cadenceTimestamps, cadenceGapIndicators, ccdModule, ccdOutput, 'virtualSmear', crFieldString{iCrField});
    end
end
if ( ~tsData.targetStarCosmicRayMetrics.empty )
    for iCrField = 1:length(crFieldString)
        [pmdOutputStruct, pmdTempStruct] = pmd_track_trend_cosmic_ray_metrics(tsData,  pmdOutputStruct, pmdTempStruct, ...
            parameters, cadenceTimestamps, cadenceGapIndicators, ccdModule, ccdOutput, 'targetStar',   crFieldString{iCrField});
    end
end
if ( ~tsData.backgroundCosmicRayMetrics.empty )
    for iCrField = 1:length(crFieldString)
        [pmdOutputStruct, pmdTempStruct] = pmd_track_trend_cosmic_ray_metrics(tsData,  pmdOutputStruct, pmdTempStruct, ...
            parameters, cadenceTimestamps, cadenceGapIndicators, ccdModule, ccdOutput, 'background',   crFieldString{iCrField});
    end
end

[pmdOutputStruct, pmdTempStruct] = pmd_track_trend_time_series_metrics(tsData,    pmdOutputStruct, pmdTempStruct, ...
    parameters, cadenceTimestamps, cadenceGapIndicators, ccdModule, ccdOutput, 'brightness'         );

[pmdOutputStruct, pmdTempStruct] = pmd_track_trend_time_series_metrics(tsData,    pmdOutputStruct, pmdTempStruct, ...
    parameters, cadenceTimestamps, cadenceGapIndicators, ccdModule, ccdOutput, 'encircledEnergy'    );

[pmdOutputStruct, pmdTempStruct] = pmd_track_trend_time_series_metrics(tsOutData, pmdOutputStruct, pmdTempStruct, ...
    parameters, cadenceTimestamps, cadenceGapIndicators, ccdModule, ccdOutput, 'backgroundLevel'    );

[pmdOutputStruct, pmdTempStruct] = pmd_track_trend_time_series_metrics(tsOutData, pmdOutputStruct, pmdTempStruct, ...
    parameters, cadenceTimestamps, cadenceGapIndicators, ccdModule, ccdOutput, 'centroidsMeanRow'   );

[pmdOutputStruct, pmdTempStruct] = pmd_track_trend_time_series_metrics(tsOutData, pmdOutputStruct, pmdTempStruct, ...
    parameters, cadenceTimestamps, cadenceGapIndicators, ccdModule, ccdOutput, 'centroidsMeanColumn');

[pmdOutputStruct, pmdTempStruct] = pmd_track_trend_time_series_metrics(tsOutData, pmdOutputStruct, pmdTempStruct, ...
    parameters, cadenceTimestamps, cadenceGapIndicators, ccdModule, ccdOutput, 'plateScale'         );

magString  = { 'mag9', 'mag10', 'mag11', 'mag12', 'mag13', 'mag14', 'mag15' };
hourString = { 'threeHour', 'sixHour', 'twelveHour' };
for iMag = 1:length(magString)
    for iHour = 1:length(hourString)
        [pmdOutputStruct, pmdTempStruct] = pmd_track_trend_cdpp_metrics(tsOutData, pmdOutputStruct, pmdTempStruct, ...
           parameters, cadenceTimestamps, cadenceGapIndicators, ccdModule, ccdOutput, 'cdppMeasured', magString{iMag},  hourString{iHour});
        [pmdOutputStruct, pmdTempStruct] = pmd_track_trend_cdpp_metrics(tsOutData, pmdOutputStruct, pmdTempStruct, ...
           parameters, cadenceTimestamps, cadenceGapIndicators, ccdModule, ccdOutput, 'cdppExpected', magString{iMag},  hourString{iHour});
        [pmdOutputStruct, pmdTempStruct] = pmd_track_trend_cdpp_metrics(tsOutData, pmdOutputStruct, pmdTempStruct, ...
           parameters, cadenceTimestamps, cadenceGapIndicators, ccdModule, ccdOutput, 'cdppRatio',    magString{iMag},  hourString{iHour});
    end
end

return
