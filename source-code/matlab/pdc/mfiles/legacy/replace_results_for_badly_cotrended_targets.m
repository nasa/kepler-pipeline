function [timeSeries, badTargetList, alerts] = ...
replace_results_for_badly_cotrended_targets(timeSeries, ...
variableTargetList, harmonicTimeSeries, shortTimeScalePowerRatio, ...
pdcModuleParameters, alerts)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function [timeSeries, badTargetList, alerts] = ...
% replace_results_for_badly_cotrended_targets(intermediateFluxTimeSeries, ...
% variableTargetList, harmonicTimeSeries, shortTimeScalePowerRatio, ...
% pdcModuleParameters, alerts)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Find the targets for which cotrending performed poorly, and replace the
% cotrending results with the results from the coarse detrending performed
% earlier. Restore the median flux level to the detrended results.
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

% Get necessary fields.
cotrendPerformanceLimit = pdcModuleParameters.cotrendPerformanceLimit;

% Find the targets for which cotrending performed poorly. Return if there
% are none.
isBadResult = ...
    shortTimeScalePowerRatio(variableTargetList) > cotrendPerformanceLimit;
badTargetList = variableTargetList(isBadResult);
if isempty(badTargetList)
    return
end

% Loop through the bad targets and update the cotrending results with the
% coarse detrending results. Restore the median flux level.
for iTarget = badTargetList( : )'
    
    gapIndicators = timeSeries(iTarget).gapIndicators;
    medianFlux = median(timeSeries(iTarget).values(~gapIndicators));
    
    timeSeries(iTarget).values = ...
        harmonicTimeSeries(iTarget).detrendedFluxValues - ...
        harmonicTimeSeries(iTarget).values + medianFlux;
    timeSeries(iTarget).values(gapIndicators) = 0;
    
    timeSeries(iTarget).uncertainties = ...
        harmonicTimeSeries(iTarget).detrendedFluxUncertainties;
    timeSeries(iTarget).uncertainties(gapIndicators) = 0;
    
end % for iTarget

% Issue an alert.
[alerts] = add_alert(alerts, 'warning', ...
    ['coarse detrending used to perform systematic error correction for ', ...
    num2str(length(badTargetList)), ' target(s)']);
disp(alerts(end).message);

% Return.
return
