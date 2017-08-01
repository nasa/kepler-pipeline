%% estimates
% Black level or uncertainty parameter estimation method for ModelParameters class.
% This is the prototype for multi-LC estimation.
% The concept is that DN = f(C_i(t, T), row, column) where C_i(t,T) are a series of
% model coefficients as a function of temperature and time.
% This algorithm estimates the C_i(t,T) for all requested LC.
% 
%   Revision History:
%
%       Version 0 - 9/18/10     released for Science Office use
%
% 
% <html>
% <style type="text/css"> pre.codeinput {background: #FFFF66; padding: 30px;} </style>
% </html>
%
%%
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
function params = estimates(obj, predictorObj, paramID_list, LC_list)
%% ARGUMENTS
% 
% * Function returns:
% * --> |params  -| estimates all parameters needed for black-level or uncertainty in DN for the given set of arguments.
%
% * Function arguments:
% * --> |obj             -| ModelComponent object being estimated. 
% * --> |predictorObj    -| ModelComponent object containing predictor information.
% * --> |paramID_list    -| which parameters to estimate for a given ModelComponent.
% * --> |LC_list         -| list of LC relative to those specified in DynOBlack_init for which to estimate parameters.
%
%% CODE
%
   if nargin > 0
       param_count = length(paramID_list);
       LC_count = length(LC_list);
       LC_range = 1:LC_count;
       params=zeros(param_count,LC_count);
       for k=1:param_count,
         paramID=paramID_list(k);
         switch obj.Type(paramID)
             case 0 % Constant
                 params(k,LC_range)=obj.Coefficients{paramID}';
             case 1 % Linear with temperature
                 temperatures=estimates(predictorObj,[],2,LC_list);
                 params(k,LC_range)=[ones(LC_count,1) temperatures'] * obj.Coefficients{paramID};
             case 2 % Linear with time
                 timeLCs=estimates(predictorObj,[],1,LC_list);
                 params(k,LC_range)=[ones(LC_count,1) timeLCs'] * obj.Coefficients{paramID};
             case 3 % Linear with temperature and time
                 temperatures=estimates(predictorObj,[],2,LC_list);
                 timeLCs=estimates(predictorObj,[],1,LC_list);
                 params(k,LC_range)=[ones(LC_count,1) temperatures' timeLCs'] * obj.Coefficients{paramID};
             case 4 % interpolate on smoothed coefficients (short term variations < noise)
                 if max(abs(mod(LC_list+0.5,1)-0.5))<.03
                    params(k,LC_range)=obj.Coefficients{paramID}(round(LC_list));
                 else
                    interp_range=1:length(obj.Coefficients{paramID})
                    params(k,LC_range)=interp1q(interp_range, obj.Coefficients{paramID}, LC_list);
                 end
             case 5 % interpolate (short term variations > noise)
                 if max(abs(mod(LC_list+0.5,1)-0.5))<.03
                    params(k,LC_range)=obj.Coefficients{paramID}(round(LC_list));
                 else
                    interp_range=1:length(obj.Coefficients{paramID})
                    params(k,LC_range)=interp1q(interp_range, obj.Coefficients{paramID}, LC_list);
                 end
             otherwise
                 params(k,LC_range)=0;
         end
       end
   end
end % estimates
