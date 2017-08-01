function validCadences = get_cadence_mjds(startMjd, endMjd, isLongCadence)
%
% validCadences = get_cadence_mjds(startMjd, endMjd, isLongCadence)
%
% or
%
% validCadences = get_cadence_mjds(startMjd, endMjd)
%
% A convenience function which takes the inputs MJDs, determines which cadence
% number each MJD falls in, and returns the start/mid/end MJD for that cadence.
%
% INPUTS:
%   startMjd            The MJD of the start of the time range.
%   endMjd              The MJD of the end of the time range.
%   isLongCadence       Optional. If TRUE, long cadence data is returned,
%                       otherwise short cadence data is returned.
%
% OUTPUTS:
%   validCadences       A vector of N structs, with each struct having these fields:
%
%       .mjdStartTime   MJD of the start of the cadence.
%       .mjdMidTime     MJD of the middle of the cadence
%       .mjdEndTime     MJD of the end of the cadence
%       .cadenceNumber  Cadence number for the MJD correcponding to the
%                       i-th entry in the input mjds argument
%
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

    % Default isLongCadnece to long (1)
    switch nargin
        case 2
            isLongCadence = 1;
        case 3
            % isLongCadence is unchanged
        otherwise
            error('MATLAB:SBT:wrapper:get_cadence_mjds', 'Illegal number of arguments.');
    end
    

    % Generate the cadences that correspond to the input MJDs:
    %
    pixelLogs = retrieve_pixel_log(isLongCadence, startMjd, endMjd, 0);
    pixelLogObject = pixelLogClass(pixelLogs);

    cadenceForThisMjd = convert_mjd_to_cadence(pixelLogObject, startMjd, endMjd);
    if length(cadenceForThisMjd) < 1
        error('MATLAB:SBT:wrapper:get_cadence_mjds', ...
            'Nothing  returned from convert_mjd_to_cadence.  Exiting');
    end

    validCadences = convert_cadence_to_mjd(pixelLogObject, cadenceForThisMjd);

    if length(validCadences) < 1
        error('MATLAB:SBT:wrapper:get_cadence_mjds', ...
              'There are %d elements in validCadences , 1 or more was expected.', length(validCadences));
    end
return

