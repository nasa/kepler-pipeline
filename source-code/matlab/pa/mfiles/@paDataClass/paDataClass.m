function [paDataObject] = paDataClass(paDataStruct)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Constructor [paDataObject] = paDataClass(paDataStruct)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
% paDataClass.m - Class Constructor
%
% This method orders the fields in the input data structure and then
% implements the constructor for the paDataClass. It is assumed that the
% inputs have been validated before this constructor is invoked.
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

% If no input, generate an error.
if nargin == 0
    error('PA:paDataClass:EmptyInputStruct', ...
        'The constructor must be called with an input structure');
end
    
% Order the fields to avoid getting error messages like:
%   Error using ==> class 
%   Field names and parent classes for class paDataClass cannot be
%   changed without clear classes
paDataStruct = orderfields(paDataStruct);

paDataStruct.paConfigurationStruct = ...
    orderfields(paDataStruct.paConfigurationStruct);

paDataStruct.oapAncillaryEngineeringConfigurationStruct = ...
    orderfields(paDataStruct.oapAncillaryEngineeringConfigurationStruct);

paDataStruct.reactionWheelAncillaryEngineeringConfigurationStruct = ...
    orderfields(paDataStruct.reactionWheelAncillaryEngineeringConfigurationStruct);

paDataStruct.ancillaryPipelineConfigurationStruct = ...
    orderfields(paDataStruct.ancillaryPipelineConfigurationStruct);

paDataStruct.ancillaryDesignMatrixConfigurationStruct = ...
    orderfields(paDataStruct.ancillaryDesignMatrixConfigurationStruct);

paDataStruct.backgroundConfigurationStruct = ...
    orderfields(paDataStruct.backgroundConfigurationStruct);

paDataStruct.motionConfigurationStruct = ...
    orderfields(paDataStruct.motionConfigurationStruct);

paDataStruct.cosmicRayConfigurationStruct = ...
    orderfields(paDataStruct.cosmicRayConfigurationStruct);

paDataStruct.harmonicsIdentificationConfigurationStruct = ...
    orderfields(paDataStruct.harmonicsIdentificationConfigurationStruct);

paDataStruct.encircledEnergyConfigurationStruct = ...
    orderfields(paDataStruct.encircledEnergyConfigurationStruct);

paDataStruct.gapFillConfigurationStruct = ...
    orderfields(paDataStruct.gapFillConfigurationStruct);

paDataStruct.pouConfigurationStruct = ...
    orderfields(paDataStruct.pouConfigurationStruct);

paDataStruct.saturationSegmentConfigurationStruct = ...
    orderfields(paDataStruct.saturationSegmentConfigurationStruct);

paDataStruct.argabrighteningConfigurationStruct = ...
    orderfields(paDataStruct.argabrighteningConfigurationStruct);

paDataStruct.fcConstants = ...
    orderfields(paDataStruct.fcConstants);

paDataStruct.spacecraftConfigMap = ...
    orderfields(paDataStruct.spacecraftConfigMap);
nMaps = length(paDataStruct.spacecraftConfigMap);
for i = 1 : nMaps
    paDataStruct.spacecraftConfigMap(i).entries = ...
        orderfields(paDataStruct.spacecraftConfigMap(i).entries);
end

paDataStruct.raDec2PixModel = ...
    orderfields(paDataStruct.raDec2PixModel);
paDataStruct.raDec2PixModel.geometryModel = ...
    orderfields(paDataStruct.raDec2PixModel.geometryModel);
paDataStruct.raDec2PixModel.pointingModel = ...
    orderfields(paDataStruct.raDec2PixModel.pointingModel);
paDataStruct.raDec2PixModel.rollTimeModel = ...
    orderfields(paDataStruct.raDec2PixModel.rollTimeModel);
paDataStruct.raDec2PixModel.geometryModel.fcModelMetadata = ...
    orderfields(paDataStruct.raDec2PixModel.geometryModel.fcModelMetadata);
paDataStruct.raDec2PixModel.pointingModel.fcModelMetadata = ...
    orderfields(paDataStruct.raDec2PixModel.pointingModel.fcModelMetadata);
paDataStruct.raDec2PixModel.rollTimeModel.fcModelMetadata = ...
    orderfields(paDataStruct.raDec2PixModel.rollTimeModel.fcModelMetadata);

paDataStruct.cadenceTimes = ...
    orderfields(paDataStruct.cadenceTimes);

paDataStruct.longCadenceTimes = ...
    orderfields(paDataStruct.longCadenceTimes);

paDataStruct.prfModel = ...
    orderfields(paDataStruct.prfModel);

if ~isempty(paDataStruct.ancillaryEngineeringDataStruct)
    paDataStruct.ancillaryEngineeringDataStruct = ...
        orderfields(paDataStruct.ancillaryEngineeringDataStruct);
end

if ~isempty(paDataStruct.ancillaryPipelineDataStruct)
    paDataStruct.ancillaryPipelineDataStruct = ...
        orderfields(paDataStruct.ancillaryPipelineDataStruct);
end

if ~isempty(paDataStruct.backgroundDataStruct)
    paDataStruct.backgroundDataStruct = ...
        orderfields(paDataStruct.backgroundDataStruct);
end

if ~isempty(paDataStruct.targetStarDataStruct)
    paDataStruct.targetStarDataStruct = ...
        orderfields(paDataStruct.targetStarDataStruct);
    nTargets = length(paDataStruct.targetStarDataStruct);
    for i = 1 : nTargets
        paDataStruct.targetStarDataStruct(i).pixelDataStruct = ...
            orderfields(paDataStruct.targetStarDataStruct(i).pixelDataStruct);
        if ~isempty(paDataStruct.targetStarDataStruct(i).rmsCdppStruct)
            paDataStruct.targetStarDataStruct(i).rmsCdppStruct = ...
                orderfields(paDataStruct.targetStarDataStruct(i).rmsCdppStruct);
        end
    end
end

if ~isempty(paDataStruct.rollingBandArtifactFlags)
    paDataStruct.rollingBandArtifactFlags = ...
        orderfields(paDataStruct.rollingBandArtifactFlags);
    nRows = length(paDataStruct.rollingBandArtifactFlags);
    for i = 1 : nRows
        paDataStruct.rollingBandArtifactFlags(i).flags = ...
            orderfields(paDataStruct.rollingBandArtifactFlags(i).flags);
    end
end

if ~isempty(paDataStruct.backgroundPolyStruct)
    paDataStruct.backgroundPolyStruct = ...
        orderfields(paDataStruct.backgroundPolyStruct);
    nStructures = length(paDataStruct.backgroundPolyStruct);
    for i = 1 : nStructures
        paDataStruct.backgroundPolyStruct(i).backgroundPoly = ...
            orderfields(paDataStruct.backgroundPolyStruct(i).backgroundPoly);
    end
end

if ~isempty(paDataStruct.motionPolyStruct)
    paDataStruct.motionPolyStruct = ...
        orderfields(paDataStruct.motionPolyStruct);
    nStructures = length(paDataStruct.motionPolyStruct);
    for i = 1 : nStructures
        paDataStruct.motionPolyStruct(i).rowPoly = ...
            orderfields(paDataStruct.motionPolyStruct(i).rowPoly);
        paDataStruct.motionPolyStruct(i).colPoly = ...
            orderfields(paDataStruct.motionPolyStruct(i).colPoly);
    end
end

paDataStruct.paFileStruct = ...
    orderfields(paDataStruct.paFileStruct);

% Now create the paDataClass object.
paDataObject = class(paDataStruct, 'paDataClass');

% Return.
return
