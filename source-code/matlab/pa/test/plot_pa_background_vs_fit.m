function outputStruct = plot_pa_background_vs_fit( inputsStruct, inputStruct, varargin )
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

PLOTS_ON = false;
WAIT_TIME = 0.0001;

% get variable input
if(nargin>2)
    PLOTS_ON = varargin{1};
    if(nargin>3)
        WAIT_TIME = varargin{2};
    end
end

% constants
FIT_RANGE_MULTIPLIER = 3;
HIST_MAD_CLIP_FACTOR = 5;
EXTREME_OUTLIER_MADS = 50;
CADENCE_IDX_START = 1;
CADENCE_IDX_SKIP = 1;
MEDFILT_LENGTH = 49;
HISTOGRAM_BINS = 101;
STD_PER_MAD = 1.4826;


% default figure positions and view     
P1 = [ 632   698   840   400];
P2 = [ 632   295   417   322];
P3 = [1478   295   440   803];                                  %#ok<NASGU>
P4 = [1056   295   416   322];


% Use with MATLAB 2007a
% DEFAULT_VIEW = ...
% [    0.5751   -0.8181         0    0.1215;...
%      0.3849    0.2705    0.8824   -0.7689;...
%      0.7219    0.5075   -0.4704    8.2808;...
%           0         0         0    1.0000];

% use with MATLAB 2010b
DEFAULT_VIEW = [-127.5 14];


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
                        'meanFiitedValue',[],...                        
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
                                                'WAIT_TIME',WAIT_TIME,...
                                                'CADENCE_IDX_START',CADENCE_IDX_START,...
                                                'CADENCE_IDX_SKIP',CADENCE_IDX_SKIP,...
                                                'MEDFILT_LENGTH',MEDFILT_LENGTH,...
                                                'HISTOGRAM_BINS',HISTOGRAM_BINS,...
                                                'STD_PER_MAD',STD_PER_MAD));

rows  = [inputsStruct.backgroundDataStruct.ccdRow]+1;
cols  = [inputsStruct.backgroundDataStruct.ccdColumn]+1;
vals  = [inputsStruct.backgroundDataStruct.values];
Cvals = [inputsStruct.backgroundDataStruct.uncertainties];
gaps  = [inputsStruct.backgroundDataStruct.gapIndicators];

vals(gaps) = NaN;

stdVals = STD_PER_MAD * mad(vals-medfilt1_soc(vals,MEDFILT_LENGTH),1);

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

stepCount = 0;
for i = cadenceIdxList
    stepCount = stepCount + 1;
    if(inputStruct(i).backgroundPolyStatus)        
        gapIndicators(stepCount) = false;
        [bgFit, CbgFit] = weighted_polyval2d(rows(:),cols(:),inputStruct(i).backgroundPoly);        
        meanFittedValue(stepCount) = mean(bgFit);

        if(PLOTS_ON)
            if( ~ismember( 1, get(0,'Children') ) )
                h1 = figure(1);
                set(h1,'Position',P1);
            else
                figure(1);
            end
            plot3( rows(:), cols(:), bgFit - meanFittedValue(stepCount), '.');
            hold on;
            plot3(rows(~gaps(i,:)), cols(~gaps(i,:)), vals(i,~gaps(i,:)) - meanFittedValue(stepCount), 'r.');
            hold off;
            grid on;
            if(exist('az','var') && exist('el','var'))
                view([az, el]);
            else
                view(DEFAULT_VIEW);
            end
            if(exist('aa1','var'))
                axis(aa1);
            else
                fitRange = max([max(bgFit) - min(bgFit), (HIST_MAD_CLIP_FACTOR/FIT_RANGE_MULTIPLIER) * mad( vals(i,~gaps(i,:)))]);
                aa1 = axis;
                aa1(5) = - FIT_RANGE_MULTIPLIER * fitRange;
                aa1(6) = + FIT_RANGE_MULTIPLIER * fitRange;
                axis(aa1);
            end
            title(['Mod.Out = ',num2str(mod),'.',num2str(out),...
                ' - relative cadence # ',num2str(i),...
                ' - fit order = ',num2str(inputStruct(i).backgroundPoly.order)]);
            xlabel('ccdRow');
            ylabel('ccdColumn');
            zlabel('background level w/mean fitted value removed ( e- )');
            legend('fit','data');
        end


        
        residual(i,:) = vals(i,:)'-bgFit(:);
        Cresidual(i,:) = sqrt(Cvals(i,:)'.^2 + CbgFit(:).^2);
        medianNormalizedResidual(stepCount) = median(residual(i,~gaps(i,:))./Cresidual(i,~gaps(i,:)));
        madNormalizedResidual(stepCount) = mad(residual(i,~gaps(i,:))./Cresidual(i,~gaps(i,:)),1);
        
        if(PLOTS_ON)
            if( ~ismember( 3, get(0,'Children') ) )
                h3 = figure(3);
                set(h3,'Position',P2);
            else
                figure(3);
            end
        end
        
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

        if(PLOTS_ON)
            bar(binCenter,number);
            grid on;
            xlabel('normalized pixel uncertainty (std)');
            ylabel('# observed');
            title(['Mod.Out = ',num2str(mod),'.',num2str(out),' - relative cadence # ',num2str(i)]);
            if(exist('aa3','var'))
                axis(aa3);
            else
                aa3 = axis;
                madClip = ceil( madLimit );
                axis([medianNormalizedPixelUncertainty(stepCount) - madClip, medianNormalizedPixelUncertainty(stepCount) + madClip, aa3(3), 1.2*aa3(4)]);
            end


            if( ~ismember( 4, get(0,'Children') ) )
                h4 = figure(4);
                set(h4,'Position',P4);
            else
                figure(4);
            end
        end
        
        normalizedResidual = residual(i,~gaps(i,:))./Cresidual(i,~gaps(i,:));
        madLimit = HIST_MAD_CLIP_FACTOR * mad(normalizedResidual,1);
        inliers = abs( normalizedResidual ) <= madLimit;        
        extremeOutlierCount(stepCount) = length( find( abs(normalizedResidual) > EXTREME_OUTLIER_MADS ) );
        
        [number, binCenter] = hist(normalizedResidual( inliers ),HISTOGRAM_BINS);
        normalizedResidualHistogram(stepCount).number = number;
        normalizedResidualHistogram(stepCount).binCenter = binCenter;
        [dummyMax, modeIndex] = max(number);
        modeNormalizedResidual(stepCount) = binCenter(modeIndex);
        
        if(PLOTS_ON)
            bar(binCenter,number);
            grid on;
            title(['Mod.Out = ',num2str(mod),'.',num2str(out),' - relative cadence # ',num2str(i)]);
            xlabel('normalized fit residual (propagated sigma)');
            ylabel('# observed')
            if(exist('aa4','var'))
                axis(aa4);
            else
                aa4 = axis;
                madClip = ceil( madLimit );
                axis([-madClip madClip aa4(3) 1.2*aa4(4)]);
            end

            if(WAIT_TIME==0)
                pause;
            else
                pause(WAIT_TIME);
            end
            
            figure(1);
            aa1 = axis;
            [az, el] = view;
            figure(3);
            aa3 = axis;
            figure(4);
            aa4 = axis;
        end
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


    
      

