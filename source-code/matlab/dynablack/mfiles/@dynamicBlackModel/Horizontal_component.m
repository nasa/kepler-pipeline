%% Horizontal_component (single pixel case)
% Method for DynamicBlackModel objects for calculating horizontal component of black level.
% This is somewhat obsolete but maintained for backward compatability.
% Horizontal_components does multiple pixels & LCs
% 
%
%   Revision History:
%
%       Version 0 - 2/9/10      released for review and comment
%       Version 1 - 4/19/10     Modified classes for pre-MATLAB V7.6
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
function valDN = Horizontal_component(obj, column, lc)
%% ARGUMENTS
% 
% * Function returns:
% * --> |valDN  -| estimates column-dependent component of black-level in DN/read for the given set of arguments.
%
% * Function arguments:
% * --> |obj    -| DynamicBlackModel object being estimated. 
% * --> |column -| which column.
% * --> |lc     -| which LC.
%
%%
   Constants.ffi_column_count=1132;
   if nargin > 0
        linearRef=(1124/(Constants.ffi_column_count-1)-0.5);
        quadRef  =(linearRef*2)^2-1/3;
        linear=((column-1)/(Constants.ffi_column_count-1)-0.5);
        quad  =(linear*2)^2-1/3;
        predictorsRef=[0  1.0 linearRef quadRef];
        predictors=[1.0*(column<293) 1.0*(column>=293) linear quad];
        RCcoef_range=obj.Horizontal_parameters.Count-7:obj.Horizontal_parameters.Count-6;
        smearcoef_range=obj.Horizontal_parameters.Count-3:obj.Horizontal_parameters.Count-2;
        smearcoefoffset_range=obj.Horizontal_parameters.Count-1:obj.Horizontal_parameters.Count;
        coefficients=[obj.Horizontal_parameters.estimate(obj.Predictors,RCcoef_range,lc)' ...
                      obj.Horizontal_parameters.estimate(obj.Predictors,smearcoef_range,lc)'- ...
                      obj.Horizontal_parameters.estimate(obj.Predictors,smearcoefoffset_range,lc)'];
        sol=0;
        if column < obj.Horizontal_parameters.Count-4 && column > 2
            sol=obj.Horizontal_parameters.estimate(obj.Predictors,column,lc);
        end
        valDN=coefficients*predictors'-coefficients*predictorsRef'+sol;
   end
end % Horizontal_component

