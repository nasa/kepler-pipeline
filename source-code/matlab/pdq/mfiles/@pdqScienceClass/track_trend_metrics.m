function [pdqOutputStruct] = ...
track_trend_metrics(pdqScienceObject, pdqOutputStruct, nModOuts, ...
modOutsProcessed)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function [pdqOutputStruct] = ...
% track_trend_metrics(pdqScienceObject, pdqOutputStruct, nModOuts, ...
% modOutsProcessed)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Perform tracking and trending for each of the 10 PDQ metrics independently
% for all mod/outs. Fixed bounds for checking against each metric time
% series are provided through the PDQ configuration parameters. These apply
% to all mod/outs.
%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% INPUT:  The following arguments are specified for this function.
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
%              pdqScienceObject: [object]  object instantiated from PDQ input structure
%               pdqOutputStruct: [struct]  PDQ output structure
%                         nModOuts: [int]  number of module outputs
%       modOutsProcessed: [logical array]  indicators for module outputs
%                                          processed by PDQ
%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% OUTPUT:  A data structure pdqOutputStruct with the following *tracking and
%          trending* fields. The other output fields are not described here.
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%   Top level:
%
%     pdqOutputStruct contains the following tracking and trending fields:
%
%  pdqModuleOutputReports: [struct array]  tracking and trending reports,
%                                          one per module output
%           pdqFocalPlaneReport: [struct]  tracking and trending report on
%                                          delta attitude
%
%--------------------------------------------------------------------------
%   Second level:
%
%     pdqOutputStruct.pdqModuleOutputReports is a struct array with the following fields:
%
%                        ccdModule: [int]  CCD module number
%                        ccdOutput: [int]  CCD output number
%               backgroundLevel: [struct]  report for background level metric
%                    blackLevel: [struct]  report for black level metric
%              centroidsMeanCol: [struct]  report for centroids mean column metric
%              centroidsMeanRow: [struct]  report for centroids mean row metric
%                   darkCurrent: [struct]  report for dark current metric
%                  dynamicRange: [struct]  report for dynamic range metric
%               encircledEnergy: [struct]  report for encircled energy metric
%                      meanFlux: [struct]  report for mean flux metric
%                    plateScale: [struct]  report for plate scale metric
%                    smearLevel: [struct]  report for smear level metric
%
%--------------------------------------------------------------------------
%   Second level:
%
%     pdqOutputStruct.pdqFocalPlaneReport is a struct array with the following fields:
%
%               deltaAttitudeRa: [struct]  report for delta attitude ra metric
%              deltaAttitudeDec: [struct]  report for delta attitude dec metric
%             deltaAttitudeRoll: [struct]  report for delta attitude roll metric
%   maxAttitudeResidualInPixels: [struct]  report for max attitude residual
%
%--------------------------------------------------------------------------
%   Third level
%
%     The PDQ metric report structs all contain the following fields:
%
%                          value: [float]  value of metric at specified time
%                                          (typically last valid sample of metric)
%                    uncertainty: [float]  uncertainty in metric at specified time
%                          time: [double]  time tag for value and uncertainty (MJD)
%          adaptiveBoundsReport: [struct]  adaptive bounds tracking and trending report
%             fixedBoundsReport: [struct]  fixed bounds tracking and trending report
%                  alerts: [struct array]  alerts to operator
%
%--------------------------------------------------------------------------
%   Fourth level
%
%     The PDQ adaptive and fixed bounds report structs contain the following
%     fields:
%
%              outOfUpperBound: [logical]  metric out of upper bound at report time
%              outOfLowerBound: [logical]  metric out of lower bound at report time
%            outOfUpperBoundsCount: [int]  count of metric samples exceeding upper bound
%            outOfLowerBoundsCount: [int]  count of metric samples exceeding lower bound
%   outOfUpperBoundsTimes: [double array]  times that metric has exceeded upper bound (MJD)
%   outOfLowerBoundsTimes: [double array]  times that metric has exceeded lower bound (MJD)
%  upperBoundCrossingPredicted: [logical]  true if trend in metric crosses upper bound
%                                          within horizon time
%  lowerBoundCrossingPredicted: [logical]  true if trend in metric crosses lower bound
%                                          within horizon time
%                  crossingTime: [double]  predicted bound crossing time (MJD)
%
%
%     The PDQ alerts is an array of structs with the following fields:
%
%                          time: [double]  time of alert to operator (MJD); same as
%                                          time of last valid metric sample
%                      severity: [string]  'error' or 'warning'
%                       message: [string]  error or warning message
%
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


% Get the fixed bounds and new sample times from the input PDQ science
% object.
pdqConfiguration = pdqScienceObject.pdqConfiguration;

debugLevel = pdqConfiguration.debugLevel;

backgroundLevelFixedLowerBound = ...
    pdqConfiguration.backgroundLevelFixedLowerBound;
backgroundLevelFixedUpperBound = ...
    pdqConfiguration.backgroundLevelFixedUpperBound;
blackLevelFixedLowerBound = ...
    pdqConfiguration.blackLevelFixedLowerBound;
blackLevelFixedUpperBound = ...
    pdqConfiguration.blackLevelFixedUpperBound;
centroidsMeanColFixedLowerBound = ...
    pdqConfiguration.centroidsMeanColFixedLowerBound;
centroidsMeanColFixedUpperBound = ...
    pdqConfiguration.centroidsMeanColFixedUpperBound;
centroidsMeanRowFixedLowerBound = ...
    pdqConfiguration.centroidsMeanRowFixedLowerBound;
centroidsMeanRowFixedUpperBound = ...
    pdqConfiguration.centroidsMeanRowFixedUpperBound;
darkCurrentFixedLowerBound = ...
    pdqConfiguration.darkCurrentFixedLowerBound;
darkCurrentFixedUpperBound = ...
    pdqConfiguration.darkCurrentFixedUpperBound;
dynamicRangeFixedLowerBound = ...
    pdqConfiguration.dynamicRangeFixedLowerBound;
dynamicRangeFixedUpperBound = ...
    pdqConfiguration.dynamicRangeFixedUpperBound;
encircledEnergyFixedLowerBound = ...
    pdqConfiguration.encircledEnergyFixedLowerBound;
encircledEnergyFixedUpperBound = ...
    pdqConfiguration.encircledEnergyFixedUpperBound;
meanFluxFixedLowerBound = ...
    pdqConfiguration.meanFluxFixedLowerBound;
meanFluxFixedUpperBound = ...
    pdqConfiguration.meanFluxFixedUpperBound;
plateScaleFixedLowerBound = ...
    pdqConfiguration.plateScaleFixedLowerBound;
plateScaleFixedUpperBound = ...
    pdqConfiguration.plateScaleFixedUpperBound;
smearLevelFixedLowerBound = ...
    pdqConfiguration.smearLevelFixedLowerBound;
smearLevelFixedUpperBound = ...
    pdqConfiguration.smearLevelFixedUpperBound;

deltaAttitudeRaFixedLowerBound = ...
    pdqConfiguration.deltaAttitudeRaFixedLowerBound;
deltaAttitudeRaFixedUpperBound = ...
    pdqConfiguration.deltaAttitudeRaFixedUpperBound;
deltaAttitudeDecFixedLowerBound = ...
    pdqConfiguration.deltaAttitudeDecFixedLowerBound;
deltaAttitudeDecFixedUpperBound = ...
    pdqConfiguration.deltaAttitudeDecFixedUpperBound;
deltaAttitudeRollFixedLowerBound = ...
    pdqConfiguration.deltaAttitudeRollFixedLowerBound;
deltaAttitudeRollFixedUpperBound = ...
    pdqConfiguration.deltaAttitudeRollFixedUpperBound;
maxAttitudeResidualInPixelsFixedLowerBound = ...
    pdqConfiguration.maxAttitudeResidualInPixelsFixedLowerBound;
maxAttitudeResidualInPixelsFixedUpperBound = ...
    pdqConfiguration.maxAttitudeResidualInPixelsFixedUpperBound;

newSampleTimes = pdqScienceObject.cadenceTimes;

% Get the cadence times for the metrics from the PDQ output structure.
cadenceTimes = pdqOutputStruct.outputPdqTsData.cadenceTimes;

% Loop over the mod/outs.
for currentModOut = 1 : nModOuts
    
    % If the given mod out was not processed to completion, do not attempt
    % to track and trend the metrics.
    if ~modOutsProcessed(currentModOut)
        continue;
    end
    
    % Get the metric time series data for the given mod/out, and also get the
    % main report structure for the given mod/out. Reports for each of the 10
    % PDQ metrics will be appended to the main report.
    moduleOutputTsData = ...
        pdqOutputStruct.outputPdqTsData.pdqModuleOutputTsData(currentModOut);
    report = pdqOutputStruct.pdqModuleOutputReports(currentModOut);
    ccdModule = report.ccdModule;
    ccdOutput = report.ccdOutput;
    
    % Set up summary subplot if the debug level is set.
    if debugLevel
        close all;
        h1 = subplot(4, 3, 1);
        hold on
    end
    
    % Create the background level report for the given mod/out.
    [report.backgroundLevel] = ...
        create_report(pdqScienceObject, moduleOutputTsData.backgroundLevels, ...
        backgroundLevelFixedLowerBound, backgroundLevelFixedUpperBound, ...
        'Background Level', 'e-', cadenceTimes, newSampleTimes, true, ...
        [4, 3, 1], ccdModule, ccdOutput, currentModOut);
    
    % Create the black level report for the given mod/out.
    [report.blackLevel] = ...
        create_report(pdqScienceObject, moduleOutputTsData.blackLevels, ...
        blackLevelFixedLowerBound, blackLevelFixedUpperBound, ...
        'Black Level', 'ADU', cadenceTimes, newSampleTimes, true, ...
        [4, 3, 2], ccdModule, ccdOutput, currentModOut);
    
    % Create the centroids mean column report for the given mod/out.
    [report.centroidsMeanCol] = ...
        create_report(pdqScienceObject, moduleOutputTsData.centroidsMeanCols, ...
        centroidsMeanColFixedLowerBound, centroidsMeanColFixedUpperBound, ...
        'Centroids Mean Column', 'Pixels', cadenceTimes, newSampleTimes, ...
        true, [4, 3, 3], ccdModule, ccdOutput, currentModOut);
    
    % Create the centroids mean row report for the given mod/out.
    [report.centroidsMeanRow] = ...
        create_report(pdqScienceObject, moduleOutputTsData.centroidsMeanRows, ...
        centroidsMeanRowFixedLowerBound, centroidsMeanRowFixedUpperBound, ...
        'Centroids Mean Row', 'Pixels', cadenceTimes, newSampleTimes, true, ...
        [4, 3, 4], ccdModule, ccdOutput, currentModOut);
    
    % Create the dark current report for the given mod/out.
    [report.darkCurrent] = ...
        create_report(pdqScienceObject, moduleOutputTsData.darkCurrents, ...
        darkCurrentFixedLowerBound, darkCurrentFixedUpperBound, ...
        'Dark Current', 'e-/sec', cadenceTimes, newSampleTimes, true, ...
        [4, 3, 5], ccdModule, ccdOutput, currentModOut);
    
    % Create the dark current report for the given mod/out.
    [report.dynamicRange] = ...
        create_report(pdqScienceObject, moduleOutputTsData.dynamicRanges, ...
        dynamicRangeFixedLowerBound, dynamicRangeFixedUpperBound, ...
        'Dynamic Range', 'ADU', cadenceTimes, newSampleTimes, true, ...
        [4, 3, 6], ccdModule, ccdOutput, currentModOut);
    
    % Create the encircled energy report for the given mod/out.
    [report.encircledEnergy] = ...
        create_report(pdqScienceObject, moduleOutputTsData.encircledEnergies, ...
        encircledEnergyFixedLowerBound, encircledEnergyFixedUpperBound, ...
        'Encircled Energy', 'Pixels', cadenceTimes, newSampleTimes, true, ...
        [4, 3 7], ccdModule, ccdOutput, currentModOut);
    
    % Create the mean flux report for the given mod/out.
    [report.meanFlux] = ...
        create_report(pdqScienceObject, moduleOutputTsData.meanFluxes, ...
        meanFluxFixedLowerBound, meanFluxFixedUpperBound, ...
        'Mean Flux', 'Unitless', cadenceTimes, newSampleTimes, true, ...
        [4, 3 8], ccdModule, ccdOutput, currentModOut);
    
    % Create the plate scale report for the given mod/out.
    [report.plateScale] = ...
        create_report(pdqScienceObject, moduleOutputTsData.plateScales, ...
        plateScaleFixedLowerBound, plateScaleFixedUpperBound, ...
        'Plate Scale', 'Unitless', cadenceTimes, newSampleTimes, true, ...
        [4, 3 9], ccdModule, ccdOutput, currentModOut);
    
    % Create the smear level report for the given mod/out.
    [report.smearLevel] = ...
        create_report(pdqScienceObject, moduleOutputTsData.smearLevels, ...
        smearLevelFixedLowerBound, smearLevelFixedUpperBound, ...
        'Smear Level', 'e-', cadenceTimes, newSampleTimes, true, ...
        [4, 3, 10], ccdModule, ccdOutput, currentModOut);
    
    % Generate summary plot with all metrics for the given module output.
    if debugLevel
        
        subplot(4, 3, 11)
        textput(0.2, 0.6, ['Module Output = ', num2str(ccdModule), '/', num2str(ccdOutput)]);
        textput(0.2, 0.4, ['All vs. Elapsed Days from ', mjd_to_utc(fix(cadenceTimes(1)), 0)]);
        axis off
    
        isLandscapeOrientation = true;
        includeTimeFlag = false;
        printJpgFlag = false;
        fileNameStr = ['tracking_trending_summary_module_'  num2str(ccdModule) '_output_', num2str(ccdOutput)  '_modout_' num2str(currentModOut)];
        plot_to_file(fileNameStr, isLandscapeOrientation, includeTimeFlag, printJpgFlag);
        
    end % if
    
    pdqOutputStruct.pdqModuleOutputReports(currentModOut) = report;
    
end % for currentModOut

clear report;

% Create the attitude report for the focal plane metrics.
outputPdqTsData = pdqOutputStruct.outputPdqTsData;

close all;
[report.deltaAttitudeRa] = ...
    create_report(pdqScienceObject, outputPdqTsData.deltaAttitudeRa, ...
    deltaAttitudeRaFixedLowerBound, deltaAttitudeRaFixedUpperBound, ...
    'Delta Attitude Ra', 'Arc Sec', cadenceTimes, newSampleTimes, false);

[report.deltaAttitudeDec] = ...
    create_report(pdqScienceObject, outputPdqTsData.deltaAttitudeDec, ...
    deltaAttitudeDecFixedLowerBound, deltaAttitudeDecFixedUpperBound, ...
    'Delta Attitude Dec', 'Arc Sec', cadenceTimes, newSampleTimes, false);

[report.deltaAttitudeRoll] = ...
    create_report(pdqScienceObject, outputPdqTsData.deltaAttitudeRoll, ...
    deltaAttitudeRollFixedLowerBound, deltaAttitudeRollFixedUpperBound, ...
    'Delta Attitude Roll', 'Arc Sec', cadenceTimes, newSampleTimes, false);

[report.maxAttitudeResidualInPixels] = ...
    create_report(pdqScienceObject, outputPdqTsData.maxAttitudeResidualInPixels, ...
    maxAttitudeResidualInPixelsFixedLowerBound, maxAttitudeResidualInPixelsFixedUpperBound, ...
    'Max Attitude Residual', 'Pixels', cadenceTimes, newSampleTimes, true);

pdqOutputStruct.pdqFocalPlaneReport = report;

% Return.
return
