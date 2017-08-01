function [histogram, theoreticalCompression, zeroCount] = ...
verify_histogram_generator(requantPixelValuesArray, requantTable, baselineInterval)

% Note that requantPixelValuesArray is nPixels x nCadences.
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

if ~exist('baselineInterval', 'var')
    baselineInterval = 48;
end

nRequantBits = 16;
zeroOffset = 2^nRequantBits - 1;
huffmanTableLength = 2^(nRequantBits + 1) - 1;
histogramEdges = (0 : huffmanTableLength - 1)';
histogram = zeros(size(histogramEdges));
nCadences = size(requantPixelValuesArray, 2);
nPixels = size(requantPixelValuesArray, 1);
zeroCount = zeros([nPixels, 1]);

b = requantPixelValuesArray( : , 1);
bi = reverse_requant_table_lookup(requantTable, (0 : 2^16-1)', ...
    double(b), false(size(b)), true);

for iCadence = 2 : nCadences
    p = requantPixelValuesArray( : , iCadence);
    pi = reverse_requant_table_lookup(requantTable, (0 : 2^16-1)', ...
        double(p), false(size(p)), true);
    del = pi - bi + zeroOffset;
    zeroCount = zeroCount + double(del == zeroOffset);
    hc = histc(del, histogramEdges, 1);
    histogram = histogram + hc;
    if mod(iCadence-1, baselineInterval) == 0
        bi = pi;
    end
end

f = histogram;
f(f < 1) = 1;
f = f / sum(f);
theoreticalCompression = -sum(f .* log2(f));

return
