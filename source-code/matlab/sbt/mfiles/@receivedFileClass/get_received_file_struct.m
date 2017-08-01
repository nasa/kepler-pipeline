function receivedFileStruct = get_received_file_struct(receivedFileObject, startMjd, endMjd, fields)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function receivedFileStruct = get_received_file_struct(receivedFileObject)
% or
% function receivedFileStruct = get_received_file_struct(receivedFileObject, startMjd, endMjd)
% or
% function receivedFileStruct = get_received_file_struct(receivedFileObject, startMjd, endMjd, fields)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
% Get the values of the specified fields of receivedFileObject within the specified time interval
%
% Inputs:
%   receivedFileObject      An object of the received file. 
%   startMjd                Optional. MJD of the start of the specified time interval.
%   endMjd                  Optional. MJD of the end of the specified time interval.
%   fields                  Optional. 1 x nFields array of strings describing the specified fields of the receivedFileObject.
%                           A valid string should be a member of the set
%                           {   'mjdSocIngestTime' 
%                               'filename'
%                               'dispatcherType'    }.
%                          If 'fields' are not specified, all fields of receivedFileObject are provided for output.
%                          If 'startMjd', 'endMjd' and 'fields' are not specified, all fields of receivedFileObject at all available
%                          time stamps are provided for output.
%                                                           
% Output:
%   receivedFileStruct      1 x nReceivedFiles array of structures describing the received files.
%                           nReceivedFiles is the number of received files in the array. 
%                           The structure contains all or some of the following fields:
%       .mjdSocIngestTime   SOC ingest time in MJD of the received file.
%       .filename           A string defining the filename of the received file.
%       .dispatcherType     A string defining the dispatcher type of the received file.
%                           It can be any member of the set
%                           {   'LONG_CADENCE_PIXEL'
%                               'SHORT_CADENCE_PIXEL'
%                               'GAP_REPORT'
%                               'CONFIG_MAP'
%                               'REF_PIXEL'
%                               'LONG_CADENCE_TARGET_PMRF'
%                               'SHORT_CADENCE_TARGET_PMRF'
%                               'BACKGROUND_PRMF'
%                               'LONG_CADENCE_COLLATERAL_PMRF'
%                               'SHORT_CADENCE_COLLATERAL_PMRF'
%                               'HISTOGRAM'
%                               'ANCILLARY'
%                               'EPHEMERIS'
%                               'SCLK'
%                               'CRCT'
%                               'FFI'
%                               'HISTORY'                       }.
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

if ~( nargin==1 || nargin==3 || nargin==4 )
    error('MATLAB:SBT:receivedFileClass:get_received_file_struct:wrongNumberOfInputs', ...
          'MATLAB:SBT:receivedFileClass:get_received_file_struct: must be called with 1 or 3 or 4 input arguments.');
end

% Define a structure with empty fields
receivedFileEmptyFields = struct('mjdSocIngestTime',    [], ...
                                 'filename',            '', ...
                                 'dispatcherType',      '');
                         
if ( isempty(receivedFileObject) )
    error('MATLAB:SBT:receivedFileClass:get_received_file_struct:invalidInput', 'receivedFileObject cannot be empty.');
elseif ( isempty([receivedFileObject.mjdSocIngestTime]) )
    warning('MATLAB:SBT:receivedFileClass:get_received_file_struct:outputStructWithEmptyFields', ...
            'No data in receivedFileObject. A structure with empty fields is provided for output.');
    receivedFileStruct = receivedFileEmptyFields;
    return
end

isAllTimeStamps = 0;
if ( ~exist('startMjd', 'var') || ~exist('endMjd', 'var') )
    % If either of the inputs "startMjd" and "endMjd" doesn't exist,
    % the received files at all available time stamps are provided for output.
    isAllTimeStamps = 1;
    indexReceivedFile = 1:length([receivedFileObject.mjdSocIngestTime]);
else
    % Check the validity of inputs "startMjd" and "endMjd"
    sbt_validate_time_interval(startMjd, endMjd, 0, 'MATLAB:SBT:receivedFileClass:get_received_file_struct:invalidInput');

    % Get the indexes of received files which are within the specified time interval
    allIngestTime = [receivedFileObject.mjdSocIngestTime];
    indexReceivedFile = find( allIngestTime>=startMjd & allIngestTime<=endMjd );
end

isAllFields = 0;
iValidField = 0;
validFields = [];
allFields = {'mjdSocIngestTime' 'filename' 'dispatcherType'};
if ( ~exist('fields', 'var') )
    % If the input "fields" doesn't exit, all fields of receivedFileObject are provided for output.
    isAllFields = 1;
    validFields = allFields;
elseif ( isempty(fields) )
    validFields = [];
else
    % Check the validity of each member of the input "fields"
    for iField = 1:length(fields)
        aField = fields{iField};
        if ( ismember(aField, allFields) )
            iValidField = iValidField + 1;
            validFields{iValidField} = aField;
        else
            warning('MATLAB:SBT:receivedFileClass:get_received_file_struct:invalidInput', [aField ' is not a valid field of receivedFileObject.']);
        end
    end
end

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Generate the output structure
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

if ( isempty(indexReceivedFile) )
    warning('MATLAB:SBT:receivedFileClass:get_received_file_struct:outputStructWithEmptyFields', ...
            'No received files found within the specified time interval. A structure with empty fields is provided for output.');
    receivedFileStruct = receivedFileEmptyFields;
    return
end

if ( isempty(validFields) )
    warning('MATLAB:SBT:receivedFileClass:get_received_file_struct:outputStructWithEmptyFields', ...
            'No valid fields found in the specified "fields". A structure with empty fields is provided for output.');
    receivedFileStruct = receivedFileEmptyFields;
    return
end

if ( isAllTimeStamps==1 && isAllFields==1 )
    receivedFileStruct = struct(receivedFileObject);
elseif ( isAllTimeStamps~=1 && isAllFields==1 )
    receivedFileStruct = struct(receivedFileObject(indexReceivedFile));
else
    for iReceivedFile = 1:length(indexReceivedFile)
        for iField = 1:length(validFields)
            indexField = strmatch(validFields{iField}, allFields, 'exact');
            receivedFileStruct(iReceivedFile).(validFields{iField}) = receivedFileObject(indexReceivedFile(iReceivedFile)).(allFields{indexField});
        end
    end
end

return
