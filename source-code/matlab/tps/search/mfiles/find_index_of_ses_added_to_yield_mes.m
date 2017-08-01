function [indexAdded, sesCombinedToYieldMes] = ...
    find_index_of_ses_added_to_yield_mes(varargin)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function find_index_of_ses_added_to_yield_mes: get the indices/cadences 
% of single event statistics components combined to yield maximum multiple 
% event statistic; remember to set the cadences that were deemphasized 
% to -1.
%
% Inputs: Can take either tpsResults and superResolutionFactor or all 6
% real variables as their arguments
%
% Outputs: indexAdded - indices that were used to form the MES
%          sesCombinedToYieldMes - the SES values at indexAdded
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

if nargin == 2
    tpsResults = varargin{1} ;
    superResolutionFactor = varargin{2} ;
    bestPhaseInCadences = tpsResults.bestPhaseInCadences*superResolutionFactor;
    bestOrbitalPeriodInCadences = (tpsResults.bestOrbitalPeriodInCadences)*...
        superResolutionFactor;
    deemphasisWeights = tpsResults.deemphasisWeightSuperResolution ;
    correlationTimeSeriesHiRes = tpsResults.correlationTimeSeriesHiRes ;
    normalizationTimeSeriesHiRes = tpsResults.normalizationTimeSeriesHiRes ;
elseif nargin == 6
    superResolutionFactor = varargin{3} ;
    bestOrbitalPeriodInCadences = varargin{1} * superResolutionFactor ;
    bestPhaseInCadences = varargin{2} * superResolutionFactor ;
    correlationTimeSeriesHiRes = varargin{4} ;
    normalizationTimeSeriesHiRes = varargin{5} ;
    deemphasisWeights = varargin{6} ;
else
    error('tps:find_index_of_ses_added_to_yield_mes:invalidArguments', ...
        'find_index_of_ses_added_to_yield_mes:2 or 6 arguments required') ;
end
isForSes = true ;

 % apply weights
[correlationTimeSeriesHiRes, normalizationTimeSeriesHiRes] = ...
    apply_deemphasis_weights( correlationTimeSeriesHiRes, ...
    normalizationTimeSeriesHiRes, deemphasisWeights, isForSes );

[indexAdded, sesCombinedToYieldMes] = find_ses_in_mes( ...
    correlationTimeSeriesHiRes, normalizationTimeSeriesHiRes, ...
    bestOrbitalPeriodInCadences, bestPhaseInCadences ) ;

% convert from zero-based indexing to one-based
indexAdded = indexAdded + 1 ;

return