function [ tpsInputStruct ] = tps_convert_91_data_to_92( tpsInputStruct )
%
% tps_convert_91_data_to_92 -- convert TPS inputs 
%
% tpsInputStruct = tps_convert_90_data_to_91( tpsInputStruct ) handles all necessary input
%    field additions, deletions, or modifications needed to allow a data struct from TPS
%    version 9.1 to run in TPS version 9.2 while the latter is under development.
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

%=========================================================================================

if ~isfield( tpsInputStruct.tpsModuleParameters, 'maxPeriodParameter' ) 
    tpsInputStruct.tpsModuleParameters.maxPeriodParameter = 0.01696 ;
end
if ~isfield( tpsInputStruct.cadenceTimes.dataAnomalyFlags, ...
        'planetSearchExcludeIndicators' )
    tpsInputStruct.cadenceTimes.dataAnomalyFlags.planetSearchExcludeIndicators = ...
        false( size( tpsInputStruct.cadenceTimes.gapIndicators ) ) ;
end

% since our cadenceTimes struct now mirrors the dvCadenceTimes struct, we need to add two
% new vectors:  lcTargetTableIds and quarters (both int-valued double vectors).  

if ~isfield( tpsInputStruct.cadenceTimes, 'lcTargetTableIds' )
    
    quarters = ones( size( tpsInputStruct.cadenceTimes.gapIndicators ) ) ;
    newQuarterStartCadence = [1861 6300 10787 15269 19965 24405 29553 33122 37945 42563 ...
        47354 51447 55920 60762 65562] ;
    
    for iNew = newQuarterStartCadence
        if length(quarters) >= iNew
            quarters(iNew:end) = quarters(iNew:end) + 1 ;
        end
    end
    
    lcTargetTableIds = quarters ;
    quarters( tpsInputStruct.cadenceTimes.gapIndicators ) = -1 ;
    lcTargetTableIds( tpsInputStruct.cadenceTimes.gapIndicators ) = 0 ;
    
    tpsInputStruct.cadenceTimes.lcTargetTableIds = lcTargetTableIds ;
    tpsInputStruct.cadenceTimes.quarters         = quarters ;
    
end

if ~isfield( tpsInputStruct.tpsModuleParameters, 'chiSquareGofThreshold' ) 
    tpsInputStruct.tpsModuleParameters.chiSquareGofThreshold = 7.5;
end

if ~isfield( tpsInputStruct.tpsModuleParameters, 'sesProbabilityThreshold' ) 
    tpsInputStruct.tpsModuleParameters.sesProbabilityThreshold = 5.0;
end

if isfield( tpsInputStruct.tpsModuleParameters, 'chiSquare1Threshold' ) 
    tpsInputStruct.tpsModuleParameters = rmfield( ...
        tpsInputStruct.tpsModuleParameters, 'chiSquare1Threshold');
end

% fix the rollTimeModel changes 
if isfield(tpsInputStruct.rollTimeModel, 'deltaAngleDegrees')
    tpsInputStruct.rollTimeModel = rmfield( tpsInputStruct.rollTimeModel, ...
        'deltaAngleDegrees');
end
if ~isfield(tpsInputStruct.rollTimeModel, 'rollOffsets')
    tpsInputStruct.rollTimeModel.rollOffsets = [];
end
if ~isfield(tpsInputStruct.rollTimeModel, 'fovCenterRas')
    tpsInputStruct.rollTimeModel.fovCenterRas = [];
end
if ~isfield(tpsInputStruct.rollTimeModel, 'fovCenterDeclinations')
    tpsInputStruct.rollTimeModel.fovCenterDeclinations = [];
end
if ~isfield(tpsInputStruct.rollTimeModel, 'fovCenterRolls')
    tpsInputStruct.rollTimeModel.fovCenterRolls = [];
end

% use a smaller period mesh in 9.2
tpsInputStruct.tpsModuleParameters.searchPeriodStepControlFactor = 0.95;

return