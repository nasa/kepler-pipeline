function params = estimate(obj, predictorObj, paramID_list, LC)
%
% function params = estimate(obj, predictorObj, paramID_list, LC)
% 
% Black level or uncertainty parameter estimation method for ModelParameters class.
% This is the prototype for single pixel estimation. It is somewhat obsolete but maintained for backward compatability.
% Use the method 'estimates' for multi-pixel multi-LC estimation. The concept is that DN = f(C_i(t, T), row, column) where C_i(t,T) are a series of
% model coefficients as a function of temperature and time. This algorithm estimates the C_i(t,T).
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
% * Function returns:
% * --> |params  -| estimates all parameters needed for black-level or uncertainty in DN for the given set of arguments.
%
% * Function arguments:
% * --> |obj             -| ModelComponent object being estimated. 
% * --> |predictorObj    -| ModelComponent object containing predictor information.
% * --> |paramID_list    -| which parameters to estimate for a given ModelComponent.
% * --> |LC              -| specific LC relative to those specified in DynOBlack_init for which to estimate parameters.

if nargin > 0
    
    param_count  = length(paramID_list);
    params       = zeros(param_count,1);
    
    for k = 1:param_count
        paramID=paramID_list(k);
        
        switch obj.Type(paramID)
            
            % constant
            case 0
                params(k) = obj.Coefficients{paramID};
                
                % linear with temperature
            case 1
                temperature = estimate(predictorObj,[],2,LC);
                params(k) = [1 temperature] * obj.Coefficients{paramID};
                
                % linear with time
            case 2
                timeLC = estimate(predictorObj,[],1,LC);
                params(k) = [1 timeLC] * obj.Coefficients{paramID};
                
                % linear with temperature and time
            case 3
                temperature = estimate(predictorObj,[],2,LC);
                timeLC = estimate(predictorObj,[],1,LC);
                params(k) = [1 temperature timeLC] * obj.Coefficients{paramID};
                
                % interpolate on smoothed coefficients (short term variations < noise)
            case 4
                if mod(LC,1) < 0.03
                    params(k) = obj.Coefficients{paramID}(round(LC));
                else
                    params(k) = obj.Coefficients{paramID}(round(LC));
                end
                
                % interpolate (short term variations > noise)
            case 5
                if mod(LC,1) < 0.03
                    params(k) = obj.Coefficients{paramID}(round(LC));
                else
                    params(k) = obj.Coefficients{paramID}(round(LC));
                end
                
            otherwise
                params(k) = 0;
        end
    end
end

