function cadenceMjdStruct = convert_cadence_to_mjd(pixelLogObject, cadenceArray)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function cadenceMjdStruct = convert_cadence_to_mjd(pixelLogObject, cadenceArray)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
% Get the start, end and mid-point time in MJDs of the cadences from a pixel log object based on the cadence numbers.
% 
% Inputs:
%   pixeLogObject       An object of the pixel logs.
%   cadenceArray        1 x nCadences array of cadence numbers. nCadences is the number of cadences in the array.
%
% Output:
%   cadenceMjdStruct    1 x nCadences array of structures containing the start, end and mid-point time in MJDs of the cadences.
%                       The structure has the following fields:
%       .cadenceNumber  Cadence number.
%       .mjdStartTime   MJD start time of the cadence.
%       .mjdEndTime     MJD end time of the cadence.
%       .mjdMidTime     MJD mid-point time of the cadence.
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
    
if nargin~=2
    error('MATLAB:SBT:pixelLogClass:convert_cadence_to_mjd:wrongNumberOfInputs', ...
          'MATLAB:SBT:pixelLogClass:convert_cadence_to_mjd: must be called with 2 input arguments.');
end

cadenceMjdStructEmptyFields = struct('cadenceNumber', [], ...
                                     'mjdStartTime',  [], ...
                                     'mjdEndTime',    [], ...
                                     'mjdMidTime',    []);

if ( isempty(pixelLogObject) )
    error('MATLAB:SBT:pixelLogClass:convert_cadence_to_mjd:invalidInput', 'pixelLogObject cannot be empty.');
elseif ( isempty([pixelLogObject.cadenceNumber]) )
    warning('MATLAB:SBT:pixelLogClass:convert_cadence_to_mjd:outputStructWithEmptyFields', ...
            'No data in pixelLogObject. A structure with empty fields is provided for output.');
    cadenceMjdStruct = cadenceMjdStructEmptyFields;
    return
end

allCadenceNumber = [pixelLogObject.cadenceNumber];
if ( ~isempty(cadenceArray) )
    variableAndBounds = {'cadenceArray'; '>= 0'; '< 1e12'; []};
    validate_field(cadenceArray, variableAndBounds, 'MATLAB:SBT:pixelLogClass:convert_cadence_to_mjd:invalidInput');
else
    cadenceArray = allCadenceNumber;
end

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Generate the output structure
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

% Preallocate the structure arrays for output
nCadences = length(cadenceArray);
cadenceMjdStruct = repmat(cadenceMjdStructEmptyFields, 1, nCadences);

for iCadence = 1:nCadences
    indexArray = find( cadenceArray(iCadence)==allCadenceNumber );

    % If the retrieved pixel log is not empty, the MJD start, end and mid-point time are assigned to
    % corresponding fields of the member of the output structure array. Otherwise, the member of the
    % output array remains to be a structure with empty fields.
    if ( ~isempty(indexArray) )

        cadenceMjdStruct(iCadence).cadenceNumber = pixelLogObject(indexArray(1)).cadenceNumber;
        cadenceMjdStruct(iCadence).mjdStartTime  = pixelLogObject(indexArray(1)).mjdStartTime;
        cadenceMjdStruct(iCadence).mjdEndTime    = pixelLogObject(indexArray(1)).mjdEndTime;
        cadenceMjdStruct(iCadence).mjdMidTime    = pixelLogObject(indexArray(1)).mjdMidTime;

    end
end

return

