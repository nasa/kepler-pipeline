function bootstrapResultsStruct = compute_threshold_by_bootstrap( bootstrapInputStruct, ...
    bootstrapResultsStruct, maxMes )

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function bootstrapResultsStruct = compute_bootstrap_threshold( 
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Decription: This function constructs the MES distribution and estimates
% the threshold that gives an equivalent false alarm rate as that
% corresponding to a standard normal with threshold given by
% searchTransitThreshold
% 
%
% Inputs:
%
% Outputs:
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

% initialize output if necessary
if ~exist('bootstrapResultsStruct', 'var') || isempty(bootstrapResultsStruct)
    bootstrapResultsStruct = struct( 'thresholdForDesiredPfa', [], ...
        'mesMeanEstimate', [], 'mesStdEstimate', [], 'falseAlarmProbability', ...
        [], 'falseAlarmProbabilities', [], 'mesBins', [], 'isThreshForDesiredPfaInterpolated', ...
        [], 'isFalseAlarmProbInterpolated', []) ;
end

searchThreshold = bootstrapInputStruct.searchTransitThreshold;

% Instantiate the object
bootstrapObject = bootstrapClass( bootstrapInputStruct );

% Validate the object
validBootstrapObject = validate_bootstrapObject(bootstrapObject);

% Generate the histogram and threshold
if validBootstrapObject
    
    % Create bootstrapResultsStruct to place bootstrap results
    tempResults = create_bootstrapResultsStruct(bootstrapObject);
    
    % generate the mes distribution by convolution
    tempResults = generate_histogram_by_convolution(bootstrapObject, tempResults);
    
    % compute the cumulative sum
    [statistics, probabilities] = compute_cumulative_probability( bootstrapObject, tempResults ); 
    
    if length(probabilities(probabilities~=0)) < 10
        % if we dont have enough points then just abort
        disp('     Insufficient points available for bootstrap. Skipping bootstrap test.');
        thresholdForDesiredPfa = -1;
        gaussModel = [-1;-1];
        mesFalseAlarmProbability = -1;
        isThresholdInterpolated = false;
        isFalseAlarmProbInterpolated = false;
        
    else
        % now fit the false alarm rate in log space with a gaussian error
        % function.  Interpolate to get the thresholdForDesiredPfa.  If
        % interpolation is not possible then use the fit.
        [gaussFitValues, gaussModel, thresholdForDesiredPfa, mesFalseAlarmProbability, ...
            isThresholdInterpolated, isFalseAlarmProbInterpolated] = ...
            fit_bootstrap_cdf( statistics, probabilities, searchThreshold, maxMes );
        
    end
else
    disp('     Invalid BootstrapObject. Skipping bootstrap test.');
    thresholdForDesiredPfa = -1;
    gaussModel = [-1;-1];
    mesFalseAlarmProbability = -1;
    isThresholdInterpolated = false;
    isFalseAlarmProbInterpolated = false;
    statistics = -1;
    probabilities = -1;
end

% truncate the vectors to save space
endIndex = find(probabilities > 0, 1, 'last');
statistics = statistics(1:endIndex);
probabilities = probabilities(1:endIndex);

% record the results
bootstrapResultsStruct.thresholdForDesiredPfa = thresholdForDesiredPfa;
bootstrapResultsStruct.mesMeanEstimate = gaussModel(1);
bootstrapResultsStruct.mesStdEstimate = gaussModel(2);
bootstrapResultsStruct.falseAlarmProbability = mesFalseAlarmProbability;
bootstrapResultsStruct.falseAlarmProbabilities = probabilities;
bootstrapResultsStruct.mesBins = statistics;
bootstrapResultsStruct.isThreshForDesiredPfaInterpolated = isThresholdInterpolated;
bootstrapResultsStruct.isFalseAlarmProbInterpolated = isFalseAlarmProbInterpolated;

return




