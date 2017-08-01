function cleanTargetStruct = clean_target(obj, targetIndex, activePixIndices)
%**************************************************************************
% cleanTargetStruct = clean_target(obj, targetIndex, activePixIndices)
%**************************************************************************
% Detect and clean cosmic rays from a single designated target using the
% following method:
%
% 1. Fill gaps, stabilize variance, and lightly detrend all pixel time
%    series.
%
% 2. Identify harmonics in the target time series (the sum of all pixel
%    time series). We pass gap indicators to the harmonic identifier so
%    that results don't depend on the gap filling in step 1.
%
%    Frequencies identified = {w1, w2, ... , wM}
%
% 3. Identify segments separated by large gaps (> gapLengthThreshold) and
%    do the following for each pixel in each segment: 
%
%    a) Simultaneously fit and remove harmonics identified in step 2,
%       motion, and focus from the lightly detrended pixel time series 
%       using the following design matrix:
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
%    b) Estimate an AR model for the residual time series, r. The Matlab 
%       function arburg(), which implements the Burg algroithm, is used to
%       estimate AR model parameters for each output time series from (a).  
%
%       Compute the prediction residual at each time step. Since CR hits
%       are frequent and violate model assumptions, we replace outliers
%       above a low threshold for the purposes of prediction. A higher
%       threshold is used later in the detection step.  
%
%    c) Separate impulsive and non-impulsive outliers (significant
%       departures from the AR model). Threshold the sum of the impulsive
%       outlier signal and the AR innovation process to recover
%       large-amplitude cosmic ray effects.
%
%    e) Remove the identified large-amplitude cosmic ray signal from the
%       input pixel time series.
%
% INPUTS:
%     targetIndex       : The integer index in obj.inputArray of the target 
%                         to clean.
%     activePixIndices  : An array of indices specifying the pixels to
%                         clean. Pixels in the specified target whose
%                         indices are not on the active list may be used in
%                         the cleaning process, but will not be altered.
%
%
% OUTPUTS:
%     cleanTargetStruct : A copy of the struct obj.inputArray(targetIndex)
%                         with pixel values cleaned and the array 
%                         cosmicRaySignal added. Any of the following
%                         additional time series may be added to the pixel
%                         data structures depending on the debugging
%                         configuration: 
%
%                             prediction
%                             largeScaleTrend
%                             hmfModel
%                             arModel
%                             nonImpulsiveOutliers
%
% NOTES:
%     * Gaps are left filled.
%     * The prefixes 'full' and 'seg' are used to differentiate matrices
%       whose columns contain either complete time series or segment time
%       series in the code below. 
%     * Most matrices are named with prefixes that designate their sizes,
%       where each row corresponds to a cadence and each column to a pixel.
%       This naming convention does violate the SOC Matlab coding standard,
%       but it was decided that in this particular case the clarity gained
%       outweighed the importance of adhering to the standard. Prefixes are
%       fxf, fxa, sxf, and sxa, where 'f' stands for "full", meaning all
%       available cadences or pixels (note that fxf does not denote a
%       square matrix, but a matrix containing all cadences and all
%       pixels), 's' stands for "segment length", and 'a' stands for
%       "number of active pixels".
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
    %----------------------------------------------------------------------
    % Initialize
    %----------------------------------------------------------------------
    nCadences         = length(obj.timestamps);
    cleanTargetStruct = obj.targetArray(targetIndex);    
    pixelArray        = cleanTargetStruct.pixelDataStruct;
    nPixels           = numel(pixelArray);
    if ~exist('activePixIndices', 'var')
        activePixIndices = 1:nPixels;
    end
    nActivePixels     = numel(activePixIndices);
    
    % Pre-allocate model component matrices (active pixels only).
    fxa_HmfModelMat          = zeros(nCadences, nActivePixels);
    fxa_HmfResidualMat       = zeros(nCadences, nActivePixels);
    fxa_ArModelMat           = zeros(nCadences, nActivePixels);
    fxa_ArResidualMat        = zeros(nCadences, nActivePixels);
    fxa_NonImpulsiveOutlierMat            = zeros(nCadences, nActivePixels);
    fxa_InnovationPlusImpulsiveOutlierMat = zeros(nCadences, nActivePixels);
    fxa_CosmicRayMat         = zeros(nCadences, nActivePixels);
    fxa_VarNormPredictionMat = zeros(nCadences, nActivePixels);
    fxa_PredictionMat        = zeros(nCadences, nActivePixels);
    
    % Create input pixel matrices (all pixels).
    fxf_InputPixelMat        = [pixelArray.values];
    fxf_PixelGapMat          = [pixelArray.gapIndicators];
    
    % Populate uncertainties matrix (all pixels), interpolating as needed.
    fxf_UncertaintiesMat     = zeros(nCadences, nPixels);
    for i = 1:nPixels
        uncertainties  = obj.linear_gap_fill(...
            pixelArray(i).uncertainties, pixelArray(i).gapIndicators);
        fxf_UncertaintiesMat(:,i) = uncertainties;
    end
        
    %----------------------------------------------------------------------
    % 1. Fill gaps and stabilize variance for all pixel time series
    %
    % NOTE that get_conditioned_time_series() returns an array of time
    % series structures. This is a hold over from a previous version that
    % used wssTimeSeriesPredictorClass, which expects such structures. We
    % leave this unchanged for now, since future versions may use data
    % packaged in this way.
    %----------------------------------------------------------------------
    [fullPixelTsArr, fxf_TrendMat] ...
        = obj.get_conditioned_time_series( targetIndex );
    fxf_ConditionedPixelMat = [fullPixelTsArr.ts];
    
    %----------------------------------------------------------------------
    % 2. Identify harmonics in the target time series (the sum of all pixel
    %    time series). We pass gap indicators to the harmonic identifier so
    %    that results don't depend on the gap filling in step 1.
    %----------------------------------------------------------------------
    
    % identifyHarmonicsBySegment was removed from the set of configuration
    % params and will probably never be used. It is left here as a
    % hard-coded flag in case we ever want to experiment with it.
    identifyHarmonicsBySegment = false;     

    harmonicSamplingTimes = zeros(nCadences, 1);
    fullTargetFlux        = sum(fxf_ConditionedPixelMat, 2);
    fullGapIndicators     = any(fxf_PixelGapMat, 2);
    
    if ~identifyHarmonicsBySegment
        harmonicModelStruct ...
            = obj.identify_harmonics(fullTargetFlux, fullGapIndicators);
        harmonicFrequencies   = harmonicModelStruct.harmonicFrequenciesInHz;
        harmonicSamplingTimes = harmonicModelStruct.samplingTimesInSeconds; 
    end
    
    %----------------------------------------------------------------------
    % 3. Loop for each segment
    %----------------------------------------------------------------------
    
    % Identify Segments.
    [segmentStarts, segmentEnds] = gap_indicators_to_segments( ...
                                            fullGapIndicators, ...
                                            obj.params.gapLengthThreshold);
    nSegments = length(segmentStarts);
    
    for iSegment = 1:nSegments
        if obj.debugStruct.flags.verbose
            fprintf('SEGMENT %d of %d\n', iSegment, nSegments);
        end
        
        segmentCadences  = segmentStarts(iSegment):segmentEnds(iSegment);
        nSegmentCadences = length(segmentCadences);

        % Extract time series segment from full time series.
        sxa_ConditionedPixelMat = fxf_ConditionedPixelMat(segmentCadences, ...
                                                         activePixIndices);
        sxa_PixelGapMat         = fxf_PixelGapMat(segmentCadences, ...
                                                 activePixIndices);

        %------------------------------------------------------------------
        % a) Model the conditioned pixel time series as a linear
        %    combination of (1) the harmonics identified, (2) row and
        %    column target position time series, and (3) the focus proxy
        %    time series.
        %------------------------------------------------------------------   
        
        % Construct the design matrix.
        if identifyHarmonicsBySegment
            harmonicModelStruct ...
                = obj.identify_harmonics(fullTargetFlux(segmentCadences), ...
                                      fullGapIndicators(segmentCadences));
            harmonicFrequencies ...
                = harmonicModelStruct.harmonicFrequenciesInHz;
            harmonicSamplingTimes(segmentCadences) ...
                = harmonicModelStruct.samplingTimesInSeconds; 
        end
        
        segDesignMat ...
            = obj.build_design_matrix(targetIndex, segmentCadences, ...
                               harmonicFrequencies, harmonicSamplingTimes);
       
        % Assess the design matrix and handle the following cases:
        % i)   The matrix is empty, in which case we do nothing.
        % ii)  The matrix is poorly conditioned or has low rank, in which 
        %      case we use SVD to compute a pseudoinverse.
        % iii) The matrix is well-conditioned.
        if isempty(segDesignMat) || any(~isfinite(segDesignMat(:)))   
            sxa_HmfModelMat = zeros(size(sxa_ConditionedPixelMat));
        else
            if (cond(segDesignMat) >= 1/eps) ...
               || (rank(segDesignMat) < min(size(segDesignMat)))
                lsCoeffMat ...
                    = obj.fit_by_svd(segDesignMat, sxa_ConditionedPixelMat);
            else
                lsCoeffMat = segDesignMat \ sxa_ConditionedPixelMat;
            end
            sxa_HmfModelMat = segDesignMat * lsCoeffMat;
        end
        
        sxa_HmfResidualMat = sxa_ConditionedPixelMat - sxa_HmfModelMat;
                
        %------------------------------------------------------------------
        % b) Estimate components of the residual from (a). The residual r =
        %    sxa_HmfResidualMat(:,i) for pixel i is modeled as the sum of a
        %    dominant autoregressive process and an outlier process. The
        %    outlier process comprises impulsive (i) and non-impulsive (ni)
        %    outliers. : r = AR(p) + i + ni. Large-amplitude cosmic ray
        %    effects should be mostly confined to the impulsive outlier
        %    component.
        %------------------------------------------------------------------
        sxa_ArModelMat        = sxa_HmfResidualMat;
        sxa_InnovationMat     = zeros(nSegmentCadences, nActivePixels);
        sxa_OutlierIndicators = false(nSegmentCadences, nActivePixels);
        detectThresholds     = repmat(obj.params.detectionThreshold, ...
                                      [1, nActivePixels]);
        
        % Limit the AR model order to approximately one quarter the length
        % of the segment, but never less than 1.  
        arOrder = obj.params.arOrder;
        arOrderLimit = max([1, fix(nSegmentCadences / 4)]);
        if arOrder > arOrderLimit
            arOrder = arOrderLimit;
        end
        
        % Do AR prediction.
        for i = 1:nActivePixels
            [sxa_ArModelMat(:,i), sxa_InnovationMat(:,i), ...
             sxa_OutlierIndicators(:,i)] ...
             = obj.predict_arburg( sxa_HmfResidualMat(:,i), arOrder, ...
                                   detectThresholds(i), sxa_PixelGapMat(:,i));              
        end
 
        % Estimate the mean and standard deviation of the WGN innovation.
        % If the model fits the data well and if the flux uncertainties
        % used for variance normalization can be trusted, then the
        % recovered innovation should have a mean near zero and and
        % variance near 1.0.
        innovationMean  = mean(sxa_InnovationMat);
        innovationSigma = std(sxa_InnovationMat);

        % Separate impulsive outliers from non-impulsive outliers by median
        % filtering.
        %
        % NOTE: At this point sxa_InnovationMat contains zeros at outlier
        % locations. This is because we replace positive and negative
        % outliers with the predicted value plus the innovation mean, which
        % is zero. The code below explicitly adds these zeros to the
        % predictions, which is currently unnecessary, but will correctly
        % handle any future changes to the way innovation outliers are
        % replaced (we may chose to replace them with random values in
        % order to presetrve local noise properties).
        sxa_OutlierMat = zeros(size(sxa_HmfResidualMat)); 
        sxa_OutlierMat(sxa_OutlierIndicators) ...
            = sxa_HmfResidualMat(sxa_OutlierIndicators) ...
            - (sxa_ArModelMat(sxa_OutlierIndicators) ...
            + sxa_InnovationMat(sxa_OutlierIndicators));
        sxa_NonImpulsiveOutlierMat ...
            = cosmicRayCleanerClass.padded_median_filter( ...
                sxa_OutlierMat, obj.params.shortMedianFilterLength );
        sxa_ImpulsiveOutlierMat = sxa_OutlierMat - sxa_NonImpulsiveOutlierMat;
        sxa_InnovationPlusImpulsiveOutlierMat = sxa_InnovationMat ...
                                               + sxa_ImpulsiveOutlierMat;
        
        %------------------------------------------------------------------
        % c) Recover the un-normalized cosmic ray signal. 
        % 
        % The impulsive outliers identified in the previous step are both
        % positive and negative and were well above the sensitivity
        % threshold. Cosmic ray energy is present in both the "impulsive
        % outlier" and "innovation" signal components. In this step we
        % detect positive-going outliers using the detection thresholds
        % specified in the cosmicRayConfigurationStruct.
        %
        % The cosmic ray signal c is characterized by Poisson-distributed
        % arrival times and per-event energy distribution described in
        % KSOC-21008-001 (Algorithm Theoretical Basis Document).
        %------------------------------------------------------------------
        sxa_cosmicRayMat = zeros(nSegmentCadences, nActivePixels);
        crIndicators = sxa_InnovationPlusImpulsiveOutlierMat - ...
                       repmat(innovationMean, [nSegmentCadences, 1]) >  ...
                           repmat(detectThresholds .* innovationSigma, ...
                                  [nSegmentCadences, 1]);
        
        % Suppress correction on excluded cadences and gapped cadences.
        crIndicators(obj.excludeIndicators(segmentCadences), :) = false; 
        crIndicators(sxa_PixelGapMat) = false; 
        
        % Separate cosmic ray and innovation flux, assuming the innovation
        % mean is zero.
        sxa_cosmicRayMat(crIndicators) ...
            = sxa_InnovationPlusImpulsiveOutlierMat(crIndicators);
       
        % Undo variance normalization.
        sxa_cosmicRayMat ...
            = sxa_cosmicRayMat .* fxf_UncertaintiesMat(segmentCadences, ...
                                                   activePixIndices);

        %------------------------------------------------------------------
        % Append the results from this segment.
        %------------------------------------------------------------------
        fxa_HmfModelMat(segmentCadences, :)    = sxa_HmfModelMat;
        fxa_HmfResidualMat(segmentCadences, :) = sxa_HmfResidualMat;
        fxa_ArModelMat(segmentCadences, :)     = sxa_ArModelMat;
        fxa_ArResidualMat(segmentCadences, :)  = sxa_InnovationMat;
        fxa_NonImpulsiveOutlierMat(segmentCadences, :)  ...
            = sxa_NonImpulsiveOutlierMat;
        fxa_InnovationPlusImpulsiveOutlierMat(segmentCadences, :) ...
            = sxa_InnovationPlusImpulsiveOutlierMat;
        fxa_CosmicRayMat(segmentCadences, :)   = sxa_cosmicRayMat;
        fxa_VarNormPredictionMat(segmentCadences,:) ...
            = sxa_NonImpulsiveOutlierMat + sxa_ArModelMat + sxa_HmfModelMat ...
            + fxf_TrendMat(segmentCadences, activePixIndices);
        fxa_PredictionMat(segmentCadences,:) ...
            = fxa_VarNormPredictionMat(segmentCadences,:) ...
            .* fxf_UncertaintiesMat(segmentCadences, activePixIndices);
        
    end % for iSegment ...
    
    
    %----------------------------------------------------------------------
    % Create output structure.
    %
    % i)  Remove the identified large-amplitude cosmic ray signal from the
    %     input pixel time series.
    % ii) Append any desired intermediate results (indicated by debug
    %     flags) are appended to each pixel struct.  
    %----------------------------------------------------------------------
    for a = 1:numel(activePixIndices)  
        p = activePixIndices(a);
        
        pixelArray(p).values ...
            = fxf_InputPixelMat(:,p) - fxa_CosmicRayMat(:,a);
        pixelArray(p).(obj.CR_SIGNAL_FIELDNAME) = fxa_CosmicRayMat(:,a);
        
        if obj.debugStruct.flags.retainPredictionComponents
            pixelArray(p).(obj.LARGE_TREND_FIELDNAME) ...
                = fxf_TrendMat(:,p)    .* fxf_UncertaintiesMat(:,p);
            pixelArray(p).(obj.LS_MODEL_FIELDNAME) ...
                = fxa_HmfModelMat(:,a) .* fxf_UncertaintiesMat(:,p);
            pixelArray(p).(obj.AR_MODEL_FIELDNAME) ...
                = fxa_ArModelMat(:,a)  .* fxf_UncertaintiesMat(:,p);
            pixelArray(p).(obj.NONIMP_OUTLIER_FIELDNAME) ...
                = fxa_NonImpulsiveOutlierMat(:,a) .* fxf_UncertaintiesMat(:,p);
        end

        if obj.debugStruct.flags.retainPrediction
            pixelArray(p).(obj.PREDICTION_FIELDNAME) ...
                = fxa_VarNormPredictionMat(:,a) .* fxf_UncertaintiesMat(:,p);
        end
    end
        
    cleanTargetStruct.pixelDataStruct = pixelArray;
end


function [segmentStarts, segmentEnds] = ...
    gap_indicators_to_segments(gapIndicators, gapLengthThreshold)
%**************************************************************************  
% [segmentStarts, segmentEnds] = ...
%     gap_indicators_to_segments(gapIndicators, gapLengthThreshold) 
%**************************************************************************  
% Identify the first and last cadences of each segment to process. Segments
% are defined by gaps whose length exceed a threshold beyond which simple
% linear interpolation is deemed inadequate to fill them.
%
% INPUTS:
%     gapIndicators      : Gap indicators for this time series
%     gapLengthThreshold : Only consider gaps longer than this number of
%                          cadences.
% OUTPUTS:
%     segmentStarts      : An ordered list of starting cadences (indices) 
%                          within each segment. 
%     segmentEnds        : An ordered list of ending cadences (indices) 
%                          within each segment. 
%**************************************************************************
    [startIndices, gapLengths] = ...
        cosmicRayCleanerClass.find_gaps( gapIndicators );
    
    % Create an indicator array for long gaps that will serve as the
    % segment boundaries.
    longGapIndicators = false(size(gapIndicators)); % Initialize
    longGapListIndices    = find(gapLengths > gapLengthThreshold);
    for iGap = 1:length(longGapListIndices)
        firstInGap = startIndices(longGapListIndices(iGap));
        lastInGap  = firstInGap + gapLengths(longGapListIndices(iGap)) - 1;
        longGapIndicators(firstInGap:lastInGap) = true;
    end
    
    % Identify segments.
    [segmentStarts, segmentLengths] = ...
        cosmicRayCleanerClass.find_gaps( ~longGapIndicators );
    segmentEnds = segmentStarts + segmentLengths -1;
end

%********************************** EOF ***********************************

