function [isOutlier, mu, sigma] = ...
bin_and_threshold_residuals(residualFluxInWindow, pdcModuleParameters)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function [isOutlier, mu, sigma] = ...
% bin_and_threshold_residuals(residualFluxInWindow, pdcModuleParameters)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Bin and threshold the residuals in the current scan window to identify
% any outliers. Compute a histogram of the the residuals, and sort the bins 
% in descending order by number of histogram counts. Select those bins
% accounting for a given percentage of the total number of counts. Compute
% the mean and standard deviation from the population of residual values
% falling in the selected bins. Apply a threshold to *all* residuals to
% identify those falling more than a specified number of standard deviations
% from the mean. These are the outliers.
%
% Return a logical array indicating the residuals that are identified as
% outliers, and the mean and standard deviation of the population used to
% set the outlier thresholds.
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


% Get the required parameter values.
histogramLength = pdcModuleParameters.histogramLength;
histogramCountFraction = ...
    pdcModuleParameters.histogramCountFraction; 
outlierThresholdXFactor = pdcModuleParameters.outlierThresholdXFactor;

% Bin the residuals. Make absolutely sure that the max residual
% falls in the final bin. Note that this extra bin has a width
% of zero. For details, see matlab help for 'histc'.
minResidual = min(residualFluxInWindow);
maxResidual = max(residualFluxInWindow);
binWidth = (maxResidual - minResidual)/histogramLength;

edges = (0 : histogramLength)' * binWidth + minResidual;
edges(end) = maxResidual;

[countsPerBin, indxBins] = histc(residualFluxInWindow, edges);

% Sort by bin counts, and identify the collection of bins with the desired
% fraction (at least) of total counts.
[sortedCountsPerBin, indxSortedBins] = sort(countsPerBin, 'descend');

cumulativeCountFraction = ...
    cumsum(sortedCountsPerBin) / sum(sortedCountsPerBin);
indxCumulativeCountOverThreshold = ...
    find(cumulativeCountFraction >= histogramCountFraction);
indxSelectedBins = ...
    indxSortedBins(1 : indxCumulativeCountOverThreshold(1));

% Get the population of residuals falling in the selected bins and
% compute the mean and standard deviation.
isSelected = ismember(indxBins, indxSelectedBins);

mu = mean(residualFluxInWindow(isSelected));
sigma = std(residualFluxInWindow(isSelected));

% Apply threshold to all residuals and identify outliers.
isOutlier = ...
    (abs(residualFluxInWindow - mu) > outlierThresholdXFactor * sigma);

% Return.
return
