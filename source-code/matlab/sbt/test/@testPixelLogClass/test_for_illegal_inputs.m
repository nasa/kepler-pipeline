function self = test_for_illegal_inputs(self)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function self = test_for_illegal_inputs(self)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% This method tests the pixel log extractor for illegal inputs.
%
%  Example
%  =======
%  Use a test runner to run the test method:
%      run(text_test_runner, testPixelLogClass('test_for_illegal_inputs'));
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

display('Test pixel log extractor for illegal inputs');

messageOut = 'Test failed - Error was not caught for illegal inputs!';

% Test MATLAB wrapper for illegal inputs

for iTest=1:18

    try
        % Ignore the returned value
        switch (iTest)
            case 1                              % illegal isLongCadence
                isLongCadence = 2;
                startCadence = 1;
                endCadence   = 10;
                isInputCadenceNumber = 1;
                retrievedPixelLogs = retrieve_pixel_log(isLongCadence, startCadence, endCadence, isInputCadenceNumber);
            case 2                              % illegal isLongCadence
                isLongCadence = 2;
                startMjd = 55553.0;
                endMjd   = 55563.0;
                isInputCadenceNumber = 0;
                retrievedPixelLogs = retrieve_pixel_log(isLongCadence, startMjd, endMjd, isInputCadenceNumber);
            case 3                              % startCadence is a vector
                isLongCadence = 1;
                startCadence = [1 2];
                endCadence   = 10;
                isInputCadenceNumber = 1;
                retrievedPixelLogs = retrieve_pixel_log(isLongCadence, startCadence, endCadence, isInputCadenceNumber);
            case 4                              % endCadence is a vector
                isLongCadence = 1;
                startCadence = 1;
                endCadence   = [10 11];
                isInputCadenceNumber = 1;
                retrievedPixelLogs = retrieve_pixel_log(isLongCadence, startCadence, endCadence, isInputCadenceNumber);
            case 5                              % startCadence is negative
                isLongCadence = 1;
                startCadence = -1;
                endCadence   = 10;
                isInputCadenceNumber = 1;
                retrievedPixelLogs = retrieve_pixel_log(isLongCadence, startCadence, endCadence, isInputCadenceNumber);
            case 6                              % endCadence is negative
                isLongCadence = 1;
                startCadence = 1;
                endCadence   = -10;
                isInputCadenceNumber = 1;
                retrievedPixelLogs = retrieve_pixel_log(isLongCadence, startCadence, endCadence, isInputCadenceNumber);
            case 7                              % startCadence is too large
                isLongCadence = 1;
                startCadence = 1e12+1;
                endCadence   = 1e12+10;
                isInputCadenceNumber = 1;
                retrievedPixelLogs = retrieve_pixel_log(isLongCadence, startCadence, endCadence, isInputCadenceNumber);
            case 8                              % endCadence is too large
                isLongCadence = 1;
                startCadence = 1;
                endCadence   = 1e12+10;
                isInputCadenceNumber = 1;
                retrievedPixelLogs = retrieve_pixel_log(isLongCadence, startCadence, endCadence, isInputCadenceNumber);
            case 9                              % startCadence is greater than endCadence
                isLongCadence = 1;
                startCadence = 10;
                endCadence   = 1;
                isInputCadenceNumber = 1;
                retrievedPixelLogs = retrieve_pixel_log(isLongCadence, startCadence, endCadence, isInputCadenceNumber);
            case 10                             % startMjd is a vector
                isLongCadence = 1;
                startMjd = [55553.0 55553.5];
                endMjd   = 55563.0;
                isInputCadenceNumber = 0;
                retrievedPixelLogs = retrieve_pixel_log(isLongCadence, startMjd, endMjd, isInputCadenceNumber);
            case 11                             % endMjd is a vector
                isLongCadence = 1;
                startMjd = 55553.0;
                endMjd   = [55563.0 55563.5];
                isInputCadenceNumber = 0;
                retrievedPixelLogs = retrieve_pixel_log(isLongCadence, startMjd, endMjd, isInputCadenceNumber);
            case 12                             % startMjd is negative
                isLongCadence = 1;
                startMjd = -55553.0;
                endMjd   =  55563.0;
                isInputCadenceNumber = 0;
                retrievedPixelLogs = retrieve_pixel_log(isLongCadence, startMjd, endMjd, isInputCadenceNumber);
            case 13                             % endMjd is negative
                isLongCadence = 1;
                startMjd =  55553.0;
                endMjd   = -55563.0;
                isInputCadenceNumber = 0;
                retrievedPixelLogs = retrieve_pixel_log(isLongCadence, startMjd, endMjd, isInputCadenceNumber);
            case 14                             % startMjd is too large
                isLongCadence = 1;
                startMjd =  65553.0;
                endMjd   =  65563.0;
                isInputCadenceNumber = 0;
                retrievedPixelLogs = retrieve_pixel_log(isLongCadence, startMjd, endMjd, isInputCadenceNumber);
            case 15                             % endMjd is too large
                isLongCadence = 1;
                startMjd =  55553.0;
                endMjd   =  65563.0;
                isInputCadenceNumber = 0;
                retrievedPixelLogs = retrieve_pixel_log(isLongCadence, startMjd, endMjd, isInputCadenceNumber);
            case 16                             % startMjd is greater than endMjd
                isLongCadence = 1;
                startMjd = 55563.0;
                endMjd   = 55553.0;
                isInputCadenceNumber = 0;
                retrievedPixelLogs = retrieve_pixel_log(isLongCadence, startMjd, endMjd, isInputCadenceNumber);
            case 17                             % illegal isInputCadenceNumber
                isLongCadence = 1;
                startCadence = 1;
                endCadence   = 10;
                isInputCadenceNumber = 2;
                retrievedPixelLogs = retrieve_pixel_log(isLongCadence, startCadence, endCadence, isInputCadenceNumber);
            case 18                             % illegal isInputCadenceNumber
                isLongCadence = 1;
                startMjd = 55553.0;
                endMjd   = 55563.0;
                isInputCadenceNumber = 2;
                retrievedPixelLogs = retrieve_pixel_log(isLongCadence, startMjd, endMjd, isInputCadenceNumber);
        end
    catch
        % Test passed, input validation failed
        err = lasterror;
        if( isempty(findstr(err.identifier, 'invalidInput')) )
            assert_equals(1, 0, messageOut);
        end
    end

end

% Test pixelLogClass constructor for illegal inputs

isLongCadence = 1;
pixelLogs = retrieve_pixel_log(isLongCadence);
pixelLog  = pixelLogs(1);

fieldsAndBounds = cell(18,4);
fieldsAndBounds( 1,:) = { 'cadenceNumber';          '>= 0';     '< 1e12';   []};
fieldsAndBounds( 2,:) = { 'cadenceType';            [];         [];         {'SHORT', 'LONG'}};
fieldsAndBounds( 3,:) = { 'dataSetType';         	[];         [];         {'Target', 'Background', 'Collateral'}};
fieldsAndBounds( 4,:) = { 'dispatcherType';         [];         [];         {'LONG_CADENCE_PIXEL', 'SHORT_CADENCE_PIXEL', 'GAP_REPORT', 'CONFIG_MAP', 'REF_PIXEL', ...
                                                                             'LONG_CADENCE_TARGET_PMRF', 'SHORT_CADENCE_TARGET_PMRF', 'BACKGROUND_PRMF', ...
                                                                             'LONG_CADENCE_COLLATERAL_PMRF', 'SHORT_CADENCE_COLLATERAL_PMRF', 'HISTOGRAM', ...
                                                                             'ANCILLARY', 'EPHEMERIS', 'SCLK', 'CRCT', 'FFI', 'HISTORY'}};
fieldsAndBounds( 5,:) = { 'mjdStartTime';           '>= 54000'; '<= 64000'; []};
fieldsAndBounds( 6,:) = { 'mjdEndTime';             '>= 54000'; '<= 64000'; []};
fieldsAndBounds( 7,:) = { 'mjdMidTime';             '>= 54000'; '<= 64000'; []};
fieldsAndBounds( 8,:) = { 'spacecraftConfigId';     '>= 0';     '< 1e12';   []};
fieldsAndBounds( 9,:) = { 'lcTargetTableId';        '>= 0';     '< 1e12';   []};
fieldsAndBounds(10,:) = { 'scTargetTableId';        '>= 0';     '< 1e12';   []};
fieldsAndBounds(11,:) = { 'backTargetTableId';      '>= 0';     '< 1e12';   []};
fieldsAndBounds(12,:) = { 'targetApertureTableId';  '>= 0';     '< 1e12';   []};
fieldsAndBounds(13,:) = { 'backApertureTableId';    '>= 0';     '< 1e12';   []};
fieldsAndBounds(14,:) = { 'compressionTableId';     '>= 0';     '< 1e12';   []};
fieldsAndBounds(15,:) = { 'isDataRequantizedForDownlink';                   [];     [];     '[1 0]'''};
fieldsAndBounds(16,:) = { 'isDataEntropicCompressedForDownlink';            [];     [];     '[1 0]'''};
fieldsAndBounds(17,:) = { 'isDataOriginatedAsBaselineImage';                [];     [];     '[1 0]'''};
fieldsAndBounds(18,:) = { 'isBaselineCreatedFromResidualBaselineImage';     [];     [];     '[1 0]'''};
assign_illegal_value_and_test_for_failure(pixelLog, 'pixelLog', pixelLog, 'pixelLog', 'pixelLogClass', fieldsAndBounds);

return
