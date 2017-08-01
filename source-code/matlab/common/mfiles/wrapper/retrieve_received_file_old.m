function receivedFiles = retrieve_received_file(dispatcherType, startMjd, endMjd)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function receivedFiles = retrieve_received_file(dispatcherType)
% or
% function receivedFiles = retrieve_received_file(dispatcherType, startMjd, endMjd)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
% Retrieve filenames and properties of the files received by the data store within the specified time interval. 
%
% Inputs: 
%   dispatcherType          A string defining the dispatcher type of the received files to be retrieved. 
%                           A valid string should be a member of the following set
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
%                               'SPACECRAFT_EPHEMERIS'
%                               'PLANETARY_EPHEMERIS' 
%                               'LEAP_SECONDS'
%                               'SCLK'
%                               'CRCT'
%                               'FFI'
%                               'HISTORY'	
%                               'TARGET_LIST'
%                               'TARGET_LIST_SET'
%                               'MASK_TABLE'        }.
%   startMjd                Optional. MJD of the start of the specified time interval. It is set to 54000 if not specified.
%   endMjd                  Optional. MJD of the end of the specified time interval. It is set to 64000 if not specified.
%
% Output:
%   receivedFiles           1 x nReceivedFiles array of structures describing the received files.
%                           nReceivedFiles is the number of received files in the array.
%                           The structure contains the following fields:
%       .mjdSocIngestTime   SOC ingest time in MJD of the received file.
%       .filename           A string defining the filename of the received file.
%       .dispatcherType     A string defining the dispatcher type of the received file. It can be any member of
%                           the set defined in the input argument dispatcherType.
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
import gov.nasa.kepler.systest.sbt.SandboxTools;
SandboxTools.displayDatabaseConfig;

import gov.nasa.kepler.hibernate.dbservice.DatabaseServiceFactory;
import gov.nasa.kepler.hibernate.dr.LogCrud;
import gov.nasa.kepler.common.MatlabEnumFetcher;
import gov.nasa.kepler.common.ModifiedJulianDate;

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Validity check on inputs
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

if ~( nargin==1 || nargin==3 )
    error('MATLAB:SBT:wrapper:retrieve_received_file:wrongNumberOfInputs', 'MATLAB:SBT:wrapper:retrieve_received_file: must be called with 1 or 3 input arguments.');
end

if ( ~exist('startMjd', 'var') || isempty(startMjd) )
    startMjd = 54000;
    disp(['startMjd is set to ' num2str(startMjd)]);
end

if ( ~exist('endMjd', 'var') || isempty(endMjd) )
    endMjd   = 64000;
    disp(['endMjd is set to ' num2str(endMjd)]);
end
   
sbt_validate_time_interval(startMjd, endMjd, 0, 'MATLAB:SBT:wrapper:retrieve_received_file:invalidInput');

if ( isempty (dispatcherType) )
    error('MATLAB:SBT:wrapper:retrieve_received_file:invalidInput', 'dispatcherType cannot be empty.');
elseif ( ~ismember(dispatcherType, {'LONG_CADENCE_PIXEL' 'SHORT_CADENCE_PIXEL' 'GAP_REPORT' 'CONFIG_MAP' 'REF_PIXEL' ...
                                    'LONG_CADENCE_TARGET_PMRF' 'SHORT_CADENCE_TARGET_PMRF' 'BACKGROUND_PMRF' ...
                                    'LONG_CADENCE_COLLATERAL_PMRF' 'SHORT_CADENCE_COLLATERAL_PMRF' 'HISTOGRAM' ...
                                    'ANCILLARY', 'SPACECRAFT_EPHEMERIS', 'PLANETARY_EPHEMERIS', 'LEAP_SECONDS', ...
                                    'SCLK', 'CRCT', 'FFI', 'HISTORY' 'TARGET_LIST' 'TARGET_LIST_SET' 'MASK_TABLE'}) )
    error('MATLAB:SBT:wrapper:retrieve_received_file:invalidInput', 'Value of dispatcherType is invalid.');
end

% Define an output structure with empty fields
receivedFileEmptyFields = struct(  'mjdSocIngestTime', [], ...
                                   'filename',         '', ...
                                   'dispatcherType',   ''  );

% Define a structure of dispatcher type
dispatcherTypeArray = MatlabEnumFetcher.fetchEnum('gov.nasa.kepler.hibernate.dr.DispatchLog$DispatcherType');
for i=1:size(dispatcherTypeArray)
    dispatcherTypeStruct.(char(dispatcherTypeArray(i).name())) = dispatcherTypeArray(i);
end

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Retrieve an array of file logs
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

dbService = DatabaseServiceFactory.getInstance();
logCrud = LogCrud(dbService);
fileLogArray = [];

try
    fileLogArray = logCrud.retrieveAllFileLogs( dispatcherTypeStruct.(dispatcherType) ).toArray();
catch
    error('MATLAB:SBT:wrapper:retrieve_received_file:dataStoreReadException', ...
          'Exception in retrieving file logs from data store.');
end

% When the data retrieved is empty, output a structure with empty fields
if ( isempty(fileLogArray) )
    warning('MATLAB:SBT:wrapper:retrieve_received_file:outputStructWithEmptyFields', ...
            'No file logs found with the specified dispatcherType. A structure with empty fields is provided for output.');
    receivedFiles = receivedFileEmptyFields;
    SandboxTools.close;
    return
end

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Generate the output array of structures
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

iReceivedFile = 0;
receivedFiles = receivedFileEmptyFields;
for j = 1:length(fileLogArray)
    
    % Get one fileLog from the array and retrieve the corresponding dispatchLog and receiveLog
    fileLog          = fileLogArray(j);        
    dispatchLog      = fileLog.getDispatchLog();
    receiveLog       = dispatchLog.getReceiveLog();
    mjdSocIngestTime = ModifiedJulianDate.dateToMjd( receiveLog.getSocIngestTime() );
    
    % The retrieved SOC ingest time of the received file of the output should be within the specified time interval
    if ( mjdSocIngestTime>=startMjd && mjdSocIngestTime<=endMjd )
     
        iReceivedFile = iReceivedFile + 1;
        
        % Assign data to the corresponding fields of the array of structures for the output
        receivedFiles(iReceivedFile).mjdSocIngestTime   = mjdSocIngestTime;
        receivedFiles(iReceivedFile).filename           = char( fileLog.getFilename() );
        receivedFiles(iReceivedFile).dispatcherType     = char( dispatchLog.getDispatcherType().toString() );
        
    end

end  

% Clear Hibernate cache
dbService.clear();

SandboxTools.close;
return
