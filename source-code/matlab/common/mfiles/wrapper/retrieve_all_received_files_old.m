function allReceivedFiles = retrieve_all_received_files(startMjd, endMjd)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function allReceivedFiles = retrieve_all_received_files(startMjd, endMjd)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
% Retrieve filenames and properties of all types of files received by the data store within the specified time interval. 
%
% Inputs: 
%    startMjd                	MJD of the start of the specified time interval.
%    endMjd                  	MJD of the end of the specified time interval.
% 
% Output:
%    allReceivedFiles           A structure describing all received files.
%                               The structure contains the following fields:
%       .longPixel              Array of structures describing the received long cadence pixel data files.
%                               The structure contains the following fields:
%           .mjdSocIngestTime 	SOC ingest time in MJD of the file.
%           .filename           A string defining the filename of the file.
%           .dispatcherType   	A string defining the dispatcher type of the file.
%       .shortPixel             Array of structures describing the received short cadence pixel data files.
%                               The structure contains the same fields as longPixel.
%       .gapReport              Array of structures describing the 	received gap report files.
%                               The structure contains the same fields as longPixel.
%       .configMap              Array of structures describing the received	spacecraft configuration ID map files.
%                               The structure contains the same fields as longPixel.
%       .refPixel               Array of structures describing the received reference pixel data files.
%                               The structure contains the same fields as longPixel.
%       .longTargetPmrf 		Array of structures describing the received long cadence target pixel mapping table files.
%                               The structure contains the same fields as longPixel.
%       .shortTargetPmrf		Array of structures describing the received short cadence target pixel mapping table files.
%                               The structure contains the same fields as longPixel.
%       .backgroundPmrf         Array of structures describing the received background target pixel mapping table files.
%                               The structure contains the same fields as longPixel.
%       .longCollateralPmrf 	Array of structures describing the received long cadence collateral pixel mapping table files. 
%                               The structure contains the same fields as longPixel.
%       .shortCollateralPmrf	Array of structures describing the received short cadence collateral pixel mapping table files.
%                               The structure contains the same fields as longPixel.
%       .histogram              Array of structures describing the 	received compression histogram files.
%                               The structure contains the same fields as longPixel.
%       .ancillary              Array of structures describing the received	ancillary engineering data files.
%                               The structure contains the same fields as longPixel.
%       .spacecraftEphemeris    Array of structures describing the received	spacecraft ephemeris kernel files.
%                               The structure contains the same fields as longPixel.
%       .planetaryEphemeris     Array of structures describing the received	planetary ephemeris kernel files.
%                               The structure contains the same fields as longPixel.
%       .leapSeconds            Array of structures describing the received	leap seconds files.
%                               The structure contains the same fields as longPixel.
%       .sclk                   Array of structures describing the received	spacecraft clock kernel files.
%                               The structure contains the same fields as longPixel.		
%       .crct                   Array of structures describing the received cosmic ray correction table files. 
%                               The structure contains the same fields as longPixel.
%       .ffi                    Array of structures describing the received FFI data files.
%                               The structure contains the same fields as longPixel.
%       .history                Array of structures describing the received history	files.
%                               The structure contains the same fields as longPixel.	
%       .targetList             Array of structures describing the target list.
%                               The structure contains the same fields as longPixel.
%       .targetListSet          Array of structures describing the target list set.
%                               The structure contains the same fields as longPixel.
%       .maskTable              Array of structures describing the mask table.
%                               The structure contains the same fields as longPixel.
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
    error('MATLAB:SBT:wrapper:retrieve_all_received_files:wrongNumberOfInputs', 'MATLAB:SBT:wrapper:retrieve_all_received_files: must be called with 2 input arguments.');
end

sbt_validate_time_interval(startMjd, endMjd, 0, 'MATLAB:SBT:wrapper:retrieve_all_received_files:invalidInput');

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Retrieve all types of received files and generate output structure
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

dispatcherType = { 'LONG_CADENCE_PIXEL', 'SHORT_CADENCE_PIXEL', 'GAP_REPORT' 'CONFIG_MAP', 'REF_PIXEL', ...
                   'LONG_CADENCE_TARGET_PMRF', 'SHORT_CADENCE_TARGET_PMRF', 'BACKGROUND_PMRF', ...
                   'LONG_CADENCE_COLLATERAL_PMRF', 'SHORT_CADENCE_COLLATERAL_PMRF', 'HISTOGRAM', ...
                   'ANCILLARY', 'SPACECRAFT_EPHEMERIS', 'PLANETARY_EPHEMERIS', 'LEAP_SECONDS', ...
                   'SCLK', 'CRCT', 'FFI', 'HISTORY' 'TARGET_LIST' 'TARGET_LIST_SET' 'MASK_TABLE' };
fieldString    = { 'longPixel', 'shortPixel', 'gapReport', 'configMap', 'refPixel', ...
                   'longTargetPmrf', 'shortTargetPmrf', 'backgroundPmrf', ...
                   'longCollateralPmrf', 'shortCollateralPmrf', 'histogram', ...
                   'ancillary', 'spacecraftEphemeris', 'planetaryEphemeris' , 'leapSeconds', ...
                   'sclk', 'crct', 'ffi', 'history' 'targetList' 'targetListSet' 'maskTable' };

for i = 1:length(dispatcherType)               
    allReceivedFiles.(fieldString{i}) = retrieve_received_file( dispatcherType{i}, startMjd, endMjd );
end

return
