function [conditionedAncillaryDataStruct, alerts] = ...
synchronize_pdc_ancillary_data(pdcDataObject, alerts)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function [conditionedAncillaryDataStruct, alerts] = ...
% synchronize_pdc_ancillary_data(pdcDataObject, alerts)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Method for PDC ancillary data conditioning. Get needed structures and
% fields from PDC data object and call common synchronization function.
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


% Extract relevant input parameters and structures.
cadenceType = pdcDataObject.cadenceType;
cadenceTimes = pdcDataObject.cadenceTimes;
longCadenceTimes = pdcDataObject.longCadenceTimes;

pdcModuleParameters = pdcDataObject.pdcModuleParameters;
debugLevel = pdcModuleParameters.debugLevel;
gapFillConfigurationStruct = pdcDataObject.gapFillConfigurationStruct;

ancillaryEngineeringConfigurationStruct = ...
    pdcDataObject.ancillaryEngineeringConfigurationStruct;
ancillaryPipelineConfigurationStruct = ...
    pdcDataObject.ancillaryPipelineConfigurationStruct;
ancillaryEngineeringDataStruct = ...
    pdcDataObject.ancillaryEngineeringDataStruct;
ancillaryPipelineDataStruct = ...
    pdcDataObject.ancillaryPipelineDataStruct;

motionPolyStruct = pdcDataObject.motionPolyStruct;

targetDataStruct = pdcDataObject.targetDataStruct;

spacecraftConfigMap = pdcDataObject.spacecraftConfigMap;

% Determine the cadences for which gaps are present in any of the target
% flux time series.
gapIndicatorsArray = [targetDataStruct.gapIndicators];
targetDataAvailable = ~all(gapIndicatorsArray, 2);
clear gapIndicatorsArray

% Perform the ancillary data conditioning and prepare the motion
% polynomials for cotrending.
[conditionedAncillaryDataStruct, alerts] = ...
    synchronize_ancillary_data_mp(cadenceTimes, ...
    longCadenceTimes, ancillaryEngineeringConfigurationStruct, ...
    ancillaryEngineeringDataStruct, ancillaryPipelineConfigurationStruct, ...
    ancillaryPipelineDataStruct, motionPolyStruct, alerts);


% Return.
return
