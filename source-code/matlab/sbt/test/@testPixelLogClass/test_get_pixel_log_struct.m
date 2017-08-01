function self = test_get_pixel_log_struct(self)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function self = test_get_pixel_log_struct(self)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% This method tests the function get_pixel_log_struct.
%
%  Example
%  =======
%  Use a test runner to run the test method:
%      run(text_test_runner, testPixelLogClass('test_get_pixel_log_struct'));
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
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

display('Test function get_pixel_log_struct');

messageOut = 'Test failed - The retrieved data and the expected data are not identical!';

pixelLogEmptyFields = struct('cadenceNumber',                               [], ...
                             'cadenceType',                                 '', ...
                             'dataSetType',                                 '', ...
                             'dispatcherType',                              '', ...
                             'fitsFilename',                                '', ...
                             'dataSetName',                                 '', ...
                             'mjdStartTime',                                [], ... 
                             'mjdEndTime',                                  [], ...
                             'mjdMidTime',                                  [], ...
                             'spacecraftConfigId',                          [], ...
                             'lcTargetTableId',                             [], ...
                             'scTargetTableId',                             [], ...
                             'backTargetTableId',                           [], ...
                             'targetApertureTableId',                       [], ...
                             'backApertureTableId',                         [], ...
                             'compressionTableId',                          [], ...
                             'isDataRequantizedForDownlink',                [], ...
                             'isDataEntropicCompressedForDownlink',         [], ...
                             'isDataOriginatedAsBaselineImage',             [], ...
                             'isBaselineCreatedFromResidualBaselineImage',  [], ...
                             'baselineImageRootname',                       '', ...
                             'residualBaselineImageRootname',               '');   

% Case 1: time interval specified by cadence numbers

isLongCadence = 1;
startCadence = 0;
endCadence   = 100;
isInputCadenceNumber = 1;
retrievedPixelLogsA = retrieve_pixel_log(isLongCadence, startCadence, endCadence, isInputCadenceNumber);
pixelLogObjectA = pixelLogClass(retrievedPixelLogsA);

pixelLogStructA1 = get_pixel_log_struct(pixelLogObjectA);
assert_equals(length([pixelLogStructA1.cadenceNumber]), 101*3, messageOut);
assert_equals(length(fieldnames(pixelLogStructA1(1))), 22, messageOut);

pixelLogStructA2 = get_pixel_log_struct(pixelLogObjectA, 91, 120, 1);
assert_equals(length([pixelLogStructA2.cadenceNumber]), 10*3, messageOut);
assert_equals(length(fieldnames(pixelLogStructA2(1))), 22, messageOut);

pixelLogStructA3 = get_pixel_log_struct(pixelLogObjectA, 91, 120, 1, {'cadenceNumber' 'cadenceType' 'mjdMidTime' 'dataSetName'});
assert_equals(length([pixelLogStructA3.cadenceNumber]), 10*3, messageOut);
assert_equals(length(fieldnames(pixelLogStructA3(1))), 4, messageOut);

pixelLogStructA4 = get_pixel_log_struct(pixelLogObjectA, 91, 120, 1, {'cadenceNumber' 'cadenceType' 'invalidField' 'mjdMidTime' 'dataSetName'});
assert_equals(length([pixelLogStructA4.cadenceNumber]), 10*3, messageOut);
assert_equals(length(fieldnames(pixelLogStructA4(1))), 4, messageOut);

pixelLogStructA5 = get_pixel_log_struct(pixelLogObjectA, 101, 120, 1, {'cadenceNumber' 'cadenceType' 'mjdMidTime' 'dataSetName'});
assert_equals(pixelLogStructA5, pixelLogEmptyFields, messageOut);

pixelLogStructA6 = get_pixel_log_struct(pixelLogObjectA, 91, 120, 1, {'invalidField1' 'invalidField2'});
assert_equals(pixelLogStructA6, pixelLogEmptyFields, messageOut);

% Case 2: time interval specified by MJDs

isLongCadence = 1;
startMjd = 55555;
%startMjd = 55415;
endMjd   = startMjd + 1;
isInputCadenceNumber = 0;
retrievedPixelLogsB = retrieve_pixel_log(isLongCadence, startMjd, endMjd, isInputCadenceNumber);
pixelLogObjectB = pixelLogClass(retrievedPixelLogsB);

pixelLogStructB1 = get_pixel_log_struct(pixelLogObjectB);
assert_equals(length([pixelLogStructB1.cadenceNumber]), 49*3, messageOut);
assert_equals(length(fieldnames(pixelLogStructB1(1))), 22, messageOut);

pixelLogStructB2 = get_pixel_log_struct(pixelLogObjectB, startMjd+0.5, startMjd+1.5, 0);
assert_equals(length([pixelLogStructB2.cadenceNumber]), 25*3, messageOut);
assert_equals(length(fieldnames(pixelLogStructB2(1))), 22, messageOut);

pixelLogStructB3 = get_pixel_log_struct(pixelLogObjectB, startMjd+0.5, startMjd+1.5, 0, {'cadenceNumber' 'cadenceType' 'mjdMidTime' 'dataSetName'});
assert_equals(length([pixelLogStructB3.cadenceNumber]), 25*3, messageOut);
assert_equals(length(fieldnames(pixelLogStructB3(1))), 4, messageOut);

pixelLogStructB4 = get_pixel_log_struct(pixelLogObjectB, startMjd+0.5, startMjd+1.5, 0, {'cadenceNumber' 'cadenceType' 'invalidField' 'mjdMidTime' 'dataSetName'});
assert_equals(length([pixelLogStructB4.cadenceNumber]), 25*3, messageOut);
assert_equals(length(fieldnames(pixelLogStructB4(1))), 4, messageOut);

pixelLogStructB5 = get_pixel_log_struct(pixelLogObjectB, startMjd+1.5, startMjd+2.5, 0, {'cadenceNumber' 'cadenceType' 'mjdMidTime' 'dataSetName'});
assert_equals(pixelLogStructB5, pixelLogEmptyFields, messageOut);

pixelLogStructB6 = get_pixel_log_struct(pixelLogObjectB, startMjd+0.5, startMjd+1.5, 0, {'invalidField1' 'invalidField2'});
assert_equals(pixelLogStructB6, pixelLogEmptyFields, messageOut);

% Case 3: time interval not specified

isLongCadence = 1;
retrievedPixelLogsC = retrieve_pixel_log(isLongCadence);
pixelLogObjectC = pixelLogClass(retrievedPixelLogsC);

pixelLogStructC1 = get_pixel_log_struct(pixelLogObjectC, 101, 120, 1);
assert_equals(length([pixelLogStructC1.cadenceNumber]), 20*3, messageOut);
assert_equals(length(fieldnames(pixelLogStructC1(1))), 22, messageOut);

pixelLogStructC2 = get_pixel_log_struct(pixelLogObjectC, 101, 120, 1, {'cadenceNumber' 'cadenceType' 'mjdMidTime' 'dataSetName'});
assert_equals(length([pixelLogStructC2.cadenceNumber]), 20*3, messageOut);
assert_equals(length(fieldnames(pixelLogStructC2(1))), 4, messageOut);

pixelLogStructC3 = get_pixel_log_struct(pixelLogObjectC, startMjd+0.5, startMjd+1.5, 0);
assert_equals(length([pixelLogStructC3.cadenceNumber]), 49*3, messageOut);
assert_equals(length(fieldnames(pixelLogStructC3(1))), 22, messageOut);

pixelLogStructC4 = get_pixel_log_struct(pixelLogObjectC, startMjd+0.5, startMjd+1.5, 0, {'cadenceNumber' 'cadenceType' 'mjdMidTime' 'dataSetName'});
assert_equals(length([pixelLogStructC4.cadenceNumber]), 49*3, messageOut);
assert_equals(length(fieldnames(pixelLogStructC4(1))), 4, messageOut);

return
