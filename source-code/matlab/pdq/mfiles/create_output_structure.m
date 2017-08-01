function  pdqOutputStruct = create_output_structure(nModuleOutputs)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function  pdqOutputStruct = create_output_structure(nModuleOutputs)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% This function defines the pdqOutputStruct which has been agreed upon by
% the Matlab and Java interface. This structure will be serialized by the
% auto-generated script into an outputs.bin file.
% create output structure
% step 1: define top level fields
% step 2: define outputPdqTsData.pdqModuleOutputTsData fields
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
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
moduleOutputStruct.ccdModule                       = [];   % CCD Module value
moduleOutputStruct.ccdOutput                       = [];   % CCD ouput value (1 - 84)


timeSeriesStruct = struct('values',[], 'gapIndicators', [], 'uncertainties', []);

moduleOutputStruct.blackLevels                     = timeSeriesStruct;   % black levels per CCD module/ouput
moduleOutputStruct.smearLevels                     = timeSeriesStruct;   % smear levels per CCD module/ouput
moduleOutputStruct.darkCurrents                    = timeSeriesStruct;   % dark current per CCD module/ouput
moduleOutputStruct.backgroundLevels                = timeSeriesStruct;   % Measured background level per CCD module/ouput
moduleOutputStruct.dynamicRanges                   = timeSeriesStruct;   % reported max value - min value in ADU
moduleOutputStruct.meanFluxes                      = timeSeriesStruct;   % mean flux for targets in PDQ list
moduleOutputStruct.centroidsMeanRows               = timeSeriesStruct;   % Mean centroid - row value
moduleOutputStruct.centroidsMeanCols               = timeSeriesStruct;   % mean centroid - column value
moduleOutputStruct.encircledEnergies               = timeSeriesStruct;   % Encircled energy time series
moduleOutputStruct.plateScales                     = timeSeriesStruct;   % Results of plate scale algorithm

pdqModuleOutputTsData = repmat(moduleOutputStruct, nModuleOutputs, 1);

outputPdqTsData.pdqModuleOutputTsData           = pdqModuleOutputTsData;

%----------------------------------------------------------------------
% Output structure step 3: define the rest of the outputPdqTsData
%----------------------------------------------------------------------
outputPdqTsData.cadenceTimes = [];

outputPdqTsData.attitudeSolutionRa              = timeSeriesStruct;
outputPdqTsData.attitudeSolutionDec             = timeSeriesStruct;
outputPdqTsData.attitudeSolutionRoll            = timeSeriesStruct;

outputPdqTsData.desiredAttitudeRa               = timeSeriesStruct;
outputPdqTsData.desiredAttitudeDec              = timeSeriesStruct;
outputPdqTsData.desiredAttitudeRoll             = timeSeriesStruct;

outputPdqTsData.deltaAttitudeRa                 = timeSeriesStruct;
outputPdqTsData.deltaAttitudeDec                = timeSeriesStruct;
outputPdqTsData.deltaAttitudeRoll               = timeSeriesStruct;

outputPdqTsData.maxAttitudeResidualInPixels     = timeSeriesStruct;




% summary report struct



boundsStruct  = struct('outOfUpperBound', false, 'outOfLowerBound', false, ...
    'outOfUpperBoundsCount', 0, 'outOfLowerBoundsCount', 0, ...
    'outOfUpperBoundsTimes', [], 'outOfLowerBoundsTimes', [], ...
    'upperBound', -1, 'lowerBound', -1, ...
    'upperBoundCrossingPredicted', false, 'lowerBoundCrossingPredicted', false, ...
    'crossingTime', -1);

timeSeriesReportStruct = struct('time', -1, 'value', -1, 'uncertainty', -1, ...
    'adaptiveBoundsReport', boundsStruct, 'fixedBoundsReport', boundsStruct, ...
    'alerts', []);



moduleSummaryStruct.ccdModule           = [];
moduleSummaryStruct.ccdOutput           = [];
moduleSummaryStruct.blackLevel          = timeSeriesReportStruct;   % black levels per CCD module/ouput
moduleSummaryStruct.smearLevel          = timeSeriesReportStruct;   % smear levels per CCD module/ouput
moduleSummaryStruct.darkCurrent         = timeSeriesReportStruct;   % dark current per CCD module/ouput
moduleSummaryStruct.backgroundLevel     = timeSeriesReportStruct;   % Measured background level per CCD module/ouput
moduleSummaryStruct.dynamicRange        = timeSeriesReportStruct;   % reported max value - min value in ADU
moduleSummaryStruct.meanFlux            = timeSeriesReportStruct;   % mean flux for targets in PDQ list
moduleSummaryStruct.centroidsMeanRow    = timeSeriesReportStruct;   % Mean centroid - row value
moduleSummaryStruct.centroidsMeanCol    = timeSeriesReportStruct;   % mean centroid - column value
moduleSummaryStruct.encircledEnergy     = timeSeriesReportStruct;   % Encircled energy time series
moduleSummaryStruct.plateScale          = timeSeriesReportStruct;   % Results of plate scale algorithm

summaryReport = repmat(moduleSummaryStruct, nModuleOutputs, 1);

focalPlaneReportStruct.deltaAttitudeRa    = timeSeriesReportStruct;   % desired minus actual attitude, Ra
focalPlaneReportStruct.deltaAttitudeDec   = timeSeriesReportStruct;   % desired minus actual attitude, Dec
focalPlaneReportStruct.deltaAttitudeRoll  = timeSeriesReportStruct;   % desired minus actual attitude, Roll
focalPlaneReportStruct.maxAttitudeResidualInPixels  = ...
    timeSeriesReportStruct;                                           % max attitude residual, pixels

attitudeAdjustments = struct('quaternion', []);

pdqOutputStruct = struct('outputPdqTsData', outputPdqTsData, 'attitudeAdjustments', attitudeAdjustments, ...
    'pdqModuleOutputReports',  summaryReport, 'pdqFocalPlaneReport', focalPlaneReportStruct);




return

