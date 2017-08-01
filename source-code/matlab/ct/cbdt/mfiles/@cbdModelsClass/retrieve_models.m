function cbdObj = retrieve_models(cbdObj, startMjd, endMjd, moduleIndex, outputIndex)
% status = get_models(cbdObj)
% Get the pre-flight models from SOC workspace
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

modoutIdx = convert_from_module_output(moduleIndex, outputIndex);

% persistent features for remembering all the gains
% persistent modelGainArray;
persistent modelNoiseArray;

% retrive an 2D black object from the SOC Sandbox
blackObject = twoDBlackClass(retrieve_two_d_black_model(moduleIndex, outputIndex, startMjd, endMjd));

% call method to get the 2D black mean and std
[blackModel, blackModelStd] = get_two_d_black(blackObject, startMjd);

% model noises
if ( isempty(modelNoiseArray) )
   noiseObject = retrieve_read_noise_model(startMjd, endMjd);
   modelNoiseArray = noiseObject.constants(1).array;
end

readNoiseModelStd = 0;% no read noise uncertainty

% set the model values
cbdObj.fc2dBlackModel= blackModel;
cbdObj.fc2dBlackModelStd = blackModelStd;

cbdObj.fcReadNoiseModel = modelNoiseArray(modoutIdx);
cbdObj.fcReadNoiseModelStd = readNoiseModelStd;

% compute the pixel statistics for the science and the four collateral
% regions: call Hayley's function
% cbdObj.fc2dBlackModelRegionStats = get_pixels_statistics(blackModel, 1, cbdObj.debugStatus);

if ( cbdObj.debugStatus )   
    fprintf(' ReadOutNoise Std: %f\n', cbdObj.fcReadNoiseModel); 
end

return
