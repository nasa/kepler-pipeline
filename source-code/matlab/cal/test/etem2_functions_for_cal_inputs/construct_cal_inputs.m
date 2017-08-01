function construct_cal_inputs(s, getRequantizedPixFlag, includeCosmicRaysFlag)
% function construct_cal_inputs(s, getRequantizedPixFlag, includeCosmicRaysFlag)
%
% This function extracts the pixel data from an ETEM2 output directory, and 
% constructs inputs for CAL collateral and photometric calibration.
%
% Optional flags:
%
%   getRequantizedPixFlag   if true, extract requantized pixels
%                           (default is true if flag is not input)
%
%   includeCosmicRaysFlag   if true, include cosmic rays 
%                           (default is false if flag is not input)
%
%
%--------------------------------------------------------------------------
% For each input file (each set of ETEM2 parameters), the following steps
% are performed:
%
% (1) extract target/mask definitions and collateral pixels from ETEM2 runs:
%
%    extract_pixel_time_series_from_etem2(etem2RunDirName, etem2RunDir, etem2RunName, getRequantizedPixFlag, includeCosmicRaysFlag)
%    
%           where runModOutDir is the diectory created by ETEM2 of the form 
%           (for module 7, output 3, and season 1):     run_long_m7o3s1
%
%          etem2OutputDir is the ETEM2 output location (ex. cal_2DblkOn_dir)
%
%          pixelDataMatFilename is the name of the .mat file with the pixel data 
%          (ex. cal_xxx_pixelData.mat)
%
%    
% (3) set input structures for CAL collateral and photometric
%
%    [calEtem2CollateralInputStruct, calEtem2PhotometricInputStruct] = ...
%         set_cal_input_struct(etem2OutputDir, pixelDataMatFilename, nCadences, getRequantizedPixFlag, includeCosmicRaysFlag)
%
% (4) save inputs to mat file:
% 
%    save /path/to/matlab/cal/calInputs_*.mat   calCollateralInputStruct_*   calPhotometricInputStruct_*
%--------------------------------------------------------------------------
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


etem2inputFilename  = s.filename;

runModOutDir        = ['run_long_m' num2str(s.ccdModule)   'o'  num2str(s.ccdOutput) 's1'];

nCadences           = s.numCadences;

if (nargin == 1)

    getRequantizedPixFlag = true;
    includeCosmicRaysFlag = false;

elseif (nargin == 2)

    includeCosmicRaysFlag = false;
end

%--------------------------------------------------------------------------
% extract pixel data, and save to matfile *_pixelData*
%--------------------------------------------------------------------------
% location where ETEM2 data was saved (set in ETEM2 input file as filename*_dir)
etem2OutputDir = ['/path/to/matlab/etem2/mfiles/' s.outputDirectory];

pixelDataMatFilename = [etem2OutputDir '/' etem2inputFilename, '_pixelData'];  

% pixel data output files are named within this function according to the
% enabled flag inputs
extract_pixel_time_series_from_etem2(etem2OutputDir, runModOutDir, pixelDataMatFilename, ...
    getRequantizedPixFlag, includeCosmicRaysFlag);

%--------------------------------------------------------------------------
% set inputs for CAL collateral and photometric data 
%--------------------------------------------------------------------------
% set name for cal input structs
calCollateralInputs  = ['calCollateralInputs_', etem2inputFilename];
calPhotometricInputs = ['calPhotometricsInputs_', etem2inputFilename];

[calCollateralInputs, calPhotometricInputs] = set_cal_input_struct(etem2OutputDir, ...
    pixelDataMatFilename, nCadences, getRequantizedPixFlag, includeCosmicRaysFlag);


%--------------------------------------------------------------------------
% load and save the ccdObject data that was output from etem2 run
%--------------------------------------------------------------------------
cd([etem2OutputDir '/' runModOutDir])

% need to clear classes to read from object, so save cal inputs to file and read back in
save temp_cal_inputs.mat calCollateralInputs calPhotometricInputs etem2inputFilename getRequantizedPixFlag includeCosmicRaysFlag

clear classes

load temp_cal_inputs.mat
load ccdObject.mat
load runParamsObject

disp('ccdObject and runParamsObject loaded')

dataUsedByEtemStruct = get_ccdObject_parameters_for_cal(ccdObject);


cd('../')

save(['ccdObject_' etem2inputFilename '.mat'], 'dataUsedByEtemStruct');

% save copy
save(['/path/to/matlab/cal/ccdObject_' etem2inputFilename ], 'dataUsedByEtemStruct');


%--------------------------------------------------------------------------
% update module parameters
%--------------------------------------------------------------------------
NLenabled = dataUsedByEtemStruct.etem2_nonlinearityEnabled;
LUenabled = dataUsedByEtemStruct.etem2_undershootEnabled;
FFenabled = dataUsedByEtemStruct.etem2_flatFieldEnabled;

calCollateralInputs.moduleParametersStruct.linearityCorrectionEnabled  = NLenabled;
calCollateralInputs.moduleParametersStruct.undershootEnabled           = LUenabled;
calCollateralInputs.moduleParametersStruct.flatFieldCorrectionEnabled  = FFenabled;

calPhotometricInputs.moduleParametersStruct.linearityCorrectionEnabled = NLenabled;
calPhotometricInputs.moduleParametersStruct.undershootEnabled          = LUenabled;
calPhotometricInputs.moduleParametersStruct.flatFieldCorrectionEnabled = FFenabled;

if ~(getRequantizedPixFlag)
    calCollateralInputs.cadenceTimes.requantEnabled  = false(size(calCollateralInputs.cadenceTimes.requantEnabled));
    calPhotometricInputs.cadenceTimes.requantEnabled = false(size(calPhotometricInputs.cadenceTimes.requantEnabled));
end


%--------------------------------------------------------------------------
% save pixel data 
%--------------------------------------------------------------------------
if (getRequantizedPixFlag && ~includeCosmicRaysFlag)

    eval(['save /path/to/matlab/cal/calInputs_', etem2inputFilename, '_RQ_cr.mat calCollateralInputs calPhotometricInputs']);
    eval(['save calInputs_', etem2inputFilename, '_RQ_cr.mat calCollateralInputs calPhotometricInputs']);


elseif (getRequantizedPixFlag && includeCosmicRaysFlag)

    eval(['save /path/to/matlab/cal/calInputs_', etem2inputFilename, '_RQ_CR.mat calCollateralInputs calPhotometricInputs']);
    eval(['save calInputs_', etem2inputFilename, '_RQ_CR.mat calCollateralInputs calPhotometricInputs']);

elseif (~getRequantizedPixFlag && ~includeCosmicRaysFlag)

    eval(['save /path/to/matlab/cal/calInputs_', etem2inputFilename, '_rq_cr.mat calCollateralInputs calPhotometricInputs']);
    eval(['save calInputs_', etem2inputFilename, '_rq_cr.mat calCollateralInputs calPhotometricInputs']);

elseif  (~getRequantizedPixFlag && includeCosmicRaysFlag)

    eval(['save /path/to/matlab/cal/calInputs_', etem2inputFilename, '_rq_CR.mat calCollateralInputs calPhotometricInputs']);
    eval(['save calInputs_', etem2inputFilename, '_rq_CR.mat calCollateralInputs calPhotometricInputs']);

end

cd('../');

return;
