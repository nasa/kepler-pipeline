function [ newOs ] = sub_in_m_dwarf_rows(origOs,mOs)
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

origList = dir('orig/kplr*txt');
mList = dir('mdwarfs/kplr*txt');
load mdwarfids

oSkyGroup = [];
mSkyGroup = [];
for i = 1:numel(origList)
    oSkyGroup = [oSkyGroup; str2num(origList(i).name(19:20))];
end

for i = 1:numel(mList)
    mSkyGroup = [mSkyGroup; str2num(mList(i).name(19:20))];
end

[c, ia, ib] = intersect(oSkyGroup,mSkyGroup);

for i = 1:numel(ia)
    origTextFilename = ['orig/' origList(ia(i)).name];
    mTextFilename = ['mdwarfs/' mList(ib(i)).name];
    
    [ origOs ] = read_simulated_transit_parameters( origTextFilename )
    [ mOs ] = read_simulated_transit_parameters( mTextFilename )
    
    [c3, ia3, ib3] = intersect(mOs.keplerId, kepIds);
    
    mOs.keplerId = mOs.keplerId(ia3);
    mOs.transitDepthPpm = mOs.transitDepthPpm(ia3);
    mOs.transitDurationHours = mOs.transitDurationHours(ia3);
    mOs.orbitalPeriodDays = mOs.orbitalPeriodDays(ia3);
    mOs.epochBjd = mOs.epochBjd(ia3);
    mOs.eccentricity = mOs.eccentricity(ia3);
    mOs.longitudeOfPeriDegrees = mOs.longitudeOfPeriDegrees(ia3);
    mOs.transitSeparationDays = mOs.transitSeparationDays(ia3);
    mOs.transitOffsetEnabled = mOs.transitOffsetEnabled(ia3);
    mOs.transitOffsetDepthPpm = mOs.transitOffsetDepthPpm(ia3);
    mOs.transitOffsetArcsec = mOs.transitOffsetArcsec(ia3);
    mOs.transitOffsetPhase = mOs.transitOffsetPhase(ia3);
    mOs.skyOffsetRaArcSec = mOs.skyOffsetRaArcSec(ia3);
    mOs.skyOffsetDecArcSec = mOs.skyOffsetDecArcSec(ia3);
    mOs.sourceOffsetRaHours = mOs.sourceOffsetRaHours(ia3);
    mOs.sourceOffsetDecDegrees = mOs.sourceOffsetDecDegrees(ia3);
    mOs.semiMajorAxisOverRstar = mOs.semiMajorAxisOverRstar(ia3);
    mOs.RplanetOverRstar = mOs.RplanetOverRstar(ia3);
    mOs.planetRadiusREarth = mOs.planetRadiusREarth(ia3);
    mOs.impactParameter = mOs.impactParameter(ia3);
    mOs.stellarRadiusRsun = mOs.stellarRadiusRsun(ia3);
    mOs.stellarMassMsun = mOs.stellarMassMsun(ia3);
    mOs.stellarLog10Gravity = mOs.stellarLog10Gravity(ia3);
    mOs.stellarEffectiveTempKelvin = mOs.stellarEffectiveTempKelvin(ia3);
    mOs.stellarLog10Metalicity = mOs.stellarLog10Metalicity(ia3);
    mOs.transitBufferCadences = mOs.transitBufferCadences(ia3);
    mOs.singleEventStatistic = mOs.singleEventStatistic(ia3);
    mOs.normalizedEpochPhase = mOs.normalizedEpochPhase(ia3);
    
    
    [c2, ia2, ib2] = intersect(origOs.keplerId, mOs.keplerId);
    
    newOs = origOs;
    
    newOs.keplerId(ia2) = mOs.keplerId(ib2);
    newOs.transitDepthPpm(ia2) = mOs.transitDepthPpm(ib2);
    newOs.transitDurationHours(ia2) = mOs.transitDurationHours(ib2);
    newOs.orbitalPeriodDays(ia2) = mOs.orbitalPeriodDays(ib2);
    newOs.epochBjd(ia2) = mOs.epochBjd(ib2);
    newOs.eccentricity(ia2) = mOs.eccentricity(ib2);
    newOs.longitudeOfPeriDegrees(ia2) = mOs.longitudeOfPeriDegrees(ib2);
    newOs.transitSeparationDays(ia2) = mOs.transitSeparationDays(ib2);
    newOs.transitOffsetEnabled(ia2) = mOs.transitOffsetEnabled(ib2);
    newOs.transitOffsetDepthPpm(ia2) = mOs.transitOffsetDepthPpm(ib2);
    newOs.transitOffsetArcsec(ia2) = mOs.transitOffsetArcsec(ib2);
    newOs.transitOffsetPhase(ia2) = mOs.transitOffsetPhase(ib2);
    newOs.skyOffsetRaArcSec(ia2) = mOs.skyOffsetRaArcSec(ib2);
    newOs.skyOffsetDecArcSec(ia2) = mOs.skyOffsetDecArcSec(ib2);
    newOs.sourceOffsetRaHours(ia2) = mOs.sourceOffsetRaHours(ib2);
    newOs.sourceOffsetDecDegrees(ia2) = mOs.sourceOffsetDecDegrees(ib2);
    newOs.semiMajorAxisOverRstar(ia2) = mOs.semiMajorAxisOverRstar(ib2);
    newOs.RplanetOverRstar(ia2) = mOs.RplanetOverRstar(ib2);
    newOs.planetRadiusREarth(ia2) = mOs.planetRadiusREarth(ib2);
    newOs.impactParameter(ia2) = mOs.impactParameter(ib2);
    newOs.stellarRadiusRsun(ia2) = mOs.stellarRadiusRsun(ib2);
    newOs.stellarMassMsun(ia2) = mOs.stellarMassMsun(ib2);
    newOs.stellarLog10Gravity(ia2) = mOs.stellarLog10Gravity(ib2);
    newOs.stellarEffectiveTempKelvin(ia2) = mOs.stellarEffectiveTempKelvin(ib2);
    newOs.stellarLog10Metalicity(ia2) = mOs.stellarLog10Metalicity(ib2);
    newOs.transitBufferCadences(ia2) = mOs.transitBufferCadences(ib2);
    newOs.singleEventStatistic(ia2) = mOs.singleEventStatistic(ib2);
    newOs.normalizedEpochPhase(ia2) = mOs.normalizedEpochPhase(ib2);
    
    % write the file back where it came from
    newfilename = [origTextFilename(1:25) '_withMs.txt'];
    display(['Writing TIP output file ',newfilename,' ...']);
    write_simulated_transit_parameters( newfilename, newOs );

end





return;