function [ra, dec]  =  Pix2RaDec(varargin)
%
% function [ra, dec]  =  Pix2RaDec(raDec2PixObject, module, output, row, column, julianTime, [aberrateFlag])
% or
% function [ra, dec]  =  Pix2RaDec(raDec2PixObject, module, output, row, column, julianTime, raPointing, decPointing, rollPointing, [aberrateFlag])
%
%
% Inputs:
%    module - the CCD module location of the star(s).  If there is more than one
%                 star, this argument should be a vector.  The module, output, row, and column arguments
%                 must be the same size.
%    output - the CCD output of the star(s).  If there is more than one
%                 star, this argument should be a vector. The module, output, row, and column arguments
%                 must be the same size.
%    row   - the CCD row of the star(s).  If there is more than one
%                 star, this argument should be a vector. The module, output, row, and column arguments
%                 must be the same size.
%    column - the CCD output of the star(s).  If there is more than one
%                 star, this argument should be a vector. The module, output, row, and column arguments
%                 must be the same size.
%    julianTime - the julian times to do the the (RA,Dec)->Pix conversion
%                 for.  The size of this argument must be:
%                     1) the same as ra and dec,
%                     2) a single value, or
%                     3) an arbitrary length vector, iff ra and dec are
%                        single values
%    raPointing    - Optional argument specifying focal plane center in RA, in
%            degrees.  raPointing, decPointing, and rollPointing must all be specified, or none.
%    decPointing    - Optional argument specifying focal plane center in declination, in degrees.
%    rollPointing  - Optional argument specifying focal plane rotation, in degrees.
%    aberrateFlag - Optional argument to turn aberration on or off. The default is on.
%            If raPointing, decPointing, and rollPointing are not specified, this can be used as the
%            fourth argument.
%    
%
%
% raPointing, decPointing, and rollPointing may be specified as 1x1 values even if other inputs are not.
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

    % Check arguments and error out if the wrong number have been given
    %
    noPointingCase   = nargin == 6 || nargin == 7;
    isPointing       = nargin == 9 || nargin == 10;
    incorrectCall = ~noPointingCase && ~isPointing;
    if incorrectCall
        error('MATLAB:FC:raDec2Pix:Pix2RaDec', 'Pix2RADec requires 6, 7, 9, or 10 inputs.');
    end
    % Default to generating the DVA shifts
    if (nargin == 6 || nargin == 7)
        aberrateFlag = 1;
    end
    if (7  == nargin), aberrateFlag = varargin{7}; end;
    if (10 == nargin), aberrateFlag = varargin{10}; end;

    % The (:) syntax converts to row-vectors (each row is a different 
    %   timestamp), which is required downstream.
    %
    raDec2PixObject = varargin{1};
    module     = varargin{2}(:);
    output     = varargin{3}(:);
    row        = varargin{4}(:);
    column     = varargin{5}(:);
    julianTime = varargin{6}(:);
    
    % Check arguments for NaN and length:
    %
    if ( any(isnan(module) | isnan(output) | isnan(row) | isnan(column)) || ...
            any(isnan(julianTime)) || ...
            length(module) ~= length(output) || ...
            length(module) ~= length(row    ) || ...
            length(module) ~= length(column))
        error( 'MATLAB:FC:raDec2Pix:Pix2RaDec', 'bad NaNs or lengths in arguments to Pix2RaDec!' );
    end

    % Make (mod, out, row, col) and julianTime the same size if one is different than
    % the other:
    %
    %    
    if ( 1 == length(julianTime) && length(module) > 1 )
        julianTime = repmat(julianTime, size(module));
    end
    if ( 1 == length(module) && length(julianTime) > 1 )
        module = repmat(module, size(julianTime));
        output = repmat(output, size(julianTime));
        row    = repmat(   row, size(julianTime));
        column = repmat(column, size(julianTime));
    end
    % Check args for type:
    %
    if (~isnumeric(    module) || ~isnumeric(output) || ...
        ~isnumeric(       row) || ~isnumeric(column) || ...
        ~isnumeric(julianTime) || ~isnumeric(aberrateFlag))
        error('MATLAB:FC:raDec2Pix:Pix2RaDec', 'bad format of arguments to Pix2RaDec!');
    end

    quarter = juliandate2quarter(raDec2PixObject, julianTime - raDec2PixObject.mjdOffset);

    % Check to see if the pointing is constant and in one quarter.
    % If that is true, then calcRaDecFromPix can be called all at once.
    %
    if noPointingCase
        pointingIsConstant = (1 == length(unique(quarter)));
        pointingModel = get(raDec2PixObject, 'pointingModel');
        pointingObject = pointingObject(pointingModel);
        pointing = get_pointing(pointingObject, julianTime - raDec2PixObject.mjdOffset);

        raPointing   = pointing(:,1);
        decPointing  = pointing(:,2);
        rollPointing = pointing(:,3);
    elseif isPointing
        raPointing   = varargin{7}(:);
        decPointing  = varargin{8}(:);
        rollPointing = varargin{9}(:);

        % If raPointing, decPointing, and rollPointing came in as 1x1 values, stretch them to the size of 
        % the other input arguments for the unique rows operation later on.
        if length(raPointing)==1 && length(decPointing)==1 && length(rollPointing)==1
            raPointing   = repmat(raPointing,   size(module));
            decPointing  = repmat(decPointing,  size(module));
            rollPointing = repmat(rollPointing, size(module));
        end

        % Check to see if season, raPointing, decPointing, and rollPointing are constant
        %   if they are, then calcPixFromRaDec can be called all at once.
        %
        pointingIsConstant = length(unique(raPointing))==1 & ...
                             length(unique(decPointing))==1 & ...
                             length(unique(rollPointing))==1 & ...
                             length(unique(quarter))==1;
    end

    if pointingIsConstant
        % Pix2RADec is being called on only one pointing and quarter

        [ra dec] = calcRaDecFromPix(raDec2PixObject, module, output, row, column, quarter, julianTime, raPointing, decPointing, rollPointing);
    else
        % Pix2RADec is being called with multiple module/output/seasons/raPointing,decPointing,rollPointing.
        % Therefore, you need to call calcRaDecFromPix multiple times...

        % Allocate room for output
        ra = zeros(size(varargin{2}(:)));
        dec = ra;

        % Identify unique calls needed
        %
        if noPointingCase
            % If there is no pointing changes, only the quarter
            uniqueQuarterPointings = quarter;
        elseif isPointing

            % If raPointing, decPointing, and rollPointing came in as 1x1 values, stretch them to the size of
            % the other input arguments for the unique rows operation later on.
            if length(raPointing)==1 && length(decPointing)==1 && length(rollPointing)==1
                raPointing   = raPointing   * ones(size(module));
                decPointing  = decPointing  * ones(size(module));
                rollPointing = rollPointing * ones(size(module));
            end

            % Construct a matrix for the unique rows operation
            uniqueQuarterPointings = [varargin{6}(:) varargin{7}(:) varargin{8}(:) varargin{9}(:)];
        end

        [uniqB, uniqI, uniqJ] = unique(uniqueQuarterPointings,'rows'); 

        % Call with subsets
        for k = 1:length(uniqI)

            index = find(uniqJ==k);  % find the indices for the kth unique entry

            [tmp_ra tmp_dec] = calcRaDecFromPix(raDec2PixObject, module(index), output(index), row(index), column(index), quarter(index), julianTime(index), raPointing(index), decPointing(index), rollPointing(index));

            % Recombine into one result
            ra(index)  = tmp_ra;
            dec(index) = tmp_dec;
        end
    end

    if aberrateFlag
        [ra dec] = unaberrate_ra_dec(raDec2PixObject, ra, dec, julianTime);
    end

return

function [ra, dec] = calcRaDecFromPix(varargin)
% function [ra, dec]  =  calcRaDecFromPix(raDec2PixObject, module, output, row, column, quarter, julianTime)
% function [ra, dec]  =  calcRaDecFromPix(raDec2PixObject, module, output, row, column, quarter, julianTime, raPointing, decPointing, rollPointing)
% 
% quarter (season) must be 0-3 (0-summer, 1-fall, 2-winter, 3-spring)
%
% This code only works for a constant quarter, raPointing, decPointing, and rollPointing.
    raDec2PixObject = varargin{1};
    module        = varargin{2};
    output        = varargin{3};
    row           = varargin{4};
    column        = varargin{5};
    quarter       = varargin{6};
    julianTime    = varargin{7};
    if (10 == nargin)
        raPointing   = varargin{8};
        decPointing  = varargin{9};
        rollPointing = varargin{10};
    end
    
    % check for large input array, call transformation routine in subsections if so
    %
    if length(module) < 1000000
        if 7 ~= nargin && 10 ~= nargin
            error('MATLAB::FC::raDec2Pix:Pix2RaDec bad args when calling doTransform');
        end
        [ra dec] = doTransform(varargin{:});
    else
        % set up output vectors
        ra  = zeros(size(module)); 
        dec = ra;

        len  = length(module);
        for i = 1:10
            range = (((i-1)*floor(len/10)+1):(i*floor(len/10)))';
            if i==10
                range = ((i-1)*floor(len/10)+1):len;
            end
            
            doTransformArgs{1} = raDec2PixObject;
            doTransformArgs{2} = module(range);
            doTransformArgs{3} = output(range);
            doTransformArgs{4} = row(range);
            doTransformArgs{5} = column(range);
            doTransformArgs{6} = quarter(range);
            doTransformArgs{7} = julianTime(range);
            if (10 == nargin)
                doTransformArgs{8} = raPointing(range);
                doTransformArgs{9} = decPointing(range);
                doTransformArgs{10} = rollPointing(range);
            end


            [ra_tmp, dec_tmp] = doTransform(doTransformArgs); % actual transform routine
            ra( range,1) = ra_tmp;
            dec(range,1) = dec_tmp;
        end
    end

return

function [ra, dec] = doTransform(raDec2PixObject, module, output, row, column, quarter, julianTime, raPointing, decPointing, rollPointing)

    dtr = pi/180;
    rtd = 180/pi;

    %[ra0 dec0 drot1] = get_nominal_fov_center();
    chn_num = getChannelNumbers();

    new_mod = [-1 0:2 -1 3:17 -1 18:20 -1]';
    output  = output + 4*new_mod(module);

    if 7 == nargin
        1; %do nothing
        error('bad branch');
    elseif 9 == nargin
        % pointing is specified
        ra0    = raPointing;
        dec0   = decPointing;
        error('bad branch');
    elseif 10 == nargin
        % pointing is specified
        ra0    = raPointing;
        dec0   = decPointing;
        drot1 = rollPointing;
    else
        error('doTransform: requires 6, 8, or 9 inputs');
    end

    rot_3 = ra0;          % 3-rot corresponds to FOV at nominal RA.
    rot_2 = -dec0;        % 2-rot corresponds to FOV at nominal Dec. Note minus sign
                          %	since +dec corresponds to -rot 

    [ DCM11  DCM12  DCM13  DCM21  DCM22  DCM23  DCM31  DCM32 DCM33 ...
        DCM11c DCM12c DCM13c DCM21c DCM22c DCM23c DCM31c DCM32c DCM33c ...
        nGmsInRange chip_trans chip_offset ] = ...
            get_direction_matrix(raDec2PixObject, julianTime, quarter, drot1, rot_2, rot_3);

    % do conversion from pixels to RA and Dec
    quad = mod(output,4); % need to find quadrant in module 
    % now convert from row and column to chip lng and lat 
    chip_n = floor( (output+1)/2 +0.1);  % chip number index  NO -1 FOR MATLAB

    geometry_object = geometryClass(raDec2PixObject.geometryModel);
    mjds = get(geometry_object,'mjds');
    
    mjd = unique(julianTime - raDec2PixObject.mjdOffset);
    % Get the MJD for the most recent geometry model that is BEFORE the
    % MJD argument.  If no geometry models meet that criteria, use the
    % MJD of the earliest available geometry model.
    %
    rightMjd = max(mjds(mjds < mjd));
    if mjd < min(mjds)
        rightMjd = min(mjds);
    end

    plate_scale = get_plate_scale(geometry_object, rightMjd);
    %     plate_scale = plate_scale(end);
    plateScaleCcd = plate_scale(1:2:length(plate_scale));
    plateScaleN = plateScaleCcd(chip_n);
    plateScaleN = reshape(plateScaleN, size(chip_n));
    
%   build a vector of pincushion corrections using the same approach as the vector of
%   plate scales

    pincushionAll = get_pincushion(geometry_object, rightMjd) ;
    pincushionAlternateOutputs = pincushionAll(1:2:length(pincushionAll)) ;
    pincushionN = pincushionAlternateOutputs(chip_n) ;
    pincushionN = reshape(pincushionN, size(chip_n)) ;


% %     lngr = plate_scale(end)*(raDec2PixObject.nRowsImaging + chip_offset(chip_n,2) - row);
%     lngr = plateScaleN .* (raDec2PixObject.nRowsImaging + chip_offset(chip_n,2) - row);
%     latp =  raDec2PixObject.nColsImaging - column;

%   convert the row and column coordinates to coordinates centered on the notional center
%   of the module, with unit vectors pointing towards the readout row/column of the
%   odd-numbered output

   rowCentered = raDec2PixObject.nRowsImaging + chip_offset(chip_n,2) - row ;
   colCentered = raDec2PixObject.nColsImaging - column ;
    
    evenQuadIndex = (quad==0|quad==2);
%    latp(evenQuadIndex) = -1 * latp(evenQuadIndex);
    colCentered(evenQuadIndex) = -1 * colCentered(evenQuadIndex) ;
    colCentered = colCentered + chip_offset(chip_n,3) ;
    
%   iteratively solve for the longitude and latitude coordinates in arcseconds, with
%   origin at the notional center of the module; set the convergence tolerance to be
%   somewhat larger than the eps for the class of the row variable

    convergenceTolerance = 8 * eps(class(rowCentered)) ;

    [lngr, latm] = compute_lat_long_iteratively( rowCentered, colCentered, ...
        plateScaleN, pincushionN, convergenceTolerance ) ;

%     latm = (latp + chip_offset(chip_n,3))*plate_scale; % in arc sec 
%    latm = (latp + chip_offset(chip_n,3)) .* plateScaleN;
    latm = latm/3600./rtd;  % latm in radians 
    lngm = lngr./cos(latm); 
    % correct for cos effect going from spherical to rectangular coor
    % one deg of long at one deg of lat is smaller than one deg at zero lat
    % by cos(lat) , amounts to 1/2 arc sec = 1/8 pix 
    lngm = lngm/3600./rtd; % lngm in radians 

    lpm = cos(lngm).*cos(latm);
    mpm = sin(lngm).*cos(latm);
    npm = sin(latm);

    %* transform from chip coor to FPA coor Do inverse of above transform (swap matrix row/coln indices) 
    lp = DCM11c(chip_n).*lpm + DCM21c(chip_n).*mpm + DCM31c(chip_n).*npm;
    mp = DCM12c(chip_n).*lpm + DCM22c(chip_n).*mpm + DCM32c(chip_n).*npm;
    np = DCM13c(chip_n).*lpm + DCM23c(chip_n).*mpm + DCM33c(chip_n).*npm;

    %* Transform from FPA to RA and Dec Again use inverse of transform matrix 
    cosa = DCM11.*lp + DCM21.*mp + DCM31.*np;
    cosb = DCM12.*lp + DCM22.*mp + DCM32.*np;
    cosg = DCM13.*lp + DCM23.*mp + DCM33.*np;

    % Convert direction cosines to equatorial coordinate system
    ra  = atan2(cosb,cosa)*rtd; % transformed RA in deg 
    dec = asin(cosg)*rtd; % transformed Dec in deg
    if ra < 0
        ra = ra + 360;
    end

    % Return column vectors
    ra  =  ra(:);
    dec = dec(:);
return

%=========================================================================================

% subfunction which iteratively computes the latitude and longitude from the row and
% column, given the plate scale and pincushion parameters

function [lngr, latm] = compute_lat_long_iteratively( rowCentered, colCentered, ...
        plateScaleN, pincushionN, convergenceTolerance )

% define a vector which shows the convergence status of each member of the data vectors,
% and initialize to false

  convergenceStatus = false(size(rowCentered)) ;
  
% initialize lngr and latm to the values they would have for no pincushion correction

  lngr = rowCentered .* plateScaleN ;
  latm = colCentered .* plateScaleN ;
  radius2 = zeros(size(lngr)) ;
  lngrNew = zeros(size(lngr)) ;
  latmNew = zeros(size(lngr)) ;
  
% iterate as long as there are members which are not yet converged

  iconverge = 0;
  converganceAttemptsLimit = 100;
  while ( ~all(convergenceStatus) && iconverge < converganceAttemptsLimit )
      iconverge = iconverge + 1;
      
%     use the old values of lngr and latm to compute new ones, in the case where
%     convergence hasn't happened yet

      needToIterate = find(~convergenceStatus) ;
      radius2(needToIterate) = lngr(needToIterate).^2 + latm(needToIterate).^2 ;
      lngrNew(needToIterate) = rowCentered(needToIterate) .* plateScaleN(needToIterate) ./ ...
          ( 1 + pincushionN(needToIterate) .* radius2(needToIterate) ) ;
      latmNew(needToIterate) = colCentered(needToIterate) .* plateScaleN(needToIterate) ./ ...
          ( 1 + pincushionN(needToIterate) .* radius2(needToIterate) ) ;
      deltaLngr = abs(lngrNew - lngr) ;
      deltaLatm = abs(latmNew - latm) ;
      
%     Convergence occurs when either the absolute change is < the convergenceTolerance or
%     else the relative change is < the convergence tolerance.  We expect the former
%     condition to hold when the value of lngr / latm is close to zero, otherwise the
%     latter.  Since I don't like hugely complicated logical expressions, I'll do this one
%     in pieces

      absoluteConvergenceLngr = deltaLngr < convergenceTolerance ;
      absoluteConvergenceLatm = deltaLatm < convergenceTolerance ;
      relativeConvergenceLngr = deltaLngr(:)' < ...
          convergenceTolerance * abs(max([lngrNew(:)' ; lngr(:)'])) ;
      relativeConvergenceLatm = deltaLatm(:)' < ...
          convergenceTolerance * abs(max([latmNew(:)' ; latm(:)'])) ;
      
%     build an overall convergence vector from the 4 component vectors

      convergenceLngr = absoluteConvergenceLngr | relativeConvergenceLngr(:) ;
      convergenceLatm = absoluteConvergenceLatm | relativeConvergenceLatm(:) ;
      convergenceStatus = convergenceLngr & convergenceLatm ;
      
%     replace the old estimated result vectors with the new ones

      lngr = lngrNew ;
      latm = latmNew ;
      
  end % while-loop on convergence status

  if ~(iconverge < converganceAttemptsLimit)
      warning('MATLAB:FC:raDec2Pix:Pix2RaDec', 'compute_lat_long_iteratively did not converge.');
  end
  
return

% and that's it!

%
%
%
