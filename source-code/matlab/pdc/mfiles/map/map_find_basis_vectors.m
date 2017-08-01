%*******************************************************************************
%% function [success] = map_find_basis_vectors (mapData, mapInput)
%*******************************************************************************
%
%   Creates the basis vector U_hat matrix based on a SVD on the most highly correlated targets. The
%   number of basis vectors is based on mapParams.svdOrder which is either user
%   selectable or automatically found (if svdOrder == 0).
%
%   The targets used for generating the basis vectors is unaffected by if there is valid KIC data or
%   not. But the vectors selected for generating the prior PDF must have complete valid KIC data.
%   Those without are removed from the list.
%
%   If mapInput.mapParams.useBasisVectorsFromBlob is true then the basis vectors saved in mapInput.cbvBlobStruct is
%   used instead of this function finding new basis vectors. The cadence length of the basis vector must be
%   the same as the light curves passed to MAP.
%
%******************************************************************************
% Inputs:
%       mapData     -- mapDataClass handle
%       mapInput    -- mapInputClass handle
%
%******************************************************************************
% Outputs:
%       success     -- [logical] False if basis vectors could not be found (usually because too few light
%                                 curves to properly perform SVD)
%       mapData.basisVectors
%       mapData.nBasisVectors
%       mapData.targetsForSvd
%       mapData.targetsForGeneratingPriors
%
%%
%*******************************************************************************
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

function [success] = map_find_basis_vectors (mapData, mapInput)

success = false;

%***
% Special Logic for smoke test:
% During smoke tests very poor data is passed to PDC. The entropy cleaner below will dutifully remove all the
% bad data light curves from the set and in some cases remove every last light curve. This results in none
% left for SVD. So, either we crash in this case or return with mapFailed = true. In productions runs we want
% to crash so that an operator is flagged and the reason for the bad data is resolved. For smoke tests we just
% want the routine to run to completion and test the algorithm for executability. (This is something a
% compiled language would test on it's own but oh well...) 
% Here we are checking to make sure the parameters are set properly for either the smoke test or production
% runs. If the entropy cleaner is running then we want to also ensure a minimum number of targets remain, if
% no minimum then do not run the entropy cleaner.
if (mapInput.mapParams.minFractionOfTargetsForSvd < 0.01 && mapInput.mapParams.entropyCleaningEnabled)
    error('If minFractionOfTargetsForSvd < 0.01 then the entropy cleaner should not be enabled  (via entropyCleaningEnabled)!');
end

% We want to keep a lot of singular vectors, many more than the small number of basis vectors, however keeping
% all is a memory hog for the U matrix so how many are we to save?
nSingularVectors = 128;

component = 'basisVectors';

mapInput.debug.display(component, 'Finding Basis Vectors...');

% We wish to normalize the flux specifically for basis vector generation. The method is dependent on the msMAP band and <svdNormalizationMethod>.
% Remember that mapData.normTargetDataStruct is normalized by <fitNormalizationMethod> and NOT used here
% The normalized flux here is NOT persisted outside map_find_basis_vectors
doNanGaps = false;
doMaskEpRecovery = mapInput.pdcModuleParameters.variabilityEpRecoveryMaskEnabled; % Only really used if normMethod = 'std'
maskWindow = mapInput.pdcModuleParameters.variabilityEpRecoveryMaskWindow;
[normTargetDataStruct, medianFlux, meanFlux, stdFlux, noiseFloor] = ...
                                mapNormalizeClass.normalize_flux (mapInput.targetDataStruct, ...
                                mapInput.mapParams.svdNormalizationMethod, doNanGaps, ...
                                doMaskEpRecovery, mapInput.cadenceTimes, maskWindow);
normFlux = [normTargetDataStruct.values];

%*******************************************************************************
% Sort by Correlation

correlationMatrix = pdc_compute_correlation(normTargetDataStruct);

% Plot the raw Correlation
if (mapInput.debug.query_do_plot(component))
    if(~mapInput.debug.doCloseAfterSaveFigures)
        % Plot the correlation matrix.
        correlationFig = mapInput.debug.create_figure;
        imagesc(abs(correlationMatrix));
        colorbar;
        title('MAP Empirical Target to Target Correlation for Raw Correlation');
        % no need to save the correlation matrix (big file and no important information)
        %mapInput.debug.save_figure(correlationFig , component, 'correlation_matrix_for_raw_correlation');
    end

    % Plot the median absolute correlation per star
    correlationHist = mapInput.debug.create_figure;
    medianAbsCorrPerStar = median(abs(correlationMatrix));
    hist(medianAbsCorrPerStar, 50, 'r');
    grid on;
    xlim([0,1]);
    title(['Median Absolute Correlation Per Star; Median Correlation Overall: ', ...
            num2str(median(medianAbsCorrPerStar)), '; for Raw Correlation']);
    mapInput.debug.save_figure(correlationHist , component, 'raw_correlation_histogram');
end

%*******************************************************************************
% Use explicit basis vectors instead of finding them here.
if (mapInput.mapParams.useBasisVectorsFromBlob || mapInput.mapParams.useBasisVectorsAndPriorsFromBlob || ...
        mapInput.mapParams.useBasisVectorsAndPriorsFromPixels)

    if (isempty(mapInput.cbvBlobStruct))
        error('map_find_basis_vectors: cbvBlobStruct appears to be empty');
    end

    if (isempty(mapInput.cbvBlobStruct.basisVectorsNoBands))
        string = [mapInput.debug.runLabel, ': No basis vectors are being passed from the CBV blob, so MAP cannot be performed.'];
        mapInput.debug.display(component, string);
        [mapData.alerts] = add_alert(mapData.alerts, 'warning', string);
        success = false;
        return;
    end

    if (mapInput.mapParams.svdOrder == 0)
        % pick min of svdMaxOrder and # basis vectors passed
        svdOrder = min([mapInput.mapParams.svdMaxOrder ...
                    length(mapInput.cbvBlobStruct.basisVectorsNoBands(1,:))]);
    else
        % pick min of svdOrder, svdMaxOrder and # basis vectors passed
        svdOrder = min([mapInput.mapParams.svdOrder mapInput.mapParams.svdMaxOrder ...
                    length(mapInput.cbvBlobStruct.basisVectorsNoBands(1,:))]);
    end
    mapData.basisVectors  = mapInput.cbvBlobStruct.basisVectorsNoBands(:,1:svdOrder);
    mapData.nBasisVectors = length(mapData.basisVectors(1,:));
    mapData.targetsForSvd = []; % CBVs were imported.

    % This is needed for denoising below
    U = mapData.basisVectors;
    
else % Find the basis vectors!
%*******************************************************************************
%*******************************************************************************

if (mapInput.mapParams.useOnlyQuietStarsForSvd)
    % An additional optional cut is to remove the variable targets from this list
    nonReducedTargetsForSvd = (mapData.variability < mapInput.mapParams.variabilityCutoff);
    nonReducedTargetsForSvd(~mapInput.targetsForBasisVectorsAndPriors) = false;
else
    % Only select targets specified with targetsForBasisVectorsAndPriors
    nonReducedTargetsForSvd = mapInput.targetsForBasisVectorsAndPriors;
end

% Remove custom targets and any other targets to exclude
nonReducedTargetsForSvd([mapInput.targetDataStruct.excludeBasedOnLabels]) = false;

if (all([mapInput.targetDataStruct.excludeBasedOnLabels]))
    error ('All targets are being excluded from basis vector generation via excludeBasedOnLabels. MAP cannot run and PDC will now fail!');
end

% Remove targets where ra, dec and kepMag were not found
nonReducedTargetsForSvd(mapData.targetsWhereKicDataNotFound) = false;

% Remove Eclipsing Binaries
% Older task files do not have the eclipsingBinary flag in the transit information, so use old catalog for such cases.
useHardCatalogAsBackup = true;
ebHere = pdcTransitClass.identify_eclipsing_binaries (mapInput.targetDataStruct, useHardCatalogAsBackup);
nonReducedTargetsForSvd(ebHere) = false;

nTargetsForSvd = length(find(nonReducedTargetsForSvd));

if (nTargetsForSvd < 1)
    error ('No targets are available for SVD. MAP cannot run and PDC will now fail!');
end
    

% NOTE: 1.1 We need to create a reduced target set and sort by median absolute correlation to find the targets
% used for SVD. However, we also need the target indicators in the full target array to keep track
% of which targets were used for SVD. The method used below is slightly awkward, there may be
% a more elegent way to do this! Nomenclature is tricky here. Reduced means the indices are
% referenced to a shortened target array (less than mapData.nTargets). The entire reason for all
% this is the need to sort a reduced set of target to find the most highly correlated of the subset.

% Median correlation coefficient per star
medianReducedAbsCorrPerStar = median(abs(correlationMatrix(:,nonReducedTargetsForSvd)));

% Sort
[~, sortedReducedCorrIndices] = sort(medianReducedAbsCorrPerStar);

% Create reduced arrays ordered by sorted correlation
% These are the targets used in SVD to find the basis vectors
midIndex = round(nTargetsForSvd*(1-mapInput.mapParams.fractionOfStarsToUseForSvd));
if (midIndex == 0)
    % This means all targets
    midIndex = 1;
end
reducedTargetIndicesForSvd = sortedReducedCorrIndices(midIndex:end);
nTargetsForSvd = length(reducedTargetIndicesForSvd);
if (nTargetsForSvd < 1)
    error ('No targets are available for SVD. MAP cannot run and PDC will now fail!');
end
reducedNormFlux = normFlux(:,nonReducedTargetsForSvd);
reducedNormFlux = reducedNormFlux(:,reducedTargetIndicesForSvd);
    
% Get the targets in the full array that are used for SVD
allTargetIndices = 1:mapData.nTargets;
reducedTargetIndicesInFullArray = allTargetIndices(nonReducedTargetsForSvd);
reducedTargetIndicesInFullArray = reducedTargetIndicesInFullArray(reducedTargetIndicesForSvd);
mapData.targetsForSvd = false(mapData.nTargets, 1);
mapData.targetsForSvd(reducedTargetIndicesInFullArray) = true;

% Set entropy cleaning here so we have option to not do it if too few targets found
doEntropyCleaning = mapInput.mapParams.entropyCleaningEnabled;

entropyCleanerRun = false;
[tooFewTargetsForMapToRun, underMinNumberToTrustSvd] = check_number_of_remaining_targets(mapInput, ...
        mapData, nTargetsForSvd, entropyCleanerRun);
if (tooFewTargetsForMapToRun)
    success = false;
    return;
elseif(underMinNumberToTrustSvd)
    doEntropyCleaning = false;
end

%*******************************************************************************
% Do SVD and find reduced rank principle component vectors
%
% Optionally use an entropy based iterative cleaning

% Dither Normalized Flux to remove zero signal amplitude at midway point
if (mapInput.mapParams.ditherFlux)
    [reducedNormFlux] = dither_flux (mapInput.mapParams.ditherMagnitude, ...
                                mapInput.randomStream, reducedNormFlux);
end

mapInput.debug.display(component, 'Computing CBVs...');
tic;
% The SVD call
[U, S, V] = svd(reducedNormFlux);
if (isempty(find(diag(S), 1)))
    % If all singular values are zero then MAP failed. (all inputs are zero?)
    success = false;
    return;
end

% Find entropy of CBVs
mapData.basisVectorEntropy = basis_vector_entropy (V);

% Find svdOrder
if (mapInput.mapParams.svdOrder == 0)
    % We shouldn't auto-find the svdOrder before first entropy cleaning so, set to maximum number of possible
    % basis vectors. If this is set too high then entropy cleaner will remove all basis vectors!
    % below after entropy cleaning we reset svdOrder based on mapInput.mapParams.svdOrder
    svdOrder = mapInput.mapParams.svdMaxOrder;
    if (svdOrder > 20)
        string = [mapInput.debug.runLabel, ': Setting svdMaxOrder to a very large number may remove too many light curves to generate meaningful basis vectors'];
        [alerts] = add_alert(alerts, 'warning',string);
        mapInput.debug.display(component, string);
    end
else
    % Use specified number of principle components
    % Can't be more than length of diag(S)
    svdOrder = min(mapInput.mapParams.svdOrder, length(diag(S)));
end


%***
% If we perform entropy cleaning then we need to iteratively perform it with auto-finding svdOrder
% Use same max iterations as for entropy cleaning
if (doEntropyCleaning)
    mapInput.debug.display(component, 'Performing entropy cleaning on basis vectors.');
    % Save the reduced set of targets from above just in case entropy cleanign fails.
    reducedNormFluxSave = reducedNormFlux;
    targetsForSvdSave = mapData.targetsForSvd;

    [U, S, V, mapData.basisVectorEntropy, allRemainingTargetIndices, alerts] = entropy_cleaning ...
                    (U, S, V, mapData.basisVectorEntropy, reducedNormFlux, svdOrder, mapInput);
 
    mapData.alerts = [mapData.alerts, alerts];
 
    nRemovedTargets = nTargetsForSvd - length(allRemainingTargetIndices);
    %mapInput.debug.display(component, [num2str(nRemovedTargets), ' targets removed using entropy cleaning.']);
    reducedNormFlux = reducedNormFlux(:,allRemainingTargetIndices);
    nTargetsForSvd = length(reducedNormFlux(1,:));
 
    % Update targetsForSvd with the new reduced list
    mapData.targetsForSvd = false(mapData.nTargets, 1);
    reducedTargetIndicesInFullArray = reducedTargetIndicesInFullArray(allRemainingTargetIndices);
    mapData.targetsForSvd(reducedTargetIndicesInFullArray) = true;
    
    % Check again if we hit the minumum number of targets
    entropyCleanerRun = true;
    [tooFewTargetsForMapToRun, underMinNumberToTrustSvd] = check_number_of_remaining_targets(mapInput, ...
                        mapData, nTargetsForSvd, entropyCleanerRun);
    if (tooFewTargetsForMapToRun || underMinNumberToTrustSvd)
        % NOTE: pdc_find_failed_entropy_cleaner_tasks relies on the specific text to this warning string so DO NOT CHANGE!
        string = [mapInput.debug.runLabel, ': Entropy cleaning appears to have kept too few targets. Reverting to non-entropy cleaned target set.'];
        mapInput.debug.display(component, string);
        [mapData.alerts] = add_alert(mapData.alerts, 'warning', string);
        [U, S, V] = svd(reducedNormFluxSave);
        doEntropyCleaning = false;
        mapData.targetsForSvd = targetsForSvdSave; 
        mapData.basisVectorEntropy = basis_vector_entropy (V);
    else
        mapInput.debug.display(component, [num2str(nRemovedTargets), ' targets removed using entropy cleaning.']);
    end
end

end % finding basis vectors (versus importing from blob)
%*******************************************************************************
%*******************************************************************************
% KSOC-4967: the spike basis vectors (and denoising) still need to be generated even if we are using basis vectors from a blob file.

%==========================================================================
% Denoise the cotrending basis vectors
% !!!!! TODO: Add MAP configuration parameters: thresholdMethod, thresholdType and denoiseScalingFilterLength
% Denoising now happens after entropy cleaning but before findSvdOrder
% Add logic to perform denoising and spike removal in coarse MAP (and to make residual spike basis vector plots in noBS MAP) 
% whenever spikeIsolationEnabled is true, even if denoiseBasisVectorsEnabled is
% false. Note that although spikeIsolationEnabled is a logical vector with 4 components. The first component is used 
% by both Coarse MAP and noBS map, while the remaining three components are used by Bands 1, 2 and 3.
% But only the scalar component corresponding to which flavor of MAP is being executed is passed into
% map_find_basis_vectors.
if(mapInput.mapParams.denoiseBasisVectorsEnabled||mapInput.mapParams.spikeIsolationEnabled)
    % If denoising is to be done, set noiseEstimationSubband, which is the number of the
    % subband from which to estimate the noise
    % !!!!! Note -- this depends on the band structure and the values of the band boundaries
    % currently there are three bands with the boundaries at [xxx,3].
    % This means that Band 2 includes cadence scales larger than 3.
    % Subbands 1, 2 and 3 correspond to candence scales of 1, 2 and 4,
    % so subband 3 is the the shortest subband within Band 2
    % TODO: make noiseEstimationSubband an input parameter so we don't need to do this case structure
    % I (JCS) would not have coded this up this way!!!
    switch mapInput.debug.runLabel
        case 'Coarse'
            noiseEstimationSubband = 1;
            retrieveUniversalThreshold = false;
            saveUniversalThreshold = false;
       case 'no_BS'
            noiseEstimationSubband = 1;
            retrieveUniversalThreshold = false;
            saveUniversalThreshold = false;
       case 'Band_1'
            % Band 1 (corresponding to cadence scales > 1023) is already smooth, no need to denoise
            % noiseEstimationSubband == 0 causes the denoiser to bypass
            % denoising and pass through the input signal as the denoised signal
            noiseEstimationSubband = 0;
            retrieveUniversalThreshold = false;
            saveUniversalThreshold = false;
       case 'Band_2'
            % Band 2 has no content in subbands 1 & 2
            noiseEstimationSubband = 3;
            retrieveUniversalThreshold = true;
            saveUniversalThreshold = false;
       case 'Band_3'
            noiseEstimationSubband = 1;
            retrieveUniversalThreshold = false;
            saveUniversalThreshold = true;
       otherwise
            error ('Unknown MAP run label');
    end
end

% Denoise CBVs if denoiseBasisVectorsEnabled, or if
% spikeIsolationEnabled
% Do not denoise Band 1 CBVs
if((mapInput.mapParams.denoiseBasisVectorsEnabled||mapInput.mapParams.spikeIsolationEnabled)&&noiseEstimationSubband>0)
    % Trim basis vectors to save time and memory
    % Denoising is slow and so the maximum number of basis vectors is 16 with denoising turned on.
    % Catch case if U is smaller than 16
    % TODO: 16 is a parameter and should not be hard-wired here
    nDenoiseBasisVectors = min(16,size(U,2));
    basisVectors = U(:,1:nDenoiseBasisVectors);

    tDenoiseStart=tic;
    string = 'Denoising cotrending basis vectors ...';
    mapInput.debug.display(component, string);
    thresholdMethod = 'universal';
    thresholdType = 'hard';
    denoiseScalingFilterLength = 12;

    % Last two switches choose option to save and retrieve universal
    % threshold using highest band
    waveletDenoiseObject = waveletDenoiseClass(thresholdMethod,thresholdType,denoiseScalingFilterLength,basisVectors,...
                                                noiseEstimationSubband,saveUniversalThreshold,retrieveUniversalThreshold );

    % Save the waveletDenoiseObject
    intelligent_save([mapInput.debug.runLabel,'_waveletDenoiseObject'],'waveletDenoiseObject');
    tElapsed = toc(tDenoiseStart);
    string = ['Finished denoising cotrending basis vectors in time , ', num2str(tElapsed), ' seconds.'];
    mapInput.debug.display(component, string);
    
    % Replace the basis vectors with the denoised basis vectors,
    % *except* for the case denoiseBasisVectorsEnabled==false and
    % spikeIsolationEnabled==true (i.e. processing noBS or coarse MAP).
    % In this case denoisedBasisVectors will be used to
    % form and inspect the spike basis vectors, but we pass the undenoised
    % basis vectors out of MAP, consistent with the
    % denoiseBasisVectorsEnabled==false setting.
    denoisedBasisVectors = waveletDenoiseObject.denoisedSignalArray;
    basisVectors = denoisedBasisVectors;
    if(~mapInput.mapParams.denoiseBasisVectorsEnabled)
        basisVectors = U(:,1:size(U,2));
    end
else
    basisVectors = U(:,1:size(U,2));
end

if (~mapInput.mapParams.useBasisVectorsFromBlob && ~mapInput.mapParams.useBasisVectorsAndPriorsFromBlob && ...
        ~mapInput.mapParams.useBasisVectorsAndPriorsFromPixels)
    % Only do this is not reading in Basis Vectors from a blob or pixels.

    % If all basis vectors were zero then MAP cannot be performed
    if(sum(any(basisVectors))==0)
        success = false;
        string = 'All found basis vectors are identically zero, MAP must fail!';
        mapInput.debug.display(component, string);
        return;
    end
    
    %*******************************************************************************
    % Auto-find svdOrder, which is the number of significant basis vectors
    if (mapInput.mapParams.svdOrder == 0)
        [svdOrder, logProb, SNR] = find_svd_order (mapData, basisVectors, diag(S), ...
            mapInput.mapParams.svdSnrCutoff, mapData.nCadences);
        % If processing band 3, override svdOrder with the number of
        % basis vectors computed by Tom Minka's Laplace PCA algorithm
        switch mapInput.debug.runLabel
            case 'Band_3'
                [~, svdOrder] = max(logProb);
            otherwise
        end
    else
        svdOrder = mapInput.mapParams.svdOrder;
    end
    
    % Truncate the number of basis vectors to svdOrder
    svdOrder = min([svdOrder mapInput.mapParams.svdMaxOrder length(diag(S))]);
    if(mapInput.mapParams.denoiseBasisVectorsEnabled)
        mapInput.debug.display(component, [num2str(svdOrder), ' significant denoised Basis Vectors found.']);
    else
        mapInput.debug.display(component, [num2str(svdOrder), ' significant non-denoised Basis Vectors found.']);
    end
    
    % Only keep singular vectors, S and entropy for nSingularVectors
    nSingularVectors = min(nSingularVectors, length(mapData.basisVectorEntropy));
    mapData.basisVectorEntropy = mapData.basisVectorEntropy(1:nSingularVectors);
    
    % Note: Before denoising was implemented, 16 basis vectors, taken from from mapData.uMatrix were
    % delivered to NExScI 
    % !!!!! TODO: 
    % If we activate denoising, we should
    % (1) Ask Sean Mccauliff to deliver the denoised basis vectors up to mapData.nBasisVectors
    %     from mapData.basisVectors and the original basis vectors from mapData.uMatrix
    % (2) Add a note to the user community to document what is being delivered
    mapData.uMatrix = U(:,1:nSingularVectors);
    mapData.vMatrix = V(:,1:nSingularVectors);
    mapData.diagS = diag(S);
    mapData.diagS = mapData.diagS(1:nSingularVectors);
    
    % Truncate the number of basis vectors to svdOrder
    nBasisVectors = svdOrder;
    
    % Package the basisVectors into the mapData struct
    mapData.basisVectors  = basisVectors(:,1:nBasisVectors);
    mapData.nBasisVectors = nBasisVectors;
end

clear basisVectors;
clear nBasisVectors;

%*******************************************************************************
% Isolate spike basisVectors, if spikeIsolationEnabled. Spike isolation is
% performed in coarse MAP and the spikes are removed from the lightcurves after the coarse MAP correction is added back in.
% In the subsequent pass through noBS MAP, if spikeIsolationEnabled, it
% will do spike isolation again and show the residual spike basis vectors as a diagnostic but the spike removal only occurs once in the Blue Box.

if (mapInput.mapParams.spikeIsolationEnabled)
    

    if (false && ~doEntropyCleaning)
        string = 'Basis vector spike isolation not performed! Can only occur if entropy cleaning occured';
        mapInput.debug.display(component, string);
        [mapData.alerts] = add_alert(mapData.alerts, 'warning', string);
    else
        % We are good to go!

        mapInput.debug.display(component, 'Isolating Spike Basis Vectors...');
        
        % Identify cadences associated with Earth Points since they should not be included in the spikes
        earthPointCadences = find(mapInput.cadenceTimes.dataAnomalyFlags.earthPointIndicators);
        % There are just a couple cadences past the earth point that will be potentially flagged
        dangerRegion = 10; % in cadences
        for iCadence = 1 : length(earthPointCadences)
            earthPointCadences = [earthPointCadences' [earthPointCadences(iCadence):earthPointCadences(iCadence) + dangerRegion]]';
        end
        % Remove duplicates and sort
        earthPointCadences = unique(earthPointCadences);
        earthPointCadences = sort(earthPointCadences);
        
        % Spike Isolation -- uses the denoised basis vectors found
        % in coarse MAP or no_BS MAP, even if denoiseBasisVectorsEnabled is false.
        
        if (mapInput.mapParams.useBasisVectorsFromBlob || mapInput.mapParams.useBasisVectorsAndPriorsFromBlob || ...
                mapInput.mapParams.useBasisVectorsAndPriorsFromPixels)
            % basisVectors are loaded from blob. No need to auto-find svdOrder
            basisVectors = denoisedBasisVectors;
            nBasisVectors = mapData.nBasisVectors;
            basisVectors = basisVectors(:,1:mapData.nBasisVectors);
        elseif(~mapInput.mapParams.denoiseBasisVectorsEnabled)
            
            % Use denoised basis vectors
            basisVectors = denoisedBasisVectors;
            
            % Auto-find svdOrder, which is the number of significant denoised basis vectors
            if (mapInput.mapParams.svdOrder == 0)
                [svdOrder, logProb, SNR] = find_svd_order (mapData, basisVectors, diag(S), ...
                    mapInput.mapParams.svdSnrCutoff, mapData.nCadences);
                % If processing band 3, override svdOrder with the number of
                % basis vectors computed by Tom Minka's Laplace PCA algorithm
                switch mapInput.debug.runLabel
                    case 'Band_3'
                        [~, svdOrder] = max(logProb);
                    otherwise
                end
            else
                svdOrder = mapInput.mapParams.svdOrder;
            end
            
            % Truncate the number of basis vectors to svdOrder
            svdOrder = min([svdOrder mapInput.mapParams.svdMaxOrder length(diag(S))]);
            disp([num2str(svdOrder), ' significant denoised Basis Vectors were found: using these for spike isolation.'])
            nBasisVectors = svdOrder;
            basisVectors = basisVectors(:,1:nBasisVectors);

        else
            % basisVectors are denoised. No need to auto-find svdOrder
            basisVectors = mapData.basisVectors;
            nBasisVectors = size(basisVectors,2);
            
        end % prepare denoised basis vectors for spike isolation
              
       % Only find spikes for each basis vector separately
       spikeBasisVectors = zeros(size(basisVectors));
       for iBasisVector = 1 : nBasisVectors
        
            % High pass basis vector
            filteredBasisVector = basisVectors(:,iBasisVector) - medfilt1_soc(basisVectors(:,iBasisVector),mapInput.mapParams.spikeBasisVectorWindow);
        
            % Identify the spikes in the basis Vectors
            % An easy way to identify spikes is to take the second derivative (acceleration)
            % Then find the average second derivative for all the basis vectors
            basisVectorMean2nd = diff(diff(filteredBasisVector));
            
            % Spikes above a threshold of 100 sigma will be flagged
            sigma = mad(basisVectorMean2nd,1) * 1.4826;
            threshold = 100 * sigma;
            aboveThreshold = abs(basisVectorMean2nd) > threshold;
            
            % Add all cadences 1 away from identified cadences because of the uncertanty introduced by taking the second deriviative via the diff function
            cadencesAboveSpikeThreshold = find(aboveThreshold);
            aboveThreshold(cadencesAboveSpikeThreshold(cadencesAboveSpikeThreshold ~= 1) - 1) = true;
            aboveThreshold(cadencesAboveSpikeThreshold(cadencesAboveSpikeThreshold ~= length(aboveThreshold)) + 1) = true;
            
            % Add 1 for the diff(diff()) offset
            cadencesAboveSpikeThreshold = find(aboveThreshold) + 1;
            
            % Remove cadences in Earth-Point Recovery regions
            earthPointRelated = ismember(cadencesAboveSpikeThreshold , earthPointCadences);
            spikeCadences = cadencesAboveSpikeThreshold(~earthPointRelated);
            
            % Isolate basis vectors just on the spike cadences
            spikeBasisVectors(spikeCadences,iBasisVector) = filteredBasisVector(spikeCadences);
        
            % We do not want to remove the spike basis vectors from the normal basis vectors since doing so creates an artifact in the normal basis vectors.
        end
        
        % Add spikeBasisVectors and nSpikeBasisVectors to mapData struct
        mapData.spikeBasisVectors = spikeBasisVectors;
        mapData.nSpikeBasisVectors = length(spikeBasisVectors(1,:));
    end

end

if (~mapInput.mapParams.useBasisVectorsFromBlob && ~mapInput.mapParams.useBasisVectorsAndPriorsFromBlob && ...
        ~mapInput.mapParams.useBasisVectorsAndPriorsFromPixels)
        %==========================================================================
        % Plot singular values
        duration = toc;
        mapInput.debug.display(component, ['CBVs computed: ' num2str(duration) ...
            ' seconds = '  num2str(duration/60) ' minutes']);

    if (mapInput.debug.query_do_plot(component));
        % Plot singular values
        singularValueFig = mapInput.debug.create_figure;
        loglog(mapData.diagS(1:min(64,length(mapData.diagS))), '-*b');
        title('Singular Values for reduced Normalized Flux matrix');
        mapInput.debug.save_figure(singularValueFig , component, 'singular_values');
 
        if (mapInput.mapParams.svdOrder == 0)
            % Plot found log-probability for each SVD dimensionality
            logProbFig = mapInput.debug.create_figure;
            semilogx(logProb(1:min(64, length(logProb))), '-*b');
            [~,order] = max(logProb);
            title(['Log-Probability of each svdOrder Dimensionality using Bayesian Model Selection; Maximum = ', ...
                    num2str(order)]);
            mapInput.debug.save_figure(logProbFig , component, 'log_prob_for_SVD_order');
            % Plot the SNR for the basis Vectors
            SNRFig = mapInput.debug.create_figure;
            semilogx(SNR, '-*b')
            hold on;
            semilogx(repmat(mapInput.mapParams.svdSnrCutoff, [length(SNR),1]), '-r','LineWidth', 2)
            title('SNR for singular Vectors');
            legend('SNR for each Singular Vector [Decibels]', ['Cutoff = ', num2str(mapInput.mapParams.svdSnrCutoff)]);
            mapInput.debug.save_figure(SNRFig , component, 'SNR_for_SVD_order');
        end
    end
end




%*******************************************************************************
% Find reduced set of targets used for finding the prior PDFs
% Note these are different than those used to find the basis vectors so redo the selection process
% from the full correlation matrix.
% The selection method is the same however.
% TODO: Create subfunction for repeated work here.


if (mapInput.mapParams.useOnlyQuietStarsForPriorPdf)
    % An additional optional cut is to remove the noisy targets from this list
    nonReducedTargetsForPriorPdf = (mapData.variability < mapInput.mapParams.variabilityCutoff);
    nonReducedTargetsForPriorPdf(~mapInput.targetsForBasisVectorsAndPriors) = false; 
else
    % Only select targets specified with targetsForBasisVectorsAndPriors
    nonReducedTargetsForPriorPdf = mapInput.targetsForBasisVectorsAndPriors;
end

% Remove custom targets
nonReducedTargetsForPriorPdf([mapInput.targetDataStruct.excludeBasedOnLabels]) = false;

nTargetsForPriorPdf = length(find(nonReducedTargetsForPriorPdf));

% See note 1.1 above...

% Median correlation coefficient per star
% We need to find the median absolute correlation a second time since the set of targets to use is
% potentially different.
medianReducedAbsCorrPerStar = median(abs(correlationMatrix(:,nonReducedTargetsForPriorPdf)));

% Sort
[~, sortedReducedCorrIndices] = sort(medianReducedAbsCorrPerStar);

% Create reduced arrays ordered by sorted correlation
% These are the targets used in SVD to find the basis vectors
midIndex = round(nTargetsForPriorPdf*(1-mapInput.mapParams.fractionOfStarsToUseForPriorPdf));
if (midIndex == 0)
    % This means all targets
    midIndex = 1;
end
reducedTargetIndicesForPriorPdf = sortedReducedCorrIndices(midIndex:end);

% Get the targets in the full array that are used for Priors
allTargetIndices = 1:mapData.nTargets;
reducedTargetIndicesInFullArray = allTargetIndices(nonReducedTargetsForPriorPdf);
reducedTargetIndicesInFullArray = reducedTargetIndicesInFullArray(reducedTargetIndicesForPriorPdf);
mapData.targetsForGeneratingPriors = false(mapData.nTargets,1);
mapData.targetsForGeneratingPriors(reducedTargetIndicesInFullArray) = true;

% Remove custom targets
mapData.targetsForGeneratingPriors([mapInput.targetDataStruct.excludeBasedOnLabels]) = false;

% Remove targets without valid RA, Dec and kepler Mag
mapData.targetsForGeneratingPriors(mapData.targetsWhereKicDataNotFound) = false;

% Remove targets without valid Pixel Prior data
if (mapInput.mapParams.useBasisVectorsAndPriorsFromPixels || mapInput.mapParams.usePriorsFromPixels)
    mapData.targetsForGeneratingPriors(mapData.targetsWherePixelDataNotFound) = false;
end


%TODO: Write unit test to confirm proper selection of targets


%*******************************************************************************
%% Option to plot the Basis Vectors
if (mapInput.debug.query_do_plot(component))
    % Plot Basis Vectors that are in the mapData struct
    basisVectorsFig = mapInput.debug.create_figure;
    % plot basis vectors in reverse order so that strongest on top (and not covered up by the noise of the
    % lower ones)
    if (svdOrder == 0)
        nPlottedSingularVectors = min(mapInput.mapParams.svdMaxOrder, length(mapData.uMatrix(1,:)));
        plot(mapData.uMatrix(:,nPlottedSingularVectors:-1:1), '-');
        title(['MAP FAILED! These are just the first ', num2str(nPlottedSingularVectors), ' singular vectors.']);
    else
        plot(mapData.basisVectors(:,end:-1:1), '-');
        title([num2str(length(mapData.basisVectors(1,:))), ' Basis Vectors']);
    end
    mapInput.debug.save_figure(basisVectorsFig , component, 'basis_vectors');

    if (mapInput.mapParams.spikeIsolationEnabled && ~isempty(mapData.spikeBasisVectors))
        % Plot Spike Basis Vectors
        spikeBasisVectorsFig = mapInput.debug.create_figure;
        % plot basis vectors in reverse order so that strongest on top (and not covered up by the noise of the
        % lower ones)
        plot(mapData.spikeBasisVectors(:,end:-1:1), '-');
        title([num2str(length(mapData.spikeBasisVectors(1,:))), ' Spike Basis Vectors']);
        mapInput.debug.save_figure(spikeBasisVectorsFig , component, 'basis_vectors_spikes');
    end
end

%*******************************************************************************
% If no basis vectors were found then MAP cannot be performed
if (mapData.nBasisVectors == 0)
    success = false;
    return;
end

success = true;
mapInput.debug.display(component, 'Finshed finding Basis Vectors');

return

%*******************************************************************************
%*******************************************************************************
%*******************************************************************************
%% Internal Functions

%*******************************************************************************
%% function [ditheredNormFlux] = dither_flux (ditherMagnitude, randStream, normFlux) 
% After normalizing the flux, each curve passes almost through zero at the midpoint. So, when doing
% SVD the principle components all pass through zero! For the few targets that do not pass through
% zero there is no principle component signal strength at zero to remove the trend. The simple
% solution is to dither all targets by a small amount so that they don't all pass through zero.

function [ditheredNormFlux] = dither_flux (ditherMagnitude, randStream, normFlux) 

% scale ditherMagnitude by std of all flux
scaleDither = max(max(normFlux)) - min(min(normFlux));
scaledDitherMagnitude = ditherMagnitude*scaleDither;

% Uniform dither distribution in interval [-1,1]
ditherAmount = -1 + 2*rand(randStream, 1, length(normFlux(1,:)));

ditheredNormFlux = normFlux + ...
                    repmat((ditherAmount.*scaledDitherMagnitude),[length(normFlux(:,1)),1]);

return

%*******************************************************************************
%% function [svdOrder, logProb, SNR] = find_svd_order (mapData, diagS)
%
% This function find s the number of principle components to use using two different methods. Using minimum of
% the two.
%
%***
% 1)  Via the diagonal of the singular value matrix. Algorithm based on
%
%   "Automatic choice of dimensionality for PCA" by Thomas P. Minka
%   M.I.T. Media Laboratory Perceptial Computing Section Technical Report No. 514
%
% Code taken from http://research.microsoft.com/en-us/um/people/minka/papers/pca/
%   This code is messy with lots of commented out lines and really bad variable names. There's also virtually
%   no comments. Clearly written by a "head in the clouds" acedemic! I'm cleaning this up and removing
%   commented out lines. No clue if it performs correctly, it's impossible to decifer.
%
%***
% 2) looking at the ratio of the noise floor to signal via:
%
% Inputs:
%   mapData -- Needed for nCadences and nTargets
%   singVec       -- [double matrix(nCadences x nTargets)] The singular vectors (NOT U!)
%   diagS   -- The singular values from SVD
%
% Outputs:
%   svdOrder -- [int] The number of basis vectors to use
%   logProb  -- [double array] log-probability of each dimensionality, starting at 1.  
%                              svdOrder is the argmax of logProb.
%   SNR      -- [double array] SNR for each singular vector
%   
%*******************************************************************************

function [svdOrder, logProb, SNR] = find_svd_order (mapData, singVec, diagS, svdSnrCutoff, nCadences)

% We want the number of targets used to generate singular vectors, not total number of targets
nTargets = length(diagS);

%***
% Using Bayesian model Selection Via Minka algorithm
[laplaceSvdOrder, logProb] = laplace_pca(diagS, nCadences, nTargets);

%***
% Looking at Signal to Noise Ratio
rmsNoise = sqrt(nansum(diff(singVec).^2) ./ nCadences);

% nansum(signVec.^2) := 1.0 since vectors are normalized
% but keep formula in here for clearity (it's fast)
rmsSignal =  sqrt(nansum(singVec.^2) ./ nCadences);

SNR = 10 * log10((rmsSignal.^2) ./ (rmsNoise.^2));

% Find the last vector before the threshold is hit
SNRBelowThreshold = find(SNR < svdSnrCutoff, 1, 'first');
if (isempty(SNRBelowThreshold))
    % All are above threshold
    SNRSvdOrder = length(diagS);
else
    SNRSvdOrder = SNRBelowThreshold - 1;
end
    
svdOrder = min(laplaceSvdOrder, SNRSvdOrder);

return

%*******************************************************************************
% Function [svdOrder, logProb] = laplace_pca (diagS, nCadences, nTargets)
%
%***
% Tom's original header:
%function [svdOrder,logProb] = laplace_pca(data, diagS, nCadences, nTargets)
% LAPLACE_PCA   Estimate latent dimensionality by Laplace approximation.
%
% svdOrder = LAPLACE_PCA([],diagS,nCadences,nTargets) returns an estimate of the latent dimensionality
% of a dataset with eigenvalues diagS, original dimensionality nCadences, and size nTargets.
% LAPLACE_PCA(data) computes (diagS,nCadences,nTargets) from the matrix data 
% (data points are rows)
% [svdOrder,logProb] = LAPLACE_PCA(...) also returns the log-probability of each 
% dimensionality, starting at 1.  svdOrder is the argmax of logProb.
%
%%
% Written by Tom Minka, copied below verbatum, including his commented out lines.
%*******************************************************************************
function [svdOrder, logProb] = laplace_pca (diagS, nCadences, nTargets)

%if ~isempty(data)
%  [nTargets,nCadences] = size(data);
%  m = mean(data);
%  data0 = data - repmat(m, nTargets, 1);
%  diagS = svd(data0,0).^2;
%end
diagS = diagS(:);
% break off the eigenvalues which are identically zero
i = find(diagS < eps);
diagS(i) = [];

logediff = zeros(1,length(diagS));
for i = 1:(length(diagS)-1)
  j = (i+1):length(diagS);
  logediff(i) = sum(log(diagS(i) - diagS(j))) + (nCadences-length(diagS))*log(diagS(i));
end
cumsum_logediff = cumsum(logediff);

invDiagS = 1./diagS;
invDiagSdiff = repmat(invDiagS,1,length(diagS)) - repmat(invDiagS',length(diagS),1);
invDiagSdiff(invDiagSdiff <= 0) = 1;
invDiagSdiff = log(invDiagSdiff);
cumsum_invDiagSdiff = cumsum(invDiagSdiff,1);
% Sum the rows
row_invDiagSdiff = sum(cumsum_invDiagSdiff,2);

loge = log(diagS);
cumsum_loge = cumsum(loge);

cumsum_e = cumsum(diagS);

dn = length(diagS);
kmax = length(diagS)-1;
ks = 1:kmax;
% the normalizing constant for the prior (from James)
% sum(z(1:k)) is -log(logProb(U))
z = log(2) + (nCadences-ks+1)/2*log(pi) - gammaln((nCadences-ks+1)/2);
cumsum_z = cumsum(z);
for i = 1:length(ks)
  k = ks(i);
  v = (cumsum_e(end) - cumsum_e(k))/(nCadences-k);
  logProb(i) = -cumsum_loge(k) - (nCadences-k)*log(v);
  logProb(i) = logProb(i)*nTargets/2 - cumsum_z(k) - k/2*log(nTargets);
  % compute h = logdet(A_Z)
  h = row_invDiagSdiff(k) + cumsum_logediff(k);
  % lambda_hat(i)=1/v for i>k
  h = h + (nCadences-k)*sum(log(1/v - invDiagS(1:k)));
  m = nCadences*k-k*(k+1)/2;
  h = h + m*log(nTargets);
  logProb(i) = logProb(i) + (m+k)/2*log(2*pi) - h/2;
end
[pmax,i] = max(logProb);
svdOrder = ks(i);

%figure;
%plot(logProb, '-*b');
%title('Log-Probability of each svdOrder Dimensionality using Bayesian Model Selection');

return
  

%*******************************************************************************
% function [H] = Basis_vectors_entropy (vMatrix)
% 
% Finds the relative entropy between the Basis Vectors and a Gaussian using the method presented and developed
% by Jeff Van Cleve in the talk Kepler_DoC_CBV_entropy_and_cleaning_20111013.ppt
%
% Input:
%   vMatrix     -- [double matrix(nTargets x nTargets)] The V-Matrix from SVD applied to the reduced basis set
%
% Output:
%   H           -- [double array(nBasisVectors)] Entropy difference from Gaussian for each basis vector
%

function [H] = basis_vector_entropy (vMatrix)

nBins = 256;
nSingVals = size(vMatrix,1);
HGauss0 = 0.5 + 0.5*log(2*pi);

H = zeros(nSingVals,1);


% I know not how to vectorize two parts of this so might as well do one big for loop for clearity
for iBasisVector = 1 : nSingVals
    % First find a histrogram derived PDF of the V-Matrix from SVD
    % We want a different x-range for each basis vector. I know of no way to vectorize this with hist.
    [pdf, x] = hist(abs(vMatrix(:,iBasisVector)), nBins);
    dx = x(2) - x(1);
    normFactor = sum(pdf)*dx;
    pdf = pdf/normFactor;

    % Calculate the Gaussian entropy
    pdfMean = sum(x.*pdf)*dx;
    sigma = sqrt( sum(((x-pdfMean).^2).*pdf).*dx);
    HGauss = HGauss0 + log(sigma);

    % Calculate vMatrix entropy
    % Only want to take log for when pdf is nonzero. But nonzero parts are different for each basis vector so no
    % easy way to parallelize this part either
    vBasisVectorNonZero = find(pdf > 0);
    HVMatrix = -1*sum(pdf(vBasisVectorNonZero).*log(pdf(vBasisVectorNonZero))).*dx;

    % Returned entropy is difference bewteen V-Matrix entropy and Gaussian entropy of similar width (sigma)
    H(iBasisVector) = HVMatrix - HGauss;
end

return

%*******************************************************************************
% function [U, S, V, entropy, removedTargetindices, alerts] = entropy_cleaning ...
%                           (U, S, V, entropy, normFlux, svdOrder, mapinput)
%
% Use the entropy metric derived from the V-Matrix to clean the flux set used to generate the basis vectors.
% The function assumes svd has already been called once and U and V are already generated for the un-clean
% basis vectors
%

function [U, S, V, entropy, allRemainingTargetIndices, alerts] = entropy_cleaning ...
                                (U, S, V, entropy, normFlux, svdOrder, mapInput)

component = 'basisVectors';
alerts = [];

iIteration = 1;
reducedNormFlux = normFlux;
% This is to keep track of all targets removed after all iterations
allRemainingTargetIndices = 1:length(normFlux(1,:));

% Do entropy cleaning but only if there is a basis vector with entropy below the threshold
while (any(entropy(1:svdOrder) < mapInput.mapParams.entropyCleaningCutoff))

    if (iIteration > mapInput.mapParams.entropyMaxIterations)
        % NOTE: pdc_find_failed_entropy_cleaner_tasks relies on the specific text to this warning string so DO NOT CHANGE!
        % If this warning the entropy cleaned basis vectors are still used 
        string = [mapInput.debug.runLabel, ': Max iterations reached while entropy cleaning basis vectors.'];
        [alerts] = add_alert(alerts, 'warning',string);
        mapInput.debug.display(component, string);
        break;
    end

    % Remove the offending targets
    % First find the basis vectors with bad entropy
    badBasisVectors = entropy(1:svdOrder) < mapInput.mapParams.entropyCleaningCutoff;

    % This only keeps track of targets removed for this basis vector
    removedTargetIndices = [];
    for iBasis = 1: svdOrder
        if (~badBasisVectors(iBasis))
        continue;
        end
        madPower =  mad(abs(V(:,iBasis)));
        % Remove at least single largest contributor but also others than are above entropic threshold
        [~, maxTargetIndex] = max(abs(V(:,iBasis)));
        removedTargetIndices = [removedTargetIndices; maxTargetIndex];
        removedTargetIndices = [removedTargetIndices; find(abs(V(:,iBasis)) > ...
                                            mapInput.mapParams.entropyMadFactor*madPower)];
    end
    %  Remove the targets from the list and redo SVD
    % removedTargetIndices may have repeats but that's OK becuase we use setdiff
    remainingTargets = setdiff([1:length(reducedNormFlux(1,:))],removedTargetIndices);
    allRemainingTargetIndices = allRemainingTargetIndices(remainingTargets);
    reducedNormFlux = normFlux(:,allRemainingTargetIndices);

    if (length(remainingTargets) < svdOrder || length(remainingTargets) < 2)
        % 2 being the minumum numbe of targets for SVD to not crash
        % Warning in this situation issued in check_number_of_remaining_targets
        break;
    end

    [U, S, V] = svd(reducedNormFlux);

    % Find new entropy
    entropy = basis_vector_entropy (V);

    iIteration = iIteration + 1;
        
end

return

%*******************************************************************************
% function [tooFewTargetRemain, alerts] = check_number_of_remaining_targets (nTargetsForSvd)
%
% There are two places in the code where we need to check if too few targets remain for SVD. Being duplicate
% code, the proper method is to create a subfunction.
%

function [tooFewTargetsForMapToRun, underMinNumberToTrustSvd] = check_number_of_remaining_targets ...
                                    (mapInput, mapData, nTargetsForSvd, entropyCleanerRun)

component = 'basisVectors';

tooFewTargetsForMapToRun = false;
underMinNumberToTrustSvd = false;

% Minimum number of targets required for SVD to run without crashing. Results may be meaningless, but it
% won't crash
minNumberOfTargets = 2;

% Minimum number of selected light curve for SVD before results should no longer be trusted
% This number is a bit arbitrary but if less than something like 100 targets are used then even though MAP
% will run, the statistics are too poor to trust the results. Note this is related to
% mapConfigurationStruct.minFractionOfTargetsForSvd but here it's an absolute value. If below this number MAP
% will not crash but just an alert warning is issued. In all likelihood this situation is occuring during a
% test run with few input targets so we don't want to crash but still warn the user not to trust MAP.
minNumberOfTargetsToTrustSvd = 100;

% KSOC-4756
% Do not include excluded targets in my statistics
excludeBasedOnLabels = [mapInput.targetDataStruct.excludeBasedOnLabels];
nTargetsNotIncludingExcludedTargets = mapData.nTargets - sum(excludeBasedOnLabels);

% If length(reducedNormFlux(1,:)) <  minNumberOfTargets then too few light curves left to properly perform
% SVD
if (nTargetsForSvd < minNumberOfTargets )
    mapData.basisVectors = [];
    mapData.nBasisVectors = 0;
    mapData.targetsForSvd = [];
    mapData.targetsForGeneratingPriors = [];
    string = [mapInput.debug.runLabel, ': MAP: Too few targets were found to generate basis vectors! Only ',...
        num2str(nTargetsForSvd), ' targets we found. MAP cannot be performed'];
    [mapData.alerts] = add_alert(mapData.alerts, 'warning', string);
    mapInput.debug.display(component, string);
    tooFewTargetsForMapToRun = true;
    underMinNumberToTrustSvd = true;
elseif (~entropyCleanerRun && nTargetsForSvd < nTargetsNotIncludingExcludedTargets*mapInput.mapParams.minFractionOfTargetsForSvd)
    % We kept too few targets, somethign must be wrong, crash and burn
    % This is so that in pipeline runs a problem with too few targets will result in a failed task
    % If this occurs during entropy cleaning then do not crash since non entropy cleaned basis vectors are
    % used instead.
    error('Too few targets were available to properly generate Basis Vectors. This is bad. MAP will now die'); 
elseif (nTargetsForSvd < minNumberOfTargetsToTrustSvd )
    % This is just a warning if the above is not aught but still too few targets were found in absolute number.
    string = [mapInput.debug.runLabel, ': MAP: Too few targets were found to properly generate basis vectors! Only ',...
        num2str(nTargetsForSvd), ' targets were found. DO NOT TRUST MAP RESULTS!'];
    [mapData.alerts] = add_alert(mapData.alerts, 'warning', string);
    mapInput.debug.display(component, string);
    underMinNumberToTrustSvd = true;
end

return
