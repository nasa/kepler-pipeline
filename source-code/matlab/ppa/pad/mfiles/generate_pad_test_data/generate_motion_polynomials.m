function [motionPolynomials, refStellarTargets] = generate_motion_polynomials(cadenceTimes, raDec2PixModel, raPointing, decPointing, rollPointing, aberrateFlag, ...
                                                                            sigma, failedChannelIndex, failedCadenceIndex)
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

nCadences        = length(cadenceTimes);

[rowRef, colRef] = ndgrid(30:100:1030, 30:100:1030);
rowRef           = rowRef(:);
colRef           = colRef(:);
ovec             = ones(size(rowRef));

motionPolynomials(84,nCadences).cadenceTime   = [];
motionPolynomials(84,nCadences).module        = [];
motionPolynomials(84,nCadences).output        = [];
motionPolynomials(84,nCadences).rowPoly       = [];
motionPolynomials(84,nCadences).rowPolyStatus = [];
motionPolynomials(84,nCadences).colPoly       = [];
motionPolynomials(84,nCadences).colPolyStatus = [];

refStellarTargets(84).raDeg  = [];
refStellarTargets(84).decDeg = [];

raDec2PixObject = raDec2PixClass(raDec2PixModel);

iCadence = 1;
for iChannel = 1:84

    [modRef, outRef] = convert_to_module_output(iChannel);

    [raRef, decRef] = pix_2_ra_dec_absolute( raDec2PixObject, modRef*ovec, outRef*ovec, rowRef, colRef, cadenceTimes(iCadence), ...
        raPointing(iCadence), decPointing(iCadence), rollPointing(iCadence), aberrateFlag);

    refStellarTargets(iChannel).raDeg  = raRef(:);
    refStellarTargets(iChannel).decDeg = decRef(:);

end % channel loop

for iCadence = 1:nCadences

    for iChannel = 1:84

        ra  = refStellarTargets(iChannel).raDeg;
        dec = refStellarTargets(iChannel).decDeg;
        
        [mod, out, row, col] = ra_dec_2_pix_absolute( raDec2PixObject, ra, dec, cadenceTimes(iCadence), ...
            raPointing(iCadence), decPointing(iCadence), rollPointing(iCadence), aberrateFlag) ;
        
        motionPolynomials(iChannel,iCadence).cadenceTime   = cadenceTimes(iCadence);
        motionPolynomials(iChannel,iCadence).module        = mod(1);
        motionPolynomials(iChannel,iCadence).output        = out(1);
        motionPolynomials(iChannel,iCadence).rowPoly       = weighted_polyfit2d(ra, dec, row+sigma*randn(size(row)), 1/sigma, 3);
        motionPolynomials(iChannel,iCadence).colPoly       = weighted_polyfit2d(ra, dec, col+sigma*randn(size(col)), 1/sigma, 3);
        
        if ( ismember(iChannel, failedChannelIndex) || ismember(iCadence, failedCadenceIndex) )
            motionPolynomials(iChannel,iCadence).rowPolyStatus = false;
            motionPolynomials(iChannel,iCadence).colPolyStatus = false ;
        else
            motionPolynomials(iChannel,iCadence).rowPolyStatus = true;
            motionPolynomials(iChannel,iCadence).colPolyStatus = true;
        end

    end % channel loop

end % cadence loop

return