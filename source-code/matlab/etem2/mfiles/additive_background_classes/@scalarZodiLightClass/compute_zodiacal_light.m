function scalarZodiLightObject = compute_zodiacal_light(scalarZodiLightObject)
% compute if it has been set to zero
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
if scalarZodiLightObject.zodiFluxValue == 0
    runParamsObject = scalarZodiLightObject.runParamsClass;
    moduleNumber = get(runParamsObject, 'moduleNumber');
    outputNumber = get(runParamsObject, 'outputNumber');
    numVisibleRows = get(runParamsObject, 'numVisibleRows');
    numVisibleCols = get(runParamsObject, 'numVisibleCols');
    runStartTime = get(runParamsObject, 'runStartTime'); % days
    runEndTime = get(runParamsObject, 'runEndTime'); % days
    timeVector = get(runParamsObject, 'timeVector'); 
    flux12 = get(runParamsObject, 'fluxOfMag12Star'); 
    raDec2PixObject = get(runParamsObject, 'raDec2PixObject');
    centerTimeIndex = get(raDec2PixObject, 'centerTimeIndex');
    
    % compute RA/Dec of the CENTER of the output
    [outputCenterRa, outputCenterDec] = ...
        pix_to_ra_dec(raDec2PixObject, moduleNumber, outputNumber, numVisibleRows/2, ...
        numVisibleCols/2, timeVector(centerTimeIndex));

    % returns vmag per pixel when sent ra/dec (in degrees) 
    % of module center in heliocentric coords
    zodiMagnitude = fake_zodi_model(outputCenterRa, outputCenterDec, (runStartTime+runEndTime)/2);
%     zodiMagnitude = Zodi_Model(outputCenterRa, outputCenterDec, (runStartTime+runEndTime)/2);

    % compute the flux in counts from the zodi mag
    scalarZodiLightObject.zodiFluxValue = flux12 * mag2b(zodiMagnitude) / mag2b(12); %zodi is in e-/sec
end

