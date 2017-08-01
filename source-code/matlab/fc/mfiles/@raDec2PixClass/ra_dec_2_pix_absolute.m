function [module output row column] = ra_dec_2_pix_absolute(raDec2PixObject, ra, dec, mjds, raPointing, decPointing, rollPointing, aberrateFlag)
%        [module output row column] = ra_dec_2_pix_absolute(raDec2PixObject, ra, dec, mjds, raPointing, decPointing, rollPointing, aberrateFlag)
%
% Returns the pixelspace positions of the N sky coordinates specified by (ra, dec), at the M times specified by mjds.
% The raPointing, decPointing, and rollPointing must be the same length as mjds.
% The size of the outputs will be NxM.
%
% INPUTS:
%   ra  -- The RA of the sky coordindate(s) in degrees.  A one-or-more element vector with a length the same size as dec.
%   dec -- The RA of the sky coordindate(s) in degrees.  A one-or-more element vector with a length the same size as ra.
%   mjds --The modified julian date of for the coordinate transformation.  Must be the same size as raPointing, decPointing, and rollPointing.  
%   raPointing --The pointing RA of the spacecraft for the vector of Julian dates given in the mjds argument.  Must be the same size as mjds.
%   decPointing --The pointing declination of the spacecraft for the vector of Julian dates given in the mjds argument.  Must be the same size as mjds.
%   rollPointing --The pointing roll of the spacecraft for the vector of Julian dates given in the mjds argument.  Must be the same size as mjds.
%
% OUTPUTS:
%   module -- the Kepler CCD module the sky coordinate falls upon.  The size of this output is NxM, where N is the length of ra, and M is the length of mjds.
%   output -- the Kepler CCD outupt the sky coordinate falls upon.  The size of this output is NxM, where N is the length of ra, and M is the length of mjds.
%   row -- the Kepler pixel row the sky coordinate falls upon.  The size of this output is NxM, where N is the length of ra, and M is the length of mjds.
%   column -- the Kepler CCD column the sky coordinate falls upon.  The size of this output is NxM, where N is the length of ra, and M is the length of mjds.
% 
%   N.B.: The row and column outputs are on the accumulation memory silicon (they include the collateral regions). 
%
%         If the instance of the raDec2PixObject that is being executed is zero-based (as determined by the constructor
%         argument and the is_zero_based(raDec2PixObject) method) the center of the science pixel closest to the readout
%         node is (20.0, 12.0), and the center of the first pixel in accumulation memory is (0.0, 0.0).
%
%         If the instance of the raDec2PixObject that is being executed is one-based (as determined by the constructor
%         argument and the is_one_based(raDec2PixObject) method) the center of the science pixel closest to the readout
%         node is (21.0, 13.0), and the center of the first pixel in accumulation memory is (1.0, 1.0).
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
    switch nargin
        case 4
            aberrateFlag = 1;
        case 5
            aberrateFlag = raPointing; % TODO: probably better to do this with varargs later
        case 7
            aberrateFlag = 1;
        case 8
            1; % do nothing
        otherwise
            error('MATLAB:FC:raDec2PixClass:ra_dec_2_pix_absolute', 'ra_dec_2_pix_absolute takes 4, 5, 7, or 8 arguments');
    end

    
    isReturnMatrix = length(ra) ~= 1 && length(mjds) ~= 1;

    if isempty(ra) 
        error('MATLAB:FC:raDec2PixClass:ra_dec_2_pix_absolute', 'Zero-element ra argument in ra_dec_2_pix_absolute. Error!');
    end
    if isempty(dec) 
        error('MATLAB:FC:raDec2PixClass:ra_dec_2_pix_absolute', 'Zero-element dec argument in ra_dec_2_pix_absolute. Error!');
    end
	if isempty(mjds)
        error('MATLAB:FC:raDec2PixClass:ra_dec_2_pix_absolute', 'Zero-element mjds argument in ra_dec_2_pix_absolute. Error!');
    end
    
    module = zeros(length(ra), length(mjds));
    output = module;
    row    = module;
    column = module;

    jds = mjds + raDec2PixObject.mjdOffset;

    if (4 == nargin || 5 == nargin)
        pointingObject = pointingClass(get(raDec2PixObject, 'pointingModel'));
        pointing = get_pointing(pointingObject, mjds);
        raPointing = pointing(:,1);
        decPointing = pointing(:,2);
        rollPointing = pointing(:,3);
    elseif (7 == nargin || 8 == nargin)
        rollTimeObject = rollTimeClass(get(raDec2PixObject, 'rollTimeModel'));
        segmentStartMjds = get_segment_start_mjds(rollTimeObject, mjds);
        pointingData = struct(...
            'mjds', mjds(:), ...
            'ras', raPointing(:), ...
            'declinations', decPointing(:), ...
            'rolls', rollPointing(:), ...
            'segmentStartMjds', segmentStartMjds(:));
        raDec2PixObject = set(raDec2PixObject, 'pointingModel', pointingData);
    end

    if isReturnMatrix
        for itime = 1:length(jds)
            [tmpm tmpo tmpr tmpc] = RaDec2Pix(raDec2PixObject, ra, dec, jds(itime), raPointing(itime), decPointing(itime), rollPointing(itime), aberrateFlag);
            module(:,itime) = tmpm;
            output(:,itime) = tmpo;
            row(   :,itime) = tmpr;
            column(:,itime) = tmpc;
        end
    else
        [module output row column] = RaDec2Pix(raDec2PixObject, ra, dec, jds, raPointing(:), decPointing(:), rollPointing(:), aberrateFlag);
    end
    
    % Adjust inputs to move center of pixel to (0.0, 0.0);
    %
    row = row - 0.5;
    column = column - 0.5;

    % RaDec2Pix gives row/col on the visable silicon.  Adjust the outputs to be on total accumulation memory:
    %
    row    = row    + raDec2PixObject.nMaskedSmear;
    column = column + raDec2PixObject.nLeadingBlack;

    % Fix row/col args depending on base value (one-based vs zero-based):
    %
    if is_one_based(raDec2PixObject)
        row = row + 1;
        column = column + 1;
    else
        % the object is zero-based, and the row/column values are correct. Do nothing.
    end
return
