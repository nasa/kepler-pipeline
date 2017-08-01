function outputStruct = barycentric_correction_matlab_controller(inputStruct)
%
% outputStruct = barycentric_correction_matlab_controller(inputStruct)
%
% DESCRIPTION:
%     The matlab sub-controller to generate the barycentric correction 
%     values. See main AR controller ar_matlab_controller.m for inputs 
%     and outputs.        
% 
% Copyright 2017 United States Government as represented by the
% Administrator of the National Aeronautics and Space Administration.
% All Rights Reserved.
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

    % Initialize the output structure, and return an empty output structure
    % if the barycentricInputs has no targets in it:
    %
    initOutputStruct = struct('barycentricTimeOffsets', [], ...
        'barycentricGapIndicator', [], 'keplerId', [], 'raDecimalHours', [],...
        'decDecimalDegrees', []);
    
    outputStruct = repmat(initOutputStruct, 1, 0);
    if isempty(inputStruct.barycentricInputs.barycentricTargets)
        return
    end
    
    raDec2PixObject = raDec2PixClass(inputStruct.raDec2PixModel, 'one-based');

    % Generate the per-target entries for the fake PA struct (including the ra/dec from the refMjd):
    %
    nTargets = length(inputStruct.barycentricInputs.barycentricTargets);
    targetRas = [inputStruct.barycentricInputs.barycentricTargets.ra];
    targetRas = targetRas .* (360 / 24);
    targetDecs = [inputStruct.barycentricInputs.barycentricTargets.dec];
    targetNeedsRaDec = isnan(targetRas) | isnan(targetDecs);
    
    for itarget = 1:nTargets
        if ~targetNeedsRaDec(itarget)
            continue
        end
        % Get MJD of the reference cadence:
        refCadenceIndex = find([inputStruct.longCadenceTimesStruct.cadenceNumbers] == ...
            inputStruct.barycentricInputs.barycentricTargets(itarget).longCadenceReference);

        refMjd = inputStruct.longCadenceTimesStruct.midTimestamps(refCadenceIndex);
        
        % Get the ra/dec at that MJD:
        barycentricInput = inputStruct.barycentricInputs.barycentricTargets(itarget);
        
        % input struct row/col are zero-basedec;
        [targetRas(itarget), targetDecs(itarget)] = ...
            pix_2_ra_dec(raDec2PixObject, inputStruct.ccdModule, ...
                inputStruct.ccdOutput, barycentricInput.centerCcdRow+1, ...
                barycentricInput.centerCcdCol+1, refMjd); 
    end
    
    baryResults = ar_compute_barycentric_offset_by_target(inputStruct, targetRas, targetDecs, raDec2PixObject);
    nResults = length(baryResults);
    
    if nResults ~= nTargets
        error('MATLAB:ar:barycentric_correction_matlab_controller', ...
              'The length of the output data (%d) is not the same as the input data (%d)', ...
              nResults, nTargets);
    end
    
    outputStruct = repmat(initOutputStruct, 1, nResults);
    for itarget = 1:nResults
        outputStruct(itarget).barycentricTimeOffsets = baryResults(itarget).barycentricTimeOffset.values;
        outputStruct(itarget).barycentricGapIndicator = baryResults(itarget).barycentricTimeOffset.gapIndicators;
        outputStruct(itarget).keplerId = inputStruct.barycentricInputs.barycentricTargets(itarget).keplerId;
        outputStruct(itarget).raDecimalHours = targetRas(itarget) * 24.0 / 360.0;
        outputStruct(itarget).decDecimalDegrees = targetDecs(itarget);
    end
    
return

function baryResults = ar_compute_barycentric_offset_by_target(inputStruct, targetRas, targetDecs, raDec2PixObject)

    % Get the timestamps, cadence gap indicators and number of targets.
    %
    cadenceTimes = inputStruct.cadenceTimesStruct;
    gapIndicators = cadenceTimes.gapIndicators;
    mjdTimestamps = cadenceTimes.midTimestamps(~gapIndicators);
    nTargets = length(targetRas);
    
    % Get the readout offset for the ccdModule
    %
    readoutOffset = get_readout_offset(inputStruct.configMaps, inputStruct.ccdModule, inputStruct.fcConstants);


    % Get the per-target barycentric offset:
    %
    for iTarget = 1 : nTargets
        baryResults(iTarget).barycentricTimeOffset.values = zeros(size(gapIndicators));
        baryResults(iTarget).barycentricTimeOffset.gapIndicators = true(size(gapIndicators));

        % If ra/dec are zero, skip (unknown target in KIC):
        %
        isValidTarget = (targetRas(iTarget) ~= 0 && targetDecs(iTarget) ~= 0);
        if ~isValidTarget
            continue
        end
        %[barycentricTimestamps] = kepler_time_to_barycentric(raDec2PixObject, targetStarDataStruct(iTarget).ra, targetStarDataStruct(iTarget).dec, mjdTimestamps); % incorrect
        [barycentricTimestamps] = ...
            kepler_time_to_barycentric(raDec2PixObject, ...
                targetRas(iTarget), targetDecs(iTarget), ...
                mjdTimestamps - readoutOffset);

        values = zeros(size(gapIndicators));
        %values(~gapIndicators) = barycentricTimestamps(:) - mjdTimestamps - readoutOffset; % incorrect
        values(~gapIndicators) = barycentricTimestamps(:) - mjdTimestamps;

        baryResults(iTarget).barycentricTimeOffset.values = values;
        baryResults(iTarget).barycentricTimeOffset.gapIndicators = gapIndicators;
    end 

return
