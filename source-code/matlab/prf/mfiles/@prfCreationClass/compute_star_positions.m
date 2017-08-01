function prfCreationObject = compute_star_positions(prfCreationObject)
% fuction prfCreationObject = compute_star_positions(prfCreationObject)
% 
% compute the row and column (as doubles) of each star at each dither
%
% Returns the result as an 1 x # of dithers array
% in prfCreationObject.targetStarsStruct(t).row, .column
%
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

raDec2PixObject = prfCreationObject.raDec2PixObject;
RA_HOURS_TO_DEGREES = 360 / 24;

% now compute the exact row and column of each star for each dither
nTargets = length(prfCreationObject.targetStarsStruct);
% 
% use ra_dec_2_pix absolute with the input attitude to place the pixels
% with the dithered offset.  
goodTimeStamps = find(prfCreationObject.cadenceTimes.endTimestamps > 0);
[m o row col] = ra_dec_2_pix_absolute(raDec2PixObject, ...
    RA_HOURS_TO_DEGREES*[prfCreationObject.targetStarsStruct.ra], ...
    [prfCreationObject.targetStarsStruct.dec], ...
    prfCreationObject.cadenceTimes.endTimestamps(goodTimeStamps), ...
    prfCreationObject.spacecraftAttitudeStruct.ra.values(goodTimeStamps), ...
    prfCreationObject.spacecraftAttitudeStruct.dec.values(goodTimeStamps), ...
    prfCreationObject.spacecraftAttitudeStruct.roll.values(goodTimeStamps));
for t=1:nTargets
    prfCreationObject.targetStarsStruct(t).row ...
        = zeros(size(prfCreationObject.cadenceTimes.endTimestamps'));
    prfCreationObject.targetStarsStruct(t).column ...
        = zeros(size(prfCreationObject.cadenceTimes.endTimestamps'));
    prfCreationObject.targetStarsStruct(t).row(goodTimeStamps) = row(t, :);
    prfCreationObject.targetStarsStruct(t).column(goodTimeStamps) = col(t, :);
end



