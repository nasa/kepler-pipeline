function [module, output, row, column] = RaDec2Pix(raDec2PixObject, ra, dec, julianTime, raPointing, decPointing,  rollPointing, aberrateFlag)
%
% function [module, output, row, column] = RaDec2Pix(raDec2PixObject, ra, dec, julianTime, raPointing, decPointing,  rollPointing, [aberrateFlag])
%
% INPUTS:
%    ra         - the right ascension of the star(s), in degrees.  If there is more than one
%                 star, this argument should be a vector.  The ra and dec arguments
%                 must be the same size.
%    dec        - the declination of the star(s), in degrees.  If there is more than one
%                 star, this argument should be a vector. The ra and dec arguments
%                 must be the same size.
%    julianTime - the julian times to do the (RA,Dec)->Pix conversion
%                 for.  The size of this argument must be:
%                     1) the same as ra and dec,
%                     2) a single value, or
%                     3) an arbitrary length vector, iff ra and dec are
%                        single values
%    raPointing    - Optional argument specifying focal plane center in RA, in
%            degrees.  raPointing, decPointing, and rollPointing must all be specified, or none.
%    decPointing    - Optional argument specifying focal plane center in declination, in degrees.
%    rollPointing  - Optional argument specifying focal plane rotation, in degrees.
%
%        If (raPointing, decPointing, rollPointing) focal plane pointing is not specified, the nominal
%        pointing is used.
%
%        If specified, the (raPointing, decPointing, rollPointing) args must be the same length as julianTime.
%
%    aberrateFlag - Optional argument to turn aberration on or off. The default is on.
%            If raPointing, decPointing, and phiPoinnting are not specified, this can be used as the
%            fourth argument.
%    
%    If the aberrateFlag flag is on (the default is on), the input RAs and Decs 
%      are assumed to be sky coordinates unaffected by the aberration of
%      starlight.
%    
%    
%
% OUTPUTS:
%    [module output row column] Four column vectors of the same size as the
%    largest of the input arguments (ra, dec, and julianTime)
%
%
% SAMPLE USE CASES:
%
%    The simplest case:  single-element inputs and outputs:
%        ra = 300, dec = 45, jt = 2455000, [module output row col] = RaDec2Pix(ra, dec, jt);
%
%    Multiple element ra/dec inputs, single julianTime inputs.  The outputs will have the same size as the
%    ra/dec inputs:
%        ra = 300.0:.01:300.1, dec = 45.0:.01:45.1, jt = 2455000, [module output row col] = RaDec2Pix(ra, dec, jt);
%
%    Single element ra/dec inputs, multiple-element julianTime inputs.  The outputs will have the same size as the
%    time input:
%        ra = 300, dec = 45, jt = 2455000:1:2455100, [module output row col] = RaDec2Pix(ra, dec, jt);
%
%    Multiple element ra/dec inputs, multiple (same size as ra/dec) julianTime inputs.  The outputs will have the same size as the
%    ra/dec/time inputs:
%        ra = 300.0:.01:300.1, dec = 45.0:.01:45.1, jt = 2455000:.01:2455000.1, [module output row col] = RaDec2Pix(ra, dec, jt);
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
    
    
    % Check arguments and throw an error if a bad call has been made.
    %
    isPointing    = nargin == 7 || nargin == 8;
%     isNotPointing = nargin == 3 || nargin == 4;
%     incorrectCall = ~isNotPointing && ~isPointing;
%     if incorrectCall
    if ~isPointing
        error('Matlab:FC:raDec2PixClass:RaDec2Pix', 'RaDec2Pix requires 3, 4, 7, or 8 inputs.');
    end
    
    % Default to do the aberration shift
    %
    if (nargin == 3 || nargin == 7)
        aberrateFlag = 1;
    end
%     if (4 == nargin), aberrateFlag = varargin{4}; end;
%     if (8 == nargin), aberrateFlag = varargin{8}; end;

%     % The (:) syntax converts to row-vectors which is required downstream.
%     %
%     ra         = varargin{1}(:);
%     dec        = varargin{2}(:);
%     julianTime = varargin{3}(:);
    
    if aberrateFlag
        % Do the aberration for the input coordinates:
        %
        [ra dec] = aberrate_ra_dec(raDec2PixObject, ra, dec, julianTime);
    end
    % Check arguments for NaN and length:
    %
    if any(isnan(ra)) | any(isnan(dec)) | any(isnan(julianTime))
        error('MATLAB:FC:raDec2PixClass:RaDec2Pix', 'bad NaNs in arguments to RaDec2Pix!');
    end
    if length(ra) ~= length(dec)
        error('MATLAB:FC:raDec2PixClass:RaDec2Pix', 'bad lengths in arguments to RaDec2Pix!');
    end

    % Make (ra,dec) and julianTime the same size if one is different than
    % the other:
    %    
    if (1 == length(julianTime) && length(ra) > 1)
        julianTime = repmat(julianTime, size(ra));
    end
    if (1 == length(ra) && length(julianTime) > 1)
        ra  = repmat(ra, size(julianTime));
        dec = repmat(dec, size(julianTime));
    end

    
    % Check arguments for valid ranges:
    %
    inputStruct = struct('ramax',         max(ra), ...
                         'ramin',         min(ra), ...
                         'decmax',        max(dec), ...
                         'decmin',        min(dec), ...
                         'julianTimeMax', max(julianTime), ...
                         'julianTimeMin', min(julianTime));
    nfields = 1;
    fieldsAndBoundsStruct(nfields).fieldName = 'ramax';
    fieldsAndBoundsStruct(nfields).binaryCompare = {' >= 0 ', ' <= 360 ' };
    nfields = nfields + 1;
    fieldsAndBoundsStruct(nfields).fieldName = 'ramin';
    fieldsAndBoundsStruct(nfields).binaryCompare = {' >= 0 ', ' <= 360 ' };    
    nfields = nfields + 1;
    fieldsAndBoundsStruct(nfields).fieldName = 'decmax';
    fieldsAndBoundsStruct(nfields).binaryCompare = {' >= -90 ', ' <= 90 ' };    
    nfields = nfields + 1;
    fieldsAndBoundsStruct(nfields).fieldName = 'decmin';
    fieldsAndBoundsStruct(nfields).binaryCompare = {' >= -90 ', ' <= 90 ' };    
    nfields = nfields + 1;
    fieldsAndBoundsStruct(nfields).fieldName = 'julianTimeMax';
    fieldsAndBoundsStruct(nfields).binaryCompare = {' >= 2.45e6 ', ' <= 2.46e6 ' };    % TODO: jd limits s/b read from SPICE kernel file
    nfields = nfields + 1;
    fieldsAndBoundsStruct(nfields).fieldName = 'julianTimeMin';
    fieldsAndBoundsStruct(nfields).binaryCompare = {' >= 2.45e6 ', ' <= 2.46e6 ' };    % TODO: jd limits s/b read from SPICE kernel file
    % 2.45e6 (Oct 1995) and 2.46e6 (Feb 2023) are chosen as conservative julian
    % date bounds to avoid passing ridiculous values to the SPICE library call
    % (for the spacecraft state vector).  Semi-ridiculous values-- julian dates
    % within this range but outside the legal range for the current SPICE
    % kernel-- will produce a MATLAB error and stack trace.
    %
    check_struct(inputStruct, fieldsAndBoundsStruct, 'FC:RaDec2Pix:inputStruct');

    quarter = juliandate2quarter(raDec2PixObject, julianTime - raDec2PixObject.mjdOffset);

    % Check to see if the pointing is constant and occurs during one quarter.
    % If that is true, then calcRaDecFromPix can be called all at once.
    %
    if isPointing
%         raPointing   = varargin{4}(:);
%         decPointing  = varargin{5}(:);
%         rollPointing = varargin{6}(:);
        
        % Verify pointing arguments are consistent lengths:
        if ~(length(raPointing) == length(decPointing) && length(raPointing) == length(rollPointing))
            error('MATLAB:FC:raDec2PixClass:RaDec2Pix', 'bad lengths in pointing arguments to RaDec2Pix!');
        end
        
        % If raPointing, decPointing, and rollPointing came in as 1x1 values, stretch them to the size of 
        % the other input arguments for the unique rows operation later on.
        if length(raPointing) == 1
            raPointing   = repmat(raPointing,  size(ra));
            decPointing  = repmat(decPointing, size(ra));
            rollPointing = repmat(rollPointing, size(ra));
        end

        % Check to see if season, raPointing, decPointing, and rollPointing are constant
        %   if they are, then calcPixFromRaDec can be called all at once.
        %
        pointingIsConstant = length(unique(raPointing )) == 1 && ...
                             length(unique(decPointing)) == 1 && ...
                             length(unique(rollPointing)) == 1 && ...
                             length(unique(quarter    )) == 1;
    else
        error('MATLAB:FC:raDec2PixClass:RaDec2Pix', 'shouldn''t get here');
        pointingIsConstant = (1 == length(unique(quarter)));
        %[raPointing decPointing rollPointing] = get_nominal_pointing(julianTime);
        pointingModel = get(raDec2PixObject, 'pointingModel');
        pointingObject = pointingObject(pointingModel);
        pointing = get_pointing(pointingObject, julianTime - raDec2PixObject.mjdOffset);

        raPointing   = pointing(:,1);
        decPointing  = pointing(:,2);
        rollPointing = pointing(:,3);
    end
    
    if pointingIsConstant
        % RaDec2Pix is being called on only one pointing and quarter

        % Perform the actual geometric transformation:
        %
        if length(unique(julianTime)) == 1
            [module output row column] = calcPixFromRaDec(raDec2PixObject, ra, dec, quarter, julianTime, raPointing, decPointing, rollPointing);
        else
            for it = 1:length(julianTime)
                [module(it) output(it) row(it) column(it)] = ...
                    calcPixFromRaDec(raDec2PixObject, ra(it), dec(it), quarter(it), julianTime(it), raPointing(it), decPointing(it), rollPointing(it));
            end
        end
                                                   
    else
        % RaDec2Pix is being called with multiple seasons/pointings
        %   so the calcPixFromRaDec function must be called multiple times.

        % Preallocate outputs:
        %
        module = zeros(size(ra));
        output = module;
        row    = module;
        column = module;

        % Identify unique sets of raPointing, decPointing, rollPointing needed
        % 
        if ~isPointing
            % The nominal pointing will be used without; the only reason to 
            %   call calcPixFromRaDec multiple times is b/c the time range
            %   argument crossed a quarter.
            %
            uniqueQuarterPointings = quarter;
        else
            
            % If raPointing, decPointing, and rollPointing came in as 1x1 values, stretch them to the size of
            % the other input arguments for the unique rows operation later on.
            if length(raPointing) == 1 && length(decPointing) == 1 && length(rollPointing) == 1
                raPointing   = repmat(raPointing,   size(ra));
                decPointing  = repmat(decPointing,  size(ra));
                rollPointing = repmat(rollPointing, size(ra));
            end

            % Construct a matrix for the unique rows operation
            uniqueQuarterPointings = [quarter(:) raPointing(:) decPointing(:) rollPointing(:)];
        end

        % Extract index vectors for the unique pointings.
        %
        [uniqB uniqI uniqJ] = unique(uniqueQuarterPointings, 'rows');

        % Perform calcPixFromRaDec call with the subsets of unique pointings/quarters
        %
        for isubset = 1:length(uniqI)
            % Generate the index vector for this unique pointing:
            %
            index = find(uniqJ == isubset);
            
            % See the pointingIsConstant if-branch above for a description of each
            %   branch of this if block.
            %
            subsetJulianTime = julianTime(index);
            for iTimeSubset = 1:length(subsetJulianTime)
                subsetIndex = index(iTimeSubset);
                [tmpm tmpo tmpr tmpc] = calcPixFromRaDec(raDec2PixObject, ra(subsetIndex), dec(subsetIndex), ...
                                                         quarter(subsetIndex), julianTime(subsetIndex), ...
                                                         raPointing(subsetIndex), decPointing(subsetIndex), rollPointing(subsetIndex));

                % Recombine into one set of results for return.  Use same index vector for this unique subset.
                %
                module(subsetIndex) = tmpm;
                output(subsetIndex) = tmpo;
                row(subsetIndex)    = tmpr;
                column(subsetIndex) = tmpc;
            end
        end
    end
    
return

function [module output row column] = calcPixFromRaDec(raDec2PixObject, ra, dec, quarter, julianTime, raPointing, decPointing, rollPointing)
%
% function [module output row column] = calcPixFromRaDec(ra, dec, quarter, julianTime)
% function [module output row column] = calcPixFromRaDec(ra, dec, quarter, julianTime, raPointing, decPointing, rollPointing)
% 
% quarter (season) must be 0-3 (0-summer, 1-fall, 2-winter, 3-spring)
%
% This code only works for a constant quarter, raPointing, decPointing, and rollPointing.


    % check for large input array, call transformation routine in subsections if so
    %
    if length(ra) < 1000000
        if 5 ~= nargin && 8 ~= nargin
            error('MATLAB::FC::raDec2PixClass::RaDec2Pix bad args when calling doTransform');
        end
        [module output row column] = doTransform(raDec2PixObject, ra, dec, quarter, julianTime, raPointing, decPointing, rollPointing);
    else
        % set up output vectors
        module = zeros(size(ra));
        output = module;
        row    = module;
        column = module;

        len  = length(ra);
        n_splits = 10;
        for isplit = 1:n_splits
            % Create start and stop indexes for range:
            %
            start = (isplit-1)*floor(len/n_splits)+1;
            if isplit ~= n_splits
                stop = isplit*floor(len/n_splits); % don't go past the end
            else
                stop = len;
            end
            range = start:stop;
            
            [tmpm tmpo tmpr tmpc] = doTransform(raDec2PixObject, ra(range), dec(range), quarter(range), julianTime(range), raPointing(range), decPointing(range), rollPointing(range));  % actual transform routine
            module(range,1) = tmpm;
            output(range,1) = tmpo;
            row(   range,1) = tmpr;
            column(range,1) = tmpc;
        end
    end

return

function [module, output, row, column] = doTransform(raDec2PixObject, ra, dec, quarter, julianTime, raPointing, decPointing, rollPointing)
% Internal function to perform the transformation math on ra/decs that are on the silicon.
%
%

    chnNum = getChannelNumbers();
    
    ra0    = raPointing;    % use input FOV right ascension
    dec0   = decPointing;    % use input FOV dec
    drot1  = rollPointing;  % use input FOV rotation offset

    if 8 ~= nargin
        error('Matlab:FC:raDec2PixClass:RaDec2Pix', 'doTransform: requires 8 inputs');
    end

    % Initialize output arrays
    %
    module = zeros(size(ra));
    output = zeros(size(ra));
    row    = zeros(size(ra));
    column = zeros(size(ra));

    rot3 = ra0;          % 3-rot corresponds to FOV at nominal RA.
    rot2 = -dec0;        % 2-rot corresponds to FOV at nomial Dec. Note minus sign.
    %	since +dec corresponds to -rot 

    % Initialize variables 
    %
    chnN  = zeros(size(ra)); % set up empty channel array
    chipN = zeros(size(ra)); % set up empty chip array

    % Get the direction cosine matrix and chip geometry constants for the
    % input julian times.
    %
    [DCM11  DCM12  DCM13  DCM21  DCM22  DCM23  DCM31  DCM32 DCM33 ...
     DCM11c DCM12c DCM13c DCM21c DCM22c DCM23c DCM31c DCM32c DCM33c ...
     nGmsInRange chipTrans chipOffset] = ...
         get_direction_matrix(raDec2PixObject, julianTime, quarter, drot1, rot2, rot3);

    trar  = deg2rad( ra); % target right ascension (radians) optionally array of values
    tdecr = deg2rad(dec); % target declination (radians) optionally array of values

    cosa = cos(trar) .* cos(tdecr); 
    cosb = sin(trar) .* cos(tdecr);
    cosg = sin(tdecr);


    % Now do coordinate transformation: get direction cosines in FPA coordinates
    % 
    lp = DCM11 .* cosa + DCM12 .* cosb + DCM13 .* cosg;
    mp = DCM21 .* cosa + DCM22 .* cosb + DCM23 .* cosg;
    np = DCM31 .* cosa + DCM32 .* cosb + DCM33 .* cosg;

    % Convert dir cosines to longitude and lat in FPA coor system 
    %
    lat = rad2deg(asin( np));    % transformed  lat +Z' in deg 
    lng = rad2deg(atan2(mp,lp)); % transformed long +Y' in deg 

    % find which channel this falls onto (+5 to center on the 10-output grid,
    % +1 for 1-offset matlab arrays).  The chnI and chnJ vars are the row and
    % column indices into this 10x10 grid.
    %
    chnI=floor(lat/raDec2PixObject.HALF_OFFSET_MODULE_ANGLE_DEGREES) + 5 + 1;
    chnJ=floor(lng/raDec2PixObject.HALF_OFFSET_MODULE_ANGLE_DEGREES) + 5 + 1;

    % Find inputs that are outside the FOV
    %
    outOfFov = find(chnI<1 | chnI>10 | chnJ<1 | chnJ>10 ...  % off FOV
                        | (chnI<=2 & chnJ<=2) ... % exclude module 1
                        | (chnI<=2 & chnJ>=9) ... % exclude module 5
                        | (chnI>=9 & chnJ<=2) ... % exclude module 21 
                        | (chnI>=9 & chnJ>=9));   % exclude module 25

    offFovCode = -1;

    module(outOfFov) = offFovCode;
    output(outOfFov) = offFovCode;
    row(outOfFov)    = offFovCode;
    column(outOfFov) = offFovCode;

    inFov = find(module ~= offFovCode);  %In FOV means it hasn't been set to "out" yet.
    if ~isempty(inFov)
        [tmpm tmpo tmpr tmpc] = process_in_FOV(...
            raDec2PixObject, inFov, ...
            chnI, chnJ, chnNum, ...
            DCM11c, DCM12c, DCM13c, DCM21c, DCM22c, DCM23c, DCM31c, DCM32c, DCM33c, ...
            lp, mp, np, chipOffset, unique(julianTime-raDec2PixObject.mjdOffset));
        module(inFov) = tmpm;
        output(inFov) = tmpo;
        row(   inFov) = tmpr;
        column(inFov) = tmpc;
    end

    % return column vectors
    %
    module = module(:);
    output = output(:);
    row    =    row(:);
    column = column(:);

    % Modulus the 84-channel output number into the 1-4 output number:
    % 
    output = 1 + mod(output-1,4);
%     k = find(output == 0);
%     if ~isempty(k)
%         output(k) = 4;
%     end
return

function [module output row column] = process_in_FOV( ...
    raDec2PixObject, inFov, ...
    chnI, chnJ, chnNum, ...
    DCM11c, DCM12c, DCM13c, DCM21c, DCM22c, DCM23c, DCM31c, DCM32c, DCM33c, ...
    lp, mp, np, chipOffset, mjd)

    % Inernal function to perform the transformation calc into chipspace.
    %
    kindex = sub2ind([raDec2PixObject.OUTPUTS_PER_ROW raDec2PixObject.OUTPUTS_PER_COLUMN], chnI(inFov), chnJ(inFov));
    chnN(inFov) = chnNum(kindex');

    chipN(inFov) = fix((chnN(inFov)+1)/2);  % chip number index,
    
    % set up temporary variables to speed the transform lines DAC 16 Mar 2005
    lpFOV    =    lp(inFov);
    mpFOV    =    mp(inFov);
    npFOV    =    np(inFov);
    chipNFov = chipN(inFov);

    % Can now transform to module coordinates Use direction cosine in FPA coor
    % now do transformation to module chip coor
    %
    if size(DCM11c(chipNFov)) == size(lpFOV)
        lpm = DCM11c(chipNFov)  .* lpFOV + DCM12c(chipNFov)  .* mpFOV + DCM13c(chipNFov)  .* npFOV;
        mpm = DCM21c(chipNFov)  .* lpFOV + DCM22c(chipNFov)  .* mpFOV + DCM23c(chipNFov)  .* npFOV;
        npm = DCM31c(chipNFov)  .* lpFOV + DCM32c(chipNFov)  .* mpFOV + DCM33c(chipNFov)  .* npFOV;
    else
        lpm = DCM11c(chipNFov)' .* lpFOV + DCM12c(chipNFov)' .* mpFOV + DCM13c(chipNFov)' .* npFOV;
        mpm = DCM21c(chipNFov)' .* lpFOV + DCM22c(chipNFov)' .* mpFOV + DCM23c(chipNFov)' .* npFOV;
        npm = DCM31c(chipNFov)' .* lpFOV + DCM32c(chipNFov)' .* mpFOV + DCM33c(chipNFov)' .* npFOV;
    end
    
    % Define chip coor as: rotation about the center of the module(field flattener lens) &
    % 	angular row and column from this center then column 1100 is angle zero
    % 	and decreases up and down with increasing angle towards readout amp on
    % 	each corner and row 1024 starts after a gap of 39 pixels decreasing
    % 	with increasing angle 
    %
    latm =asin(npm);                      % transformed lat +Z' to chip coor in radians 
    lngm =rad2deg(atan2(mpm,lpm)) * 3600.;   % transformed long +Y' to chip coor in arc sec 
    lngr =lngm.*cos(latm);                % correct for cos effect going from spherical to rectangular coor
                                          % one deg of long at one deg of lat is smaller than one deg at zero lat
                                          % by cos(lat) , amounts to 1/2 arc sec=1/8 pix 
    latm =rad2deg(latm)*3600;   % latm in arc sec 
    
    % Now convert to row and column 
    %
    geometryObject = geometryClass(raDec2PixObject.geometryModel);
    mjds = get(geometryObject,'mjds');
   
    % Get the MJD for the most recent geometry model that is BEFORE the
    % MJD argument.  If no geometry models meet that criteria, use the
    % MJD of the earliest available geometry model.
    %
    rightMjd = max(mjds(mjds < mjd));
    if mjd < min(mjds)
        rightMjd = min(mjds);
    end
   
%   obtain the plate scales and generate a vector of plate scales which goes with the
%   vector of latitude / longitude coordinates.  Note that we are using 1 plate scale per
%   CCD here -- the "even-numbered" mod/out's plate scale is used for both even and odd
%   mod/outs.  
    
    plateScalesAll = get_plate_scale(geometryObject, rightMjd);
%    plateScalePerOutput = reshape(plateScalesAll(chipNFov*2), size(lngr));
    plateScaleN = reshape(plateScalesAll(chipNFov*2), size(lngr));

%   obtain the pincushion parameters and reshape them along the same lines as the plate
%   scales
    
    pincushionAll = get_pincushion(geometryObject, rightMjd) ;
    pincushionN = reshape(pincushionAll(chipNFov*2), size(lngr)) ;
    
    chipOffsetWork2 = chipOffset(chipNFov,2);
    if size(chipOffsetWork2,1) == size(lngr,2)
        chipOffsetWork2 = chipOffsetWork2';
    end

    chipOffsetWork3 = chipOffset(chipNFov,3);
    if size(chipOffsetWork3,1) == size(lngr,2)
        chipOffsetWork3 = chipOffsetWork3';
    end

%     pRow = raDec2PixObject.nRowsImaging - lngr ./ plateScalePerOutput + chipOffsetWork2;  % 1-offset MATLAB array
%     row(inFov) = pRow;
%     latp = latm ./ plateScalePerOutput - chipOffsetWork3;  % +/-latitude in pixels on chip, 1-offset MATLAB array 
    
%   convert the longitude and latitude from arcsec to pixels, and take into account the
%   pincushion aberration -- these are equivalent to row and column, but with an origin of
%   coordinates at the notional center of the module

    radius2 = lngr.^2 + latm.^2 ;
    rowCentered = lngr ./ plateScaleN .* ( 1 + pincushionN .* radius2 ) ;
    colCentered = latm ./ plateScaleN .* ( 1 + pincushionN .* radius2 ) ;
    
%   apply fixed offsets to get to the correct origin of coordinates

    pRow = raDec2PixObject.nRowsImaging - rowCentered + chipOffsetWork2 ;
    row(inFov) = pRow ;
    colRecentered = colCentered - chipOffsetWork3 ;
    
    pColn = zeros(size(colRecentered));
    % positive side of chip
    gez = find(colRecentered >= 0.0);
    pColn(gez) = raDec2PixObject.nColsImaging - colRecentered(gez);

    % bottom half of chip
    chnN(inFov(gez)) = fix((chnN(inFov(gez)) - 1) / 2) * 2 + 1;

    % negative side of chip
    lz = find(colRecentered < 0.0);
    pColn(lz) = raDec2PixObject.nColsImaging + colRecentered(lz);

    % top half of chip
    chnN(inFov(lz)) = fix((chnN(inFov(lz))+1)/2) * 2;

    % set column & output values
    column(inFov) = pColn;
    output(inFov) = chnN(inFov); 

    % determine module number
    mtemp = ceil(output(inFov)/4)+1;  

    mtemp(mtemp >=  5) = mtemp(mtemp >=  5) + 1; % add one to account for missing module 5
    mtemp(mtemp >= 21) = mtemp(mtemp >= 21) + 1; % add one again to account for missing module 21
    module(inFov) = mtemp;

    % Return the nonzero calculated data:
    %
    nonZeroIndex = module ~= 0;
    module = module(nonZeroIndex);
    output = output(nonZeroIndex);
    row    = row(   nonZeroIndex);
    column = column(nonZeroIndex);
return
