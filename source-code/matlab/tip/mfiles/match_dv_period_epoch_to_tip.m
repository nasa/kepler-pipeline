function [indexIntoTip, indexIntoDv] = match_dv_period_epoch_to_tip(tipData, dvData, inputStruct ) 
% 
% function [indexIntoTip, indexIntoDv] = match_dv_period_epoch_to_tip(tipData, dvData, inputStruct ) 
% 
% This function matches the TIP injected transit period and epoch with those found in DV to within tolerance and returns lists of matching
% indices into tipData and dvData. 
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

% extract parameters
periodFractionalTolerance   = inputStruct.periodFractionalTolerance;
epochFractionalTolerance    = inputStruct.epochFractionalTolerance;
epochToleranceDays          = inputStruct.epochToleranceDays;
periodMultiplier            = inputStruct.periodMultiplier;

% extract keplerIds
tipKeplerId = tipData.keplerId;
dvKeplerId  = dvData.keplerId;

% initialize matched indices and differences as nan
indexIntoDv = nan(size(tipKeplerId));
indexIntoTip = nan(size(dvKeplerId));

% get all the period data - apply multiplier to tipPeriod
tipPeriod = periodMultiplier .* tipData.orbitalPeriodDays;
dvPeriod  = dvData.allTransitsFit.orbitalPeriodDays.value;

% get all the epoch data
tipEpoch = tipData.epochBjd;
dvEpoch = dvData.allTransitsFit.transitEpochBkjd.value;


% loop through TIP ids looking for matches
for i = 1:length(tipKeplerId)
        
    % find keplerId match
    tf = ismember(dvKeplerId, tipKeplerId(i));
    if any(tf)
        
        % reset diffs
        periodDiff = nan(size(dvKeplerId));
        epochDiff = nan(size(dvKeplerId));
        
        % extract TIP period for targetId
        period = tipPeriod(i);
        
        % find the shorter of the original and multiplied period for epoch matching
        originalPeriod = period / periodMultiplier;
        shorterPeriod = min(originalPeriod,period);
        
        % find period match
        periodDiff(tf) = abs((period - dvPeriod(tf))./period);
        
        % update logical
        tf = tf & (periodDiff < periodFractionalTolerance);
        
        if any(tf)
            
            % Find epoch match based on shorter of original tipPeriod and multiplied period.
            % This will include matches where DV finds a signal with the right period but out
            % of phase with the original period multiplied signal
            tE = tipEpoch(i);
            dE = dvEpoch(tf) + kjd_offset_from_mjd;
            if epochToleranceDays == 0                
                epochDiff(tf) = abs((mod(tE - dE + 0.5.*shorterPeriod,shorterPeriod) - 0.5.*shorterPeriod)./ period);
                tf = tf & (epochDiff < epochFractionalTolerance);
            else
                epochDiff(tf) = abs(mod(tE - dE + 0.5.*shorterPeriod,shorterPeriod) - 0.5.*shorterPeriod);
                tf = tf & (epochDiff < epochToleranceDays);
            end                        
            
            if any(tf)
                % if more than one match choose the closest
                if numel(find(tf)) > 1
                    minPeriod = min(periodDiff(tf));
                    tf = tf & (periodDiff == minPeriod);
                end                
                % pick the first one if more than one at the minimum
                idx = find(tf);
                indexIntoDv(i) = idx(1);        % set index into dvData for match at tipData(i)
                indexIntoTip(idx(1)) = i;       % set index into tipData for match at dvData(idx(1))                                
            end
        end
    end
end
