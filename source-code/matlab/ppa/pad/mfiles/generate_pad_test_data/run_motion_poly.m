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
clear;
close all;

load ../test_data/padInputStruct_noMotionPoly.mat;
load ../test_data/pointingOffset.mat;

sigma = 1e0;
aberrateFlag = 1;
failedChannelIndex = 1:10:81;
failedCadenceIndex = [1 3];

cadenceTimes = padInputStruct.cadenceTimes;
nCadences    = length(cadenceTimes);

raDec2PixObject = raDec2PixClass(padInputStruct.raDec2PixModel);
pointingObject  = pointingClass(padInputStruct.raDec2PixModel.pointingModel);

nominalPointing  = get_pointing(pointingObject, cadenceTimes);
raPointing       = nominalPointing(:,1) + raOffset;
decPointing      = nominalPointing(:,2) + decOffset;
rollPointing     = nominalPointing(:,3) + rollOffset;

[motionPolys, refStars] = generate_motion_polynomials(cadenceTimes, padInputStruct.raDec2PixModel, raPointing, decPointing, rollPointing, aberrateFlag, ...
                                                    sigma, failedChannelIndex, failedCadenceIndex);

[rowRef, colRef] = ndgrid(30:500:1030, 30:500:1030);
rowRef           = rowRef(:);
colRef           = colRef(:);
ovec             = ones(size(rowRef));

refStellarTargets(84).raDeg  = [];
refStellarTargets(84).decDeg = [];

iCadence = 1;
for iChannel = 1:84
    
    iChannel
    
    [modRef, outRef] = convert_to_module_output(iChannel);

    [raRef, decRef] = pix_2_ra_dec_absolute( raDec2PixObject, modRef*ovec, outRef*ovec, rowRef, colRef, cadenceTimes(iCadence), ...
        raPointing(iCadence), decPointing(iCadence), rollPointing(iCadence), aberrateFlag);

    refStellarTargets(iChannel).raDeg  = raRef(:);
    refStellarTargets(iChannel).decDeg = decRef(:);

end % channel loop

modelPredicted(84).row =[];
modelPredicted(84).col =[];

polyFitted(84).row  = [];
polyFitted(84).col  = [];
polyFitted(84).Crow = [];
polyFitted(84).Ccol = [];

index = zeros(1,nCadences);

for iChannel = 1:84
    
    iChannel
    
    raRef  = refStellarTargets(iChannel).raDeg;
    decRef = refStellarTargets(iChannel).decDeg;
    nTargets = length(raRef);
    
    for iCadence = 1:nCadences
        
        [mod, out, modelPredicted(iChannel, iCadence).row, modelPredicted(iChannel, iCadence).col] = ...
            ra_dec_2_pix_absolute( raDec2PixObject, raRef, decRef, cadenceTimes(iCadence), raPointing(iCadence), decPointing(iCadence), rollPointing(iCadence), aberrateFlag); 
        
        [polyFitted(iChannel, iCadence).row, polyFitted(iChannel, iCadence).rowUncertainty] = weighted_polyval2d(raRef, decRef, motionPolys(iChannel, iCadence).rowPoly);
        [polyFitted(iChannel, iCadence).col, polyFitted(iChannel, iCadence).colUncertainty] = weighted_polyval2d(raRef, decRef, motionPolys(iChannel, iCadence).colPoly);
        
        deltaRow(index(iCadence)+(1:nTargets),iCadence) = polyFitted(iChannel, iCadence).row - modelPredicted(iChannel, iCadence).row;
        deltaCol(index(iCadence)+(1:nTargets),iCadence) = polyFitted(iChannel, iCadence).col - modelPredicted(iChannel, iCadence).col;
        index(iCadence) = index(iCadence) + nTargets;
        
    end
    
end

padInputStruct.motionPolys = motionPolys;

save ../test_data/padInputStruct.mat padInputStruct

figure(11)
plot(deltaRow(:,1), '.');
figure(12)
plot(deltaRow(:,2), '.');
figure(13)
plot(deltaRow(:,3), '.');
figure(14)
plot(deltaRow(:,4), '.');

figure(21)
plot(deltaCol(:,1), '.');
figure(22)
plot(deltaCol(:,2), '.');
figure(23)
plot(deltaCol(:,3), '.');
figure(24)
plot(deltaCol(:,4), '.');
