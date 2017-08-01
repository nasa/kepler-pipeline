function transitInjectionStruct = build_pa_transit_injection_struct(paDataObject, paResultsStruct, iTarget, simulatedTransitsStruct)
%**************************************************************************
% function transitInjectionStruct = build_pa_transit_injection_struct( ...
%     paDataObject, paResultsStruct, iTarget, simulatedTransitsStruct)
%**************************************************************************
% This paDataClass method builds the transitInjectionStruct for PA for a
% single target. These are the timestamps the injected transit model will
% be built on. The input structure 'simulatedTransitsStruct' contains all
% the transit injection parameters associated with targets in the currect
% PA unit of work. Multiple planet systems are represented in this
% structure with a separate row for each planet, each using the same
% keplerId.
%**************************************************************************
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


% default returns empty transitInjectionStruct
transitInjectionStruct = [];
if isempty(simulatedTransitsStruct) || iTarget > length(paDataObject.targetStarDataStruct)
    return;
end

% extract target data and results structs
targetDataStruct = paDataObject.targetStarDataStruct(iTarget);
targetResultsStruct = paResultsStruct.targetStarResultsStruct(iTarget);

% find entries in simulatedTransitsStruct for this target if they exist
logicalIdx = simulatedTransitsStruct.keplerId == targetDataStruct.keplerId;

% return empty struct if keplerId is not found in simulatedTransitsStruct
if isempty(logicalIdx) || all(~logicalIdx)
    return;                                                 
else
    
    % extract cadence time stamps - note gaps have been interpolated over already
    midTimestamps = simulatedTransitsStruct.cadenceTimes.midTimestamps;
    
    % build barycentric timestamps
    barycentricCadenceTimes = midTimestamps + targetResultsStruct.barycentricTimeOffset.values;
    
    % update models with config maps and barcentric cadence times for this target table
    transitModelStructArray = simulatedTransitsStruct.transitModelStructArray(logicalIdx);
    for i = 1:length(transitModelStructArray)
        transitModelStructArray(i).cadenceTimes = barycentricCadenceTimes;
        transitModelStructArray(i).configMaps   = paDataObject.spacecraftConfigMap;
    end
    
    % build transitInjectionStruct for output
    transitInjectionStruct = struct('transitModelStruct',transitModelStructArray,...
        'transitSeparation',simulatedTransitsStruct.transitSeparation(logicalIdx),...
        'transitDepthToModel',simulatedTransitsStruct.modeledDepth(logicalIdx),...
        'transitWidthToModel',simulatedTransitsStruct.modeledWidth(logicalIdx),...
        'offsetArcSec',simulatedTransitsStruct.offsetArcSec(logicalIdx),...
        'offsetPhase',simulatedTransitsStruct.offsetPhase(logicalIdx),...
        'offsetEnabled',simulatedTransitsStruct.offsetEnabled(logicalIdx),...
        'offsetTransitDepth',simulatedTransitsStruct.offsetTransitDepth(logicalIdx),...
        'targetDataStruct',targetDataStruct,...
        'motionPolyStruct',simulatedTransitsStruct.motionPolyStruct,...
        'backgroundPolyStruct',simulatedTransitsStruct.backgroundPolyStruct,...
        'cadenceTimes',simulatedTransitsStruct.cadenceTimes,...
        'prfObject',simulatedTransitsStruct.prfObject,...
        'CADENCE_DURATION_SEC',simulatedTransitsStruct.CADENCE_DURATION_SEC,...
        'MAG12_E_PER_S',simulatedTransitsStruct.MAG12_E_PER_S);    
end
