function collect_photometric_data_for_dawg(quarterString, monthString, cadenceTypeString, ...
    dataDir, figurePath, collateralFigurePath, invocation, uow, dawgFigureFlag)
%
% function to compute the 2D black-corrected photometric pixels, and to extract
% the calibrated output pixels, for a given taskfile.  Figures that created to
% compare (1) the two sets, (2) the ratio of the two sets, and (3) the median.
%
% The computed output uncertainties are also compared to the expected uncertainties.
%
% For the given taskfile, the following figures are created for each
% photometric invocation (in this example, for invocation #1):
%
% Q6_M1_LC_ch19_inv1_in_vs_out.fig
% Q6_M1_LC_ch19_inv1_in_vs_outinratio.fig
% Q6_M1_LC_ch19_inv1_uncert_vs_out.fig
%
% Q6_M1_LC_ch19_inv1_med_uncert_vs_out.fig
% Q6_M1_LC_ch19_inv1_med_in_vs_out.fig
% Q6_M1_LC_ch19_inv1_med_in_vs_outinratio.fig
%
% These are created by loading the input pixels and computing the
% 2D black-corrected pixels, and then loading the output pixels, both of
% which are saved to a matfile:
%
% Q6_M1_LC_2DB_input_pixels_1_ch19.mat
% Q6_M1_LC_output_1_ch19.mat
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


close all;

% check for existence of inputs/outputs
%if ~exist([ dataDir '/st-',num2str(invocation),'/cal-inputs-0.mat'], 'file') || ~exist([ dataDir '/st-',num2str(invocation),'/cal-outputs-0.mat'], 'file') 
if ~exist([ dataDir '/cal-inputs-' num2str(invocation) '.mat'], 'file') || ~exist([ dataDir '/cal-outputs-' num2str(invocation) '.mat'], 'file') 
    display('No inputs/outputs found! Check for st directory')
    if exist([ dataDir '/st-',num2str(invocation),'/cal-inputs-0.mat'], 'file') 
        load([dataDir '/st-' num2str(invocation) '/cal-inputs-0.mat'])
        stFlag = true;
    else
        display('Okay, no inputs/outputs there either!')
        return;
    end
else
    load([dataDir '/cal-inputs-' num2str(invocation) '.mat'])
    stFlag = false;
end

% load input photometric pixels    

timestamp      = inputsStruct.cadenceTimes.midTimestamps;
timestampGaps  = inputsStruct.cadenceTimes.gapIndicators;

inputPixels = [inputsStruct.targetAndBkgPixels.values]';      % nPixels x nCadence
inputGaps = [inputsStruct.targetAndBkgPixels.gapIndicators]'; % nPixels x nCadence
inputRows = [inputsStruct.targetAndBkgPixels.row] + 1;        % nPixels x 1
inputCols = [inputsStruct.targetAndBkgPixels.column] + 1;     % nPixels x 1

% update gaps
isMmntmDmp = inputsStruct.cadenceTimes.isMmntmDmp; % nCadencesx1 array
isFinePnt  = inputsStruct.cadenceTimes.isFinePnt;  % nCadencesx1 array

newCadenceGaps = isMmntmDmp | ~isFinePnt;
inputGaps(:, newCadenceGaps) = true;

timestampGaps(newCadenceGaps) = true;

% find valid pixel indices:
validInputPixels = ~inputGaps;

[nPixels nCadences] = size(inputPixels); %#ok<ASGLU>

ccdModule = inputsStruct.ccdModule;
ccdOutput = inputsStruct.ccdOutput;

channel = convert_from_module_output(ccdModule, ccdOutput);

% create new figure path
figurePath  = [figurePath 'photometric_figures_' lower(monthString) '_ch' num2str(channel) '/'];
mkdir(figurePath)

dataPath = [figurePath 'photometric_data_' lower(monthString) '_ch' num2str(channel) '/'];
mkdir(dataPath)

% copy pipeline figures to collateral data path here
pipelineFigurePath = [collateralFigurePath 'pipeline_figures_ch' num2str(channel) '/'];
mkdir(pipelineFigurePath)

eval(['!cp ' dataDir  'figures/*.fig ' pipelineFigurePath])


% extract config maps
spacecraftConfigMap = inputsStruct.spacecraftConfigMap;
configMapObject     = configMapClass(spacecraftConfigMap);


%--------------------------------------------------------------------------
% extract number of exposures and fixed offset for long/short cadence
%--------------------------------------------------------------------------
numberOfExposures = nan(size(timestamp));
fixedOffset = nan(size(timestamp));

if strcmpi(cadenceTypeString, 'long') || strcmpi(cadenceTypeString, 'LC')
    
    numberOfExposures(~timestampGaps) = ...
        get_number_of_exposures_per_long_cadence_period(configMapObject, timestamp(~timestampGaps));
    
    fixedOffset(~timestampGaps) = ...
        get_long_cadence_fixed_offset(configMapObject, timestamp(~timestampGaps));
    
    cadenceTypeString = 'LC';
    
elseif  strcmpi(cadenceTypeString, 'short') || strcmpi(cadenceTypeString, 'SC')
    
    [numberOfExposures(~timestampGaps)] = ...
        get_number_of_exposures_per_short_cadence_period(configMapObject, timestamp(~timestampGaps));
    
    fixedOffset(~timestampGaps) = ...
        get_short_cadence_fixed_offset(configMapObject, timestamp(~timestampGaps));
    
    cadenceTypeString = 'SC';
end


if nanmin(numberOfExposures) == nanmax(numberOfExposures)
    numberOfExposures = nanmedian(numberOfExposures);
    display(['Number of exposures is: ' num2str(numberOfExposures) ]);
else
    display('Number of exposures varies with time!');
end

if nanmin(fixedOffset) == nanmax(fixedOffset)
    
    fixedOffset = nanmedian(fixedOffset);
    display(['Fixed offset is: ' num2str(fixedOffset) ]);
else
    display('Fixed offset varies with time!');
end


%----------------------------------------------------------------------
% correct for fixed offset
%----------------------------------------------------------------------
inputPixels(validInputPixels) = inputPixels(validInputPixels) - fixedOffset;


%--------------------------------------------------------------------------
% correct for mean black
%--------------------------------------------------------------------------
% extract mean black table values (84 x 1 array)
meanBlackEntries = inputsStruct.requantTables.meanBlackEntries;

% find mean black value for current mod/out and scale by number of exposures
meanBlack = meanBlackEntries(channel);

meanBlackForPhotometric = meanBlack * numberOfExposures;

% correct for mean black
inputPixels = inputPixels + meanBlackForPhotometric;


%--------------------------------------------------------------------------
% correct for 2D black
%--------------------------------------------------------------------------
tic
% extract 2D black model from cal object
twoDBlackModel = inputsStruct.twoDBlackModel;

twoDBlackObject = twoDBlackClass(twoDBlackModel);

clear twoDBlackModel


% lastDuration = 0;
% tic
% hWaitbar = waitbar(0,'Correcting data (per cadence) for 2D black level...');
display('Correcting photometric data for 2D black level...')
for cadenceIndex = 1:nCadences
    
    %----------------------------------------------------------------------
    % subtract 2D black model from valid photometric pixels
    %----------------------------------------------------------------------
    % get twoDBlack pixels for this cadence
    twoDBlackArray = get_two_d_black(twoDBlackObject, timestamp(cadenceIndex));
    
    % extract pixels and gaps for cadence
    pixels  = inputPixels(:, cadenceIndex);
    gaps    = inputGaps(:, cadenceIndex);
    columns = inputCols(:);
    rows    = inputRows(:);
    
    validIdx = ~gaps;
    
    if  ~isempty(validIdx)
        
        % pixel array to correct
        validPixelsForCadence = pixels(validIdx);
        
        validRowsForCadence = rows(validIdx);
        validColumnsForCadence = columns(validIdx);
        
        
        validLinearIdx = sub2ind(size(twoDBlackArray), validRowsForCadence, validColumnsForCadence);
        
        twoDBlackforPhotometric = twoDBlackArray(validLinearIdx);
        
        % 2D black is valid for one exposure, scale for long or short cadence
        twoDBlackforPhotometric = numberOfExposures * twoDBlackforPhotometric;
        
        % subtract 2D black
        if issparse(validPixelsForCadence)
            
            correctedPixels = validPixelsForCadence - sparse(twoDBlackforPhotometric(:));
        else
            
            correctedPixels = validPixelsForCadence - twoDBlackforPhotometric(:);
        end
        
        % save 2D black corrected pixels
        inputPixels(validIdx, cadenceIndex) = correctedPixels;
    end
    
    %duration = toc;
    %if (duration > 10+lastDuration)
    %    lastDuration = duration;
    %    display(['Correcting target pixels for 2Dblack, cadence ' num2str(cadenceIndex) ': ' num2str(duration/60) ' minutes']);
    %end
    %waitbar(cadenceIndex/nCadences);
end
%close(hWaitbar);


close all;

%--------------------------------------------------------------------------
% set gaps to NaNs for figures and save 2D black-corrected pixels
%--------------------------------------------------------------------------
inputPixels(inputGaps) = nan;

eval(['save ' dataPath, lower(quarterString) '_' lower(monthString)  '_' lower(cadenceTypeString) ...
    '_input_pixels_ch'  num2str(channel)  '_inv' num2str(invocation) '.mat inputPixels inputGaps inputRows inputCols'])



%--------------------------------------------------------------------------
% extract the gain for output vs input comparison
%--------------------------------------------------------------------------
gainModel  = inputsStruct.gainModel;

% create the gain object
gainObject = gainClass(gainModel);

% get gain for this mod/out
gain = nan(size(timestamp));  % nCadences x 1
gain(~timestampGaps) = ...
    get_gain(gainObject, timestamp(~timestampGaps), ccdModule, ccdOutput);

gain = nanmedian(gain);


%--------------------------------------------------------------------------
% extract output calibrated pixels
%--------------------------------------------------------------------------

% load photometric output pixels
if(stFlag)
    load([dataDir '/st-',num2str(invocation),'/cal-outputs-0.mat'])
else
    load([dataDir '/cal-outputs-' num2str(invocation) '.mat'])
end

outputPixels = [outputsStruct.targetAndBackgroundPixels.values]';      % nPixels x nCadence
outputGaps = [outputsStruct.targetAndBackgroundPixels.gapIndicators]'; % nPixels x nCadence
outputRows = [outputsStruct.targetAndBackgroundPixels.row];            %#ok<NASGU> % nPixels x 1
outputCols = [outputsStruct.targetAndBackgroundPixels.column];         %#ok<NASGU> % nPixels x 1
outputUncertainties = [outputsStruct.targetAndBackgroundPixels.uncertainties]'; % nPixels x nCadence

outputPixels(outputGaps) = nan;
outputUncertainties(outputGaps) = nan;

%--------------------------------------------------------------------------
% save calibrated pixels
%--------------------------------------------------------------------------
eval(['save ' dataPath, lower(quarterString) '_' lower(monthString)  '_' lower(cadenceTypeString) ...
    '_output_pixels_ch'  num2str(channel)  '_inv' num2str(invocation) '.mat outputPixels outputGaps outputRows outputCols outputUncertainties gain'])

%--------------------------------------------------------------------------
% transpose pixel arrays so that columns will be time series for 
% given pixel to make plots show same pixel in same color
%--------------------------------------------------------------------------
inputPixelsPrime = inputPixels';
outputPixelsPrime = outputPixels';

%--------------------------------------------------------------------------
% compare the calibrated output pixels to the 2D black-corrected input
% pixels (plot and save data to collect full channel)
%--------------------------------------------------------------------------
h1 = figure;
plot(inputPixelsPrime, outputPixelsPrime)
xlabel(' 2D black-corrected input pixels (DN/cadence) ', 'fontsize', 12)
ylabel(' Output pixels (e-/cadence) ', 'fontsize', 12)

if strcmpi(cadenceTypeString, 'long') || strcmpi(cadenceTypeString, 'LC')
    title([quarterString ' ' monthString ' ' cadenceTypeString ' Data (Ch ' num2str(channel) ', Invoc ' num2str(invocation) '): Input vs Output (gain = ' num2str(gain(1)) ')'], 'fontsize', 12)
else
    title([quarterString ' ' monthString ' ' cadenceTypeString ' Data (Ch ' num2str(channel) ', UOW ' num2str(uow) '): Input vs Output (gain = ' num2str(gain(1)) ')'], 'fontsize', 12)
end

set(h1, 'PaperPositionMode', 'auto');
set(gca, 'fontsize', 13);


if strcmpi(cadenceTypeString, 'long') || strcmpi(cadenceTypeString, 'LC')
    fileNameStr = [figurePath, lower(cadenceTypeString) '_ch' num2str(channel) '_inv' num2str(invocation)  '_in_vs_out'];
else
    fileNameStr = [figurePath, lower(cadenceTypeString) '_ch' num2str(channel) '_uow' num2str(uow)  '_in_vs_out'];
end

plot_cal_figs_to_file(fileNameStr);



h2 = figure;
targetPixelRatio = outputPixelsPrime./inputPixelsPrime;
plot(inputPixelsPrime, targetPixelRatio, '.')

xlabel(' 2D black-corrected input pixels (DN/cadence) ', 'fontsize', 12)
ylabel(' Output pixels / input pixels   (e-/DN) ', 'fontsize', 12)

if strcmpi(cadenceTypeString, 'long') || strcmpi(cadenceTypeString, 'LC')
    title([quarterString ' ' monthString ' ' cadenceTypeString ' Data (Ch ' num2str(channel) ', Invocation ' num2str(invocation) '): Input vs Output (gain = ' num2str(gain(1)) ')'], 'fontsize', 12)
else
    title([quarterString ' ' monthString ' ' cadenceTypeString ' Data (Ch ' num2str(channel) ', UOW ' num2str(uow) '): Input vs Output (gain = ' num2str(gain(1)) ')'], 'fontsize', 12)
end

x=axis;

 % select pixels with significant flux to set the mean & std based on
 % cadence type
if strcmpi(cadenceTypeString,'short') || strcmpi(cadenceTypeString, 'SC')
    brightPixelLevel = 1e5/30;
else
    brightPixelLevel = 1e5;
end

ihi = find(inputPixelsPrime(:) >brightPixelLevel); % select pixels with significant flux to set the mean & std

medTargetPixelRatio = nanmedian(targetPixelRatio(ihi));
stdTargetPixelRatio = nanstd(targetPixelRatio(ihi));
if isnan(medTargetPixelRatio)
    medTargetPixelRatio=gain;
    warning('collect_photomtric_data_for_dawg: median of pixel values not valid');
end
if (stdTargetPixelRatio==0 | isnan(stdTargetPixelRatio) )
    stdTargetPixelRatio = 20;
    warning('collect_photomtric_data_for_dawg: std-dev of pixel values not valid');
end

x0 = x(1);
x1 = x(2);
y0 = medTargetPixelRatio - 5*stdTargetPixelRatio;
y1 = medTargetPixelRatio + 5*stdTargetPixelRatio;

% check to be sure expected gain is on the screen
if (gain<y0 | gain>y1)
    y0 = gain - 8*stdTargetPixelRatio;
    y1 = gain + 8*stdTargetPixelRatio;
end
    
axis([x0 x1 y0 y1])

line0 = [x0 x1];
line1 = [gain gain];
hh2 = line(line0, line1);
set(hh2, 'linewidth', 2, 'color', 'k')


set(h2, 'PaperPositionMode', 'auto');
set(gca, 'fontsize', 13);

if strcmpi(cadenceTypeString, 'long') || strcmpi(cadenceTypeString, 'LC')
    fileNameStr = [figurePath, lower(cadenceTypeString) '_ch' num2str(channel) '_inv' num2str(invocation)  '_in_vs_outinratio'];
else
    fileNameStr = [figurePath, lower(cadenceTypeString) '_ch' num2str(channel) '_uow' num2str(uow)  '_in_vs_outinratio'];
end
plot_cal_figs_to_file(fileNameStr);



if ~dawgFigureFlag
    
    medianInputPixels = nanmedian(inputPixels, 2);
    medianOutputPixels = nanmedian(outputPixels, 2);
    
    h3 = figure;
    plot(medianInputPixels, medianOutputPixels)
    xlabel(' Median 2D black-corrected input pixels (DN/cadence) ', 'fontsize', 12)
    ylabel(' Median output pixels (e-/cadence) ', 'fontsize', 12)
    
    if strcmpi(cadenceTypeString, 'long') || strcmpi(cadenceTypeString, 'LC')
        title([quarterString ' ' monthString ' ' cadenceTypeString ' Data (Ch ' num2str(channel) ', Invoc ' num2str(invocation) '): Med Input vs Output (gain = ' num2str(gain(1)) ')'], 'fontsize', 12)
    else
        title([quarterString ' ' monthString ' ' cadenceTypeString ' Data (Ch ' num2str(channel) ', UOW ' num2str(uow) '): Med Input vs Output (gain = ' num2str(gain(1)) ')'], 'fontsize', 12)
    end
    
    set(h3, 'PaperPositionMode', 'auto');
    set(gca, 'fontsize', 13);
    
    if strcmpi(cadenceTypeString, 'long') || strcmpi(cadenceTypeString, 'LC')
        fileNameStr = [figurePath, lower(cadenceTypeString) '_ch' num2str(channel) '_inv' num2str(invocation)  '_med_in_vs_out'];
    else
        fileNameStr = [figurePath, lower(cadenceTypeString) '_ch' num2str(channel) '_uow' num2str(uow)  '_med_in_vs_out'];
    end
    plot_cal_figs_to_file(fileNameStr);
    
    
    
    h4 = figure;
    medTargetPixelRatio = medianOutputPixels./medianInputPixels;
    
    plot(medianInputPixels, medTargetPixelRatio, '.')
    xlabel(' Median 2D black-corrected input pixels (DN/cadence) ', 'fontsize', 12)
    ylabel(' Median output pixels / input pixels   (e-/DN) ', 'fontsize', 12)
    
    if strcmpi(cadenceTypeString, 'long') || strcmpi(cadenceTypeString, 'LC')
        title([quarterString ' ' monthString ' ' cadenceTypeString ' Data (Ch ' num2str(channel) ', Invoc ' num2str(invocation) '): Med Input vs Output (gain = ' num2str(gain(1)) ')'], 'fontsize', 12)
    else
        title([quarterString ' ' monthString ' ' cadenceTypeString ' Data (Ch ' num2str(channel) ', UOW ' num2str(uow) '): Med Input vs Output (gain = ' num2str(gain(1)) ')'], 'fontsize', 12)
    end
    
    
    x=axis;
    
    medMedTargetPixelRatio = nanmedian(medTargetPixelRatio(:));
    stdMedTargetPixelRatio = nanstd(medTargetPixelRatio(:));
    if isnan(medTargetPixelRatio)
        medTargetPixelRatio=gain;
        warning('collect_photomtric_data_for_dawg: median of pixel values not valid');
    end
    if (stdMedTargetPixelRatio==0 | isnan(stdTargetPixelRatio) )
        stdMedTargetPixelRatio = 20;
        warning('collect_photomtric_data_for_dawg: std-dev of pixels values not valid');
    end

    x0 = x(1);
    x1 = x(2);
    y0 = medMedTargetPixelRatio - 1*stdMedTargetPixelRatio;
    y1 = medMedTargetPixelRatio + 1*stdMedTargetPixelRatio;
    
    axis([x0 x1 y0 y1])
    
    line0 = [x0 x1];
    line1 = [gain gain];
    hh2 = line(line0, line1);
    set(hh2, 'linewidth', 2, 'color', 'k')
    
    set(h4, 'PaperPositionMode', 'auto');
    set(gca, 'fontsize', 13);
    
    if strcmpi(cadenceTypeString, 'long') || strcmpi(cadenceTypeString, 'LC')
        fileNameStr = [figurePath, lower(cadenceTypeString) '_ch' num2str(channel) '_inv' num2str(invocation)  '_med_in_vs_outinratio'];
    else
        fileNameStr = [figurePath, lower(cadenceTypeString) '_ch' num2str(channel) '_uow' num2str(uow)  '_med_in_vs_outinratio'];
    end
    plot_cal_figs_to_file(fileNameStr);
end

%--------------------------------------------------------------------------
% compare calibrated pixel uncertainties measured versus expected
%--------------------------------------------------------------------------

h5 = figure;
outputUncertaintiesPrime = outputUncertainties';
plot(outputUncertaintiesPrime, abs(sqrt(outputPixelsPrime)),'.')

xlabel(' Output uncertainties (e-/cadence) ', 'fontsize', 12)
ylabel(' Sqrt output pixels (e-/cadence) ', 'fontsize', 12)

if strcmpi(cadenceTypeString, 'long') || strcmpi(cadenceTypeString, 'LC')
    title([quarterString ' ' monthString ' ' cadenceTypeString ' Data (Ch ' num2str(channel) ', Invoc ' num2str(invocation) '): Uncertainties vs Sqrt Output '], 'fontsize', 12)
else
    title([quarterString ' ' monthString ' ' cadenceTypeString ' Data (Ch ' num2str(channel) ', UOW ' num2str(uow) '): Uncertainties vs Sqrt Output '], 'fontsize', 12)
end

set(h5, 'PaperPositionMode', 'auto');
set(gca, 'fontsize', 13);

if strcmpi(cadenceTypeString, 'long') || strcmpi(cadenceTypeString, 'LC')
    fileNameStr = [figurePath, lower(cadenceTypeString) '_ch' num2str(channel) '_inv' num2str(invocation)  '_uncert_vs_out'];
else
    fileNameStr = [figurePath, lower(cadenceTypeString) '_ch' num2str(channel) '_uow' num2str(uow)  '_uncert_vs_out'];
end
plot_cal_figs_to_file(fileNameStr);


if ~dawgFigureFlag
    h6 = figure;
    medianOutputUncertainties = nanmedian(outputUncertainties, 2);
    
    plot(medianOutputUncertainties, abs(sqrt(medianOutputPixels)),'.')
    
    xlabel(' Median output uncertainties (e-/cadence) ', 'fontsize', 12)
    ylabel(' Sqrt median output pixels (e-/cadence) ', 'fontsize', 12)
    
    if strcmpi(cadenceTypeString, 'long') || strcmpi(cadenceTypeString, 'LC')
        title([quarterString ' ' monthString ' ' cadenceTypeString ' Data (Ch ' num2str(channel) ', Invoc ' num2str(invocation) '): Med Uncert vs Sqrt Med Output '], 'fontsize', 12)
    else
        title([quarterString ' ' monthString ' ' cadenceTypeString ' Data (Ch ' num2str(channel) ', UOW ' num2str(uow) '): Med Uncert vs Sqrt Med Output '], 'fontsize', 12)
    end
    
    set(h6, 'PaperPositionMode', 'auto');
    set(gca, 'fontsize', 13);
    
    if strcmpi(cadenceTypeString, 'long') || strcmpi(cadenceTypeString, 'LC')
        fileNameStr = [figurePath, lower(cadenceTypeString) '_ch' num2str(channel) '_inv' num2str(invocation)  '_med_uncert_vs_out'];
    else
        fileNameStr = [figurePath, lower(cadenceTypeString) '_ch' num2str(channel) '_uow' num2str(uow)  '_med_uncert_vs_out'];
    end
    plot_cal_figs_to_file(fileNameStr);
end


%--------------------------------------------------------------------------
% create image of gaps for target pixels
%--------------------------------------------------------------------------
% 
% create_gap_image_for_dawg(inputsStruct, outputsStruct, quarterString, monthString, invocation, uow)




return;
