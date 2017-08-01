function pdqTempStruct = bin_smear_measurements(pdqTempStruct, cadenceIndex)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function pdqTempStruct = bin_smear_measurements(pdqTempStruct, cadenceIndex)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Description: 
%   This function bins the virtual smear and masked smear pixels (if they
%   come from more than one row) into one row.
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

%--------------------------------------------------------------------------
% see whether there is any need to bin masked smear pixels (see whether
% they come from more than one row)
%--------------------------------------------------------------------------

uniqueMsmearRows    = unique(pdqTempStruct.msmearRows); % bin msmear from several rows into one row per column
nUniqueMsmearRows   = length(uniqueMsmearRows); % bin msmear from several rows into one row per column

% it is possible that some column(s) might have data gaps in some of the
% rows and not all the columns will have data in the same rows
uniqueMsmearColumns     = unique(pdqTempStruct.msmearColumns);
nUniqueMsmearColumns    = length(uniqueMsmearColumns);

msmearGapIndicators         = reshape(pdqTempStruct.msmearGapIndicators(:,cadenceIndex),  nUniqueMsmearColumns, nUniqueMsmearRows); % a matrix now

numberOfMsmearsInEachColumn = binmat(~msmearGapIndicators, 1, nUniqueMsmearRows); % must be a vector by now

% bin the msmearPixels
msmearPixels = pdqTempStruct.msmearPixels(:, cadenceIndex);

msmearPixels = reshape(msmearPixels,  nUniqueMsmearColumns, nUniqueMsmearRows); % a matrix now
msmearPixels = binmat(msmearPixels, 1, nUniqueMsmearRows);% should have only one row at this point


% divide by zero possible here...to avoid that...
validIndices = find(numberOfMsmearsInEachColumn);
msmearPixels(validIndices) = msmearPixels(validIndices)./numberOfMsmearsInEachColumn(validIndices);


if(cadenceIndex == 1)
    % allocate memory
    pdqTempStruct.binnedMsmearPixels        =  zeros(length(msmearPixels), pdqTempStruct.numCadences);
    pdqTempStruct.msmearPixelsInColumnBin   = zeros(length(msmearPixels), pdqTempStruct.numCadences);
    pdqTempStruct.binnedMsmearGapIndicators = zeros(length(msmearPixels), pdqTempStruct.numCadences);

    pdqTempStruct.binnedMsmearRow           = zeros(pdqTempStruct.numCadences, 1);
    pdqTempStruct.binnedMsmearColumns       = zeros(length(msmearPixels), pdqTempStruct.numCadences);

end


pdqTempStruct.binnedMsmearPixels(:, cadenceIndex)           = msmearPixels;
pdqTempStruct.msmearPixelsInColumnBin(:, cadenceIndex)      = numberOfMsmearsInEachColumn;
pdqTempStruct.binnedMsmearGapIndicators(:, cadenceIndex)    = ~logical(numberOfMsmearsInEachColumn);
pdqTempStruct.binnedMsmearRow(cadenceIndex)                 = uniqueMsmearRows(1);
pdqTempStruct.binnedMsmearColumns(:, cadenceIndex)          = uniqueMsmearColumns;
pdqTempStruct.numberOfMsmearRowsBinned(:, cadenceIndex)     = nUniqueMsmearRows;


%--------------------------------------------------------------------------
% see whether there is any need to bin virtual smear pixels (see whether
% they come from more than one row)
%--------------------------------------------------------------------------
uniqueVsmearRows    = unique(pdqTempStruct.vsmearRows); % bin msmear from several rows into one row per column
nUniqueVsmearRows   = length(uniqueVsmearRows); % bin msmear from several rows into one row per column


% it is possible that some column(s) might have data gaps in some of the
% rows and not all the columns will have data in the same rows
uniqueVsmearColumns     = unique(pdqTempStruct.vsmearColumns);
nUniqueVsmearColumns    = length(uniqueVsmearColumns);


vsmearGapIndicators         = reshape(pdqTempStruct.vsmearGapIndicators(:,cadenceIndex), nUniqueVsmearColumns, nUniqueVsmearRows); % a matrix now
numberOfVsmearsInEachColumn = binmat(~vsmearGapIndicators, 1, nUniqueVsmearRows); % must be a vector by now


% bin the vsmear pixels
vsmearPixels                            = pdqTempStruct.vsmearPixels(:, cadenceIndex);

vsmearPixels = reshape(vsmearPixels, nUniqueVsmearColumns, nUniqueVsmearRows); % a matrix now
vsmearPixels = binmat(vsmearPixels, 1, nUniqueVsmearRows);

% divide by zero possible here...to avoid that...
validIndices = find(numberOfVsmearsInEachColumn);
vsmearPixels(validIndices) = vsmearPixels(validIndices)./numberOfVsmearsInEachColumn(validIndices);

if(cadenceIndex == 1)
    % allocate memory

    pdqTempStruct.binnedVsmearPixels            = zeros(length(vsmearPixels), pdqTempStruct.numCadences);
    pdqTempStruct.vsmearPixelsInColumnBin       = zeros(length(vsmearPixels), pdqTempStruct.numCadences);
    pdqTempStruct.binnedVsmearGapIndicators     = zeros(length(vsmearPixels), pdqTempStruct.numCadences);

    pdqTempStruct.binnedVsmearRow               = zeros(pdqTempStruct.numCadences, 1);
    pdqTempStruct.binnedVsmearColumns           = zeros(length(vsmearPixels), pdqTempStruct.numCadences);

end


pdqTempStruct.binnedVsmearPixels(:, cadenceIndex)           = vsmearPixels;
pdqTempStruct.vsmearPixelsInColumnBin(:, cadenceIndex)      = numberOfVsmearsInEachColumn;
pdqTempStruct.binnedVsmearGapIndicators(:, cadenceIndex)    = ~logical(numberOfVsmearsInEachColumn);
pdqTempStruct.binnedVsmearRow(cadenceIndex)                 = uniqueVsmearRows(1);
pdqTempStruct.binnedVsmearColumns(:, cadenceIndex)          = uniqueVsmearColumns;
pdqTempStruct.numberOfVsmearRowsBinned(:, cadenceIndex)     = nUniqueVsmearRows;


return
