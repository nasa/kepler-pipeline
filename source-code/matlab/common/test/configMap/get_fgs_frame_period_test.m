% get_fgs_frame_period_test: script for testing get_fgs_frame_period
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

% Initialize soc variables
initialize_soc_variables

% Load a struct with 1 configMap and instantiate into configMap object
configMap1FullPath = [socTestDataRoot filesep 'common' filesep 'configMap' filesep 'configMap_1_struct.mat'];
eval(['load ' configMap1FullPath])
configMapObject1 = configMapClass(configMap1);

% Call get_fgs_frame_period with no timestamp as input
[fgsFramePeriodInMsec, closestConfigMapTimeStamps] = get_fgs_frame_period(configMapObject1);

% Call get_fgs_frame_period with timestamp that is 8 days off from tiemsta in configMap
[fgsFramePeriodInMsec, closestConfigMapTimeStamps] = get_fgs_frame_period(configMapObject1, 54960);
assert_equals(fgsFramePeriodInMsec, 103.79, 'FGS frame period retrieved not 103.70 milliseconds');

% Load a struct with 3 configMaps and instantiate into configMap object
configMap3FullPath = [socTestDataRoot filesep 'common' filesep 'configMap' filesep 'configMap_3_struct.mat'];
eval(['load ' configMap3FullPath])
configMapObject3 = configMapClass(configMap3);

% Call get_fgs_frame_period with no timestamp as input
[fgsFramePeriodInMsec, closestConfigMapTimeStamps] = get_fgs_frame_period(configMapObject3);

% Call get_fgs_frame_period with timestamp input
[fgsFramePeriodInMsec, closestConfigMapTimeStamps] = get_fgs_frame_period(configMapObject3, [ 54953 54960]);
assert_equals(fgsFramePeriodInMsec, 103.79, 'FGS frame period retrieved not 103.70 milliseconds')

% Check that error will be thrown if inconsistent fgs frame periods are
% retrieved
configMapStruct = repmat(configMap1,1,3);
configMapStruct(2).entries(33).value = '200'; % as string
configMapStruct(3).entries(33).value = '200';

configMapInconsistentObject = configMapClass(configMapStruct);
% Call get_fgs_frame_period with no timestamp as input and expect an error
try
    [fgsFramePeriodInMsec, closestConfigMapTimeStamps] = get_fgs_frame_period(configMapInconsistentObject);
catch
    disp('Error caught')
end


% Call get_fgs_frame_period with timestamp as input and expect an error
try
    [fgsFramePeriodInMsec, closestConfigMapTimeStamps] = get_fgs_frame_period(configMapInconsistentObject, [54953 54960]);
catch
    disp('Error caught')
end