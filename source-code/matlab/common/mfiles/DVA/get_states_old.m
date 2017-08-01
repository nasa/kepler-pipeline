function states = get_states( stars_ra, stars_dec, firstguess, quarter, julian_dates, bCompareRecent, bAberrateGuess,  orbit_file_name )
%
% function states = get_states( stars_ra, stars_dec, firstguess, quarter, julian_dates, bCompareRecent, bAberrateGuess )
%
% Return the best (defined in best_state) apparent motion-minimizing
%   spacecraft attitude for the input star positions, based on the attitude initial
%   guess.
%
% Inputs:
%   stars_ra-- RAs of the input stars.  A 2d matrix, with stars in the rows
%      and timesteps in the columns.
%   stars_dec-- DECs of the input stars.  Same dimensions as stars_ra
%   firstguess-- initial guess at the spacecraft attitude.  This should be
%       an UNABERRATED RA/DEC
%   quarter-- the quarter of the oberservation
%   bCompareRecent-- boolean flag to minimize motion from previous
%       timestep, or from first timestep.  Defaults to 1.
%   bAberrateGuess-- boolean flag to indicate if the input guess is to be aberrated or not.
%   orbit_file_name- path to a file specifying the Kepler orbit vector
%
% Outputs:
%    states-- vector of spacecraft attitudes, one timestep.
%    states(:,1) = ra, states(:,2) = dec, states(:,3) = roll
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

    if nargin < 7, bAberrateGuess = 1; end;
    if nargin < 6, bCompareRecent = 1; end;

    if bAberrateGuess
        if nargin < 8
            [ ab_guess_ra ab_guess_dec ] = aberrate_stars( firstguess(1), firstguess(2), julian_dates(1) );
        else
            [ ab_guess_ra ab_guess_dec ] = aberrate_stars( firstguess(1), firstguess(2), julian_dates(1),  orbit_file_name );
        end
        firstguess(1) = ab_guess_ra;
        firstguess(2) = ab_guess_dec;
    end

    states(1,:) = firstguess;

    for i_time = 2 : size( stars_ra, 2 )

        curr_stars  = [stars_ra(:,i_time) stars_dec(:,i_time)];
        state_guess = states(i_time-1,:);

        if bCompareRecent  % Minimze offset from previous timestep:
            index = i_time - 1;
        else % Minimize offset from FIRST timestep:
            index = 1;
        end

        prev_stars = [stars_ra(:,index) stars_dec(:,index)];
        prev_state = states(index,:);
        states(i_time,:) = best_state( prev_stars, curr_stars, prev_state, state_guess, quarter, julian_dates(i_time) );
    end
return
