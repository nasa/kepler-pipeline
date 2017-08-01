function model = dynamicBlackModel(varargin)
%
% function model = dynamicBlackModel(channel, modelInputs, errorInputs)
% 
% Pre-MATLAB V7.6 constructor for a dynamicBlackModel class object. 
% Defines a data structure for model components for use in estimation algorithms. Each dynamicBlackModel contains 
% complete information to calculate dynamic 2D Black levels for one channel.
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

% ARGUMENTS
% 
% * Function returns: model - an object of class dynamicBlackModel.
% * Function arguments:
% * |channel        -| channel number
% * |modelInputs    -| structure containing model parameters as model_parameters objects
% * |errorInputs    -| similar structure for errors
% *
% * properties:
% *        Channel                  - which channel
% *        Black_offset             - mean offset from requant table
% *        Vertical_parameters      - model_parameters object
% *        Horizontal_parameters    - model_parameters object
% *        FGSFrame_parameters      - model_parameters object
% *        FGSParallel_parameters   - model_parameters object
% *        Predictors               - model_parameters object (temperature and time)
% *        Vertical_errorParams     - model_parameters object
% *        Horizontal_errorParams   - model_parameters object
% *        FGSFrame_errorParams     - model_parameters object
% *        FGSParallel_errorParams  - model_parameters object
% *        PredictorErrors          - model_parameters object
%


if nargin == 1
    
    % assumes input is struct version of model object
    model = varargin{1};
    
    % build sub field ModelParameters objects    
    model.Vertical_parameters     = ModelParameters(model.Vertical_parameters);
    model.Horizontal_parameters   = ModelParameters(model.Horizontal_parameters);
    model.FGSFrame_parameters     = ModelParameters(model.FGSFrame_parameters);
    model.FGSParallel_parameters  = ModelParameters(model.FGSParallel_parameters);
    model.Predictors              = ModelParameters(model.Predictors);
    
    model.Vertical_errorParams    = ModelParameters(model.Vertical_errorParams);
    model.Horizontal_errorParams  = ModelParameters(model.Horizontal_errorParams);
    model.FGSFrame_errorParams    = ModelParameters(model.FGSFrame_errorParams);
    model.FGSParallel_errorParams = ModelParameters(model.FGSParallel_errorParams);
    model.PredictorErrors         = ModelParameters(model.PredictorErrors);
    
else
    
    % assumes input is parameters and objects needed to build struct version of model object
    channel     = varargin{1};
    modelInputs = varargin{2};
    errorInputs = varargin{3};
    
    nVerticleParams     = modelInputs.vertical_coeffs.Count;
    nHorizontalParams   = modelInputs.horizontal_coeffs.Count;
    nFgsFrameParams     = modelInputs.FGSframe_coeffs.Count;
    nFgsParallelParams  = modelInputs.FGSparallel_coeffs.Count;
    nPredictors         = modelInputs.predictor_data.Count;
    
    % INITIALIZATION
    model.Channel                 = channel;
    model.Black_offset            = double(modelInputs.mean_black);
    model.staticTwoDBlackImage    = modelInputs.staticTwoDBlackImage;
    model.thermalRowOffset        = modelInputs.thermalRowOffset;
    model.maxMaskedSmearRow       = modelInputs.maxMaskedSmearRow;
    model.removeStatic2DBlack     = modelInputs.removeStatic2DBlack;
    model.longTimeConstant        = modelInputs.longTimeConstant;    
    
    model.Vertical_parameters     = ModelParameters(nVerticleParams);
    model.Horizontal_parameters   = ModelParameters(nHorizontalParams);
    model.FGSFrame_parameters     = ModelParameters(nFgsFrameParams);
    model.FGSParallel_parameters  = ModelParameters(nFgsParallelParams);
    model.Predictors              = ModelParameters(nPredictors);
    
    model.Vertical_errorParams    = ModelParameters(nVerticleParams);
    model.Horizontal_errorParams  = ModelParameters(nHorizontalParams);
    model.FGSFrame_errorParams    = ModelParameters(nFgsFrameParams);
    model.FGSParallel_errorParams = ModelParameters(nFgsParallelParams);
    model.PredictorErrors         = ModelParameters(nPredictors);
    
    model.Vertical_parameters       = modelInputs.vertical_coeffs;
    model.Horizontal_parameters     = modelInputs.horizontal_coeffs;
    model.FGSFrame_parameters       = modelInputs.FGSframe_coeffs;
    model.FGSParallel_parameters    = modelInputs.FGSparallel_coeffs;
    model.Predictors                = modelInputs.predictor_data;
        
    % 08-22-2011:JK  --- Added errors    
    model.Vertical_errorParams      = errorInputs.vertical_errCoeffs;
    model.Horizontal_errorParams    = errorInputs.horizontal_errCoeffs;
    model.FGSFrame_errorParams      = errorInputs.FGSframe_errCoeffs;
    model.FGSParallel_errorParams   = errorInputs.FGSparallel_errCoeffs;
    model.verticalCorrelationMatrix = errorInputs.verticalCorrelationMatrix;
    
end

% make dynamicBlackModel object from struct if it is not already an object 
if isobject(model)
    return;
else
    model = class(model, 'dynamicBlackModel');  
end