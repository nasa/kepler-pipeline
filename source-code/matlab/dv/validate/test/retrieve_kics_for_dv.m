function validKeplerIds = retrieve_kics_for_dv(module, output, ...
    minKeplerMag, maxKeplerMag, startDateString, targetListSetName)
%
%
% Kepler Ids are retrieved from the database using retrieve_kics.
%
% The selected kepler Ids must be cross checked with:
%
%   (1) the target list set (in this case 'quarter2_summer2009_lc' from the
%       kepsnpq database)
%
%   (2) allowed Teff range [5240 6530]
%
%   (3) allowed logg range [4 5]
%
%   (4) allowed magnitude range [9 15]
%
%
%
% kics = retrieve_kics_matlabstyle(7, 3,  55001, 12, 12.05, 'get_chars')
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



if nargin == 0
    module = 7;
    output = 3;
    minKeplerMag = 12;
    maxKeplerMag = 12.1;
    startDateString     = '26-June-2009 00:00:00.000'; % mjd = 55008
    targetListSetName   = 'quarter2_summer2009_lc';

elseif nargin == 2

    minKeplerMag = 12;
    maxKeplerMag = 12.1;
    startDateString     = '26-June-2009 00:00:00.000'; % mjd = 55008
    targetListSetName   = 'quarter2_summer2009_lc';
else
    display('function must be called with 0, 2, 4, or 6 arguments')

end


allowedMagnitudeRange = [9 15];
allowedEffTempRange   = [5240 6530];
allowedlogGRange      = [4 5];



% retrieve targets
mjd = datestr2mjd(startDateString);

kics = retrieve_kics_matlabstyle(module, output, mjd, minKeplerMag, maxKeplerMag, 'get_chars');



keplerIds = [kics.keplerId]';

% fill empty values with zeros to keep arrays the same size
for i = 1:length(keplerIds)

    effectiveTemp = kics(i).effectiveTemp.value;
    if isempty(effectiveTemp)
        kics(i).effectiveTemp.value = 0;
    end

    keplerMag = kics(i).keplerMag.value;
    if isempty(keplerMag)
        kics(i).keplerMag.value = 0;
    end

    log10SurfaceGravity = kics(i).log10SurfaceGravity.value;
    if isempty(log10SurfaceGravity)
        kics(i).log10SurfaceGravity.value = 0;
    end
end


effectiveTempArray       = [kics.effectiveTemp.value]';
keplerMagArray           = [kics.keplerMag.value]';
log10SurfaceGravityArray = [kics.log10SurfaceGravity.value]';


% find valid kepler Ids

validKeplerIdsForDv = keplerIds(...
    effectiveTempArray >= allowedEffTempRange(1) & ...
    effectiveTempArray <= allowedEffTempRange(2) & ...
    keplerMagArray     >= allowedMagnitudeRange(1) & ...
    keplerMagArray     <= allowedMagnitudeRange(2) & ...
    log10SurfaceGravityArray >= allowedlogGRange(1) & ...
    log10SurfaceGravityArray <= allowedlogGRange(2));


% retrieve targets from input target list set
tadInputStruct = retrieve_tad(module, output, targetListSetName);


allKeplerIds = [tadInputStruct.targetDefinitions.keplerId]';


% find kepler Ids in target list set
validKeplerIds = intersect(validKeplerIdsForDv, allKeplerIds);


display(['Valid Kepler Ids from mod ' num2str(module) ' out ' num2str(output)  ' are' mat2str(validKeplerIds)  ])



% Other characteristics available:
%
% kics =
% 1x27 struct array with fields:
%     dec
%     galacticLatitude
%     galacticLongitude
%     ra
%     avExtinction
%     d51Mag
%     decProperMotion
%     ebMinusVRedding
%     gkColor
%     gMag
%     grColor
%     gredMag
%     iMag
%     jkColor
%     keplerMag
%     log10Metallicity
%     log10SurfaceGravity
%     parallax
%     radius
%     raProperMotion
%     rMag
%     totalProperMotion
%     twoMassHMag
%     twoMassJMag
%     twoMassKMag
%     uMag
%     zMag
%     alternateId
%     alternateSource
%     astrophysicsQuality
%     blendIndicator
%     catalogId
%     effectiveTemp
%     galaxyIndicator
%     internalScpId
%     photometryQuality
%     scpId
%     twoMassId
%     variableIndicator
%     keplerId
%     skyGroupId
%     source
%     characteristics


return;

