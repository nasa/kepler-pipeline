function pdqTempStruct = compute_centroids(pdqTempStruct)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function pdqTempStruct = compute_centroids(pdqTempStruct)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% The algorithm chosen fits 2 1-D Gaussians, after summing the pixel data
% along rows, then columns. This is much faster than a 2-D Gaussian fit.
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
warning off all;

numCadences         = pdqTempStruct.numCadences;
targetIndices       = pdqTempStruct.targetIndices;

numTargets       = length(targetIndices);

% Pre-allocate memory for arrays
centroidRows = zeros(numTargets, numCadences);
centroidCols = zeros(numTargets, numCadences);


nUniqueTargetRows = 0;
nUniqueTargetColumns = 0;
numPixels           = pdqTempStruct.numPixels;
indexStart = 1;

targetPixelRows     = pdqTempStruct.targetPixelRows;
targetPixelColumns  = pdqTempStruct.targetPixelColumns;

for j = 1:numTargets

    indexEnd    = indexStart + numPixels(j) -1;

    nUniqueTargetRows = nUniqueTargetRows + length(unique( targetPixelRows(indexStart : indexEnd)));
    nUniqueTargetColumns = nUniqueTargetColumns +length(unique(targetPixelColumns(indexStart : indexEnd)));
    indexStart = indexEnd + 1;
end


centroidRowUncertainties = zeros(numTargets, numCadences);
centroidColumnUncertainties = zeros(numTargets, numCadences);

centroidUncertaintyStructOld = repmat(struct('TcolumnSumFluxToRowCentroidFit', [], 'TpixelsToColumnSumFlux', [], ...
    'CtargetPixelsAllRowCentroid',[], 'CcentroidRow', [],...
    'TrowSumFluxToColumnCentroidFit', [],  'TpixelsToRowSumFlux', [], ...
    'CtargetPixelsAllColumnCentroid', [], 'CcentroidColumn' , []), numCadences, 1);

pdqTempStruct.centroidUncertaintyStructOld = centroidUncertaintyStructOld;


%........................................................................

prfCentroidRowGuesses = zeros(numTargets, numCadences);
prfCentroidColumnGuesses = zeros(numTargets, numCadences);


%------------------------------------------------------------------
% Loop over all cadences, and for each cadence all targets
%------------------------------------------------------------------
debugLevel = pdqTempStruct.debugLevel;

for cadenceIndex = 1 : numCadences

    CtargetPixelsAllRowCentroid    = pdqTempStruct.targetPixelsUncertaintyStruct(cadenceIndex).CtargetPixels;
    CtargetPixelsAllColumnCentroid    = pdqTempStruct.targetPixelsUncertaintyStruct(cadenceIndex).CtargetPixels;

    indexBeginPixel     = 1;
    indexBeginColumnSum = 1;
    indexBeginRowSum    = 1;
    nTotalValidPixels = size(CtargetPixelsAllRowCentroid,1);

    TpixelsToRowSumFlux         = zeros(nUniqueTargetColumns, nTotalValidPixels);
    TpixelsToColumnSumFlux      = zeros(nUniqueTargetRows, nTotalValidPixels);

    TcolumnSumFluxToRowCentroidFit = zeros(numTargets, nUniqueTargetRows);
    TrowSumFluxToColumnCentroidFit    = zeros(numTargets, nUniqueTargetColumns);


    if(isempty(CtargetPixelsAllRowCentroid))
        centroidRows(:, cadenceIndex) = -1;
        centroidCols(:, cadenceIndex) = -1; % that column entries are set to -1
        centroidColumnUncertainties(:, cadenceIndex) = -1;
        centroidRowUncertainties(:, cadenceIndex) = -1;

        pdqTempStruct.centroidUncertaintyStructOld(cadenceIndex).TcolumnSumFluxToRowCentroidFit = [];
        pdqTempStruct.centroidUncertaintyStructOld(cadenceIndex).TpixelsToColumnSumFlux = [];
        pdqTempStruct.centroidUncertaintyStructOld(cadenceIndex).CtargetPixelsAllRowCentroid = [];
        pdqTempStruct.centroidUncertaintyStructOld(cadenceIndex).CcentroidRow = [];

        pdqTempStruct.centroidUncertaintyStructOld(cadenceIndex).TrowSumFluxToColumnCentroidFit = [];
        pdqTempStruct.centroidUncertaintyStructOld(cadenceIndex).TpixelsToRowSumFlux = [];
        pdqTempStruct.centroidUncertaintyStructOld(cadenceIndex).CtargetPixelsAllColumnCentroid = [];
        pdqTempStruct.centroidUncertaintyStructOld(cadenceIndex).CcentroidColumn = [];

        continue; % no targets present for this cadence
    end


    for targetIndex = 1 : numTargets

        %------------------------------------------------------------------
        % brightness weighted centroid calculation (not PSF fitting)
        %------------------------------------------------------------------
        [targetPixelFluxes, CtargetPixels, targetRows, targetColumns] = extract_target_pixels_and_uncertainties(pdqTempStruct, cadenceIndex, targetIndex);


        if(isempty(targetPixelFluxes))

            % all the pixels for this target for this cadence gapped
            centroidRows(targetIndex, cadenceIndex) = -1;
            centroidCols(targetIndex, cadenceIndex) = -1;
            centroidColumnUncertainties(targetIndex, cadenceIndex) = -1;
            centroidRowUncertainties(targetIndex, cadenceIndex) = -1;
            continue;

        end

        % Determine number of pixels for this target
        numTargetPixels = length(targetPixelFluxes);

        nTargetRows     = length(unique(targetRows));
        nTargetColumns  = length(unique(targetColumns));

        TpixelsToColumnSumFlux1  = zeros(nTargetRows, numTargetPixels);
        TpixelsToRowSumFlux1     = zeros(nTargetColumns, numTargetPixels);
        rowSum      = zeros(nTargetColumns,1);
        columnSum   = zeros(nTargetRows,1);

        tRows = targetRows - min(targetRows) +1;
        tCols = targetColumns - min(targetColumns) +1;

        for j = 1 :nTargetRows
            idx = find(tRows == j);
            TpixelsToColumnSumFlux1(j,idx)   = 1;
            columnSum(j)                     = sum(targetPixelFluxes(idx));
        end

        for j = 1 :nTargetColumns
            idx = find(tCols == j);
            TpixelsToRowSumFlux1(j,idx)      = 1;
            rowSum(j)                        = sum(targetPixelFluxes(idx));
        end

        if(debugLevel)

            % meshplot for a visual check
            minRow = min(targetRows);
            maxRow = max(targetRows);
            nUniqueRows = maxRow - minRow +1;
            minCol = min(targetColumns);
            maxCol = max(targetColumns);
            nUniqueCols = maxCol - minCol +1;

            X = repmat((minRow:maxRow)',1, nUniqueCols);
            Y = repmat((minCol:maxCol), nUniqueRows,1);

            Z = zeros(size(X));
            idx = sub2ind(size(X), targetRows -minRow+1,targetColumns-minCol+1);
            %                Z(idx) = psfValueAtPixel;
            Z(idx) = targetPixelFluxes;
            figure(1);
            mesh(X,Y,Z);
            fprintf('');
        end


        % next target's  beginning index
        indexEndPixel       = indexBeginPixel + numTargetPixels - 1;
        indexEndColumnSum   = indexBeginColumnSum + nTargetRows -1;
        indexEndRowSum      = indexBeginRowSum +  nTargetColumns -1;

        TpixelsToColumnSumFlux(indexBeginColumnSum:indexEndColumnSum, indexBeginPixel:indexEndPixel) = ...
            TpixelsToColumnSumFlux1;

        TpixelsToRowSumFlux(indexBeginRowSum:indexEndRowSum, indexBeginPixel:indexEndPixel) = ...
            TpixelsToRowSumFlux1;

        CcolumnSumUncertainties = TpixelsToColumnSumFlux1 * CtargetPixels * TpixelsToColumnSumFlux1';
        columnSumUncertainties  = sqrt(diag(CcolumnSumUncertainties));

        CrowSumUncertainties    = TpixelsToRowSumFlux1 * CtargetPixels * TpixelsToRowSumFlux1' ;

        % it would be interesting to factor the  inverse of the covariance
        % matrix and multiply by the factor
        rowSumUncertainties     = sqrt(diag(CrowSumUncertainties)) ;

        uniqueTargetRows      = unique(targetRows);
        uniqueTargetColumns   = unique(targetColumns);
        % Sum pixel value along rows and columns
        columnSum       = columnSum(:);
        rowSum          = rowSum(:);

        xRows       = uniqueTargetRows(:);
        xColumns    = uniqueTargetColumns(:);


        % Create initial guesses for Gaussian fit using flux weighted
        % centroids
        starFlux = sum(rowSum);

        fluxWeightedCentroidRow     = targetRows'* targetPixelFluxes / starFlux;
        fluxWeightedCentroidColumn  = targetColumns'* targetPixelFluxes / starFlux;

        guessRow                = [1 fluxWeightedCentroidRow 1];

        guessColumn             = [1 fluxWeightedCentroidColumn 1];



        prfCentroidRowGuesses(targetIndex, cadenceIndex) = guessRow(2);
        prfCentroidColumnGuesses(targetIndex, cadenceIndex) = guessColumn(2);


        % Fit a 1-D gaussian along the pixel distribution summed in rows
        % and columns
        %----------------------------------------------------------------------
        % column centroids
        %----------------------------------------------------------------------

        rowSum1 = rowSum/max(rowSum);
        rowSumUncertainties1 = rowSumUncertainties/max(rowSum);

        modelFunRow = @(alpha,x) gaussian(alpha,x)./rowSumUncertainties1;

        lastwarn('');

        [gaussFitColumn,rwColumn,JwColumn,SigmaColumn]  = nlinfit(xColumns, rowSum1./rowSumUncertainties1, modelFunRow, guessColumn);


        % if there is a warning from nlinfit about ill-conditioned
        % Jacobian,  or about overparametrized model then discard this
        % target's centroid as calculations are unreliable
        msgstr = lastwarn;

        if(~isempty(msgstr))

            %if(~isempty(strfind(msgstr, 'overparameterized')) || ~isempty(strfind(msgstr, 'ill-conditioned')))
            warning('PDQ:centroidCalculation:nlinfit', ...
                'ill-conditioned jacobian, discarding this row centroid');


            centroidRows(targetIndex, cadenceIndex) = -1;
            centroidCols(targetIndex, cadenceIndex) = -1;
            centroidColumnUncertainties(targetIndex, cadenceIndex) = -1;
            centroidRowUncertainties(targetIndex, cadenceIndex) = -1;
            % zero out this target in the uncertainty matrix
            CtargetPixelsAllColumnCentroid(indexBeginPixel:indexEndPixel,:) = 0;
            CtargetPixelsAllColumnCentroid(:,indexBeginPixel:indexEndPixel) = 0;
            % zero out this target in the uncertainty matrix
            CtargetPixelsAllRowCentroid(indexBeginPixel:indexEndPixel,:) = 0;
            CtargetPixelsAllRowCentroid(:,indexBeginPixel:indexEndPixel) = 0;


            indexBeginPixel     = indexEndPixel + 1;
            indexBeginColumnSum = indexEndColumnSum + 1;
            indexBeginRowSum    = indexEndRowSum + 1;

            continue;
            %end

        end
        TrowSum = (inv(JwColumn'*JwColumn)*JwColumn');

        TrowSum = TrowSum*(diag(1./rowSumUncertainties));

        TrowSumFluxToColumnCentroidFit(targetIndex,indexBeginRowSum:indexEndRowSum) = TrowSum(2,:)';

        %----------------------------------------------------------------------
        % row centroids
        %----------------------------------------------------------------------

        lastwarn('');
        columnSum1 = columnSum/max(columnSum);
        columnSumUncertainties1 = columnSumUncertainties/max(columnSum);

        modelFunColumn = @(alpha,x) gaussian(alpha,x)./columnSumUncertainties1;
        [gaussFitRow,rwRow,JwRow, SigmaRow] = nlinfit(xRows, (columnSum1./columnSumUncertainties1), modelFunColumn, guessRow);

        msgstr = lastwarn;

        if(~isempty(msgstr))

            %if(~isempty(strfind(msgstr, 'overparameterized')) || ~isempty(strfind(msgstr, 'ill-conditioned')))
            warning('PDQ:centroidCalculation:nlinfit', ...
                'ill-conditioned jacobian, discarding this column centroid');

            centroidRows(targetIndex, cadenceIndex) = -1;
            centroidCols(targetIndex, cadenceIndex) = -1;
            centroidColumnUncertainties(targetIndex, cadenceIndex) = -1;
            centroidRowUncertainties(targetIndex, cadenceIndex) = -1;

            % zero out this target in the uncertainty matrix
            CtargetPixelsAllColumnCentroid(indexBeginPixel:indexEndPixel,:) = 0;
            CtargetPixelsAllColumnCentroid(:,indexBeginPixel:indexEndPixel) = 0;
            % zero out this target in the uncertainty matrix
            CtargetPixelsAllRowCentroid(indexBeginPixel:indexEndPixel,:) = 0;
            CtargetPixelsAllRowCentroid(:,indexBeginPixel:indexEndPixel) = 0;

            indexBeginPixel     = indexEndPixel + 1;
            indexBeginColumnSum = indexEndColumnSum + 1;
            indexBeginRowSum    = indexEndRowSum + 1;


            continue;
            %end

        end

        TcolumnSum = (inv(JwRow'*JwRow)*JwRow');  % add comments...
        TcolumnSum = TcolumnSum*(diag(1./columnSumUncertainties));

        TcolumnSumFluxToRowCentroidFit(targetIndex,indexBeginColumnSum:indexEndColumnSum) = TcolumnSum(2,:)';


        %----------------------------------------------------------------------
        % row centroids end
        %----------------------------------------------------------------------

        % Bad fits - skip this target's centroid or generate error?
        if (gaussFitRow(2) < xRows(1) || gaussFitRow(2) > xRows(end) )
            gaussFitRow(2) = (xRows(end) + xRows(1))/2;
        end
        if (gaussFitColumn(2) < xColumns(1) || gaussFitColumn(2) > xColumns(end) )
            gaussFitColumn(2) = (xColumns(end) + xColumns(1))/2;
        end


        %Store results in pre-allocated arrays
        centroidRows(targetIndex, cadenceIndex) = gaussFitRow(2);
        centroidCols(targetIndex, cadenceIndex) = gaussFitColumn(2);


        indexBeginPixel     = indexEndPixel + 1;
        indexBeginColumnSum = indexEndColumnSum + 1;
        indexBeginRowSum    = indexEndRowSum + 1;


    end % target loop

    % remove extra rows and columns
    TcolumnSumFluxToRowCentroidFit = TcolumnSumFluxToRowCentroidFit(:, 1:indexEndColumnSum);
    TpixelsToColumnSumFlux = TpixelsToColumnSumFlux(1:indexEndColumnSum, :);

    TrowSumFluxToColumnCentroidFit = TrowSumFluxToColumnCentroidFit(:, 1:indexEndRowSum);
    TpixelsToRowSumFlux = TpixelsToRowSumFlux(1:indexEndRowSum,:);


    CcentroidRow = TcolumnSumFluxToRowCentroidFit * TpixelsToColumnSumFlux * CtargetPixelsAllRowCentroid *...
        TpixelsToColumnSumFlux' * TcolumnSumFluxToRowCentroidFit';

    CcentroidColumn = TrowSumFluxToColumnCentroidFit * TpixelsToRowSumFlux * CtargetPixelsAllColumnCentroid *...
        TpixelsToRowSumFlux' * TrowSumFluxToColumnCentroidFit';

    centroidColumnUncertainties(:, cadenceIndex) = sqrt(diag(CcentroidColumn));
    centroidRowUncertainties(:, cadenceIndex) = sqrt(diag(CcentroidRow));


    [Trow,errFlagRow] = factor_covariance_matrix(CcentroidRow);
    [Tcolumn,errFlagColumn] = factor_covariance_matrix(CcentroidColumn);


    if(  errFlagRow < 0 || errFlagColumn < 0)

        warning('PDQ:centroidCalculation:InvalidCcentroidRowColumnCovMat', ...
            'CcentroidColumnCcentroidRow:centroid Column/Row Covariance matrix must be positive definite or positive semidefinite.');

        centroidRows(:, cadenceIndex) = -1;
        centroidCols(:, cadenceIndex) = -1;
        centroidColumnUncertainties(:, cadenceIndex) = -1;
        centroidRowUncertainties(:, cadenceIndex) = -1;
        pdqTempStruct.centroidUncertaintyStructOld(cadenceIndex).TcolumnSumFluxToRowCentroidFit = [];
        pdqTempStruct.centroidUncertaintyStructOld(cadenceIndex).TpixelsToColumnSumFlux = [];
        pdqTempStruct.centroidUncertaintyStructOld(cadenceIndex).CtargetPixelsAllRowCentroid = [];
        pdqTempStruct.centroidUncertaintyStructOld(cadenceIndex).CcentroidRow = [];

        pdqTempStruct.centroidUncertaintyStructOld(cadenceIndex).TrowSumFluxToColumnCentroidFit = [];
        pdqTempStruct.centroidUncertaintyStructOld(cadenceIndex).TpixelsToRowSumFlux = [];
        pdqTempStruct.centroidUncertaintyStructOld(cadenceIndex).CtargetPixelsAllColumnCentroid = [];
        pdqTempStruct.centroidUncertaintyStructOld(cadenceIndex).CcentroidColumn = [];
        continue;


    end

    % copy to uncertainty structre

    pdqTempStruct.centroidUncertaintyStructOld(cadenceIndex).TcolumnSumFluxToRowCentroidFit = TcolumnSumFluxToRowCentroidFit;
    pdqTempStruct.centroidUncertaintyStructOld(cadenceIndex).TpixelsToColumnSumFlux = TpixelsToColumnSumFlux;
    pdqTempStruct.centroidUncertaintyStructOld(cadenceIndex).CtargetPixelsAllRowCentroid = CtargetPixelsAllRowCentroid;
    pdqTempStruct.centroidUncertaintyStructOld(cadenceIndex).CcentroidRow = CcentroidRow;

    pdqTempStruct.centroidUncertaintyStructOld(cadenceIndex).TrowSumFluxToColumnCentroidFit = TrowSumFluxToColumnCentroidFit;
    pdqTempStruct.centroidUncertaintyStructOld(cadenceIndex).TpixelsToRowSumFlux = TpixelsToRowSumFlux;
    pdqTempStruct.centroidUncertaintyStructOld(cadenceIndex).CtargetPixelsAllColumnCentroid = CtargetPixelsAllColumnCentroid;
    pdqTempStruct.centroidUncertaintyStructOld(cadenceIndex).CcentroidColumn = CcentroidColumn;

    warning on all;

end % cadence loop

if( any(any((centroidColumnUncertainties./centroidCols) > 1.0)) || any(any((centroidRowUncertainties./centroidRows) > 1.0)))
    warning('PDQ:centroidCalculation:centroidColumnRowUncertainties', ...
        'centroidColumnRowUncertainties:centroidColumn/RowUncertainties >> centroidCols/centroidRows ');
    pdqTempStruct.centroidRows = -1*ones(size(centroidRows));
    pdqTempStruct.centroidCols = -1*ones(size(centroidCols));
    pdqTempStruct.centroidRowUncertainties = -1*ones(size(centroidRowUncertainties));
    pdqTempStruct.centroidColumnUncertainties = -1*ones(size(centroidColumnUncertainties));

end

pdqTempStruct.centroidRowsOld = centroidRows;
pdqTempStruct.centroidColsOld = centroidCols;
pdqTempStruct.centroidRowUncertaintiesOld = centroidRowUncertainties;
pdqTempStruct.centroidColumnUncertaintiesOld = centroidColumnUncertainties;

warning on all;


%..................................................................
prfFilename = sprintf('prf%02d%d-2008032321.dat', pdqTempStruct.ccdModule, pdqTempStruct.ccdOutput);
fprintf('reading  %s......\n', prfFilename );
fid = fopen(['/path/to/ETEM_PSFs/all_blobs/' prfFilename]);
% fid = fopen('/path/to/matlab/tad/coa/prfBlob_z1f1_4.dat');

% prfBlob = fread(fid, 'uint8=>uint8');
% fclose(fid);
% % Instantiate a prf object. Blob must first be converted to struct.
% prfStruct = blob_to_struct(prfBlob);
% prfObject = prfClass(prfStruct);

prfBlob = fread(fid, 'uint8=>uint8');
fclose(fid);
% Instantiate a prf object. Blob must first be converted to struct.
prfStruct = blob_to_struct(prfBlob);

if(isfield(prfStruct, 'c')) % it's a single prf model
    prfModelStruct.polyStruct = prfStruct;
else
    prfModelStruct = prfStruct;
end

prfObject = prfCollectionClass(prfModelStruct,fcConstantsStruct);



for cadenceIndex = 1 : numCadences

    prfRowJacobianAllTargets = zeros(numTargets, sum(pdqTempStruct.numPixels));
    prfColumnJacobianAllTargets = zeros(numTargets, sum(pdqTempStruct.numPixels));

    indexBegin = 1;
    for targetIndex = 1 : numTargets

        %------------------------------------------------------------------
        % brightness weighted centroid calculation (not PSF fitting)
        %------------------------------------------------------------------
        [targetPixelFluxes, CtargetPixels, targetRows, targetColumns] = extract_target_pixels_and_uncertainties(pdqTempStruct, cadenceIndex, targetIndex);

        prfCovMatrix = zeros(size(CtargetPixels,1), size(CtargetPixels,2),2);
        prfCovMatrix(:,:,1) = CtargetPixels;
        [prfCentroidRow, prfCentroidColumn, centroidStatus, prfCentroidCovariance, prfRowJacobian, prfColumnJacobian, amplitude]...
            = compute_prf_centroid(targetRows, targetColumns, targetPixelFluxes, prfCovMatrix, ...
            prfObject, pdqTempStruct.cadenceTimes(cadenceIndex),prfCentroidRowGuesses(targetIndex, cadenceIndex),...
            prfCentroidColumnGuesses(targetIndex, cadenceIndex));

        indexEnd = indexBegin + length(targetRows) -1;
        prfRowJacobianAllTargets(targetIndex, indexBegin:indexEnd) = prfRowJacobian;
        prfColumnJacobianAllTargets(targetIndex, indexBegin:indexEnd) = prfColumnJacobian;
        indexBegin = indexEnd +1;

    end

    CcentroidRow = prfRowJacobianAllTargets * CtargetPixelsAllRowCentroid *prfRowJacobianAllTargets';

    CcentroidColumn = prfColumnJacobianAllTargets * CtargetPixelsAllColumnCentroid *prfColumnJacobianAllTargets';

    prfCentroidColumnUncertainties(:, cadenceIndex) = sqrt(diag(CcentroidColumn));
    prfCentroidRowUncertainties(:, cadenceIndex) = sqrt(diag(CcentroidRow));


    [Trow,errFlagRow] = factor_covariance_matrix(CcentroidRow);
    [Tcolumn,errFlagColumn] = factor_covariance_matrix(CcentroidColumn);


    fprintf('');

end
%..................................................................

return

function ygauss = gaussian(alpha, x)

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function ygauss = gaussian(alpha, x)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
%   ygauss = gaussian(alpha,X) gives the predicted fit of the
%   Gaussian as a function of the vector of
%   parameters, ALPHA, and the matrix of data, X.
%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

a1 = alpha(1);
a2 = alpha(2);
a3 = alpha(3);

ygauss = a1 * exp(-((x-a2).*(x-a2))./(2*a3*a3) ) ;



return
