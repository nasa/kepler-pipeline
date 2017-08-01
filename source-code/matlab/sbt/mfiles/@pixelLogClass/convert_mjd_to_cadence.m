function cadenceArray = convert_mjd_to_cadence(pixelLogObject, startMjd, endMjd)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function cadenceArray = convert_mjd_to_cadence(pixelLogObject, startMjd, endMjd)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
% Get the cadence numbers within a time interval specified by the MJD start and end time from a pixel log object.
%
% Inputs:
%   pixeLogObject       An object of the pixel logs.
%   startMjd            MJD of the start of the specified time interval.
%   endMjd              MJD of the end of the specified time interval.
%
% Output:
%   cadenceArray        1 x nCadences array of cadence numbers. nCadences is the number of  
%                       cadences within the specified time interval.
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

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Validity check on inputs
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    
if nargin~=3
    error('MATLAB:SBT:pixelLogClass:convert_mjd_to_cadence:wrongNumberOfInputs', ...
          'MATLAB:SBT:pixelLogClass:convert_mjd_to_cadence: must be called with 3 input arguments.');
end

if ( isempty(pixelLogObject) )
    error('MATLAB:SBT:pixelLogClass:convert_mjd_to_cadence:invalidInput', 'pixelLogObject cannot be empty.');
elseif ( isempty([pixelLogObject.cadenceNumber]) )
    warning('MATLAB:SBT:pixelLogClass:convert_mjd_to_cadence:outputEmptyArray', ...
            'No data in pixelLogObject. An empty array is provided for output.');
    cadenceArray = [];
    return
end

isInputCadenceNumber = 0;
sbt_validate_time_interval(startMjd, endMjd, isInputCadenceNumber, 'MATLAB:SBT:pixelLogClass:convert_mjd_to_cadence:invalidInput');

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Generate the output array
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

pixelLogStruct = get_pixel_log_struct(pixelLogObject, startMjd, endMjd, isInputCadenceNumber, {'cadenceNumber'});
intermCadenceArray = [pixelLogStruct.cadenceNumber];        

% When the data retrieved is empty, an empty array is provided for output.
if ( isempty(intermCadenceArray) )
    warning('MATLAB:SBT:pixelLogClass:convert_mjd_to_cadence:outputEmptyArray', ...
            'No valid pixel logs found within the specified time interval. An empty array is provided for output.');
    cadenceArray = [];
    return
end

% Get rid of repeated members of the array and sort the array in ascending order for output.
cadenceArray = sort( unique(intermCadenceArray(:)'), 2, 'ascend' );

return
