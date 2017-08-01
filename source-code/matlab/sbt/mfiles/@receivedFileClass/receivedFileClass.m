function receivedFileObject = receivedFileClass(receivedFiles)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function receivedFileObject = receivedFileClass(receivedFiles)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
% Construct a receivedFileObject from the results of retrieve_received_file
%
% Input: 
%   receivedFiles           1 x nReceivedFiles array of structures describing the received files.
%                           nReceivedFiles is the number of received files in the array.
%                           The structure contains the following fields:
%       .mjdSocIngestTime   SOC ingest time in MJD of the received file.
%       .filename           A string defining the filename of the received file.
%       .dispatcherType     A string defining the dispatcher type of the received file. 
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
%                               'EPHEMERIS'
%                               'SCLK'
%                               'CRCT'
%                               'FFI'
%                               'HISTORY'					}.
%
% Output:
%   receivedFileObject      An object of the received files.
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
    error('MATLAB:SBT:receivedFileClass:receivedFileClass:wrongNumberOfInputs', 'MATLAB:SBT:receivedFileClass:receivedFileClass: must be called with one input argument.');
end

if ( isempty(receivedFiles) )
    error('MATLAB:SBT:receivedFileClass:receivedFileClass:invalidInput', 'receivedFiles cannot be empty.');
end

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Sanity check on fields of each member of receivedFiles
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
                       
fieldsAndBounds = cell(3,4);
fieldsAndBounds( 1,:) = { 'mjdSocIngestTime';       '>= 54000'; '<= 64000'; []};
fieldsAndBounds( 2,:) = { 'filename';               [];         [];         []};
fieldsAndBounds( 3,:) = { 'dispatcherType';         [];         [];         {'LONG_CADENCE_PIXEL', 'SHORT_CADENCE_PIXEL', 'GAP_REPORT', 'CONFIG_MAP', 'REF_PIXEL', ...
                                                                             'LONG_CADENCE_TARGET_PMRF', 'SHORT_CADENCE_TARGET_PMRF', 'BACKGROUND_PRMF', ...
                                                                             'LONG_CADENCE_COLLATERAL_PMRF', 'SHORT_CADENCE_COLLATERAL_PMRF', 'HISTOGRAM', ...
                                                                             'ANCILLARY', 'EPHEMERIS', 'SCLK', 'CRCT', 'FFI', 'HISTORY'}};

% Take sanity check on each member of the array receivedFiles. The invalid members are deleted from the array.
indexInvalidFiles = [];
for iFile = 1:length(receivedFiles)
    try
        validate_structure(receivedFiles(iFile), fieldsAndBounds, ['MATLAB:SBT:receivedFileClass:receivedFileClass:receivedFile_' num2str(iFile)]);
    catch
        indexInvalidFiles = [indexInvalidFiles iFile];
        if (debugFlag)
            err = lasterror;
            error(err.identifier, err.message);
        end
    end
end
receivedFiles(indexInvalidFiles) = [];

if ( isempty(receivedFiles) || isempty([receivedFiles.mjdSocIngestTime]) )
    warning('Matlab:SBT:receivedFileClass:receivedFileClass:outputStructWithEmptyFields', ...
            'No valid data in receivedFiles. A receivedFileObject with empty fields is provided for output.');
end

% Construct a receivedFileObject
receivedFileObject = class(receivedFiles, 'receivedFileClass');

return


