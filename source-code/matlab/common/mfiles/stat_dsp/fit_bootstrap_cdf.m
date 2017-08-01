function [fitValues, gaussModel, thresholdForDesiredPfa, mesFalseAlarmProbability, ...
    isThresholdInterpolated, isFalseAlarmProbInterpolated] = ...
    fit_bootstrap_cdf( statistics, probabilities, mesThreshold, mes )

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% This function attempts to fit a generalized complementary error function
% in log space to the cumulative distribution function produced by the 
% bootstrap. When this is not possible, a simple linear fit is performed.  
% The thresholdForDesiredPfa and mesFalseAlarmProbability are then computed.
%
% INPUTS:
%
% OUTPUTS:
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

% check inputs
if length(probabilities) < 2
    % if we dont have enough points then just abort
    error('fit_bootstrap_cdf: Insufficient points available for fitting the bootstrap CDF.');
end

if ~isequal( length(probabilities), length(statistics) )
    error('fit_bootstrap_cdf: Lenths of input vectors are not equal for fit to bootstrap CDF.');
end

% initialize
computeFalseAlarmRate = true;
computeBootstrapThreshold = true;
thresholdForDesiredPfa = -1;
mesFalseAlarmProbability = -1;
isThresholdInterpolated = false;
isFalseAlarmProbInterpolated = false;

% warning messages to disable
warningMessages = {'stats:nlinfit:IterationLimitExceeded' ; 'stats:nlinfit:IllConditioned'};

% check if warnings are on or off and turn them all off for now
isWarningOff = false( length(warningMessages),1 );
for i=1:length(warningMessages)
    warningStatus = warning( 'query', warningMessages{i} );
    isWarningOff(i) = isequal( warningStatus.state,'off' );
    warning( 'off', warningMessages{i} );
end

if ~exist('mes','var') || isempty(mes)
    computeFalseAlarmRate = false;
end

if ~exist('mesThreshold', 'var') || isempty(mesThreshold)
    computeBootstrapThreshold = false;
else
    % compute gaussian false alarm rate for the mesThreshold
    gaussianFalseAlarm = 0.5 * erfc( mesThreshold / sqrt(2) );
end

% do the fit using an error function in log space
[gaussModel, fitValues] = model_false_alarm_rate_with_gaussian(statistics, probabilities);

% Now compute the thresholdForDesiredPfa which is threshold that, when applied to
% this cdf, will achieve the same false alarm rate as that of a gaussian
% distribution with mesThreshold for the threshold.  

if ~isequal(gaussModel(2),-1)

    if computeBootstrapThreshold
        % get index for interpolation
        interpIndex = find(probabilities > gaussianFalseAlarm, 1, 'last');

        % interpolate using the data if possible
        if any(probabilities(1:end-1) > gaussianFalseAlarm & probabilities(2:end) < gaussianFalseAlarm) && ...
                interpIndex < length(probabilities)
            % interpolate
            thresholdForDesiredPfa = interp1(probabilities(interpIndex + [0,1]), ...
                statistics(interpIndex + [0,1]), gaussianFalseAlarm, 'linear');
                isThresholdInterpolated = true;
        else
            % use the fit parameters to calculate it directly
            if ~any(isnan(gaussModel))
                thresholdForDesiredPfa = gaussModel(1) + sqrt(2) * gaussModel(2) * ...
                    erfcinv(2 * gaussianFalseAlarm);
            end
        end

    end

    % Now compute the estimtae of the false alarm rate
    if computeFalseAlarmRate
        % find last point above 1e-13.5
        xMax = statistics(find(probabilities >= 10^(-13.5), 1, 'last'));

        % interpolate using the data if possible
        if mes <= xMax
            % interpolate
            mesFalseAlarmProbability = interp1(statistics, log10(probabilities), mes, 'linear');
            mesFalseAlarmProbability = 10^mesFalseAlarmProbability;
            isFalseAlarmProbInterpolated = true;
        else
            % use the fit parameters to calculate it directly
            if ~any(isnan(gaussModel))
                mesFalseAlarmProbability = .5 * erfc(sqrt(2) \ (mes - gaussModel(1)) / gaussModel(2));
            end
        end

    end
    
end

% re-enable warning messages that were previously on
for i=1:length(warningMessages)
    if ~isWarningOff(i)
        warning( 'on', warningMessages{i} );
    end
end

return

%==========================================================================
% model_cdf_with_gaussian
%==========================================================================

function [lambda,falseAlarmFitted] = model_false_alarm_rate_with_gaussian(x,falseAlarmProb)

indicesForFit = find(falseAlarmProb < 1e-4 & falseAlarmProb > 1e-13);

if isempty(indicesForFit)
    warning('No points to fit!');
    lambda = [-1; -1];
    falseAlarmFitted = -1 * ones(size(x));
    return
end

% get the endpoints
x1 = x( indicesForFit(1) );
y1 = log10( falseAlarmProb(indicesForFit(1)) );
x2 = x( indicesForFit(end) );
y2 = log10(falseAlarmProb(indicesForFit(end)) );

% use the endpoints to initialize
erfcinv1 =  sqrt(2) * erfcinv(2 * 10^y1);
erfcinv2 = sqrt(2) * erfcinv(2 * 10^y2);
sigmaSquared = (x1 - x2)/(erfcinv1 - erfcinv2);
mu = x1 - erfcinv1 * sigmaSquared;
lambda0 = [mu,sigmaSquared];

% set nlinfit options
opts = statset('nlinfit');
opts.WgtFun = 'bisquare';
opts.Robust = 'on';

% define the model - error function in log space
modelFun = @(lambda,X)real(log10(max(eps, 0.5 * erfc( sqrt(2) \ (x(indicesForFit) - lambda(1)) / lambda(2) ) )));

% do the fit
try
    lambda = nlinfit([],log10(falseAlarmProb(indicesForFit)), modelFun, lambda0, opts);
    falseAlarmFitted = 0.5 * erfc( sqrt(2) \ (x - lambda(1)) / lambda(2) );
catch
    warning('Couldn''t fit falseAlarmProb')
    lambda = [-1; -1];
    falseAlarmFitted = -1 * ones(size(x));
end

% in rare circumstances, the fit parameters become infinite
if any(isinf(lambda))
    lambda = [-1; -1];
    falseAlarmFitted = -1 * ones(size(x));
end

return