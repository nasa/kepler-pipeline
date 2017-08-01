function obm = oneDBlackModelClass(chan, model_in, error_in)
%
% DynamicBlackModel:  Defines a data structure for model components for use
%                     in estimation algorithms. Each DynamicBlackModel contains
%                     complete information to calculate 1D Black levels for
%                     one channel.
%
% * Function returns: dbm - an object of class DynamicBlackModel.
% * Function arguments:
% * |chan        -| channel number
% * |model_in    -| structure containing model parameters as model_parameters objects
% * |error_in    -| similar structure for errors
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
%% INITIALIZATION
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
obm.Channel                 = chan;
obm.Black_offset            = double(model_in.mean_black);
obm.Vertical_parameters     = modelParametersClass(5);
obm.Predictors              = modelParametersClass(2);
obm.Vertical_errorParams    = modelParametersClass(5);
obm.PredictorErrors         = modelParametersClass(2);

if nargin > 0
    
    obm.Channel = chan;
    obm.Black_offset = double(model_in.mean_black);
    
    obm.Vertical_parameters = model_in.vertical_coeffs;
    %                 dbm.Vertical_errorParams = error_in.vertical_errCoeffs;
    
    obm.Predictors = model_in.predictor_data;
    %                 dbm.PredictorErrors = error_in.predictor_errors;
    
end

obm = class(obm, 'oneDBlackModelClass');

return

end % OneDBlackModel
