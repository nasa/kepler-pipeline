function [ra dec roll] = kepler_dva_attitude(mjds)
%
% function [ra dec roll] = kepler_dva_attitude(mjds)
%
% Creates vectors of the spacecraft attitude for a given time sequence.
%     Options parameters can specify the guide star positions.
%
% INPUTS:
%   mjds--       An array of modified Julian dates to return the attitudes for.
%
% OUTPUTS:
%    Vectors ra, dec, and roll.  Each is nTimeFrames long, and
%      contains the day number, RA, dec, and roll angles of the optimum
%      attitude for that timeframe.
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
    FAKE_QUARTER_NOT_USED_IN_GET_STATES = 0;    
    raDec2PixObject = raDec2PixClass(retrieve_ra_dec_2_pix_model(), 'one-based');
    
    bCompareRecent = 1;
    ctr = FOV_nominal_center();

    quarters = juliandate2quarter(raDec2PixObject, mjds);
    jds = mjds + 2400000.5;

    [guide_stars_ra, guide_stars_dec] = get_guidance_stars(raDec2PixObject, jds, ctr);
    aber_ra = guide_stars_ra;
    aber_dec = guide_stars_dec;
    
%     aber_ra = [];
%     aber_dec = [];
%     for iguidestar = 1:4
%         [x y] = aberrate_stars(guide_stars_ra(iguidestar, :), guide_stars_dec(iguidestar, :), jds);
%         aber_ra(iguidestar, :) = diag(x);
%         aber_dec(iguidestar, :) = diag(y);
%     end

    attitudes = get_states(raDec2PixObject, aber_ra', aber_dec', ctr, FAKE_QUARTER_NOT_USED_IN_GET_STATES, jds, bCompareRecent);
    ra   = attitudes(:,1)';
    dec  = attitudes(:,2)';
    roll = attitudes(:,3)';
    
    [ra dec roll] = fix_edges(ra, dec, roll, quarters); 
return

function [raNew decNew rollNew] = fix_edges(ra, dec, roll, quarters)
    raNew = ra;
    decNew = dec;
    rollNew = roll;

    dRa = 0.0;
    dDec = 0.0;
    dRoll = 0.0;

    for ii = 2:length(quarters)
        isNewQuarter = quarters(ii) ~= quarters(ii-1);
        if isNewQuarter
%             dRa = dRa + (ra(ii) - ra(ii-1));
%             dDec = dDec + (dec(ii) - dec(ii-1));
%             dRoll = dRoll + (roll(ii0) - roll(ii-1));
             dRa = dRa + ra(ii)+ra(ii-2)-2*ra(ii-1) ;
             dDec = dDec + dec(ii)+dec(ii-2)-2*dec(ii-1) ;
             dRoll = dRoll + roll(ii)+roll(ii-2)-2*roll(ii-1) ;
        end

        raNew(ii)   = ra(ii)   - dRa;
        decNew(ii)  = dec(ii)  - dDec;
        rollNew(ii) = roll(ii) - dRoll;
    end

    raNew = raNew(:);
    decNew = decNew(:);
    rollNew = rollNew(:);
return
