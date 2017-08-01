function self = test_for_illegal_inputs(self)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function self = test_for_illegal_inputs(self)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% This method tests the configuration ID map extractor for illegal inputs.
%
%  Example
%  =======
%  Use a test runner to run the test method:
%      run(text_test_runner, testConfigMapClass('test_for_illegal_inputs'));
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

display('Test configuration ID map extractor for illegal inputs');

messageOut = 'Test failed - Error was not caught for illegal inputs!';

% Test MATLAB wrapper for illegal inputs

for iTest=1:13

    try
        % Ignore the returned value
        switch (iTest)
            case 1                              % startMjd is a vector
                startMjd = [55295.0 55296.0];
                endMjd   = 55300.0;
                retrievedConfigMaps = retrieve_config_map(startMjd, endMjd);
            case 2                              % endMjd is a vector
                startMjd = 55295.0;
                endMjd   = [55300.0 55301.0];
                retrievedConfigMaps = retrieve_config_map(startMjd, endMjd);
            case 3                             % startMjd is neagtive
                startMjd = -55295.0;
                endMjd   =  55300.0;
                retrievedConfigMaps = retrieve_config_map(startMjd, endMjd);
            case 4                             % endMjd is negative
                startMjd =  55295.0;
                endMjd   = -55300.0;
                retrievedConfigMaps = retrieve_config_map(startMjd, endMjd);
            case 5                             % startMjd is too large
                startMjd =  65295.0;
                endMjd   =  65300.0;
                retrievedConfigMaps = retrieve_config_map(startMjd, endMjd);
            case 6                             % endMjd is too large
                startMjd =  55295.0;
                endMjd   =  65300.0;
                retrievedConfigMaps = retrieve_config_map(startMjd, endMjd);
            case 7                             % startMjd is greater than endMjd
                startMjd =  55300.0;
                endMjd   =  55295.0;
                retrievedConfigMaps = retrieve_config_map(startMjd, endMjd);
            case 8                             % mjd is a vector
                mjd =  [55300.0 55301.0];
                retrievedConfigMaps = retrieve_config_map(mjd);
            case 9                             % mjd is too small
                mjd = 53300.0;
                retrievedConfigMaps = retrieve_config_map(mjd);
            case 10                            % mjd is too large
                mjd = 65300.0;
                retrievedConfigMaps = retrieve_config_map(mjd);
            case 11                            % scConfigId is a vector
                scConfigId = [1 2];
                retrievedConfigMap  = retrieve_config_map_by_id(scConfigId);
            case 12                            % scConfigId is negative
                scConfigId = -1;
                retrievedConfigMap  = retrieve_config_map_by_id(scConfigId);
            case 13                            % scConfigId is too large
                scConfigId = 1e4+1;
                retrievedConfigMap  = retrieve_config_map_by_id(scConfigId);
        end
    catch
        % Test passed, input validation failed
        err = lasterror;
        if( isempty(findstr(err.identifier, 'invalidInput')) )
            assert_equals(1, 0, messageOut);
        end
    end

end

% Test configMapClass constructor for illegal inputs

configMaps  = retrieve_config_map();
configMap = configMaps(1);

fieldsAndBounds = cell(2,4);
fieldsAndBounds(1,:)  = { 'id'; '>= 0'; '<=1e4'; []};
fieldsAndBounds(2,:)  = { 'time'; '> 54000'; '< 64000'; []};
assign_illegal_value_and_test_for_failure(configMap, 'configMap', configMap, 'configMap', 'configMapClass', fieldsAndBounds);

return
