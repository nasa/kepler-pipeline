%% classdef mapCentroidClass
%
% Generates and compiles centroid motion data for all targets.
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

classdef mapCentroidClass

properties (Constant, GetAccess = 'private')
    RA_HOURS_TO_DEGREES = 360 / 24; % RA stored in hours but need to convert to degrees to line up with Dec
    component = 'compileCentroidData';
end

properties(GetAccess = 'public', SetAccess = 'private')
    motion = [];
    centroidMotionDataExists = false;
end

methods (Access = 'public')

    function obj = mapCentroidClass(mapData, mapInput, createEmptyObject)

        multiChannelRun = ~isempty(mapInput.multiChannelMotionPolyStruct);
        nChannels = length(mapInput.multiChannelMotionPolyStruct);

        if (nChannels >1)
            mapInput.debug.display(obj.component, 'Compiling Centroid Data for a multi-channel run, this may take a while...');
        else
            mapInput.debug.display(obj.component, 'Compiling Centroid Data...');
        end
        tic;

        centroidMotionStruct = struct( ...
                                'row', nan(mapData.nCadences,1), ...
                                'col', nan(mapData.nCadences,1));

        % Smoke test data appears to not always be good motion poly data and can be to short in length
        if (createEmptyObject || ~multiChannelRun && (isempty(mapInput.motionPolyStruct) || length(mapInput.motionPolyStruct) < mapData.nCadences))
            obj.centroidMotionDataExists = false;
            return;
        end


        obj.motion = repmat (centroidMotionStruct, [mapData.nTargets, 1]);
        
        % Vectors of target RA and Dec
        targetRa = obj.RA_HOURS_TO_DEGREES * mapData.kic.ra;
        targetDec = mapData.kic.dec;

        centroidMotionTemp = struct('row', nan(mapData.nCadences, mapData.nTargets), ...
                                    'col', nan(mapData.nCadences, mapData.nTargets));

        targetsOnChannel = repmat(struct('targets', []), [nChannels,1]);
        for iChannel = 1 : nChannels
            targetsOnChannel(iChannel).targets = [mapInput.targetDataStruct.channelIndex] == iChannel;
        end

        for iCadence = 1 : mapData.nCadences
            
            if (multiChannelRun)
                % Multi channel runs have different motion polynomials for each channel so, we need to do this per channel
                for iChannel = 1 : nChannels
                    % Find all targets for this channel
                    centroidMotionTemp.row(iCadence,targetsOnChannel(iChannel).targets) = ...
                        weighted_polyval2d(targetRa(targetsOnChannel(iChannel).targets), targetDec(targetsOnChannel(iChannel).targets), ...
                            mapInput.multiChannelMotionPolyStruct(iChannel).motionPolyStruct(iCadence).rowPoly);                                                  

                    centroidMotionTemp.col(iCadence,targetsOnChannel(iChannel).targets) = ...
                        weighted_polyval2d(targetRa(targetsOnChannel(iChannel).targets), targetDec(targetsOnChannel(iChannel).targets), ...
                            mapInput.multiChannelMotionPolyStruct(iChannel).motionPolyStruct(iCadence).colPoly);
                end
            else
                % This function will calculate the centroid for all targets at ONE cadence
                centroidMotionTemp.row(iCadence,:) = weighted_polyval2d(targetRa, targetDec, ...
                    mapInput.motionPolyStruct(iCadence).rowPoly);
                centroidMotionTemp.col(iCadence,:) = weighted_polyval2d(targetRa, targetDec, ...
                    mapInput.motionPolyStruct(iCadence).colPoly);
            end
        end

        gaps = [mapData.normTargetDataStruct.gapIndicators];

        for iTarget = 1 : mapData.nTargets
            obj.motion(iTarget).row(~gaps(:,iTarget)) = centroidMotionTemp.row(~gaps(:,iTarget), iTarget);
            obj.motion(iTarget).col(~gaps(:,iTarget)) = centroidMotionTemp.col(~gaps(:,iTarget), iTarget);
        end
        clear centroidMotionTemp;

        obj.centroidMotionDataExists = true;

        duration = toc;
        mapInput.debug.display(obj.component, ['Centroid Data Compiled: ' num2str(duration) ...
            ' seconds = '  num2str(duration/60) ' minutes']);
    end

end % public methods

end % classdef mapCentroidClass

