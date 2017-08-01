function [Cpixels, gapIndicators, gapFilledUsed] = get_pixel_covariance_matrix( S, row, col, pouPixelChunkSize )
%**************************************************************************
% function [Cpixels, gapIndicators, gapFilledUsed] = ...
%     get_pixel_covariance_matrix( S, row, col, pouPixelChunkSize )
%**************************************************************************
% Return the covariance matrix for the pixels at location row and col for
% given single cadence errorPropStruct array S. The indices along each 
% dimension of Cx correspond to the indices of the row, col pairs. Gaps
% are indicated where a rox, col pair is not found in S.
%
% INPUT:    S                   =   single cadence of errorPropStruct from
%                                   CAL. This is a single column of a
%                                   decompressed and maximized
%                                   errorPropStruct array; nVars x 1
%           row                 =   row indices; nPixels x 1; int
%           col                 =   column indices; nPixels x 1; int
%           pouPixelChunkSize   =   maximum length of row and col for which
%                                   a covariance matrix can be returned
%                                   based on memory constraints
% OUTPUT:   Cpixels             =   covariance matrix for the pixels that
%                                   are found; nPixels x nPixels; double.
%           gapIndicators       =   boolean indicator for gapped indices,
%                                   true == gapped index; 1 x nPixels;
%                                   logical. 
%           gapFilledUsed       =   1 == gap filled primitive data used to
%                                   propagate covariance; logical.
%
%**************************************************************************
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

% prefix used in CAL for photometric pixel batches - use as temporary name
% for concatenated pixels.
OUTPUT_NAME = 'calibratedPixels';

% make column vectors
row = row(:);
col = col(:);
    
% check row-col list
if( length(row) ~= length(col) )
    error(['PA:',mfilename,':inconsistentRowColumnList'],...
        'Number of elements in input row must equal the number of elements in input col.');    
end

% allocate space
Cpixels = zeros(length(row));
gapIndicators = true(1,length(row));
gapFilledUsed = false;

% Find number of sub batches to use in chunking
% sSize of two sub batches must be smaller than pouPixelChunkSize
nSubBatches = ceil(length(row)/pouPixelChunkSize) * 2;

% if list is greater than chunck size, break it up
if( length(row) > pouPixelChunkSize )
    
    groupedIndices = make_n_pixel_groups(length(row),nSubBatches);
    
    % generate list of unique pairs of grouped indices
    batchNumber = 1:nSubBatches;
    batchPairs = combnk(batchNumber, 2);
   
    % loop through all unique batch pairs
    for i=1:size(batchPairs,1)
        
        % concatenate lists of indices for batch pair
        subIndex = [groupedIndices{batchPairs(i,1)}; groupedIndices{batchPairs(i,2)}];

        % get the sub covariance matrix for this batch pair
        [Cpixels(subIndex,subIndex), gapIndicators(subIndex), subGapFilledUsed] = ...
            get_pixel_covariance_matrix( S, row(subIndex), col(subIndex), pouPixelChunkSize );
        
        % update gapFilledUsed flag
        gapFilledUsed = gapFilledUsed || subGapFilledUsed;

    end
    
else
    % otherwise process covariance from this chunk
    
    % find which elements of S contain the row, col pairs
    [indexS, pixelIndices, foundRows, foundCols] = get_photometric_errorPropStruct_elements(row, col, S);

    if( ~isempty(indexS) && ~isempty(pixelIndices) )
        % build the array of contributing photometric elements
        elementArray = build_photometric_element_array(S, indexS, pixelIndices);

        % make a single element out of the array
        targetElement = concatenate_errorPropStruct_elements(elementArray, OUTPUT_NAME);

        % build new errorPropStruct array = collateral + targetElement
        collateralIndices = get_collateral_and_photometric_indices(S);
        tempStruct = [S(collateralIndices); targetElement];

        % set gapFilledUsed flag
        gapFilledUsed = any([tempStruct.cadenceGapFilled]);

        % generate the covariance matrix for the found rows and cols
        [x, Cx] = cascade_transformations(tempStruct, OUTPUT_NAME);

        % set non gaps by comparing found row-col pairs to those requested
        [TF, LOC] = ismember( [cell2mat(foundRows), cell2mat(foundCols)], [row, col], 'rows');
        gapIndicators(LOC) = false;

        % set covariance matrix relative to requested pixels
        Cpixels(LOC,LOC) = Cx;
    end
end
