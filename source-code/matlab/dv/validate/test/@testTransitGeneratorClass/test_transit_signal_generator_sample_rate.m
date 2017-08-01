function self = test_transit_signal_generator_sample_rate( self )
%
% test_transit_signal_generator_sample_rate -- perform unit test of the 
% transitGeneratorClass methods with the new sampleRate module parameter
%
%
% This test is intended to be executed in the mlunit context.  For standalone execution
% use the following syntax:
%
%      run(text_test_runner, testTransitGeneratorClass('test_transit_signal_generator_sample_rate'));
%
% Version date:  2010-Oct-14 EQ
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

% Modification History:
% 2011-Aug-2 EQ: Updated to include new transit model
%
%=========================================================================================

%
% original function notes:
% function to regression test the v6.2 code and to investigate the cpu time
% for various transit sampling rates.  This function will eventually become
% a unit test for both v6.2 and v7.0 as the v7.0 transit model algorithms
% develop.
%
% To test the cpu time for fewer samples in v6.2 code, I will modify my 
% local 6.2 branch for debugFlag = 2.
%
%


% set test data directory
initialize_soc_variables;

testDataDir = [socTestDataRoot, filesep, 'dv', filesep, 'unit-tests', filesep, ...
    'transitGeneratorClass'] ;

clear soc*


%--------------------------------------------------------------------------
% regression test for transit generator class
%--------------------------------------------------------------------------
disp('... regression testing the transit signal generator class ... ')


% load the saved transitModelStruct and transitModelResultsStruct
load(fullfile(testDataDir, 'transit-model-sample-rate-test.mat')) ;

% regression test:
transitModelObjectNew = transitGeneratorClass(transitModelStruct);

transitModelStructNew = struct(transitModelObjectNew);

assert_equals( transitModelStructNew, transitModelStructDefault, ...
    'TransitGeneratorClass fails regression test.' ) ;
disp('TransitGeneratorClass passed regression test.')



%--------------------------------------------------------------------------
% test the transit signal generator
%--------------------------------------------------------------------------
disp('... testing transit signal generator ... ')


tic
[transitModelLightCurveNew, cadenceTimesNew]  = ...
    generate_planet_model_light_curve(transitModelObjectNew);
elapsedTime = toc;

assert_equals( transitModelLightCurveNew, transitModelLightCurveDefault, ...
    'The generated light curve fails regression test.' ) ;
disp('The generated light curve passed regression test.')

assert_equals( cadenceTimesNew, cadenceTimesDefault, ...
    'The generated cadence time array fails regression test.' ) ;
disp('The generated cadence time array passed regression test.')

disp(['The elapsed time for generate_planet_model_light_curve: ' num2str(elapsedTime) ' sec.'])


figure; 
plot(cadenceTimesNew, transitModelLightCurveNew, 'b.-')


%--------------------------------------------------------------------------
% test the transit signal generator with fewer samples
%--------------------------------------------------------------------------
disp('... testing transit signal generator with fewer samples ... ')
transitModelStructResampled = transitModelStruct;

transitModelStructResampled.transitSamplesPerCadence = 5;

transitModelObjectResampled = transitGeneratorClass(transitModelStructResampled); 

tic
[transitModelLightCurveResampled, cadenceTimesResampled]  = ...
    generate_planet_model_light_curve(transitModelObjectResampled);
elapsedTime = toc;


hold on; 
plot(cadenceTimesResampled, transitModelLightCurveResampled, 'm.-')


assert_equals( transitModelLightCurveResampled, transitModelLightCurveResampledDefault, ...
    'The resampled light curve fails regression test.' ) ;
disp('The resampled light curve passed regression test.')

assert_equals( cadenceTimesResampled, cadenceTimesResampledDefault, ...
    'The resampled cadence time array fails regression test.' ) ;
disp('The resampled cadence time array passed regression test.')


disp(['The elapsed time for resampled light curve is ' num2str(elapsedTime) ' sec.'])



return;


