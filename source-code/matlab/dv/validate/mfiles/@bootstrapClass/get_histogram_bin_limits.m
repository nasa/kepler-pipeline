function bootstrapObject = get_histogram_bin_limits(bootstrapObject)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function bootstrapObject = get_histogram_bin_limits(bootstrapObject)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Dynamically determine the null distribution min and max from which to
% build a histogram.  Maximum sigma is set depending on which trial pulse
% has the highest single event statistic.
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

% get needed inputs
binWidth = bootstrapObject.histogramBinWidth;
ses = bootstrapObject.degappedSingleEventStatistics;

nPulseWidths = bootstrapObject.numberPulseWidths;
numTransits = bootstrapObject.observedTransitCount;
maxNumberBins = bootstrapObject.bootstrapMaxNumberBins;
searchTransitThreshold = bootstrapObject.searchTransitThreshold;
NUM_LOWER_BINS = 20; % Constant, allocate 20 bins below threshold

if nPulseWidths >= 1

    maxPossibleMES = zeros(1,nPulseWidths); % preallocate

    for ipulse = 1:nPulseWidths
        sesPulse = ses(ipulse);
        maxPossibleMES(ipulse) = (sesPulse.degappedSortedCorrelationTimeSeries(1).*numTransits)/sqrt((sesPulse.degappedSortedNormalizationTimeSeries(1).^2).*numTransits);
    end

    numBins = (ceil(max(maxPossibleMES)) - (searchTransitThreshold - NUM_LOWER_BINS * binWidth) )/ binWidth;

    if numBins > maxNumberBins % Needed if there are too many bins: KSOC 897 (triggered by high residual SES)
        binWidth = ceil((ceil(max(maxPossibleMES)) - ...
            (searchTransitThreshold - NUM_LOWER_BINS * binWidth) ) / maxNumberBins);
        bootstrapObject.histogramBinWidth = binWidth;
    end

    minHistBin = searchTransitThreshold - NUM_LOWER_BINS * binWidth; % produces a lower edge of the histogram with the searchTransitThreshold at the border of two bins
    maxHistBin = searchTransitThreshold + binWidth * ceil((max(maxPossibleMES) - searchTransitThreshold) / binWidth);
    bootstrapObject.nullTailMinSigma = minHistBin;
    bootstrapObject.nullTailMaxSigma = maxHistBin;

end


return