function [result, inputStruct] = iseeTempStruct(inputStruct)

% function [result, inputStruct] = iseeTempStruct(inputStruct)
%
% Checks the field of inputStruct to see if they match those required for
% an eeTempStruct per encircledEnergy.m
% Also checks for control parameter (optional) fields, creates them and
% fills with default values if not present.
% Returns boolean and inputStruct with any modifications made.
%
%   INPUT   inputStruct     = data structure
%   OUTPUT  result          = boolean; 1 == inputStruct matches
%                             eeTempStruct field structure
%           inputStruct     = original inputStruct with possible added
%                             fields if the minimum field requirements were
%                             met.
%
%   NOTE: This function does not check the existance of validity of data
%   within the structure.
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

%% Encircled energy default parameters

MIN_POLY_ORDER      = -1;
MAX_POLY_ORDER      = 30;
DEFAULT_POLY_ORDER  = 7;    %#ok<NASGU>

MIN_EE_FRACTION     = 0.40; %#ok<NASGU>
MAX_EE_FRACTION     = 0.98; %#ok<NASGU>
DEFAULT_EE_FRACTION = 0.95; %#ok<NASGU>

MAX_TARGETS         = 3000;
MAX_PIXELS          = 200;

SEED_RADIUS         = 0.6;
AIC_FRACTION        = 0.1;
EE_TARGET_LABEL     = 'EE_TARGET';

TARGET_P_ORDER      = 2;
MAX_RADIUS          = 0;

%% Check data structure

result = 0;

if(isfield(inputStruct,'targetStar') && ...
        isfield(inputStruct.targetStar(1),'gapList') && ...
        isfield(inputStruct.targetStar(1),'expectedFlux') && ...
        isfield(inputStruct.targetStar(1),'cadence') && ...        
        isfield(inputStruct.targetStar(1).cadence(1),'pixFlux') && ...
        isfield(inputStruct.targetStar(1).cadence(1),'Cpixflux') && ...
        isfield(inputStruct.targetStar(1).cadence(1),'radius') && ...
        isfield(inputStruct.targetStar(1).cadence(1),'row') && ...
        isfield(inputStruct.targetStar(1).cadence(1),'col') && ...
        isfield(inputStruct.targetStar(1).cadence(1),'gapFlag') && ...        
   isfield(inputStruct,'encircledEnergyStruct') && ...
        isfield(inputStruct.encircledEnergyStruct,'polyOrder') && ...
        isfield(inputStruct.encircledEnergyStruct,'eeFraction'))
    
    % data struct is there
    result = 1;
    
    % check constants - seed with defaults if absent
    if(~isfield(inputStruct.encircledEnergyStruct,'EE_TARGET_LABEL'))
        inputStruct.encircledEnergyStruct.EE_TARGET_LABEL = EE_TARGET_LABEL;
    end
            
    if(~isfield(inputStruct.encircledEnergyStruct,'MAX_TARGETS'))
        inputStruct.encircledEnergyStruct.MAX_TARGETS = MAX_TARGETS;
    end
    
    if(~isfield(inputStruct.encircledEnergyStruct,'MAX_PIXELS'))
        inputStruct.encircledEnergyStruct.MAX_PIXELS = MAX_PIXELS;
    end
    
    if(~isfield(inputStruct.encircledEnergyStruct,'SEED_RADIUS'))
        inputStruct.encircledEnergyStruct.SEED_RADIUS = SEED_RADIUS;
    end
    
    if(~isfield(inputStruct.encircledEnergyStruct,'MIN_POLY_ORDER'))
        inputStruct.encircledEnergyStruct.MIN_POLY_ORDER = MIN_POLY_ORDER;
    end
    
    if(~isfield(inputStruct.encircledEnergyStruct,'MAX_POLY_ORDER'))
        inputStruct.encircledEnergyStruct.MAX_POLY_ORDER = MAX_POLY_ORDER;
    end
    
    if(~isfield(inputStruct.encircledEnergyStruct,'AIC_FRACTION'))
        inputStruct.encircledEnergyStruct.AIC_FRACTION = AIC_FRACTION;
    end
    
    if(~isfield(inputStruct.encircledEnergyStruct,'TARGET_P_ORDER'))
        inputStruct.encircledEnergyStruct.TARGET_P_ORDER = TARGET_P_ORDER;
    end
    
    if(~isfield(inputStruct.encircledEnergyStruct,'MAX_RADIUS'))
        inputStruct.encircledEnergyStruct.MAX_RADIUS = MAX_RADIUS;
    end
    
end
    
%%
 