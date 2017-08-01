function [validFig] = pad_plot_centroid_bias_over_entire_focal_plane(padScienceObject, padOutputStruct, nominalPointingStruct, cadenceIndex, raDec2PixObject)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function [validFig] = pad_plot_centroid_bias_over_entire_focal_plane(padScienceObject, padOutputStruct, nominalPointingStruct, cadenceIndex, raDec2PixObject)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
% This method, modified from plot_centroid_bias_over_entire_focal_plane 
% in pdqScienceClass, generates two plots to demonstrate the attitude 
% solotion at the specified cadence:
% (1) Differences of centroid positions in entire focal plane from nominal 
%     pointing attitude and attitude solution;
% (2) Differences of centroid positions in entire focal plane from attitude
%     solution and motion polynomials.
%
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

% Set default value of validFig to false
validFig = false;

% Return if there is no valid attitude solution at the specified cadence
if ( padOutputStruct.attitudeSolution.gapIndicators(cadenceIndex) )
%     warning('PAD:plotRowColResidual:noValidAttitudeSolution', ...
%         ['Centroid bias for cadence ' num2str(cadenceIndex) ' cannot be plotted since there is no valid attitude solution'] );
    disp(['PAD:plotRowColResidual: Centroid bias for cadence ' num2str(cadenceIndex) ...
          ' cannot be plotted since there is no valid attitude solution']);
    return
end

% Get cadence times and number of module/outputs
cadenceTime  = padScienceObject.cadenceTimes.midTimestamps(cadenceIndex);
nChannels    = padScienceObject.fcConstants.MODULE_OUTPUTS;
aberrateFlag = 1;

% Retrieve nominal pointing attitude from padOutStruct
raNominalPointing    = nominalPointingStruct.ra(cadenceIndex);
decNominalPointing   = nominalPointingStruct.dec(cadenceIndex);
rollNominalPointing  = nominalPointingStruct.roll(cadenceIndex);

% Retrieve attitude solution from padOutStruct
raAttitudeSolution   = padOutputStruct.attitudeSolution.ra(cadenceIndex);
decAttitudeSolution  = padOutputStruct.attitudeSolution.dec(cadenceIndex);
rollAttitudeSolution = padOutputStruct.attitudeSolution.roll(cadenceIndex);

% Retrieve grid parameters from padScienceObject
gridRowStart     = padScienceObject.padModuleParameters.gridRowStart;
%gridRowStep      = padScienceObject.padModuleParameters.gridRowStep;
gridRowEnd       = padScienceObject.padModuleParameters.gridRowEnd;
gridRowMid       = round( 0.5*(gridRowStart + gridRowEnd) );

gridColStart     = padScienceObject.padModuleParameters.gridColStart;
%gridColStep      = padScienceObject.padModuleParameters.gridColStep;
gridColEnd       = padScienceObject.padModuleParameters.gridColEnd;
gridColMid       = round( 0.5*(gridColStart + gridColEnd) );

% Define (rowRef, colRef) pairs of fake target stars on a 3x3 grid within each module/output
gridRowVector    = [gridRowStart gridRowMid gridRowEnd];
gridColVector    = [gridColStart gridColMid gridColEnd];
[rowRef, colRef] = ndgrid(gridRowVector, gridColVector);
rowRef           = rowRef(:);
colRef           = colRef(:);
ovec             = ones(size(rowRef));

% Allocate memory for raStars. decStars, modMotionPoly, outMotionPoly,
% rowMotionPoly, colMotionPoly
nStarModOut  = length(rowRef);
nStars       = nStarModOut*nChannels;

raStars       = -1*ones(nStars, 1);
decStars      = -1*ones(nStars, 1);
modMotionPoly = -1*ones(nStars, 1);
outMotionPoly = -1*ones(nStars, 1);
rowMotionPoly = -1*ones(nStars, 1);
colMotionPoly = -1*ones(nStars, 1);

% Loop over each module/output and determine (ra, dec) pairs of each fake target star
for iChannel = 1 : nChannels

    % Get the pair (modRef, outRef) from the channel number
    [modRef, outRef] = convert_to_module_output(iChannel);

    % The pair (raRef, decRef) of each fake target star is determined with method pix_2_ra_dec_absolute() from nominal pointing attitude
    [raRef, decRef] = pix_2_ra_dec_absolute( raDec2PixObject, modRef*ovec, outRef*ovec, rowRef, colRef, cadenceTime, ...
        raNominalPointing, decNominalPointing, rollNominalPointing, aberrateFlag);

    % Copy raRef, decRef into raStars, decStars respectively
    index = (iChannel-1)*nStarModOut + (1:nStarModOut);
    raStars(index, 1)  = raRef(:);
    decStars(index, 1) = decRef(:);
    
    if ( padScienceObject.motionPolyStruct(iChannel, cadenceIndex).rowPolyStatus && ...
            padScienceObject.motionPolyStruct(iChannel, cadenceIndex).colPolyStatus )
        
        % Rows/columns of centroids and corresponding uncertainties are determined by evaluating motion polynomials
        % when the statuses of rowPoly and colPoly are good.
        [ rowRef, rowUncertaintyIgnored ] = weighted_polyval2d(raRef, decRef, padScienceObject.motionPolyStruct(iChannel, cadenceIndex).rowPoly);
        [ colRef, colUncertaintyIgnored ] = weighted_polyval2d(raRef, decRef, padScienceObject.motionPolyStruct(iChannel, cadenceIndex).colPoly);

        % Copy modRef, outRef, rowRef, colRef into modMotionPoly,
        % outMotionPoly, rowMotionPoly, colMotionPoly respectively
        modMotionPoly(index, 1) = modRef*ovec;
        outMotionPoly(index, 1) = outRef*ovec;
        rowMotionPoly(index, 1) = rowRef;
        colMotionPoly(index, 1) = colRef;
        
    end
    
end

% Calculate (mod, out, row, col) of centroids with ra_dec_2_pix_absolute() from the nominal pointing attitude
[modNominalPointing, outNominalPointing, rowNominalPointing, colNominalPointing] = ra_dec_2_pix_absolute( raDec2PixObject, raStars, decStars, cadenceTime, ...
    raNominalPointing, decNominalPointing, rollNominalPointing, aberrateFlag);

% Calculate (mod, out, row, col) of centroids with ra_dec_2_pix_absolute() from the attitude solution
[modAttitudeSolution1, outAttitudeSolution1, rowAttitudeSolution1, colAttitudeSolution1] = ra_dec_2_pix_absolute( raDec2PixObject, raStars, decStars, cadenceTime, ...
    raAttitudeSolution, decAttitudeSolution, rollAttitudeSolution, aberrateFlag);

% Convert (mod, out, row, col) to focal plane coordinates
[zNominalPointing,   yNominalPointing  ]  = morc_to_focal_plane_coords(modNominalPointing,   outNominalPointing,   rowNominalPointing,   colNominalPointing,   'one-based');
[zAttitudeSolution1, yAttitudeSolution1]  = morc_to_focal_plane_coords(modAttitudeSolution1, outAttitudeSolution1, rowAttitudeSolution1, colAttitudeSolution1, 'one-based');

% Plot differences of centroid positions in entire focal plane from nominal pointing attitude and attitude solution
%figure(10000+cadenceIndex)
figure(1)
pad_draw_ccd(1:42);
quiver(zNominalPointing, yNominalPointing, (zAttitudeSolution1-zNominalPointing)*1000, (yAttitudeSolution1-yNominalPointing)*1000, 0);
hold off;
title(sprintf('Differences of Centroid Positions from\n Nominal Attitude and Attitude Solution\n (cadence index: %s, unit: pixel*1000)', num2str(cadenceIndex)));
xlabel('Axis +Z (FPA coordinates)');
ylabel('Axis +Y (FPA coordinates)');
format_graphics_for_report(1, 1.0, 0.75)


% Remove the fake target stars on the module/outputs with invalid motion polynomials
index = find(rowMotionPoly==-1 | colMotionPoly==-1);
raStars(index)  = [];
decStars(index) = [];
modMotionPoly(index) = [];
outMotionPoly(index) = [];
rowMotionPoly(index) = [];
colMotionPoly(index) = [];

% Return if no valid fake target stars are left
if ( isempty(raStars) || isempty(decStars) )
%     warning('PAD:plotRowColResidual:noValidMotionPolys', ...
%         ['can''t plot row column residuals for cadence ' num2str(cadenceIndex) ' since there are no valid motion polynomials'] );
    disp(['PAD:plotRowColResidual: can''t plot row column residuals for cadence ' num2str(cadenceIndex) ...
          ' since there are no valid motion polynomials']);
    return
end
    
% Calculate (mod, out, row, col) of centroids of remained fake target stars with ra_dec_2_pix_absolute() from the attitude solution
[modAttitudeSolution2, outAttitudeSolution2, rowAttitudeSolution2, colAttitudeSolution2] = ra_dec_2_pix_absolute( raDec2PixObject, raStars, decStars, cadenceTime, ...
    raAttitudeSolution, decAttitudeSolution, rollAttitudeSolution, aberrateFlag);

% Convert (mod, out, row, col) to focal plane coordinates
[zMotionPoly,        yMotionPoly       ]  = morc_to_focal_plane_coords(modMotionPoly, outMotionPoly, rowMotionPoly, colMotionPoly, 'one-based');
[zAttitudeSolution2, yAttitudeSolution2]  = morc_to_focal_plane_coords(modAttitudeSolution2, outAttitudeSolution2, rowAttitudeSolution2, colAttitudeSolution2, 'one-based');

% Plot differences of centroid positions in entire focal plane from attitude solution and motion polynomials
%figure(20000+cadenceIndex)
figure(2)
pad_draw_ccd(1:42);
quiver(zAttitudeSolution2, yAttitudeSolution2, (zMotionPoly-zAttitudeSolution2)*1000, (yMotionPoly-yAttitudeSolution2)*1000, 0);
hold off;
title(sprintf('Differences of Centroid Positions from\n Attitude Solution and Motion Polynomials\n (cadence index: %s, unit: pixel*1000)', num2str(cadenceIndex)))
xlabel('Axis +Z (FPA coordinates)');
ylabel('Axis +Y (FPA coordinates)');
format_graphics_for_report(2, 1.0, 0.75)

% Both figures are valid. Set validFig to true
validFig = true;

return

