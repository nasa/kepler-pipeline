function [ tpsInputStruct ] = tps_convert_92_data_to_93( tpsInputStruct )
%
% tps_convert_92_data_to_93 -- convert TPS inputs 
%
% tpsInputStruct = tps_convert_92_data_to_93( tpsInputStruct ) handles all necessary input
%    field additions, deletions, or modifications needed to allow a data struct from TPS
%    version 9.2 to run in TPS version 9.3 while the latter is under development.
%
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

%=========================================================================================

if isfield( tpsInputStruct.tpsModuleParameters, 'sesProbabilityThreshold' ) 
    tpsInputStruct.tpsModuleParameters = rmfield(tpsInputStruct.tpsModuleParameters,'sesProbabilityThreshold');
end

if ~isfield(tpsInputStruct.tpsModuleParameters, 'bootstrapThresholdReductionFactor')
    tpsInputStruct.tpsModuleParameters.bootstrapThresholdReductionFactor = 2;
end

if ~isfield(tpsInputStruct,'bootstrapParameters')
    bootstrapParameters = struct('autoSkipCountEnabled', true, 'binsBelowSearchTransitThreshold', 2, ...
        'convolutionMethodEnabled', true, 'histogramBinWidth', 0.1, 'maxAllowedMes', -1, 'maxAllowedTransitCount', ...
        -1, 'maxIterations', 2000000, 'maxNumberBins', 4096, 'skipCount', 25, 'upperLimitFactor', 2, ...
        'useTceTrialPulseOnly', true, 'deemphasizeQuartersWithoutTransits', true, 'sesZeroCrossingWidthDays', 2, ...
        'sesZeroCrossingDensityFactor', 4, 'nSesPeaksToRemove', 3, 'sesPeakRemovalThreshold', 7.1, ...
        'sesPeakRemovalFloor', 2, 'bootstrapResolutionFactor', 256);
    tpsInputStruct.bootstrapParameters = bootstrapParameters;
end

if ~isfield(tpsInputStruct.bootstrapParameters, 'deemphasizeQuartersWithoutTransits')
    tpsInputStruct.bootstrapParameters.deemphasizeQuartersWithoutTransits = true;
end

if ~isfield(tpsInputStruct.bootstrapParameters, 'sesZeroCrossingDensityFactor')
    tpsInputStruct.bootstrapParameters.sesZeroCrossingDensityFactor = 4;
end

if ~isfield(tpsInputStruct.bootstrapParameters, 'nSesPeaksToRemove')
    tpsInputStruct.bootstrapParameters.nSesPeaksToRemove = 3;
end

if ~isfield(tpsInputStruct.bootstrapParameters, 'sesZeroCrossingWidthDays')
    tpsInputStruct.bootstrapParameters.sesZeroCrossingWidthDays = 2;
end

if ~isfield(tpsInputStruct.bootstrapParameters, 'sesPeakRemovalThreshold')
    tpsInputStruct.bootstrapParameters.sesPeakRemovalThreshold = 7.1;
end

if ~isfield(tpsInputStruct.bootstrapParameters, 'sesPeakRemovalFloor')
    tpsInputStruct.bootstrapParameters.sesPeakRemovalFloor = 2;
end

if ~isfield(tpsInputStruct.bootstrapParameters, 'bootstrapResolutionFactor')
    tpsInputStruct.bootstrapParameters.bootstrapResolutionFactor = 256;
end

tpsInputStruct.bootstrapParameters.maxNumberBins = 4096;

if ~isfield(tpsInputStruct.tpsModuleParameters, 'mesHistogramMinMes')
    tpsInputStruct.tpsModuleParameters.mesHistogramMinMes = -10;
end

if ~isfield(tpsInputStruct.tpsModuleParameters, 'mesHistogramMaxMes')
    tpsInputStruct.tpsModuleParameters.mesHistogramMaxMes = 20;
end

if ~isfield(tpsInputStruct.tpsModuleParameters, 'mesHistogramBinSize')
    tpsInputStruct.tpsModuleParameters.mesHistogramBinSize = 0.2;
end

if ~isfield(tpsInputStruct.tpsModuleParameters, 'performWeakSecondaryTest')
    tpsInputStruct.tpsModuleParameters.performWeakSecondaryTest = true;
end

if ~isfield(tpsInputStruct.tpsModuleParameters, 'bootstrapGaussianEquivalentThreshold')
    tpsInputStruct.tpsModuleParameters.bootstrapGaussianEquivalentThreshold = 6.36;
end

if ~isfield(tpsInputStruct.tpsModuleParameters, 'bootstrapLowMesCutoff')
    tpsInputStruct.tpsModuleParameters.bootstrapLowMesCutoff = -1;
end

if ~isfield(tpsInputStruct, 'tasksPerCore')
    tpsInputStruct.tasksPerCore = 4;
end

if isfield( tpsInputStruct.tpsModuleParameters, 'storeCdppFlag' )
    tpsInputStruct.tpsModuleParameters = rmfield( tpsInputStruct.tpsModuleParameters, 'storeCdppFlag' );
end

if ~isfield( tpsInputStruct.tpsModuleParameters, 'noiseEstimationByQuarterEnabled' ) 
    tpsInputStruct.tpsModuleParameters.noiseEstimationByQuarterEnabled = true;
end

if ~isfield( tpsInputStruct.tpsModuleParameters, 'positiveOutlierHaircutThreshold' )
    tpsInputStruct.tpsModuleParameters.positiveOutlierHaircutThreshold = 12;
end

if ~isfield( tpsInputStruct.tpsModuleParameters, 'maxSesInMesStatisticThreshold' )
    tpsInputStruct.tpsModuleParameters.maxSesInMesStatisticThreshold= 0.9;
end

if ~isfield( tpsInputStruct.tpsModuleParameters, 'maxSesInMesStatisticPeriodCutoff' )
    tpsInputStruct.tpsModuleParameters.maxSesInMesStatisticPeriodCutoff= 90;
end

if ~isfield( tpsInputStruct.tpsModuleParameters, 'vetoDiagnosticsMaxNumIterationsToRecord' )
    tpsInputStruct.tpsModuleParameters.vetoDiagnosticsMaxNumIterationsToRecord = 100;
end

return
