function [ mod out row col ra dec roll ] = kepler_dva_aberrated_path( ra_star, dec_star, quarter, julian_dates, bCompareRecent, bAberrateGuess, orbit_file_name )
%
% function [ mod out row col ra dec roll ] = kepler_dva_aberrated_path( ra_star, dec_star, quarter, julian_dates, bCompareRecent, bAberrateGuess )
%
% Generates the aberrated path of a star in pixelspace, given the RA and
%   DEC of the star, and the time sampling desired.
%
% INPUTS:
%    ra_star--        The celestial RA of the star.
%    dec_star--       The celestial DEC of the star.
%    quarter--        The quarter of interest.
%    julian_dates--   The Julian dates to calculate the aberrated path for.
%    bCompareRecent-- A boolean flag to use the most recent timeframe to
%                     calculate the spacecraft attitude (the default), or
%                     the first timeframe(if bCompareRecent = 0).
%    bCompareRecent-- A boolean flag to determine if the attitude-determining routine
%                     should assume the input needs aberration.  Defaults to 1.
%    orbit_file_name- path to a file specifying the Kepler orbit vector
%
% OUTPUTS:
%   Seven vectors: mod, out, row, col, ra, dec, and roll.  The first four are
%   the module, output, pixel row, and pixel column of the star with time.  The
%   last three are the ra, dec, and roll of the optimal spacecraft attitude.
%   Each vector is nTimeFrames long.
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
    tic
    if nargin < 6, bAberrateGuess = 1; end
    if nargin < 5, bCompareRecent = 1; end
    
    obj = raDec2PixClass(retrieve_ra_dec_2_pix_model(), 'one-based');
        
    % Get the unaberrated RA and DECs for the guidance stars:
    %
    [guide_stars_ra, guide_stars_dec] = get_guidance_stars(julian_dates(1));

    % Calculate the stars' aberrated equatorial positions for each timestep:
    %
    [guide_stars_aberrated_ra, guide_stars_aberrated_dec] = aberrate_stars(guide_stars_ra, guide_stars_dec, julian_dates);
    [star_aberrated_ra, star_aberrated_dec] = aberrate_stars(ra_star, dec_star, julian_dates);

    % Get the FOV center (in RA and DEC) and roll angle which minimize the
    %   pixel offsets between the first aberrated frame and each subsequent
    %   frame:
    %
    ctr = FOV_nominal_center();
    correction_states = get_states(  ...
                            guide_stars_aberrated_ra,  ...
                            guide_stars_aberrated_dec, ...
                            ctr,                       ...
                            quarter,                   ...
                            julian_dates,              ...
                            bAberrateGuess);%,            ...
%                             bCompareRecent,            ...
%                             orbit_file_name            ...
%                         );
    ra   = correction_states(:,1);
    dec  = correction_states(:,2);
    roll = correction_states(:,3);
    toc
    
    % Calculate what pixels the stars will fall in, with the spacecraft
    %   oriented to the best states:
    %
    tic
    [mod out row col ] = apply_states(           ...
                             star_aberrated_ra,  ...
                             star_aberrated_dec, ...
                             correction_states,  ...
                             julian_dates -  2400000.5, obj       ...
                         );
    toc
return
