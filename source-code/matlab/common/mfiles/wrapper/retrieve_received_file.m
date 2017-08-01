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
    
    import gov.nasa.kepler.systest.sbt.SbtRetrieveReceivedFile;
    sbt = SbtRetrieveReceivedFile();
    
    if (nargin==1)
        pathJava = sbt.retrieveReceivedFile(dispatcherType);
    elseif (nargin==3)
        pathJava = sbt.retrieveReceivedFile(dispatcherType, startMjd, endMjd);
    else
        error('MATLAB:SBT:wrapper:retrieve_received_file:wrongNumberOfInputs', 'MATLAB:SBT:wrapper:retrieve_received_file: must be called with 1 or 3 input arguments.');
    end
    path = pathJava.toCharArray()';
    
    receivedFiles = sbt_sdf_to_struct(path);
    if ~isempty(receivedFiles)
        receivedFiles = receivedFiles.sbtReceivedFiles;
    else
        receivedFiles = [];
    end
    
    SandboxTools.close;
return
