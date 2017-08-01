function receivedFiles = retrieve_all_received_files(startMjd, endMjd)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function receivedFiles = retrieve_all_received_files()
% or
% function receivedFiles = retrieve_all_received_files(startMjd, endMjd)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
% Retrieve filenames and properties of the files received by the data store within the specified time interval. 
%
% Inputs: 
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
%                           the set defined in the input argument dispatcherType from the tool retrieve_received_file.
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
    
    import gov.nasa.kepler.systest.sbt.SbtRetrieveAllReceivedFiles;
    sbt = SbtRetrieveAllReceivedFiles();
    
    if (nargin==0)
        pathJava = sbt.retrieveAllReceivedFiles();
    elseif (nargin==2)
        pathJava = sbt.retrieveAllReceivedFiles(startMjd, endMjd);
    else
        error('MATLAB:SBT:wrapper:retrieve_all_received_files:wrongNumberOfInputs', 'MATLAB:SBT:wrapper:retrieve_all_received_files: must be called with 0 or 2 input arguments.');
    end
    path = pathJava.toCharArray()';
    
    dataStruct = sbt_sdf_to_struct(path);

    if isempty(dataStruct)
        receivedFiles = [];
    else
        receivedFiles = dataStruct.allFiles;
    end
    
    SandboxTools.close;
return
