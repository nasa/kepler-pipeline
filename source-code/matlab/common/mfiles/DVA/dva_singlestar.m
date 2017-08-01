
function [ row_out col_out ] = dva_singlestar( module, output, row_in, column_in, quarter, julian_dates, bCompareRecent )
%
% function [ row_out col_out ] = dva_singlestar( module, output, row_in, column_in, quarter, julian_dates, bCompareRecent )
%
% Generate a path for the Differential Velocity Aberration-corrected motion of an input star
%   (at module, output, row, column) for the given quarter.  
%
%   Inputs:
%       module--        The module the star is on.  Defaults to 24.
%       output--        The output the star is on.  Defaults to 4.
%       row_in--        The row number (can be floating point) that the star is on. Defaults to 4.0.
%       column_in--     The column number (can be floating point) that the star is on. Defaults to 4.0.
%       quarter--       The quarter of interest. Defaults to 1.
%       julian_dates--  An array of julian dates.
%
%   Outputs:
%       row_out-- a nTimeFrames-length vector of row positions of the star after correction for DVA, 
%       col_out-- a nTimeFrames-length vector of column positions of the star after correction for DVA, 
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

    % Read, set, and validate arguments:
    %
    if nargin < 7, bCompareRecent =                  1; end
    if nargin < 6
        load keplerInitialOrbit t0jd;
        julian_dates =  t0jd:3:(t0jd+93);
    end
    if nargin < 5, quarter        =                  0; end
    if nargin < 4, column_in      =                100; end
    if nargin < 3, row_in         =                100; end
    if nargin < 2, output         =                  4; end
    if nargin < 1, module         =                 24; end
    

    if ~is_args_valid( module, output, row_in, column_in, quarter )
        error 'invalid args to dva';
    end
    
    % Get the unaberrated RA and DECs for the guidance stars:
    %
    [ guide_stars_ra guide_stars_dec ] = get_guidance_stars( quarter );
    [        star_ra        star_dec ] = get_other_stars( module, output, row_in, column_in, quarter );

    % Calculate the stars' aberrated equatorial positions for each timestep:
    %
    [ guide_stars_aber_ra guide_stars_aber_dec ] = aberrate_stars( guide_stars_ra, guide_stars_dec, julian_dates );
    [        star_aber_ra        star_aber_dec ] = aberrate_stars(        star_ra,        star_dec, julian_dates );

    % Get the FOV center (in RA and DEC) and roll angle which minimize the
    %   pixel offsets between the first aberrated frame and each subsequent
    %   frame:
    %
    correction_states = get_states( guide_stars_aber_ra, guide_stars_aber_dec, FOV_nominal_center(), quarter, julian_dates, bCompareRecent );

    % Calculate what pixels the stars will fall in, with the spacecraft
    %   oriented to the best states:
    %
    [ m o r c ] = apply_states(          ...
                      star_aber_ra,      ...
                      star_aber_dec,     ...
                      correction_states, ...
                      quarter            ...
                  );
                      
    [ row_out col_out ] = baselined_pix( r, c, row_in, column_in );
return

function [ rows cols ] = baselined_pix( pix_r, pix_c, row_in, col_in )
    for i_time = 1 : size( pix_r, 2 )
        rows(i_time) = pix_r(i_time) - pix_r(1) + row_in;
        cols(i_time) = pix_c(i_time) - pix_c(1) + col_in;
    end
return

function bArgsValid = is_args_valid( module, output, row, column, quarter )
    bModule  = 1;
    bOutput  = 1;
    bRow     = 1;
    bCol     = 1;
    bQuarter = 1;

    if ( module < 2 || module > 24 || 5 == module || 21 == module )
        bModule = 0;
        warn 'bad module argument';
    end

    if ( output < 1 || output > 4 )
        bOutput = 0;
        warn 'bad output argument';
    end

    if ( row < 0 || row > 1100 )
        bRow = 0;
        warn 'bad row argument';
    end

    if ( column < 0 || column > 1100 )
        bCol = 0;
        warn 'bad column argument';
    end

    if ( quarter < 0 || quarter > 3 )
        bQuarter = 0;
        warn 'bad quarter argument';
    end

    bArgsValid = bModule && bOutput && bRow && bCol && bQuarter;
return

function [ stars_ra stars_dec ] = get_other_stars( module, output, row_in, column_in, quarter )
    [ stars_ra stars_dec ] =Pix2RADec(  module, output, row_in, column_in, quarter );
return
