function tpsResults = validate_tps_output_structure(tpsResults, tpsLiteEnabledFlag)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function tpsResults = validate_tps_output_structure(tpsResults,
% tpsLiteEnabledFlag)
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

warningInsteadOfErrorFlag = true;

% tpsOutputStruct.tpsResults(1)
% ans =
%                          keplerId: 4646780
%          trialTransitPulseInHours: 3
%           maxSingleEventStatistic: 2.81110214541306
%          meanSingleEventStatistic: -0.00042939527939227
%                           rmsCdpp: 43.5068552994373
%                    cdppTimeSeries: [476x1 double]
%             correlationTimeSeries: [476x1 double]
%           normalizationTimeSeries: [476x1 double]
%                 matchedFilterUsed: 0
%        correlationTimeSeriesHiRes: [2380x1 double]
%      normalizationTimeSeriesHiRes: [2380x1 double]
%               bestPhaseInCadences: 9.8
%       bestOrbitalPeriodInCadences: 195.593188091159
%         maxMultipleEventStatistic: 3.84549225126157
%       detectedOrbitalPeriodInDays: 3.9966729686556
%          timeToFirstTransitInDays: 0.200249280023854
%           timeOfFirstTransitInMjd: 54953.23840164
%                isPlanetACandidate: 0
%      foldedStatisticAtTrialPhases: [978x1 double]
%                phaseLagInCadences: [978x1 double]
%     foldedStatisticAtTrialPeriods: [998x1 double]
%         possiblePeriodsInCadences: [998x1 double]



if(tpsLiteEnabledFlag)
    fieldsAndBounds = cell(7,4);
    fieldsAndBounds(1,:)  = { 'keplerId';  '>= 0'; '<= 1e8'; []};
    fieldsAndBounds(2,:)  = { 'trialTransitPulseInHours'; '> 0'; '<= 72'; []};
    fieldsAndBounds(3,:)  = { 'maxSingleEventStatistic'; '>= -1'; '<= 1e3'; []}; % may need to change later on
    fieldsAndBounds(4,:)  = { 'meanSingleEventStatistic'; '>= -1'; '<= 1e3'; []}; % may need to change later on
    fieldsAndBounds(5,:)  = { 'rmsCdpp'; '>= -1'; '<= 1e6'; []};
    fieldsAndBounds(6,:)  = { 'cdppTimeSeries'; '>= -1'; '<= 1e6'; []};
    fieldsAndBounds(7,:)  = { 'isResultValid'; []; []; [true, false]};
else
    fieldsAndBounds = cell(16,4);
    fieldsAndBounds(1,:)  = { 'keplerId';  '>= 0'; '<= 1e8'; []};
    fieldsAndBounds(2,:)  = { 'trialTransitPulseInHours'; '> 0'; '<= 72'; []};
    fieldsAndBounds(3,:)  = { 'maxSingleEventStatistic'; '>= -1'; '<= 1e3'; []}; % may need to change later on
    fieldsAndBounds(4,:)  = { 'meanSingleEventStatistic'; '>= -1'; '<= 1e3'; []}; % may need to change later on
    fieldsAndBounds(5,:)  = { 'rmsCdpp'; '>= -1'; '<= 1e6'; []};
    fieldsAndBounds(6,:)  = { 'cdppTimeSeries'; '>= -1'; '<= 1e6'; []};
    fieldsAndBounds(7,:)  = { 'detectedOrbitalPeriodInDays'; '>= -1'; '<= 1e6'; []};
    fieldsAndBounds(8,:)  = { 'maxMultipleEventStatistic'; '>= -1'; '<= 1e6'; []};
    fieldsAndBounds(9,:)  = { 'timeToFirstTransitInDays';'>= -1'; '<= 1e6'; []};
    fieldsAndBounds(10,:)  = { 'timeOfFirstTransitInMjd';'>= -1'; '<= 1e5'; []};  % validate mjd
    fieldsAndBounds(11,:)  = { 'isPlanetACandidate'; []; []; [true, false]};
    fieldsAndBounds(12,:)  = { 'isResultValid'; []; []; [true, false]};
    fieldsAndBounds(13,:)  = { 'minMultipleEventStatistic'; '>= -1e6'; '<= 1'; []}; % validate new fields for microlensing events
    fieldsAndBounds(14,:)  = { 'detectedMicrolensOrbitalPeriodInDays'; '>= -1'; '<= 1e6'; []}; % validate new fields for mircrolensing events
    fieldsAndBounds(15,:)  = { 'timeToFirstMicrolensInDays';'>= -1'; '<= 1e6'; []}; % validate new fields for microlensing events
    fieldsAndBounds(16,:)  = { 'timeOfFirstMicrolensInMjd';'>= -1'; '<= 1e5'; []}; % validate new fields for mircrolensing events
end


nStructures = length(tpsResults);

for j = 1:nStructures
    
    if(isempty(tpsResults(j).cdppTimeSeries))
        continue; % do not validate this structure
    end
    validate_structure(tpsResults(j), fieldsAndBounds,'tpsResults',warningInsteadOfErrorFlag);% set the flag to false once things stabilize
end

clear fieldsAndBounds;

return
%------------------------------------------------------------