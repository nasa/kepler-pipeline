function smoothed_vector = smooth_vsLC( input_vector, predictors, interval_starts, interval_ends )
% 
% function smoothed_vector = smooth_vsLC( input_vector, predictors, interval_starts, interval_ends )
% 
% Smoothing routine for DynOBlack parameters which vary smoothly but do not produce good fits to temperature and/or time.
% This routine assumes temp and time are the first two elements in the predictor list. Any predictor elements beyond
% index == 2 (e.g. steps) are ignored.
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

% ARGUMENTS
% 
% * Function returns: 
% * |smoothed_vector| - smoothed result locally fit to predictors.
% * Function arguments:
% * |input_vector -| data to be smoothed 
% * |predictors -| temperature and time vectors
% * |interval_starts -| locations in input_vector where stepwise intervals start
% * |interval_ends -| locations in input_vector where stepwise intervals end


% LOCAL CONSTANTS
lc_max              = interval_ends(end);
fitRange_max        = floor(lc_max/400)*100;
fitRange            = [20, 50, (100:100:fitRange_max)];
range_count         = length(fitRange);
stdDev_resid        = zeros(range_count,1);
smoothed_results    = zeros(range_count,lc_max);
ref_noise           = std( diff(input_vector) ) / sqrt(2);
noise_threshold     = 1.5 * ref_noise;

% SMOOTHING 
for rangeID = 1:range_count
    
    this_fitRange   = fitRange(rangeID);
    fitWidth        = 2*this_fitRange+1;
    kernels         = zeros(lc_max,fitWidth);
    segments        = zeros(fitWidth,lc_max);
  
    for lcID = 1:lc_max
        firstLC     = max(lcID-this_fitRange,1);
        lastLC      = min(lcID+this_fitRange,lc_max);
        LC_count    = lastLC-firstLC+1;
        norm1       = std(predictors{1}(firstLC:lastLC));
        norm2       = std(predictors{2}(firstLC:lastLC));
        
        local_model = [ones(LC_count,1), ...
                        (predictors{1}(firstLC:lastLC)-predictors{1}(lcID))/norm1, ...
                        ((predictors{1}(firstLC:lastLC)-predictors{1}(lcID))/norm1).^2, ...
                        (predictors{2}(firstLC:lastLC)-predictors{2}(lcID))/norm2, ...
                        ((predictors{2}(firstLC:lastLC)-predictors{2}(lcID))/norm2).^2];
        
        local_kerns      = (local_model'*local_model) \ local_model';
        kernels(lcID,:)  = [local_kerns(1,:) zeros(1,fitWidth-LC_count)];
        segments(:,lcID) = [input_vector(firstLC:lastLC); zeros(fitWidth-LC_count,1)];
    end

    smoothed_results(rangeID,:) = sum(kernels'.*segments)';
    stdDev_resid(rangeID)       = std( input_vector - smoothed_results(rangeID,:)' );
end

% select largest fit range which satisfies noise criteria
selector = find(stdDev_resid < noise_threshold, 1, 'last' );

% if no fit range meets the noise criteria select the fit range with the lowest stddev
if isempty(selector)
    [~, selector] = min(stdDev_resid);
    display(['WARNING:initialize_dynoblack_models:DynOBlack_init:smooth_vsLC: No fit range meets noise threshold criteria of ',num2str(noise_threshold)]);
    display(['Selecting range ',num2str(selector),' with minimum noise of ',num2str(stdDev_resid(selector))]);
end

smoothed_vector = smoothed_results(selector,:);
