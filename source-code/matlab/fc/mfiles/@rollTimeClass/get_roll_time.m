function rollTime = get_roll_time(rollTimeObject, mjd)
%
% rollTime = get_roll_time(rollTimeObject, mjd)
% or
% rollTime = get_roll_time(rollTimeObject)
%
% Get the most recent roll time for the input MJD
%
% The call with no input args (except the object) gets the roll time that
% is valid for the latest MJD.
%
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

% Check usage.
%
veryLargeMjd = 100000;
if nargin == 1
    mjd = veryLargeMjd;
end

minMjds = min(rollTimeObject.mjds);
if any(mjd < minMjds)
    error('Matlab:FC:rollTimeClass:get_roll_time', ...
        '%f occurs before the start of this Roll Time object: %f', ...
        min(mjd), minMjds);
end

% Find the latest roll time entry for each mjd.
%
matchingIndex = zeros(size(mjd));
for ii=1:length(mjd)
    matchingIndex(ii) = find(rollTimeObject.mjds <= mjd(ii), 1, 'last');
end

% The first column of rollTime is the MJD, second column is the roll offset,
% the third column is the season, the fourth column is the FOV center RA,
% the fifth column is the FOV center Dec, and the sixth column is the FOV
% center roll.
% 
rollTimeMjds         = rollTimeObject.mjds(matchingIndex);
rollTimeOffsets      = rollTimeObject.rollOffsets(matchingIndex);
rollTimeSeasons      = double(rollTimeObject.seasons(matchingIndex)) ;
rollTimeRas          = rollTimeObject.fovCenterRas(matchingIndex);
rollTimeDeclinations = rollTimeObject.fovCenterDeclinations(matchingIndex);
rollTimeRolls        = rollTimeObject.fovCenterRolls(matchingIndex);

rollTime = [rollTimeMjds(:), rollTimeOffsets(:), rollTimeSeasons(:), ...
    rollTimeRas(:), rollTimeDeclinations(:), rollTimeRolls(:)];
% rollTime = double(rollTime);

return
