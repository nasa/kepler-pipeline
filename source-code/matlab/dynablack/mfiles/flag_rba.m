function  [flagInfo, flags, inRollingBand, variationLevel] = flag_rba(residual, robustResid, robwt, pixPerPt, wasInRollingBand, constants, rowNotSceneDep)
%
% function  [flagInfo, flags, inRollingBand, variationLevel] = flag_rba(residual, robustResid, robwt, pixPerPt, wasInRollingBand, constants, rowNotSceneDep)
%
% The flags returned are defined as follows:
%         bit 0: 1->scene dependent row
%         bit 1: 1->possible rolling band detected
%         bits 3-2: 0-0-> level at 1-2 * threshold for rolling bands (bits 1-0 ==  1-0 or 1-1)
%                   0-0-> level at 0-2 * threshold for scene dependent only (bits 1-0 == 0-1)
%                   0-1-> level at 2-3 * threshold
%                   1-0-> level at 3-4 * threshold
%                   1-1-> level at >4  * threshold
%         bits 3-2 are not set if not scene dependent and not rolling band (bits 1-0 = 0-0)
%
% INPUT:
% residual              residuals of spatial OLS fit for a series of LC for one row
% robustResid           residuals of spatial robust fit. (LC series; single row)
% robwt                 robust weights from spatial robust fit. (LC series; single row)
% pixPerPt              number of pixels added together to produce each point (single value)
% wasInRollingBand      true if previous row was in rolling band
% constants             constant structure
%         data_end
%         meanThreshold
%         meanSigmaThreshold
%         varianceThreshold
%         transitDepthThreshold
%         transitDepthErrorThreshold
%         transitDepthSigmaThreshold
%         testPulseDurations
%
% OUTPUT: 
% flagInfo              array of 9 parameters calculated for each LC.
%   residMean
%   residVariance
%   residTransitDepth
%   residTransitDepthError
%   robustResidMean
%   robustResidVariance
%   robustResidTransitDepth
%   robustResidTransitDepthError
%   robwtMean
%
% flags                 2D array with least significant 4 bits set as defined above
% inRollingBand         flag set to true when a rolling band is detected in a row
% variationLevel        severity level before it is converted into 4-bit flag
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



% unpack parameters
nCadences                   = constants.nCadences;
testPulseDurations          = constants.testPulseDurations;
varianceThreshold           = constants.varianceThreshold;
transitDepthThreshold       = constants.transitDepthThreshold;
transitDepthErrorThreshold  = constants.transitDepthErrorThreshold;
transitDepthSigmaThreshold  = constants.transitDepthSigmaThreshold;
meanThreshold               = constants.meanThreshold;
meanSigmaThreshold          = constants.meanSigmaThreshold;
robustWeightLoThresh        = constants.robustWeightLoThresh;
robustWeightHiThresh        = constants.robustWeightHiThresh;

% develop local constants
pad = floor(testPulseDurations*3/2);
padIndicesHead = pad:-1:1;
padIndicesTail = fliplr(padIndicesHead);
kernelTransitDepth = [ones(testPulseDurations,1)/testPulseDurations/2.; ...
                     -ones(testPulseDurations,1)/testPulseDurations; ...
                      ones(testPulseDurations,1)/testPulseDurations/2.];
kernelConstant = ones(testPulseDurations*3,1)/testPulseDurations/3;

% 9/26/14
% Change the way 'pad' is applied. Padded data is a reflection back into
% the original data. Also, after convolution is applied (now using 'full'
% shape rather than 'valid'), select only original indices.

origIndicators = true(nCadences + 2 * pad,1);
origIndicators(padIndicesHead) = false;
origIndicators(end - padIndicesTail + 1) = false;

% calculate rba parameters in 3*testPulseDurations window
residPadded = [residual(padIndicesHead + 1);...
                residual;...
                residual(end - padIndicesTail)];
robustResidPadded = [robustResid(padIndicesHead + 1);...
                     robustResid;...
                     robustResid(end - padIndicesTail)];

robustResidMean = conv(robustResidPadded, kernelConstant, 'full');
robustResidVariance = conv(robustResidPadded.^2, kernelConstant, 'full') - robustResidMean.^2;
robustResidMean = robustResidMean(origIndicators);
robustResidVariance = robustResidVariance(origIndicators);

robustResidVariancePadded = [robustResidVariance(padIndicesHead + 1); ...
                              robustResidVariance; ...
                              robustResidVariance(end - padIndicesTail)];

residMean = conv(residPadded, kernelConstant, 'full');
residVariance = conv(residPadded.^2, kernelConstant, 'full') - residMean.^2;
residMean = residMean(origIndicators);
residVariance = residVariance(origIndicators);

residVariancePadded = [residVariance(padIndicesHead + 1); ...
                       residVariance; ...
                       residVariance(end - padIndicesTail)];
residSigma = abs( residMean./sqrt(residVariance) );

residTransitDepth = conv(residPadded,kernelTransitDepth,'full');
residTransitDepthError = sqrt(conv(residVariancePadded,kernelTransitDepth.^2,'full'));
robustResidTransitDepth = conv(robustResidPadded,kernelTransitDepth,'full');
robustResidTransitDepthError = sqrt(conv(robustResidVariancePadded,kernelTransitDepth.^2,'full'));
residTransitDepth = residTransitDepth(origIndicators);
residTransitDepthError = residTransitDepthError(origIndicators);
robustResidTransitDepth = robustResidTransitDepth(origIndicators);
robustResidTransitDepthError = robustResidTransitDepthError(origIndicators);



unused = -ones(nCadences,1);

if rowNotSceneDep
    robwtPadded = [robwt(padIndicesHead + 1);...
                    robwt;...
                    robwt(end - padIndicesTail)];
    robustResidSigma = abs( robustResidMean./sqrt(robustResidVariance) );
    robwtMean = conv(robwtPadded, kernelConstant, 'full');
    robwtMean = robwtMean(origIndicators);
end


% check parameters against thresholds
residTooVariable = residVariance > varianceThreshold*pixPerPt | ...
                   ((abs(residTransitDepth) > transitDepthThreshold*pixPerPt | ...
                     residTransitDepthError > transitDepthErrorThreshold*pixPerPt) & ...
                     abs(residTransitDepth./residTransitDepthError) > transitDepthSigmaThreshold) ;

if rowNotSceneDep

    robustResidTooVariable = robustResidVariance > varianceThreshold*pixPerPt | ...
                              ((abs(robustResidTransitDepth) > transitDepthThreshold*pixPerPt | ...
                                robustResidTransitDepthError > transitDepthErrorThreshold*pixPerPt) & ...
                                abs(robustResidTransitDepth./robustResidTransitDepthError) > transitDepthSigmaThreshold);

    flagRbaLowrobwt = robwtMean < robustWeightLoThresh & ...
                        abs(residMean) > meanThreshold*pixPerPt & ...
                        residSigma > meanSigmaThreshold & ...
                        residTooVariable;
                    
    flagRbaMedrobwt = robwtMean >= robustWeightLoThresh & ...
                        robwtMean < robustWeightHiThresh & ...
                        robustResidSigma > meanSigmaThreshold & ...
                        abs(robustResidMean) > meanThreshold*pixPerPt & ...
                        residTooVariable;
                    
    flagRbaHirobwt = robwtMean >= robustWeightHiThresh & ...
                       robustResidSigma > meanSigmaThreshold & ...
                       abs(robustResidMean) > meanThreshold*pixPerPt & ...
                       robustResidTooVariable;

    isRBA = flagRbaLowrobwt | flagRbaMedrobwt | flagRbaHirobwt ;

else    
    robwtMean   = unused;                         
    isRBA       = wasInRollingBand & abs(residMean) > meanThreshold*pixPerPt & ...
                    residSigma > meanSigmaThreshold & residTooVariable;
end

    
% build variation level info by normalizing convolution results by threshold for
% spatially coadded pixels
varLevel                = residVariance./(varianceThreshold*pixPerPt);
transitLevel            = abs(residTransitDepth)./(transitDepthThreshold*pixPerPt);
transitErrLevel         = residTransitDepthError./(transitDepthErrorThreshold*pixPerPt);
varRobustLevel          = robustResidVariance./(varianceThreshold*pixPerPt);
transitRobustLevel      = abs(robustResidTransitDepth)./(transitDepthThreshold*pixPerPt);
transitErrRobustLevel   = robustResidTransitDepthError./(transitDepthErrorThreshold*pixPerPt);

% populate output info array
flagInfo = [residMean, ...
               residVariance, ...
               residTransitDepth, ...
               residTransitDepthError, ...
               robustResidMean, ...
               robustResidVariance, ...
               robustResidTransitDepth, ...
               robustResidTransitDepthError, ...
               robwtMean];

% set variation severity level as max of robust and non-robust normalized levels
variationLevel = max([varLevel, transitLevel, transitErrLevel, varRobustLevel, transitRobustLevel, transitErrRobustLevel],[],2);

% variationLevel is non-negative by definition so use -1 to mark cadences where the calculation gave Inf or NaN results (in lieu of gaps)
variationLevel(isinf(variationLevel)|isnan(variationLevel)) = -1;

% quantize variationLevel to set rba flag level
flagLevel = floor(min([ max([variationLevel, ones(nCadences,1)],[],2)-1, 3.*ones(nCadences,1) ],[],2));

% set scene dependent and/or rolling bits and build output flags [nCadences x 2]
if rowNotSceneDep    
    % non-scene dependent non-RBA rows get zero severity levels
    flagLevel = flagLevel .* isRBA;    
    flags =[unused, 0 + 2 .* isRBA + 4 .* flagLevel];
    inRollingBand = isRBA;
else
    % scene dependent rows get flag level determined by variation level
    % plus scene dependent bit is set and rba bit is set if prior row is
    % rba (was in rolling band)
    flags =[unused, 1 + 2 .* isRBA + 4 .* flagLevel];
    inRollingBand = wasInRollingBand;
end