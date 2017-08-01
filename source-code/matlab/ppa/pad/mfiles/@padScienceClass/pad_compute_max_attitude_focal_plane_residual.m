function [padOutputStruct] = pad_compute_max_attitude_focal_plane_residual(padScienceObject, padOutputStruct, nominalPointingStruct, raDec2PixObject)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function [padOutputStruct] = pad_compute_max_attitude_focal_plane_residual(padScienceObject, padOutputStruct, nominalPointingStruct, raDec2PixObject)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% This method computes the maximum offset between measured "star" (extreme
% corners of FOV on the visible CCD) positions and the mapped star
% positions given the attitude solution. It is a measure of goodness of the
% computed attitude solution.
%
% Step 1
% Define extreme corners (artificial stars) of the active field of view (5
% pixels in from the edges) There are 20 masked smear cornerStarRows & 12
% leading black cornerStarColumns row = 26 column = 18
%
% Step 2
% Using pix2RaDec and nominal attitude, map these "corners" to {ra, dec}
%
% Step 3
% Using raDec2Pix and actual attitude, map those artificial stars'
% ("corners") {ra, dec} to {row, col}
%
% Step 4
% Compute distance each "star" moved in row, col space and get the
% maximum distance over the entire focal plane
%
% Step 5
% concatenate current time series with historical time series
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
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

% Define extreme corners of the field of view (5 pixels in from the
% edges)
%
% mod = 2  out = 4 modOut = 4   row = 13 col = 21
% mod = 4  out = 3 modout = 11
% mod = 6  out = 3 modOut = 15
% mod = 10 out = 4 modOut = 32
% mod = 16 out = 4 modOut = 56
% mod = 20 out = 3 modOut = 71
% mod = 22 out = 3 modOut = 75
% mod = 24 out = 4 modout = 84


%--------------------------------------------------------------------------
% Step 1
% Define extreme corners (artificial stars) of the active field of view (5
% pixels in from the edges) There are 20 masked smear cornerStarRows & 12 leading
% black cornerStarColumns row = 26 column = 18
%--------------------------------------------------------------------------

modules             = [ 2  4  6 10 16 20 22 24]';
outputs             = [ 4  3  3  4  4  3  3  4]';
cornerStarRows      = [26 26 26 26 26 26 26 26]';
cornerStarColumns   = [18 18 18 18 18 18 18 18]';

cadenceTimes        = padScienceObject.cadenceTimes.midTimestamps; % in MJD
nCadences           = length(cadenceTimes);

maxAttitudeErrorPixels = 100.0;

for jCadence = 1 : nCadences

    % Skip if there is a gap in attitudeSolution
    if ( padOutputStruct.attitudeSolution.gapIndicators(jCadence) )
        
%         warning('PAD:computeMaxAttitudeError:noValidAttitudeSolution', ...
%             ['maxAttitudeFocalPlaneResidual for cadence ' num2str(jCadence) ' cannot be computed since there is no valid attitude solution'] );
        disp(['PAD:computeMaxAttitudeError: maxAttitudeFocalPlaneResidual for cadence ' num2str(jCadence) ...
              ' cannot be computed since there is no valid attitude solution'] );
        continue;
        
    elseif ( padOutputStruct.attitudeSolution.attitudeErrorPixels(jCadence) > maxAttitudeErrorPixels )
        
        disp(['PAD:computeMaxAttitudeError: Calculation of maxAttitudeFocalPlaneResidual for cadence ' num2str(jCadence) ...
              ' is skipped since the attitude error is ' num2str( padOutputStruct.attitudeSolution.attitudeErrorPixels(jCadence) ) ...
              ' pixels, which is beyond the upper limit of ' num2str(maxAttitudeErrorPixels) ' pixels'] );
        continue;
        
    end

    %--------------------------------------------------------------------------
    % Step 2
    % Using pix2RaDec and nominal attitude, map these "corners" to {ra, dec}
    %--------------------------------------------------------------------------
    aberrateFlag = 1; % not a boolean

    raNominalPointing    = nominalPointingStruct.ra(jCadence);
    decNominalPointing   = nominalPointingStruct.dec(jCadence);
    rollNominalPointing  = nominalPointingStruct.roll(jCadence);

    [raAber, decAber] = pix_2_ra_dec_absolute(raDec2PixObject, modules, outputs, cornerStarRows, cornerStarColumns, cadenceTimes(jCadence), ...
        raNominalPointing, decNominalPointing, rollNominalPointing, aberrateFlag);

    %--------------------------------------------------------------------------
    % Step 3
    % Using raDec2Pix and actual attitude, map those artificial stars'
    % ("corners") {ra, dec} to {row, col}
    %--------------------------------------------------------------------------

    raActualPointing      = padOutputStruct.attitudeSolution.ra(jCadence);
    decActualPointing     = padOutputStruct.attitudeSolution.dec(jCadence);
    rollActualPointing    = padOutputStruct.attitudeSolution.roll(jCadence);

    [modulesMapped outputsMapped rowsMapped columnsMapped] = ra_dec_2_pix_absolute(raDec2PixObject, raAber, decAber, cadenceTimes(jCadence), ...
        raActualPointing, decActualPointing, rollActualPointing, aberrateFlag);

    % detect errors in mapping

    if( ~isequal(modules,modulesMapped) || ~isequal(outputs,outputsMapped) )
        
%         error('PAD:computeMaxAttitudeError:raDec2PixMappingFailed', ...
%             'raDec2Pix mapping the corners of FOV on to differenet modules/outputs');
        display(['Warning! PAD:computeMaxAttitudeError:raDec2PixMappingFailed: raDec2Pix maps the corners of FOV on to differenet modules/outputs for cadence ' num2str(jCadence)]);
        continue;
        
    end

    distancesMoved = sqrt( (cornerStarRows - rowsMapped).^2 + (cornerStarColumns - columnsMapped).^2 );

    %--------------------------------------------------------------------------
    % Step 4
    % Compute distance each "star" moved in row, col space and get the
    % maximum distance over the entire focal plane
    % Save results in padOutputStruct
    %--------------------------------------------------------------------------

    padOutputStruct.attitudeSolution.maxAttitudeFocalPlaneResidual(jCadence) = max(distancesMoved);

end

return
