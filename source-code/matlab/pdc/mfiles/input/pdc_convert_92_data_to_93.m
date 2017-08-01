%% function [pdcInputStruct] = pdc_convert_92_data_to_93(pdcInputStruct)
%
% Update earlier PDC input structures to 9.3. It recursively calls earlier version 
% conversion functions. This is useful when testing with existing data sets.
%%
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

function [pdcInputStruct] = pdc_convert_92_data_to_93(pdcInputStruct)

% First call all previous conversion files
% These should iteratively call each other on down
[pdcInputStruct] = pdc_convert_91_data_to_92(pdcInputStruct);

% Don't be vocal about when to set a field
verbosity = false;

% Set PDC version
pdcInputStruct.pdcVersion = 9.3;


% Using centroid priors logical
pdcInputStruct.mapConfigurationStruct = assert_field(pdcInputStruct.mapConfigurationStruct , 'useCentroidPriors', false, verbosity);
% Increase weight gain on middle band for centroid priors
%if (pdcInputStruct.mapConfigurationStruct.useCentroidPriors)
%    pdcInputStruct.mapConfigurationStruct.priorPdfGoodnessGain = [1 1 1 100 20];
%    pdcInputStruct.mapConfigurationStruct.goodnessMetricIterationsEnabled = [true true true true false];
%    pdcInputStruct.pdcModuleParameters.mapSelectionMethodMultiscaleBias = 0.0;
%end

% New targetDataStruct field: optimalAperture
if (isfield(pdcInputStruct, 'channelDataStruct') && isfield(pdcInputStruct.channelDataStruct(1), 'targetDataStruct'))
    for iChannel = 1 : length(pdcInputStruct.channelDataStruct)
        for iTarget = 1 : length(pdcInputStruct.channelDataStruct(iChannel).targetDataStruct)
            pdcInputStruct.channelDataStruct(iChannel).targetDataStruct(iTarget) = ...
                assert_field(pdcInputStruct.channelDataStruct(iChannel).targetDataStruct(iTarget), 'optimalAperture', [], verbosity);
        end
    end
else
    for iTarget = 1 : length(pdcInputStruct.targetDataStruct)
        pdcInputStruct.targetDataStruct(iTarget) = assert_field(pdcInputStruct.targetDataStruct(iTarget), 'optimalAperture', [], verbosity);
    end
end

% Denoising basis vectors logical
% This has to either be one or off for PDC and not for individual bands.
pdcInputStruct.mapConfigurationStruct = assert_field(pdcInputStruct.mapConfigurationStruct , 'denoiseBasisVectorsEnabled', false, verbosity);

% Spike Removal Goodness Component
pdcInputStruct.goodnessMetricConfigurationStruct = assert_field(pdcInputStruct.goodnessMetricConfigurationStruct , 'spikeScale', 5.0e-6, verbosity);

% Spike isolation for Basis Vectors
pdcInputStruct.mapConfigurationStruct = assert_field(pdcInputStruct.mapConfigurationStruct , 'spikeIsolationEnabled', [true true false false false], verbosity);
pdcInputStruct.mapConfigurationStruct = assert_field(pdcInputStruct.mapConfigurationStruct , 'spikeBasisVectorWindow', 15, verbosity);

% Thruster data field, will be present whether Kprime or K2 data; with
% Kprime data, it will be empty
if(~isfield(pdcInputStruct,'thrusterDataAncillaryEngineeringConfigurationStruct'))
    pdcInputStruct.thrusterDataAncillaryEngineeringConfigurationStruct = struct();
   %pdcInputStruct.thrusterDataAncillaryEngineeringConfigurationStruct = assert_field(pdcInputStruct.thrusterDataAncillaryEngineeringConfigurationStruct, ...
   %    'mnemonics', {'ADTHR1CNTNIC' 'ADTHR2CNTNIC' 'ADTHR3CNTNIC' 'ADTHR4CNTNIC' 'ADTHR5CNTNIC' 'ADTHR6CNTNIC' 'ADTHR7CNTNIC' 'ADTHR8CNTNIC'}, verbosity);
    pdcInputStruct.thrusterDataAncillaryEngineeringConfigurationStruct = assert_field(pdcInputStruct.thrusterDataAncillaryEngineeringConfigurationStruct, ...
        'mnemonics', [], verbosity);
    pdcInputStruct.thrusterDataAncillaryEngineeringConfigurationStruct = assert_field(pdcInputStruct.thrusterDataAncillaryEngineeringConfigurationStruct, 'modelOrders', [], verbosity);
    pdcInputStruct.thrusterDataAncillaryEngineeringConfigurationStruct = assert_field(pdcInputStruct.thrusterDataAncillaryEngineeringConfigurationStruct, 'interactions', [], verbosity);
    pdcInputStruct.thrusterDataAncillaryEngineeringConfigurationStruct = assert_field(pdcInputStruct.thrusterDataAncillaryEngineeringConfigurationStruct, 'quantizationLevels', [], verbosity);
    pdcInputStruct.thrusterDataAncillaryEngineeringConfigurationStruct = assert_field(pdcInputStruct.thrusterDataAncillaryEngineeringConfigurationStruct, 'intrinsicUncertainties', [], verbosity);
end

% Set the end of mission date
pdcInputStruct.fcConstants = assert_field(pdcInputStruct.fcConstants, 'KEPLER_END_OF_MISSION_MJD', 56444, verbosity);

% KSOC-4646; Remove residual thruster sawtooth spikes
pdcInputStruct.pdcModuleParameters = assert_field(pdcInputStruct.pdcModuleParameters, 'thrusterSawtoothRemovalDetectionThreshold', 5.0, verbosity);
pdcInputStruct.pdcModuleParameters = assert_field(pdcInputStruct.pdcModuleParameters, 'thrusterSawtoothRemovalMaxDetectionThreshold', 100.0, verbosity);
pdcInputStruct.pdcModuleParameters = assert_field(pdcInputStruct.pdcModuleParameters, 'thrusterSawtoothRemovalMaxIterations', 6, verbosity);

% KSOC-4685; thruster firing engineering cadence in seconds, C0-C1 => 8 seconds, C2-Cx => 16 seconds
pdcInputStruct.thrusterDataAncillaryEngineeringConfigurationStruct = assert_field(pdcInputStruct.thrusterDataAncillaryEngineeringConfigurationStruct, ...
        'thrusterFiringDataCadenceSeconds', 8, verbosity);

return
