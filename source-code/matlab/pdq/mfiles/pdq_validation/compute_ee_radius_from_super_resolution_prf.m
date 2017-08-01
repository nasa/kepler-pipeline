function pdqTempStruct = compute_ee_radius_from_super_resolution_prf(pdqTempStruct, fcConstantsStruct)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function pdqTempStruct = compute_ee_radius_from_super_resolution_prf(pdqTempStruct, fcConstantsStruct)
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

module                      = pdqTempStruct.ccdModule;
output                      = pdqTempStruct.ccdOutput;
currentModOut               = pdqTempStruct.currentModOut;


eePixelExclusionIndicators = true(size(pdqTempStruct.targetGapIndicators));
haloAroundOptimalApertureInPixels = pdqTempStruct.haloAroundOptimalApertureInPixels;

eeRadiusFromPrf = zeros(numTargets,numCadences);
timeToCalculateHiResPrf = 0;
nUniqueTargetRows = 0;
nUniqueTargetColumns = 0;
numPixels           = pdqTempStruct.numPixels;
indexStart = 1;

targetPixelRows     = pdqTempStruct.targetPixelRows;
targetPixelColumns  = pdqTempStruct.targetPixelColumns;

targetPixelsStarEnd = zeros(numTargets,2);

for j = 1:numTargets

    indexEnd    = indexStart + numPixels(j) -1;

    nUniqueTargetRows = nUniqueTargetRows + length(unique( targetPixelRows(indexStart : indexEnd)));
    nUniqueTargetColumns = nUniqueTargetColumns +length(unique(targetPixelColumns(indexStart : indexEnd)));

    targetPixelsStarEnd(j,:) = [indexStart ; indexEnd];

    indexStart = indexEnd + 1;
end


centroidRowUncertainties = zeros(numTargets, numCadences);
centroidColumnUncertainties = zeros(numTargets, numCadences);

centroidUncertaintyStruct = repmat(struct('prfRowJacobianAllTargets', [],  ...
    'CtargetPixelsAllRowCentroid',[], 'CcentroidRow', [],...
    'prfColumnJacobianAllTargets', [],  ...
    'CtargetPixelsAllColumnCentroid', [], 'CcentroidColumn' , []), numCadences, 1);

pdqTempStruct.centroidUncertaintyStruct = centroidUncertaintyStruct;


fprintf('reading  %s......\n', pdqTempStruct.prfFilename );
fid = fopen(pdqTempStruct.prfFilename);
if(fid == -1) % unable to open file
    error('PDQ:compute_prf_based_centroids:prfFileNotFound', ...
        ['could not open prf model file ' pdqTempStruct.prfFilename ]);

end

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

prfCentroidRowGuesses = zeros(numTargets, numCadences);
prfCentroidColumnGuesses = zeros(numTargets, numCadences);


%------------------------------------------------------------------
% Loop over all cadences, and for each cadence all targets
%------------------------------------------------------------------
debugLevel = pdqTempStruct.debugLevel;

for cadenceIndex = 1 : numCadences

    CtargetPixelsAllRowCentroid    = pdqTempStruct.targetPixelsUncertaintyStruct(cadenceIndex).CtargetPixels;
    CtargetPixelsAllColumnCentroid    = pdqTempStruct.targetPixelsUncertaintyStruct(cadenceIndex).CtargetPixels;

    if(isempty(CtargetPixelsAllRowCentroid))
        centroidRows(:, cadenceIndex) = -1;
        centroidCols(:, cadenceIndex) = -1; % that column entries are set to -1
        centroidColumnUncertainties(:, cadenceIndex) = -1;
        centroidRowUncertainties(:, cadenceIndex) = -1;

        pdqTempStruct.centroidUncertaintyStruct(cadenceIndex).prfRowJacobianAllTargets = [];
        pdqTempStruct.centroidUncertaintyStruct(cadenceIndex).CtargetPixelsAllRowCentroid = [];
        pdqTempStruct.centroidUncertaintyStruct(cadenceIndex).CcentroidRow = [];

        pdqTempStruct.centroidUncertaintyStruct(cadenceIndex).prfColumnJacobianAllTargets = [];
        pdqTempStruct.centroidUncertaintyStruct(cadenceIndex).CtargetPixelsAllColumnCentroid = [];
        pdqTempStruct.centroidUncertaintyStruct(cadenceIndex).CcentroidColumn = [];

        continue; % no targets present for this cadence
    end

    prfRowJacobianAllTargets = zeros(numTargets, sum(~pdqTempStruct.targetGapIndicators(:,cadenceIndex)));
    prfColumnJacobianAllTargets = zeros(numTargets, sum(~pdqTempStruct.targetGapIndicators(:,cadenceIndex)));

    indexBegin = 1;
    skipCadenceFlag = false;

    for targetIndex = 1 : numTargets

        %------------------------------------------------------------------
        % get the row, column, pixel values, and cov. matrix for this
        % target
        %------------------------------------------------------------------
        [targetPixelFluxes, CtargetPixels, targetRows, targetColumns, inOptimalAperture] = ...
            extract_target_pixels_and_uncertainties(pdqTempStruct, cadenceIndex, targetIndex);

        if(isempty(targetPixelFluxes))

            % all the pixels for this target for this cadence gapped
            centroidRows(targetIndex, cadenceIndex) = -1;
            centroidCols(targetIndex, cadenceIndex) = -1;
            centroidColumnUncertainties(targetIndex, cadenceIndex) = -1;
            centroidRowUncertainties(targetIndex, cadenceIndex) = -1;
            continue;
        end

        %------------------------------------------------------------------
        % flux weighted centroids as seeds for prf based centroids
        %------------------------------------------------------------------

        if(any(inOptimalAperture)) % this inOptimalAperture flag is applicable to the pixels returned by extract_target_pixels_and_uncertainties


            % now add 1 pixel wide ring around the optimal aperture to
            % provide buffer against optimal aperture drift due to dva/spacecraft jitter


            [inExpandedOptimalAperture] = add_ring_to_aperture(targetRows, targetColumns, inOptimalAperture, haloAroundOptimalApertureInPixels);

            % find if any of the target pixels come from the smear regions
            indexInSmearRegions = find(targetRows <= pdqTempStruct.nMaskedSmearRows ...
                | targetRows >= (pdqTempStruct.nMaskedSmearRows + pdqTempStruct.nRowsImaging ));

            indexInBlackRegions = find(targetColumns <= pdqTempStruct.nLeadingBlackColumns ...
                | targetColumns >= (pdqTempStruct.nLeadingBlackColumns + pdqTempStruct.nColsImaging ));

            invalidIndices = [indexInSmearRegions indexInBlackRegions]; % works even if all are empty

            if(~isempty(invalidIndices))
                inExpandedOptimalAperture(invalidIndices)    = false;  % declare as gaps
            end

            starFlux = sum(targetPixelFluxes(inExpandedOptimalAperture));
            fluxWeightedCentroidRow     = targetRows(inExpandedOptimalAperture)'* targetPixelFluxes(inExpandedOptimalAperture) / starFlux;
            fluxWeightedCentroidColumn  = targetColumns(inExpandedOptimalAperture)'* targetPixelFluxes(inExpandedOptimalAperture) / starFlux;

        else

            warning('PDQ:centroidCalculation:noPixelsInOptimalAperture', ...
                'fluxWeightedCentroid:No pixels in optimal aperture and hence can''t seed the centroids for PRF based centroid estimation.');

            centroidRows(:, cadenceIndex) = -1;
            centroidCols(:, cadenceIndex) = -1;
            centroidColumnUncertainties(:, cadenceIndex) = -1;
            centroidRowUncertainties(:, cadenceIndex) = -1;
            pdqTempStruct.centroidUncertaintyStruct(cadenceIndex).prfRowJacobianAllTargets = [];
            pdqTempStruct.centroidUncertaintyStruct(cadenceIndex).CtargetPixelsAllRowCentroid = [];
            pdqTempStruct.centroidUncertaintyStruct(cadenceIndex).CcentroidRow = [];

            pdqTempStruct.centroidUncertaintyStruct(cadenceIndex).prfColumnJacobianAllTargets = [];
            pdqTempStruct.centroidUncertaintyStruct(cadenceIndex).CtargetPixelsAllColumnCentroid = [];
            pdqTempStruct.centroidUncertaintyStruct(cadenceIndex).CcentroidColumn = [];
            continue;
        end

        %------------------------------------------------------------------
        % prf based centroid calculation
        %------------------------------------------------------------------

        prfCentroidRowGuesses(targetIndex, cadenceIndex) = fluxWeightedCentroidRow;
        prfCentroidColumnGuesses(targetIndex, cadenceIndex) = fluxWeightedCentroidColumn;

        prfCovMatrix = zeros(size(CtargetPixels,1), size(CtargetPixels,2),2);
        prfCovMatrix(:,:,1) = CtargetPixels;


        [prfCentroidRow, prfCentroidColumn, centroidStatus, prfCentroidCovariance, prfRowJacobian, prfColumnJacobian, amplitude]...
            = compute_prf_centroid(targetRows, targetColumns, targetPixelFluxes, prfCovMatrix, ...
            prfObject, pdqTempStruct.cadenceTimes(cadenceIndex),prfCentroidRowGuesses(targetIndex, cadenceIndex),...
            prfCentroidColumnGuesses(targetIndex, cadenceIndex));

        [prfFitted, prfRows, prfColumns] = evaluate(prfObject, prfCentroidRow, prfCentroidColumn);
        prfFittedFlux = prfFitted.*amplitude;


        if(debugLevel)
            if(cadenceIndex == 1)

                % plot how well the prf fitted the star pixel flux profile

                [commonPixelValues, indexIntoPrf, indexIntoTarget] = intersect([prfRows prfColumns], [targetRows, targetColumns], 'rows');
                figure;
                subplot(2,1,1);
                h1 = plot(targetPixelFluxes, 'b.-');
                xlim([1, length(targetPixelFluxes)]);
                hold on;
                h2 = plot(indexIntoTarget, prfFittedFlux(indexIntoPrf),'r.-');
                legend([h1 h2], {'target pixel flux'; 'prf fitted flux'});
                xlabel('index of target pixels');
                ylabel('pixel flux in photo electrons');
                title(['Prf fit of target pixels with Kepler Id '  num2str(pdqTempStruct.keplerIds(targetIndex)) ', KeplerMag ' num2str(pdqTempStruct.keplerMags(targetIndex))]);
                subplot(2,1,2);

                residualFluxAfterFit = zeros(length(targetPixelFluxes),1);

                residualFluxAfterFit(indexIntoTarget) = targetPixelFluxes(indexIntoTarget) - prfFittedFlux(indexIntoPrf);


                plot(indexIntoTarget,residualFluxAfterFit(indexIntoTarget), 'bp-');
                xlim([1, length(targetPixelFluxes)]);

                xlabel('common index between target row/column and prf row/column');
                ylabel('error in photo electrons');
                title('Prf fit of target pixels - target pixel flux');
                fileNameStr = ['prf_fit_quality_kepler_id_'  num2str(pdqTempStruct.keplerIds(targetIndex))  '_module_' num2str(module) '_output_', num2str(output)  '_modout_' num2str(currentModOut)];

                paperOrientationFlag = true;
                includeTimeFlag = false;
                printJpgFlag = false;

                % add figure caption as user data
                plotCaption = strcat(...
                    'In this plot, targets'' pixel fluxes (encircled energy) and the prf fitted fluxes are plotted as a function\n',...
                    'of the target pixel index. Also plotted is the residual flux (the difference between the target flux and the\n',...
                    'prf fit. This plot serves to illustrate how well or how poorly the prf fit approximates the data\n',...
                    'Click on the link to open the figure in Matlab to examine the pixels closely. \n');
                set(h1, 'UserData', sprintf(plotCaption));

                plot_to_file(fileNameStr, paperOrientationFlag, includeTimeFlag, printJpgFlag);
                close all;
            end

        end


        [sortedPrfFlux sortIndex] = sort(prfFittedFlux, 'descend');

        if(sum(prfFittedFlux) ~= 0)
            cumPrfFlux = cumsum(sortedPrfFlux)./sum(prfFittedFlux);
            cumPrfFlux = cumPrfFlux*100; % convert to percentage
        else

            warning('PDQ:compute_prf_based_centroids:invalidPrf', ...
                ['compute_prf_based_centroids:sum of prf fitted flux equals zero; skipping cadence ' num2str(cadenceIndex)]);
            skipCadenceFlag = true;
            break;
        end



        cutOffIndex = find(cumPrfFlux >= 99.5, 1, 'first');

        %         bkgdUncertainty= pdqTempStruct.bkgdLevelsUncertainties(targetIndex, cadenceIndex);
        %         cutOffIndex2 = find(cumPrfFlux <= 3*bkgdUncertainty, 1, 'last');


        inclusionIndex = sortIndex(1:cutOffIndex);
        % find the pixels in target aperture that correspond to pixels in the PRF that made it to the inclusion list


        % model was specified with pixels
        rowsColsPrf = [prfRows(inclusionIndex), prfColumns(inclusionIndex)];
        rowsColsTarget = [targetRows(:), targetColumns(:)];


        % find the common rows and column
        [commonRowColumns, indexIntoTarget] = intersect(rowsColsTarget, rowsColsPrf, 'rows');


        indexEnd = indexBegin + length(targetRows) - 1;

        indexForThisTarget = targetPixelsStarEnd(targetIndex,1):targetPixelsStarEnd(targetIndex,2);

        eePixelExclusionIndicators(indexForThisTarget(indexIntoTarget),cadenceIndex) = false; % include the pixels by setting the gap to false


        prfRowJacobianAllTargets(targetIndex, indexBegin:indexEnd) = prfRowJacobian;
        prfColumnJacobianAllTargets(targetIndex, indexBegin:indexEnd) = prfColumnJacobian;


        indexBegin = indexEnd +1;


        centroidRows(targetIndex, cadenceIndex) = prfCentroidRow;
        centroidCols(targetIndex, cadenceIndex) = prfCentroidColumn;


        %----------------------------- calculate EE from PRF -------------------------------------------
        % turn off when not needed for regular runs, is is a time hog 
        % ee radius computed from can be compared to the computed ee metric over the focal plane

        % default resolution of 100 pixels for now
        tStartToCalculateHiResPrf = tic ;
        
        [prfArray, prfSubPixelRows, prfSubPixelColumns] = make_array(prfObject, prfCentroidRow, prfCentroidColumn);
        
        prfArray = prfArray/sum(sum(prfArray));

        % convert to absolute co-ordinates prfSubPixelRows run from 0 through 11 with the first pixel being
        % centered at 0.5 pixel

        prfSubPixelRows = prfSubPixelRows + min(prfRows) - 1;

        prfSubPixelColumns = prfSubPixelColumns + min(prfColumns) - 1;

        prfSubPixelRows = prfSubPixelRows(:);
        prfSubPixelColumns = prfSubPixelColumns(:);

        prfArray = prfArray(:);


        distFromPrfCentroid = sqrt( (prfSubPixelRows - prfCentroidRow).^2 + (prfSubPixelColumns - prfCentroidColumn).^2 );

        [minDist, sortLinearIndex] = sort(distFromPrfCentroid);

        newCumPrf = cumsum(prfArray(sortLinearIndex));

        eeCutOffIndex = find(newCumPrf >= pdqTempStruct.eeFluxFraction, 1, 'first');

        % locate this pixel and find its distance from centroid

        eeRadiusFromPrf(targetIndex, cadenceIndex) = sqrt( (prfSubPixelRows(sortLinearIndex(eeCutOffIndex)) - prfCentroidRow).^2 + (prfSubPixelColumns(sortLinearIndex(eeCutOffIndex)) - prfCentroidColumn).^2 );

        timeToCalculateHiResPrf = timeToCalculateHiResPrf + toc(tStartToCalculateHiResPrf) ;
        %----------------------------- calculate EE from PRF -------------------------------------------
        
    end % target loop

    % account for data gaps
    if(~skipCadenceFlag)

        CcentroidRow = prfRowJacobianAllTargets * CtargetPixelsAllRowCentroid *prfRowJacobianAllTargets';

        CcentroidColumn = prfColumnJacobianAllTargets * CtargetPixelsAllColumnCentroid *prfColumnJacobianAllTargets';

        centroidColumnUncertainties(:, cadenceIndex) = sqrt(diag(CcentroidColumn));
        centroidRowUncertainties(:, cadenceIndex) = sqrt(diag(CcentroidRow));

        [Trow,errFlagRow] = factor_covariance_matrix(CcentroidRow);
        [Tcolumn,errFlagColumn] = factor_covariance_matrix(CcentroidColumn);
    else
        % minor annoyance - errFlagRow,  errFlagColumn have to exist so
        % same black of code can be used to skip cadence
        errFlagRow = -1;
        errFlagColumn = -1;

    end

    if(errFlagRow < 0 || errFlagColumn < 0 || skipCadenceFlag)

        warning('PDQ:centroidCalculation:InvalidCcentroidRowColumnCovMat', ...
            'CcentroidColumnCcentroidRow:centroid Column/Row Covariance matrix must be positive definite or positive semidefinite.');

        centroidRows(:, cadenceIndex) = -1;
        centroidCols(:, cadenceIndex) = -1;
        centroidColumnUncertainties(:, cadenceIndex) = -1;
        centroidRowUncertainties(:, cadenceIndex) = -1;
        pdqTempStruct.centroidUncertaintyStruct(cadenceIndex).prfRowJacobianAllTargets = [];
        pdqTempStruct.centroidUncertaintyStruct(cadenceIndex).CtargetPixelsAllRowCentroid = [];
        pdqTempStruct.centroidUncertaintyStruct(cadenceIndex).CcentroidRow = [];

        pdqTempStruct.centroidUncertaintyStruct(cadenceIndex).prfColumnJacobianAllTargets = [];
        pdqTempStruct.centroidUncertaintyStruct(cadenceIndex).CtargetPixelsAllColumnCentroid = [];
        pdqTempStruct.centroidUncertaintyStruct(cadenceIndex).CcentroidColumn = [];
        continue;


    end

    % copy to uncertainty structre

    pdqTempStruct.centroidUncertaintyStruct(cadenceIndex).prfRowJacobianAllTargets = prfRowJacobianAllTargets;
    pdqTempStruct.centroidUncertaintyStruct(cadenceIndex).CtargetPixelsAllRowCentroid = CtargetPixelsAllRowCentroid;
    pdqTempStruct.centroidUncertaintyStruct(cadenceIndex).CcentroidRow = CcentroidRow;

    pdqTempStruct.centroidUncertaintyStruct(cadenceIndex).prfColumnJacobianAllTargets = prfColumnJacobianAllTargets;
    pdqTempStruct.centroidUncertaintyStruct(cadenceIndex).CtargetPixelsAllColumnCentroid = CtargetPixelsAllColumnCentroid;
    pdqTempStruct.centroidUncertaintyStruct(cadenceIndex).CcentroidColumn = CcentroidColumn;

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

pdqTempStruct.centroidRows = centroidRows;
pdqTempStruct.centroidCols = centroidCols;
pdqTempStruct.centroidRowUncertainties = centroidRowUncertainties;
pdqTempStruct.centroidColumnUncertainties = centroidColumnUncertainties;
pdqTempStruct.eePixelExclusionIndicators = eePixelExclusionIndicators | pdqTempStruct.targetGapIndicators; % incorporate preexisting gaps

% turn off, not needed for production run

fprintf('PDQ: Computing encircled energy radius using super resolution PRF took %f seconds\n', timeToCalculateHiResPrf);

pdqTempStruct.eeRadiusFromPrf = eeRadiusFromPrf ;

warning on all;

return

