function [dataAnomalyIndicators] = ...
parse_data_anomaly_types(dataAnomalyTypes)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function [dataAnomalyIndicators] = ...
% parse_data_anomaly_types(dataAnomalyTypes)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Parse the data anomaly types in the cadenceTimes structure into separate
% logical indicators arrays (with one element per cadence) for each type of
% data anomaly.
%
% Input:
%
%   dataAnomalyTypes[cell array of string cell arrays]
%                                 cell array with one cell array of strings
%                                 per cadence, obtained from SOC
%                                 cadenceTimes structure
%
% Output:
%
%   dataAnomalyIndicators[struct] with the following fields:
%
%     attitudeTweakIndicators[logical array]  one indicator per cadence, nx1
%          safeModeIndicators[logical array]  one indicator per cadence, nx1
%        earthPointIndicators[logical array]  one indicator per cadence, nx1
%       coarsePointIndicators[logical array]  one indicator per cadence, nx1
%   argabrighteningIndicators[logical array]  one indicator per cadence, nx1
%           excludeIndicators[logical array]  one indicator per cadence, nx1
%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
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

% Define dictionary.
ATTITUDE_TWEAK = 'ATTITUDE_TWEAK';
SAFE_MODE = 'SAFE_MODE';
EARTH_POINT = 'EARTH_POINT';
COARSE_POINT = 'COARSE_POINT';
ARGABRIGHTENING = 'ARGABRIGHTENING';
EXCLUDE = 'EXCLUDE';

% Initialize the output structure.
nCadences = length(dataAnomalyTypes);

dataAnomalyIndicators = struct( ...
    'attitudeTweakIndicators', false([nCadences, 1]), ...
    'safeModeIndicators', false([nCadences, 1]), ...
    'earthPointIndicators', false([nCadences, 1]), ...
    'coarsePointIndicators', false([nCadences, 1]), ...
    'argabrighteningIndicators', false([nCadences, 1]), ...
    'excludeIndicators', false([nCadences, 1]));

% Loop over cadences and set the appropriate indicators.
for iCadence = 1 : nCadences
    
    types = dataAnomalyTypes{iCadence};
    
    if ~isempty(types)
        
        for iType = 1 : length(types)
            
            switch types{iType}
                case ATTITUDE_TWEAK
                    dataAnomalyIndicators.attitudeTweakIndicators(iCadence) = true;
                case SAFE_MODE
                    dataAnomalyIndicators.safeModeIndicators(iCadence) = true;
                case EARTH_POINT
                    dataAnomalyIndicators.earthPointIndicators(iCadence) = true;
                case COARSE_POINT
                    dataAnomalyIndicators.coarsePointIndicators(iCadence) = true;
                case ARGABRIGHTENING
                    dataAnomalyIndicators.argabrighteningIndicators(iCadence) = true;
                case EXCLUDE
                    dataAnomalyIndicators.excludeIndicators(iCadence) = true;
                otherwise
                    error('Common:parseDataAnomalyTypes:unknownType', ...
                        '%s is not a known type (cadence index %d)', ...
                        types{iType}, iCadence);
            end % switch
            
        end % for iType
    
    end % if
        
end % for iCadence

% Return.
return
