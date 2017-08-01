function result = modify_offsets_in_tip_file( tipFilename )
% function result = modify_offsets_in_tip_file( tipFilename )
%
% This TIP utility modifies a TIP text file so that transit offsets are modified. We modify transitOffsetArcsec for 10% of the targets,
% moving them to a uniform distribution between 4 and 10 arcsec. The following derived parameters are also updated:  
% sourceOffsetDecDegrees
% sourceOffsetRaHours
% skyOffsetDecArcSec
% skyOffsetRaArcSec
% 
% INPUTS:  tipFilename  == filename of TIP text output
%                          The modified TIP text file output will be
%                          written to the same filename
% OUTPUT:   result      == boolean; true if write succeeds, otherwise false
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


% retrieve units conversions
DAYS_PER_HOUR = get_unit_conversion('hour2day');
HOURS_PER_SECOND = get_unit_conversion('sec2hour');
DEGREES_PER_RADIAN = get_unit_conversion('rad2deg');
DEGREES_PER_HOUR = 2 * pi * DAYS_PER_HOUR * DEGREES_PER_RADIAN;
DEGREES_PER_ARCSEC = HOURS_PER_SECOND;

% read the TIP input
M = read_simulated_transit_parameters( tipFilename );

% select 10 percent of targets and change their offset to between 4 and 10 arcsec
idx = rand(numel(M.transitOffsetEnabled),1) < 0.1;
M.transitOffsetArcsec(idx) = rand(sum(idx),1) .* 6 + 4;

% Below is the correct computation for skyOffset and sourceOffset
% % compute sky offset and offset source location
% skyOffsetRaArcSec       = offsetArcSec .* cos(offsetPhase);
% skyOffsetDecArcSec      = offsetArcSec .* sin(offsetPhase);
% sourceOffsetRaHours     = targetRaHours + skyOffsetRaArcSec .* DEGREES_PER_ARCSEC ./ DEGREES_PER_HOUR ./ cos(deg2rad( targetDecDegrees ));
% sourceOffsetDecDegrees  = targetDecDegrees + skyOffsetDecArcSec .* DEGREES_PER_ARCSEC;

% adjust skyOffset for new transitOffsetArcsec
oldSkyOffsetRaArcSec = M.skyOffsetRaArcSec(idx);
oldSkyOffsetDecArcSec = M.skyOffsetDecArcSec(idx);
newSkyOffsetRaArcSec = M.transitOffsetArcsec(idx) .* cos(M.transitOffsetPhase(idx));
newSkyOffsetDecArcSec = M.transitOffsetArcsec(idx) .* sin(M.transitOffsetPhase(idx));

M.skyOffsetRaArcSec(idx) = newSkyOffsetRaArcSec;
M.skyOffsetDecArcSec(idx) = newSkyOffsetDecArcSec;

% adjust sourceOffset for new skyOffset
M.sourceOffsetDecDegrees(idx) = M.sourceOffsetDecDegrees(idx) - ...
    (oldSkyOffsetDecArcSec - newSkyOffsetDecArcSec) .* DEGREES_PER_ARCSEC;
M.sourceOffsetRaHours(idx) = M.sourceOffsetRaHours(idx) - ...
    (oldSkyOffsetRaArcSec - newSkyOffsetRaArcSec) .* DEGREES_PER_ARCSEC ./ DEGREES_PER_HOUR ./ cos(deg2rad( M.sourceOffsetDecDegrees(idx) ));

% write the result back to the incoming filename
result = write_simulated_transit_parameters( tipFilename, M );