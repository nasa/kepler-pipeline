function [self] = test_dv_matlab_controller(self)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function [self] = test_dv_matlab_controller(self)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% This test generates or loads a previously generated dv input data
% structure (dvDataStruct), and then compares that structure with another 
% obtained by writing and reading a binary file.  This first part of the
% test uses the auto-generated write_DvInputs and read_DvInputs functions.
%
% After generating a dv results structure (dvResultsStruct) with the 
% dv_matlab_controller, this test also compares that structure with 
% another obtained by writing and reading a binary file.  This second part
% of the test uses the auto-generated write_DvOutputs and read_DvOutputs
% functions.
%
% If the regression test fails, an error condition occurs.
%
%  Example
%  =======
%  Use a test runner to run the test method:
%      run(text_test_runner, testDvDataClass('test_dv_matlab_controller'));
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

% Define path and file names.
inputFileName = 'inputs-0.bin';
outputFileName = 'outputs-0.bin';

cadsFileName = 'dv_cads.mat';
limbDarkeningFileName = 'atlasNonlinearLimbDarkeningData.mat';
fitResultFileName = 'fitResult_*';
trapezoidalFitFileName = 'trapezoidalFit_*';
postFitFileName = 'dv_post_fit_workspace.mat';
randFileName = 'dv_rand.mat';
outputMatrixFileName = 'dvOutputMatrixTarget.mat';
tpsDawgFileName = 'tps-task-file-dawg-struct-dv.mat';

pixelDataDirName = 'pixelData';

initialize_soc_variables;
path = ...
    [socTestDataRoot filesep 'dv' filesep 'unit-tests' filesep 'dv-matlab-controller'];

% Add path so that blobs can be found.
addpath(path);

% This matfile contains only 1 target: kepId # 5097392.
matFileName = 'dvInputs.mat';
fullMatFileName = [path filesep matFileName];

% Load pre-generated data.
load(fullMatFileName, 'dvDataStruct');

% Update spiceFileDir.
dvDataStruct.raDec2PixModel.spiceFileDir = fullfile(socTestDataRoot, 'fc', 'spice');

% Replace known NaNs with 0's.
for iTarget = 1 : length(dvDataStruct.targetStruct)

    if isnan(dvDataStruct.targetStruct(iTarget).keplerMag.uncertainty)
        dvDataStruct.targetStruct.keplerMag.uncertainty = 0;
    end
    
    if isnan(dvDataStruct.targetStruct(iTarget).raHours.uncertainty)
        dvDataStruct.targetStruct.raHours.uncertainty = 0;
    end
    
    if isnan(dvDataStruct.targetStruct(iTarget).decDegrees.uncertainty)
        dvDataStruct.targetStruct.decDegrees.uncertainty = 0;
    end
    
    if isnan(dvDataStruct.targetStruct(iTarget).effectiveTemp.value)
        dvDataStruct.targetStruct.effectiveTemp.value = ...
            dvDataStruct.planetFitConfigurationStruct.defaultEffectiveTemp;
    end
    
    if isnan(dvDataStruct.targetStruct(iTarget).effectiveTemp.uncertainty)
        dvDataStruct.targetStruct.effectiveTemp.uncertainty = 0;
    end

    if isnan(dvDataStruct.targetStruct(iTarget).log10SurfaceGravity.value)
        dvDataStruct.targetStruct.log10SurfaceGravity.value = ...
            dvDataStruct.planetFitConfigurationStruct.defaultLog10SurfaceGravity;
    end

    if isnan(dvDataStruct.targetStruct(iTarget).log10SurfaceGravity.uncertainty)
        dvDataStruct.targetStruct.log10SurfaceGravity.uncertainty = 0;
    end

    if isnan(dvDataStruct.targetStruct(iTarget).log10Metallicity.value)
        dvDataStruct.targetStruct.log10Metallicity.value = ...
            dvDataStruct.planetFitConfigurationStruct.defaultLog10Metallicity;
    end

    if isnan(dvDataStruct.targetStruct(iTarget).log10Metallicity.uncertainty)
        dvDataStruct.targetStruct.log10Metallicity.uncertainty = 0;
    end
    
    if isnan(dvDataStruct.targetStruct(iTarget).radius.value)
        dvDataStruct.targetStruct.radius.value = ...
            dvDataStruct.planetFitConfigurationStruct.defaultRadius;
    end

    if isnan(dvDataStruct.targetStruct(iTarget).radius.uncertainty)
        dvDataStruct.targetStruct.radius.uncertainty = 0;
    end

end
        
% Write to, and read from, auto-generated scripts for input.
write_DvInputs(inputFileName, dvDataStruct);
[dvDataStructNew] = read_DvInputs(inputFileName);
delete(inputFileName);

% Copy the pixel data struct to the new data structure so that the unit
% test can work with a simple legacy input structure. The pixel data were
% moved to SDF files in 8.3 so they are not explicitly included in the
% module interface.
dvDataStructNew.targetStruct.targetDataStruct.pixelDataStruct = ...
    dvDataStruct.targetStruct.targetDataStruct.pixelDataStruct;

% Convert to floats for assert equals test and compare structures that are
% written to and read back from a bin file. Make sure that the exclude
% target labels compare if they are both empty.
messageOut = ...
    'dv_matlab_controller - data generated and read back by read_DvInputs are not identical!';
if isempty(dvDataStruct.pdcConfigurationStruct.excludeTargetLabels)
    dvDataStruct.pdcConfigurationStruct.excludeTargetLabels = [];
end

assert_equals(convert_struct_fields_to_float(dvDataStructNew), ...
    convert_struct_fields_to_float(dvDataStruct), messageOut);
clear dvDataStructNew

%--------------------------------------------------------------------------
% Generate output test data.
%--------------------------------------------------------------------------
% Run the Matlab controller. Really it should be sufficient to load a
% regression output file and write/read a bin file.
[dvResultsStruct] = dv_matlab_controller(dvDataStruct);

% Clean up.
delete(cadsFileName);
delete(limbDarkeningFileName);
delete(fitResultFileName);
delete(trapezoidalFitFileName);
delete(postFitFileName);
delete(randFileName);
delete(outputMatrixFileName);
delete(tpsDawgFileName);

rmdir(pixelDataDirName, 's');
for iTarget = 1 : length(dvResultsStruct.targetResultsStruct)
    rmdir(dvResultsStruct.targetResultsStruct(iTarget).dvFiguresRootDirectory, 's');
end

% Remove fields that don't get written in write_DvOutputs. These are not
% part of the official DV MI.
dvResultsStruct = rmfield(dvResultsStruct, 'skyGroupId');

dvResultsStruct.targetResultsStruct = ...
    rmfield(dvResultsStruct.targetResultsStruct, 'dvFiguresRootDirectory');

for i = 1 : length(dvResultsStruct.targetResultsStruct)
    dvResultsStruct.targetResultsStruct(i).residualFluxTimeSeries = ...
        rmfield(dvResultsStruct.targetResultsStruct(i).residualFluxTimeSeries, ...
        {'outlierIndicators', 'fittedTrend', 'frontExponentialSize', 'backExponentialSize'});
    dvResultsStruct.targetResultsStruct(i).singleEventStatistics = ...
        rmfield(dvResultsStruct.targetResultsStruct(i).singleEventStatistics, ...
        'deemphasisWeights');
    for j = 1 : length(dvResultsStruct.targetResultsStruct(i).planetResultsStruct)
        dvResultsStruct.targetResultsStruct(i).planetResultsStruct(j).planetCandidate.initialFluxTimeSeries = ...
            rmfield(dvResultsStruct.targetResultsStruct(i).planetResultsStruct(j).planetCandidate.initialFluxTimeSeries, ...
            {'outlierIndicators', 'fittedTrend', 'frontExponentialSize', 'backExponentialSize'});
        dvResultsStruct.targetResultsStruct(i).planetResultsStruct(j).imageArtifactResults.rollingBandContaminationHistogram = ...
            rmfield(dvResultsStruct.targetResultsStruct(i).planetResultsStruct(j).imageArtifactResults.rollingBandContaminationHistogram, 'transitMetadata');
        for k = 1 : length(dvResultsStruct.targetResultsStruct(i).planetResultsStruct(j).differenceImageResults)
            dvResultsStruct.targetResultsStruct(i).planetResultsStruct(j).differenceImageResults(k).kicReferenceCentroid = ...
                rmfield(dvResultsStruct.targetResultsStruct(i).planetResultsStruct(j).differenceImageResults(k).kicReferenceCentroid, ...
                {'rowColumnCovariance', 'raDecCovariance', 'transformationCadenceIndices'});
            dvResultsStruct.targetResultsStruct(i).planetResultsStruct(j).differenceImageResults(k).controlImageCentroid = ...
                rmfield(dvResultsStruct.targetResultsStruct(i).planetResultsStruct(j).differenceImageResults(k).controlImageCentroid, ...
                {'rowColumnCovariance', 'raDecCovariance', 'transformationCadenceIndices'});
            dvResultsStruct.targetResultsStruct(i).planetResultsStruct(j).differenceImageResults(k).differenceImageCentroid = ...
                rmfield(dvResultsStruct.targetResultsStruct(i).planetResultsStruct(j).differenceImageResults(k).differenceImageCentroid, ...
                {'rowColumnCovariance', 'raDecCovariance', 'transformationCadenceIndices'});
        end
        dvResultsStruct.targetResultsStruct(i).planetResultsStruct(j).differenceImageResults = ...
            rmfield(dvResultsStruct.targetResultsStruct(i).planetResultsStruct(j).differenceImageResults, ...
            'mjdTimestamp');
        for k = 1 : length(dvResultsStruct.targetResultsStruct(i).planetResultsStruct(j).pixelCorrelationResults)
            dvResultsStruct.targetResultsStruct(i).planetResultsStruct(j).pixelCorrelationResults(k).kicReferenceCentroid = ...
                rmfield(dvResultsStruct.targetResultsStruct(i).planetResultsStruct(j).pixelCorrelationResults(k).kicReferenceCentroid, ...
                {'rowColumnCovariance', 'raDecCovariance', 'transformationCadenceIndices'});
            dvResultsStruct.targetResultsStruct(i).planetResultsStruct(j).pixelCorrelationResults(k).controlImageCentroid = ...
                rmfield(dvResultsStruct.targetResultsStruct(i).planetResultsStruct(j).pixelCorrelationResults(k).controlImageCentroid, ...
                {'rowColumnCovariance', 'raDecCovariance', 'transformationCadenceIndices'});
            dvResultsStruct.targetResultsStruct(i).planetResultsStruct(j).pixelCorrelationResults(k).correlationImageCentroid = ...
                rmfield(dvResultsStruct.targetResultsStruct(i).planetResultsStruct(j).pixelCorrelationResults(k).correlationImageCentroid, ...
                {'rowColumnCovariance', 'raDecCovariance', 'transformationCadenceIndices'});
        end
        dvResultsStruct.targetResultsStruct(i).planetResultsStruct(j).pixelCorrelationResults = ...
            rmfield(dvResultsStruct.targetResultsStruct(i).planetResultsStruct(j).pixelCorrelationResults, ...
            'mjdTimestamp');
    end
end

% Write to, and read from, auto-generated scripts for output.
write_DvOutputs(outputFileName, dvResultsStruct);
[dvResultsStructNew] = read_DvOutputs(outputFileName);
delete(outputFileName);

% % TEMP FOR NOW. DV MI FOR 9.3 REMAINS INCOMPLETE.
% for i = 1 : length(dvResultsStruct.targetResultsStruct)
%     for j = 1 : length(dvResultsStruct.targetResultsStruct(i).planetResultsStruct)
%         dvResultsStructNew.targetResultsStruct(i).planetResultsStruct(j).planetCandidate.modelChiSquareGof = ...
%             dvResultsStruct.targetResultsStruct(i).planetResultsStruct(j).planetCandidate.modelChiSquareGof;
%         dvResultsStructNew.targetResultsStruct(i).planetResultsStruct(j).planetCandidate.modelChiSquareGofDof = ...
%             dvResultsStruct.targetResultsStruct(i).planetResultsStruct(j).planetCandidate.modelChiSquareGofDof;        
%     end
% end

% % TEMP FOR NOW. DV MI FOR 9.3 REMAINS INCOMPLETE.
% for i = 1 : length(dvResultsStruct.targetResultsStruct)
%     for j = 1 : length(dvResultsStruct.targetResultsStruct(i).planetResultsStruct)
%         dvResultsStructNew.targetResultsStruct(i).planetResultsStruct(j).detrendFilterLength = ...
%             dvResultsStruct.targetResultsStruct(i).planetResultsStruct(j).detrendFilterLength;
%         dvResultsStructNew.targetResultsStruct(i).planetResultsStruct(j).foldedPhase = ...
%             dvResultsStruct.targetResultsStruct(i).planetResultsStruct(j).foldedPhase;
%     end
% end

% Convert to floats for assert equals test and compare structures that are
% written to and read back from a bin file.
messageOut = ...
    'dv_matlab_controller - results received and read back by read_DvOutputs are not identical!';
assert_equals(convert_struct_fields_to_float(dvResultsStructNew), ...
    convert_struct_fields_to_float(dvResultsStruct), messageOut);

% Return.
return
