function [newPaDataStruct] = ...
convert_to_current_trunk_pa_data_struct(paDataStruct, updateRaDec2PixModel)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function [newPaDataStruct] = ...
% convert_to_current_trunk_pa_data_struct(paDataStruct, updateRaDec2PixModel)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Attempt to bring an existing but outdated PA input data structure up to
% the current standard. Not guaranteed to work with any existing PA data
% structure (depending on heritage).
%
% If the updateRaDec2PixModel argument is specified as 'true', the
% raDec2PixModel in the returned data structure will be updated with a
% model that points to current NAIF spice files. This will
% enable the returned data structure to run out of the box.
%
% Note that for older data structures without the ppaTargetCount field,
% this conversion will produce a target count only for those PPA targets
% that appear to be in the first PA target invocation. This function has
% now way to know whether or not there are any additional PPA targets in
% the following PA target invocation.
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

% Set default for optional input parameter if not specified.
if ~exist('updateRaDec2PixModel', 'var')
    updateRaDec2PixModel = false;
end

% Set raDec2PixModel directory path.
raDec2PixModelDir = '/path/to/matlab/pa/raDec2PixModel';

% Copy the PA input data structure.
newPaDataStruct = paDataStruct;

% Get fields from input structure.
cadenceType = paDataStruct.cadenceType;

% Check for latest PA module parameters.
paConfigurationStruct = paDataStruct.paConfigurationStruct;
if ~isfield(paConfigurationStruct, 'stellarVariabilityDetrendOrder')
    paConfigurationStruct.stellarVariabilityDetrendOrder = 6;
    paConfigurationStruct.stellarVariabilityThreshold = 0.01;
    paConfigurationStruct.madThresholdForCentroidOutliers = 3.5;
end
newPaDataStruct.paConfigurationStruct = paConfigurationStruct;
clear paConfigurationStruct

% Check for the saturationSegmentConfigurationStruct.
if ~isfield(paDataStruct, 'saturationSegmentConfigurationStruct')
    saturationSegmentConfigurationStruct.sgPolyOrder = 6;
    saturationSegmentConfigurationStruct.sgFrameSize = 193;
    saturationSegmentConfigurationStruct.satSegThreshold = 193;
    saturationSegmentConfigurationStruct.satSegExclusionZone = 90;
    saturationSegmentConfigurationStruct.maxSaturationMagnitude = 11.5;
    newPaDataStruct.saturationSegmentConfigurationStruct = ...
        saturationSegmentConfigurationStruct;
    clear saturationSegmentConfigurationStruct
end

% Check for the argabrighteningConfigurationStruct.
if ~isfield(paDataStruct, 'argabrighteningConfigurationStruct')
    argabrighteningConfigurationStruct.mitigationEnabled = true;
    argabrighteningConfigurationStruct.fitOrder = 2;
    argabrighteningConfigurationStruct.medianFilterLength = 25;
    if strcmpi(cadenceType, 'LONG')
        argabrighteningConfigurationStruct.madThreshold = 100;
    else
        argabrighteningConfigurationStruct.madThreshold = 60;
    end
    newPaDataStruct.argabrighteningConfigurationStruct = ...
        argabrighteningConfigurationStruct;
    clear argabrighteningConfigurationStruct
end

% Check for the proper ancillaryTargetConfigurationStruct.
ancillaryTargetConfigurationStruct.gridSize = 2;
ancillaryTargetConfigurationStruct.modelOrder = 1;
ancillaryTargetConfigurationStruct.interactionEnabled = false;
ancillaryTargetConfigurationStruct.smoothingEnabled = true;
ancillaryTargetConfigurationStruct.sgPolyOrder = 2;
ancillaryTargetConfigurationStruct.sgFrameSize = 145;

if isfield(paDataStruct, 'ancillaryAttitudeConfigurationStruct')
    newPaDataStruct = rmfield(newPaDataStruct, ...
        'ancillaryAttitudeConfigurationStruct');
    newPaDataStruct.ancillaryTargetConfigurationStruct = ...
        ancillaryTargetConfigurationStruct;
elseif ~isfield(paDataStruct.ancillaryTargetConfigurationStruct, 'smoothingEnabled')
    newPaDataStruct.ancillaryTargetConfigurationStruct = ...
        ancillaryTargetConfigurationStruct;  
end
clear ancillaryTargetConfigurationStruct

% Do something about the PPA target count. This won't necessarily include
% all of the PPA targets if there are some in the second target invocation
% on branch.
if ~isfield(paDataStruct, 'ppaTargetCount')
    ppaTargetCount = 0;
    if strcmpi(cadenceType, 'LONG') && ~isempty(paDataStruct.targetStarDataStruct)
        [isPpaTarget] = ...
            identify_targets('PPA_STELLAR', ...
            {paDataStruct.targetStarDataStruct.labels});
        if sum(isPpaTarget) > 100
            ppaTargetCount = sum(isPpaTarget);
        end
    end
    newPaDataStruct.ppaTargetCount = ppaTargetCount;
end

% Check if the inOptimalAperture field exists.
if ~isempty(paDataStruct.backgroundDataStruct) && ...
        ~isfield(paDataStruct.backgroundDataStruct(1), 'inOptimalAperture')
    for i = 1 : length(paDataStruct.backgroundDataStruct)
        newPaDataStruct.backgroundDataStruct(i).inOptimalAperture = ...
                paDataStruct.backgroundDataStruct(i).isInOptimalAperture;
    end
    newPaDataStruct.backgroundDataStruct = ...
        rmfield(newPaDataStruct.backgroundDataStruct, 'isInOptimalAperture'); 
end

if ~isempty(paDataStruct.targetStarDataStruct) && ...
        ~isfield(paDataStruct.targetStarDataStruct(1).pixelDataStruct(1), 'inOptimalAperture')
    for i = 1 : length(paDataStruct.targetStarDataStruct)
        for j = 1 : length(paDataStruct.targetStarDataStruct(i).pixelDataStruct)
            newPaDataStruct.targetStarDataStruct(i).pixelDataStruct(j).inOptimalAperture = ...
                paDataStruct.targetStarDataStruct(i).pixelDataStruct(j).isInOptimalAperture;
        end
        newPaDataStruct.targetStarDataStruct(i).pixelDataStruct = ...
            rmfield(newPaDataStruct.targetStarDataStruct(i).pixelDataStruct, 'isInOptimalAperture'); 
    end
end

% Check for a raDec2PixModel and include one that points to valid SPICE
% files if one does not exist. Or, update the existing
% raDec2PixModel if the updateRaDec2PixModel option was specified.
if ~isfield(paDataStruct, 'raDec2PixModel') || updateRaDec2PixModel
    load([raDec2PixModelDir, '/raDec2PixModel.mat']);
    newPaDataStruct.raDec2PixModel = raDec2PixModel;
end
clear raDec2PixModel

return
