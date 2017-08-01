function result = fully_disable_offsets_in_tip_file( tipFilename, varargin )
% function result = fully_disable_offsets_in_tip_file( tipFilename, varargin )
%
% This TIP utility modifies a TIP text file so that transit offsets are
% disabled. Other TIP parameters are adjusted to the resulting TIP text
% file written is identical to that which would have been produced running
% TIP with the module parameter simulatedTransitsConfigurationStruct.offsetEnabled = false;
% All outputs are seen to agree with a offsetEnabled = false TIP run to
% 1e-8 which is the minimum resolution of the TIP test file. 
%
% Note that the only modified parameters used by PA and DV when injecting transits are:
% transitOffsetEnabled
% transitOffsetArcsec
% transitOffsetPhase
% 
% We've also corrected the following unused derived parameters for completeness:
% sourceOffsetDecDegrees
% sourceOffsetRaHours
% skyOffsetDecArcSec
% skyOffsetRaArcSec
%
% INPUTS:  tipFilename  == filename of TIP text output
%                          The modified TIP text file output will be
%                          written to the same filename
%           varargin    == nx1 double array; List of keplerIds to disable
%                          the offsets for. If there is no variable
%                          argument input the offsets will be disabled for
%                          all KeplerIds in the input file
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

% get variable argument
if nargin > 1
    keplerIdsToChange = varargin{1};
else
    keplerIdsToChange = M.keplerId;
end

% find logical indices
tf = ismember(M.keplerId,keplerIdsToChange);

% set transitOffsetEnabled to false
M.transitOffsetEnabled(tf) = false(size(M.transitOffsetEnabled(tf)));

% set trasitOffset magintude and phase to zero
M.transitOffsetArcsec(tf) = zeros(size(M.transitOffsetArcsec(tf)));
M.transitOffsetPhase(tf) = zeros(size(M.transitOffsetPhase(tf)));

% sourceOffsetDecDegrees should equal targetDecDegrees from the kic which
% we don't have but we can back it out since:
% sourceOffsetDecDegrees = targetDecDegrees + skyOffsetDecArcSec .* DEGREES_PER_ARCSEC;
M.sourceOffsetDecDegrees(tf) = M.sourceOffsetDecDegrees(tf) - M.skyOffsetDecArcSec(tf) .* DEGREES_PER_ARCSEC;

% sourceOffsetRaHours should equal targetRaHours from the kic which we
% don't have. Use the dec results above since sourceOffsetDecDegrees is now equal to
% targetDecDegrees and back out sourceOffsetRaHours since:
% sourceOffsetRaHours = targetRaHours + skyOffsetRaArcSec .* DEGREES_PER_ARCSEC ./ DEGREES_PER_HOUR ./ cos(deg2rad( targetDecDegrees ));
M.sourceOffsetRaHours(tf) = M.sourceOffsetRaHours(tf) - M.skyOffsetRaArcSec(tf) .* DEGREES_PER_ARCSEC ./ DEGREES_PER_HOUR ./ cos(deg2rad( M.sourceOffsetDecDegrees(tf) ));

% set skyOffsetRaArcSec and skyOffsetDecArcSec to zero
M.skyOffsetRaArcSec(tf) = zeros(size(M.skyOffsetRaArcSec(tf)));
M.skyOffsetDecArcSec(tf) = zeros(size(M.skyOffsetDecArcSec(tf)));

% write the result back to the incoming filename
result = write_simulated_transit_parameters( tipFilename, M );

