function [status, dataModels] = retrieve_cbd_models(runStartMjd, runEndMjd)
% get_cbd_models: get the triplets of FFI for CCD bias and dark estimation
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
if ( nargin == 1 )
    runEndMjd = runStartMjd + 1;
elseif ( nargin == 0 || nargin > 2 )
    status = 1;
    error('retrieve_cbd_models must be called with 1 or 2 args');
end

% load constants
constants;

status = 0;

dataModels = cbdtModels();

% gain array for all modouts
gainObject = retrieve_gain_model(runStartMjd, runEndMjd);

% mean noise for all modouts 
noiseObject = retrieve_read_noise_model(runStartMjd, runEndMjd);  

% save model information to pre-allocated data structure
dataModels.fcGainModel  = single( gainObject.constants(1).array );
dataModels.fcNoiseModel = single( noiseObject.constants.array );  
        
idx_modout = 0;

% looping through each modout
for k=1:MOD_NO
    
    iModule = IDX_MOD_OUTS(k);
   
    fprintf('module: %2d\n', iModule);
    for iOutput = 1:OUTPUT_NO;

        % the current modout index
        idx_modout = idx_modout + 1;
        
        tic;
        
        % retrive an 2D black object from the SandBox
        blackObject = twoDBlackClass(...
            retrieve_two_d_black_model(iModule, iOutput, runStartMjd, runEndMjd));

        toc; 
        % call method to get the FFI
        [blackArrayAdu, blackArrayAduStd] = get_two_d_black(blackObject, runStartMjd);
        
        
        % bad pixels: not working
        %badPixelObject = retrieve_invalid_pixels_model(iModule, iOutput, runStartMjd, runEndMjd);       
        

        % save model information to pre-allocated data structure
        dataModels.fc2DBlackModel(:, :, idx_modout) = single( blackArrayAdu );
     
        dataModels.fc2DBlackModelStd(:, :, idx_modout) = single( blackArrayAduStd );        

    end
    
end