function self = test_get_received_file_struct(self)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function self = test_get_received_file_struct(self)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% This method tests the function get_received_file_struct.
%
%  Example
%  =======
%  Use a test runner to run the test method:
%      run(text_test_runner, testReceivedFileClass('test_get_received_file_struct'));
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

display('Test function get_received_file_struct');

messageOut = 'Test failed - The retrieved data and the expected data are not identical!';

receivedFileEmptyFields = struct(  'mjdSocIngestTime', [], ...
                                   'filename',         '', ...
                                   'dispatcherType',   ''  );
                               
% Case 1: time interval specified

dispatcherType = 'CONFIG_MAP';
startMjd =  54620.0;
endMjd   =  54625.0;
%startMjd =  54605.0;
%endMjd   =  54610.0;
retrievedReceivedFilesA = retrieve_received_file(dispatcherType, startMjd, endMjd);
receivedFileObjectA = receivedFileClass(retrievedReceivedFilesA);

receivedFileStructA1 = get_received_file_struct(receivedFileObjectA);
assert_equals(length([receivedFileStructA1.mjdSocIngestTime]), 1, messageOut);
assert_equals(length(fieldnames(receivedFileStructA1(1))), 3, messageOut);

receivedFileStructA2 = get_received_file_struct(receivedFileObjectA, startMjd, endMjd);
assert_equals(length([receivedFileStructA2.mjdSocIngestTime]), 1, messageOut);
assert_equals(length(fieldnames(receivedFileStructA2(1))), 3, messageOut);

receivedFileStructA3 = get_received_file_struct(receivedFileObjectA, startMjd, endMjd, {'mjdSocIngestTime' 'filename'});
assert_equals(length([receivedFileStructA3.mjdSocIngestTime]), 1, messageOut);
assert_equals(length(fieldnames(receivedFileStructA3(1))), 2, messageOut);

receivedFileStructA4 = get_received_file_struct(receivedFileObjectA, startMjd, endMjd, {'mjdSocIngestTime' 'invalidField' 'filename'});
assert_equals(length([receivedFileStructA4.mjdSocIngestTime]), 1, messageOut);
assert_equals(length(fieldnames(receivedFileStructA4(1))), 2, messageOut);

receivedFileStructA5 = get_received_file_struct(receivedFileObjectA, startMjd+5, endMjd+5, {'mjdSocIngestTime' 'filename'});
assert_equals(receivedFileStructA5, receivedFileEmptyFields, messageOut);

receivedFileStructA6 = get_received_file_struct(receivedFileObjectA, startMjd, endMjd, {'invalidField1' 'invalidField2'});
assert_equals(receivedFileStructA6, receivedFileEmptyFields, messageOut);

% Case 2: time interval not specified

dispatcherType = 'CONFIG_MAP';
retrievedReceivedFilesB = retrieve_received_file(dispatcherType);
receivedFileObjectB = receivedFileClass(retrievedReceivedFilesB);

receivedFileStructB1 = get_received_file_struct(receivedFileObjectB, startMjd, endMjd, {'mjdSocIngestTime' 'filename'});
assert_equals(length([receivedFileStructB1.mjdSocIngestTime]), 1, messageOut);
assert_equals(length(fieldnames(receivedFileStructB1(1))), 2, messageOut);

return
