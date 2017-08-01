% Script to perform a short-cadence simulation test.
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

%----------------------------------------------------------------------
% Configure
dataDir = '~/data/pdc/lcsc_data/7.3/';
pruneNonScTargets = false;
nEventsPerMonth = 10;
dropSizeRange = [0.005 0.02];
recoveryFractionRange = [0 0.8];
recoverySpeedRange = [0.005 0.02];
%----------------------------------------------------------------------

% Load LC and SC input structs.
if ~exist('lcInputsStruct','var') || ~exist('scInputsStruct','var')

    eval(['load ', fullfile(dataDir, '/lc/pdc-inputs-0.mat')]);
    lcInputsStruct = pdc_convert_81_data_to_82(inputsStruct);

    eval(['load ', fullfile(dataDir, '/sc-m1/pdc-inputs-0.mat')]);
    scInputsStruct = {pdc_convert_81_data_to_82(inputsStruct)};

    eval(['load ', fullfile(dataDir, '/sc-m2/pdc-inputs-0.mat')]);
    scInputsStruct{2} = pdc_convert_81_data_to_82(inputsStruct);

    eval(['load ', fullfile(dataDir, '/sc-m3/pdc-inputs-0.mat')]);
    scInputsStruct{3} = pdc_convert_81_data_to_82(inputsStruct);
end

% Load spsdCorrectedFluxObject.
eval(['load ', fullfile(dataDir, '/lc/spsdCorrectedFluxObject_1.mat')]);
scfObj = spsdCorrectedFluxClass.loadobj(spsdCorrectedFluxObject);
scfObj.detectionParamsStruct.quickSpsdEnabled = false;

% prune non-SC targets, if desired.
if pruneNonScTargets
    scKeplerIds = [ [scInputsStruct{1}.targetDataStruct.keplerId], ...
                    [scInputsStruct{2}.targetDataStruct.keplerId], ...
                    [scInputsStruct{3}.targetDataStruct.keplerId] ]';
    lcKeplerIds = [lcInputsStruct.targetDataStruct.keplerId];
    scTargetIndicators = ismember(lcKeplerIds, scKeplerIds);
    scfObj.inputTargetDataStruct = scfObj.inputTargetDataStruct(scTargetIndicators);
end

sstObj = spsdSimulationTesterClass(scfObj);

% Set parameter ranges for simulated events
sstObj.eventParams.nEvents          = nEventsPerMonth; 
sstObj.eventParams.dropSize         = dropSizeRange; 
sstObj.eventParams.recoveryFraction = recoveryFractionRange; 
sstObj.eventParams.recoverySpeed    = recoverySpeedRange; 

% Perform test.
[resultsArray, spsdCorrectedFluxObjectArray] = sstObj.test_sc(lcInputsStruct, scInputsStruct);


