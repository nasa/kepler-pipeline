function transitInjectionStruct = build_dv_transit_injection_struct(dvDataObject, pixelDataStruct, iTarget, selectCadenceIdx, simulatedTransitsStruct)
%
% function transitInjectionStruct = build_dv_transit_injection_struct(dvDataObject, pixelDataStruct, iTarget, selectCadenceIdx, simulatedTransitsStruct)
%
% This dvDataClass method builds the transitInjectionStruct for DV for a single target and target table. The barycentric cadence times for
% the target table are selected using the index array 'selectCadenceIdx'. These are the timestamps the injected transit model will be built on.
% The input structure 'simulatedTransitsStruct' contains all the transit injection parameters associated with targets in the currect DV unit
% of work. Multiple planet systems are represented in this structure with a separate row for each planet, each using the same keplerId. 
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



transitInjectionStruct = [];                                % default returns empty struct

targetDataStruct = dvDataObject.targetStruct(iTarget);
keplerId = targetDataStruct.keplerId;

logicalIdx = simulatedTransitsStruct.keplerId == keplerId;
if isempty(logicalIdx) || all(~logicalIdx)
    return;                                                 % return empty struct if keplerId is not found in simulatedTransitsStruct
else
    
    % find barycentric timestamps for this target
    barycentricCadenceTimes = dvDataObject.barycentricCadenceTimes;
    baryKeplerIds = [barycentricCadenceTimes.keplerId];
    [tf, barycentricIdx] = ismember(keplerId, baryKeplerIds);
    
    if tf
        
        % repackage pixelDataStruct to match that used in PA
        for iPixel = 1: length(pixelDataStruct)
            pixelDataStruct(iPixel).values = pixelDataStruct(iPixel).calibratedTimeSeries.values;
            pixelDataStruct(iPixel).uncertainties = pixelDataStruct(iPixel).calibratedTimeSeries.uncertainties;
            pixelDataStruct(iPixel).gapIndicators = pixelDataStruct(iPixel).calibratedTimeSeries.gapIndicators;
        end
        pixelDataStruct = rmfield(pixelDataStruct,'calibratedTimeSeries');

        % attach pixeldataStruct to targetDataStruct    
        targetDataStruct.pixelDataStruct = pixelDataStruct;
            
        % update models with config maps and barcentric cadence times for this target table 
        transitModelStructArray = simulatedTransitsStruct.transitModelStructArray(logicalIdx);
        for i = 1:length(transitModelStructArray)
            transitModelStructArray(i).cadenceTimes = barycentricCadenceTimes(barycentricIdx).midTimestamps(selectCadenceIdx);
            transitModelStructArray(i).configMaps   = dvDataObject.configMaps;
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
    else
        
        % throw error if there are no barycentric cadence times available
        error(['DV:build_dv_transit_injection_struct: barycentricCadenceTimes not found for keplerId ',num2str(keplerId)]);
        
    end
end

