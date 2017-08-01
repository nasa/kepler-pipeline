function set_k2_thruster_activity_exclude_cadences( obj, ...
    thrusterFiringEvents, halfWindowSize)
%**************************************************************************
% set_k2_thruster_activity_exclude_cadences( obj, thrusterFiringEvents, ...
%     halfWindowSize)
%**************************************************************************
% Given an output structure from process_K2_thruster_firing_data() and a
% half-window size, determine cadences to exclude from cosmic ray cleaning.
%
% INPUTS
%     thrusterFiringEvents :
%     |
%     |-.definiteThrusterActivityIndicators 
%     |                    : An nCadences-by-1 logical array. Values of 1
%     |                      indicate that thruster activity definitely
%     |                      occurred on the flagged cadence. 
%      -.possibleThrusterActivityIndicators 
%                           : An nCadences-by-1 logical array. Values of 1
%                             indicate that it is uncertain whether
%                             thruster firing on the flagged cadences.
%
%     halfWindowSize       : An integer in the range [0, nCadences]
%                            specifying number of cadences, including the
%                            cadence of the event itself, on either side of
%                            the thruster event to exclude. A value of zero
%                            excludes no cadences, 1 excludes only the
%                            cadence of the event, 2 excludes the event and
%                            one cadence on either side, etc.   
% OUTPUTS
%     (none)
%
% NOTES
%     
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
    nCadences = length(obj.timestamps);

    % Clamp the half-window value to the legal range.
    if halfWindowSize < 0
        halfWindowSize = 0;
    elseif halfWindowSize > nCadences
        halfWindowSize = nCadences;
    end
    
    % Force the half-window size to be an integer.
    halfWindowSize = fix(halfWindowSize);

    possibleEventCadences = ...
        colvec(thrusterFiringEvents.definiteThrusterActivityIndicators | ...
               thrusterFiringEvents.possibleThrusterActivityIndicators);
    thrusterFiringExcludeIndicators = false(size(possibleEventCadences));
    
    for i = 1:halfWindowSize
        excludeIndicators = thrusterFiringExcludeIndicators | ...
            zero_padded_shift(possibleEventCadences, i - 1) | ...
            zero_padded_shift(possibleEventCadences, -(i - 1));
    end
    
    if ~isempty(obj.excludeIndicators)
        excludeIndicators = excludeIndicators | obj.excludeIndicators;
    end
    
    obj.set_exclude_cadences( excludeIndicators );
end

%**************************************************************************    
function shifted = zero_padded_shift( colVector, n )
    colVector(1:abs(n)) = 0;
    shifted = circshift(colVector, n);
end

%********************************** EOF ***********************************
