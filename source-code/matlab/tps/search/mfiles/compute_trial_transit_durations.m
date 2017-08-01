%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function [trialTransitDurations] = compute_trial_transit_durations(tpsModuleParameters)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Background:
% This function computes a vector of trial transit durations using an
% algorithmic method that resulted from KSOC-1031.  The number of durations
% is based on a calculation in the TPS SPIE paper: deltaD = (1-rho)*D.
% After the number is determined, a rounded logarithmic spacing is used to
% populate the D space between Dmin and Dmax.
%
% References:
%  [1].  J. Jenkins et al, Transiting planet search in the kepler pipeline,
%        SPIE Proceedings, 2010
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

%__________________________________________________________________________
% Input:  An object of tpsClass 'tpsObject' with the following fields:
%__________________________________________________________________________
%
%  tpsModuleParameters contains the following fields:
%
%                             debugLevel: 0
%       requiredTrialTransitPulseInHours: [3x1 double]
%          searchPeriodStepControlFactor: 0.9000
%         varianceWindowLengthMultiplier: 5
%              minimumSearchPeriodInDays: 1
%                 searchTransitThreshold: 7.1000
%                constrainedPolyMaxOrder: 10
%              maximumSearchPeriodInDays: 365
%                          waveletFamily: 'daub'
%                    waveletFilterLength: 12
%                         tpsLiteEnabled: 0
%                  superResolutionFactor: 3
%        adXFactorForSimpleMatchedFilter: 20
%   deemphasizePeriodAfterSafeModeInDays: 2
%  deemphasizePeriodAfterTweakInCadences: 8
%        edgeDetrendingSignificanceValue: 0.0100
%       requiredTrialTransitPulseInHours: [3x1 double]
%            minTrialTransitPulseInHours: 1.5 (-1 to disable algorithmic D)
%            maxTrialTransitPulseInHours: 15  (-1 to disable algorithmic D)
%      searchTrialTransitDurationStepControlFactor: 0.8000
%               maxFoldingsInPeriodSearch: 10
%                 performQuarterStitching: 1
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

function [trialTransitDurationsInHours] = compute_trial_transit_durations(tpsModuleParameters)

rhoD = tpsModuleParameters.searchTrialTransitPulseDurationStepControlFactor;
minTrialTransitPulseInHours = tpsModuleParameters.minTrialTransitPulseInHours;
maxTrialTransitPulseInHours = tpsModuleParameters.maxTrialTransitPulseInHours;
requiredTransitPulseDurationsInHours = tpsModuleParameters.requiredTrialTransitPulseInHours;

% count the number of D's if we are algorithmically determinging them

if( minTrialTransitPulseInHours ~= -1 && maxTrialTransitPulseInHours ~= -1 )

    dCnt=1;
    dValue=minTrialTransitPulseInHours;
    
    while dValue <= maxTrialTransitPulseInHours
        dValue=dValue+(1-rhoD)*dValue;
        dCnt=dCnt+1;
    end

    trialTransitDurationsInHours = logspace(log10(minTrialTransitPulseInHours),log10(maxTrialTransitPulseInHours),dCnt);
    
    % round to nearest half hour
    trialTransitDurationsInHours=round(2.*trialTransitDurationsInHours)./2;
    trialTransitDurationsInHours=unique(trialTransitDurationsInHours);
    
    % force inclusion of requiredTrialTransitPulseInHours
    missingRequiredPulses = setdiff(requiredTransitPulseDurationsInHours, intersect(trialTransitDurationsInHours,requiredTransitPulseDurationsInHours));
    
    if(missingRequiredPulses)
        trialTransitDurationsInHours=[trialTransitDurationsInHours(1,:) missingRequiredPulses'];
        trialTransitDurationsInHours = sort(trialTransitDurationsInHours);
    end
    
    trialTransitDurationsInHours = trialTransitDurationsInHours(trialTransitDurationsInHours <= maxTrialTransitPulseInHours);
    trialTransitDurationsInHours = trialTransitDurationsInHours(:);
else
    
    % bypassing the algorithmically determined D space
    trialTransitDurationsInHours = requiredTransitPulseDurationsInHours;
    
end

return