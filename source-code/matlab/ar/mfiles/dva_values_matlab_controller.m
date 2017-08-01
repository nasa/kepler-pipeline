function outputStruct = dva_values_matlab_controller(inputStruct)
%
% outputStruct = dva_values_matlab_controller(inputStruct)
%
% DESCRIPTION:
%     The matlab sub-controller to calculate DVA values.  See main AR 
%     controller ar_matlab_controller.m for inputs and outputs.        
%
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

    nTargets = length(inputStruct.dvaInputs.dvaTargets);
    outputStruct = repmat(initializeOutputStruct(), 1, nTargets);
    if nTargets == 0
        return
    end
    
    motionPolyStruct = poly_blob_series_to_struct(inputStruct.motionPolyBlobs);

    % If the data are LC, the gap indicators are the MP gap indicators.
    % If the data are SC, the gap indicators need to be computed.  If the
    % short cadence started at the same time as the long cadence then we
    % could just repmat, but short cadence may not start or end on a
    % precise long cadence boundry.
    gaps = construct_gaps(inputStruct.motionPolyBlobs.gapIndicators, ...
        inputStruct.longCadenceTimesStruct, inputStruct.cadenceTimesStruct, ...
        inputStruct.cadenceType);
        
    for itarget = 1:nTargets
        outputStruct(itarget).keplerId = inputStruct.dvaInputs.dvaTargets(itarget).keplerId;
        
        [rowOffsets columnOffsets refMjd targetRaDegrees targetDec isRaDecNull] = dva_from_moton_polys(inputStruct, motionPolyStruct, itarget);
        
        outputStruct(itarget).rowDva = rowOffsets;
        outputStruct(itarget).columnDva = columnOffsets;

        outputStruct(itarget).rowGapIndicator = gaps;
        outputStruct(itarget).columnGapIndicator = gaps;
    end

return

% Creates the gap indicators or the dva motion timeseries.  This is simple
% for long cadence, but convoluted for short cadence.
function [gaps] = construct_gaps(motionPolyGapIndicators, lcCadenceTimes, cadenceTimes, cadenceType)
    if strcmpi(cadenceType, 'long')
        gaps = motionPolyGapIndicators;
        return
    end
    % else short cadence  this handles the cade where the short cadence
    % may not start at the same time as the long cadence
    gaps = false(length(cadenceTimes.gapIndicators), 1);
    shortCadencesPerLongCadence = 30; %Get from configmap?
    endOfFirstLc = lcCadenceTimes.endTimestamps(1);
    scMjdMidTimes = cadenceTimes.midTimestamps;
    shortIndexOffset = 1;
    while scMjdMidTimes(shortIndexOffset) < endOfFirstLc
        if cadenceTimes.gapIndicators(shortIndexOffset)
            error('MATLAB:ar:dva_values_matlab_controller', ...
                'Gap in the begnning of short cadence means I can not be sure of when short cadence starts relative to long cadence.');
        end
        shortIndexOffset = shortIndexOffset + 1;
    end
    shortIndexOffset = shortCadencesPerLongCadence - shortIndexOffset - 1;
    for desti=1:length(gaps)
        matchingLcIndex = floor( (desti + shortIndexOffset) / shortCadencesPerLongCadence) + 1;
         if matchingLcIndex < 1
            matchingLcIndex = 1;
         elseif matchingLcIndex > length(motionPolyGapIndicators)
            matchingLcIndex = length(motionPolyGapIndicators);
        end 
        gaps(desti) = motionPolyGapIndicators(matchingLcIndex);
    end
return

function [rowOffsets columnOffsets refMjd targetRa targetDec isBadRaDec] = ...
    dva_from_moton_polys(inputStruct, motionPolyStruct, itarget)

    refCadenceIndex = find([motionPolyStruct.cadence] == inputStruct.dvaInputs.dvaTargets(itarget).longCadenceReference);
    refMjd = motionPolyStruct(refCadenceIndex).mjdMidTime;
        
    if ~motionPolyStruct(refCadenceIndex).rowPolyStatus || ~motionPolyStruct(refCadenceIndex).colPolyStatus
        error('MATLAB:ar:dva_values_matlab_controller', ...
            'The motion poly for target %d is gapped.  Exiting.', itarget);
    end
    
    % Interpolate motion polys if the data is short cadence:
    [motionPolyStruct refCadenceIndex] = ...
        interpolate_motion_polys_ar(inputStruct.cadenceType, ...
            motionPolyStruct, inputStruct.longCadenceTimesStruct, ...
            inputStruct.cadenceTimesStruct, refCadenceIndex);
    rowPoly = [motionPolyStruct.rowPoly];
    colPoly = [motionPolyStruct.colPoly];
    
    refRowPoly = rowPoly(refCadenceIndex);
    refColPoly = colPoly(refCadenceIndex);
    
    targetStruct = inputStruct.dvaInputs.dvaTargets(itarget);
    
    isBadRaDec = targetStruct.ra == 0 || targetStruct.dec == 0 || ...
                 isnan(targetStruct.ra) || isnan(targetStruct.dec);
    if isBadRaDec
        [targetRa targetDec] = run_pix_2_ra_dec(inputStruct.raDec2PixModel, inputStruct.ccdModule, inputStruct.ccdOutput, targetStruct.targetRowCentroid+1, targetStruct.targetColumnCentroid+1, refMjd); % targetStruct row/column values are zero-based
    else
        targetRa  = targetStruct.ra * 15;
        targetDec = targetStruct.dec;
    end
    
    referenceCadenceRow    = weighted_polyval2d(targetRa, targetDec, refRowPoly);
    referenceCadenceColumn = weighted_polyval2d(targetRa, targetDec, refColPoly);
    
    nCadences = length(inputStruct.cadenceTimesStruct.cadenceNumbers);
    rowOffsets    = zeros(nCadences, 1);
    columnOffsets = zeros(nCadences, 1);

    for iCadence = 1:nCadences
        cadenceRow    = weighted_polyval2d(targetRa, targetDec, rowPoly(iCadence));
        cadenceColumn = weighted_polyval2d(targetRa, targetDec, colPoly(iCadence));
        
        rowOffsets(   iCadence) = cadenceRow - referenceCadenceRow;
        columnOffsets(iCadence) = cadenceColumn - referenceCadenceColumn;
    end

return

function singleOutputStruct = initializeOutputStruct()
    singleOutputStruct = struct(...
        'keplerId', [0], ...
        'rowDva', [0], ...
        'columnDva', [0], ...
        'rowGapIndicator', [0], ...
        'columnGapIndicator', [0]);
return
