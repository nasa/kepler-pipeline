function [self] = test_get_readout_offset(self)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% [self] = test_get_readout_offset(self)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
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

% Constants
FGSFRPER = 103.79;
MILLISECOND_TO_SECOND = 1/1000;
SECOND_TO_DAY = get_unit_conversion('sec2day');

% Initialize soc variables
initialize_soc_variables

% Load a struct with 1 configMap, called configMap1, and instantiate into configMap object
configMap1FullPath = [socTestDataRoot filesep 'common' filesep 'configMap' filesep 'configMap_1_struct.mat'];
eval(['load ' configMap1FullPath])

% Load fcConstants from mat file, variable is called fcConstantsStruct
fcConstantsFullPath = [socTestDataRoot filesep 'common' filesep 'fcConstants' filesep 'fcConstants.mat'];
eval(['load ' fcConstantsFullPath])
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Test outputs when ccdModule = 3, 10, 12, 19
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
expectedSlice = 1;
expectedOffset = (2.5*FGSFRPER + 6*FGSFRPER*(5-expectedSlice))*MILLISECOND_TO_SECOND*SECOND_TO_DAY;

for ccdModule  = [ 3, 10, 12, 19 ]
    errorMessageOffset =  sprintf('Wrong readout offset for ccdModule %d', ccdModule);
    errorMessageSlice = sprintf('Wrong slice identified %d', expectedSlice);
    [readoutOffsetDays, nSlice] = get_readout_offset(configMap1, ccdModule, fcConstantsStruct);
    fprintf('ccdModule %d, Offset %1.4f (sec), timeSlice %d\n', ccdModule, readoutOffsetDays/SECOND_TO_DAY, nSlice)
    assert_equals(readoutOffsetDays, expectedOffset, errorMessageOffset);
    assert_equals(nSlice, expectedSlice, errorMessageSlice);

end

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Test outputs when ccdModule = 8, 15, 17, 24
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
expectedSlice = 2;
expectedOffset = (2.5*FGSFRPER + 6*FGSFRPER*(5-expectedSlice))*MILLISECOND_TO_SECOND*SECOND_TO_DAY;

for ccdModule  = [ 8, 15, 17, 24 ]
    errorMessageOffset =  sprintf('Wrong readout offset for ccdModule %d', ccdModule);
    errorMessageSlice = sprintf('Wrong slice identified %d', expectedSlice);
    [readoutOffsetDays, nSlice] = get_readout_offset(configMap1, ccdModule, fcConstantsStruct);
    fprintf('ccdModule %d, Offset %1.4f (sec), timeSlice %d\n', ccdModule, readoutOffsetDays/SECOND_TO_DAY, nSlice)
    assert_equals(readoutOffsetDays, expectedOffset, errorMessageOffset);
    assert_equals(nSlice, expectedSlice, errorMessageSlice);

end

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Test outputs when ccdModule = 4, 6, 13, 20, 22
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
expectedSlice = 3;
expectedOffset = (2.5*FGSFRPER + 6*FGSFRPER*(5-expectedSlice))*MILLISECOND_TO_SECOND*SECOND_TO_DAY;

for ccdModule  = [ 4, 6, 13, 20, 22 ]
    errorMessageOffset =  sprintf('Wrong readout offset for ccdModule %d', ccdModule);
    errorMessageSlice = sprintf('Wrong slice identified %d', expectedSlice);
    [readoutOffsetDays, nSlice] = get_readout_offset(configMap1, ccdModule, fcConstantsStruct);
    fprintf('ccdModule %d, Offset %1.4f (sec), timeSlice %d\n', ccdModule, readoutOffsetDays/SECOND_TO_DAY, nSlice)
    assert_equals(readoutOffsetDays, expectedOffset, errorMessageOffset);
    assert_equals(nSlice, expectedSlice, errorMessageSlice);

end

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Test outputs when ccdModule = 2, 9, 11, 18
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
expectedSlice = 4;
expectedOffset = (2.5*FGSFRPER + 6*FGSFRPER*(5-expectedSlice))*MILLISECOND_TO_SECOND*SECOND_TO_DAY;

for ccdModule  = [ 2, 9, 11, 18 ]
    errorMessageOffset =  sprintf('Wrong readout offset for ccdModule %d', ccdModule);
    errorMessageSlice = sprintf('Wrong slice identified %d', expectedSlice);
    [readoutOffsetDays, nSlice] = get_readout_offset(configMap1, ccdModule, fcConstantsStruct);
    fprintf('ccdModule %d, Offset %1.4f (sec), timeSlice %d\n', ccdModule, readoutOffsetDays/SECOND_TO_DAY, nSlice)
    assert_equals(readoutOffsetDays, expectedOffset, errorMessageOffset);
    assert_equals(nSlice, expectedSlice, errorMessageSlice);

end

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Test outputs when ccdModule = 7, 14, 16, 23
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
expectedSlice = 5;
expectedOffset = (2.5*FGSFRPER + 6*FGSFRPER*(5-expectedSlice))*MILLISECOND_TO_SECOND*SECOND_TO_DAY;

for ccdModule  = [ 7, 14, 16, 23 ]
    errorMessageOffset =  sprintf('Wrong readout offset for ccdModule %d', ccdModule);
    errorMessageSlice = sprintf('Wrong slice identified %d', expectedSlice);
    [readoutOffsetDays, nSlice] = get_readout_offset(configMap1, ccdModule, fcConstantsStruct);
    fprintf('ccdModule %d, Offset %1.4f (sec), timeSlice %d\n', ccdModule, readoutOffsetDays/SECOND_TO_DAY, nSlice)
    assert_equals(readoutOffsetDays, expectedOffset, errorMessageOffset);
    assert_equals(nSlice, expectedSlice, errorMessageSlice);

end
