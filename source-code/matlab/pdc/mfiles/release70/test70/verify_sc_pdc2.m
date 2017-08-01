function verify_sc_pdc2(flightDataDirString)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function verify_sc_pdc2
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
% All parameters listed below shall be inputs to PDC CSCI:
% 1)Uncertainties in relative flux
% 2)Short or long cadence flag
% 3)Number of short cadences in a long cadence
% 4)Outlier rejection threshold
% 5)Sample timestamps of various ancillary data
% 6)Data gap locations in relative flux
% 7)Median filter length used in outlier detection
% 8)Minimum long data gap size
%
%
% flightDataDirString
%
% ex. /path/to/flight/q2/i956/pdc-matlab-956-22686
%     /path/to/flight/q2/i956/pdc-matlab-956-22692
%     /path/to/flight/q2/i956/pdc-matlab-956-22703
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

SCRATCHDIR = '/path/to/matlab/pdc/test/';
cd(SCRATCHDIR);

invocation = 0;
fileName = ['pdc-inputs-', num2str(invocation), '.mat'];

if nargin==1
    cd(flightDataDirString);
    load(fileName);
    cd(SCRATCHDIR);
else
    load(fileName);
end

% inputsStruct =
%                                      ccdModule: 2
%                                      ccdOutput: 1
%                                    cadenceType: 'SHORT'
%                                   startCadence: 77410
%                                     endCadence: 122619
%                                    fcConstants: [1x1 struct]
%                            spacecraftConfigMap: [1x3 struct]
%                                   cadenceTimes: [1x1 struct]
%                               longCadenceTimes: [1x1 struct]
%                            pdcModuleParameters: [1x1 struct]
%                                 raDec2PixModel: [1x1 struct]
%        ancillaryEngineeringConfigurationStruct: [1x1 struct]
%                 ancillaryEngineeringDataStruct: [1x10 struct]
%           ancillaryPipelineConfigurationStruct: [1x1 struct]
%                    ancillaryPipelineDataStruct: []
%       ancillaryDesignMatrixConfigurationStruct: [1x1 struct]
%                         attitudeSolutionStruct: [1x1 struct]
%                                    motionBlobs: [1x1 struct]
%                     gapFillConfigurationStruct: [1x1 struct]
%           saturationSegmentConfigurationStruct: [1x1 struct]
%     harmonicsIdentificationConfigurationStruct: [1x1 struct]
%       dataAnomalyMitigationConfigurationStruct: [1x1 struct]
%               discontinuityConfigurationStruct: [1x1 struct]
%                               targetDataStruct: [1x4 struct]


i=1;

if ~isempty(inputsStruct.targetDataStruct(i).uncertainties)
    display(['Field exists:  inputsStruct.targetDataStruct(i).uncertainties,  array length = ' num2str(length(inputsStruct.targetDataStruct(i).uncertainties))])
    display(' ')
else
    display('Field does not exist!:  inputsStruct.targetDataStruct(i).uncertainties')
    display(' ')
end


if ~isempty(inputsStruct.cadenceType)
    display(['Field exists:  inputsStruct.cadenceType = ' num2str((inputsStruct.cadenceType))])
    display(' ')
else
    display('Field does not exist!:  inputsStruct.cadenceType')
    display(' ')
end


if ~isempty(inputsStruct.spacecraftConfigMap)
    display(['Field exists:  inputsStruct.spacecraftConfigMap, struct array length = ' num2str(length((inputsStruct.spacecraftConfigMap)))])
    display(' ')
else
    display('Field does not exist!:  inputsStruct.spacecraftConfigMap')
    display(' ')
end


if ~isempty(inputsStruct.pdcModuleParameters.outlierThresholdXFactor)
    display(['Field exists:  inputsStruct.pdcModuleParameters.outlierThresholdXFactor = ' num2str((inputsStruct.pdcModuleParameters.outlierThresholdXFactor))])
    display(' ')
else
    display('Field does not exist!:  inputsStruct.pdcModuleParameters.outlierThresholdXFactor')
    display(' ')
end


if ~isempty(inputsStruct.ancillaryEngineeringDataStruct(i).timestamps)
    display(['Field exists:  inputsStruct.ancillaryEngineeringDataStruct(i).timestamps, struct array length = ' num2str(length((inputsStruct.ancillaryEngineeringDataStruct(i).timestamps)))])
    display(' ')
else
    display('Field does not exist!:  inputsStruct.ancillaryEngineeringDataStruct(i).timestamps')
    display(' ')
end


if ~isempty(inputsStruct.targetDataStruct(i).gapIndicators)
    display(['Field exists:  inputsStruct.targetDataStruct(i).gapIndicators,  array length = ' num2str(length(inputsStruct.targetDataStruct(i).gapIndicators))])
    display(' ')
else
    display('Field does not exist!:  inputsStruct.targetDataStruct(i).gapIndicators')
    display(' ')
end



if ~isempty(inputsStruct.pdcModuleParameters.medianFilterLength)
    display(['Field exists:  inputsStruct.pdcModuleParameters.medianFilterLength = ' num2str((inputsStruct.pdcModuleParameters.medianFilterLength))])
    display(' ')
else
    display('Field does not exist!:  inputsStruct.pdcModuleParameters.medianFilterLength')
    display(' ')
end


if ~isempty(inputsStruct.gapFillConfigurationStruct.maxArOrderLimit) && ...
        ~isempty(inputsStruct.gapFillConfigurationStruct.maxCorrelationWindowXFactor)

    display('Fields exist:  inputsStruct.gapFillConfigurationStruct.maxArOrderLimit and ')
    display('               inputsStruct.gapFillConfigurationStruct.maxCorrelationWindowXFactor')
    display(['               Minimum long data gap size is the product of these: ' num2str(inputsStruct.gapFillConfigurationStruct.maxArOrderLimit * inputsStruct.gapFillConfigurationStruct.maxCorrelationWindowXFactor) ]);
    display(' ')
else
    display('Fields do not exist!:  inputsStruct.gapFillConfigurationStruct.maxArOrderLimit and inputsStruct.gapFillConfigurationStruct.maxCorrelationWindowXFactor')
    display(' ')
end



return;