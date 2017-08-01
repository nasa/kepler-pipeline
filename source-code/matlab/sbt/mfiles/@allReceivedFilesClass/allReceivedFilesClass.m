function allReceivedFilesObject = allReceivedFilesClass(allReceivedFiles)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function allReceivedFilesObject = allReceivedFilesClass(allReceivedFiles)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Construct an allReceivedFilesObject from the results of retrieve_all_received_files.
%
% Input: 
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
%
% Output:
%   allReceivedFilesObject    	An object of all received files.
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

debugFlag = 1;

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Validity check on input
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

if nargin~=1
    error('MATLAB:SBT:allReceivedFilesClass:allReceivedFilesClass:wrongNumberOfInputs', 'MATLAB:SBT:allReceivedFilesClass:allReceivedFilesClass: must be called with one input argument.');
end

if ( isempty(allReceivedFiles) )
    error('MATLAB:SBT:allReceivedFilesClass:allReceivedFilesClass:invalidInput', 'allReceivedFiles cannot be empty.');
end

dispatcherType = { 'LONG_CADENCE_PIXEL', 'SHORT_CADENCE_PIXEL', 'GAP_REPORT' 'CONFIG_MAP', 'REF_PIXEL', ...
                   'LONG_CADENCE_TARGET_PMRF', 'SHORT_CADENCE_TARGET_PMRF', 'BACKGROUND_PMRF', ...
                   'LONG_CADENCE_COLLATERAL_PMRF', 'SHORT_CADENCE_COLLATERAL_PMRF', 'HISTOGRAM', ...
                   'ANCILLARY', 'SPACECRAFT_EPHEMERIS', 'PLANETARY_EPHEMERIS', 'LEAP_SECONDS', ...
                   'SCLK', 'CRCT', 'FFI', 'HISTORY' };
fieldString    = { 'longPixel', 'shortPixel', 'gapReport', 'configMap', 'refPixel', ...
                   'longTargetPmrf', 'shortTargetPmrf', 'backgroundPmrf', ...
                   'longCollateralPmrf', 'shortCollateralPmrf', 'histogram', ...
                   'ancillary', 'spacecraftEphemeris', 'planetaryEphemeris' , 'leapSeconds', ...
                   'sclk', 'crct', 'ffi', 'history' };

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Top level validation
% Validate fields in allReceivedFiles
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
                       
nFields = length(fieldString);
               
fieldsAndBounds = cell(nFields,4);
for iField = 1:nFields
    fieldsAndBounds(iField,:) = { fieldString{iField};   [];    [];     [] };
end

validate_structure(allReceivedFiles, fieldsAndBounds, 'MATLAB:SBT:allReceivedFilesClass:allReceivedFilesClass:allReceivedFiles');

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Second level validation
% Validate fields in allReceivedFiles.longPixel
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
                      
fieldsAndBounds = cell(3,4);
fieldsAndBounds( 1,:) = { 'mjdSocIngestTime';  [];  [];  [] };
fieldsAndBounds( 2,:) = { 'filename';          [];  [];  [] };
fieldsAndBounds( 3,:) = { 'dispatcherType';    [];  [];  [] };

% Take sanity check on each member of the array receivedFiles. The invalid members are deleted from the array.
for iField = 1:nFields
    
    receivedFileTemp = allReceivedFiles.(fieldString{iField});

    indexInvalidFiles = [];
    for iFile = 1:length(receivedFileTemp)
        try
            validate_structure(receivedFileTemp(iFile), fieldsAndBounds, ...
                ['MATLAB:SBT:allReceivedFilesClass:allReceivedFilesClass:allReceivedFiles.' fieldString{iField} '_' num2str(iFile)]);
        catch
            indexInvalidFiles = [indexInvalidFiles iFile];
            if (debugFlag)
                err = lasterror;
                error(err.identifier, err.message);
            end
        end
    end
    
    receivedFileTemp(indexInvalidFiles) = [];
    allReceivedFiles.(fieldString{iField}) = receivedFileTemp;

end

fieldsAndBounds = cell(2,4);
fieldsAndBounds( 1,:) = { 'mjdSocIngestTime';  '>= 54000'; '<= 64000'; [] };

% Take sanity check on each member of the array receivedFiles. The invalid members are deleted from the array.
for iField = 1:nFields
    
    fieldsAndBounds( 2,:) = { 'dispatcherType';         [];         [];      { dispatcherType{iField} } };

    receivedFileTemp = allReceivedFiles.(fieldString{iField});

    if ( ~isempty(receivedFileTemp.dispatcherType) )
        indexInvalidFiles = [];
        for iFile = 1:length(receivedFileTemp)
            try
                validate_structure(receivedFileTemp(iFile), fieldsAndBounds, ...
                    ['MATLAB:SBT:allReceivedFilesClass:allReceivedFilesClass:allReceivedFiles.' fieldString{iField} '_' num2str(iFile)]);
            catch
                indexInvalidFiles = [indexInvalidFiles iFile];
                if (debugFlag)
                    err = lasterror;
                    error(err.identifier, err.message);
                end
            end
        end

        receivedFileTemp(indexInvalidFiles) = [];
        allReceivedFiles.(fieldString{iField}) = receivedFileTemp;
    end

end

isEmptyFlag = true;
for iField = 1:nFields
    isEmptyFlag = isEmptyFlag && ( isempty(allReceivedFiles.(fieldString{iField})) || ...
                                   isempty([allReceivedFiles.(fieldString{iField}).mjdSocIngestTime] ) );
end
if ( isEmptyFlag )
    warning('Matlab:SBT:allReceivedFilesClass:allReceivedFilesClass:outputStructWithEmptyFields', ...
        'No valid data in allReceivedFiles.  An allReceivedFilesObject with empty fields is provided for output.');
end

% Construct a receivedFileObject
allReceivedFilesObject = class(allReceivedFiles, 'allReceivedFilesClass');

return


