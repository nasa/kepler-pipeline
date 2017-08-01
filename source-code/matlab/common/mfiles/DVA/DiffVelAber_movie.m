
function [ mov mov1 ] = DiffVelAber_movie( module, output, quarter, julian_dates, which_others )
%
% function [ mov mov1 ] = DiffVelAber_movie(  module, output, quarter, julian_dates, which_others )
%
% Generate movies or plots for a given output which_others = 2), or the whole field,  for a given
%   (which_others = 1 or 3).  The modules, output, quarter, and julian dates to generate frames for
%   are specified with the arguments.
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
    if nargin < 5, which_others =  2;                  end
    if nargin < 4
        load keplerInitialOrbit t0jd;
        julian_dates =  t0jd:1:(t0jd+93);
    end
    if nargin < 3, quarter      =  0;                  end
    if nargin < 2, output       =  4;                  end
    if nargin < 1, module       = 24;                  end

    if ~is_args_valid( quarter, module, output )
        error 'invalid args to DiffVelAber_movie';
    end
    
    % Nominal FOV center:
    %
    FOV_ctr_nom = FOV_nominal_center();

    % Get the unaberrated RA and DECs for the guidance stars:
    %
    [ guide_stars_ra, guide_stars_dec ] = get_guidance_stars( quarter );
    other_stars_radec = get_other_stars( which_others, quarter, module, output );
    other_stars_ra  = squeeze( other_stars_radec(:,1,:) );
    other_stars_dec = squeeze( other_stars_radec(:,2,:) );

    % Calculate the stars' aberrated equatorial positions for each timestep:
    %
    [ guide_stars_aberrated_ra, guide_stars_aberrated_dec ] = aberrate_stars( guide_stars_ra, guide_stars_dec, julian_dates );
    [ other_stars_aberrated_ra, other_stars_aberrated_dec ] = aberrate_stars( other_stars_ra, other_stars_dec, julian_dates );

    
    % Get the FOV center (in RA and DEC) and roll angle which minimize the
    %   pixel offsets between the first aberrated frame and each subsequent
    %   frame:
    %
    correction_states = get_states( guide_stars_aberrated_ra, guide_stars_aberrated_dec, FOV_ctr_nom, quarter, julian_dates );
    correction_state_offsets = get_state_offsets( FOV_ctr_nom, correction_states );
                               
    % Calculate what pixels the stars will fall in, with the spacecraft
    %   oriented to the best states:
    %
    [cor_m cor_o cor_r cor_c ] = apply_states(                    ...
                                     guide_stars_aberrated_ra,    ...
                                     guide_stars_aberrated_dec,   ...
                                     correction_states,           ...
                                     quarter                      ...
                                 );
    [oth_m oth_o oth_r oth_c ] = apply_states(                    ...
                                     other_stars_aberrated_ra,    ...
                                     other_stars_aberrated_dec,   ...
                                     correction_states,           ...
                                     quarter                      ...
                                 );
          corrected_pix(:,1,:) = cor_m;
          corrected_pix(:,2,:) = cor_o;
          corrected_pix(:,3,:) = cor_r;
          corrected_pix(:,4,:) = cor_c;
    other_corrected_pix(:,1,:) = oth_m;
    other_corrected_pix(:,2,:) = oth_o;
    other_corrected_pix(:,3,:) = oth_r;
    other_corrected_pix(:,4,:) = oth_c;

    switch which_others 
        case 1
            plot_offsets( other_corrected_pix, quarter );
            mov = 666; mov1 = 666;
        case 2
            plot_offsets_oneoutput( other_corrected_pix, quarter, module, output );
            mov = 666; mov1 = 666;
        case 3
            % Make plots and movies:
            %
            do_full_field_plot( other_corrected_pix, other_stars_aberrated_radec, quarter );
            guide_stars_aberrated_pix = convert_to_pix( guide_stars_aberrated_radec, quarter );    
            [ mov mov1 ] = do_plots( guide_stars_aberrated_pix, corrected_pix, nDaysPerFrame );
        otherwise
            error 'unreachable other star set in main';
    end
return

function stars_d = get_other_stars( which_set, quarter, module, output )
    %
    % function stars_d = get_other_stars( which_set, quarter, module, output )
    %
    % Generate another set of stars.  If which_set = 1, put one star on each
    %   output.  If which_set = 2, put 100 stars on one output.  If 
    %   which_set = 3, put about 50 stars randomly down on the FOV.
    %
    if nargin < 4, output    = 4; end    
    if nargin < 3, module    = 2; end
    if nargin < 1, quarter   = 1; end
    if nargin < 2, which_set = 1; end

    switch which_set
        case 1
            mods = 2:24;
            mods = mods( mods ~= 5 & mods ~= 21 );
            outs = repmat( 1:4, size( mods ) )';
            mods = reshape( repmat( mods, 4, 1 ), 84, 1 );
            rows = ones( size( mods ) ) .* 15;
            cols = ones( size( mods ) ) .* 15;            
        case 2
            [ rows cols ] = meshgrid( 100:100:1000 );
            rows = rows(:);
            cols = cols(:);
            mods = ones( size( rows ) ) .* module;
            outs = ones( size( rows ) ) .* output;
        case 3
            nStars =   50;
            nOuts  =    4;
            nRows  = 1000;
            nCols  = 2000;
            nMods  =   25;    

            mods = ceil( rand( nStars, 1 ) * nMods );            
            outs = ceil( rand( nStars, 1 ) * nOuts );
            rows = ceil( rand( nStars, 1 ) * nRows );
            cols = ceil( rand( nStars, 1 ) * nCols );

            good_cells = find( mods ~= 1 & mods ~= 5 & mods ~= 21 & mods ~= 25 );
            mods = mods(good_cells);
            outs = outs(good_cells);
            rows = rows(good_cells);
            cols = cols(good_cells);
        otherwise
            error 'unreachable which_set in get_other_stars';
    end
    
    [ stars_d(:,1) stars_d(:,2) ] = Pix2RADec(  mods, outs, rows, cols, quarter );
return

function bArgsValid = is_args_valid( quarter, module, output )
    bQuarter = 1;
    bModule  = 1;
    bOutput  = 1;

    if ( quarter < 0 || quarter > 3 )
        bQuarter = 0;
    end

    if ( module < 2 || module > 24 || 5 == module || 21 == module )
        bModule = 0;
    end

    if ( output < 1 || output > 4 )
        bOutput = 0;
    end

    bArgsValid = bQuarter && bModule && bOutput;
return


function offsets = get_offsets( pix )
    first_frame = squeeze( pix(:,:,1) );
    for i_time = 1 : size( pix, 3 )
        offsets(:,:,i_time) = squeeze( pix(:,:,i_time) ) - first_frame;
    end
return

function ranges = get_offsets_ranges( pix )
    offsets = get_offsets( pix );
    for i_star = 1 : size( offsets, 1 )
        dx = range( squeeze( offsets(i_star,3,:) ) );
        dy = range( squeeze( offsets(i_star,4,:) ) );
        ranges(i_star,:) = [ dx dy ];
    end
return

function plot_offsets_oneoutput( pix, quarter, module, output )
    offsets = get_offsets( pix );

    [ size_x junk size_y ] = size( offsets );
    nObs = size_x * size_y;
    maxx = max( reshape( squeeze( offsets(:,3,:) ), 1, nObs ) );
    minx = min( reshape( squeeze( offsets(:,3,:) ), 1, nObs ) );
    maxy = max( reshape( squeeze( offsets(:,4,:) ), 1, nObs ) );
    miny = min( reshape( squeeze( offsets(:,4,:) ), 1, nObs ) );    
    
    figure;
    plot( squeeze(offsets(:,3,:))', squeeze(offsets(:,4,:))' )
    title( sprintf( 'Star motions for quarter %d module %d output %d, evenly spaced 10x10 grid', quarter, module, output ) );
    xlabel( 'delta x (pix)' );
    ylabel( 'delta y (pix)' );
    grid on;
    axis equal;
    hold off;
    print( '-dps', sprintf( 'oneoutput_grid_module%02d_output%d_quarter%d.ps', module, output, quarter ) );

    figure;
    ranges = get_offsets_ranges( pix );
    diag = sqrt(ranges(:,1).^2 + ranges(:,2).^2);
    disp( sprintf( 'diagonal range: %8.5f to %8.5f', min( diag ), max( diag ) ) );
    plot( sqrt(ranges(:,1).^2 + ranges(:,2).^2), '.-' );
    title( sprintf( 'Enclosing box size for quarter %d module %d output %d, evenly spaced 10x10 grid', quarter, module, output ) );
    xlabel( 'star number (1-100)' );
    ylabel( 'box diagonal size(pix)' );    
    axis normal;    
    hold off;
    print( '-dps', sprintf( 'oneoutput_diag_module%02d_output%d_quarter%d.ps', module, output, quarter ) );
return

function plot_offsets( pix, quarter )
    
    offsets = get_offsets( pix );
    for i_star = 1 : size( offsets, 1 )
        i_output = mod(i_star,4);
        if 0 == i_output, i_output = 4; end
        
        subplot( 2, 2, i_output );
        
        plot( ...
            squeeze( offsets(i_star,3,:) ), ...
            squeeze( offsets(i_star,4,:) )  ...
        );
        grid on;
        axis equal;
        title( sprintf( 'output %d', i_star ) );
        xlabel( 'delta x (pix)' );
        ylabel( 'delta y (pix)' );        
    
        if 4 == i_output
            sFmt = sprintf( 'quarter%d_module%%02d.ps', quarter );    
            print( '-dps', sprintf( sFmt, i_star / 4 ) );
        end
        
    end
    
    figure;
    ranges = get_offsets_ranges( pix );
    plot(sqrt(ranges(:,1).^2 + ranges(:,2).^2));
    title( sprintf('Diagonal length of enclosing box vs Output Number for quarter %d', quarter ));
    xlabel( 'output number' );
    ylabel( 'diagonal length of enclosing box (pix)' );
    print( '-dps', sprintf( 'quarter%d_overall.ps', quarter ) );
return

function stars_pix = convert_to_pix( stars_radec, quarter )
    if 1 == nargin, quarter = 1; end

    for i_time = 1:size( stars_radec, 3 )
        ra  = stars_radec(:,1,i_time);
        dec = stars_radec(:,2,i_time);
        [ m o r c ] = RADec2Pix( ra, dec, quarter );
        stars_pix(:,:,i_time) = [ m o r c ];
    end
return

function plot_pixel_locs( pix_frames, color )

    if 1 == nargin, color = 'r.'; end

    xy = squeeze( pix_frames(:,3:4,:) );
    for i_star = 1:4
        subplot(2,2,i_star);
        plot( squeeze(xy(i_star,1,:)), ... 
              squeeze(xy(i_star,2,:)), color );
        title( pix_frames(i_star,1,1) );
        hold all
    end
return

function mov = make_movie( varargin )
    if length( varargin ) < 2
        error [ 'Must have first arg = nDaysPerFrame' ...
                'and at least one frameset as second + args' ];
    end;

    nDaysPerFrame = varargin{1};

    frames = varargin{2};
    nStars  = size( frames, 1 );
    nFrames = size( frames, 3 );

    mov = moviein( nFrames );
    rect = get( gcf, 'Position' );
    rect(1:2) = [0 0];

    color   = { 'r', 'g', 'b', 'k' }; % 1 per point
    pt_type = { '.', 'o', 'x', 'v', '+', '%', '>' }; % 1 per set of frames

    [ wid frames ] = munge_frames_for_movie( frames );

    hold off;
    for i_frame = 1:nFrames 
        for i_dataset = 2:length( varargin )

            frames = varargin{i_dataset};
            [ junk frames ] = munge_frames_for_movie( frames );    
            nStars  = size( frames, 1 );
            nFrames = size( frames, 3 );

             for i_star = 1:nStars
                plot_str = [ color{i_star} pt_type{i_dataset-1} ];
                x = squeeze( frames(i_star, 3, i_frame) );
                y = squeeze( frames(i_star, 4, i_frame) );

                plot( x, y, plot_str );
                axis( [-wid wid -wid wid] );
                axis square;
                if 2 == i_dataset, hold all; end
            end
            title ( sprintf( 'Day %03d', nDaysPerFrame * i_frame ) );
            xlabel( 'pix x' );
            ylabel( 'pix y' );

             x = squeeze( frames(:, 3, i_frame) );
             y = squeeze( frames(:, 4, i_frame) );
             plot( x,y, [color{i_dataset-1} '-'] );
        end

        hold off;
        mov(i_frame) = getframe( gcf, rect );
    end

return

function [ dx frames ] = munge_frames_for_movie( frames )
    nStars  = size( frames, 1 );
    for i_star = 1:nStars
        lims(  i_star,:) = bounding_limits( frames(i_star,:,:) );
        frames(i_star,3,:) = frames(i_star,3,:) - lims(i_star,1);
        frames(i_star,4,:) = frames(i_star,4,:) - lims(i_star,3);

        width( i_star) = lims(i_star,2) - lims(i_star,1);
        height(i_star) = lims(i_star,4) - lims(i_star,3);
    end
    big_width( 1) = max( width( 2), width( 3) );
    big_width( 2) = max( width( 1), width( 4) );
    big_height(1) = max( height(3), height(4) );
    big_height(2) = max( height(1), height(2) );

    dx = max( sum( big_width  ), sum( big_height ) );

    frames(3,3,:) = frames(3,3,:) + 0;
    frames(3,4,:) = frames(3,4,:) + 0;

    frames(4,3,:) = frames(4,3,:) + big_width(1);
    frames(4,4,:) = frames(4,4,:) + 0;

    frames(1,3,:) = frames(1,3,:) + big_width( 1);
    frames(1,4,:) = frames(1,4,:) + big_height(1);

    frames(2,3,:) = frames(2,3,:);
    frames(2,4,:) = frames(2,4,:) + big_height(1);
    
    % Flip the data to correspond to their focal plane orientation:
    %
    r = frames(1,3,:);
    c = frames(1,4,:);
    frames(1,3,:) = -r;
    frames(1,4,:) = -c;

    r = frames(2,3,:);
    c = frames(2,4,:);
    frames(2,3,:) =  c;
    frames(2,4,:) = -r;

    r = frames(4,3,:);
    c = frames(4,4,:);
    frames(4,3,:) = -c;
    frames(4,4,:) =  r;
return

function lims = bounding_limits( one_star )
    one_star = squeeze( one_star );
    lims = [ min( one_star(3,:) ),
             max( one_star(3,:) ),
             min( one_star(4,:) ),
             max( one_star(4,:) ) ];
return 

function subplot_data( orig, new, new2, txt )
    % Plot the data for each star:
    %
    nStars = size( orig, 1 );
    for i=1:nStars
        subplot(2,2,i);
        switch ndims( orig )
            case 2
                plot( orig(i,1), orig(i,2), 'r.' );
            case 3
                plot( squeeze(orig(i,1,:)), squeeze(orig(i,2,:)), 'r.' );
            otherwise
                error( sprintf( 'orig must have 2 or 3 dims, has %d', ndims(orig) ) );
        end
        hold all;
        title( txt );
    end
    
    for i=1:nStars
        subplot(2,2,i);
        plot( squeeze( new(i,1,:) ),squeeze( new(i,2,:) ), 'g-' );
    end

    for i=1:nStars
        subplot(2,2,i);
        plot( squeeze( new2(i,1,:) ), squeeze( new2(i,2,:) ), 'b.' );
        hold off;
    end
return

function [ mov mov1 ] = do_plots( aberrated_pix, corrected_pix, nDaysPerFrame )
    figure;
    mov  = make_movie(    ...
           nDaysPerFrame, ...
           aberrated_pix, ...
           corrected_pix  ...
       );

    mov1  = make_movie(   ...
           nDaysPerFrame, ...
           corrected_pix, ...
           corrected_pix  ...
       );

    figure;
    plot_pixel_locs( aberrated_pix );
    plot_pixel_locs( corrected_pix, 'bx'  );
    hold off;
return

function do_full_field_plot( fixed_pix, aberrated, quarter )
    % plot the ra/decs of the aberrated stars with and without the
    %     correction:
    
    for i_star      = 1 : size( fixed_pix, 1 )
        for i_frame = 1 : size( fixed_pix, 3 )

            tmp = fixed_pix(i_star,:,i_frame);
            [ fixed_radec(i_star,1,i_frame) fixed_radec(i_star,2,i_frame) ] =...
                Pix2RADec(  tmp(1), tmp(2), tmp(3), tmp(4), quarter );
        end
    end

    figure
    title 'Random Stars with Aberration Correction'
    hold all;
    colors = [ 'b' 'g' 'r' 'c' 'm' 'y' 'k' ];
    points = [ '.' 'o' 'x' '+' '*' 's' 'd' 'v' '^' '<' '>' 'p' 'h' ];
    
    nCol = length( colors );    
    nPts = length( points );
    
    for i_star = 1 : size( aberrated, 1 )
        col = colors( mod( i_star,   nCol )   + 1 );
        col2= colors( mod( i_star+1, nCol )   + 1 );
        pts = points( ceil( i_star / nPts ) + 1 );
        disp_str = [ col  pts ];
        disp_str2= [ col2 pts ];
        
        tmp_a   = squeeze(   aberrated(i_star,:,:) );
        tmp_cor = squeeze( fixed_radec(i_star,:,:) );

        plot( tmp_a(  1,:), tmp_a(  2,:), disp_str );
        plot( tmp_cor(1,:), tmp_cor(2,:), disp_str2 );
    end
    hold off
return

function plot4rows ( rows, arg )
    if 1 == nargin, arg = '-'; end;
    
    plot( rows(1,:), ['r' arg] ); hold all;
    plot( rows(2,:), ['g' arg] );
    plot( rows(3,:), ['b' arg] );
    plot( rows(4,:), ['k' arg] ); hold off;    
return
