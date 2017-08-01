function [result, modelParameters, alertsOnly] = is_valid_model_for_centroid_test( targetResultsStruct, iTarget, iPlanet, alertsOnly, centroidType )
%
% function [result, modelParameters, alertsOnly] = is_valid_model_for_centroid_test( targetResultsStruct, iTarget, iPlanet, alertsOnly, centroidType )
%
% This function checks whether or not transitModelStruct contains a valid model 
% fit (by checking chiSquared) and whether or not the fitted parameters lie 
% within the bounded space as defined below. Valid parameters must also have 
% valid uncertainties. Fall back to trapezoidal fit results if the model fit
% to all transits was not performed or did not converge. An alert is thrown if
% result = false for any reason except modelChiSquare = -1. The centroidType is
% used to attach correct component to alert message.
%
% INPUT:    targetResultslStruct    structure containing the results of the transit model fit 
%                                   e.g. dvResultsStruct.targetResultsStruct(iTarget)
%           iTarget                 target index e.g. dvResultsStruct.targetResultsStruct(iTarget)
%           iPlanet                 planet index e.g. targetResultsStruct(iTarget).planetResultsStruct(iPlanet)
%           alertsOnly              Centroid test alerts structure
%           centroidType            {'prf','fluxWeighted','none'}
% OUTPUT:   result                  true == model is valid for centroid test
%                                   false == model is invalid for centroid test
%           modelParameters         structure containing fitted parameters and their uncertainty in the following fields:
%                                   transitEpochBkjd.value
%                                                   .uncertainty
%                                   orbitalPeriodDays.value
%                                                    .uncertainty
%                                   transitDurationHours.value
%                                                       .uncertainty
%                                   transitDepthPpm.value
%                                                  .uncertainty
%                                   If the parameter is not found, value == 0, uncertainty == -1
%           alertsOnly              Centroid test alerts structure
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



% set up default return values
result = false;

defaultStruct = struct('value',0,...
                       'uncertainty',-1); 

modelParameters = struct('transitEpochBkjd',defaultStruct,...
                         'orbitalPeriodDays',defaultStruct,...
                         'transitDurationHours',defaultStruct,...
                         'transitDepthPpm',defaultStruct);


% parameter bounds (hard coded)
MIN_PERIOD_DAYS     = 1/24;
MAX_PERIOD_DAYS     = 1e6;
MIN_DURATION_HOURS  = 0.5;
MAX_DURATION_HOURS  = 500;
MIN_DEPTH_PPM       = 5;
MAX_DEPTH_PPM       = 1e6;

% barycentric timestamps define unit of work
tStart = targetResultsStruct.barycentricCorrectedTimestamps(1);
tEnd = targetResultsStruct.barycentricCorrectedTimestamps(end);

% epoch must lie within the unit of work
MIN_EPOCH_BKJD = tStart;
MAX_EPOCH_BKJD = tEnd;

% get limb darkened model fit to all transits or trapezoidal model fit if
% necessary
[transitModelStruct, ~, allTransitsFitReturned, trapezoidalFitReturned] = ...
    get_fit_results_for_diagnostic_test(targetResultsStruct.planetResultsStruct(iPlanet));

% check chiSquared first since modelParameters will be empty if modelChiSquare = -1
if( isempty(transitModelStruct) || transitModelStruct.modelChiSquare == -1 )    
    message = ['     Model Chi-Squared = -1 in planetResultsStruct(',num2str(iPlanet),').allTransitsFit. Ignoring fitted transit model.'];
    disp(message);
    return;
end

% generate alert if falling back to trapezoidal fit results
fitString = 'allTransitsFit';

if( trapezoidalFitReturned )
    string = 'Falling back to trapezoidal model fit results to support diagnostic test';
    if( strcmpi(centroidType,'none') )
        alertsOnly = add_dv_alert(alertsOnly, 'Pixel correlation test', 'warning', string, iTarget, targetResultsStruct.keplerId, iPlanet);
    else
        alertsOnly = add_dv_alert(alertsOnly, 'Centroid test', 'warning', string, iTarget, targetResultsStruct.keplerId, iPlanet);
    end
    disp(alertsOnly.alerts(end).message);
    fitString = 'trapezoidalFit';
end
    
% load transit model parameters from model structure
[epoch, epochFound]       = retrieve_model_parameter(transitModelStruct.modelParameters,'transitEpochBkjd');
[period, periodFound]     = retrieve_model_parameter(transitModelStruct.modelParameters,'orbitalPeriodDays');
[duration, durationFound] = retrieve_model_parameter(transitModelStruct.modelParameters,'transitDurationHours');
[depth, depthFound]       = retrieve_model_parameter(transitModelStruct.modelParameters,'transitDepthPpm');

modelParameters.transitEpochBkjd.value           = epoch.value;
modelParameters.transitEpochBkjd.uncertainty     = epoch.uncertainty;
modelParameters.orbitalPeriodDays.value          = period.value;
modelParameters.orbitalPeriodDays.uncertainty    = period.uncertainty;
modelParameters.transitDurationHours.value       = duration.value;
modelParameters.transitDurationHours.uncertainty = duration.uncertainty;
modelParameters.transitDepthPpm.value            = depth.value;
if( allTransitsFitReturned )
    modelParameters.transitDepthPpm.uncertainty  = depth.uncertainty;
else % ESTIMATE TRAPEZOIDAL FIT DEPTH UNCERTAINTY FOR NOW AND SET OTHER UNCERTAINTIES TO ZERO.
    modelParameters.transitDepthPpm.uncertainty  = depth.value / transitModelStruct.modelFitSnr;
    modelParameters.transitEpochBkjd.uncertainty = 0;
    modelParameters.orbitalPeriodDays.uncertainty = 0;
    modelParameters.transitDurationHours.uncertainty = 0;
end

% check all params are found
if any(~[epochFound, periodFound, durationFound, depthFound])
    
    message = ['     One or more fit parameters not found in planetResultsStruct(',num2str(iPlanet),').', fitString, '. Ignoring fitted transit model.'];
    disp(message);
    if( strcmpi(centroidType,'none') ) 
        alertsOnly = add_dv_alert(alertsOnly, 'Pixel correlation test', 'warning', message, iTarget, targetResultsStruct.keplerId, iPlanet);
    else
        alertsOnly = add_dv_alert(alertsOnly, 'Centroid test', 'warning', message, iTarget, targetResultsStruct.keplerId, iPlanet);
    end
    return;
end

% check all params are in bounds
if( modelParameters.transitEpochBkjd.value      < MIN_EPOCH_BKJD     || modelParameters.transitEpochBkjd.value      > MAX_EPOCH_BKJD        ||...
    modelParameters.orbitalPeriodDays.value     < MIN_PERIOD_DAYS    || modelParameters.orbitalPeriodDays.value     > MAX_PERIOD_DAYS       ||...
    modelParameters.transitDurationHours.value  < MIN_DURATION_HOURS || modelParameters.transitDurationHours.value  > MAX_DURATION_HOURS    ||...
    modelParameters.transitDepthPpm.value       < MIN_DEPTH_PPM      || modelParameters.transitDepthPpm.value       > MAX_DEPTH_PPM )
    
    message = ['     One or more fit parameters out of bounds in planetResultsStruct(',num2str(iPlanet),').', fitString, '. Ignoring fitted transit model.'];
    disp(message);
    if( strcmpi(centroidType,'none') ) 
        alertsOnly = add_dv_alert(alertsOnly, 'Pixel correlation test', 'warning', message, iTarget, targetResultsStruct.keplerId, iPlanet);
    else
        alertsOnly = add_dv_alert(alertsOnly, 'Centroid test', 'warning', message, iTarget, targetResultsStruct.keplerId, iPlanet);
    end
    return;
end

% check all param uncertainties are valid ( real, ~inf and >= 0 )
if( ~isreal(modelParameters.transitEpochBkjd.uncertainty)     || modelParameters.transitEpochBkjd.uncertainty < 0     || isinf(modelParameters.transitEpochBkjd.uncertainty) ||...
    ~isreal(modelParameters.orbitalPeriodDays.uncertainty)    || modelParameters.orbitalPeriodDays.uncertainty < 0    || isinf(modelParameters.orbitalPeriodDays.uncertainty) ||...
    ~isreal(modelParameters.transitDurationHours.uncertainty) || modelParameters.transitDurationHours.uncertainty < 0 || isinf(modelParameters.transitDurationHours.uncertainty) ||...
    ~isreal(modelParameters.transitDepthPpm.uncertainty)      || modelParameters.transitDepthPpm.uncertainty < 0      || isinf(modelParameters.transitDepthPpm.uncertainty))
    
    message = ['     One or more fit parameter uncertainty invalid in planetResultsStruct(',num2str(iPlanet),').', fitString, '. Ignoring fitted transit model.'];
    disp(message);
    if( strcmpi(centroidType,'none') ) 
        alertsOnly = add_dv_alert(alertsOnly, 'Pixel correlation test', 'warning', message, iTarget, targetResultsStruct.keplerId, iPlanet);
    else
        alertsOnly = add_dv_alert(alertsOnly, 'Centroid test', 'warning', message, iTarget, targetResultsStruct.keplerId, iPlanet);
    end
    return;
end

% check model self consistancy
%  -- period must be longer than duration
if( modelParameters.orbitalPeriodDays.value < modelParameters.transitDurationHours.value/24 )
    
    message = ['     Fitted period < fitted duration in planetResultsStruct(',num2str(iPlanet),').', fitString, '. Ignoring fitted transit model.'];
    disp(message);
    if( strcmpi(centroidType,'none') ) 
        alertsOnly = add_dv_alert(alertsOnly, 'Pixel correlation test', 'warning', message, iTarget, targetResultsStruct.keplerId, iPlanet);
    else
        alertsOnly = add_dv_alert(alertsOnly, 'Centroid test', 'warning', message, iTarget, targetResultsStruct.keplerId, iPlanet);
    end
    return;
end

% -- duration cannot be longer than the unit of work
if( tEnd - tStart < modelParameters.transitDurationHours.value/24 )
    
    message = ['     Fitted duration is longer than unit of work in planetResultsStruct(',num2str(iPlanet),').', fitString, '. Ignoring fitted transit model.'];
    disp(message);
    if( strcmpi(centroidType,'none') ) 
        alertsOnly = add_dv_alert(alertsOnly, 'Pixel correlation test', 'warning', message, iTarget, targetResultsStruct.keplerId, iPlanet);
    else
        alertsOnly = add_dv_alert(alertsOnly, 'Centroid test', 'warning', message, iTarget, targetResultsStruct.keplerId, iPlanet);
    end
    return;
end

% passed all checks - transit model is valid for centroid test processing
result = true;

