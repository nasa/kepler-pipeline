function self = test_all_configmap(self)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function self = test_all_configmap(self)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% This method tests all configMapClass methods.
%
%  Example
%  =======
%  Use a test runner to run the test method:
%      run(text_test_runner, testConfigMapClass('test_all_configmap'));
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

display('Test all configMapClass methods');

messageOut = 'Test failed - Retrieved data and expected data are not identical!';

configMaps = retrieve_config_map();
configMapObject = configMapClass(configMaps(1));

timeStamp1 = 55371;         % a timeStamp after  the commanded time of configMap

assert_equals( get_black_start_row(configMapObject, timeStamp1),                                   1,       messageOut );       % 1-based
assert_equals( get_black_end_row(configMapObject, timeStamp1),                                  1070,       messageOut );       % 1-based
assert_equals( get_black_start_column(configMapObject, timeStamp1),                             1128,       messageOut );       % 1-based
assert_equals( get_black_end_column(configMapObject, timeStamp1),                               1132,       messageOut );       % 1-based

assert_equals( get_masked_smear_start_row(configMapObject, timeStamp1),                            7,       messageOut );       % 1-based
assert_equals( get_masked_smear_end_row(configMapObject, timeStamp1),                             14,       messageOut );       % 1-based  
assert_equals( get_masked_smear_start_column(configMapObject, timeStamp1),                        13,       messageOut );       % 1-based
assert_equals( get_masked_smear_end_column(configMapObject, timeStamp1),                        1112,       messageOut );       % 1-based

assert_equals( get_virtual_smear_start_row(configMapObject, timeStamp1),                        1052,       messageOut );       % 1-based
assert_equals( get_virtual_smear_end_row(configMapObject, timeStamp1),                          1059,       messageOut );       % 1-based
assert_equals( get_virtual_smear_start_column(configMapObject, timeStamp1),                       13,       messageOut );       % 1-based
assert_equals( get_virtual_smear_end_column(configMapObject, timeStamp1),                       1112,       messageOut );       % 1-based

assert_equals( get_number_of_shorts_in_long(configMapObject, timeStamp1),                         30,       messageOut );
assert_equals( get_number_of_longs_between_baselines(configMapObject, timeStamp1),                48,       messageOut );   
assert_equals( get_number_of_exposures_per_long_cadence_period(configMapObject, timeStamp1),     270,       messageOut ); 
assert_equals( get_number_of_exposures_per_short_cadence_period(configMapObject, timeStamp1),      9,       messageOut ); 

assert_equals( round( get_long_cadence_period(configMapObject, timeStamp1)*1e6 ),               1793491200, messageOut );       % microsecond
assert_equals( round( get_short_cadence_period(configMapObject, timeStamp1)*1e6 ),                59783040, messageOut );       % microsecond
assert_equals( round( get_exposure_time(configMapObject, timeStamp1)*1e6 ),                        6642560, messageOut );       % microsecond
assert_equals( round( get_readout_time(configMapObject, timeStamp1)*1e6 ),                          518950, messageOut );       % microsecond


timeStamp2 = 55250;         % a timeStamp before the commanded time of configMap

assert_equals( get_black_start_row(configMapObject, timeStamp2),                                -1,         messageOut );
assert_equals( get_black_end_row(configMapObject, timeStamp2),                                  -1,         messageOut );
assert_equals( get_black_start_column(configMapObject, timeStamp2),                             -1,         messageOut );
assert_equals( get_black_end_column(configMapObject, timeStamp2),                               -1,         messageOut );

assert_equals( get_masked_smear_start_row(configMapObject, timeStamp2),                         -1,         messageOut );
assert_equals( get_masked_smear_end_row(configMapObject, timeStamp2),                           -1,         messageOut );  
assert_equals( get_masked_smear_start_column(configMapObject, timeStamp2),                      -1,         messageOut );
assert_equals( get_masked_smear_end_column(configMapObject, timeStamp2),                        -1,         messageOut );

assert_equals( get_virtual_smear_start_row(configMapObject, timeStamp2),                        -1,         messageOut );
assert_equals( get_virtual_smear_end_row(configMapObject, timeStamp2),                          -1,         messageOut );
assert_equals( get_virtual_smear_start_column(configMapObject, timeStamp2),                     -1,         messageOut );
assert_equals( get_virtual_smear_end_column(configMapObject, timeStamp2),                       -1,         messageOut );

assert_equals( get_number_of_shorts_in_long(configMapObject, timeStamp2),                       -1,         messageOut );
assert_equals( get_number_of_longs_between_baselines(configMapObject, timeStamp2),              -1,         messageOut );   
assert_equals( get_number_of_exposures_per_long_cadence_period(configMapObject, timeStamp2),    -1,         messageOut ); 
assert_equals( get_number_of_exposures_per_short_cadence_period(configMapObject, timeStamp2),   -1,         messageOut );

assert_equals( get_long_cadence_period(configMapObject, timeStamp2),                            -1,         messageOut );
assert_equals( get_short_cadence_period(configMapObject, timeStamp2),                           -1,         messageOut );
assert_equals( get_exposure_time(configMapObject, timeStamp2),                                  -1,         messageOut );
assert_equals( get_readout_time(configMapObject, timeStamp2),                                   -1,         messageOut );


return

