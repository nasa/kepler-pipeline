function [compressionPerformance] = ...
compute_compression_performance(nRequantBits, baselineIntervals, histograms)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function [compressionPerformance] = ...
% compute_compression_performance(nRequantBits, baselineIntervals, histograms)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Compute the baseline overhead rate, theoretical compression rate and total
% storage requirement for each of the intervals specified in the
% 'baselineIntervals' vector.
%
% The input argument 'histograms' is a 2-D array of counts representing
% histograms for each of the baseline intervals of interest.
%
% The number of bits in the indices of the requantization table is specified
% by 'nRequantBits'. This also represents the number of bits per pixel in the
% uncompressed baseline images.
%
% The overhead rate for storage of the uncompressed baseline image is equal
% to the ratio of the number of bits in the requantization table indices to the
% length of each baseline interval in units of cadences.
%
% For each input histogram, compute the theoretical compression rate
% (entropy) in bits/symbol as -sum(p_i*log2(p_i)). First, add a count
% to all histogram bins with zero counts.
%
% The total storage requirement for each baseline interval is the sum of
% the baseline overhead rate and the theoretical compression rate.
%
% Return a compression performance structure with the original baseline intervals, 
% uncompressed baseline overhead rate, theoretical compression rate and total
% storage rate.
%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% INPUT:  The following arguments are specified for this function.
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
%                   nRequantBits: [int]  number of bits in requant table indices
%        baselineIntervals: [int array]  intervals to evaluate compression performance
%           histograms [long 2-D array]  histograms for each baseline interval
%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% OUTPUT:  A data structure compressionPerformance with the following fields.
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
%                   baselineIntervals: [int array]  intervals (cadences)
% uncompressedBaselineOverheadRate: [double array]  baseline overhead for intervals (bpp)
%       theoreticalCompressionRate: [double array]  entropy for intervals (bpp)
%                 totalStorageRate: [double array]  storage requirements (bpp)
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


% Initialize variables and vectors.
nIntervals = length(baselineIntervals);
theoreticalCompressionRate = zeros([nIntervals, 1]);

% Initialize the output structure.
 compressionPerformance = struct( ...
    'baselineIntervals', [], ...
    'uncompressedBaselineOverheadRate', [], ...
    'theoreticalCompressionRate', [], ...
    'totalStorageRate', [] );

% Compute the theoretical compression rate for each baseline interval.
for i = 1 : nIntervals
    symbolCounts = cast(histograms( : , i), 'double');
    symbolCounts(0 == symbolCounts) = 1;
    probabilityOfSymbols = symbolCounts ./ sum(symbolCounts);
    theoreticalCompressionRate(i) = ...
        -sum(probabilityOfSymbols .* log2(probabilityOfSymbols));
end

% Compute the overhead rate and the total compression requirement for each
% interval.
uncompressedBaselineOverheadRate = nRequantBits ./ baselineIntervals;
totalStorageRate = uncompressedBaselineOverheadRate + theoreticalCompressionRate;

% Assign values to the fields in the compression performance structure.
compressionPerformance.baselineIntervals = baselineIntervals;
compressionPerformance.uncompressedBaselineOverheadRate = ...
    uncompressedBaselineOverheadRate;
compressionPerformance.theoreticalCompressionRate = theoreticalCompressionRate;
compressionPerformance.totalStorageRate = totalStorageRate;

% Return.
return
