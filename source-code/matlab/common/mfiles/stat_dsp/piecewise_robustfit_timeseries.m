%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function [fittedTimeSeries] =
% piecewise_robustfit_timeseries(timeSeries, chunkSize, madXFactor, ...
% maxFitPolyOrder, dataGapIndicators)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Description:
% This function chunks up the input time series into chunks the size of
% chunkSize and robustly estimates the optimal polynomial order for a fit
% to each chunk using the AI criteria.  It then repeates this for a series
% of chunks that are shifted by half a chunkSize.  Each chunk in both
% series is fitted with it's own optimal polynomial.  Each chunk is 
% triangularly tapered so that the ends have zero weight and the middle has
% unity weight.  The two chunk series are then added together to form a 
% robust fit of the input time series.
%
% Inputs:
%       1) timeSeries: A time series
%       2) chunkSize: The size of chunks to divide the time series into
%       3) madXFactor:  MAD threshold multiplier for outlier screening
%          prior to robust estimation/fit.  This can be set relatively high
%          (10-20) since robustfit mitigates outliers.
%       4) maxFitPolyOrder:  Set a maximum to the polynomial order being
%          estimated and used for the fits to each chunk.
%       5) dataGapIndicators:  optional boolean time series identifying
%          gaps in the data that should be deweighted when performing 
%          robust fits
%
%         
% Output:
%       1) fittedTimeSeries: The stitched together robustly fit polynomial
%          representation of the original time series.
%
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

function [fittedTrend] = ...
    piecewise_robustfit_timeseries(timeSeries, chunkSize, madXFactor, ...
    maxFitPolyOrder, gapIndicators)

if ( length( timeSeries(~gapIndicators) ) < 2 )
    % time series is gapped, aborting fit
    fittedTrend = timeSeries;
    return;
end

chunkSize = round(chunkSize);
nCadences = length(timeSeries);
numChunks = floor(nCadences/chunkSize);

if ~exist('gapIndicators', 'var') || isempty(gapIndicators)
    gapIndicators = false(nCadences,1);
end

if nCadences < 11
    %warning('stat_dsp:piecewise_robustfit_timeseries', ...
    %    'stat_dsp:piecewise_robustfit_timeseries: nCadences is too small for a piecewise robustfit...proceeding with a single robustfit...');
    fittedTrend = robust_poly_fit_chunk(timeSeries, madXFactor, maxFitPolyOrder, gapIndicators);
    return;
end

if chunkSize < 5
    %warning('stat_dsp:piecewise_robustfit_timeseries', ...
    %    'stat_dsp:piecewise_robustfit_timeseries:chunkSize must be greater than 4 cadences...setting chunkSize=5...');
    chunkSize = 5;
end

if chunkSize > nCadences
    %warning('stat_dsp:piecewise_robustfit_timeseries', ...
    %    'stat_dsp:piecewise_robustfit_timeseries:chunkSize is larger than nCadences...setting chunkSize=nCadences...');
    chunkSize = nCadences;
    numChunks = 1;
end

if isequal(numChunks,1)
    % if there is just one chunk then set the size to nCadences to make
    % things easier
    chunkSize = nCadences;
end

[polyFits, ~, chunkPolyOrder] = fit_timeseries_chunks( timeSeries, gapIndicators, ...
    chunkSize, madXFactor, maxFitPolyOrder, 0 );

[polyFitsShifted, ~, chunkPolyOrderShifted] = fit_timeseries_chunks( timeSeries, gapIndicators, ...
    chunkSize, madXFactor, maxFitPolyOrder, 0.5 );

dataIndices = find(~gapIndicators);

polyFits = vertcat(polyFits{:});
polyFitsShifted = vertcat(polyFitsShifted{:});

% interpolate over gaps in the time series before constructing residual
timeSeries(gapIndicators) = interp1(dataIndices,timeSeries(dataIndices),find(gapIndicators),'spline');
polyFits(gapIndicators) = interp1(dataIndices,polyFits(dataIndices),find(gapIndicators),'spline');
polyFitsShifted(gapIndicators) = interp1(dataIndices,polyFitsShifted(dataIndices),find(gapIndicators),'spline');

% construct absolute residual timeseries
absResidual = abs(timeSeries - polyFits);
absResidualShifted = abs(timeSeries - polyFitsShifted);

% construct the taper weights based on the percentage of the total squared
% residual
taperSeries = absResidualShifted.^2./((absResidual.^2 + absResidualShifted.^2));
taperSeriesShifted = absResidual.^2./((absResidual.^2 + absResidualShifted.^2));

% replace NaN's with 0.5 since this is where the total squared residual is
% zero
taperSeries(isnan(taperSeries)) = 0.5;
taperSeriesShifted(isnan(taperSeriesShifted)) = 0.5;

% form the fittedTrend by tapering the two fits together
fittedTrend = polyFits.*taperSeries + polyFitsShifted.*taperSeriesShifted;

% get the Savitzky-Golay filter parameters from the chunk fits
sgPolyOrder = max( [chunkPolyOrder;chunkPolyOrderShifted] );
sgWindowSize = floor( chunkSize / 2 ) ; 
if isequal( mod(sgWindowSize,2), 0 )
    sgWindowSize = sgWindowSize + 1;
end

% make sure the poly order is smaller than the window size
sgPolyOrder = min( sgPolyOrder, sgWindowSize - 2 );

% now smooth the fittedTrend using a Savitzky-Golay filter
warning( 'off', 'MATLAB:nearlySingularMatrix' );
fittedTrend = sgolayfilt( fittedTrend, sgPolyOrder, sgWindowSize );
warning( 'on', 'MATLAB:nearlySingularMatrix' );

return


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function to fit the time series chunks
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [fittedTrendChunks, chunkAIC, chunkPolyOrder] = fit_timeseries_chunks( timeSeries, ...
    gapIndicators, chunkSize, madXFactor, maxFitPolyOrder, offsetFactor )

% generate chunks
[chunkIndices,numPadCadences] = generate_timeseries_chunks( timeSeries, gapIndicators, ...
    chunkSize, offsetFactor );

% initialize results
numChunks = size(chunkIndices,1);
fittedTrendChunks = cell(numChunks,1);
chunkAIC = cell(numChunks,1);
chunkPolyOrder = zeros(numChunks,1);

for i=1:numChunks
    % get the chunk
    timeSeriesChunk = timeSeries(chunkIndices(i,1):chunkIndices(i,2));
    gapIndicatorChunk = gapIndicators(chunkIndices(i,1):chunkIndices(i,2));
    
    % perform the fit
    [fittedTrend, fittedPolyOrder, minAIC] = robust_poly_fit_chunk(timeSeriesChunk, madXFactor, ...
        maxFitPolyOrder, gapIndicatorChunk);
    
    % record results for the chunk
    fittedTrendChunks{i} = fittedTrend((numPadCadences(i,1)+1):(end-numPadCadences(i,2)));   
    chunkAIC{i} = minAIC * ones( size(fittedTrendChunks{i}) );
    chunkPolyOrder(i) = fittedPolyOrder;
end

return

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function to do the chunking of the time series
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [chunkIndices, numPadCadences] = generate_timeseries_chunks( timeSeries, ...
    gapIndicators, chunkSize, offsetFactor )

% make sure chunkSize is an integer number of cadences
chunkSize = round(chunkSize);
nCadences = length(timeSeries);
numChunks = floor(nCadences/chunkSize);

remainderPoints = nCadences - numChunks*chunkSize;
firstChunkSize = chunkSize + ceil(remainderPoints/2);

if ~isequal(offsetFactor,0)
    % if we are offsetting the chunking then there will be an extra chunk
    numChunks = numChunks + 1;
    firstChunkSize = firstChunkSize - floor(offsetFactor * chunkSize);
end

% allocate memory for chunk indices
chunkIndices = zeros(numChunks,2);
numPadCadences = zeros(numChunks,2);
indexAvailable = find(~gapIndicators);

% This only adds padding if the gap is on the end
for i=1:numChunks
    startIndex = 1 + (i>1) * firstChunkSize + max(i-2,0) * chunkSize;
    endIndex = (i<numChunks) * (firstChunkSize + (i-1) * chunkSize) + (i==numChunks) * nCadences;
    numGapCadences = sum(gapIndicators(startIndex:endIndex));
    chunkIndices(i,1) = startIndex;
    chunkIndices(i,2) = endIndex;
    if (gapIndicators(startIndex) && ~isequal(startIndex,1))
        % gap at start, so pad
        %indexAvailableLeft = (indexAvailable < startIndex) & (indexAvailable > (startIndex - floor(chunkSize/2)));
        indexAvailableLeft = indexAvailable < startIndex;
        numAvailableLeft = sum(indexAvailableLeft);
        if ~isequal(numAvailableLeft,0)
            leftIndex = indexAvailable(indexAvailableLeft);
            %leftIndex = leftIndex(end-min(numAvailableLeft,fix(numGapCadences/2)) + 1);
            leftIndex = leftIndex(end-min(numAvailableLeft,numGapCadences) + 1);
            chunkIndices(i,1) = leftIndex;
            numPadCadences(i,1) = startIndex - leftIndex;
        end
    end
    if (gapIndicators(endIndex) && ~isequal(endIndex,nCadences))
        % gap at end, so pad
        %indexAvailableRight = (indexAvailable > endIndex) & (indexAvailable < (endIndex + ceil(chunkSize/2)));
        indexAvailableRight = indexAvailable > endIndex;
        numAvailableRight = sum(indexAvailableRight);
        if ~isequal(numAvailableRight,0)
            rightIndex = indexAvailable(indexAvailableRight);
            %rightIndex = rightIndex(min(numAvailableRight,fix(numGapCadences/2)));
            rightIndex = rightIndex(min(numAvailableRight,numGapCadences));
            chunkIndices(i,2) = rightIndex;
            numPadCadences(i,2) = rightIndex - endIndex;
        end
    end
end    

return

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Function to do the robust fitting of the chunks
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [polyFit, fittedPolyOrder, minAIC] = robust_poly_fit_chunk(timeSeriesChunk, madXFactor, ...
    maxFitPolyOrder, gapIndicatorChunk)

% initialize output
polyFit = [];
fittedPolyOrder = 0;
minAIC = 1e16;

gapIndices = find(gapIndicatorChunk);

% if there is less than 2 cadences left after ignoring gaps, then do not
% attempt to fit, just return the input
if (length(timeSeriesChunk) - length(gapIndices)) < 2
    polyFit = timeSeriesChunk;
    return
end

% get rid of some outliers in chunk and shifted chunk before
% determining the optimal fit order
absDeviationFromMedian = abs(timeSeriesChunk - median(timeSeriesChunk(~gapIndicatorChunk)));
medianAbsDeviation = median(absDeviationFromMedian);
isCandidateIndexForFit = ...
    absDeviationFromMedian <= madXFactor * medianAbsDeviation;
indexForFit = find(isCandidateIndexForFit);

%remove gap cadences so they dont affect the fit
indexForFit = setdiff(indexForFit,gapIndices);

nCadencesChunk = length(timeSeriesChunk(indexForFit));

if nCadencesChunk < 2
    polyFit = timeSeriesChunk;
    return
end

% restrict polynomial order to avoid order > # samples
maxChunkDetrendPolyOrder = min(maxFitPolyOrder, nCadencesChunk - 2);

% preallocate storage
AIC = zeros(maxChunkDetrendPolyOrder + 1, 1);
robustPolyCoeffs = cell(maxChunkDetrendPolyOrder + 1,1);

% construct design matrices
x=(1:size(timeSeriesChunk,1))';
designMatrix = repmat(x(:)/length(x), 1, maxChunkDetrendPolyOrder+1).^repmat(0:maxChunkDetrendPolyOrder,length(x),1); 

% if it is a horizontal line then just fit a zero order to it and exit
% this keeps robustfit from issuing warnings
if var(timeSeriesChunk(indexForFit)) < 1e-9
    fitCoeff = polyfit((1:length(indexForFit))',timeSeriesChunk(indexForFit),0);
    polyFit = designMatrix(:,1) * fitCoeff;
    return;
end

warningMessage = 'stats:statrobustfit:IterationLimit' ;
warningMessageRank = 'stats:robustfit:RankDeficient' ;
warningMessageSingular = 'MATLAB:nearlySingularMatrix' ;
warning( 'off', warningMessage ) ;
warning( 'off', warningMessageRank ) ;
warning( 'off', warningMessageSingular ) ;

jPolyOrder = 0;
while (jPolyOrder <= fittedPolyOrder + 2) && (jPolyOrder <= maxChunkDetrendPolyOrder)

    % perform robust fit.  By default, ROBUSTFIT adds a column of ones to X
    [robustPolyCoeffs{jPolyOrder+1}, stats] = robustfit(designMatrix(indexForFit, 2:jPolyOrder+1), timeSeriesChunk(indexForFit));

    % extract final estimate of sigma, the larger of robust_s and a weighted
    % average of ols_s and robust_s, where stats.ols_s is the sigma estimate
    % (rmse) from least squares fit, and stats.robust_s is the robust estimate of sigma
    robustSigma = stats.s;

    K = length(robustPolyCoeffs{jPolyOrder+1});
    n = nCadencesChunk; 
    AIC(jPolyOrder+1) = 2*K + 0.5*n*log(robustSigma) + 2*K*(K + 1)/(n - K - 1);

    % update bestBlackPolyOrder
    if AIC(jPolyOrder+1) < minAIC
        minAIC = AIC(jPolyOrder+1);
        fittedPolyOrder = jPolyOrder;
    end

    % If AIC fails to decrease after two attempts past current minimum
    % then use the poly order corresponding to the current minAIC to 
    % construct the fit to the chunk
    if isequal(jPolyOrder, fittedPolyOrder+2)
       polyFit = designMatrix(:,1:fittedPolyOrder+1) * robustPolyCoeffs{fittedPolyOrder+1};
    end
    
    jPolyOrder = jPolyOrder + 1;
end

% if no fit succeeded then fit with zero order polynomial
if isempty(polyFit)
    polyFit = designMatrix(:,1) * robustPolyCoeffs{1};
    minAIC = 0;
end

warning( 'on', warningMessage ) ;
warning( 'on', warningMessageRank ) ;
warning( 'on', warningMessageSingular ) ;

return


