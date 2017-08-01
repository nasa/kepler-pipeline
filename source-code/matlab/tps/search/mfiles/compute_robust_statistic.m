function robustStatisticResultsStruct = compute_robust_statistic( waveletObject, ...
    transitModel, deemphasisWeights, robustStatisticResultsStruct )

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function robustStatisticResultsStruct = compute_robust_statistic( waveletObject, ...
%    minSesCount, nCadences, transitModel, deemphasisWeights, robustStatisticResultsStruct )
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Decription: This function computes the robust statistic
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
if ~exist('robustStatisticResultsStruct', 'var') || isempty(robustStatisticResultsStruct)
    robustStatisticResultsStruct = struct( 'robustStatistic', [], 'fittedDepth', [], ...
        'depthUncertainty', [], 'robustfitFail', [] ) ;
end

% generate whitened flux and whitened transit model 

whitenedTransitModel = apply_whitening_to_time_series( waveletObject, transitModel, true ) ;
whitenedFluxTimeSeries = apply_whitening_to_time_series( waveletObject ) ;

% Apply the deemphasis weights with cadence by cadence
% multiplication with the whitened flux and whitened model

whitenedFluxTimeSeries = whitenedFluxTimeSeries.*deemphasisWeights ;
whitenedTransitModel = whitenedTransitModel.*deemphasisWeights ;

% Now get the rectangular window indices and remove cadences with 
% deemphasis weights*data near zero
windowIndices = find(transitModel ~= 0) ;
windowIndices = windowIndices(abs(whitenedFluxTimeSeries(windowIndices))>sqrt(eps)) ;

% robustfit the whitened, windowed model transit to the
% whitened, windowed flux and compute the robust statistic 

% Note that robustfit can fail if there's not enough points to do the fit,
% or potentially under other circumstances.  We want to treat a failure
% there as equivalent to robust statistic == 0 and continue, not error
% out.  Thus the try-catch block,

try

    [fittedTransitDepth, stats] = robustfit(whitenedTransitModel(windowIndices), ...
        whitenedFluxTimeSeries(windowIndices), [], [], 'off') ;
    robustStatistic = sum(...
        whitenedTransitModel(windowIndices) .* ...
        whitenedFluxTimeSeries(windowIndices).* ...
        stats.w ) / sqrt(sum(whitenedTransitModel(windowIndices).^2.*stats.w)) ;
    if isnan( robustStatistic )
        robustStatistic = 0 ;
    end
    if isempty(stats.covb)
        % poor fit
        depthUncertainty = -1 ;
    else
        depthUncertainty = sqrt(stats.covb) ;
    end

    robustfitFail = false ;

catch 

    robustStatistic = 0 ;
    robustfitFail = true ;
    fittedTransitDepth = 0 ;
    depthUncertainty = -1;

end  

% populate results struct

robustStatisticResultsStruct.robustStatistic  = robustStatistic ;
robustStatisticResultsStruct.robustfitFail    = robustfitFail ;
robustStatisticResultsStruct.fittedDepth      = fittedTransitDepth ;
robustStatisticResultsStruct.depthUncertainty = depthUncertainty ;

return
