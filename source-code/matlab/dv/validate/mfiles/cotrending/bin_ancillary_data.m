function [binnedValues, uncertaintyInBinnedValues, binnedDataGapIndicators] = ...
bin_ancillary_data(ancillaryDataStruct, binEdges)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function [binnedValues, uncertaintyInBinnedValues, binnedDataGapIndicators] = ...
% bin_ancillary_data(ancillaryDataStruct, binEdges)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Resample ancillary data into bins defined by 'binEdges'. Compute the
% value for each bin as the mean of the ancillary values falling in that
% bin, and the uncertainty for each bin as the rms value of the ancillary
% data samples in that bin. Return vectors of binned values, uncertainty in
% binned values and boolean gap indicators for empty bins.
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


% Get fields from the input structure.
timestamps = ancillaryDataStruct.timestamps;
ancillaryValues = ancillaryDataStruct.values;
uncertaintyInAncillaryValues = ancillaryDataStruct.uncertainties;

% Get the number of bins. An extra bin edge has been added to ensure that
% ancillary samples in the final real bin are properly accounted for. The
% final virtual "bin" will later be disregarded.
nBins = length(binEdges) - 1;

% Initialize the binned values, uncertainties and gap indicators.
binnedValues = zeros([nBins, 1]);
varianceOfBinnedValues = zeros([nBins, 1]);
binnedDataGapIndicators = false([nBins, 1]);
            
% Bin the ancillary data timestamps. Disregard counts (if any) in final
% virtual bin.
[binCounts, binAssignments] = histc(timestamps, binEdges);
binCounts(end) = [];

% Set the gap indicators.
validDataIndicators = binAssignments > 0 ...
    & binAssignments <= nBins;
binAssignments = binAssignments(validDataIndicators);
binsWithData = unique(binAssignments);
gapList = setxor(binsWithData, (1 : nBins)');
binnedDataGapIndicators(gapList) = true;

% Compute the mean value and uncertainty of the ancillary samples in each
% bin. See help for matlab 'unique' for details of [b, m]. Loop over the
% counts of ancillary data values per bin. In the ith iteration, update all
% bins for which there are at least i counts. This is far more efficient
% than looping over a large number of long or short cadence bins. For the
% uncertainty calculation, assume that the ancillary samples in each bin
% are independent.
ancillaryValues = ancillaryValues(validDataIndicators);
uncertaintyInAncillaryValues = ...
    uncertaintyInAncillaryValues(validDataIndicators);

while ~isempty(binAssignments)
    [b, m] = unique(binAssignments, 'first');
    binnedValues(b) = binnedValues(b) + ancillaryValues(m);
    varianceOfBinnedValues(b) = ...
        varianceOfBinnedValues(b) + uncertaintyInAncillaryValues(m) .^ 2;
    binAssignments(m) = [];
    ancillaryValues(m) = [];
    uncertaintyInAncillaryValues(m) = [];
end

positiveCountIndicators = binCounts > 0;
binnedValues(positiveCountIndicators) = ...
    binnedValues(positiveCountIndicators) ./ binCounts(positiveCountIndicators);
varianceOfBinnedValues(positiveCountIndicators) = ...
    varianceOfBinnedValues(positiveCountIndicators) ./ ...
    binCounts(positiveCountIndicators) .^ 2;
uncertaintyInBinnedValues = sqrt(varianceOfBinnedValues);

% Return.
return
