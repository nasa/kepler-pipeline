function paDataStruct = pa_convert_81_data_to_82(paDataStruct)
%
% function paDataStruct = pa_convert_81_data_to_82(paDataStruct)
%
% Update 8.1-era PA input structures to 8.2. This is useful when testing
% with existing data sets.
%
% INPUTS:       paDataStruct    = SOC 8.1 paInputsStruct
% OUTPUTS:      paDataStruct    = SOC 8.2 paInputsStruct
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


% will need these updates after KSOC-2022 branch is merged to trunk vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv

% default param values
USE_EXISTING_POLYS = true;
INPUT_SES_UPPER_LIMIT = 20;
INPUT_SES_LOWER_LIMIT = 2;
INPUT_DURATION_UPPER_LIMIT = 16;
INPUT_DURATION_LOWER_LIMIT = 1;
IMPACT_PARAM_UPPER_LIMIT = 1;
IMPACT_PARAM_LOWER_LIMIT = 0;
TRANSIT_SEPARATION_FACTOR = 50;
USE_DEFAULT_KICS = true;

% seed simulated transit configuration struct
simulatedTransitsConfigurationStruct = struct('useExistingPolynomials',USE_EXISTING_POLYS,...
                                                'inputSesUpperLimit',INPUT_SES_UPPER_LIMIT,...
                                                'inputSesLowerLimit',INPUT_SES_LOWER_LIMIT,...
                                                'inputDurationUpperLimit',INPUT_DURATION_UPPER_LIMIT,...
                                                'inputDurationLowerLimit',INPUT_DURATION_LOWER_LIMIT,...
                                                'impactParameterUpperLimit',IMPACT_PARAM_UPPER_LIMIT,...
                                                'impactParameterLowerLimit',IMPACT_PARAM_LOWER_LIMIT,...
                                                'transitSeparationFactor',TRANSIT_SEPARATION_FACTOR,...
                                                'useDefaultKicsParameters',USE_DEFAULT_KICS);
                                            
% update pa data struct with simulated transit configuration
if ~isfield(paDataStruct,'simulatedTransitsConfigurationStruct')
    paDataStruct.simulatedTransitsConfigurationStruct = simulatedTransitsConfigurationStruct;
else
    % some 8.1.delta configuration parameters may need to be added here
    if ~isfield(paDataStruct.simulatedTransitsConfigurationStruct,'transitSeparationFactor')
        paDataStruct.simulatedTransitsConfigurationStruct.transitSeparationFactor = TRANSIT_SEPARATION_FACTOR;
    end
    if ~isfield(paDataStruct.simulatedTransitsConfigurationStruct,'useDefaultKicsParameters')
        paDataStruct.simulatedTransitsConfigurationStruct.useDefaultKicsParameters = USE_DEFAULT_KICS;
    end
end

% default is *not* to run simulated transits
if ~isfield(paDataStruct.paConfigurationStruct,'simulatedTransitsEnabled')
    paDataStruct.paConfigurationStruct.simulatedTransitsEnabled = false;
end

% must have kics field but structure can be empty
if ~isfield(paDataStruct,'kics')
    paDataStruct.kics = [];
end
    
% must have rmsCdppStruct field for each target but structure can be empty
if ~isempty(paDataStruct.targetStarDataStruct)
    for iTarget = 1:length(paDataStruct.targetStarDataStruct)            
        if ~isfield(paDataStruct.targetStarDataStruct(iTarget),'rmsCdppStruct')
           paDataStruct.targetStarDataStruct(iTarget).rmsCdppStruct = [];
        end            
    end
end    

% will need these updates after KSOC-2022 branch is merged to trunk ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^


return
