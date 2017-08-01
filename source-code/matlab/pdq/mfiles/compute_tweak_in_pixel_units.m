function pdqOutputStruct = compute_tweak_in_pixel_units(pdqOutputStruct, raDec2PixObject)
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


geometryObject = geometryClass(get(raDec2PixObject,'geometryModel'));
computedPointing = pdqOutputStruct.attitudeSolution;

nominalPointing = cat(1, pdqOutputStruct.attitudeSolutionUncertaintyStruct.nominalPointing);

tweakInArcsec = (nominalPointing-computedPointing).*3600;

offsetInPixelUnitsAtEdgeOfFocalPlane = zeros(size(tweakInArcsec));

cadenceTimes        = cat(1, pdqOutputStruct.attitudeSolutionUncertaintyStruct.cadenceTime);
nCadences           = length(cadenceTimes);

modules       = [ 13 4 ];
outputs       = [ 1  3 ];
starRows      = [1044 21 ];
starColumns   = [1112  13];

%--------------------------------------------------------------------------
% Step 1
% using pix2RaDec and nominal attitude, map these "corners" to {ra, dec}
%--------------------------------------------------------------------------
aberrateFlag = 1; % not a boolean
raNominalPointing      = nominalPointing(:,1);
decNominalPointing     = nominalPointing(:,2);
rollNominalPointing    = nominalPointing(:,3);

[raCorner, decCorner] = pix_2_ra_dec_absolute(raDec2PixObject, modules(2), outputs(2), starRows(2),...
    starColumns(2), cadenceTimes, raNominalPointing, decNominalPointing, rollNominalPointing, aberrateFlag);


[raCenter, decCenter] = pix_2_ra_dec_absolute(raDec2PixObject, modules(1), outputs(1), starRows(1),...
    starColumns(1), cadenceTimes, raNominalPointing, decNominalPointing, rollNominalPointing, aberrateFlag);

%--------------------------------------------------------------------------
% Step 2
% convert the ra, dec of corner and center to cartesian coordinates the
% sine of angle between the two unit vectors forms the radius (of the
% circle) which moves by deltaRoll so that the roll in pixel units becomes
% radius*angle or sin(alpha)*deltaRoll
%--------------------------------------------------------------------------

[xc, yc, zc] = sph2cart(deg2rad(raCorner(:)), deg2rad(decCorner(:)), ones(nCadences,1));
[x0, y0, z0] = sph2cart(deg2rad(raCenter(:)), deg2rad(decCenter(:)), ones(nCadences,1));



%--------------------------------------------------------------------------
% Step 3
% compute alpha, the angle beween two unit vectors in the direction of the
% two artificial stars mapped onto the sky in the previous step
%--------------------------------------------------------------------------


for iCadence = 1:nCadences


    % convert deltaRa which is in arcseconds of time to arcseconds of angle by
    % applying the shrinkage factor (circles of constant declination get
    % smaller as dec increases from 0 to 90, ultimately becoming a point at dec = 90.
    % So seconds of arc in Ra gets smaller with increasing Dec

    tweakInArcsec(iCadence,1) = tweakInArcsec(iCadence,1) * cos(decNominalPointing(iCadence)*deg2rad);


    plateScaleForAll  = get_plate_scale(geometryObject, cadenceTimes(iCadence));

    pixel2arcsec =  median(plateScaleForAll); % median platescale


    unitVector1 = [xc(iCadence) yc(iCadence) zc(iCadence)]';
    unitVector2 = [x0(iCadence) y0(iCadence) z0(iCadence)]';

    alpha = sin(acos(dot(unitVector1, unitVector2)));

    % imagine a circle with a radius = the separation of the stars in the
    % sky (given by sin(alpha)), with the center at star 1 (star at the
    % center of the focal plane), X or roll axis normal to the circle, then
    % the arc swept by radius when it moves by an angle deltaRoll is given
    % by the following:

    % convert to pixel units by dividing by the platescale which is in
    % pixel/arcsec
    offsetInPixelUnitsAtEdgeOfFocalPlane(iCadence,1:2) = tweakInArcsec(iCadence,1:2)./pixel2arcsec;
    offsetInPixelUnitsAtEdgeOfFocalPlane(iCadence,3) = tweakInArcsec(iCadence,3)*sin(alpha)./pixel2arcsec;

end



fprintf('\n attitude tweak in units of arcsec\n');

disp(tweakInArcsec)

pdqOutputStruct.offsetInPixelUnitsAtEdgeOfFocalPlane =  offsetInPixelUnitsAtEdgeOfFocalPlane;
pdqOutputStruct.tweakInArcsec =  tweakInArcsec;


return;



