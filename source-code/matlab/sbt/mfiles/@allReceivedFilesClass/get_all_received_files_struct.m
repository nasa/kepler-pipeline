function allReceivedFilesStruct = get_all_received_files_struct(allReceivedFilesObject, dispatcherTypes)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function allReceivedFilesStruct = get_all_received_files_struct(allReceivedFilesObject)
% or
% function allReceivedFilesStruct = get_all_received_files_struct(allReceivedFilesObject, dispatcherTypes)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
% Get the values of the specified fields of allReceivedFileObject.
%
% Inputs:
%    allReceivedFileObject     	An object of all received files. 
%    dispatcherTypes          	Optional. An array of strings defining the dispatcher types of the received files.
%                            	A valid string should be a member of the following set
%                            	{   'LONG_CADENCE_PIXEL'
%                                	'SHORT_CADENCE_PIXEL'
%                                	'GAP_REPORT'
%                                	'CONFIG_MAP'
%                                	'REF_PIXEL'
%                                	'LONG_CADENCE_TARGET_PMRF'
%                                	'SHORT_CADENCE_TARGET_PMRF'
%                                	'BACKGROUND_PRMF'
%                                	'LONG_CADENCE_COLLATERAL_PMRF'
%                                	'SHORT_CADENCE_COLLATERAL_PMRF'
%                                	'HISTOGRAM'
%                                	'ANCILLARY'
%                                	'SPACECRAFT_EPHEMERIS'
%                                	'PLANETARY_EPHEMERIS'
%                                	'LEAP_SECONDS'
%                                	'SCLK'
%                                	'CRCT'
%                                	'FFI'
%                                	'HISTORY'                       }.
%                               If 'dispatcherTypes' is not specified, all types of available received files are provided for output.  
%                                                           
% Output:
%    allReceivedFileStruct     	A structure describing all received files.
%                               It contains all or some of the following fields:
%       .longPixel              Array of structures describing the received long cadence pixel data files.
%                               The structure contains the following fields:
%           .mjdSocIngestTime 	SOC ingest time in MJD of the file.
%           .filename           A string defining the filename of the file.
%           .dispatcherType   	A string defining the dispatcher type of the file.
%                               It can be any member of the set defined in 'dispatcherTypes' of inputs.
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

if ~( nargin==1 || nargin==2 )
    error('MATLAB:SBT:receivedFileClass:get_received_file_struct:wrongNumberOfInputs', ...
          'MATLAB:SBT:receivedFileClass:get_received_file_struct: must be called with 1 or 2 input arguments.');
end

% Define a structure with empty fields
allReceivedFilesEmptyFields = struct('longPixel',           [], ...
                                     'shortPixel',          [], ...
                                     'gapReport',           [], ...
                                     'configMap',           [], ...
                                     'refPixel',            [], ...
                                     'longTargetPmrf',      [], ...
                                     'shortTargetPmrf',     [], ...
                                     'backgroundPmrf',      [], ...
                                     'longCollateralPmrf',  [], ...
                                     'shortCollateralPmrf', [], ...
                                     'histogram',           [], ...
                                     'ancillary',           [], ...
                                     'spacecraftEphemeris', [], ...
                                     'planetaryEphemeris',  [], ...
                                     'leapSeconds',         [], ...
                                     'sclk',                [], ...
                                     'crct',                [], ...
                                     'ffi',                 [], ...
                                     'history',             []);
                         
if ( isempty(allReceivedFilesObject) )
    error('MATLAB:SBT:receivedFileClass:get_received_file_struct:invalidInput', 'receivedFileObject cannot be empty.');
end

allTypes    = { 'LONG_CADENCE_PIXEL' 'SHORT_CADENCE_PIXEL' 'GAP_REPORT' 'CONFIG_MAP' 'REF_PIXEL' ...
                'LONG_CADENCE_TARGET_PMRF' 'SHORT_CADENCE_TARGET_PMRF' 'BACKGROUND_PMRF' ...
                'LONG_CADENCE_COLLATERAL_PMRF' 'SHORT_CADENCE_COLLATERAL_PMRF' 'HISTOGRAM' ...
                'ANCILLARY' 'SPACECRAFT_EPHEMERIS' 'PLANETARY_EPHEMERIS' 'LEAP_SECONDS' ...
                'SCLK' 'CRCT' 'FFI' 'HISTORY'};
fieldString = { 'longPixel', 'shortPixel', 'gapReport', 'configMap', 'refPixel', ...
                'longTargetPmrf', 'shortTargetPmrf', 'backgroundPmrf', ...
                'longCollateralPmrf', 'shortCollateralPmrf', 'histogram', ...
                'ancillary', 'spacecraftEphemeris', 'planetaryEphemeris' , 'leapSeconds', ...
                'sclk', 'crct', 'ffi', 'history' };

isAllTypes = 1;
validTypes = allTypes;

if ( exist('dispatcherTypes', 'var') && ~isempty (dispatcherTypes) )
    isAllTypes = 0;
    k = 0;
    validTypes = [];
    for i=1:length(dispatcherTypes)
        if ( ismember(dispatcherTypes{i}, allTypes) )
            k = k + 1;
            validTypes{1, k} = dispatcherTypes{i};
        else
            warning('MATLAB:SBT:allReceivedFilesClass:get_all_received_files_struct:invalidInput', ...
                ['Specified dispatcherType "' dispatcherTypes{i} '" is invalid.']);
        end
    end
end


%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Generate the output structure
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

if ( isempty(validTypes) )
    warning('MATLAB:SBT:receivedFileClass:get_received_file_struct:outputStructWithEmptyFields', ...
            'No valid fields found in the specified "fields". A structure with empty fields is provided for output.');
    allReceivedFilesStruct = allReceivedFilesEmptyFields;
    return
end

if ( isAllTypes==1 )
    allReceivedFilesStruct = struct(allReceivedFilesObject);
else
    for iField = 1:length(allTypes)
        if ( ~isempty( strmatch( allTypes{iField}, validTypes, 'exact' ) ) )
            allReceivedFilesStruct.(fieldString{iField}) = allReceivedFilesObject.(fieldString{iField});
        end
    end
end

return
