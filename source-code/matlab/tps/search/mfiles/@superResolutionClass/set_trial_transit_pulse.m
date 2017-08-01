function superResolutionObject = set_trial_transit_pulse( superResolutionObject, ...
    customTransitModel)

% function superResolutionObject = compute_trial_transit_pulse( ...
%    superResolutionObject )
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% 
% Decription: Basic function to compute the trial transit pulse.
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

superResolutionFactor = superResolutionObject.superResolutionFactor ;
trialTransitPulseWidth = superResolutionObject.pulseDurationInCadences ;
usePolyFitTransitModel = superResolutionObject.usePolyFitTransitModel ;
useCustomTransitModel = superResolutionObject.useCustomTransitModel ;

if useCustomTransitModel && (~exist('customTransitModel', 'var') || ...
        isempty(customTransitModel) )
    error('set_trial_transit_pulse:noCustomTransitModel', ...
        'set_trial_transit_pulse: need custom model when useCustomTransitModel == true!' ) ;
end

if usePolyFitTransitModel
    % construct the master pulse fit
    polyFit = load_master_pulse_polyfit() ;
    modelLength = length( polyFit ) ;
    xOrig = (1:modelLength)' ;
    % do cubic spline interpolation to extract the require pulse
    % assume that the master pulse is symmetric with an odd number of
    % cadences and the minimum right in the middle
    startCadence = (modelLength - 1)/(2*trialTransitPulseWidth) + 1 ;
    xModel = startCadence:((modelLength - 1)/trialTransitPulseWidth):modelLength ;
    basePulse = interp1(xOrig, polyFit, xModel, 'spline') ;
    basePulse = basePulse(:) ;
    basePulse = basePulse/abs(min(basePulse)) ;
elseif useCustomTransitModel
    if ~isequal(min(customTransitModel),0)
        basePulse = customTransitModel / abs(min(customTransitModel));
    else
        basePulse = customTransitModel;
    end
    modelLength = length( basePulse ) ;
    if ~isequal(modelLength,trialTransitPulseWidth)
        xOrig = (1:modelLength)' ;
        % do cubic spline interpolation to extract the require pulse
        % assume that the master pulse is symmetric with an odd number of
        % cadences and the minimum right in the middle
        startCadence = (modelLength - 1)/(2*trialTransitPulseWidth) + 1 ;
        xModel = startCadence:((modelLength - 1)/trialTransitPulseWidth):modelLength ;
        basePulse = interp1(xOrig, basePulse, xModel, 'spline') ;
        basePulse = basePulse(:) ;
        basePulse = basePulse/abs(min(basePulse)) ;
    end
else
    basePulse = -ones(trialTransitPulseWidth,1) ;
end

baseLength = length(basePulse);

if(superResolutionFactor == 3)
    
    trialTransitPulse = zeros(baseLength+1,superResolutionFactor) ;
    trialTransitPulse(1:baseLength,1) = basePulse ;
    trialTransitPulse(1:baseLength,2) = basePulse ;
    trialTransitPulse(2:end,3) = basePulse ;
    
    % repeat the first cadence or last cadence for the shift
    trialTransitPulse(end,2) = trialTransitPulse(end-1,2) ;
    trialTransitPulse(1,3) = trialTransitPulse(2,3) ;

    % apply the shift factor
    samplingFraction = 1 - (0:superResolutionFactor-1)/superResolutionFactor;
    trialTransitPulse(1,:) = samplingFraction .* trialTransitPulse(1,:) ;
    samplingFraction = fliplr(1 - (0:superResolutionFactor)/superResolutionFactor);
    samplingFraction(end) = [];
    trialTransitPulse(end,:) = samplingFraction .* trialTransitPulse(end,:) ;

else
    trialTransitPulse = [basePulse; 0] ;
end

superResolutionObject.trialTransitPulse = trialTransitPulse ;

return