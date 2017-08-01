function  compactInputStruct = extract_compact_data_structure(requantizationInputStruct)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function  compactInputStruct = extract_compact_data_structure(requantizationInputStruct)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% requantizationTableClass.m - Class Constructor
% This function first checks for the presence of expected fields in the
% input structure and then implements the constructor for the
% requantizationClass using the input data structure as the template for
% the class. Once the class is created, the data members are type cast to
% double and each parameter is checked to see whether it is within
% appropriate range.
%
% Input: A data structure 'requantizationInputStruct' with the following fields:
%     requantModuleParameters: [1x1 struct]
%                 scConfigParameters: [1x1 struct]
%                    twoDBlackModels: [1x84 struct]
%                          gainModel: [1x1 struct]
%                     readNoiseModel: [1x1 struct]
%                        fcConstants: [1x1 struct]
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

% ........................................................
% requantizationInputStruct.requantModuleParameters
% ........................................................
%                                  guardBandHigh: 0.0500
%                           quantizationFraction: 0.2500
%     expectedSmearMaxBlackCorrectedPerReadInAdu: 533
%     expectedSmearMinBlackCorrectedPerReadInAdu: 0.4400
%            rssOutOriginalQuantizationNoiseFlag: 1
%                                     debugFlag: 3
% ........................................................
%  requantizationInputStruct.scConfigParameters
% ........................................................
%                          scConfigId: 1
%                                 mjd: 55000
%             fgsFramesPerIntegration: 59
%             millisecondsPerFgsFrame: 103.79
%              millisecondsPerReadout: 518.95
%         integrationsPerShortCadence: 9
%         shortCadencesPerLongCadence: 30
%             longCadencesPerBaseline: 48
%           integrationsPerScienceFfi: 270
%                       smearStartRow: 1047
%                         smearEndRow: 1051
%                       smearStartCol: 12
%                         smearEndCol: 1111
%                      maskedStartRow: 3
%                        maskedEndRow: 7
%                      maskedStartCol: 12
%                        maskedEndCol: 1111
%                        darkStartRow: 0
%                          darkEndRow: 1069
%                        darkStartCol: 3
%                          darkEndCol: 7
%                  requantFixedOffset: 80000
% ........................................................
%  requantizationInputStruct.twoDBlackModels
% ........................................................
%                 1x84 struct array with fields:
%                 mjds
%                 rows
%                 columns
%                 blacks
%                 uncertainties
% ........................................................
%  requantizationInputStruct.gainModel
% ........................................................
%                  mjds: 54505
%             constants: [1x1 struct]
% ........................................................
%  requantizationInputStruct.readNoiseModel
% ........................................................
%                  mjds: 54504
%             constants: [1x1 struct]
% ........................................................
% requantInputsStruct.fcConstants
% ........................................................
%                                 BITS_IN_ADC: 14
%                                nRowsImaging: 1024
%                                nColsImaging: 1100
%                               nLeadingBlack: 12
%                              nTrailingBlack: 20
%                               nVirtualSmear: 26
%                                nMaskedSmear: 20
%                        REQUANT_TABLE_LENGTH: 65536
%                     REQUANT_TABLE_MIN_VALUE: 0
%                     REQUANT_TABLE_MAX_VALUE: 8388607
%                     MEAN_BLACK_TABLE_LENGTH: 84
%                  MEAN_BLACK_TABLE_MIN_VALUE: 0
%                  MEAN_BLACK_TABLE_MAX_VALUE: 2^14-1
%                             MODULE_OUTPUTS: 84
%
% Output: A compact data structure' containing the above fields and other
% computed fields as data memebers.
%                       meanBlackTable: [84x1 double]
%                 visibleCCDResidualBlackRange: [84x2 double]
%               vsmearResidualBlackRange: [84x2 double]
%               msmearResidualBlackRange: [84x2 double]
%                blackResidualBlackRange: [84x2 double]
%         virtualBlackResidualBlackRange: [84x2 double]
%          maskedBlackResidualBlackRange: [84x2 double]
%                            gainTable: [84x1 double]
%                       readNoiseTable: [84x1 double]
%     numberOfExposuresPerShortCadence: 9
%      numberOfExposuresPerLongCadence: 270
%       numberOfVirtualSmearRowsSummed: 5
%        numberOfMaskedSmearRowsSummed: 5
%           numberOfBlackColumnsSummed: 5
%                          fixedOffset: 80000
%                        guardBandHigh: 0.0500
%                    numberOfBitsInADC: 14
%                 quantizationFraction: 0.2500
%                            requantTableLength: 65536
%                        requantTableMinValue: 0
%                        requantTableMaxValue: 8388607
%                           debugLevel: 3
%
% Comments: This function generates an error under the following scenarios:
%          (1) when invoked with no inputs
%          (2) when any of the fields are missing
%          (3) when any of the fields are NaNs/Infs or outside the
%          appropriate bounds
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


%-------------------------------------------------------------------------
% Step 1
% compute mean black value here and add to the new smaller structure before
% invoking the class constructor on this small structure
%-------------------------------------------------------------------------


nModOuts = length(requantizationInputStruct.twoDBlackModels); % nModOuts = 84, validate_requantization_inputs made sure of that

meanBlackTable = zeros(84,1);
meanBlackTableWithoutTrim = zeros(84,1); % for plotting purposes


visibleCCDResidualBlackRange    = zeros(84,2); % collect maximum, minimum  for each modout
msmearResidualBlackRange        = zeros(84,2);
vsmearResidualBlackRange        = zeros(84,2);
blackResidualBlackRange         = zeros(84,2);
virtualBlackResidualBlackRange  = zeros(84,2);
maskedBlackResidualBlackRange   = zeros(84,2);


% for plotting purposes; for comparing the effectiveness of trimming the
% residual black range fo reach region
visibleCCDResidualBlackRange0   = zeros(84,2); % collect maximum, minimum  for each modout
msmearResidualBlackRange0       = zeros(84,2);
vsmearResidualBlackRange0       = zeros(84,2);
blackResidualBlackRange0        = zeros(84,2);

% virtualBlackResidualBlackRange0 = zeros(84,2);
% maskedBlackResidualBlackRange0  = zeros(84,2);



% convert to 1-base
visibleCcdStartRow      = requantizationInputStruct.fcConstants.nMaskedSmear+1;
visibleCcdEndRow        = visibleCcdStartRow + requantizationInputStruct.fcConstants.nRowsImaging -1;

visibleCcdStartColumn   = requantizationInputStruct.fcConstants.nLeadingBlack+1;
visibleCcdEndColumn     = visibleCcdStartColumn + requantizationInputStruct.fcConstants.nColsImaging -1;

% scConfigParameters is 0 based, so convert to 1 based index
vsmearStartRow          = requantizationInputStruct.scConfigParameters.smearStartRow + 1;
vsmearEndRow            = requantizationInputStruct.scConfigParameters.smearEndRow + 1;

msmearStartRow          = requantizationInputStruct.scConfigParameters.maskedStartRow + 1;
msmearEndRow            = requantizationInputStruct.scConfigParameters.maskedEndRow + 1;

blackStartColumn        = requantizationInputStruct.scConfigParameters.darkStartCol + 1;
blackEndColumn          = requantizationInputStruct.scConfigParameters.darkEndCol + 1;


twoDBlackTrimPercentage     = requantizationInputStruct.requantModuleParameters.twoDBlackTrimPercentage;
twoDBlackTrimPercentageHigh  = (100 - twoDBlackTrimPercentage);
twoDBlackTrimPercentageLow   = twoDBlackTrimPercentage;


trimPercentageForBlackResiduals     = requantizationInputStruct.requantModuleParameters.trimPercentageForBlackResiduals;
trimPercentageLowForBlackResiduals  = trimPercentageForBlackResiduals;
trimPercentageHighForBlackResiduals = (100 - trimPercentageLowForBlackResiduals);


fprintf('Reading two-d black models....\n');

coaddedBlackResiduals = zeros(1070,84);

for currentModOut = 1:nModOuts


    fprintf('%d/%d\n',currentModOut, nModOuts);

    mjd = requantizationInputStruct.twoDBlackModels(currentModOut).mjds(1);
    black2DObject = twoDBlackClass(requantizationInputStruct.twoDBlackModels(currentModOut));

    twoDBlack = get_two_d_black(black2DObject,mjd); % earlier made sure this model contains only one mjd


    %----------------------------------------------------------------------
    % Compute mean black table
    %
    % twoDBlack better not contain any NaNs
    % turn this into robust mean to accommodate dead/hot pixels
    % m = trimmean(X,percent) calculates the mean of a sample X excluding
    % the highest and lowest (percent/2)% of the observations.
    %----------------------------------------------------------------------

    meanBlackTable(currentModOut) = round(trimmean(twoDBlack(:),2.0*twoDBlackTrimPercentageLow));

    meanBlackTableWithoutTrim(currentModOut) = floor(mean(mean(twoDBlack)));


    % here collect additional information listed below:
    % 1. min(bottom 1 percentile) , max (top 1 percentile) values of Black2D in the leading/trailing black regions
    % for all the 84 modouts
    % 2. min, max values of Black2D in the virtual/masked smear regions for
    % all the 84 modouts
    % 3. min, max values of Black2D in the visible CCD regions for
    % all the 84 modouts

    % 4. min, max values of Black2D in the SC virtual black regions for
    % all the 84 modouts

    % 5. min, max values of Black2D in the SC masked black regions for
    % all the 84 modouts

    %----------------------------------------------------------------------
    % subtract the mean black  IMPORTANT
    %----------------------------------------------------------------------

    twoDBlack = twoDBlack - meanBlackTable(currentModOut);

    %----------------------------------------------------------------------
    % compute max, min of deviations from mean black 2D for all 10 data
    % types
    %----------------------------------------------------------------------

    visible2DBlack = twoDBlack(visibleCcdStartRow:visibleCcdEndRow,visibleCcdStartColumn:visibleCcdEndColumn);
    visible2DBlack = visible2DBlack(:);
    visibleCCDResidualBlackRange(currentModOut,1) = prctile(visible2DBlack, twoDBlackTrimPercentageHigh);
    visibleCCDResidualBlackRange(currentModOut,2) = prctile(visible2DBlack, twoDBlackTrimPercentageLow);


    coaddedVsmearRegionBlack = sum(twoDBlack(vsmearStartRow:vsmearEndRow,visibleCcdStartColumn:visibleCcdEndColumn));
    coaddedVsmearRegionBlack = coaddedVsmearRegionBlack(:);
    vsmearResidualBlackRange(currentModOut,1) = prctile(coaddedVsmearRegionBlack, twoDBlackTrimPercentageHigh);
    vsmearResidualBlackRange(currentModOut,2) = prctile(coaddedVsmearRegionBlack, twoDBlackTrimPercentageLow);


    coaddedMsmearRegionBlack = sum(twoDBlack(msmearStartRow:msmearEndRow,visibleCcdStartColumn:visibleCcdEndColumn));
    coaddedMsmearRegionBlack = coaddedMsmearRegionBlack(:);
    msmearResidualBlackRange(currentModOut,1) = prctile(coaddedMsmearRegionBlack, twoDBlackTrimPercentageHigh);
    msmearResidualBlackRange(currentModOut,2) = prctile(coaddedMsmearRegionBlack, twoDBlackTrimPercentageLow);

    coaddedBlackRegionBlack = sum(twoDBlack(:, blackStartColumn:blackEndColumn),2);
    coaddedBlackRegionBlack = coaddedBlackRegionBlack(:);

    coaddedBlackResiduals(:,currentModOut) = coaddedBlackRegionBlack;



    % using ttwoDBlackTrimPercentageHigh/Low here to get the deviation
    % range
    %     blackResidualBlackRange(currentModOut,1) = prctile(coaddedBlackRegionBlack, twoDBlackTrimPercentageHigh);
    %     blackResidualBlackRange(currentModOut,2) = prctile(coaddedBlackRegionBlack, twoDBlackTrimPercentageLow);

    % use trimPercentageHighForBlackResiduals here to get the deviation
    % range
    blackResidualBlackRange(currentModOut,1) = prctile(coaddedBlackRegionBlack, trimPercentageHighForBlackResiduals);
    blackResidualBlackRange(currentModOut,2) = prctile(coaddedBlackRegionBlack, trimPercentageLowForBlackResiduals);


    %----------------------------------------------------------------------
    % for verifying the effectiveness of prctile or trimming operation on
    % residual black only...
    %----------------------------------------------------------------------

    % compute max, min of deviations from mean black 2D
    visibleCCDResidualBlackRange0(currentModOut,1)  = max(visible2DBlack);
    visibleCCDResidualBlackRange0(currentModOut,2)  = min(visible2DBlack);
    vsmearResidualBlackRange0(currentModOut,1)      = max(coaddedVsmearRegionBlack);
    vsmearResidualBlackRange0(currentModOut,2)      = min(coaddedVsmearRegionBlack);
    msmearResidualBlackRange0(currentModOut,1)      = max(coaddedMsmearRegionBlack);
    msmearResidualBlackRange0(currentModOut,2)      = min(coaddedMsmearRegionBlack);
    blackResidualBlackRange0(currentModOut,1)       = max(coaddedBlackRegionBlack);
    blackResidualBlackRange0(currentModOut,2)       = min(coaddedBlackRegionBlack);
    %----------------------------------------------------------------------


    doublyCoaddedVirtualBlack = sum(sum(twoDBlack(vsmearStartRow:vsmearEndRow, blackStartColumn:blackEndColumn )));
    virtualBlackResidualBlackRange(currentModOut,1) = doublyCoaddedVirtualBlack; % already a scalar
    virtualBlackResidualBlackRange(currentModOut,2) = doublyCoaddedVirtualBlack;

    % coadd and take min, max

    doublyCoaddedMaskedBlack = sum(sum(twoDBlack(msmearStartRow:msmearEndRow, blackStartColumn:blackEndColumn )));
    maskedBlackResidualBlackRange(currentModOut,1) = doublyCoaddedMaskedBlack;
    maskedBlackResidualBlackRange(currentModOut,2) = doublyCoaddedMaskedBlack;


end

save coaddedBlackResiduals.mat coaddedBlackResiduals;

plot(coaddedBlackResiduals);
hold on;
h1 = plot(1:1070, repmat(max(blackResidualBlackRange(:,1)),1,1070),'gp-','linewidth',2);
h2 = plot(1:1070, repmat(min(blackResidualBlackRange(:,2)),1,1070),'rp-','linewidth',2);

xlabel('row Number')
ylabel('black residual in ADU')
title(['Binned black residual from the 84 modouts (Trim Percentile at ' num2str(trimPercentageLowForBlackResiduals) '% )']);
legend([h1 h2],{'upper range cutoff'; 'lower range cut off'});
grid on;

isOrientationLandscapeFlag = true;



plot_to_file('requantization_trimming_black_residuals', isOrientationLandscapeFlag);


compactInputStruct.meanBlackTable = meanBlackTable(:);

compactInputStruct.visibleCCDResidualBlackRange   = visibleCCDResidualBlackRange;
compactInputStruct.vsmearResidualBlackRange       = vsmearResidualBlackRange;
compactInputStruct.msmearResidualBlackRange       = msmearResidualBlackRange;
compactInputStruct.blackResidualBlackRange        = blackResidualBlackRange;
compactInputStruct.virtualBlackResidualBlackRange = virtualBlackResidualBlackRange;
compactInputStruct.maskedBlackResidualBlackRange  = maskedBlackResidualBlackRange;

%-------------------------------------------------------------------------
% plot mean black with/without trim mean
%-------------------------------------------------------------------------

figure;

h1 = plot(meanBlackTable, 'b.-');
hold on;
h2 = plot(meanBlackTableWithoutTrim, 'rp-');


h3 = plot(visibleCCDResidualBlackRange(:,1), '.-', 'color', [0.48 0.06 0.89], 'LineWidth',2);
h4 = plot(visibleCCDResidualBlackRange0(:,1), 'o-', 'color', [0.48 0.06 0.89], 'LineWidth',2);
h5 = plot(visibleCCDResidualBlackRange(:,2), '.-', 'color', [0.75 0 0.75], 'LineWidth',2);
h6 = plot(visibleCCDResidualBlackRange0(:,2), 'o-', 'color', [0.75 0 0.75], 'LineWidth',2);


h7 = plot(vsmearResidualBlackRange(:,1), '.-', 'color', [0.04 0.52 0.78], 'LineWidth',2);
h8 = plot(vsmearResidualBlackRange0(:,1), 'o-', 'color', [0.04 0.52 0.78],'LineWidth',2);
h9 = plot(vsmearResidualBlackRange(:,2), '.-', 'color', [1 0.69 0.39], 'LineWidth',2);
h10 = plot(vsmearResidualBlackRange0(:,2), 'o-', 'color', [1 0.69 0.39], 'LineWidth',2);


h11 = plot(msmearResidualBlackRange(:,1), '.-', 'color', 'k', 'LineWidth',2);
h12 = plot(msmearResidualBlackRange0(:,1), 'o-', 'color', 'k', 'LineWidth',2);
h13 = plot(msmearResidualBlackRange(:,2), '.-', 'color', 'g', 'LineWidth',2);
h14 = plot(msmearResidualBlackRange0(:,2), 'o-', 'color', 'g', 'LineWidth',2);


h15 = plot(blackResidualBlackRange(:,1), '.-', 'color', 'm', 'LineWidth',2);
h16 = plot(blackResidualBlackRange0(:,1), 'o-', 'color', 'm', 'LineWidth',2);
h17 = plot(blackResidualBlackRange(:,2), '.-', 'color', 'c', 'LineWidth',2);
h18 = plot(blackResidualBlackRange0(:,2), 'o-', 'color', 'c', 'LineWidth',2);


legend([h1 h2 h3 h4 h5 h6 h7 h8 h9 h10 h11 h12 h13 h14 h15 h16 h17 h18 ],...
    {'trimmed mean black'; 'mean black (no trimming)';
    'trimmed visible residual black max'; 'visible residual black max';...
    'trimmed visible residual black min'; 'visible residual black min';...
    'trimmed vsmear residual black max'; 'vsmear residual black max';...
    'trimmed vsmear residual black min'; 'vsmear residual black min';...
    'trimmed msmear residual black max'; 'msmear residual black max';...
    'trimmed msmear residual black min'; 'msmear residual black min';...
    'trimmed black residual black max'; 'black residual black max';...
    'trimmed black residual black min'; 'black residual black min';},'Location', 'Southeast', 'fontsize', 8);

xlabel('Modout Number')
ylabel('Mean Black in ADU')
title('Mean Black with/without Trim')
grid on;

isOrientationLandscapeFlag = true;


plot_to_file('requantization_mean_black_with_without_trim', isOrientationLandscapeFlag);

%-------------------------------------------------------------------------
% Step 2
%-------------------------------------------------------------------------
gainObject = gainClass(requantizationInputStruct.gainModel);
gainTable  =  get_gain(gainObject); % earlier made sure this model contains only one mjd
compactInputStruct.gainTable = gainTable(:);

%-------------------------------------------------------------------------
% Step 3
%-------------------------------------------------------------------------
readNoiseObject = readNoiseClass(requantizationInputStruct.readNoiseModel);
readNoiseTable  = get_read_noise(readNoiseObject);% earlier made sure this model contains only one mjd
compactInputStruct.readNoiseTable = readNoiseTable(:);



%-------------------------------------------------------------------------
% Step 4
% collect needed parameters from the planned spacecraft configuration
% structure
%-------------------------------------------------------------------------

compactInputStruct.numberOfExposuresPerShortCadence = requantizationInputStruct.scConfigParameters.integrationsPerShortCadence;

compactInputStruct.numberOfExposuresPerLongCadence = ...
    (compactInputStruct.numberOfExposuresPerShortCadence) * (requantizationInputStruct.scConfigParameters.shortCadencesPerLongCadence);

compactInputStruct.numberOfVirtualSmearRowsSummed = ...
    requantizationInputStruct.scConfigParameters.smearEndRow - requantizationInputStruct.scConfigParameters.smearStartRow + 1;


compactInputStruct.numberOfMaskedSmearRowsSummed = ...
    requantizationInputStruct.scConfigParameters.maskedEndRow - requantizationInputStruct.scConfigParameters.maskedStartRow + 1;

compactInputStruct.numberOfBlackColumnsSummed = ...
    requantizationInputStruct.scConfigParameters.darkEndCol - requantizationInputStruct.scConfigParameters.darkStartCol + 1;


compactInputStruct.fixedOffsetLc = requantizationInputStruct.scConfigParameters.lcRequantFixedOffset ;

compactInputStruct.fixedOffsetSc = requantizationInputStruct.scConfigParameters.scRequantFixedOffset ;


%-------------------------------------------------------------------------
% Step 5
% copy the module parameters from the input structure to the smaller structure
%-------------------------------------------------------------------------

compactInputStruct.guardBandHigh = requantizationInputStruct.requantModuleParameters.guardBandHigh;
compactInputStruct.quantizationFraction = requantizationInputStruct.requantModuleParameters.quantizationFraction;

compactInputStruct.expectedSmearMaxBlackCorrectedPerReadInAdu = ...
    requantizationInputStruct.requantModuleParameters.expectedSmearMaxBlackCorrectedPerReadInAdu;
compactInputStruct.expectedSmearMinBlackCorrectedPerReadInAdu =...
    requantizationInputStruct.requantModuleParameters.expectedSmearMinBlackCorrectedPerReadInAdu;
compactInputStruct.rssOutOriginalQuantizationNoiseFlag = ...
    requantizationInputStruct.requantModuleParameters.rssOutOriginalQuantizationNoiseFlag;
compactInputStruct.inflationFactorForBufferZone = ...
    requantizationInputStruct.requantModuleParameters.inflationFactorForBufferZone;
compactInputStruct.debugLevel = requantizationInputStruct.requantModuleParameters.debugFlag;




compactInputStruct.requantTableLength = requantizationInputStruct.fcConstants.REQUANT_TABLE_LENGTH;
compactInputStruct.requantTableMinValue = requantizationInputStruct.fcConstants.REQUANT_TABLE_MIN_VALUE;
compactInputStruct.requantTableMaxValue = requantizationInputStruct.fcConstants.REQUANT_TABLE_MAX_VALUE;

compactInputStruct.numberOfBitsInADC = requantizationInputStruct.fcConstants.BITS_IN_ADC;



compactInputStruct.meanBlackTableLength = requantizationInputStruct.fcConstants.MEAN_BLACK_TABLE_LENGTH;
compactInputStruct.meanBlackTableMinValue = requantizationInputStruct.fcConstants.MEAN_BLACK_TABLE_MIN_VALUE;
compactInputStruct.meanBlackTableMaxValue = requantizationInputStruct.fcConstants.MEAN_BLACK_TABLE_MAX_VALUE;

compactInputStruct.numberOfModuleOutputs = requantizationInputStruct.fcConstants.MODULE_OUTPUTS;

save compactInputStruct.mat compactInputStruct;

return
