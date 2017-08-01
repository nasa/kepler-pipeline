function [mesPdf, mesCdf, mesBinEdges] = estimate_mes_distribution_by_2d_convolution( ...
    correlationTimeSeries, normalizationTimeSeries, nTransits, resolution, ...
    histogramBinWidth, maxNumberBins)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function [mesPdf,mesCdf,mesBinEdges] = estimate_mes_distribution_by_2d_convolution( ...
%     correlationTimeSeries, normalizationTimeSeries, nTransits, resolution)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Description:
% Computes the bootstrap for nTransits given the single event statistics
% for a star for the given TCE duration. The normalizationTimeSeries should
% be the "square root" form so that the single event statistics can be
% formed by dividing the correlationTimeSeries by the
% normalizationTimeSeries.
% This function exploits the fact that the single event statistics are a
% bivariate distribution and so when we combine single event statistics
% together we are adding random deviates drawn from this 2-D distribution
% for the single event statistics.
% So we need to convolve the PDF for the single events together with itself
% nTransits times. This can be accomplished in the Fourier domain using
% fft2.
%
% Inputs:
%
% Outputs: 
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

nStatistics = length(correlationTimeSeries);

% set a hard limit on the buffering
nMaxBuffers = maxNumberBins / resolution; 

% Now figure out how to break up the work if nTransits is too high
% nHalfBuffers controls number of half correlation-range and
% normalization-range buffers are used on either side of the central range
% of bins containing the original correlation and normalization
% information.
nBuffers = 2 ^ ceil( log2(nTransits + 1) ); % force the number of buffers to be a power of two
nBuffers = min(nMaxBuffers,nBuffers);
nHalfBuffers = nBuffers / 2; % so embedding box is Nbuffers times the size of the support for the distribution

% Reduce magnitudes of both corr and norm terms
% this doesn't have to be corrected out afterwards
madCorrelationTimeSeries = mad(correlationTimeSeries,1);

% protect against zero
if isequal(madCorrelationTimeSeries,0)
    madCorrelationTimeSeries = 1;
end
correlationTimeSeries = correlationTimeSeries / madCorrelationTimeSeries;
normalizationTimeSeries = normalizationTimeSeries / madCorrelationTimeSeries;

% square normalization term so that they add when forming new multiple
% event statistics
normalizationTimeSeries = normalizationTimeSeries .^ 2;

% establish starting grids in (corr,norm) space
maxAbsCorr = max( abs(correlationTimeSeries) );
corrVec = linspace(-2 * maxAbsCorr * nHalfBuffers, 2 * maxAbsCorr * nHalfBuffers,...
    resolution * 2 * nHalfBuffers);

minNorm = min(normalizationTimeSeries);
maxNorm = max(normalizationTimeSeries);
midNorm = (minNorm+maxNorm)/2; % this will be used to normalize the normalization terms at 1.0
rangeNorm = maxNorm-minNorm;

% in case there is no spread in the normalizationTimeSeries
if rangeNorm == 0 
    rangeNorm = midNorm * .1;
end

normVec = linspace(-nHalfBuffers * rangeNorm, nHalfBuffers * rangeNorm,...
    resolution * 2 * nHalfBuffers) / midNorm;

% normalize so center of support is at 1.0, then shift to 0.0
% the resulting waveform can be shifted to nTransits after the fact, and
% renormalized
normalizationTimeSeries = normalizationTimeSeries / midNorm - 1.0;

% populate 2-D histogram for single transit PDF
nCounts = hist3([normalizationTimeSeries, correlationTimeSeries], {normVec, corrVec});

% normalize the counts
nCounts = nCounts / nStatistics;

% initialize the number of transits left to convolve
nTransitsToGo = nTransits;

% go to Fourier domain for 1 transit
fftCounts = fft2(nCounts);

% Set up initial incremental PDFs (only 2 at most at lowest level);
blockSize = nMaxBuffers / 2;
remainder = rem(nTransitsToGo, blockSize);
nBlocks = floor(nTransitsToGo / blockSize);
   
nnTransits = convolve_pdf(fftCounts, remainder);
nTransitsToGo = nTransitsToGo - remainder;

if nBlocks > 0
   nnBlocks = convolve_pdf(fftCounts, blockSize);
end

clear fftCounts;

count = 0;

if nTransitsToGo == 0
    % loop will not occur, so set count to 1
    count = 1; 
end

while nTransitsToGo > 0
    
    % Go ahead and combine one block with nnTransits at this resolution
    nnTransits = combine_pdfs(nnTransits, nnBlocks);
    nTransitsToGo = nTransitsToGo - blockSize;
    
    % Break out early to avoid extra bin averaging
    if nTransitsToGo ==0
        count = count + 1;
        break
    end
    
    % reduce resolution of nnBuffers and nnTransits by a factor of two
    % and embed in a box the same size as the original one
    nnTransits = bin_and_embed(nnTransits, 2);
    nnBlocks = bin_and_embed(nnBlocks, 2);
    
    count = count + 1;
    
    % scale by 2 to account for bin-averaging
    corrVec = 2 * corrVec; 
    normVec = 2 * normVec; 
     
    % take care of extra block at this block size before continuing
    if is_even(nBlocks) 
        nnTransits = combine_pdfs(nnTransits, nnBlocks);
        nTransitsToGo = nTransitsToGo - blockSize;
        if nTransitsToGo == 0
            break
        end
    end
    
    nnBlocks = convolve_pdf( fft2(nnBlocks), 2 );
    if is_even(count)
        nnBlocks = circshift(nnBlocks,-[1,1]);
    end
    
    blockSize = blockSize * 2;
    nBlocks = floor(nTransitsToGo / blockSize);

    % Generate interim distributions for comparison to prevent egregious
    % roundoff errors
    normVecConvolved = midNorm * (nTransits - nTransitsToGo + normVec(:)); % account for shifts by convolution and scaling
    mes = sqrt( abs(normVecConvolved) ) .^ (-1) * corrVec(:)';

    % Now re-bin observed MES Distribution
    [mesPdf{count}, mesCdf{count}, mesBinEdges{count}] = collapse_mes_distribution(mes, ...
        nnTransits, histogramBinWidth, maxNumberBins);

end

% bin one more time to the MES grid
normVecConvolved = midNorm * (nTransits - nTransitsToGo + normVec(:)); % account for shifts by convolution and scaling
mes = sqrt( abs(normVecConvolved) ) .^ (-1) * corrVec(:)';

% Now re-bin observed MES Distribution
[mesPdf{count}, mesCdf{count}, mesBinEdges{count}] = collapse_mes_distribution(mes, ...
    nnTransits, histogramBinWidth, maxNumberBins);

% merge CDFs to common grid
[mesBinEdges, mesCdf, mesPdf] = merge_pdfs(mesBinEdges, mesPdf, histogramBinWidth);

return

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% merge_pdfs: merge the PDFs from the incremental loops to one common grid
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [mesGridEdgesOut, mesCdfs, mesPdfs] = merge_pdfs(mesBinEdges, mesPdf, histogramBinWidth)

MAX_N_BINS = 1e6;

nCDFs = length(mesBinEdges);

gridEdgesMin = mesBinEdges{1}(1);
gridEdgesMax = mesBinEdges{1}(end);
for i = 2:nCDFs
    gridEdgesMin = min(gridEdgesMin, mesBinEdges{i}(1));
    gridEdgesMax = max(gridEdgesMax, mesBinEdges{i}(end)); 
end

mesGridEdgesOut = linspace( round(gridEdgesMin), round(gridEdgesMax), ...
    min(MAX_N_BINS, (round(gridEdgesMax) - round(gridEdgesMin)) / histogramBinWidth) );
mesPdfs = zeros(length(mesGridEdgesOut), nCDFs);


for i = 1:nCDFs
    mesPdfs(:,i) = interp1(mesBinEdges{i}, mesPdf{i}, mesGridEdgesOut, 'near', 'extrap');
end

mesCdfs = cumsum(mesPdfs);

return


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% bin_and_embed
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function nnBoxed = bin_and_embed(nn, embedScale)

nnBinned = nn(1:2:end, 1:2:end) + nn(1:2:end, 2:2:end) + ...
    nn(2:2:end, 1:2:end) + nn(2:2:end, 2:2:end);

nnBinnedSize = size(nnBinned);
boxSize = embedScale * nnBinnedSize;

nnBoxed = zeros(boxSize);

startIndex = (boxSize - nnBinnedSize) / embedScale + 1;
stopIndex = startIndex + nnBinnedSize - 1;

nnBoxed(startIndex(1):stopIndex(1), startIndex(2):stopIndex(2)) = nnBinned;

return
        
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% combine_pdfs: convolve two PDFs in Fourier domain
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function nn12 = combine_pdfs(nn1, nn2)
    
    nn12 = ifft2( fft2(nn1) .* fft2(nn2) );
    
    % account for zero point offsets from convolution in correlation dimension
    % for even powers, we need to shift by 1/2 the boxWidth
    % for both odd and even powers, we need to shift by 1 for each two increments
    corrShift = size(nn1, 2) / 2;
    normShift = size(nn1, 1) / 2;
        
    nn12 = circshift(nn12, [normShift,corrShift]);
    
return

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% convolve_pdf: convolve single transit PDF nTransits times with itself in 
%               Fourier domain
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function nnNtimes = convolve_pdf(NN1, nTimes)

    nnNtimes = ifft2(NN1 .^ nTimes);

    % account for zero point offsets from convolution in correlation dimension
    % for even powers, we need to shift by 1/2 the boxWidth
    % for both odd and even powers, we need to shift by 1 for each two increments
    corrShift = size(NN1,2)/2 * is_even(nTimes) + floor(nTimes/2);
    normShift = size(NN1,1)/2 * is_even(nTimes) + floor(nTimes/2);
        
    nnNtimes = circshift(nnNtimes, [normShift, corrShift]);
    
return

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% is_even
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function isEven = is_even(x)

isEven = round(x/2)*2 == x;

return

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% collapse_mes_distribution
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [mesPdf, mesCdf, mesBinEdges] = collapse_mes_distribution(mes, nnNtransits, ...
    histogramBinWidth, maxNumberBins)

MAX_N_BINS = 1e6;

while length(mes) > maxNumberBins
    mes = bin_2_by_2(mes);
    mes = mes/4;% average mes
    nnNtransits = bin_2_by_2(nnNtransits);
end

maxAbsMes = abs( mes( nnNtransits > eps(max(max(nnNtransits))) ) );
maxAbsMes = maxAbsMes(:);
maxAbsMes = 2*round(max(max(maxAbsMes),1));

mesBinEdges = linspace(-maxAbsMes, maxAbsMes, min(MAX_N_BINS,2 * maxAbsMes / histogramBinWidth + 1))';
mesGridMidpoints = (mesBinEdges(1:end-1) + mesBinEdges(2:end)) / 2;

iiKeep = find( nnNtransits > eps(max(max(nnNtransits))) );
nnNtransits = nnNtransits(iiKeep);
mes = mes(iiKeep);

% polish pdf info
[sortedNnNtransits,iSort] = sort(nnNtransits(:));
sortedNnNtransits = sortedNnNtransits / sum(sortedNnNtransits);

mes1 = mes(:);
sortedMes = mes1(iSort);
sortedMesGridIndex = interp1(mesGridMidpoints, 1:length(mesGridMidpoints), sortedMes, 'near', 'extrap');

% use sparse matrix properties to generate pdf?
% we get somewhat better numerical results with the loop below
mesPdf = 0 + ...
    sparse(sortedMesGridIndex+1, ones(size(sortedMesGridIndex)), sortedNnNtransits, length(mesBinEdges), 1);
mesPdf = full(mesPdf);

% normalize
mesPdf = mesPdf / sum(mesPdf);

% get the CDF
mesCdf = cumsum(mesPdf);

% polish the CDF
mesCdf = mesCdf - min(mesCdf);
mesCdf = mesCdf / max(mesCdf);

return
