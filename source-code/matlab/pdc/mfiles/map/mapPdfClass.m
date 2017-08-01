%% classdef mapPdfClass
%
% Constructs the prior, conditional and posterior PDFs for MAP.
%
% Maximizes the posterior PDF.
%
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

classdef mapPdfClass < handle & classIoTools

properties (Constant, GetAccess = 'public')
    USEONLYTUSFORPRIOR = false; % For testing purposes. The Prior is constructed purely from the coeffs from the TUS
    COMPAREPRIORTOCONDITIONALREWEIGHTING = false; % Compare the noise of the prior to the conditional and adjust prior weight accordingly
    DOSEQUENTIALFITTING = true;
end
properties (Constant, GetAccess = 'private')
    INITIALRANGEEXPANDFACTOR = 2.0; % Look at a range twice as large as the basis vector
            % coefficients would suggest (just in case the maximum is past the end of the range
    BRACKETRANGEEXPANDFACTOR = 1.5; % When bracketing the maximum if the maximum was not found within the
            % initial range then expand the range by this factor and re-try 
    MINIMUMPRIORWEIGHT = 1e-3 % Minimum weight for goodness metric iterator and when turnign off MAP for k2
    MAXIMUMPRIORWEIGHT = 1e7 % Maximum weight for goodness metric iterator
end

properties(GetAccess = 'public', SetAccess = 'public')
    targetsMapAppliedTo; % Targets where the Prior was nonzero and a proper MAP was performed (subset of targetsMapWasAttempted)
    targetsMapWasAttempted; % Targets where a prior was formed and MAP was attempted.
end
properties(GetAccess = 'public', SetAccess = 'private')
    targetInfo;
    defaultCentroidPriorSigmas; % The default gaussian sigma values for Jeff K's centroid prior method, used if better sigma not available
end

methods (Access = 'public')

    %******************************************************************************
    % Constructor
    % 
    %
    % Two input options:
    % 1) (mapData, mapInput)    -- normal usage
    %
    % 2) No inputs              --  for generating a blank opbject when loading in saved data (see construct_from_struct below)

    function obj = mapPdfClass(varargin)

        if (length(varargin) == 0)
                % a "naked" object is desired (used for loading in a saved struct)
                return;
        elseif(length(varargin) ~= 2)
            error('mapPdfClass can only be called with zero or two arguments (mapData, mapInput)');
        else
            mapData  = varargin{1};
            mapInput = varargin{2};
        end

        % This stores the maximizer fit information for the posterior, prior and conditional PDFs
        pdfFitStruct = struct ('basisVectorCoeff', zeros(mapData.nBasisVectors,1), ... % Basis Vector maximum value
                               'pdfMaxValue', zeros(mapData.nBasisVectors,1)); % Value of the PDF at basisVectorCoeff

        % This is used for Jeff K's centroid motion prior information
        centroidPriorStruct = struct(...
            'centroidPriorUsed', false, ... % Logical if centroid prior is to be used
            'coeffs', [],...    % Centroid value for prior PDF
            'coeffSigmas', []); % Gaussian width for prior PDF

        priorPdfInfo = struct( ...
            'targetsForPrior', false(mapData.nTargets,1), ...
            'distance', [], ...
            'targetWeight', [], ...
            'centroidPrior', centroidPriorStruct);

        conditionalPdfInfo = struct(...
            'stdFlux', 0.0);

        posteriorPdfInfo = struct(...
            'priorGoodness', 0.0, ...
            'priorWeight', 0.0,  ...
            'basisVectorInitialRanges', [], ...
            'goodnessWeight', 0.0, ...
            'theta0', zeros(mapData.nBasisVectors,1)); % coefficient values from previous goodness iteration

        fitsStruct = struct (...
            'posterior',   pdfFitStruct, ...
            'prior',       pdfFitStruct, ...
            'goodness',    pdfFitStruct, ...
            'conditional', pdfFitStruct);

        % Remove basis vectors that are no good
        % Such as containing all zeros or nans
        basisVectorsToUse = true(mapData.nBasisVectors,1);
        for iBasisVector = 1 : mapData.nBasisVectors
            if ( all(mapData.basisVectors(:,iBasisVector) == 0) || ...
                    any(isnan(mapData.basisVectors(:,iBasisVector))))
                basisVectorsToUse(iBasisVector) = false;
            end
        end
        
        obj.targetInfo = repmat( struct( ...
                'basisVectorsToUse', basisVectorsToUse, ... % For now use all basis vectors
                'priorPdfInfo', priorPdfInfo , ...
                'conditionalPdfInfo', conditionalPdfInfo , ...
                'posteriorPdfInfo', posteriorPdfInfo , ...
                'fits', fitsStruct), [mapData.nTargets,1]);


        % Find targets to run maximizer on
        % As the maximizer is run any targets that cannot be maximized will be removed from this list.
        % Also, any targets where the prior weight is zero will be added.
        if (mapInput.debug.applyMapToAllTargets)
            obj.targetsMapWasAttempted = true(mapData.nTargets,1);
        else
            % Only run MAP on targets in reduced set to analyze (increases speed)
            obj.targetsMapWasAttempted = false(mapData.nTargets,1);
            obj.targetsMapWasAttempted(mapInput.debug.targetsToAnalyze) = true;
        end

        % Remove targets where RA, DEC and KepMag wehere not found 
        obj.targetsMapWasAttempted(mapData.targetsWhereKicDataNotFound) = false;

        % Remove targets without valid Pixel Prior data
        if (mapInput.mapParams.useBasisVectorsAndPriorsFromPixels || mapInput.mapParams.usePriorsFromPixels)
            obj.targetsMapWasAttempted(mapData.targetsWherePixelDataNotFound) = false;
        end

        % Remove targets that are all gapped
        gapMatrix = [mapInput.targetDataStruct.gapIndicators];
        obj.targetsMapWasAttempted(all(gapMatrix)) = false;
        
        % Start with trying MAP on all targets possible. If MAP is not really performed then targetsMapAppliedTo is updated to remove those targets.
        obj.targetsMapAppliedTo = obj.targetsMapWasAttempted;

    end
 
    %*******************************************************************************
    %% function [] = generate_prior_pdf(obj, mapData, mapInput)
    %*******************************************************************************
    % 
    % Using the robust fit coefficients, KIC information (and other parameters) prior PDFs are generated for each target.
    % The pdf function is actually a handle to Matlab's ksdensity function with the robust coefficients.
    % Weighting of the robust coefficients is based on the distance between the Target Under Study (TUS)
    % and each target used to generate the PDF (dictated by mapInput.targetsToUseForPriors).
    %
    % If mapParams.useBasisVectorsAndPriorsFromBlob = true then the prior PDF information is loaded from
    % mapInoput.cbvBlobStruct. If mapParams.usePriorsFromPixels or mapParams.useBasisVectorsAndPriorsFromPixels 
    % then we use the fit coefficients from pixels as an extra dimension to the prior.
    %
    % For testing Jeff K's controid motion / optimum aperture method this function will also optionall load his data for use as the prior
    %
    %*******************************************************************************

    function [] = generate_prior_pdf(obj, mapData, mapInput)
 
        component = 'generatePrior';

        useJeffKPriors = true;

        % Load prior PDFs from blob
        if (mapInput.mapParams.useBasisVectorsAndPriorsFromBlob)
            mapInput.debug.display(component, 'Loading Prior PDF information from Blob...');
            tic;

            if (mapData.nTargets ~= length(mapInput.cbvBlobStruct.priorPdfInfoNoBands.priorPdfInfoArray))
                error('GENERATE_PRIOR_PDF: the cbvBlobStruct is incorrect length, is this for the correct data?');
            end

            for iTarget = 1 : mapData.nTargets
               %if (~obj.targetsMapAppliedTo(iTarget))
               %    continue;
               %end
                obj.targetInfo(iTarget).priorPdfInfo = ...
                    mapInput.cbvBlobStruct.priorPdfInfoNoBands.priorPdfInfoArray(iTarget).priorPdfInfo;
            end
    
            duration = toc;
            mapInput.debug.display(component, ['Prior PDF loaded: ' num2str(duration) ...
                ' seconds = '  num2str(duration/60) ' minutes']);

            return;

        end

        mapInput.debug.display(component, 'Generating Prior PDF...');
        tic;

        %***********
        % multi-vector of ra, dec, keplermag, effTemp, logRadius
        XAll = [[mapData.kic.ra] [mapData.kic.dec] [mapData.kic.keplerMag] [mapData.kic.effTemp] [mapData.kic.logRadius]];
            scaleFactor(1) = mapInput.mapParams.priorRaScalingFactor;
            scaleFactor(2) = mapInput.mapParams.priorDecScalingFactor;
            scaleFactor(3) = mapInput.mapParams.priorKeplerMagnitudeScalingFactor;
            scaleFactor(4) = mapInput.mapParams.priorEffTempScalingFactor;
            scaleFactor(5) = mapInput.mapParams.priorLogRadiusScalingFactor;
            iScale = 5;
        if (mapData.centroid.centroidMotionDataExists)
            % Add in c% NOTE: This is NOT centroid priors! This is using the standard prior but using the mad of the centorid motion as 
            % one of the prior vectors entroid for all targets
            XAll = [ XAll mad([mapData.centroid.motion.row])' mad([mapData.centroid.motion.col])'];
            scaleFactor(iScale+1) = mapInput.mapParams.priorCentroidMotionScalingFactor;
            scaleFactor(iScale+2) = mapInput.mapParams.priorCentroidMotionScalingFactor;
            iScale = iScale+2;
        end
        if (mapInput.mapParams.usePriorsFromPixels || mapInput.mapParams.useBasisVectorsAndPriorsFromPixels)
            % Check that the other prior components are turned off
            if (any(scaleFactor(1:iScale)))
                error('If using picel priors then other prior scaling factors must be 0.');
            end
            % Add in the pixel data
            XAll = [ XAll [mapData.pixelData.priors]];
            scaleFactor(iScale+1 : iScale+1+length(mapData.pixelData.priors(1,:))) = mapInput.mapParams.priorPixelScalingFactor;
            iScale = iScale+length(mapData.pixelData.priors(1,:));
        end
        
        %***
        % Need to scale the three axes so that the distance metric is calibrated to the relative
        % contribution of the three dimensions to the Bayesian Prior.
        
        % Remove outliers to get better range in each axis.
        XScale = (prctile(XAll, 90) - prctile(XAll, 10));
 
        % The 5 vectors have different scaling constants
        % If the scaling factor is zero then turn off that dimension
        turnDimensionOff = false(length(XScale),1);
        for iDim = 1 : length(XScale)

            if (scaleFactor(iDim) ~= 0)
                XScale(iDim) = XScale(iDim) / scaleFactor(iDim);
            else
                XScale(iDim) = 0;
                turnDimensionOff(iDim) = true;
            end
        end

        % Remove the dimensions that are turned off (with scaleFactor = 0)
        XScale = XScale(~turnDimensionOff);
        XAll = XAll(:,~turnDimensionOff);


        %***********
        
        for iTarget = 1 : mapData.nTargets
            if (~obj.targetsMapAppliedTo(iTarget))
                continue;
            end
            % Right now the same targets are used for all TUS's but leaving this parameter in for future
            % upgrades.
            obj.targetInfo(iTarget).priorPdfInfo.targetsForPrior = mapData.targetsForGeneratingPriors;
            % Remove TUS from Prior target list
            obj.targetInfo(iTarget).priorPdfInfo.targetsForPrior(iTarget) = false;

            %***
            % Calculate the distance to each target
        
            % TUS coordinates
            Y = XAll(iTarget,:);
        
            % Coordinates for targets used to generate prior
            X = XAll(obj.targetInfo(iTarget).priorPdfInfo.targetsForPrior,:);
        
            % Use pdist2 to get Scaled Euclidean distance to TUS
            % If using pixel priors then create a different distance for each coefficient dimension seperately
            if (mapInput.mapParams.useBasisVectorsAndPriorsFromPixels)
                obj.targetInfo(iTarget).priorPdfInfo.distance = zeros(length(X(:,1)),mapData.nBasisVectors);
                for iDim = 1 : mapData.nBasisVectors
                    obj.targetInfo(iTarget).priorPdfInfo.distance(:,iDim) = pdist2(X(:,iDim), Y(iDim), 'seuclidean', XScale(iDim));
                end
            else
                obj.targetInfo(iTarget).priorPdfInfo.distance = pdist2(X, Y, 'seuclidean', XScale);
            end
        
            % Weight each target for the pdf relative to its distance to the TUS
            % Weight by inverse square to the distance
            % TODO: priorWeight and distance are only for priorPdfInfo.targetsForPrior and not for mapData.nTargets. This should be changed to conform the PDC
            % coding standards.
            if (mapInput.mapParams.useBasisVectorsAndPriorsFromPixels)
                obj.targetInfo(iTarget).priorPdfInfo.targetWeight = zeros(size(obj.targetInfo(iTarget).priorPdfInfo.distance));
                for iDim = 1 : mapData.nBasisVectors
                    obj.targetInfo(iTarget).priorPdfInfo.targetWeight(:,iDim) = 1 ./ (obj.targetInfo(iTarget).priorPdfInfo.distance(:,iDim) .^ 2);
                end
            else
                obj.targetInfo(iTarget).priorPdfInfo.targetWeight = 1 ./ (obj.targetInfo(iTarget).priorPdfInfo.distance .^ 2);
            end

            if (mapInput.debug.query(component, mapInput.debug.VERBOSEDEBUGLEVEL));
                mapInput.debug.waitbar(iTarget/mapData.nTargets, 'Generating Prior PDF...')
            end
        end

        %******************
        %******************
        % Jeff K centroid / Optimum Aperture priors
        if (mapInput.mapParams.useCentroidPriors)
            % Obtain the optimum aperture information if it is not in the inputsStruct
            if (isfield(mapInput.targetDataStruct(1), 'optimalAperture'))
                % Formulate the apertureStruct from inputsStruct
               %tadApertures = repmat([], [mapData.nTargets,1]);
                for iTarget = 1 : mapData.nTargets
                    tadApertures(iTarget) = mapInput.targetDataStruct(iTarget).optimalAperture;
                end
                optimalApertures = mapPdfClass.construct_absolute_optimum_apertures (tadApertures);
                centroidPriorsAvailable = true;
            elseif(~isdeployed)
                optimalApertures = mapPdfClass.load_optimum_aperture_information (mapInput, mapData);
                centroidPriorsAvailable = true;
            elseif (~mapData.centroid.centroidMotionDataExists)
                string = [mapInput.debug.runLabel, 'Centroid motion information is not available; Reverting to raDecMag priors.'];
                mapInput.debug.display(component, string);
                [mapData.alerts] = add_alert(mapData.alerts, 'warning', string);
                centroidPriorsAvailable = false;
            else
                string = [mapInput.debug.runLabel, 'Optimum aperture information is not available; Reverting to raDecMag priors.'];
                mapInput.debug.display(component, string);
                [mapData.alerts] = add_alert(mapData.alerts, 'warning', string);
                centroidPriorsAvailable = false;
            end
        else
            centroidPriorsAvailable = false;
        end

        if (centroidPriorsAvailable)
            % Formulate the apertureStruct
            centroidStruct = struct('row', nan, 'column', nan);
            apertureStruct = repmat(struct('optimalAperture', [], 'centroid', centroidStruct), [mapData.nTargets,1]);
            for iTarget = 1 : mapData.nTargets
                apertureStruct(iTarget).optimalAperture = optimalApertures(iTarget);
                apertureStruct(iTarget).centroid.row    = median(mapData.centroid.motion(iTarget).row(~mapData.normTargetDataStruct(iTarget).gapIndicators));
                apertureStruct(iTarget).centroid.column = median(mapData.centroid.motion(iTarget).col(~mapData.normTargetDataStruct(iTarget).gapIndicators));
            end

            % Call Jeff K's function
            [priorEstimates, targetsWithEstimates] = mapPdfClass.estimate_priors_using_centroids_and_apertures(apertureStruct, mapData.robustFit.coefficients');

            if (sum(targetsWithEstimates) > 0)
                % Find the PDF sigma widths from the distribution
                % estimate the sigma by the median absolute deviation times factor given in the Matlab documentation on mad
                obj.defaultCentroidPriorSigmas = zeros(mapData.nBasisVectors,1);
                % This is the difference between the robustFit and the centroid priors
                diffValues = zeros(mapData.nTargets, mapData.nBasisVectors);
                for iBasisVector = 1 : mapData.nBasisVectors
                    diffValues(:,iBasisVector) = mapData.robustFit.coefficients(iBasisVector,:)' - priorEstimates(:,iBasisVector);
                    obj.defaultCentroidPriorSigmas(iBasisVector) = 1.4826*mad(diffValues(targetsWithEstimates,iBasisVector),1);
                end
            end

            kepMag = [mapInput.targetDataStruct.keplerMag];
            for iTarget = 1 : mapData.nTargets
                if (~obj.targetsMapAppliedTo(iTarget))
                    continue;
                end

                if (~targetsWithEstimates(iTarget))
                    % No prior estimates for this target
                    obj.targetInfo(iTarget).priorPdfInfo.centroidPrior.centroidPriorUsed = false;
                    continue;
                end
                obj.targetInfo(iTarget).priorPdfInfo.centroidPrior.centroidPriorUsed = true;

                obj.targetInfo(iTarget).priorPdfInfo.centroidPrior.coeffSigmas = zeros(mapData.nBasisVectors,1);
                distance = abs(kepMag - kepMag(iTarget))';
                %***
               % Derive the prior sigma widths from the median absolute deviation of targets with priors in a window about TUS
                windowHalfWidth = 0.25; % in kepler magnitude units
                targetsInWindow = (distance <= windowHalfWidth) & targetsWithEstimates;
                while (sum(targetsInWindow) < 10)
                    % Too few targets in window so expand window
                    windowHalfWidth = windowHalfWidth * 2; % in kepler magnitude units
                    targetsInWindow = (distance <= windowHalfWidth) & targetsWithEstimates;
                    if (all(targetsInWindow) || windowHalfWidth > 16)
                        error('generate_prior_pdf: Error in finding targets in window for centroid priors');
                    end
                end
                for iBasisVector = 1 : mapData.nBasisVectors
                    % Derive the prior sigma widths from the median absolute deviation of targets with priors in a window about TUS
                    obj.targetInfo(iTarget).priorPdfInfo.centroidPrior.coeffSigmas(iBasisVector) = ...
                            1.4826*mad(diffValues(targetsInWindow,iBasisVector),1);

                    % If sigma is Nan then use full sigma value found above
                    if (isnan(obj.targetInfo(iTarget).priorPdfInfo.centroidPrior.coeffSigmas(iBasisVector)))
                        obj.targetInfo(iTarget).priorPdfInfo.centroidPrior.coeffSigmas(iBasisVector) = obj.defaultCentroidPriorSigmas(iBasisVector);
                    end
                end
                % The prior coefficient mean is simply the centroid prior coefficients
                obj.targetInfo(iTarget).priorPdfInfo.centroidPrior.coeffs = priorEstimates(iTarget,:);
            end
        end
       %if (mapInput.debug.query_do_plot(component))
            %obj.plot_priors(mapInput, mapData);
       %end

        %******************
        %******************


        duration = toc;
        mapInput.debug.display(component, ['Prior PDF generated: ' num2str(duration) ...
            ' seconds = '  num2str(duration/60) ' minutes']);

        %***
        % Plot some Prior PDF histograms and fit curves
        if (mapInput.debug.query_do_plot(component) && ...
                    mapInput.debug.doAnalyzeReducedSetOfTargets);
            priorPdfFig = mapInput.debug.create_figure;
            % Plot whatever targets that have already been selected
            targetIndicesToPlot = find(mapInput.debug.targetsToAnalyze);

            % Plot Prior PDF for each component for selected targets
            nTargetsToPlot =  length(targetIndicesToPlot);
            for targetArrayIndex = 1 : nTargetsToPlot 
                iTarget = targetIndicesToPlot(targetArrayIndex);
                if (~obj.targetsMapAppliedTo(iTarget))
                    continue;
                end
                for iBasisVector = 1 : mapData.nBasisVectors
                    if (~obj.targetInfo(iTarget).basisVectorsToUse(iBasisVector))
                        continue;
                    end
                    mapInput.debug.select_figure(priorPdfFig);

                    sortedHistData = ...
                     sort(mapData.robustFit.coefficients(iBasisVector, obj.targetInfo(iTarget).priorPdfInfo.targetsForPrior));
                    nHistTargets = length(sortedHistData);
                    % Select only the middle 96% (don't plot the histogram tails)
                    sortedHistData = [sortedHistData(ceil(0.02*nHistTargets):round(0.98*nHistTargets))];
                    [n, xout] = hist(sortedHistData);

                    % Plot the histogram of robust fit coefficients
                    bar(xout, n);
                    hold on;

                    % Generate values for PDF curve
                    % Plot a bit past the histogram
                    width = 3.0 * (max(xout) - min(xout));
                    center = (max(xout) + min(xout)) / 2.0;
                    stepSize = width / 200;
                    x = [center-width/2.0:stepSize:center+width/2.0];
                    y(1:size(x)) = 0.0;
                    y = mapData.pdf.priorPdf(iTarget, iBasisVector, x, mapData, mapInput);
                    % Normalize PDF to 1 for plot legibility
                    factor =  max(n) / max(y);
                    y = y .* factor;
                    plot(x,y, '-r')

                    coeffLegend = [num2str(length(obj.targetInfo(iTarget).priorPdfInfo.targetsForPrior)), ' coefficients'];
                    legend(coeffLegend, 'ksdensity PDF fit');
                    title(['Prior PDF (renormalized); kepID ', num2str(mapData.kic.keplerId(iTarget)), ...
                        '; Component ', num2str(iBasisVector)])
                    hold off;
                    string = ['Generated plot for target ', num2str(targetArrayIndex), ' of ', ...
                    num2str(nTargetsToPlot), '; Component ', num2str(iBasisVector), ' of ', num2str(mapData.nBasisVectors)];
                    mapInput.debug.pause(string);
                    filename = ['prior_PDF_kepID_', num2str(mapData.kic.keplerId(iTarget)), ...
                                    '_basis_vector_', num2str(iBasisVector)];
                    mapInput.debug.save_figure(priorPdfFig, component, filename);
                end % iBasisVector
            end % iTarget
        end % plotting

    end %function [] = generatePriorPdf(obj, mapData, mapInput)
 
    %*******************************************************************************
    %% function [value] = priorPdf (targetIndex, basisVectorIndex, theta, mapData, mapInput, priorType)
    %*******************************************************************************
    % Uses ksdensity to construct a PDF and evaluates it at <theta> for basis vector basisVectorIndex
    % <basisVectorIndex>.
    %
    % Inputs:
    %   priorType   -- [char (Optional)] force this type of prior {'raDecMag' 'centroid'}
    %
    % Outputs:
    %   value        -- [double] Value of PDF at theta (>=realmin)
    %   
    %*******************************************************************************
 
    function [value] = priorPdf (obj, targetIndex, basisVectorIndex, theta, mapData, mapInput, varargin)
 
        forceCentroidPrior = false;
        forceRaDecKepmagPrior = false;

        nTheta = length(theta);
        % Check if this basisVectorIndex is used, if not then value = realmin
        if (~obj.targetInfo(targetIndex).basisVectorsToUse(basisVectorIndex))
            value = repmat(realmin, [nTheta,1]);
            return;
        end
 
        % Check if forcing a specific prior type
        if (length(varargin) > 0)
            switch varargin{1}
            case 'raDecMag'
                forceRaDecKepmagPrior = true;
            case 'centroid'
                forceCentroidPrior = true;
            end
        end

        if ((forceCentroidPrior || (~forceRaDecKepmagPrior && mapInput.mapParams.useCentroidPriors)) && obj.targetInfo(targetIndex).priorPdfInfo.centroidPrior.centroidPriorUsed)
            if (isempty(obj.targetInfo(targetIndex).priorPdfInfo.centroidPrior.coeffs))
                % No prior available
                value = repmat(realmin, [nTheta,1]);
            else
                % Uses a gaussian distribution
                % This should be normalized the same as ksdensity below
                value = pdf('Normal', theta, obj.targetInfo(targetIndex).priorPdfInfo.centroidPrior.coeffs(basisVectorIndex), ...
                                    obj.targetInfo(targetIndex).priorPdfInfo.centroidPrior.coeffSigmas(basisVectorIndex))';
            end
        else
            if (obj.USEONLYTUSFORPRIOR)
                targetsForPrior = false(mapData.nTargets, 1);
                targetsForPrior(targetIndex) = true;
                targetWeights = 1.0; % Set to 1.0 for the one TUS
            elseif (mapInput.mapParams.useBasisVectorsAndPriorsFromPixels)
                % When using pixel priors there's a different distance/weight for each dimension seperately
                targetsForPrior = obj.targetInfo(targetIndex).priorPdfInfo.targetsForPrior;
                targetWeights = obj.targetInfo(targetIndex).priorPdfInfo.targetWeight(:,basisVectorIndex);
            else
                % *** THIS IS THE DEFAULT CHOICE USED FOR STANDARD RUNS ***
                targetsForPrior = obj.targetInfo(targetIndex).priorPdfInfo.targetsForPrior;
                targetWeights = obj.targetInfo(targetIndex).priorPdfInfo.targetWeight;
            end
            % Use robust coeffs from blob if requested
            % The priorPdfInfo was already loaded from the Blob to it's ussual spot in generate_prior_pdf (if needed)
            if (mapInput.mapParams.useBasisVectorsAndPriorsFromBlob)
                coeffsForPrior = mapInput.cbvBlobStruct.robustFitCoefficientsNoBands(basisVectorIndex, targetsForPrior);
            %elseif (mapInput.mapParams.useBasisVectorsAndPriorsFromPixels || obj.USEONLYTUSFORPRIOR)
            elseif (obj.USEONLYTUSFORPRIOR)
                coeffsForPrior = mapData.pixelData.priors(targetsForPrior, basisVectorIndex);
            else
                coeffsForPrior = mapData.robustFit.coefficients(basisVectorIndex, targetsForPrior);
            end
            value = ksdensity (coeffsForPrior, theta, 'weights', targetWeights)';
        end
 
        % Check if the resultant value is zero. If so, then set to realmin so that taking the log
        % doesn't result in -Inf
        if (value <= 0)
            value = repmat(realmin, [nTheta,1]);
        end
 
    end
 
    %*******************************************************************************
    %% function [] = generate_conditional_pdf(obj, mapData, mapInput)
    %*******************************************************************************
    % 
    % generated the data needed to construct the conditional PDF and stores in
    % mapData.pdf.targetInfo(nTargets).conditionalPdfInfo.
    %
    % 1) calculate the standard deviation for each target flux.
    %
    %*******************************************************************************
 
    function [] = generate_conditional_pdf(obj, mapData, mapInput)
 
        component = 'generateConditional';

        mapInput.debug.display(component, 'Generating Conditional PDF...');
        tic;

        for iTarget = 1 : mapData.nTargets
            if (~obj.targetsMapAppliedTo(iTarget))
                continue;
            end
            obj.targetInfo(iTarget).conditionalPdfInfo.stdFlux = ...
                        nanstd(mapData.normTargetDataStruct(iTarget).values);
        end
 
        %***
        % Plot some Conditional PDF curves
        if (mapInput.debug.query_do_plot(component) & ...
                    mapInput.debug.doAnalyzeReducedSetOfTargets);
            conditionalPdfFig = mapInput.debug.create_figure;
            % Plot whatever targets that have already been selected
            targetIndicesToPlot = find(mapInput.debug.targetsToAnalyze);

            % Find the basis vector ranges from the robust fit coefficient ranges
            basisVectorInitialRanges = obj.find_basis_vector_range(mapData);

            % Plot Conditional PDF for each component for selected targets
            nTargetsToplot =  length(targetIndicesToPlot);
            for targetArrayIndex = 1 : nTargetsToplot 
                iTarget = targetIndicesToPlot(targetArrayIndex);
                for iComponent = 1 : mapData.nBasisVectors
                    if (~obj.targetInfo(iTarget).basisVectorsToUse(iComponent))
                        continue;
                    end
                    mapInput.debug.select_figure(conditionalPdfFig);

                    % Generate values for PDF curve
                    width  = (basisVectorInitialRanges(iComponent).high  - basisVectorInitialRanges(iComponent).low);
                    center = (basisVectorInitialRanges(iComponent).high  + ...
                                        basisVectorInitialRanges(iComponent).high) / 2.0;
                    stepSize = width / 200;
                    x = [center-width/2.0:stepSize:center+width/2.0];
                    y(1:size(x)) = 0.0;
                    y = mapData.pdf.conditionalPdf(iTarget, iComponent, x, mapData);
                    % Normalize maximum of PDF to 1 for plot legibility
                    factor =  abs(max(y));
                    y = y .* factor;
                    plot(x,y, '-r')

                    title(['Conditional PDF (renormalized); kepID ', num2str(mapData.kic.keplerId(iTarget)), ...
                        '; Component ', num2str(iComponent)])
                    hold off;
                    string = ['Generated plot for target ', num2str(targetArrayIndex), ' of ', ...
                    num2str(nTargetsToplot), '; Component ', num2str(iComponent), ' of ', num2str(mapData.nBasisVectors)];
                    mapInput.debug.pause(string);
                    filename = ['conditional_PDF_kepID_', num2str(mapData.kic.keplerId(iTarget)), ...
                                    '_basis_vector_', num2str(iComponent)];
                    mapInput.debug.save_figure(conditionalPdfFig, component, filename);
                end % iComponent
            end % iTarget
        end % plotting

        duration = toc;
        mapInput.debug.display(component, ['Conditional PDF generated: ' num2str(duration) ...
            ' seconds = '  num2str(duration/60) ' minutes']);

    end %function [] = generate_conditional_pdf
 
    %*******************************************************************************
    %% function [condPdf] = conditionalPdf (obj, targetIndex, basisVectorIndex, theta, mapData)
    %*******************************************************************************
    %
    % Computes the non-constant part of the log of the conditional PDF for each target using the
    % following formula:
    %
    % p(y|theta) = (1/(2*pi*sigma)^(N/2)) * Exp[(1/(2*sigma^2)) * (y_hat - U_hat*theta)'(y_hat - H_hat*theta)]
    %
    % log(p(y|theta)) = - (1/(2*sigma^2) * (y_hat - U_hat*theta)'(y_hat - H_hat*theta)
    %
    % The answer is for the basis vector specified by <basisVectorIndex>
    %
    % This is a vectorized function so if <theta> is an array the resultant is an array of answers for each
    % calue of <theta>.
    % 
    % NOTE: This function assumes orthogonal basis vectors!
    %
    % TODO: create a robust version of this least-squares fit. Maybe use the robustfit stats output...
    %
    % Outputs:
    %   condPDF         -- [double] log of the PDF (>=log(realmin))
    %   
    %*******************************************************************************
 
    function [condPdf] = conditionalPdf(obj, targetIndex, basisVectorIndex, theta, mapData)
 
        nTheta = length(theta);
        % Only do least-squares fit for basis vectors used for this target
        % Otherwise use log(realmin) (to agree with Prior PDF)
        if (obj.targetInfo(targetIndex).basisVectorsToUse(basisVectorIndex))
            % Sequential least-squares fitting
            % only used if obj.DOSEQUENTIALFITTING is true
            % First subtract off the fit from all basis vectors already fit before basisVectorIndex
            if (basisVectorIndex > 1)
                coeffs = zeros(mapData.nBasisVectors, 1);
                coeffs(1:basisVectorIndex-1) = ...
                    obj.targetInfo(targetIndex).fits.conditional.basisVectorCoeff(1:basisVectorIndex-1);
                % If this basis vector is not used force coeff to zero
                coeffs(~obj.targetInfo(targetIndex).basisVectorsToUse) = 0.0;
                residual = mapData.normTargetDataStruct(targetIndex).values - mapData.basisVectors * coeffs;
            else
                residual = mapData.normTargetDataStruct(targetIndex).values;
            end

            % Create matrix of fit residual for each theta value. Then calculate the conditional PDF values at
            % each theta value in parallel.
           fitResidualMatrix = zeros(length(mapData.normTargetDataStruct(targetIndex).values),nTheta);
            for iTheta = 1 : nTheta
                if (obj.DOSEQUENTIALFITTING)
                    fitResidualMatrix(:,iTheta) = (residual - ...
                            mapData.basisVectors(:,basisVectorIndex)*theta(iTheta)); 
                else
                    % It's a lot faster just to do the for loop versus repmat!
                    fitResidualMatrix(:,iTheta) = (mapData.normTargetDataStruct(targetIndex).values - ...
                            mapData.basisVectors(:,basisVectorIndex)*theta(iTheta)); 
                end
            end
            condPdf = - (1./(2.0*obj.targetInfo(targetIndex).conditionalPdfInfo.stdFlux^2)) * ...
                                    diag((fitResidualMatrix' * fitResidualMatrix));
        else
            condPdf = repmat(log(realmin), [nTheta,1]);
        end
 
    end % function conditional PDF

    %*******************************************************************************
    %% function [] = generate_posterior_pdf (obj, mapData, mapInput)
    %*******************************************************************************
    % 
    %   Calculates and collects all the information to construct the posterior PDF.
    %
    %   This includes the Prior and conditional PDFs and the Goodness component.
    %
    %*******************************************************************************

    function [] = generate_posterior_pdf (obj, mapData, mapInput)

        component = 'generatePosterior';

        mapInput.debug.display(component, 'Generating Posterior PDF...');
        tic;

        % Find the initial basis vector ranges for finding the maximum
        basisVectorInitialRanges = obj.find_basis_vector_range(mapData);

        % Only set up posterior for targets MAP is applied to (for speed)
        targetIndicesToAnalyze = find(obj.targetsMapAppliedTo);
        nTargetsToAnalyze = length(targetIndicesToAnalyze);

        nTargetsRevertedToRaDecMagPrior = 0;
        % Loop through each target
        for targetArrayIndex = 1 : nTargetsToAnalyze   
            iTarget =  targetIndicesToAnalyze(targetArrayIndex);
            
            obj.targetInfo(iTarget).posteriorPdfInfo.basisVectorInitialRanges = basisVectorInitialRanges;

            %***
            % Find prior weighting
         
            %*************************
            if (mapInput.mapParams.useCentroidPriors && ~strcmp(mapInput.debug.runLabel, 'Band_1'))
                % If using Centroid Priors...
                % Compare the prior from the two methods (raDecMag and centroid) and pick the one that has better goodness
                % This is based on the noise in the prior fit. So, don't do for Band 1
                
                % raDecMag prior goodness
                pdf = @(theta, basisVectorIndex) mapData.pdf.priorPdf(iTarget, basisVectorIndex, ...        
                                                                     theta, mapData, mapInput, 'raDecMag');
                % Must save in the fits struct for the prior goodness calculation to use it!
                obj.targetInfo(iTarget).fits.prior = obj.maximize_pdf (pdf, iTarget, basisVectorInitialRanges, ...
                                                    mapData, mapInput, component);
                raDecKepmagPrior = obj.targetInfo(iTarget).fits.prior;
                
                % Use prior Noise Goodness metric to determine which prior is better
                [dummy raDecKepmagNoiseGoodness] = obj.find_prior_goodness (iTarget, mapData, mapInput);
                
                % centroid prior goodness
                pdf = @(theta, basisVectorIndex) mapData.pdf.priorPdf(iTarget, basisVectorIndex, ...        
                                                                     theta, mapData, mapInput, 'centroid');
                obj.targetInfo(iTarget).fits.prior = obj.maximize_pdf (pdf, iTarget, basisVectorInitialRanges, ...
                                                    mapData, mapInput, component);
                centroidPrior = obj.targetInfo(iTarget).fits.prior;
                
                % Use prior Noise Goodness metric to determine which prior is better
                [dummy centroidNoiseGoodness] = obj.find_prior_goodness (iTarget, mapData, mapInput);

                % Pick the one that is better
                % TODO: make centroidBias an input parameter
                centroidBias = 0.0;
                if (raDecKepmagNoiseGoodness > centroidNoiseGoodness + centroidBias)
                    obj.targetInfo(iTarget).fits.prior = raDecKepmagPrior;
                    obj.targetInfo(iTarget).priorPdfInfo.centroidPrior.centroidPriorUsed = false;
                    nTargetsRevertedToRaDecMagPrior  = nTargetsRevertedToRaDecMagPrior + 1;
                else
                    % centroidPrior already saved in fits struct!
                end
            else
                % Still need to maximize prior fit if using old raDecKepmag priors
                pdf = @(theta, basisVectorIndex) mapData.pdf.priorPdf(iTarget, basisVectorIndex, theta, mapData, mapInput);
                obj.targetInfo(iTarget).fits.prior = obj.maximize_pdf (pdf, iTarget, basisVectorInitialRanges, ...
                                                    mapData, mapInput, component);
            end
            %*************************

            % Find prior goodness for chosen prior. For Coarse, no_BS and Band_1 use polyfit for Band_2 (and Band_3) use noise
            switch mapInput.debug.runLabel
                case {'Band_2' 'Band_3'}
                    % Use prior Noise Goodness metric 
                    [dummy obj.targetInfo(iTarget).posteriorPdfInfo.priorGoodness] = obj.find_prior_goodness (iTarget, mapData, mapInput);
                otherwise
                    % Compare the Prior PDF fit to a simple low order polynomial. If not even close then probably not a good
                    % prior
                    [obj.targetInfo(iTarget).posteriorPdfInfo.priorGoodness ~] = obj.find_prior_goodness (iTarget, mapData, mapInput);
            end
         
            % Prior PDF weight is 
            obj.targetInfo(iTarget).posteriorPdfInfo.priorWeight = obj.find_prior_weight (iTarget, mapData, mapInput);

            % If prior goodness is near zero then MAP is not applied,
            % So, instead use reduced robust fit (by setting targetsMapAppliedTo = false)
            if (obj.targetInfo(iTarget).posteriorPdfInfo.priorGoodness < mapInput.mapParams.priorWeightGoodnessCutoff)
                obj.targetsMapAppliedTo(iTarget) = false;
            end

            % For K2 if the prior weight is zero then use the reduced robust fit
            % TODO: consider doing this for Kepler data as well! It's a good idea.
            if (mapInput.taskInfoStruct.thisIsK2Data && obj.targetInfo(iTarget).posteriorPdfInfo.priorWeight < obj.MINIMUMPRIORWEIGHT )
                obj.targetsMapAppliedTo(iTarget) = false;
            end

            if (mapInput.debug.query(component, mapInput.debug.VERBOSEDEBUGLEVEL));
                mapInput.debug.waitbar(targetArrayIndex/nTargetsToAnalyze, 'Generating Posterior PDF...')
            end
        end
         
        if (nTargetsRevertedToRaDecMagPrior > 0)
            mapInput.debug.display(component, ['Reverted to RaDecMag prior for ', num2str(nTargetsRevertedToRaDecMagPrior), ' of ', ...
                                                num2str(mapData.nTargets), ' targets.']);
        end

        duration = toc;
        mapInput.debug.display(component, ['Posterior PDF generated: ' num2str(duration) ...
            ' seconds = '  num2str(duration/60) ' minutes']);

        %***
        % Plot some Posterior PDF curves
        if (mapInput.debug.query_do_plot(component) && ...
                    mapInput.debug.doAnalyzeReducedSetOfTargets);
            posteriorPdfFig = mapInput.debug.create_figure;
            % Plot whatever targets that have already been selected
            targetIndicesToPlot = find(mapInput.debug.targetsToAnalyze);

            % Plot Conditional PDF for each component for selected targets
            nTargetsToplot =  length(targetIndicesToPlot);
            for targetArrayIndex = 1 : nTargetsToplot 
                iTarget = targetIndicesToPlot(targetArrayIndex);
                for iComponent = 1 : mapData.nBasisVectors
                    if (~obj.targetInfo(iTarget).basisVectorsToUse(iComponent))
                        continue;
                    end
                    mapInput.debug.select_figure(posteriorPdfFig);

                    % Generate values for PDF curve
                    basisVectorInitialRanges = obj.targetInfo(iTarget).posteriorPdfInfo.basisVectorInitialRanges;
                    width  = (basisVectorInitialRanges(iComponent).high  - basisVectorInitialRanges(iComponent).low);
                    center = (basisVectorInitialRanges(iComponent).high  + ...
                                        basisVectorInitialRanges(iComponent).high) / 2.0;
                    stepSize = width / 200;
                    x = [center-width/2.0:stepSize:center+width/2.0];
                    y(1:size(x)) = 0.0;
                    y = mapData.pdf.posteriorPdf(iTarget, iComponent, x, mapData, mapInput);
                    % Normalize maximum of PDF to 1 for plot legibility
                    factor =  abs(max(y));
                    y = y .* factor;
                    plot(x,y, '-r')

                    title(['Posterior PDF (renormalized); kepID ', num2str(mapData.kic.keplerId(iTarget)), ...
                        '; Component ', num2str(iComponent)])
                    hold off;
                    string = ['Generatin plot for target ', num2str(targetArrayIndex), ' of ', ...
                    num2str(nTargetsToplot), '; Component ', num2str(iComponent), ' of ', num2str(mapData.nBasisVectors)];
                    mapInput.debug.pause(string);
                    filename = ['posterior_PDF_kepID_', num2str(mapData.kic.keplerId(iTarget)), ...
                                    '_basis_vector_', num2str(iComponent)];
                    mapInput.debug.save_figure(posteriorPdfFig, component, filename);
                end % iComponent
            end % iTarget
        end % plotting
    
    end % Generate Posterior PDF

    %*******************************************************************************
    %% function [value] = posteriorPdf (obj, targetIndex, basisVectorIndex, theta, mapData, mapInput)
    %*******************************************************************************
    %
    % posteriorPdf = posteriorPdf(theta) + W_pr * priorPdf(theta) + W_G * G(theta)
    %
    % If using centroid priors and the conditional fit coefficient is within n sigma of prior fit coefficient then just use conditional fit.
    %

    function [value] = posteriorPdf (obj, targetIndex, basisVectorIndex, theta, mapData, mapInput)

        snapThreshold = 1.0; % Number of sigma conditional fit must be to prior to snap to robust fit.

        nTheta = length(theta);
        % Generate value for basis vectors used for this target
        % Otherwise use log(realmin) to represent zero PDF (to agree with Prior PDF)
        if (obj.targetInfo(targetIndex).basisVectorsToUse(basisVectorIndex))
            conditionalValue =  obj.conditionalPdf(targetIndex, basisVectorIndex, theta, mapData);
            if (mapInput.mapParams.useCentroidPriors && obj.targetInfo(targetIndex).priorPdfInfo.centroidPrior.centroidPriorUsed)
                % Check if conditional fit is within n sigma of prior fit, If so only use the confitional. 
                % This is a snap-grid posterior
                % Do not check for Bands 2 or 3
                switch mapInput.debug.runLabel
                    case {'Band_2' 'Band_3'}
                        checkForThisData = false;
                    otherwise
                        priorCoeff = obj.targetInfo(targetIndex).fits.prior.basisVectorCoeff(basisVectorIndex);
                        priorSigma = obj.targetInfo(targetIndex).priorPdfInfo.centroidPrior.coeffSigmas(basisVectorIndex);
                        conditionalCoeff = obj.targetInfo(targetIndex).fits.conditional.basisVectorCoeff(basisVectorIndex);
                        checkForThisData = true;
                end
                if (checkForThisData && abs(conditionalCoeff - priorCoeff) < priorSigma * snapThreshold)
                    value = conditionalValue;
                else
                    priorValue =  obj.priorPdf (targetIndex, basisVectorIndex, theta, mapData, mapInput);
                    value = conditionalValue + obj.targetInfo(targetIndex).posteriorPdfInfo.priorWeight * priorValue;
                end
            else
                priorValue =  obj.priorPdf (targetIndex, basisVectorIndex, theta, mapData, mapInput);
                value = conditionalValue + obj.targetInfo(targetIndex).posteriorPdfInfo.priorWeight * priorValue;
            end
        else
            value = repmat(log(realmin), [1,nTheta]);
        end

    end % posteriorPdf

    %*******************************************************************************
    %% function [] = maximize_posterior_pdf (obj, mapData, mapInput)
    %*******************************************************************************
    %
    % Maximizes the Conditional and Posterior PDFs (The Prior PDF was already maximized in
    % generate_posterior_pdf in order to find the weighting).
    %
    % If the Goodness Metric is included then the maximizer passes through all targets once to get the base
    % values. For those targets with bad goodness they are iterated where the goodness metric value is
    % now included in the posterior PDF. All bad targets are passed through a second time before any are
    % iterated a thrid time in order to keep the goodness metric correlation statistic updated.
    %
    % The correlation statistic only accounts for targets where MAP was applied. It is not appropriate to use
    % targets where a reduced robust fit is performed.
    %
    %*******************************************************************************

    function [] = maximize_posterior_pdf (obj, mapData, mapInput)

        component = 'maximizePosterior';

        mapInput.debug.display(component, 'Maximizing Posterior PDF...');
        tic;

        % Only maximize posterior for targets to analyze (for speed)
        targetIndicesToAnalyze = find(obj.targetsMapAppliedTo);
        nTargetsToAnalyze = length(targetIndicesToAnalyze);
        if (nTargetsToAnalyze == 0)
            string = [mapInput.debug.runLabel, 'No targets found to apply MAP to.'];
            mapInput.debug.display(component, string);
            [mapData.alerts] = add_alert(mapData.alerts, 'warning', string);
            return;
        end
            

        % Loop through each target
        % This is the first iteration if using the goodness metric PDF
        for targetArrayIndex = 1 : nTargetsToAnalyze   
            iTarget =  targetIndicesToAnalyze(targetArrayIndex);
            
            % If only I could use a pointer...
            basisVectorInitialRanges = obj.targetInfo(iTarget).posteriorPdfInfo.basisVectorInitialRanges;

            %***
            % Prior PDF already maximized in obj.generate_posterior_pdf

            %***
            % Maximize Conditional PDF
            % NOTE: be sure to maximize conditional before posterior so that sequential least-squares fitting works properly
            if (obj.DOSEQUENTIALFITTING)
                doSetConditionalCoeffs = true;
            else
                doSetConditionalCoeffs = false;
            end
            pdf = @(theta, basisVectorIndex) mapData.pdf.conditionalPdf(iTarget, basisVectorIndex, theta, mapData);
            obj.targetInfo(iTarget).fits.conditional = obj.maximize_pdf (pdf, iTarget, basisVectorInitialRanges, ...
                                                mapData, mapInput, component, doSetConditionalCoeffs);

            %***
            % Compare prior to conditional fit noise and re-weight the prior accordingly
            if (obj.COMPAREPRIORTOCONDITIONALREWEIGHTING)
                priorFit       = mapData.basisVectors * obj.targetInfo(iTarget).fits.prior.basisVectorCoeff;
                conditionalFit = mapData.basisVectors * obj.targetInfo(iTarget).fits.conditional.basisVectorCoeff;
                [PSDPrior, ~]       = periodogram(diff(priorFit));
                [PSDConditional, ~] = periodogram(diff(conditionalFit));
                
                PSDRatio = PSDPrior ./ PSDConditional;
                
                % We want to see if the conditional has lower noise than the prior, which implies PSDRatio > 1
                % We are only concerned with bands where the power increased so when(PSDRatio) > 1 
                noiseWeight = 1e-4;
                priorNoiseGoodness    = noiseWeight * sum(log(PSDRatio(PSDRatio>1)).^2);
                
                priorNoiseGoodness = 1 ./ (priorNoiseGoodness + 1);

                % priorNoiseGoodness has a range [0,1], 1 being good. So, multiply prior weight by this goodness to scale with noise.
                obj.targetInfo(iTarget).posteriorPdfInfo.priorWeight = priorNoiseGoodness * obj.targetInfo(iTarget).posteriorPdfInfo.priorWeight;
            end


            %***
            % Maximize Posterior PDF
            pdf = @(theta, basisVectorIndex) mapData.pdf.posteriorPdf(iTarget, basisVectorIndex, ...                                                              theta, mapData)
                                                                  theta, mapData, mapInput);
            obj.targetInfo(iTarget).fits.posterior = obj.maximize_pdf (pdf, iTarget, basisVectorInitialRanges, ...
                                                mapData, mapInput, component);


            if (mapInput.debug.query(component, mapInput.debug.VERBOSEDEBUGLEVEL));
                mapInput.debug.waitbar(targetArrayIndex/nTargetsToAnalyze, 'Maximizing Posterior PDF...')
            end
        end
         
        % The maximizer can fail on some targets, update the list of targets to analyze if the maximizer
        % failed (rare, but ussually occurs a couple times per quarter).
        targetIndicesToAnalyze = find(obj.targetsMapAppliedTo);
        nTargetsToAnalyze = length(targetIndicesToAnalyze);

        %***
        % Goodness Metric Iterations
        %***
        if (mapInput.mapParams.goodnessMetricIterationsEnabled)
            if (nTargetsToAnalyze == 0)
                string = [mapInput.debug.runLabel, 'No targets found to apply MAP to for goodness metric iterations.'];
                mapInput.debug.display(component, string);
                [mapData.alerts] = add_alert(mapData.alerts, 'warning', string);
                return;
            end
            mapInput.debug.display(component, 'Iterating Posterior maximizer with Goodness Metric...');
            % Intially, we don't know what's bad so call everything bad.
            badTargets = targetIndicesToAnalyze;
            hitCorrelationCutoff = false(mapData.nTargets, 1);
            stopWorkingOnThisTarget = false(mapData.nTargets,1);
            for iGoodnessIter = 1 : mapInput.mapParams.goodnessMetricMaxIterations
                % Record coefficient values from previous iteration
                % Matlab can't do this asignment on one line : (
                coeffs = [obj.targetInfo];
                coeffs = [coeffs.fits];
                coeffs = [coeffs.posterior];
                coeffs = [coeffs.basisVectorCoeff];
                for iTarget = 1  : length(badTargets)
                    % Theta0 is used by find_goodness_pdf_value
                    obj.targetInfo(badTargets(iTarget)).posteriorPdfInfo.theta0 = coeffs(:,badTargets(iTarget));
                end
             
                % Find the goodness for all targets left
                % The EP goodness calculation is slow compared to the rest of the goodness metric so do not
                % compute that component here.
                doCalcEpGoodness = false;
                goodnessPdfStruct = obj.find_goodness_pdf_value (badTargets, [], [], mapData, mapInput, doCalcEpGoodness);
                if(iGoodnessIter == 1)
                    % On first iteration save all coefficient values and the initial goodness values
                    initialValues.badTargets = badTargets;
                    initialValues.coeffs = coeffs(:,badTargets);
                    initialValues.goodnessPdfStruct = goodnessPdfStruct;
                    % Matlab can't do this asignment on one line : (
                    initialValues.priorWeight = [obj.targetInfo(badTargets)];
                    initialValues.priorWeight = [initialValues.priorWeight.posteriorPdfInfo];
                    initialValues.priorWeight = [initialValues.priorWeight.priorWeight];
                end
             
                badCorrelationTargetIndicesToKeep = intersect(find([goodnessPdfStruct.correlation] < ...
                            mapInput.mapParams.goodnessMetricIterationsCutoff), find(logical(obj.targetsMapAppliedTo(badTargets))));
                badNoiseTargetIndicesToKeep       = intersect(find([goodnessPdfStruct.introducedNoise] < ...
                            mapInput.mapParams.goodnessMetricIterationsCutoff), find(logical(obj.targetsMapAppliedTo(badTargets))));
                badTargetIndicesToKeep            = union (badCorrelationTargetIndicesToKeep, badNoiseTargetIndicesToKeep);
                badTargets = badTargets(badTargetIndicesToKeep);
                badTargets = setdiff(badTargets, find(stopWorkingOnThisTarget));
                nTargetsToAnalyze = length(badTargets);
                if (nTargetsToAnalyze == 0)
                    break;
                end

                % Only keep goodness for targets that are bad
                goodnessPdfStruct = goodnessPdfStruct(badTargetIndicesToKeep);
                
                stepSize = mapInput.mapParams.goodnessMetricIterationsPriorWeightStepSize;
                % Redo for targets with bad goodness
                for targetArrayIndex = 1 : nTargetsToAnalyze   
                    iTarget =  badTargets(targetArrayIndex);
                    
                    % If only I could use a pointer...
                    basisVectorInitialRanges = obj.targetInfo(iTarget).posteriorPdfInfo.basisVectorInitialRanges;
          
                    % Adjust priorWeight based on goodness components
                    % Deciding on which way to adjust the weight is dependent on the values of the individual
                    % components. Correlation is the most important and easiest component to correct so that
                    % one takes precedence over introducedNoise. I.e. if the noise is bad, increase the prior
                    % weighting until the correlation hits the cutoff then stop.
                    if (goodnessPdfStruct(targetArrayIndex).correlation < mapInput.mapParams.goodnessMetricIterationsCutoff)
                        hitCorrelationCutoff(iTarget) = true;
                        deltaGoodness = mapInput.mapParams.goodnessMetricIterationsCutoff - goodnessPdfStruct(targetArrayIndex).correlation;
                        goodnessScaleFactor = (1/stepSize) / (10 * deltaGoodness);
                        % If the goodness scaling factor is greater than one then set to a small decrease of 10%
                        if (goodnessScaleFactor > 1)
                            goodnessScaleFactor = 0.9;
                        end
                        obj.targetInfo(iTarget).posteriorPdfInfo.priorWeight = ...
                            obj.targetInfo(iTarget).posteriorPdfInfo.priorWeight * goodnessScaleFactor;
                    elseif (goodnessPdfStruct(targetArrayIndex).introducedNoise < mapInput.mapParams.goodnessMetricIterationsCutoff)
                        % Only fix noise if correlation cutoff hasn't already been hit
                        if (hitCorrelationCutoff(iTarget))
                            stopWorkingOnThisTarget(iTarget) = true;
                        else
                            deltaGoodness = mapInput.mapParams.goodnessMetricIterationsCutoff - goodnessPdfStruct(targetArrayIndex).introducedNoise;
                            goodnessScaleFactor = stepSize * (10 * deltaGoodness);
                            % If the goodness scaling factor is less than one then set to a small increase of 10%
                            if (goodnessScaleFactor < 1)
                                goodnessScaleFactor = 1.1;
                            end
                            obj.targetInfo(iTarget).posteriorPdfInfo.priorWeight = ...
                                obj.targetInfo(iTarget).posteriorPdfInfo.priorWeight * goodnessScaleFactor ;
                        end
                    end

                    % Check if we hit the limit
                    if (obj.targetInfo(iTarget).posteriorPdfInfo.priorWeight < obj.MINIMUMPRIORWEIGHT)
                        obj.targetInfo(iTarget).posteriorPdfInfo.priorWeight = obj.MINIMUMPRIORWEIGHT;
                        stopWorkingOnThisTarget(iTarget) = true;
                    elseif (obj.targetInfo(iTarget).posteriorPdfInfo.priorWeight > obj.MAXIMUMPRIORWEIGHT)
                        obj.targetInfo(iTarget).posteriorPdfInfo.priorWeight = obj.MAXIMUMPRIORWEIGHT;
                        stopWorkingOnThisTarget(iTarget) = true;
                    end

                    %***
                    % Maximize Posterior PDF
                    pdf = @(theta, basisVectorIndex) mapData.pdf.posteriorPdf(iTarget, basisVectorIndex, theta, mapData, mapInput);
                    obj.targetInfo(iTarget).fits.posterior = obj.maximize_pdf (pdf, iTarget, basisVectorInitialRanges, mapData, mapInput, component);
          
                    if (mapInput.debug.query(component, mapInput.debug.VERBOSEDEBUGLEVEL));
                        mapInput.debug.waitbar(targetArrayIndex/nTargetsToAnalyze, ...
                            ['Iterating Posterior PDF with Goodness Metric; iteration ', num2str(iGoodnessIter), ...
                                ' of ', num2str(mapInput.mapParams.goodnessMetricMaxIterations)], true)
                    end
                end

                % Check if goodness actually improved.
                stopWorkingOnThisTarget = obj.check_if_goodness_improved_with_iterator (goodnessPdfStruct, badTargets, stopWorkingOnThisTarget, mapData, mapInput);

            end % goodness iterations loop

            if (iGoodnessIter == mapInput.mapParams.goodnessMetricMaxIterations)
                string = [mapInput.debug.runLabel, ': Reached maximum iterations while Goodness Metric Cleaning, some targets may still be below cutoff.'];
                mapInput.debug.display(component, string);
                [mapData.alerts] = add_alert(mapData.alerts, 'warning', string);
            end

            % If goodness did not improve then revert to non-iterated coefficient values
            obj.revert_to_old_fits_if_goodness_no_better_after_itarator (initialValues, mapData, mapInput);

            mapInput.debug.close_waitbar;
            mapInput.debug.display(component, 'Finished iterating Posterior maximizer with Goodness Metric.');
        end
        %***
        % END Goodness iterations
        %***

        duration = toc;
        mapInput.debug.display(component, ['Posterior PDF Maximized: ' num2str(duration) ...
            ' seconds = '  num2str(duration/60) ' minutes']);

        %***
        % Plot some PDF curves. All three together
        if (mapInput.debug.query_do_plot(component) && ...
                    mapInput.debug.doAnalyzeReducedSetOfTargets)
            % Plot whatever targets that have already been selected
            targetIndicesToPlot = find(mapInput.debug.targetsToAnalyze);
            obj.plot_pdf(targetIndicesToPlot);
        end

    end % maximize_posterior_pdf

    %*******************************************************************************
    %% function [figureHandle] = plot_pdf (obj, targetIndicesToPlot)
    %*******************************************************************************
    %
    % Plots the target Prior, Conditional and Posterior Pdfs. The Prior and Conditional are scaled and normalized to the posterior so they can all be seen in
    % the same plot.
    %
    %*******************************************************************************
    function [figureHandle] = plot_pdf (obj, targetIndicesToPlot, keplerIds, basisVectors, mapParams, normTargetDataStruct, robustFitCoefficients, ...
                                        debug, figureHandle)
    
        if (isempty(figureHandle))
            figureHandle = figure;
        end
        nBasisVectors = length(basisVectors(1,:));

        % Make fake mapInput and mapData for use with PDF functions
        % This will only create fields that are polpulated here so that any empty data will result in an error
        mapInput.mapParams = mapParams;
        mapInput.debug = debug;

        mapData.normTargetDataStruct = normTargetDataStruct;
        mapData.basisVectors = basisVectors;
        mapData.nTargets = length(normTargetDataStruct);
        mapData.robustFit.coefficients = robustFitCoefficients;

        % Plot All three PDFs for each component for selected targets
        % and the maximization values for each
        nTargetsToPlot =  length(targetIndicesToPlot);
        for targetArrayIndex = 1 : nTargetsToPlot 
            iTarget = targetIndicesToPlot(targetArrayIndex);
            for iComponent = 1 : nBasisVectors
                if (~obj.targetInfo(iTarget).basisVectorsToUse(iComponent))
                    continue;
                end
                figure(figureHandle);

                % Generate values for PDF curve
                basisVectorInitialRanges = obj.targetInfo(iTarget).posteriorPdfInfo.basisVectorInitialRanges;
                width  = 2.0 * (basisVectorInitialRanges(iComponent).high  - basisVectorInitialRanges(iComponent).low);
                center = (basisVectorInitialRanges(iComponent).high  + ...
                                    basisVectorInitialRanges(iComponent).high) / 2.0;
                stepSize = width / 200;
                x = [center-width/2.0:stepSize:center+width/2.0];

                %***
                % Posterior PDF
                posteriorCurve = obj.posteriorPdf(iTarget, iComponent, x, mapData, mapInput);
                % Normalize maximum of PDF to 1 for plot legibility
                factor =  abs(max(posteriorCurve));
                posteriorCurve = posteriorCurve .* factor;
                plot(x,posteriorCurve, '-b', 'LineWidth', 3);
                hold on;
                
                % The prior and conditional need to be rescaled to be seen on the same plot as the
                % posterior
                posteriorRange = [min(posteriorCurve), max(posteriorCurve)];

                %***
                % Prior PDF
                priorCurve = obj.priorPdf(iTarget, iComponent, x, mapData, mapInput);
                priorCurve = obj.rescale_data (priorCurve, posteriorRange);
                plot(x,priorCurve, '-k');

                %***
                % Conditional PDF
                conditionalCurve = obj.conditionalPdf(iTarget, iComponent, x, mapData);
                conditionalCurve = obj.rescale_data (conditionalCurve, posteriorRange);
                plot(x,conditionalCurve, '-m');

                %***
                % The maximum values for all three on the posterior curve
                maxPosteriorCoeffVal = obj.targetInfo(iTarget).fits.posterior.basisVectorCoeff(iComponent);
                scatter( maxPosteriorCoeffVal, factor * obj.posteriorPdf(iTarget, iComponent, ...
                        maxPosteriorCoeffVal, mapData, mapInput), 80, 'b');
                maxPriorCoeffVal = obj.targetInfo(iTarget).fits.prior.basisVectorCoeff(iComponent);
                scatter( maxPriorCoeffVal, factor * obj.posteriorPdf(iTarget, iComponent, maxPriorCoeffVal, mapData, mapInput), ...
                        50, 'k', 'filled');
                maxConditionalCoeffVal = obj.targetInfo(iTarget).fits.conditional.basisVectorCoeff(iComponent);
                scatter( maxConditionalCoeffVal, factor * obj.posteriorPdf(iTarget, iComponent, ...
                        maxConditionalCoeffVal, mapData, mapInput), 50, 'm', 'filled');

                title([mapInput.debug.runLabel, '; Maximization of All Three PDFs (normalized); kepID ', num2str(keplerIds(targetArrayIndex)), ...
                    '; Basis Vector ', num2str(iComponent), '; Prior Weight = ', num2str(obj.targetInfo(iTarget).posteriorPdfInfo.priorWeight)])
                hold off;
                legend('Posterior PDF', 'Prior PDF', 'Conditional PDF', ...
                        'Posterior Maximum', 'Prior Maximum', 'Conditional Maximum', 'Location', 'Best')
                ylabel('Arbitrary Units');
                xlabel('Coefficient Value');

                string = ['Generated plot for target ', num2str(targetArrayIndex), ' of ', ...
                            num2str(nTargetsToPlot), '; Component ', num2str(iComponent), ' of ', num2str(nBasisVectors)];
                disp(string);
                if (iComponent < nBasisVectors)
                    pause;
                end
               %filename = ['maximized_PDFs_kepID_', num2str(mapData.kic.keplerId(iTarget)), ...
               %                '_basis_vector_', num2str(iComponent)];
               %mapInput.debug.save_figure(figureHandle, component, filename);
            end % iComponent
        end % iTarget
    end
    
end % Public Methods

methods (Access = 'private')

    %***************************************************************************
    % This simply finds ranges for each coefficient based on the robust fit coefficients

    function [basisVectorInitialRanges] = find_basis_vector_range(obj, mapData)

        basisVectorInitialRanges = repmat( struct('low' , 0.0 , ...
                                                  'high', 0.0), [mapData.nBasisVectors,1]);
 
        for iBasisVector = 1 : mapData.nBasisVectors
            % Set initial range to 5% and 95% of basis vector coefficient values to remove outliers
            basisVectorInitialRanges(iBasisVector).low  = prctile(mapData.robustFit.coefficients(iBasisVector,:), 5);
            basisVectorInitialRanges(iBasisVector).high = prctile(mapData.robustFit.coefficients(iBasisVector,:), 95);

            % Now expand by INITIALRANGEEXPANDFACTOR
            width = basisVectorInitialRanges(iBasisVector).high - basisVectorInitialRanges(iBasisVector).low;
            basisVectorInitialRanges(iBasisVector).low  = ...
                    basisVectorInitialRanges(iBasisVector).low  - (obj.INITIALRANGEEXPANDFACTOR-1) * (width/2);
            basisVectorInitialRanges(iBasisVector).high = ...
                    basisVectorInitialRanges(iBasisVector).high + (obj.INITIALRANGEEXPANDFACTOR-1) * (width/2);
        end
            
    end

    %*******************************************************************************
    %% function [pdfFitStruct] = maximize_pdf (obj, pdf, targetIndex, basisVectorInitialRanges,...
    %                                          mapData, mapInput, component, doSetConditionalCoeffs);
    %*******************************************************************************
    %
    % Maximize the PDF specified by <whichPdf>. All three PDf have the same input and output arguments.
    %
    % Input:
    %       pdf           -- [function handle] arguments: pdf(theta, basisVectorIndex) 
    %       targetIndex   -- [integer] Target Index to maximize the PDF of
    %       basisVectorInitialRanges -- [struct] fields: low, high 
    %       mapData
    %       mapInput
    %       component     -- [string] The name of the component calling this function (for display purposes)
    %       doSetConditionalCoeffs  -- [logical (optional)] This is a hack!!! If doing sequential least-squares fitting we need to set the conditional 
    %                                       fit coeff values dynamically. There is no easy way to do that in this framework. This flag forces the conditional
    %                                       fit coeff values set during this function's iBasisVector loop. pdfMaxValue is not needed for this. Default is false.
    %
    % Output:
    %       pdfFitStruct            -- See above for description of this struct
    %       obj.targetsMapAppliedTo -- if maximizer falied on all basis vectors for any targets
    %
    %*******************************************************************************

    function [pdfFitStruct] = maximize_pdf (obj, pdf, targetIndex, basisVectorInitialRanges, ...
                                            mapData, mapInput, component, varargin)

        doSetConditionalCoeffs = false;
        if (obj.DOSEQUENTIALFITTING && ~isempty(varargin))
            doSetConditionalCoeffs = varargin{1};
        end
        basisVectorsForThisTarget = obj.targetInfo(targetIndex).basisVectorsToUse;

        success = false(mapData.nBasisVectors,1);

        % Set the options for fminbnd
        % Just use default for most, only tolX is defined by the MAP parameter maxTolerance
        options = optimset('fminbnd');
        options = optimset(options, 'TolX', mapInput.mapParams.maxTolerance);

        % Cycle through basis vector components and maximize each in order. 
        % Note: For orthogonal basis vectors each fit does not need to be removed from the light curve before
        % fitting the next.  
        % Since there are only minimizers in Matlab we are actually minimizing the negative of
        % the PDF.
        for iBasisVector = 1 : mapData.nBasisVectors
    
            % If this basis vector is not used the set coefficient to 0.0
            if (~basisVectorsForThisTarget(iBasisVector))
                pdfFitStruct.basisVectorCoeff(iBasisVector) = 0.0;
                pdfFitStruct.pdfMaxValue(iBasisVector)      = NaN;
                continue;
            end

            pdfThisBasisVector = @(theta) -pdf(theta, iBasisVector); % NEGATIVE of PDF

            coeffInitialRange = basisVectorInitialRanges(iBasisVector);
            if (~(coeffInitialRange.low < coeffInitialRange.high))
                % Initial ranges are not valid
                pdfFitStruct.basisVectorCoeff(iBasisVector) = 0.0;
                pdfFitStruct.pdfMaxValue(iBasisVector) = NaN;
                success(iBasisVector) = false;
            else
                % Initial ranges are good
                [thetaBound, success(iBasisVector)] = obj.bracket_minimum (pdfThisBasisVector, coeffInitialRange, mapInput, component);
            end
                
            if(success(iBasisVector))
                % Now minimize
                [pdfFitStruct.basisVectorCoeff(iBasisVector), pdfFitStruct.pdfMaxValue(iBasisVector)] = ...
                    fminbnd (pdfThisBasisVector, thetaBound.low, thetaBound.high, options);
            else
                pdfFitStruct.basisVectorCoeff(iBasisVector) = 0.0;
                pdfFitStruct.pdfMaxValue(iBasisVector) = NaN;
            end

            if (doSetConditionalCoeffs)
                obj.targetInfo(targetIndex).fits.conditional.basisVectorCoeff(iBasisVector) = pdfFitStruct.basisVectorCoeff(iBasisVector);
            end
        end

        % Change to column vectors so matrix algebra works.
        pdfFitStruct.basisVectorCoeff = pdfFitStruct.basisVectorCoeff';
        pdfFitStruct.pdfMaxValue = pdfFitStruct.pdfMaxValue';
            
        % Collect failed maximizations
        failedMaximizations = find(~success(basisVectorsForThisTarget));
        if (length(failedMaximizations) >= 1)
            string = [mapInput.debug.runLabel, ': MAP: Could not maximize PDF for kepID ', ...
                    num2str(mapInput.targetDataStruct(targetIndex).kic.keplerId), ', basis vector(s) ', num2str(failedMaximizations')];
            mapInput.debug.display(component, string);
            [mapData.alerts] = add_alert(mapData.alerts, 'warning', string);
        end

        % If maximizer failed on all basis vectors then update targetsMapAppliedTo
        if (all(~success(basisVectorsForThisTarget)))
            obj.targetsMapAppliedTo(targetIndex) = false;
        end

    end % function maximize_pdf

    %*******************************************************************************
    %% function [thetaBound, success] = bracket_minimum (obj, pdf, coeffInitialRange, mapInput, component)
    %*******************************************************************************
    %
    % Brackets the minimum of the pdf. Due to the difficulty in minimizing a non-monotonic function this
    % method uses brute force by sweeping through the 1-D function space and finding the minimum of the
    % function at each point. It then returns the two sweep points in either side of this minimum.
    %
    % If the minimum was not found within the initial range then the range is expanded by 
    % obj.BRACKETRANGEEXPANDFACTOR 
    %
    % Input:
    %       pdf                 -- [function handle] arguments: pdf(theta) 
    %       coeffInitialRange   -- [struct] fields: low, high
    %       mapInput            -- [mapInputClass] 
    %       component           -- [char] name of this MAP component
    %
    % Output:
    %       thetaBound    --  [struct] fields: low, high
    %       success       --  [logical] if false then could not bracket minimum
    %
    %*******************************************************************************

    function [thetaBound, success] = bracket_minimum (obj, pdf, coeffInitialRange, mapInput, component)

        % Create an initial distribution of points to evaluate the PDF
        rangeStart = coeffInitialRange.low;
        rangeEnd   = coeffInitialRange.high;
        width = rangeEnd - rangeStart;
        stepSize = width / mapInput.mapParams.numPointsForMaximizerFirstGuess;
        x = rangeStart:stepSize:rangeEnd;
        
        minIndex = -1; % index of the found minimum
        for iIterate = 1 : mapInput.mapParams.maxNumMaximizerIteration
        
            % Find the function values at the x points to locate the minimum.
            y = pdf(x);
 
            [~, minIndex] = min(y);

            if ( isempty(minIndex) || isnan(minIndex))
                % minimum of pdf sample could not be found
                success=false;
                thetaBound.low  = rangeStart;
                thetaBound.high = rangeEnd;
                return
            end

            if (minIndex > 1 && minIndex < length(x))
                % Then we bracketed the minimum!
                break;
            end

            % We need to expand the region to find the minimum
            %mapInput.debug.display(component, 'Could not Bracket minimum: increasing initial range...');
            rangeStart = rangeStart - (width*obj.BRACKETRANGEEXPANDFACTOR)/2.0;
            rangeEnd   = rangeEnd   + (width*obj.BRACKETRANGEEXPANDFACTOR)/2.0;
            width = rangeEnd - rangeStart;
            stepSize = width / mapInput.mapParams.numPointsForMaximizerFirstGuess;
            x = rangeStart:stepSize:rangeEnd;
 
        end
        
        if (iIterate == mapInput.mapParams.maxNumMaximizerIteration)
            % Maximum iterations reached. bracketing failed
            success=false;
            thetaBound.low  = rangeStart;
            thetaBound.high = rangeEnd;
            return
        end

        thetaBound.low  = x(minIndex-1);
        thetaBound.high = x(minIndex+1);
        success = true;

    end % function bracket_minimum


    %*******************************************************************************
    %% function [priorGeneralTrendGoodness priorNoiseGoodness] = find_prior_goodness (targetIndex, mapData, mapInput);
    %*******************************************************************************
    %
    % Determines how well a prior PDF fit is to the raw flux data. This is determined using two different methods:
    %
    %   1) by comparing the prior fit to a low order polynomial fit. If it is way-off then the prior must not be any good and it is
    %       weighted accordingly.
    %
    %   2) by comparing the noise of the prior to the flux. If the prior noise is larger than it has poor goodness
    %
    % Result range: 0 < priorGoodness < 1
    % The larger the goodness the better the fit. A goodness of zero means a a bad prior.
    %
    % Inputs:
    %   mapData.normTargetDataStruct.values)
    %   mapData.pdf.fits.prior.basisVectorCoeff
    %   mapData.basisVectors
    %
    % Outputs
    %   priorGeneralTrendGoodness
    %   priorNoiseGoodness
    %   
    %
    %*******************************************************************************

    function [priorGeneralTrendGoodness priorNoiseGoodness] = find_prior_goodness (obj, targetIndex, mapData, mapInput)

        % This is only called in generate_posterior_pdf so 'generatePosterior' is the component
        component = 'generatePosterior';
 
        % Re-use the same figure for each run of this function
        persistent priorGeneralTrendGoodnessFigure
        if (isempty(priorGeneralTrendGoodnessFigure) && mapInput.debug.query_do_plot(component) && ...
            mapInput.debug.doAnalyzeReducedSetOfTargets && mapInput.debug.targetsToAnalyze(targetIndex))
       %if (isempty(priorGeneralTrendGoodnessFigure) || isnan(priorGeneralTrendGoodnessFigure))
            priorGeneralTrendGoodnessFigure = mapInput.debug.create_figure;
        end
 
        % Generate the the prior fit to the flux
        priorFit = mapData.basisVectors * obj.targetInfo(targetIndex).fits.prior.basisVectorCoeff;
 
        flux = mapData.normTargetDataStruct(targetIndex).values;
        gaps = mapData.normTargetDataStruct(targetIndex).gapIndicators;

        %******************
        % 1) General Trend goodness

        % Remove low order poly fit
        x = [1:length(mapData.normTargetDataStruct(targetIndex).values)]';
        [p, s, mu] = polyfit(x, flux, mapInput.mapParams.coarseDetrendPolyOrder);
        polyFit = polyval(p, x, s, mu);
        
        %***
        % Compare the two and find the standard deviation of the difference.
        diffPriorToPolyFit = priorFit - polyFit;
        % Normalize to the mean absolute deviation of the polyfit removed light curve. This allows for a
        % comparison of the difference between the polyfit and the prior fit with respect to the variance of the
        % target.
        absDev = mad(mapData.normTargetDataStruct(targetIndex).values - polyFit);
        stdDiffPriorToPolyfit = std((diffPriorToPolyFit/absDev) - 1);
 
        % This scaling was empirically found where around a stdDiff of ~>3 is where the prior appears to
        % beginng to be poor: 1 - (stdDiff / 5)^3
        priorGeneralTrendGoodness = 1 - (stdDiffPriorToPolyfit/mapInput.mapParams.priorGoodnessScalingFactor)^...
                    mapInput.mapParams.priorGoodnessPowerFactor;

        if (priorGeneralTrendGoodness < 0)
            % When stdDiff is above priorGeneralTrendGoodnessScalingFactor then the above formula yields negative number.
            % But we should make weighting no less than 0. Anything above priorGeneralTrendGoodnessScalingFactor 
            % meens fit is poor.
            priorGeneralTrendGoodness = 0.0;
        end
        
        % Protect from the case when the prior goodness is NaN. This should
        % never happen but the JAVA databases REALLY does not like NaNs and
        % will crash upon first sight,
        if (isnan(priorGeneralTrendGoodness))
            priorGeneralTrendGoodness = 0.0;
        end

        %******************
        % 1) Noise goodness

        % This compares the periodograms of the first differences between the prior fit and the normFlux
        [PSDFlux, ~]    = periodogram(diff(    flux));
        [PSDPrior, ~]   = periodogram(diff(priorFit));

        PSDRatio = PSDPrior ./ PSDFlux;
        
        % We are only concerned with bands where the power increased so when(PSDRatio) > 1 
        noiseWeight = 2e-4;
        priorNoiseGoodness    = noiseWeight * sum(log(PSDRatio(PSDRatio>1)).^2);

        priorNoiseGoodness = 1 ./ (priorNoiseGoodness + 1);

        %******************
 
        
        % Plot the goodness fits for 1) targets to analyze if 2) plotting on and 3) anlyzing reduced set
        if (mapInput.debug.query_do_plot(component) && ...
                mapInput.debug.doAnalyzeReducedSetOfTargets && mapInput.debug.targetsToAnalyze(targetIndex));
            mapInput.debug.select_figure(priorGeneralTrendGoodnessFigure);
            subplot(2,1,1);
            hold off;
            plot(flux, '-b')
            hold on
            plot(priorFit, '-c')
            plot(polyFit, '-m')
            legend('Raw Flux (Normalized)', 'Prior Fit', 'Poly Fit');
            title(['Comparing Prior Fit to Low order Polynomial Fit; Kepler ID: ', ...
                    num2str(mapData.kic.keplerId(targetIndex))]);
            subplot(2,1,2);
            plot(diffPriorToPolyFit, '-*k')
            title(['Difference between Prior Fit and Poly Fit; Kepler ID: ', num2str(mapData.kic.keplerId(targetIndex)), ...
            ' stdDiff = ', num2str(stdDiffPriorToPolyfit), '; Goodness = ', num2str(priorGeneralTrendGoodness)]);
            string = ['Generated plot for target ', num2str(targetIndex)];
            mapInput.debug.pause(string);
            filename = ['priorGoodness_kepID_', num2str(mapData.kic.keplerId(targetIndex))];
            mapInput.debug.save_figure(priorGoodnessFigure, component, filename);
        end



    end % find_prior_goodness

    %*******************************************************************************
    %% function [priorWeight] = find_prior_weight (targetIndex, mapData, mapInput);
    %*******************************************************************************
    %
    % Determines the weighting of the prior PDF in the posterior PDF.
    %
    % posteriorPDF = conditionalPDF + W_pr priorPDF
    %
    %   W_pr = (1+variability)^priorPdfVariabilityWeight  * 
    %                                       priorPdfGoodnessGain * priorGoodness^priorPdfGoodnessWeight
    %
    % The addition to 1 on the variability is probably no longer needed but the parameters have been tuned with
    % this in so it would just require more wotk to take it out.
    %
    % Input:
    %   mapInput.mapParams.priorPdfVariabilityWeight
    %   mapInput.mapParams.priorPdfGoodnessWeight
    %   mapInput.mapParams.priorPdfGoodnessGain
    %   mapData.variability(:)
    %   mapData.pdf.targetInfo(:).posteriorPdfInfo.priorGoodness
    %
    %
    % Output:
    %   priorWeight
    %*******************************************************************************

    function [priorWeight] = find_prior_weight (obj, targetIndex, mapData, mapInput)

        % Priors can be problematic for quiet targets so zero priorWeighting for quiet targets
        if (mapData.variability(targetIndex) < mapInput.mapParams.priorWeightVariabilityCutoff)
            priorWeight = 0.0;
            return;
        end
 
        % This part is due to the stellar variability w = (variability)^gain
        variabilityPart = (1 + mapData.variability(targetIndex))^(mapInput.mapParams.priorPdfVariabilityWeight);
 
        % Normalization by standard deviation or sqrt(median) requires greater weighting on the prior due to
        % different scaling factors (by orders of magnitude).
        priorGoodnessPart =  mapInput.mapParams.priorPdfGoodnessGain * ...
                obj.targetInfo(targetIndex).posteriorPdfInfo.priorGoodness ^ mapInput.mapParams.priorPdfGoodnessWeight;
 
        priorWeight = variabilityPart * priorGoodnessPart;
       
    end % find_prior_prior_weight

    %*******************************************************************************
    %% function [data] = rescale_data(data, range)
    %*******************************************************************************
    %
    % Scales data curve <data> so that max and min are same as range(1) and range(2)
    %

    function [data] = rescale_data (obj, data, range)

        % Offset the bottom to origin
        data = data - min(data);
 
        % rescale
        scale = (range(2) - range(1)) / (max(data) - min(data));
        data = scale * data;
 
        % offset to range minimum
        data = data + range(1);
    end

    %*******************************************************************************
    % function [goodnessPdfStruct] = find_goodness_pdf_value (obj, targetIndex, basisVectorIndex, ...
    %                                                           theta, mapData, mapInput)
    %*******************************************************************************
    %
    % Calculates the Goodness Metric Given a set of coefficients and the specified theta coefficient value for
    % the specified basis vector.
    %
    % This function is called in several different situation. Each situation is listed below. TODO: Consdier
    % rewriting this to be more elegent using some sort of subfunction. The code is also difficult to read.
    %
    % If TargetIndex is a single value and theta is an array then the goodness is found for all values of
    % theta.
    %
    % If targetIndex is an array but theta must be the same length.
    %
    % If basisVectorIndex = [] then find the goodness for all targets using the default coefficient values.
    %
    % Outputs:
    %   goodnessPdfStruct   -- [GoodnessStruct length(nTheta or nTargetIndex)]
    %       fields:
    %           keplerId          -- [int] for reference
    %           total             -- [double]
    %           correlation       -- [double]
    %           deltaVariability  -- [double]
    %           introducedNoise   -- [double]
    %
    %*******************************************************************************
    function [goodnessPdfStruct] = find_goodness_pdf_value (obj, targetIndex, basisVectorIndex, ...
                                                                theta, mapData, mapInput, doCalcEpGoodness)

    doNormalizeFlux = false;
    doSavePlots = false;

    % We are only generating statistics on targets MAP was applied to since only these have map coefficient
    % values
    % In the future we can consider adding in the robust fit targets if we want to
    correctedDataStruct = mapData.normTargetDataStruct;
    % Again, why Matab, why?!? There is no ambiguity in the following, please let me do it on one line
    coeffsAllTargets = [obj.targetInfo];
    coeffsAllTargets = [coeffsAllTargets.posteriorPdfInfo];
    coeffsAllTargets = [coeffsAllTargets.theta0];

    goodnessSingleStruct = struct( 'total', 0, 'correlation', 0, 'deltaVariability', 0, 'introducedNoise', 0);

    if (length(targetIndex) == 1 && ~isempty(theta) && length(theta) ~= 1)
        % We are calculating the goodness for one target for multiple theta values
        nGoodnessCalls = length(theta);
        goodnessPdfStruct = repmat(goodnessSingleStruct, [length(theta),1]);
    else
        % Calculating goodness for one or more targets but for just one theta value
        nGoodnessCalls = 1;
        goodnessPdfStruct = repmat(goodnessSingleStruct, [length(targetIndex),1]);
    end

    % Do not calculate CDPP
    gapFillConfigurationStruct = [];
    % Loop over all theta values if only being called on one targetIndex but multiple thetas
    % Otherwise this chunk of code is only called once
    for iGoodnessCall = 1 : nGoodnessCalls
        % Generate correctedDataStruct with specified coefficient values (thetas) for all targets
        % but with the specific theta value for this targetIndex.
        if (~isempty(basisVectorIndex))
            if (nGoodnessCalls > 1)
                coeffsAllTargets(basisVectorIndex, targetIndex) = theta(iGoodnessCall);
            else
                coeffsAllTargets(basisVectorIndex, targetIndex) = theta;
            end
        end
 
        fit = mapData.basisVectors * coeffsAllTargets;
        for iTarget = 1 : mapData.nTargets
            correctedDataStruct(iTarget).values = mapData.normTargetDataStruct(iTarget).values - fit(:, iTarget);
        end
 
        %***
        % Call the goodness metric function but only find the goodness for targetIndex indices.
        % NOTE: Raw and corrected array must only contain targets where a correction has been performed. Otherwise
        % bad statistics for the correlation part.
        % So, need to only calculate good for targetIndex indices in the set of obj.targetsMapAppliedTo.
        % And also keep the same order as in targetIndex.

        [~, reducedTargetList, targetIndexOrder] = intersect(find(obj.targetsMapAppliedTo), targetIndex);
        [~, sortOrder] = sort(targetIndexOrder);
        reducedTargetList = reducedTargetList(sortOrder);

        % NOTE: PDC Goodness Metric spike residual goodness is designed to use denoised single-scale basis vectors. Those are not always available here so so
        % bot pass any basis vectors.
        goodnessSubStruct = pdc_goodness_metric (mapData.normTargetDataStruct(obj.targetsMapAppliedTo), correctedDataStruct(obj.targetsMapAppliedTo), ...
            mapInput.cadenceTimes, [], mapInput.pdcModuleParameters, ...
            mapInput.goodnessMetricConfigurationStruct,  gapFillConfigurationStruct, doNormalizeFlux, doSavePlots, [], reducedTargetList, doCalcEpGoodness);
        % NOTE: goodnesSubStruct is of length targetsMapAppliedTo; We need to switch to targetIndex frame
        % Find the keplerIds for the targets we want (and in the correct order)
        keplerIds = [mapInput.targetDataStruct(targetIndex).keplerId];

        if (nGoodnessCalls > 1)
            goodnessPdfStruct(iGoodnessCall).keplerId               = goodnessSubStruct.keplerId;
            goodnessPdfStruct(iGoodnessCall).total            = goodnessSubStruct.total.value;
            goodnessPdfStruct(iGoodnessCall).correlation      = goodnessSubStruct.correlation.value;
            goodnessPdfStruct(iGoodnessCall).deltaVariability = goodnessSubStruct.deltaVariability.value;
            goodnessPdfStruct(iGoodnessCall).introducedNoise  = goodnessSubStruct.introducedNoise.value;
        else
            for iTarget = 1 : length(targetIndex)
                goodnessSubStructIndex = find([goodnessSubStruct.keplerId] == keplerIds(iTarget));

                if (length(goodnessSubStructIndex) ~= 1)
                    error('Internal indexing error');
                end

                goodnessPdfStruct(iTarget).keplerId         = goodnessSubStruct(goodnessSubStructIndex).keplerId;
                goodnessPdfStruct(iTarget).total            = goodnessSubStruct(goodnessSubStructIndex).total.value;
                goodnessPdfStruct(iTarget).correlation      = goodnessSubStruct(goodnessSubStructIndex).correlation.value;
                goodnessPdfStruct(iTarget).deltaVariability = goodnessSubStruct(goodnessSubStructIndex).deltaVariability.value;
                goodnessPdfStruct(iTarget).introducedNoise  = goodnessSubStruct(goodnessSubStructIndex).introducedNoise.value;
            end
        end
    end

    end % find_goodness_pdf_value

    %*******************************************************************************
    % function [] = revert_to_old_fits_if_goodness_no_better_after_itarator (initialValues)
    %*******************************************************************************
    %
    % Checks the goodness values after running the goodness metric iterator. For targets where the goodness has not improved revert to the initial coefficient
    % values.
    %
    % This re-runs the maximizer instead of using saved values. This is so that all bookkeeping is redone minimizing the chances that future improvements are
    % not included in the fit.
    %
    % Input:
    %   initialValues   -- [struct]
    %       .badTargets         -- [int array] full list of target indices that we attempted goodness iterations on
    %       .coeffs             -- [float matrix(nBasisVector,nBadTargets)] the initial coefficient values before goodness iterations 
    %       .goodnessPdcStruct  -- [struct] the goodness values before goodness iterations
    %       .priorWeight        -- [float array] the prior weight values before goodness iterations
    %
    % Output:
    %   obj.targetInfo(badTargets).fits.posterior
    %
    %*******************************************************************************

    function [] = revert_to_old_fits_if_goodness_no_better_after_itarator (obj, initialValues, mapData, mapInput)

        component = 'maximizePosterior';
 
        initialBias = 0.025; % Bias toward initial prior weighting goodness in goodness units
 
        % Get the current goodness values on the initial target list
        % Matlab can't do this asignment on one line : (
        coeffs = [obj.targetInfo];
        coeffs = [coeffs.fits];
        coeffs = [coeffs.posterior];
        coeffs = [coeffs.basisVectorCoeff];
        for iTarget = 1  : length(initialValues.badTargets)
            % Theta0 is used by find_goodness_pdf_value
            obj.targetInfo(initialValues.badTargets(iTarget)).posteriorPdfInfo.theta0 = coeffs(:,initialValues.badTargets(iTarget));
        end
             
        doCalcEpGoodness = false;
        currentGoodnessPdfStruct = obj.find_goodness_pdf_value (initialValues.badTargets, [], [], mapData, mapInput, doCalcEpGoodness);
 
        % Parity check, make sure Kepler IDs line up!
        if (any ([initialValues.goodnessPdfStruct.keplerId] ~= [currentGoodnessPdfStruct.keplerId]))
            error ('Bookeepking error during Goodness Metric Iterations');
        end
 
        % Compare to current to initial goodness values and pick which did not improve
        targetsThatAreNotBetter = [currentGoodnessPdfStruct.total] < [initialValues.goodnessPdfStruct.total] + initialBias;
 
        if (any(targetsThatAreNotBetter))
            
            string = [mapInput.debug.runLabel, ...
                ': Reverting to non-goodness iterating prior weight values for ', num2str(sum(targetsThatAreNotBetter)), ' targets.'];
            mapInput.debug.display(component, string);
 
            % Revert back to non-iterated prior weighing for targets that did not improve
            for badTargetIndex = 1 : length(targetsThatAreNotBetter)
                if (targetsThatAreNotBetter(badTargetIndex))
                    iTarget =  initialValues.badTargets(badTargetIndex);
                    obj.targetInfo(iTarget).posteriorPdfInfo.priorWeight = initialValues.priorWeight(badTargetIndex);

                    % Maximize Posterior PDC one more time to ensure all internal bookkeeping is kept up to date. 
                    % Simply inserting saved values introduces the risk that some new implementation is not included in the fit
                    basisVectorInitialRanges = obj.targetInfo(iTarget).posteriorPdfInfo.basisVectorInitialRanges;
                    pdf = @(theta, basisVectorIndex) mapData.pdf.posteriorPdf(iTarget, basisVectorIndex, theta, mapData, mapInput);
                    obj.targetInfo(iTarget).fits.posterior = obj.maximize_pdf (pdf, iTarget, basisVectorInitialRanges, mapData, mapInput, component);
                end
            end
  
        end

    end % function revert_to_old_fits_if_goodness_no_better_after_itarator 
    
    %*******************************************************************************
    % If goodness is not improving then stop iterating.
    function [stopWorkingOnThisTarget] = check_if_goodness_improved_with_iterator ...
                    (obj, previousGoodnessPdfStruct, badTargets, stopWorkingOnThisTarget, mapData, mapInput)

        component = 'maximizePosterior';
 
        % Bias toward previous goodness in goodness units
        previousBias = 0.002; % Something small -- we are just looking for any improvement at all
 
        % Get the current goodness values on the bad target list
        % Matlab can't do this asignment on one line : (
        coeffs = [obj.targetInfo];
        coeffs = [coeffs.fits];
        coeffs = [coeffs.posterior];
        coeffs = [coeffs.basisVectorCoeff];
        for iTarget = 1  : length(badTargets)
            % Theta0 is used by find_goodness_pdf_value
            obj.targetInfo(badTargets(iTarget)).posteriorPdfInfo.theta0 = coeffs(:,badTargets(iTarget));
        end
             
        doCalcEpGoodness = false;
        currentGoodnessPdfStruct = obj.find_goodness_pdf_value (badTargets, [], [], mapData, mapInput, doCalcEpGoodness);
 
        % Compare current to previous goodness values and pick which did not improve
        targetsThatAreNotBetter = false(length(badTargets), 1);
        for iTarget = 1 : length(badTargets)
            %The previous iteration used a larger number of targets so we need to find the corresponding entry in the large array
            previousGoodnessPdfStructIndex = [previousGoodnessPdfStruct.keplerId] == currentGoodnessPdfStruct(iTarget).keplerId;
            if (length(sum(previousGoodnessPdfStructIndex)) ~= 1)
                error ('Bookeepking error during Goodness Metric Iterations');
            end
            targetsThatAreNotBetter(iTarget) = currentGoodnessPdfStruct(iTarget).total < ...
                    previousGoodnessPdfStruct(previousGoodnessPdfStructIndex).total + previousBias;
        end
 
        stopWorkingOnThisTarget(badTargets(targetsThatAreNotBetter)) = true;

    end % function check_if_goodness_improved_with_iterator 
 
    %*******************************************************************************
    % plots the centroid priors and raDecMag priors versus robust fit coeffs

    function [] = plot_priors (obj, mapInput, mapData)

        component = 'generatePrior';

        centroidStruct = [obj.targetInfo.priorPdfInfo];
        centroidStruct = [centroidStruct.centroidPrior];

        centroidPriorAvailable = false(mapData.nTargets,1);
        centroidPriors = zeros(mapData.nBasisVectors, mapData.nTargets);
        for iTarget = 1 : mapData.nTargets
            centroidPriorAvailable(iTarget) = ~isempty(obj.targetInfo(iTarget).priorPdfInfo.centroidPrior.coeffs);
            if (centroidPriorAvailable(iTarget))
                centroidPriors(:,iTarget) = centroidStruct(iTarget).coeffs;
            end
        end

        % RaDecMag prior is not saved so find it here
        % TODO: maximizing the prior every time I call this is obviously slow, store the raDecMag priors 
        % Find the basis vector ranges from the robust fit coefficient ranges
        basisVectorInitialRanges = obj.find_basis_vector_range(mapData);
        % Must save in the fits struct for the prior goodness calculation to use it!
        raDecMagPriors = zeros(mapData.nBasisVectors, mapData.nTargets);
        mapInput.debug.display(component, 'Finding raDecMag prior for plotting priors...');
        for iTarget = 1 : mapData.nTargets
            if (~obj.targetsMapAppliedTo(iTarget))
                continue;
            end
            pdf = @(theta, basisVectorIndex) mapData.pdf.priorPdf(iTarget, basisVectorIndex, ...        
                                                             theta, mapData, mapInput, 'raDecMag');
            raDecMagPriorFitStruct = obj.maximize_pdf (pdf, iTarget, basisVectorInitialRanges, mapData, mapInput, component);
            raDecMagPriors(:,iTarget) = [raDecMagPriorFitStruct.basisVectorCoeff];
        end
        mapInput.debug.display(component, 'Finished finding raDecMag prior for plotting priors.');

        % Plot relative to robust fit coeffs
        robustFitCoeffs = mapData.robustFit.coefficients; % nBasisVector x nTargets
        % First four basis vectors
        figure;
        subplot(2,2,1);
        plot(robustFitCoeffs(1,obj.targetsMapAppliedTo), raDecMagPriors(1,obj.targetsMapAppliedTo), '*b');
        hold on;
        plot(robustFitCoeffs(1,centroidPriorAvailable), centroidPriors(1,centroidPriorAvailable), '*r');
        legend('RaDecMag Priors', 'Centroid Priors');
        xlabel('Robust Coeffs');
        ylabel('Prior Coeffs');
        title('Basis Vector 1');
        subplot(2,2,2);
        plot(robustFitCoeffs(2,obj.targetsMapAppliedTo), raDecMagPriors(2,obj.targetsMapAppliedTo), '*b');
        hold on;
        plot(robustFitCoeffs(2,centroidPriorAvailable), centroidPriors(2,centroidPriorAvailable), '*r');
        xlabel('Robust Coeffs');
        ylabel('Prior Coeffs');
        title('Basis Vector 2');
        subplot(2,2,3);
        plot(robustFitCoeffs(3,obj.targetsMapAppliedTo), raDecMagPriors(3,obj.targetsMapAppliedTo), '*b');
        hold on;
        plot(robustFitCoeffs(3,centroidPriorAvailable), centroidPriors(3,centroidPriorAvailable), '*r');
        xlabel('Robust Coeffs');
        ylabel('Prior Coeffs');
        title('Basis Vector 3');
        subplot(2,2,4);
        if (mapData.nBasisVectors > 3)
            plot(robustFitCoeffs(4,obj.targetsMapAppliedTo), raDecMagPriors(4,obj.targetsMapAppliedTo), '*b');
            hold on;
            plot(robustFitCoeffs(4,centroidPriorAvailable), centroidPriors(4,centroidPriorAvailable), '*r');
            xlabel('Robust Coeffs');
            ylabel('Prior Coeffs');
            title('Basis Vector 4');
        end

        if (mapData.nBasisVectors > 4)
            % Second four basis vectors
            figure;
            subplot(2,2,1);
            plot(robustFitCoeffs(5,obj.targetsMapAppliedTo), raDecMagPriors(5,obj.targetsMapAppliedTo), '*b');
            hold on;
            plot(robustFitCoeffs(5,centroidPriorAvailable), centroidPriors(5,centroidPriorAvailable), '*r');
            legend('RaDecMag Priors', 'Centroid Priors');
            xlabel('Robust Coeffs');
            ylabel('Prior Coeffs');
            title('Basis Vector 5');
            subplot(2,2,2);
            if (mapData.nBasisVectors > 5)
                plot(robustFitCoeffs(6,obj.targetsMapAppliedTo), raDecMagPriors(6,obj.targetsMapAppliedTo), '*b');
                hold on;
                plot(robustFitCoeffs(6,centroidPriorAvailable), centroidPriors(6,centroidPriorAvailable), '*r');
                xlabel('Robust Coeffs');
                ylabel('Prior Coeffs');
                title('Basis Vector 6');
            end
            subplot(2,2,3);
            if (mapData.nBasisVectors > 6)
                plot(robustFitCoeffs(7,obj.targetsMapAppliedTo), raDecMagPriors(7,obj.targetsMapAppliedTo), '*b');
                hold on;
                plot(robustFitCoeffs(7,centroidPriorAvailable), centroidPriors(7,centroidPriorAvailable), '*r');
                xlabel('Robust Coeffs');
                ylabel('Prior Coeffs');
                title('Basis Vector 7');
            end
            subplot(2,2,4);
            if (mapData.nBasisVectors > 7)
                plot(robustFitCoeffs(8,obj.targetsMapAppliedTo), raDecMagPriors(8,obj.targetsMapAppliedTo), '*b');
                hold on;
                plot(robustFitCoeffs(8,centroidPriorAvailable), centroidPriors(8,centroidPriorAvailable), '*r');
                xlabel('Robust Coeffs');
                ylabel('Prior Coeffs');
                title('Basis Vector 8');
            end
        end

    end % function plot_priors

    %********************************************************************************
    % We need to only set the values if they exist in mapPdfStruct. Using assert_field converts the
    % object into a struct, so create new function so keep as object
    function obj = assert_property (obj, struct, field, value, verbosity)

        struct = assert_field (struct, field, value, verbosity);

        obj.(field) = struct.(field);

    end

end % private methods

methods (Static=true)

    %*******************************************************************************
    % fits the Robust Fit Coefficients using aperture information and target centroids derived from the motion
    % polynomials.
    %
    % Inputs:
    %   apertureStruct          -- [struct array(nTargets)] Contains the optimum aperture and centroid information
    %       .optimalAperture
    %           .rows               -- [int array(nPixelsInAperture)] The row indices of the optimum aperture pixels (one-based)
    %           .columns            -- [int array(nPixelsInAperture)] The column indices of the optimum aperture pixels (one-based)
    %       .centroid
    %           .row                -- [double] row poisition of the motion polynomia' derived centroid in units of pixels (one-based)
    %           .column             -- [double] column position of the motion polynomia' derived centroid in units of pixels (one-based)
    %   robustFitCoefficients   -- [double matrix(nTargets x nBasisVectors)] The robust fit coefficients
    %
    % Outputs:
    %   priorEstimates          -- [double matrix(nTargets x nBasisVectors] The prior fit estimates for each target
    %   targetsWithEstimates    -- [logical array(nTargets)] Targets where priors were obtained
    %
    
    function [priorEstimates, targetsWithEstimates] = estimate_priors_using_centroids_and_apertures(apertureStruct, robustFitCoefficients)

        nBasisVectors=size(robustFitCoefficients,2);

        %% Condition Centroids
        warning('off','stats:statrobustfit:IterationLimit');
        nTargets=length(apertureStruct);
        centroids=[apertureStruct(:).centroid];
        rowCentroids=[centroids(:).row]';
        columnCentroids=[centroids(:).column]';
        rowDeltaFromMean=(rowCentroids-mean(rowCentroids(~isnan(rowCentroids))))/512.;
        columnDeltaFromMean=(columnCentroids-mean(columnCentroids(~isnan(columnCentroids))))/550.;
        
        %% Construct Design Matrix Using Apertures and Centroids
        gridSize=5;
        numEdgeParameters=gridSize*(gridSize+1)*4;
        edgeToCentroidMatrix=zeros(nTargets,numEdgeParameters);
        %%
        for iTarget = 1 : nTargets
            edgeToCentroidMatrix(iTarget,:) = mapPdfClass.construct_aperture_state_vector(apertureStruct(iTarget), gridSize);
        end

        %%
        % Condition matrix and assemble design matrix
        lowIndex=nTargets-sum(edgeToCentroidMatrix==0)<10;
        targetOK=sum(edgeToCentroidMatrix.^2,2)~=0 & sum(edgeToCentroidMatrix(:,lowIndex).^2,2)==0;
        okTargetCount=sum(targetOK);

        % If no targets are within maximum aperture return (I think, not sure exactly, this is Jeff K code)
        if (okTargetCount == 0)
            priorEstimates=zeros(nTargets,nBasisVectors);
            targetsWithEstimates = targetOK;
            return;
        end 

        maskZeros=edgeToCentroidMatrix~=0;
        meanOfMatrixColumns=sum(edgeToCentroidMatrix)./max(sum(maskZeros),1);
        edgeToCentroidMatrixMeanAdjusted=(edgeToCentroidMatrix-repmat(meanOfMatrixColumns,nTargets,1)).*maskZeros;
        edgeToCentroidMatrixExpanded=[edgeToCentroidMatrixMeanAdjusted, ...
            repmat(rowDeltaFromMean,1,numEdgeParameters).*edgeToCentroidMatrixMeanAdjusted, ...
            repmat(columnDeltaFromMean,1,numEdgeParameters).*edgeToCentroidMatrixMeanAdjusted];
        edgeModelMatrixNew=edgeToCentroidMatrixExpanded(targetOK,:);
        
        rankOfMatrix=rank(edgeModelMatrixNew);
        [leftVectorsU, singularValuesS, rightVectorsV]=svds(edgeModelMatrixNew,rankOfMatrix);
        matrixSize=find(abs(diff(diag(singularValuesS)/singularValuesS(1,1)<10^-3))~=0);
        designMatrix=[ones(okTargetCount,1),rowDeltaFromMean(targetOK),columnDeltaFromMean(targetOK),leftVectorsU(:,1:matrixSize)];

        % Initialize result
        priorEstimates=zeros(nTargets,nBasisVectors);
        
        % designMatrix must be large enough for robustFit to run. 
        [n,p] = size(designMatrix);
        if (n <= p+1)
            targetsWithEstimates = false(size(targetOK));
            return;
        end
        
        % Condition robust fit coefficients for each basis vector
        meanCoefficients=mean(robustFitCoefficients(targetOK,:));
        robustFitCoefficientsMinusMeans=robustFitCoefficients(targetOK,:)-repmat(meanCoefficients,sum(targetOK),1);
        
        % Fit for coefficients for each basis vector choosing method (robust or
        % regress) that gives the best median abs. dev.
        
        for iBasisVector=1:nBasisVectors
            
            [robustFitParameters,robustFitStats]         = robustfit(designMatrix,robustFitCoefficientsMinusMeans(:,iBasisVector),'bisquare',4.685,'off');
            [regressFitParameters,~,residualsRegressFit] = regress(robustFitCoefficientsMinusMeans(:,iBasisVector),designMatrix);
            priorsFromRobustFit   = designMatrix*robustFitParameters+meanCoefficients(iBasisVector);
            priorsFromRegressFit  = designMatrix*regressFitParameters+meanCoefficients(iBasisVector);
            madOfRobustResiduals  = mad(robustFitStats.resid,1);
            madOfRegressResiduals = mad(residualsRegressFit,1);
            if madOfRobustResiduals < madOfRegressResiduals
                priorEstimates(targetOK,iBasisVector) = priorsFromRobustFit;
            else
                priorEstimates(targetOK,iBasisVector) = priorsFromRegressFit;
            end
            
        end
        
        targetsWithEstimates = targetOK;
        warning('on','stats:statrobustfit:IterationLimit');

    end

    %*******************************************************************************
    % construct_aperture_state_vector 
    %   constructs a row of the aperture model design matrix
    %   This function accepts a structure 'apertureStruct' and contructs an output row
    %   vector 'apertureStateVector' which linearly models any parameter which
    %   depends on changing centroid and focus, e.g. the coefficients of
    %   cotrending basis vectors.
    %
    % Inputs:
    %   apertureStruct          -- [struct] Contains the optimum aperture and centroid information for ONE target
    %       .optimalAperture
    %           .rows               -- [int array(nPixelsInAperture)] The row indices of the optimum aperture pixels (one-based)
    %           .columns            -- [int array(nPixelsInAperture)] The column indices of the optimum aperture pixels (one-based)
    %       .centroid
    %           .row                -- [double] row poisition of the motion polynomia' derived centroid in units of pixels (one-based)
    %           .column             -- [double] column position of the motion polynomia' derived centroid in units of pixels (one-based)
    %   gridSize                -- [int] square grid size (e.g. 5x5 pixel grid) 
    %
    % Outputs:
    %   apertureStateVector
    %
    
    function apertureStateVector = construct_aperture_state_vector(apertureStruct, gridSize)

        %%  Initialization
        rows    = apertureStruct.optimalAperture.rows;
        columns = apertureStruct.optimalAperture.columns;
        centroidRow     = apertureStruct.centroid.row+0.5;
        centroidColumn  = apertureStruct.centroid.column+0.5;
        apertureStateVector = zeros(1, gridSize*(gridSize+1)*4);
        apertureNotTooLarge = size(rows,1)<=gridSize^2 & size(rows,1)>0;
        centroidsAreNumbers = ~isnan(centroidRow) & ~isnan(centroidColumn);
        
        if apertureNotTooLarge & centroidsAreNumbers
        
        %%  Identify aperture edges
        %    This algorithm assembles a list of all the edge coordinates of the 
        %    pixels in the optimal aperture and then identifies the aperture edge 
        %    as the set of pixel edges which only occur once in the list
        
            edgeArray=[columns rows+0.5; columns+1 rows+0.5; columns+0.5 rows; columns+0.5 rows+1];
            [uniqueEdgeElements,~,elementIndex]=unique(edgeArray,'rows');
        
            edgeTally=[uniqueEdgeElements';arrayfun(@(x) sum(elementIndex==x), 1:length(uniqueEdgeElements))];
            apertureEdges=edgeTally(1:2,edgeTally(3,:)==1);
            edgeCount=size(apertureEdges,2);
        
        
        %%  Construct state vector for the given aperture
        %    This algorithm populates the elements of a vector containing 
        %    coordinates of all the pixel edges in a gridSize x gridSize 
        %    pixel grid. Generally, gridSize should be odd and the center pixel is
        %    the one containing the target centroid.
        
            offset=3;
            columnIndex     = floor(apertureEdges(1,:)-floor(centroidColumn)+offset);
            rowIndex        = floor(apertureEdges(2,:)-floor(centroidRow)+offset);
            coordinateIndex = floor(2*mod(apertureEdges(1,:),1) + 1);
            apertureFitsInGrid = min(rowIndex)>0 & min(columnIndex)>0 & ...
                max(rowIndex    - (coordinateIndex==2))<gridSize+1 & ...
                max(columnIndex - (coordinateIndex==1))<gridSize+1 ;
        
            if apertureFitsInGrid
                
                for indexOfEdge=1:edgeCount
                    gridColumnSize=gridSize+2-coordinateIndex(indexOfEdge);
                    gridRowSize=gridSize+coordinateIndex(indexOfEdge)-1;
                    indicesOfEdgeInStateVector= ...
                        sub2ind( ...
                        [gridColumnSize,gridRowSize,2,2], ...
                        columnIndex(indexOfEdge([1,1])), ...
                        rowIndex(indexOfEdge([1,1])), ...
                        coordinateIndex(indexOfEdge([1,1])), ...
                        1:2);
                    apertureStateVector(indicesOfEdgeInStateVector)= ...
                        apertureEdges(:,indexOfEdge)'-[centroidColumn,centroidRow];
                end
            
            end
        
        end

    end
    %*******************************************************************************
    %
    % For testing purposes this will load the optimum aperture for all targets based on retrieve_tad and the hard coded list of target tables
    %
    % Output:
    %   optimalApertures    -- [struct array(nTargets)]
    %       .rows           -- [double array(nPixelsInAperture)] absolute row indices for pixels in aperture (one-based)
    %       .columns        -- [double array(nPixelsInAperture)] absolute column indices for pixels in aperture (one-based)
    %

    function [optimalApertures] = load_optimum_aperture_information (mapInput, mapData)

        if (isdeployed)
            error ('load_optimum_aperture_information: this function is for testing purposes but this is a deployed pipeline run');
        end

        % hard coded list for testing purposes
        targetListTable = {'quarter1_spring2009_lc_v2', ...
                           'quarter2_summer2009_lc', ...
                           'quarter3_fall2009_lc_v3', ...
                           'quarter4_winter2009_lc', ...
                           'quarter5_spring2010_lc_v2', ...
                           'quarter6_summer2010_trimmed_v3_lc', ...
                           'quarter7_fall2010_trimmed_v4_lc', ...
                           'quarter8_winter2010_trimmed_lc', ...
                           'quarter9_spring2011_trimmed_lc', ...
                           'quarter10_summer2011_trimmed_lc', ...
                           'quarter11_fall2011_trimmed_lc', ...
                           'quarter12_winter2011_trimmed_v5_lc', ...
                           'quarter13_spring2012_trimmed_lc', ...
                           'quarter14_summer2012_trimmed_lc', ...
                           'quarter15_fall2012_trimmed_lc', ...
                           'quarter16_winter2012_trimmed_lc', ...
                           'quarter17_spring2013_trimmed_lc'};

        if (mapInput.taskInfoStruct.quarter == 0)
            targetList = 'cdpp_v1_verification_lc';
        else
            targetList = targetListTable(mapInput.taskInfoStruct.quarter);
        end

        % Call sandbox tool with appropriate mod.out and target table
        % Ony do this if tadStruct is not already stored in task directory
        filename = ['tadStruct_q', num2str(mapInput.taskInfoStruct.quarter), '_', num2str(mapInput.taskInfoStruct.ccdModule), '.', ...
                    num2str(mapInput.taskInfoStruct.ccdOutput), '.mat'];
        if (exist(filename, 'file'))
            disp(['Loading tad information from file ', filename]);
            load(filename);
        else
            tadStruct = retrieve_tad(mapInput.taskInfoStruct.ccdModule, mapInput.taskInfoStruct.ccdOutput, targetList);
            % Save tadStruct so it can be loaded from file next time
            intelligent_save(filename, 'tadStruct');
        end

        
        % Make sure the target order of tadStruct is the same as in targetDataStruct
        [isAMember, loc] = ismember([tadStruct.targets.keplerId], [mapData.normTargetDataStruct.keplerId]');
        if(sum(isAMember) ~= mapData.nTargets)
            error('load_optimum_aperture_information: tadStruct does not appear to contain all targets on mod.out');
        end
        tadApertures = tadStruct.targets(loc(loc ~=0));

        optimalApertures = mapPdfClass.construct_absolute_optimum_apertures (tadApertures);
    end

    %*******************************************************************************
    % optimalApertures = construct_absolute_optimum_apertures (tadApertures)
    %
    % The optimum aperture information obtained from TAD is given as reference pixels and offsets. But the optimum aperture priors information functions
    % requires absolute pixel values for the optimum aperture. This function performs the conversion.
    %
    function optimalApertures = construct_absolute_optimum_apertures (tadApertures)

        % We need row and column numbers for each target optimum aperture
        optimalApertures = repmat(struct('rows', [], 'columns', []), [length(tadApertures),1]);
        for iTarget = 1 : length(tadApertures)
            nPixelsInAperture = length(tadApertures(iTarget).offsets);
            optimalApertures(iTarget).rows    = nan(nPixelsInAperture,1);
            optimalApertures(iTarget).columns = nan(nPixelsInAperture,1);
            for iPixel = 1 : nPixelsInAperture 
                % TAD data is zero-based! Convert to one-based
                optimalApertures(iTarget).rows(iPixel)    = tadApertures(iTarget).offsets(iPixel).row    + tadApertures(iTarget).referenceRow    + 1;
                optimalApertures(iTarget).columns(iPixel) = tadApertures(iTarget).offsets(iPixel).column + tadApertures(iTarget).referenceColumn + 1;
            end
        end

    end

    %********************************************************************************
    % function  obj = construct_from_struct (pdf)
    %
    % This will construct the mapPdfObject using the data stored in mapPdfStruct which was saved
    % in mapResultsStruct.
    %

    function obj = construct_from_struct (mapPdfStruct)

        if (~isstruct(mapPdfStruct))
            error('mapPdfStruct does not appear to be a struct!');
        end

        verbosity = true;

        % First create a "naked" mapResultsObject with empty properties
        obj = mapPdfClass();

        % assert_property is used here since new fields added mapResultsClass will not exists in older
        % versions. So, set to default value of just empty. If it exists then set the object propertie to the struct field value.
       %obj = obj.assert_property (mapPdfStruct, 'USEONLYTUSFORPRIOR', [], verbosity);
       %obj = obj.assert_property (mapPdfStruct, 'COMPAREPRIORTOCONDITIONALREWEIGHTING', [], verbosity);
        obj = obj.assert_property (mapPdfStruct, 'targetsMapAppliedTo', [], verbosity);
        obj = obj.assert_property (mapPdfStruct, 'targetsMapWasAttempted', [], verbosity);
        obj = obj.assert_property (mapPdfStruct, 'targetInfo', [], verbosity);
        obj = obj.assert_property (mapPdfStruct, 'defaultCentroidPriorSigmas', [], verbosity);

    end


end % Static methods

end % classdeff mapPdfClass
