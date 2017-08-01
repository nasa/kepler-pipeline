function cleanTargetStruct = clean_target_83( obj, targetIdx )
%**************************************************************************
% function cleanTargetStruct = clean_target( obj, targetIdx )
%**************************************************************************
% This is a copy of clean_target.m, revision 48430 (The revision used for
% 8.3 V&V). It is currently used as a reference point for regression
% testing. The following changes were made for compatibility: 
%
%   (1) the function name was changed to 'clean_target_83' 
%   (2) The variable 'excludeCadences' was renamed 'excludeIndicators' 
%
%**************************************************************************
% Detect and clean cosmic rays from a single designated target using the
% following method:
%
% 1. Fill gaps, stabilize variance, and lightly detrend all pixel time
%    series.
% 2. Derive row and column position time series from motion polynomial
%    struct and lightly detrend.   
% 3. Derive focus proxy time series from motion polynomial struct and
%    lightly detrend.
% 4. Identify harmonics in *target* time series. We pass gap indicators to
%    the harmonic identifier so that results don't depend on the gap
%    filling in step 1.
%
%    Frequencies identified = {w1, w2, ... , wM}
%
% For each segment:
% ----------------
%    5. Simultaneously fit and remove harmonics identified in step 4,
%       motion, and focus from the lightly detrended *pixel* time series using
%       the following design matrix:
%
%       D = [ cos(w1*t1) sin(w1*t1) ... cos(wM*t1) sin(wM*t1) dx1 dy1 ds1 ]
%           [ cos(w1*t2) sin(w1*t2) ... cos(wM*t2) sin(wM*t2) dx2 dy2 ds2 ]
%           [     :          :              :          :       :   :   :  ]
%           [ cos(w1*tN) sin(w1*tN) ... cos(wM*tN) sin(wM*tN) dxN dyN dsN ]
% 
%       Solve y = D*a in the least squares sense by computing the
%       pseudoinverse of D. 
%
%           a = pseudoinv(D)*y
%    
%       Compute the residual. 
%
%           r = y - D*a
%
%    For each pixel:
%    --------------
%       6. Estimate an AR model for the residual time series. The Matlab function
%          arburg(), which implements the Burg algroithm, is used to
%          estimate AR model parameters for each output time series from
%          step 5.
%       7. Compute the prediction residual at each time step. Since CR hits
%          are frequent and violate model assumptions, we replace outliers
%          above a low threshold for the purposes of prediction. A higher
%          threshold is used later in the detection step.
%       8. Determine an appropriate detection threshold and apply it to the
%          residual.
%       9. Replace values at each cosmic ray cadence with the following:
%          cleaned = (predicted value + while noise) x (pixel uncertainty)
%
% NOTES:
%     Corrections are additive. That is, 
%         correctedFlux = uncorrectedFlux + correction
%
%     Gaps are left filled.
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
    cleanTargetStruct = obj.targetArray(targetIdx);    
    pixelArray        = cleanTargetStruct.pixelDataStruct;
    nPixels           = numel(pixelArray);
    
    %----------------------------------------------------------------------
    % 1. Fill gaps and stabilize variance for all pixel time series
    %----------------------------------------------------------------------
    [fullPixelTsArr, fullTrendMat] = obj.get_conditioned_time_series( targetIdx );
        
    
    %----------------------------------------------------------------------
    % 4. Identify harmonics in *target* time series. We pass gap indicators 
    %    to the harmonic identifier so that results don't depend on the gap
    %    filling in step 1.
    %----------------------------------------------------------------------
    % This option was removed from the set of configuration params and will 
    % probably never be used. It is left here as a hard-coded flag in case
    % we ever want to experiment with it.
    identifyHarmonicsBySegment = false;     

    harmonicSamplingTimes = zeros(obj.nCadences, 1);
    targetFlux = sum([fullPixelTsArr.ts], 2);
    gapIndicators = any([fullPixelTsArr.gaps], 2);
    if ~identifyHarmonicsBySegment
        harmonicModelStruct = obj.identify_harmonics(targetFlux, gapIndicators);
        harmonicFrequencies = harmonicModelStruct.harmonicFrequenciesInHz;
        harmonicSamplingTimes = harmonicModelStruct.samplingTimesInSeconds; 
    end
    
    
    %----------------------------------------------------------------------
    % Loop for each segment
    %----------------------------------------------------------------------
    % Determine Segments.
    % This assumes long gaps are not at or near the first or last cadences.
    [startIndices, gapLengths] = find_gaps( gapIndicators );
    ind = find(gapLengths > obj.params.gapLengthThreshold);
    segmentStarts = vertcat(1, startIndices(ind) + gapLengths(ind));
    segmentEnds = vertcat(startIndices(ind) - 1, obj.nCadences);
    nSegments = length(segmentStarts);
    
    for segmentIter = 1:nSegments
        if obj.debugStruct.flags.verbose
            fprintf('SEGMENT %d of %d\n', segmentIter, nSegments);
        end
        
        segmentCadences  = segmentStarts(segmentIter):segmentEnds(segmentIter);
        nSegmentCadences = length(segmentCadences);
                    
        
        %------------------------------------------------------------------
        % 5. Model the lightly detrended *pixel* time series as a linear
        %    combination of (1) the harmonics identified in step 4, (2)
        %    row and column target position time series, and (3) the focus
        %    proxy time series. 
        %------------------------------------------------------------------   
        pixelTsMat     = zeros(nSegmentCadences, nPixels);
        pixelGapMat    = zeros(nSegmentCadences, nPixels);
        
        % Extract time series segment from full time series.
        for i = 1:nPixels
            pixelTsMat(:, i)  = fullPixelTsArr(i).ts(segmentCadences);
            pixelGapMat(:, i) = fullPixelTsArr(i).gaps(segmentCadences);
        end
        
        % Construct the design matrix.
        if identifyHarmonicsBySegment
            segmentTargetFlux    = sum(pixelTsMat, 2);
            segmentGapIndicators = any(pixelGapMat, 2);
            harmonicModelStruct  = obj.identify_harmonics(segmentTargetFlux, segmentGapIndicators);
            harmonicFrequencies  = harmonicModelStruct.harmonicFrequenciesInHz;
            harmonicSamplingTimes(segmentCadences) = harmonicModelStruct.samplingTimesInSeconds; 
        end
        
        designMat = obj.build_design_matrix(targetIdx, segmentCadences, ...
                                            harmonicFrequencies, ...
                                            harmonicSamplingTimes);
        
        % Assess the design matrix and handle the following cases:
        % 1) The matrix is empty, in which case we do nothing.
        % 2) The matrix is poorly conditioned or has low rank, in which 
        %    case we use SVD to compute a pseudoinverse.
        % 3) The matrix is well-conditioned.
        if isempty(designMat) || any(~isfinite(designMat(:)))   
            hmfModelMat = zeros(size(pixelTsMat));
        else
            if (cond(designMat) >= 1/eps) || (rank(designMat) < min(size(designMat)))
                lsCoeffMat = obj.fit_by_svd(designMat, pixelTsMat);
            else
                lsCoeffMat = designMat \ pixelTsMat;
            end
            hmfModelMat = designMat * lsCoeffMat;
        end
        
        hmfResidualMat = pixelTsMat - hmfModelMat;
        
        
        %------------------------------------------------------------------
        % 6. Estimate components of the residual from step 5. The residual
        %    is modeled as the sum of a dominant autoregressive process and
        %    a outlier process. The outlier process comprises a cosmic ray
        %    process and other components that do not coform to the AR
        %    model: R = AR(p) + c + e. The cosmic ray signal c is
        %    characterized by Poisson-distributed arrival times and
        %    per-event energy distribution described in KSOC-21008-001
        %    (Algorithm Theoretical Basis Document).
        %------------------------------------------------------------------
        predictionMat     = hmfResidualMat;
        innovationMat     = zeros(nSegmentCadences, nPixels);
        outlierIndicators = false(nSegmentCadences, nPixels);
        detectThresholds  = repmat(obj.params.detectionThreshold, [1, nPixels]);
        
        % Limit the AR model order to approximately one quarter the length
        % of the segment, but never less than 1.  
        arOrder = obj.params.arOrder;
        arOrderLimit = max([1, fix(nSegmentCadences / 4)]);
        if arOrder > arOrderLimit
            arOrder = arOrderLimit;
        end
        
        % Do AR prediction and make a rough estiamte of the cosmic ray
        % signal.
        for i = 1:nPixels
            [predictionMat(:,i), innovationMat(:,i), outlierIndicators(:,i)] = ...
                obj.predict_arburg( hmfResidualMat(:,i), arOrder, ...
                                    detectThresholds(i), pixelGapMat(:,i));              
        end
 
        % Estimate the mean and standard deviation of the WGN innovation.
        % If the model fits the data well and if the flux uncertainties
        % used for variance normalization can be trusted, then the
        % recovered innovation should have a mean near zero and and
        % variance near 1.0.
        innovationMean  = mean(innovationMat);
        innovationSigma = std(innovationMat);

        % Separate the outlier signal into large- and fine-scale
        % components.
        %
        % At this point innovationMat contains zeros at outlier locations.
        % This is because we replace outliers with the predicted value plus
        % the innovation mean, which is zero. The code below explicitly
        % adds these zeros to the predictions, which is currently
        % unnecessary, but will correctly handle any future changes to the
        % way innovation outliers are replaced (we may chose to replace
        % them with random values).
        outlierMat                      = zeros(size(hmfResidualMat)); 
        outlierMat(outlierIndicators)   = hmfResidualMat(outlierIndicators) - (predictionMat(outlierIndicators) + innovationMat(outlierIndicators)); 
        impulsiveOutlierMat             = outlierMat - medfilt1(outlierMat, obj.params.shortMedianFilterLength); % Median filter along columns.
        innovationPlusImpulsiveOutliers = innovationMat + impulsiveOutlierMat;
                    
        if obj.debugStruct.flags.plotInnovationPlusOutliers
            for i = 1:nPixels
                INNOV_COLOR = [0 128 102]/255;
                TITLE_FONTSIZE = 12;
                LABEL_FONTSIZE = 10;
                
                plot(innovationPlusImpulsiveOutliers(:,i), 'color', INNOV_COLOR);
                title(gca,'Estimated Innovation + Outliers','fontsize',TITLE_FONTSIZE);
                ylabel('Residual','fontsize',LABEL_FONTSIZE);
                hold on;
                yCoord = detectThresholds(i) * innovationSigma(i);
                line(xlim(gca), [yCoord, yCoord], ...
                    'LineStyle','--','Color', 'k', 'LineWidth', 1);
                legend({'Innovation + Outliers', 'Detection Threshold'});

                hold off;
                pause;
            end
        end
        
        
        %------------------------------------------------------------------
        % Re-estimate the cosmic ray signal. 
        % 
        % The outliers identified in the previous step were well above the
        % sensitivity threshold. Cosmic ray energy is present in both the
        % "outlier" and "innovation" signal components. This step is an
        % opportunity to refine our estimate of the cosmic ray signal.
        %------------------------------------------------------------------
        crIndicators = innovationPlusImpulsiveOutliers - ...
                       repmat(innovationMean, [nSegmentCadences, 1]) >  ...
                           repmat(detectThresholds .* innovationSigma, ...
                                  [nSegmentCadences, 1]);
        cosmicRayMat = zeros(nSegmentCadences, nPixels);
        
        % Separate cosmic ray and innovation flux, assuming the innovation
        % mean is zero.
        cosmicRayMat(crIndicators) = innovationPlusImpulsiveOutliers(crIndicators);

        
        %------------------------------------------------------------------
        % 8. Add back the harmonics/motion/focus model and restore the
        %    trend; unset event indicators for excluded cadences; undo the
        %    variance normalization; and fill in the output struct.
        %------------------------------------------------------------------
        cleanedPixelTsMat = (hmfResidualMat - cosmicRayMat) + hmfModelMat + fullTrendMat(segmentCadences,:);

        % Suppress correction on excluded cadences.
        crIndicators(obj.excludeIndicators, :) = false; 
        
        for i = 1:nPixels
            originalValues = pixelArray(i).values(segmentCadences);
            uncertainties  = obj.linear_gap_fill(pixelArray(i).uncertainties(segmentCadences), pixelArray(i).gapIndicators(segmentCadences));
            corrected      = originalValues;
            corrected(crIndicators(:,i)) = uncertainties(crIndicators(:,i)) .* cleanedPixelTsMat(crIndicators(:,i),i);
            pixelArray(i).values(segmentCadences)          = corrected;
            pixelArray(i).cosmicRaySignal(segmentCadences) = originalValues - corrected;
        end
        
    end % for segmentIter ...
    
    cleanTargetStruct.pixelDataStruct = pixelArray;
end


function [startIndices, gapLengths] = find_gaps( gapIndicators, roi )
%**************************************************************************  
% function [startIndices, gapLengths] = find_gaps( gapIndicators, roi )
%**************************************************************************  
% Determine the lengths of gaps in the logical gapIndicators input vector.
%
% INPUTS:
%     gapIndicators : Gap indicators for this time series
%     roi           : A region of interest (cadence indices). Only report
%                     on gaps that overlap these cadences. 
% OUTPUTS:
%     startIndices  : Starting cadence of each gap, in order.
%     gapLengths    : An array of gap lengths corresponding to each
%                     starting index.
%
%**************************************************************************  
    nCadences = length(gapIndicators);
    
    if ~exist('roi','var')
        roi = 1:nCadences;
    end
    
    if ~any(gapIndicators)
        startIndices = [];
        gapLengths = [];
        return
    end
    
    firstDifference = diff(gapIndicators(:));
    beforeGaps = find( firstDifference > 0 );
    lastInGaps = find( firstDifference < 0 );
    
    % Handle gaps at the beginning of the time series.
    if lastInGaps(1) - beforeGaps(1) <= 0
        beforeGaps = [0; beforeGaps];
    end
    
    % Handle gaps at the end of the time series.
    if lastInGaps(end) - beforeGaps(end) <= 0
        lastInGaps = [lastInGaps; nCadences];
    end

    % We want to consider the total width of each gap that overlaps the
    % roi.
    considerTheseGaps = ismember(beforeGaps, roi) | ismember(lastInGaps, roi);
    startIndices = beforeGaps(considerTheseGaps) + 1;
    gapLengths = lastInGaps(considerTheseGaps) - beforeGaps(considerTheseGaps);
    
end


%********************************** EOF ***********************************

