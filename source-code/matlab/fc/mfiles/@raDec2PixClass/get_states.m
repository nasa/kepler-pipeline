function states = get_states(raDec2PixObject, starsRa, starsDec, firstguess, quarter, julianDates, bAberrateGuess)
%
% function states = get_states(raDec2PixObject, starsRa, starsDec, firstguess, quarter, julianDates, bCompareRecent, bAberrateGuess)
%
% Return the best (defined in best_state) apparent motion-minimizing
%   spacecraft attitude for the input star positions, based on the attitude initial
%   guess.
%
% Inputs:
%   starsRa-- RAs of the input stars.  A 2d matrix, with stars in the rows
%      and timesteps in the columns.
%   starsDec-- DECs of the input stars.  Same dimensions as starsRa
%   firstguess-- initial guess at the spacecraft attitude.  This should be
%       an UNABERRATED RA/DEC
%   quarter-- the quarter of the observation
%   bCompareRecent-- boolean flag to minimize motion from previous
%       timestep, or from first timestep.  Defaults to 1.
%   bAberrateGuess-- boolean flag to indicate if the input guess is to be
%   aberrated or not.
%
% Outputs:
%    states-- vector of spacecraft attitudes, one per timestep.
%    states(:,1) = ra, states(:,2) = dec, states(:,3) = roll
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

    if nargin < 6, bAberrateGuess = 1; end;

    if bAberrateGuess
        [ abGuessRa abGuessDec ] = aberrate_ra_dec(raDec2PixObject, ...
            firstguess(1), firstguess(2), julianDates(1));
        firstguess(1) = abGuessRa;
        firstguess(2) = abGuessDec;
    end

    states(1,:) = firstguess;

    for itime = 2 : size(starsRa, 1)
        currStars  = [starsRa(itime,:); starsDec(itime,:)];
        lastIndx = itime - 1;
        stateGuess = states(lastIndx,:);
        
        prevStars = [starsRa(lastIndx,:); starsDec(lastIndx,:)];
        prevState = states(lastIndx,:);
        states(itime,:) = best_state(prevStars', currStars', prevState, ...
            stateGuess, julianDates(lastIndx:itime), raDec2PixObject);
    end
return

