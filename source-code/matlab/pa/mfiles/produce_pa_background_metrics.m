function outputStruct = produce_pa_background_metrics( inputsStruct, inputStruct )
%**************************************************************************
% function outputStruct = produce_pa_background_metrics( inputsStruct, inputStruct )
%**************************************************************************
% Assemble diagnostic metrics for the background polynomial fits on a
% cadence by cadence basis.
%
% INPUTS:
%       inputsStruct    = paDataStruct - contains original background pixels
%       inputStruct     = background polynomial struct - contins fit for all cadences
% OUTPUTS:
%       outputStruct    = 
%        .module            = ccdModule
%        .output            = ccdOutput
%        .cadences          = absolute cadence numbers,[nCadencesx1]
%        .gapIndicators     = cadence gap indicators,[nCadencesx1]
%        .meanFittedValue   = mean of background fit evaluated at background pixels,[nCadencesx1]                       
%        .normalizedResidualHistogram   = histogram of residuals normalized to the propagated uncertainty
%                                         and clipped at HIST_MAD_CLIP_FACTOR mads
%        .medianNormalizedResidual  = median of normalized residual to the fit,[nCadencesx1]
%        .modeNormalizedResidual    = mode of normalized residual to the fit,[nCadencesx1]
%        .madNormalizedResidual     = mad of normalized residual to the fit,[nCadencesx1]
%        .extremeOutlierCount       = number of points > EXTREME_OUTLIER_MADS from mean,[nCadencesx1]
%        .normalizedPixelHistogram      = histogram of background pixel uncertainties normalized to standard 
%                                         deviation of the median filtered background pixel values estimated
%                                         from the mad clipped at HIST_MAD_CLIP_FACTOR mads
%        .medianNormalizedPixelUncertainty  = median of normalized uncertainties,[nCadencesx1]
%        .modeNormalizedPixelUncertainty    = mode of normalized uncertainties,[nCadencesx1]
%        .madNormalizedPixelUncertainty     = mad of normalized uncertainties,[nCadencesx1]
%        .runParameters
%           FIT_RANGE_MULTIPLIER    = was used for plotting in earlier rev
%                                     - not currently used (3)
%           HIST_MAD_CLIP_FACTOR    = clip outliers for histograms and stats (50)
%           EXTREME_OUTLIER_MADS    = (50)
%           CADENCE_IDX_START       = look at all the cadences (1)
%           CADENCE_IDX_SKIP        = (1)
%           MEDFILT_LENGTH          = one days worth of LC and odd (49)
%           HISTOGRAM_BINS          = (101)
%           STD_PER_MAD             = assumes normal distribution (1.48)
%
% Run parameters are hard coded.
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

disp('PA:Produce dawg metrics for background polynomial fits.');

% constants
FIT_RANGE_MULTIPLIER    = 3;
HIST_MAD_CLIP_FACTOR    = 5;
EXTREME_OUTLIER_MADS    = 50;
CADENCE_IDX_START       = 1;
CADENCE_IDX_SKIP        = 1;
MEDFILT_LENGTH          = 49;
HISTOGRAM_BINS          = 101;
STD_PER_MAD             = 1.4826;

% DISPLAY_STEP            = 100;


nCadences = length(inputStruct);
cadenceIdxList = CADENCE_IDX_START:CADENCE_IDX_SKIP:nCadences;
nSteps = length(cadenceIdxList);
cadences = inputsStruct.cadenceTimes.cadenceNumbers(cadenceIdxList);

mod = inputsStruct.ccdModule;
out = inputsStruct.ccdOutput;

outputStruct = struct('module',mod,...
                        'output',out,...
                        'cadences',cadences,...
                        'gapIndicators',[],...
                        'meanFittedValue',[],...                        
                        'medianNormalizedResidual',[],...
                        'modeNormalizedResidual',[],...
                        'madNormalizedResidual',[],...
                        'extremeOutlierCount',[],...
                        'normalizedResidualHistogram',struct('number',[],...
                                                                'binCenter',[]),...
                        'medianNormalizedPixelUncertainty',[],...
                        'modeNormalizedPixelUncertainty',[],...
                        'madNormalizedPixelUncertainty',[],...
                        'normalizedPixelHistogram',struct('number',[],...
                                                            'binCenter',[]),...
                        'runParameters',struct('FIT_RANGE_MULTIPLIER',FIT_RANGE_MULTIPLIER,...
                                                'HIST_MAD_CLIP_FACTOR',HIST_MAD_CLIP_FACTOR,...
                                                'EXTREME_OUTLIER_MADS',EXTREME_OUTLIER_MADS,...
                                                'CADENCE_IDX_START',CADENCE_IDX_START,...
                                                'CADENCE_IDX_SKIP',CADENCE_IDX_SKIP,...
                                                'MEDFILT_LENGTH',MEDFILT_LENGTH,...
                                                'HISTOGRAM_BINS',HISTOGRAM_BINS,...
                                                'STD_PER_MAD',STD_PER_MAD));


% internal to the pa_matlab_controller row and cols are already one based
rows  = [inputsStruct.backgroundDataStruct.ccdRow];
cols  = [inputsStruct.backgroundDataStruct.ccdColumn];
vals  = [inputsStruct.backgroundDataStruct.values];
Cvals = [inputsStruct.backgroundDataStruct.uncertainties];
gaps  = [inputsStruct.backgroundDataStruct.gapIndicators];

vals(gaps) = NaN;

nPixels = length(rows);

if( nCadences > MEDFILT_LENGTH )
    stdVals = STD_PER_MAD * mad(vals-medfilt1_soc(vals,MEDFILT_LENGTH),1);
else
    stdVals = ones(1,nPixels) .* nanmedian(sqrt(vals));
end


% preallocate space
residual = zeros(size(vals));
Cresidual = zeros(size(vals));

meanFittedValue                   = zeros(nSteps,1);
medianNormalizedResidual          = zeros(nSteps,1);
modeNormalizedResidual            = zeros(nSteps,1);
madNormalizedResidual             = zeros(nSteps,1);
extremeOutlierCount               = zeros(nSteps,1);
medianNormalizedPixelUncertainty  = zeros(nSteps,1);
modeNormalizedPixelUncertainty    = zeros(nSteps,1);
madNormalizedPixelUncertainty     = zeros(nSteps,1);
gapIndicators                     = true(nSteps,1);

normalizedResidualHistogram       = repmat(struct('number',[],...
                                                    'binCenter',[]),nSteps,1);
normalizedPixelHistogram          = repmat(struct('number',[],...
                                                    'binCenter',[]),nSteps,1);                                                

% loop through cadences                                                
stepCount = 0;
for i = cadenceIdxList
    stepCount = stepCount + 1;
    
%     if( floor(stepCount/DISPLAY_STEP)*DISPLAY_STEP == stepCount )
%         disp(['Cadence ',num2str(stepCount),' of ',num2str(nSteps),'...']);
%     end
    
    if(inputStruct(i).backgroundPolyStatus)        
        gapIndicators(stepCount) = false;
        [bgFit, CbgFit] = weighted_polyval2d(rows(:),cols(:),inputStruct(i).backgroundPoly);        
        meanFittedValue(stepCount) = mean(bgFit);
        
        residual(i,:) = vals(i,:)'-bgFit(:);
        Cresidual(i,:) = sqrt(Cvals(i,:)'.^2 + CbgFit(:).^2);
        medianNormalizedResidual(stepCount) = median(residual(i,~gaps(i,:))./Cresidual(i,~gaps(i,:)));
        madNormalizedResidual(stepCount) = mad(residual(i,~gaps(i,:))./Cresidual(i,~gaps(i,:)),1);        
        
        normalizedPixelUncertainty = Cvals(i,(~gaps(i,:)))./stdVals(~gaps(i,:));        
        medianNormalizedPixelUncertainty(stepCount) = median(normalizedPixelUncertainty);
        madNormalizedPixelUncertainty(stepCount) = mad(normalizedPixelUncertainty,1);        
        madLimit = HIST_MAD_CLIP_FACTOR * mad(normalizedPixelUncertainty,1);
        inliers = abs( normalizedPixelUncertainty -  medianNormalizedPixelUncertainty(stepCount) ) <= madLimit;
        
        [number, binCenter] = hist(normalizedPixelUncertainty( inliers ),HISTOGRAM_BINS);        
        normalizedPixelHistogram(stepCount).number = number;
        normalizedPixelHistogram(stepCount).binCenter = binCenter;  
        [dummyMax, modeIndex] = max(number);
        modeNormalizedPixelUncertainty(stepCount) = binCenter(modeIndex);
        
        normalizedResidual = residual(i,~gaps(i,:))./Cresidual(i,~gaps(i,:));
        madLimit = HIST_MAD_CLIP_FACTOR * mad(normalizedResidual,1);
        inliers = abs( normalizedResidual ) <= madLimit;        
        extremeOutlierCount(stepCount) = length( find( abs(normalizedResidual) > EXTREME_OUTLIER_MADS ) );
        
        [number, binCenter] = hist(normalizedResidual( inliers ),HISTOGRAM_BINS);
        normalizedResidualHistogram(stepCount).number = number;
        normalizedResidualHistogram(stepCount).binCenter = binCenter;
        [dummyMax, modeIndex] = max(number);
        modeNormalizedResidual(stepCount) = binCenter(modeIndex);
        
    end    
end

% package output
% only save out the metrics and histograms
outputStruct.gapIndicators                      = gapIndicators;
outputStruct.meanFittedValue                    = meanFittedValue;
outputStruct.medianNormalizedResidual           = medianNormalizedResidual;
outputStruct.modeNormalizedResidual             = modeNormalizedResidual;
outputStruct.madNormalizedResidual              = madNormalizedResidual;
outputStruct.extremeOutlierCount                = extremeOutlierCount;
outputStruct.normalizedResidualHistogram        = normalizedResidualHistogram;
outputStruct.medianNormalizedPixelUncertainty   = medianNormalizedPixelUncertainty;
outputStruct.modeNormalizedPixelUncertainty     = modeNormalizedPixelUncertainty;
outputStruct.madNormalizedPixelUncertainty      = madNormalizedPixelUncertainty;
outputStruct.normalizedPixelHistogram           = normalizedPixelHistogram;

    
      

