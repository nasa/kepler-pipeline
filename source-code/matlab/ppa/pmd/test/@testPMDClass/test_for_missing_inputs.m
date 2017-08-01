function self = test_for_missing_inputs(self)
%--------------------------------------------------------------------------
% function self = test_for_missing_inputs(self)
%--------------------------------------------------------------------------
% test_for_missing_inputs checks to see if missing fields in the input data
% (NaN in this case ) are found
%
%  Example
%  =======
%  Use a test runner to run the test method:
%                   runner = text_test_runner(1, 1);
%         Example:  run(text_test_runner, testPMDClass('test_for_missing_inputs'));
%--------------------------------------------------------------------------
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

clear pmdInputStruct;
clear pmdScienceClass;

fprintf('\nTest PMD: test for missing inputs\n');

% load a valid PMD input structure
initialize_soc_variables;
load(fullfile(socTestDataRoot, 'ppa', 'MATLAB', 'unit-tests', 'pmd', 'pmdInputStruct.mat'));

%______________________________________________________________________
% top level validation
% validate the structure pmdInputStruct
%______________________________________________________________________

% pmdInputStruct fields
fieldsAndBounds = cell(16,4);

fieldsAndBounds( 1,:)  = { 'ccdModule';                      []; []; '[2:4, 6:20, 22:24]''' };
fieldsAndBounds( 2,:)  = { 'ccdOutput';                      []; []; '[1 2 3 4]''' };
fieldsAndBounds( 3,:)  = { 'cadenceTimes';                   []; []; [] };      % structure
fieldsAndBounds( 4,:)  = { 'pmdModuleParameters';            []; []; [] };      % structure
fieldsAndBounds( 5,:)  = { 'fcConstants';                    []; []; [] };      % structure, do not validate
fieldsAndBounds( 6,:)  = { 'spacecraftConfigMaps';           []; []; [] };      % structure array, do not validate
fieldsAndBounds( 7,:)  = { 'raDec2PixModel';                 []; []; [] };      % structure 
fieldsAndBounds( 8,:)  = { 'inputTsData';                    []; []; [] };      % structure
fieldsAndBounds( 9,:)  = { 'cdppTsData';                     []; []; [] };      % structure array
fieldsAndBounds(10,:)  = { 'badPixels';                      []; []; [] };      % structure array
fieldsAndBounds(11,:)  = { 'ancillaryEngineeringParameters'; []; []; [] };      % structure
fieldsAndBounds(12,:)  = { 'ancillaryEngineeringData';       []; []; [] };      % structure array
fieldsAndBounds(13,:)  = { 'ancillaryPipelineParameters';    []; []; [] };      % structure
fieldsAndBounds(14,:)  = { 'ancillaryPipelineData';          []; []; [] };      % structure array
fieldsAndBounds(15,:)  = { 'backgroundBlobs';                []; []; [] };      % structure array
fieldsAndBounds(16,:)  = { 'motionBlobs';                    []; []; [] };      % structure array

remove_field_and_test_for_failure(pmdInputStruct, 'pmdInputStruct', pmdInputStruct, ...
    'pmdInputStruct', 'pmdScienceClass', fieldsAndBounds, true, true);

clear fieldsAndBounds;

%--------------------------------------------------------------------------
% second level validation.
% validate the fields in pmdInputStruct.cadenceTimes
%--------------------------------------------------------------------------

% pmdInputStruct.cadenceTimes fields
fieldsAndBounds = cell(5,4);

fieldsAndBounds(1,:)   = { 'startTimestamps';   [];     []; 	[] };
fieldsAndBounds(2,:)   = { 'midTimestamps';     [];     [];     [] };
fieldsAndBounds(3,:)   = { 'endTimestamps';     [];     [];     [] };
fieldsAndBounds(4,:)   = { 'gapIndicators';     [];     [];     [true; false] };
fieldsAndBounds(5,:)   = { 'requantEnabled';    [];     [];     [true; false] };

remove_field_and_test_for_failure(pmdInputStruct.cadenceTimes, 'pmdInputStruct.cadenceTimes', pmdInputStruct, ...
    'pmdInputStruct', 'pmdScienceClass', fieldsAndBounds, true, true);

clear fieldsAndBounds;

%______________________________________________________________________
% second level validation
% validate the structure field pmdModuleParameters in pmdInputStruct
%______________________________________________________________________

% pmdInputStruct.pmdModuleParameters fields
fieldsAndBounds = cell(167,4);

fieldsAndBounds(  1,:)  = { 'horizonTime';                                           '>= 0'; '<= 100';       [] }; 
fieldsAndBounds(  2,:)  = { 'trendFitTime';                                          '>= 0'; '<= 30';        [] };
fieldsAndBounds(  3,:)  = { 'minTrendFitSampleCount';                                '>= 0'; '<= 500';       [] };
fieldsAndBounds(  4,:)  = { 'initialAverageSampleCount';                             '>= 0'; '<= 500';       [] };
fieldsAndBounds(  5,:)  = { 'alertTime';                                             '>= 0'; '<= 30';        [] };

fieldsAndBounds(  6,:)  = { 'blackLevelSmoothingFactor';                             '>= 0'; '<= 1';         [] };
fieldsAndBounds(  7,:)  = { 'blackLevelFixedLowerBound';                             '>= -100'; '<= 0';      [] };
fieldsAndBounds(  8,:)  = { 'blackLevelFixedUpperBound';                             '>= 0';    '<= 100';    [] };
fieldsAndBounds(  9,:)  = { 'blackLevelAdaptiveXFactor';                             '>= 0'; '<= 100';       [] };   

fieldsAndBounds( 10,:)  = { 'smearLevelSmoothingFactor';                             '>= 0'; '<= 1';         [] };
fieldsAndBounds( 11,:)  = { 'smearLevelFixedLowerBound';                             '== 0'; []';            [] };
fieldsAndBounds( 12,:)  = { 'smearLevelFixedUpperBound';                             '>= 0'; '<= 100000';    [] };
fieldsAndBounds( 13,:)  = { 'smearLevelAdaptiveXFactor';                             '>= 0'; '<= 100';       [] }; 

fieldsAndBounds( 14,:)  = { 'darkCurrentSmoothingFactor';                            '>= 0'; '<= 1';         [] };
fieldsAndBounds( 15,:)  = { 'darkCurrentFixedLowerBound';                            '== 0'; [];             [] };
fieldsAndBounds( 16,:)  = { 'darkCurrentFixedUpperBound';                            '>= 0'; '<= 1';         [] };
fieldsAndBounds( 17,:)  = { 'darkCurrentAdaptiveXFactor';                            '>= 0'; '<= 100';       [] }; 

fieldsAndBounds( 18,:)  = { 'twoDBlackSmoothingFactor';                              '>= 0'; '<= 1';         [] };
fieldsAndBounds( 19,:)  = { 'twoDBlackFixedLowerBound';                              '== 0'; [];             [] };
fieldsAndBounds( 20,:)  = { 'twoDBlackFixedUpperBound';                              '>= 0'; '<= 1e6';       [] };
fieldsAndBounds( 21,:)  = { 'twoDBlackAdaptiveXFactor';                              '>= 0'; '<= 100';       [] }; 

fieldsAndBounds( 22,:)  = { 'ldeUndershootSmoothingFactor';                          '>= 0'; '<= 1';         [] };
fieldsAndBounds( 23,:)  = { 'ldeUndershootFixedLowerBound';                          '>= -500'; '<= 0';      [] };
fieldsAndBounds( 24,:)  = { 'ldeUndershootFixedUpperBound';                          '>= 0';    '<= 500';    [] };
fieldsAndBounds( 25,:)  = { 'ldeUndershootAdaptiveXFactor';                          '>= 0'; '<= 100';       [] }; 

fieldsAndBounds( 26,:)  = { 'compressionSmoothingFactor';                            '>= 0'; '<= 1';         [] };
fieldsAndBounds( 27,:)  = { 'compressionFixedLowerBound';                            '>= 0'; '<= 10';        [] };
fieldsAndBounds( 28,:)  = { 'compressionFixedUpperBound';                            '>= 5'; '<= 50';        [] };
fieldsAndBounds( 29,:)  = { 'compressionAdaptiveXFactor';                            '>= 0'; '<= 100';       [] }; 

fieldsAndBounds( 30,:)  = { 'blackCosmicRayHitRateSmoothingFactor';                  '>= 0'; '<= 1';         [] };
fieldsAndBounds( 31,:)  = { 'blackCosmicRayHitRateFixedLowerBound';                  '== 0'; [];             [] };
fieldsAndBounds( 32,:)  = { 'blackCosmicRayHitRateFixedUpperBound';                  '>= 0'; '<= 100';       [] };
fieldsAndBounds( 33,:)  = { 'blackCosmicRayHitRateAdaptiveXFactor';                  '>= 0'; '<= 100';       [] }; 

fieldsAndBounds( 34,:)  = { 'blackCosmicRayMeanEnergySmoothingFactor';               '>= 0'; '<= 1';         [] };
fieldsAndBounds( 35,:)  = { 'blackCosmicRayMeanEnergyFixedLowerBound';               '== 0'; [];             [] };
fieldsAndBounds( 36,:)  = { 'blackCosmicRayMeanEnergyFixedUpperBound';               '>= 0'; '<= 1e10';      [] };
fieldsAndBounds( 37,:)  = { 'blackCosmicRayMeanEnergyAdaptiveXFactor';               '>= 0'; '<= 100';       [] }; 

fieldsAndBounds( 38,:)  = { 'blackCosmicRayEnergyVarianceSmoothingFactor';           '>= 0'; '<= 1';         [] };
fieldsAndBounds( 39,:)  = { 'blackCosmicRayEnergyVarianceFixedLowerBound';           '== 0'; [];             [] };
fieldsAndBounds( 40,:)  = { 'blackCosmicRayEnergyVarianceFixedUpperBound';           '>= 0'; '<= 1e10';      [] };
fieldsAndBounds( 41,:)  = { 'blackCosmicRayEnergyVarianceAdaptiveXFactor';           '>= 0'; '<= 100';       [] }; 

fieldsAndBounds( 42,:)  = { 'blackCosmicRayEnergySkewnessSmoothingFactor';           '>= 0'; '<= 1';         [] };
fieldsAndBounds( 43,:)  = { 'blackCosmicRayEnergySkewnessFixedLowerBound';           '>= -100'; '<= 0';      [] }; 
fieldsAndBounds( 44,:)  = { 'blackCosmicRayEnergySkewnessFixedUpperBound';           '>= 0';    '<= 100';    [] };
fieldsAndBounds( 45,:)  = { 'blackCosmicRayEnergySkewnessAdaptiveXFactor';           '>= 0'; '<= 100';       [] }; 

fieldsAndBounds( 46,:)  = { 'blackCosmicRayEnergyKurtosisSmoothingFactor';           '>= 0'; '<= 1';         [] };
fieldsAndBounds( 47,:)  = { 'blackCosmicRayEnergyKurtosisFixedLowerBound';           '== 0'; [];             [] };
fieldsAndBounds( 48,:)  = { 'blackCosmicRayEnergyKurtosisFixedUpperBound';           '>= 0'; '<= 1e10';      [] };
fieldsAndBounds( 49,:)  = { 'blackCosmicRayEnergyKurtosisAdaptiveXFactor';           '>= 0'; '<= 100';       [] }; 

fieldsAndBounds( 50,:)  = { 'maskedSmearCosmicRayHitRateSmoothingFactor';            '>= 0'; '<= 1';         [] };
fieldsAndBounds( 51,:)  = { 'maskedSmearCosmicRayHitRateFixedLowerBound';            '== 0'; [];             [] };
fieldsAndBounds( 52,:)  = { 'maskedSmearCosmicRayHitRateFixedUpperBound';            '>= 0'; '<= 100';       [] };
fieldsAndBounds( 53,:)  = { 'maskedSmearCosmicRayHitRateAdaptiveXFactor';            '>= 0'; '<= 100';       [] }; 

fieldsAndBounds( 54,:)  = { 'maskedSmearCosmicRayMeanEnergySmoothingFactor';         '>= 0'; '<= 1';         [] };
fieldsAndBounds( 55,:)  = { 'maskedSmearCosmicRayMeanEnergyFixedLowerBound';         '== 0'; [];             [] };
fieldsAndBounds( 56,:)  = { 'maskedSmearCosmicRayMeanEnergyFixedUpperBound';         '>= 0'; '<= 1e10';      [] };
fieldsAndBounds( 57,:)  = { 'maskedSmearCosmicRayMeanEnergyAdaptiveXFactor';         '>= 0'; '<= 100';       [] }; 

fieldsAndBounds( 58,:)  = { 'maskedSmearCosmicRayEnergyVarianceSmoothingFactor';     '>= 0'; '<= 1';         [] };
fieldsAndBounds( 59,:)  = { 'maskedSmearCosmicRayEnergyVarianceFixedLowerBound';     '== 0'; [];             [] };
fieldsAndBounds( 60,:)  = { 'maskedSmearCosmicRayEnergyVarianceFixedUpperBound';     '>= 0'; '<= 1e10';      [] };
fieldsAndBounds( 61,:)  = { 'maskedSmearCosmicRayEnergyVarianceAdaptiveXFactor';     '>= 0'; '<= 100';       [] }; 

fieldsAndBounds( 62,:)  = { 'maskedSmearCosmicRayEnergySkewnessSmoothingFactor';     '>= 0'; '<= 1';         [] };
fieldsAndBounds( 63,:)  = { 'maskedSmearCosmicRayEnergySkewnessFixedLowerBound';     '>= -100'; '<= 0';      [] }; 
fieldsAndBounds( 64,:)  = { 'maskedSmearCosmicRayEnergySkewnessFixedUpperBound';     '>= 0';    '<= 100';    [] };
fieldsAndBounds( 65,:)  = { 'maskedSmearCosmicRayEnergySkewnessAdaptiveXFactor';     '>= 0'; '<= 100';       [] }; 

fieldsAndBounds( 66,:)  = { 'maskedSmearCosmicRayEnergyKurtosisSmoothingFactor';     '>= 0'; '<= 1';         [] };
fieldsAndBounds( 67,:)  = { 'maskedSmearCosmicRayEnergyKurtosisFixedLowerBound';     '== 0'; [];             [] };
fieldsAndBounds( 68,:)  = { 'maskedSmearCosmicRayEnergyKurtosisFixedUpperBound';     '>= 0'; '<= 1e10';      [] };
fieldsAndBounds( 69,:)  = { 'maskedSmearCosmicRayEnergyKurtosisAdaptiveXFactor';     '>= 0'; '<= 100';       [] }; 

fieldsAndBounds( 70,:)  = { 'virtualSmearCosmicRayHitRateSmoothingFactor';           '>= 0'; '<= 1';         [] };
fieldsAndBounds( 71,:)  = { 'virtualSmearCosmicRayHitRateFixedLowerBound';           '== 0'; [];             [] };
fieldsAndBounds( 72,:)  = { 'virtualSmearCosmicRayHitRateFixedUpperBound';           '>= 0'; '<= 100';       [] };
fieldsAndBounds( 73,:)  = { 'virtualSmearCosmicRayHitRateAdaptiveXFactor';           '>= 0'; '<= 100';       [] }; 

fieldsAndBounds( 74,:)  = { 'virtualSmearCosmicRayMeanEnergySmoothingFactor';        '>= 0'; '<= 1';         [] };
fieldsAndBounds( 75,:)  = { 'virtualSmearCosmicRayMeanEnergyFixedLowerBound';        '== 0'; [];             [] };
fieldsAndBounds( 76,:)  = { 'virtualSmearCosmicRayMeanEnergyFixedUpperBound';        '>= 0'; '<= 1e10';      [] };
fieldsAndBounds( 77,:)  = { 'virtualSmearCosmicRayMeanEnergyAdaptiveXFactor';        '>= 0'; '<= 100';       [] }; 

fieldsAndBounds( 78,:)  = { 'virtualSmearCosmicRayEnergyVarianceSmoothingFactor';    '>= 0'; '<= 1';         [] };
fieldsAndBounds( 79,:)  = { 'virtualSmearCosmicRayEnergyVarianceFixedLowerBound';    '== 0'; [];             [] };
fieldsAndBounds( 80,:)  = { 'virtualSmearCosmicRayEnergyVarianceFixedUpperBound';    '>= 0'; '<= 1e10';      [] };
fieldsAndBounds( 81,:)  = { 'virtualSmearCosmicRayEnergyVarianceAdaptiveXFactor';    '>= 0'; '<= 100';       [] }; 

fieldsAndBounds( 82,:)  = { 'virtualSmearCosmicRayEnergySkewnessSmoothingFactor';    '>= 0'; '<= 1';         [] };
fieldsAndBounds( 83,:)  = { 'virtualSmearCosmicRayEnergySkewnessFixedLowerBound';    '>= -100'; '<= 0';      [] }; 
fieldsAndBounds( 84,:)  = { 'virtualSmearCosmicRayEnergySkewnessFixedUpperBound';    '>= 0';    '<= 100';    [] };
fieldsAndBounds( 85,:)  = { 'virtualSmearCosmicRayEnergySkewnessAdaptiveXFactor';    '>= 0'; '<= 100';       [] }; 

fieldsAndBounds( 86,:)  = { 'virtualSmearCosmicRayEnergyKurtosisSmoothingFactor';    '>= 0'; '<= 1';         [] };
fieldsAndBounds( 87,:)  = { 'virtualSmearCosmicRayEnergyKurtosisFixedLowerBound';    '== 0'; [];             [] };
fieldsAndBounds( 88,:)  = { 'virtualSmearCosmicRayEnergyKurtosisFixedUpperBound';    '>= 0'; '<= 1e10';      [] };
fieldsAndBounds( 89,:)  = { 'virtualSmearCosmicRayEnergyKurtosisAdaptiveXFactor';    '>= 0'; '<= 100';       [] }; 

fieldsAndBounds( 90,:)  = { 'targetStarCosmicRayHitRateSmoothingFactor';             '>= 0'; '<= 1';         [] };
fieldsAndBounds( 91,:)  = { 'targetStarCosmicRayHitRateFixedLowerBound';             '== 0'; [];             [] };
fieldsAndBounds( 92,:)  = { 'targetStarCosmicRayHitRateFixedUpperBound';             '>= 0'; '<= 100';       [] };
fieldsAndBounds( 93,:)  = { 'targetStarCosmicRayHitRateAdaptiveXFactor';             '>= 0'; '<= 100';       [] }; 

fieldsAndBounds( 94,:)  = { 'targetStarCosmicRayMeanEnergySmoothingFactor';          '>= 0'; '<= 1';         [] };
fieldsAndBounds( 95,:)  = { 'targetStarCosmicRayMeanEnergyFixedLowerBound';          '== 0'; [];             [] };
fieldsAndBounds( 96,:)  = { 'targetStarCosmicRayMeanEnergyFixedUpperBound';          '>= 0'; '<= 1e10';      [] };
fieldsAndBounds( 97,:)  = { 'targetStarCosmicRayMeanEnergyAdaptiveXFactor';          '>= 0'; '<= 100';       [] }; 

fieldsAndBounds( 98,:)  = { 'targetStarCosmicRayEnergyVarianceSmoothingFactor';      '>= 0'; '<= 1';         [] };
fieldsAndBounds( 99,:)  = { 'targetStarCosmicRayEnergyVarianceFixedLowerBound';      '== 0'; [];             [] };
fieldsAndBounds(100,:)  = { 'targetStarCosmicRayEnergyVarianceFixedUpperBound';      '>= 0'; '<= 1e20';      [] };
fieldsAndBounds(101,:)  = { 'targetStarCosmicRayEnergyVarianceAdaptiveXFactor';      '>= 0'; '<= 100';       [] }; 

fieldsAndBounds(102,:)  = { 'targetStarCosmicRayEnergySkewnessSmoothingFactor';      '>= 0'; '<= 1';         [] };
fieldsAndBounds(103,:)  = { 'targetStarCosmicRayEnergySkewnessFixedLowerBound';      '>= -100'; '<= 0';      [] }; 
fieldsAndBounds(104,:)  = { 'targetStarCosmicRayEnergySkewnessFixedUpperBound';      '>= 0';    '<= 100';    [] };
fieldsAndBounds(105,:)  = { 'targetStarCosmicRayEnergySkewnessAdaptiveXFactor';      '>= 0'; '<= 100';       [] }; 

fieldsAndBounds(106,:)  = { 'targetStarCosmicRayEnergyKurtosisSmoothingFactor';      '>= 0'; '<= 1';         [] };
fieldsAndBounds(107,:)  = { 'targetStarCosmicRayEnergyKurtosisFixedLowerBound';      '== 0'; [];             [] };
fieldsAndBounds(108,:)  = { 'targetStarCosmicRayEnergyKurtosisFixedUpperBound';      '>= 0'; '<= 1e10';      [] };
fieldsAndBounds(109,:)  = { 'targetStarCosmicRayEnergyKurtosisAdaptiveXFactor';      '>= 0'; '<= 100';       [] }; 

fieldsAndBounds(110,:)  = { 'backgroundCosmicRayHitRateSmoothingFactor';             '>= 0'; '<= 1';         [] };
fieldsAndBounds(111,:)  = { 'backgroundCosmicRayHitRateFixedLowerBound';             '== 0'; [];             [] };
fieldsAndBounds(112,:)  = { 'backgroundCosmicRayHitRateFixedUpperBound';             '>= 0'; '<= 100';       [] };
fieldsAndBounds(113,:)  = { 'backgroundCosmicRayHitRateAdaptiveXFactor';             '>= 0'; '<= 100';       [] }; 

fieldsAndBounds(114,:)  = { 'backgroundCosmicRayMeanEnergySmoothingFactor';          '>= 0'; '<= 1';         [] };
fieldsAndBounds(115,:)  = { 'backgroundCosmicRayMeanEnergyFixedLowerBound';          '== 0'; [];             [] };
fieldsAndBounds(116,:)  = { 'backgroundCosmicRayMeanEnergyFixedUpperBound';          '>= 0'; '<= 3e5';       [] };
fieldsAndBounds(117,:)  = { 'backgroundCosmicRayMeanEnergyAdaptiveXFactor';          '>= 0'; '<= 100';       [] }; 

fieldsAndBounds(118,:)  = { 'backgroundCosmicRayEnergyVarianceSmoothingFactor';      '>= 0'; '<= 1';         [] };
fieldsAndBounds(119,:)  = { 'backgroundCosmicRayEnergyVarianceFixedLowerBound';      '== 0'; [];             [] };   
fieldsAndBounds(120,:)  = { 'backgroundCosmicRayEnergyVarianceFixedUpperBound';      '>= 0'; '<= 1e10';      [] };  
fieldsAndBounds(121,:)  = { 'backgroundCosmicRayEnergyVarianceAdaptiveXFactor';      '>= 0'; '<= 100';       [] }; 

fieldsAndBounds(122,:)  = { 'backgroundCosmicRayEnergySkewnessSmoothingFactor';      '>= 0'; '<= 1';         [] };
fieldsAndBounds(123,:)  = { 'backgroundCosmicRayEnergySkewnessFixedLowerBound';      '>= -100'; '<= 0';      [] };  
fieldsAndBounds(124,:)  = { 'backgroundCosmicRayEnergySkewnessFixedUpperBound';      '>= 0';    '<= 100';    [] };   
fieldsAndBounds(125,:)  = { 'backgroundCosmicRayEnergySkewnessAdaptiveXFactor';      '>= 0'; '<= 100';       [] }; 

fieldsAndBounds(126,:)  = { 'backgroundCosmicRayEnergyKurtosisSmoothingFactor';      '>= 0'; '<= 1';         [] };
fieldsAndBounds(127,:)  = { 'backgroundCosmicRayEnergyKurtosisFixedLowerBound';      '== 0'; [];             [] };
fieldsAndBounds(128,:)  = { 'backgroundCosmicRayEnergyKurtosisFixedUpperBound';      '>= 0'; '<= 1e10';      [] };
fieldsAndBounds(129,:)  = { 'backgroundCosmicRayEnergyKurtosisAdaptiveXFactor';      '>= 0'; '<= 100';       [] }; 

fieldsAndBounds(130,:)  = { 'brightnessSmoothingFactor';                             '>= 0'; '<= 1';         [] };
fieldsAndBounds(131,:)  = { 'brightnessFixedLowerBound';                             '>= 0';    '<= 1';      [] };
fieldsAndBounds(132,:)  = { 'brightnessFixedUpperBound';                             '>= 0.5';  '<= 2';      [] };
fieldsAndBounds(133,:)  = { 'brightnessAdaptiveXFactor';                             '>= 0'; '<= 100';       [] }; 

fieldsAndBounds(134,:)  = { 'encircledEnergySmoothingFactor';                        '>= 0'; '<= 1';         [] };
fieldsAndBounds(135,:)  = { 'encircledEnergyFixedLowerBound';                        '>= 0'; '<= 15';        [] };
fieldsAndBounds(136,:)  = { 'encircledEnergyFixedUpperBound';                        '>= 0'; '<= 15';        [] };
fieldsAndBounds(137,:)  = { 'encircledEnergyAdaptiveXFactor';                        '>= 0'; '<= 100';       [] }; 

fieldsAndBounds(138,:)  = { 'backgroundLevelSmoothingFactor';                        '>= 0'; '<= 1';         [] };
fieldsAndBounds(139,:)  = { 'backgroundLevelFixedLowerBound';                        '== 0'; [];             [] };
fieldsAndBounds(140,:)  = { 'backgroundLevelFixedUpperBound';                        '>= 0'; '<= 300000';    [] };
fieldsAndBounds(141,:)  = { 'backgroundLevelAdaptiveXFactor';                        '>= 0'; '<= 100';       [] }; 

fieldsAndBounds(142,:)  = { 'centroidsMeanRowSmoothingFactor';                       '>= 0'; '<= 1';         [] };
fieldsAndBounds(143,:)  = { 'centroidsMeanRowFixedLowerBound';                       '>= -100';  '<= 0';     [] };
fieldsAndBounds(144,:)  = { 'centroidsMeanRowFixedUpperBound';                       '>= 0';     '<= 100';   [] };
fieldsAndBounds(145,:)  = { 'centroidsMeanRowAdaptiveXFactor';                       '>= 0'; '<= 100';       [] }; 

fieldsAndBounds(146,:)  = { 'centroidsMeanColumnSmoothingFactor';                    '>= 0'; '<= 1';         [] };
fieldsAndBounds(147,:)  = { 'centroidsMeanColumnFixedLowerBound';                    '>= -100';  '<= 0';     [] };
fieldsAndBounds(148,:)  = { 'centroidsMeanColumnFixedUpperBound';                    '>= 0';     '<= 100';   [] };
fieldsAndBounds(149,:)  = { 'centroidsMeanColumnAdaptiveXFactor';                    '>= 0'; '<= 100';       [] }; 

fieldsAndBounds(150,:)  = { 'plateScaleSmoothingFactor';                             '>= 0'; '<= 1';         [] };
fieldsAndBounds(151,:)  = { 'plateScaleFixedLowerBound';                             '>= 0'; '<= 2';         [] }; 
fieldsAndBounds(152,:)  = { 'plateScaleFixedUpperBound';                             '>= 0'; '<= 2';         [] };
fieldsAndBounds(153,:)  = { 'plateScaleAdaptiveXFactor';                             '>= 0'; '<= 100';       [] }; 

fieldsAndBounds(154,:)  = { 'cdppMeasuredSmoothingFactor';                           '>= 0'; '<= 1';         [] };
fieldsAndBounds(155,:)  = { 'cdppMeasuredFixedLowerBound';                           '== 0'; [];             [] };
fieldsAndBounds(156,:)  = { 'cdppMeasuredFixedUpperBound';                           '>= 0'; '<= 200000';    [] };
fieldsAndBounds(157,:)  = { 'cdppMeasuredAdaptiveXFactor';                           '>= 0'; '<= 100';       [] }; 

fieldsAndBounds(158,:)  = { 'cdppExpectedSmoothingFactor';                           '>= 0'; '<= 1';         [] };
fieldsAndBounds(159,:)  = { 'cdppExpectedFixedLowerBound';                           '== 0'; [];             [] };
fieldsAndBounds(160,:)  = { 'cdppExpectedFixedUpperBound';                           '>= 0'; '<= 200000';    [] };
fieldsAndBounds(161,:)  = { 'cdppExpectedAdaptiveXFactor';                           '>= 0'; '<= 100';       [] }; 

fieldsAndBounds(162,:)  = { 'cdppRatioSmoothingFactor';                              '>= 0'; '<= 1';         [] };
fieldsAndBounds(163,:)  = { 'cdppRatioFixedLowerBound';                              '== 0'; [];             [] };
fieldsAndBounds(164,:)  = { 'cdppRatioFixedUpperBound';                              '>= 0'; '<= 2000';      [] };
fieldsAndBounds(165,:)  = { 'cdppRatioAdaptiveXFactor';                              '>= 0'; '<= 100';       [] }; 

fieldsAndBounds(166,:)  = { 'debugLevel';                                            '>= 0'; '<= 5';         [] };
fieldsAndBounds(167,:)  = { 'plottingEnabled';                                       [];     [];             [true false] };

remove_field_and_test_for_failure(pmdInputStruct.pmdModuleParameters, 'pmdInputStruct.pmdModuleParameters',...
    pmdInputStruct, 'pmdInputStruct', 'pmdScienceClass', fieldsAndBounds, true, true);

clear fieldsAndBounds;

%______________________________________________________________________
% second level validation
% validate the fields in pmdInputStruct.inputTsData
%______________________________________________________________________

% pmdInputStruct.inputTsData fields 
fieldsAndBounds = cell(14,4);
fieldsAndBounds( 1,:) = { 'blackLevel';                         []; []; [] }; % structure
fieldsAndBounds( 2,:) = { 'smearLevel';                         []; []; [] }; % structure
fieldsAndBounds( 3,:) = { 'darkCurrent';                        []; []; [] }; % structure
fieldsAndBounds( 4,:) = { 'twoDBlack';                          []; []; [] }; % structure array
fieldsAndBounds( 5,:) = { 'ldeUndershoot';                      []; []; [] }; % structure array
fieldsAndBounds( 6,:) = { 'theoreticalCompressionEfficiency';   []; []; [] }; % structure
fieldsAndBounds( 7,:) = { 'achievedCompressionEfficiency';      []; []; [] }; % structure
fieldsAndBounds( 8,:) = { 'blackCosmicRayMetrics';              []; []; [] }; % structure
fieldsAndBounds( 9,:) = { 'maskedSmearCosmicRayMetrics';        []; []; [] }; % structure
fieldsAndBounds(10,:) = { 'virtualSmearCosmicRayMetrics';       []; []; [] }; % structure
fieldsAndBounds(11,:) = { 'targetStarCosmicRayMetrics';         []; []; [] }; % structure
fieldsAndBounds(12,:) = { 'backgroundCosmicRayMetrics';         []; []; [] }; % structure
fieldsAndBounds(13,:) = { 'brightness';                         []; []; [] }; % structure
fieldsAndBounds(14,:) = { 'encircledEnergy';                    []; []; [] }; % structure

remove_field_and_test_for_failure(pmdInputStruct.inputTsData, 'pmdInputStruct.inputTsData', ...
    pmdInputStruct, 'pmdInputStruct', 'pmdScienceClass', fieldsAndBounds, true, true);

clear fieldsAndBounds;

%______________________________________________________________________
% third level validation
% validate the fields in pmdInputStruct.inputTsData.blackLevel
%______________________________________________________________________

% pmdInputStruct.inputTsData.blackLevel fields
fieldsAndBounds = cell(3,4);
fieldsAndBounds(1,:)  = { 'values';         [];     [];     []};                % TBD
fieldsAndBounds(2,:)  = { 'gapIndicators';  [];     [];     [true, false]};
fieldsAndBounds(3,:)  = { 'uncertainties';  [];     [];     []};                % TBD

remove_field_and_test_for_failure(pmdInputStruct.inputTsData.blackLevel, 'pmdInputStruct.inputTsData.blackLevel', ...
    pmdInputStruct, 'pmdInputStruct', 'pmdScienceClass', fieldsAndBounds, true, true);

clear fieldsAndBounds;

%______________________________________________________________________
% third level validation
% validate the fields in pmdInputStruct.inputTsData.smearLevel
%______________________________________________________________________

% pmdInputStruct.inputTsData.smearLevel fields
fieldsAndBounds = cell(3,4);
fieldsAndBounds(1,:)  = { 'values';         [];     [];     []};                % TBD
fieldsAndBounds(2,:)  = { 'gapIndicators';  [];     [];     [true, false]};
fieldsAndBounds(3,:)  = { 'uncertainties';  [];     [];     []};                % TBD

remove_field_and_test_for_failure(pmdInputStruct.inputTsData.smearLevel, 'pmdInputStruct.inputTsData.smearLevel', ...
    pmdInputStruct, 'pmdInputStruct', 'pmdScienceClass', fieldsAndBounds, true, true);

clear fieldsAndBounds;

%______________________________________________________________________
% third level validation
% validate the fields in pmdInputStruct.inputTsData.darkCurrent
%______________________________________________________________________

% pmdInputStruct.inputTsData.darkCurrent fields
fieldsAndBounds = cell(3,4);
fieldsAndBounds(1,:)  = { 'values';         [];     [];     []};                % TBD
fieldsAndBounds(2,:)  = { 'gapIndicators';  [];     [];     [true, false]};
fieldsAndBounds(3,:)  = { 'uncertainties';  [];     [];     []};                % TBD

remove_field_and_test_for_failure(pmdInputStruct.inputTsData.darkCurrent, 'pmdInputStruct.inputTsData.darkCurrent', ...
    pmdInputStruct, 'pmdInputStruct', 'pmdScienceClass', fieldsAndBounds, true, true);

clear fieldsAndBounds;

%______________________________________________________________________
% third level validation
% validate the fields in pmdInputStruct.inputTsData.twoDBlack
%______________________________________________________________________

% pmdInputStruct.inputTsData.twoDBlack fields
fieldsAndBounds = cell(4,4);
fieldsAndBounds(1,:)  = { 'keplerId';       '> 0';  '< 1e9';    []};                
fieldsAndBounds(2,:)  = { 'values';         [];     [];         []};                % TBD
fieldsAndBounds(3,:)  = { 'gapIndicators';  [];     [];         [true, false]};
fieldsAndBounds(4,:)  = { 'uncertainties';  [];     [];         []};                % TBD

remove_field_and_test_for_failure(pmdInputStruct.inputTsData.twoDBlack, 'pmdInputStruct.inputTsData.twoDBlack', ...
    pmdInputStruct, 'pmdInputStruct', 'pmdScienceClass', fieldsAndBounds, true, true);

clear fieldsAndBounds;

%______________________________________________________________________
% third level validation
% validate the fields in pmdInputStruct.inputTsData.ldeUndershoot
%______________________________________________________________________

% pmdInputStruct.inputTsData.ldeUndershoot fields
fieldsAndBounds = cell(4,4);
fieldsAndBounds(1,:)  = { 'keplerId';       '> 0';  '< 1e9';    []}; 
fieldsAndBounds(2,:)  = { 'values';         [];     [];         []};                % TBD
fieldsAndBounds(3,:)  = { 'gapIndicators';  [];     [];         [true, false]};
fieldsAndBounds(4,:)  = { 'uncertainties';  [];     [];         []};                % TBD

remove_field_and_test_for_failure(pmdInputStruct.inputTsData.ldeUndershoot, 'pmdInputStruct.inputTsData.ldeUndershoot', ...
    pmdInputStruct, 'pmdInputStruct', 'pmdScienceClass', fieldsAndBounds, true, true);

clear fieldsAndBounds;

%______________________________________________________________________
% third level validation
% validate the fields in pmdInputStruct.inputTsData.theoreticalCompressionEfficiency
%______________________________________________________________________

% pmdInputStruct.inputTsData.theoreticalCompressionEfficiency fields
fieldsAndBounds = cell(2,4);
fieldsAndBounds(1,:)  = { 'values';         [];     [];     []};                % TBD
fieldsAndBounds(2,:)  = { 'gapIndicators';  [];     [];     [true, false]};

remove_field_and_test_for_failure(pmdInputStruct.inputTsData.theoreticalCompressionEfficiency, 'pmdInputStruct.inputTsData.theoreticalCompressionEfficiency', ...
    pmdInputStruct, 'pmdInputStruct', 'pmdScienceClass', fieldsAndBounds, true, true);

clear fieldsAndBounds;

%______________________________________________________________________
% third level validation
% validate the fields in pmdInputStruct.inputTsData.achievedCompressionEfficiency
%______________________________________________________________________

% pmdInputStruct.inputTsData.achievedCompressionEfficiency fields
fieldsAndBounds = cell(2,4);
fieldsAndBounds(1,:)  = { 'values';         [];     [];     []};                % TBD
fieldsAndBounds(2,:)  = { 'gapIndicators';  [];     [];     [true, false]};

remove_field_and_test_for_failure(pmdInputStruct.inputTsData.achievedCompressionEfficiency, 'pmdInputStruct.inputTsData.achievedCompressionEfficiency', ...
    pmdInputStruct, 'pmdInputStruct', 'pmdScienceClass', fieldsAndBounds, true, true);

clear fieldsAndBounds;

%______________________________________________________________________
% third level validation
% validate the fields in pmdInputStruct.inputTsData.brightness
%______________________________________________________________________

% pmdInputStruct.inputTsData.brightness fields
fieldsAndBounds = cell(3,4);
fieldsAndBounds(1,:)  = { 'values';         [];     [];     []};                % TBD
fieldsAndBounds(2,:)  = { 'gapIndicators';  [];     [];     [true, false]};
fieldsAndBounds(3,:)  = { 'uncertainties';  [];     [];     []};                % TBD

remove_field_and_test_for_failure(pmdInputStruct.inputTsData.brightness, 'pmdInputStruct.inputTsData.brightness', ...
    pmdInputStruct, 'pmdInputStruct', 'pmdScienceClass', fieldsAndBounds, true, true);

clear fieldsAndBounds;

%______________________________________________________________________
% third level validation
% validate the fields in pmdInputStruct.inputTsData.encircledEnergy
%______________________________________________________________________

% pmdInputStruct.inputTsData.encircledEnergy fields
fieldsAndBounds = cell(3,4);
fieldsAndBounds(1,:)  = { 'values';         [];     [];     []};                % TBD
fieldsAndBounds(2,:)  = { 'gapIndicators';  [];     [];     [true, false]};
fieldsAndBounds(3,:)  = { 'uncertainties';  [];     [];     []};                % TBD

remove_field_and_test_for_failure(pmdInputStruct.inputTsData.encircledEnergy, 'pmdInputStruct.inputTsData.encircledEnergy', ...
    pmdInputStruct, 'pmdInputStruct', 'pmdScienceClass', fieldsAndBounds, true, true);

clear fieldsAndBounds;

%______________________________________________________________________
% third level validation
% validate the fields in pmdInputStruct.inputTsData.blackCosmicRayMetrics
%                        pmdInputStruct.inputTsData.maskedSmearCosmicRayMetrics
%                        pmdInputStruct.inputTsData.virtualSmearCosmicRayMetrics
%                        pmdInputStruct.inputTsData.targetStarCosmicRayMetrics
%                        pmdInputStruct.inputTsData.backgroundCosmicRayMetrics
%______________________________________________________________________

% pmdInputStruct.inputTsData.cosmicRayMetrics fields
fieldsAndBounds = cell(6,4);
fieldsAndBounds( 1,:)  = { 'empty';             []; []; [true, false] };
fieldsAndBounds( 2,:)  = { 'hitRate';           []; []; [] };
fieldsAndBounds( 3,:)  = { 'meanEnergy';        []; []; [] };
fieldsAndBounds( 4,:)  = { 'energyVariance';    []; []; [] };
fieldsAndBounds( 5,:)  = { 'energySkewness';    []; []; [] };
fieldsAndBounds( 6,:)  = { 'energyKurtosis';    []; []; [] };

remove_field_and_test_for_failure(pmdInputStruct.inputTsData.blackCosmicRayMetrics,        'pmdInputStruct.inputTsData.blackCosmicRayMetrics', ...
     pmdInputStruct, 'pmdInputStruct', 'pmdScienceClass', fieldsAndBounds, true, true);
remove_field_and_test_for_failure(pmdInputStruct.inputTsData.maskedSmearCosmicRayMetrics,  'pmdInputStruct.inputTsData.maskedSmearCosmicRayMetrics', ...
     pmdInputStruct, 'pmdInputStruct', 'pmdScienceClass', fieldsAndBounds, true, true);
remove_field_and_test_for_failure(pmdInputStruct.inputTsData.virtualSmearCosmicRayMetrics, 'pmdInputStruct.inputTsData.virtualSmearCosmicRayMetrics', ...
     pmdInputStruct, 'pmdInputStruct', 'pmdScienceClass', fieldsAndBounds, true, true);
remove_field_and_test_for_failure(pmdInputStruct.inputTsData.targetStarCosmicRayMetrics,   'pmdInputStruct.inputTsData.targetStarCosmicRayMetrics', ...
     pmdInputStruct, 'pmdInputStruct', 'pmdScienceClass', fieldsAndBounds, true, true);
remove_field_and_test_for_failure(pmdInputStruct.inputTsData.backgroundCosmicRayMetrics,   'pmdInputStruct.inputTsData.backgroundCosmicRayMetrics', ...
     pmdInputStruct, 'pmdInputStruct', 'pmdScienceClass', fieldsAndBounds, true, true);

clear fieldsAndBounds;

%______________________________________________________________________
% fourth level validation
% validate the fields in pmdInputStruct.inputTsData.blackCosmicRayMetrics.hitRate
%______________________________________________________________________

fieldsAndBounds = cell(2,4);
fieldsAndBounds(1,:)  = { 'values';         [];     [];     []};                % TBD
fieldsAndBounds(2,:)  = { 'gapIndicators';  [];     [];     [true, false]};

remove_field_and_test_for_failure(pmdInputStruct.inputTsData.blackCosmicRayMetrics.hitRate,                'pmdInputStruct.inputTsData.blackCosmicRayMetrics.hitRate', ...
    pmdInputStruct, 'pmdInputStruct', 'pmdScienceClass', fieldsAndBounds, true, true);

clear fieldsAndBounds;

%______________________________________________________________________
% fourth level validation
% validate the fields in pmdInputStruct.inputTsData.blackCosmicRayMetrics.meanEnergy
%______________________________________________________________________

fieldsAndBounds = cell(2,4);
fieldsAndBounds(1,:)  = { 'values';         [];     [];     []};                % TBD
fieldsAndBounds(2,:)  = { 'gapIndicators';  [];     [];     [true, false]};

remove_field_and_test_for_failure(pmdInputStruct.inputTsData.blackCosmicRayMetrics.meanEnergy,             'pmdInputStruct.inputTsData.blackCosmicRayMetrics.meanEnergy', ...
    pmdInputStruct, 'pmdInputStruct', 'pmdScienceClass', fieldsAndBounds, true, true);

clear fieldsAndBounds;

%______________________________________________________________________
% fourth level validation
% validate the fields in pmdInputStruct.inputTsData.blackCosmicRayMetrics.energyVariance
%______________________________________________________________________

fieldsAndBounds = cell(2,4);
fieldsAndBounds(1,:)  = { 'values';         [];     [];     []};                % TBD
fieldsAndBounds(2,:)  = { 'gapIndicators';  [];     [];     [true, false]};

remove_field_and_test_for_failure(pmdInputStruct.inputTsData.blackCosmicRayMetrics.energyVariance,         'pmdInputStruct.inputTsData.blackCosmicRayMetrics.energyVariance', ...
    pmdInputStruct, 'pmdInputStruct', 'pmdScienceClass', fieldsAndBounds, true, true);

clear fieldsAndBounds;

%______________________________________________________________________
% fourth level validation
% validate the fields in pmdInputStruct.inputTsData.blackCosmicRayMetrics.energySkewness
%______________________________________________________________________

fieldsAndBounds = cell(2,4);
fieldsAndBounds(1,:)  = { 'values';         [];     [];     []};                % TBD
fieldsAndBounds(2,:)  = { 'gapIndicators';  [];     [];     [true, false]};

remove_field_and_test_for_failure(pmdInputStruct.inputTsData.blackCosmicRayMetrics.energySkewness,         'pmdInputStruct.inputTsData.blackCosmicRayMetrics.energySkewness', ...
    pmdInputStruct, 'pmdInputStruct', 'pmdScienceClass', fieldsAndBounds, true, true);

clear fieldsAndBounds;

%______________________________________________________________________
% fourth level validation
% validate the fields in pmdInputStruct.inputTsData.blackCosmicRayMetrics.energyKurtosis
%______________________________________________________________________

fieldsAndBounds = cell(2,4);
fieldsAndBounds(1,:)  = { 'values';         [];     [];     []};                % TBD
fieldsAndBounds(2,:)  = { 'gapIndicators';  [];     [];     [true, false]};

remove_field_and_test_for_failure(pmdInputStruct.inputTsData.blackCosmicRayMetrics.energyKurtosis,         'pmdInputStruct.inputTsData.blackCosmicRayMetrics.energyKurtosis', ...
    pmdInputStruct, 'pmdInputStruct', 'pmdScienceClass', fieldsAndBounds, true, true);

clear fieldsAndBounds;

%______________________________________________________________________
% fourth level validation
% validate the fields in pmdInputStruct.inputTsData.maskedSmearCosmicRayMetrics.hitRate
%______________________________________________________________________

fieldsAndBounds = cell(2,4);
fieldsAndBounds(1,:)  = { 'values';         [];     [];     []};                % TBD
fieldsAndBounds(2,:)  = { 'gapIndicators';  [];     [];     [true, false]};

remove_field_and_test_for_failure(pmdInputStruct.inputTsData.maskedSmearCosmicRayMetrics.hitRate,          'pmdInputStruct.inputTsData.maskedSmearCosmicRayMetrics.hitRate', ...
    pmdInputStruct, 'pmdInputStruct', 'pmdScienceClass', fieldsAndBounds, true, true);

clear fieldsAndBounds;

%______________________________________________________________________
% fourth level validation
% validate the fields in pmdInputStruct.inputTsData.maskedSmearCosmicRayMetrics.meanEnergy
%______________________________________________________________________

fieldsAndBounds = cell(2,4);
fieldsAndBounds(1,:)  = { 'values';         [];     [];     []};                % TBD
fieldsAndBounds(2,:)  = { 'gapIndicators';  [];     [];     [true, false]};

remove_field_and_test_for_failure(pmdInputStruct.inputTsData.maskedSmearCosmicRayMetrics.meanEnergy,       'pmdInputStruct.inputTsData.maskedSmearCosmicRayMetrics.meanEnergy', ...
    pmdInputStruct, 'pmdInputStruct', 'pmdScienceClass', fieldsAndBounds, true, true);

clear fieldsAndBounds;

%______________________________________________________________________
% fourth level validation
% validate the fields in pmdInputStruct.inputTsData.maskedSmearCosmicRayMetrics.energyVariance
%______________________________________________________________________

fieldsAndBounds = cell(2,4);
fieldsAndBounds(1,:)  = { 'values';         [];     [];     []};                % TBD
fieldsAndBounds(2,:)  = { 'gapIndicators';  [];     [];     [true, false]};

remove_field_and_test_for_failure(pmdInputStruct.inputTsData.maskedSmearCosmicRayMetrics.energyVariance,   'pmdInputStruct.inputTsData.maskedSmearCosmicRayMetrics.energyVariance', ...
    pmdInputStruct, 'pmdInputStruct', 'pmdScienceClass', fieldsAndBounds, true, true);

clear fieldsAndBounds;

%______________________________________________________________________
% fourth level validation
% validate the fields in pmdInputStruct.inputTsData.maskedSmearCosmicRayMetrics.energySkewness
%______________________________________________________________________

fieldsAndBounds = cell(2,4);
fieldsAndBounds(1,:)  = { 'values';         [];     [];     []};                % TBD
fieldsAndBounds(2,:)  = { 'gapIndicators';  [];     [];     [true, false]};

remove_field_and_test_for_failure(pmdInputStruct.inputTsData.maskedSmearCosmicRayMetrics.energySkewness,   'pmdInputStruct.inputTsData.maskedSmearCosmicRayMetrics.energySkewness', ...
    pmdInputStruct, 'pmdInputStruct', 'pmdScienceClass', fieldsAndBounds, true, true);

clear fieldsAndBounds;

%______________________________________________________________________
% fourth level validation
% validate the fields in pmdInputStruct.inputTsData.maskedSmearCosmicRayMetrics.energyKurtosis
%______________________________________________________________________

fieldsAndBounds = cell(2,4);
fieldsAndBounds(1,:)  = { 'values';         [];     [];     []};                % TBD
fieldsAndBounds(2,:)  = { 'gapIndicators';  [];     [];     [true, false]};

remove_field_and_test_for_failure(pmdInputStruct.inputTsData.maskedSmearCosmicRayMetrics.energyKurtosis,   'pmdInputStruct.inputTsData.maskedSmearCosmicRayMetrics.energyKurtosis', ...
    pmdInputStruct, 'pmdInputStruct', 'pmdScienceClass', fieldsAndBounds, true, true);

clear fieldsAndBounds;

%______________________________________________________________________
% fourth level validation
% validate the fields in pmdInputStruct.inputTsData.virtualSmearCosmicRayMetrics.hitRate
%______________________________________________________________________

fieldsAndBounds = cell(2,4);
fieldsAndBounds(1,:)  = { 'values';         [];     [];     []};                % TBD
fieldsAndBounds(2,:)  = { 'gapIndicators';  [];     [];     [true, false]};

remove_field_and_test_for_failure(pmdInputStruct.inputTsData.virtualSmearCosmicRayMetrics.hitRate,         'pmdInputStruct.inputTsData.virtualSmearCosmicRayMetrics.hitRate', ...
    pmdInputStruct, 'pmdInputStruct', 'pmdScienceClass', fieldsAndBounds, true, true);

clear fieldsAndBounds;

%______________________________________________________________________
% fourth level validation
% validate the fields in pmdInputStruct.inputTsData.virtualSmearCosmicRayMetrics.meanEnergy
%______________________________________________________________________

fieldsAndBounds = cell(2,4);
fieldsAndBounds(1,:)  = { 'values';         [];     [];     []};                % TBD
fieldsAndBounds(2,:)  = { 'gapIndicators';  [];     [];     [true, false]};

remove_field_and_test_for_failure(pmdInputStruct.inputTsData.virtualSmearCosmicRayMetrics.meanEnergy,      'pmdInputStruct.inputTsData.virtualSmearCosmicRayMetrics.meanEnergy', ...
    pmdInputStruct, 'pmdInputStruct', 'pmdScienceClass', fieldsAndBounds, true, true);

clear fieldsAndBounds;

%______________________________________________________________________
% fourth level validation
% validate the fields in pmdInputStruct.inputTsData.virtualSmearCosmicRayMetrics.energyVariance
%______________________________________________________________________

fieldsAndBounds = cell(2,4);
fieldsAndBounds(1,:)  = { 'values';         [];     [];     []};                % TBD
fieldsAndBounds(2,:)  = { 'gapIndicators';  [];     [];     [true, false]};

remove_field_and_test_for_failure(pmdInputStruct.inputTsData.virtualSmearCosmicRayMetrics.energyVariance,  'pmdInputStruct.inputTsData.virtualSmearCosmicRayMetrics.energyVariance', ...
    pmdInputStruct, 'pmdInputStruct', 'pmdScienceClass', fieldsAndBounds, true, true);

clear fieldsAndBounds;

%______________________________________________________________________
% fourth level validation
% validate the fields in pmdInputStruct.inputTsData.virtualSmearCosmicRayMetrics.energySkewness
%______________________________________________________________________

fieldsAndBounds = cell(2,4);
fieldsAndBounds(1,:)  = { 'values';         [];     [];     []};                % TBD
fieldsAndBounds(2,:)  = { 'gapIndicators';  [];     [];     [true, false]};

remove_field_and_test_for_failure(pmdInputStruct.inputTsData.virtualSmearCosmicRayMetrics.energySkewness,  'pmdInputStruct.inputTsData.virtualSmearCosmicRayMetrics.energySkewness', ...
    pmdInputStruct, 'pmdInputStruct', 'pmdScienceClass', fieldsAndBounds, true, true);

clear fieldsAndBounds;

%______________________________________________________________________
% fourth level validation
% validate the fields in pmdInputStruct.inputTsData.virtualSmearCosmicRayMetrics.energyKurtosis
%______________________________________________________________________

fieldsAndBounds = cell(2,4);
fieldsAndBounds(1,:)  = { 'values';         [];     [];     []};                % TBD
fieldsAndBounds(2,:)  = { 'gapIndicators';  [];     [];     [true, false]};

remove_field_and_test_for_failure(pmdInputStruct.inputTsData.virtualSmearCosmicRayMetrics.energyKurtosis,  'pmdInputStruct.inputTsData.virtualSmearCosmicRayMetrics.energyKurtosis', ...
    pmdInputStruct, 'pmdInputStruct', 'pmdScienceClass', fieldsAndBounds, true, true);

clear fieldsAndBounds;

%______________________________________________________________________
% fourth level validation
% validate the fields in pmdInputStruct.inputTsData.targetStarCosmicRayMetrics.hitRate
%______________________________________________________________________

fieldsAndBounds = cell(2,4);
fieldsAndBounds(1,:)  = { 'values';         [];     [];     []};                % TBD
fieldsAndBounds(2,:)  = { 'gapIndicators';  [];     [];     [true, false]};

remove_field_and_test_for_failure(pmdInputStruct.inputTsData.targetStarCosmicRayMetrics.hitRate,           'pmdInputStruct.inputTsData.targetStarCosmicRayMetrics.hitRate', ...
    pmdInputStruct, 'pmdInputStruct', 'pmdScienceClass', fieldsAndBounds, true, true);

clear fieldsAndBounds;

%______________________________________________________________________
% fourth level validation
% validate the fields in pmdInputStruct.inputTsData.targetStarCosmicRayMetrics.meanEnergy
%______________________________________________________________________

fieldsAndBounds = cell(2,4);
fieldsAndBounds(1,:)  = { 'values';         [];     [];     []};                % TBD
fieldsAndBounds(2,:)  = { 'gapIndicators';  [];     [];     [true, false]};

remove_field_and_test_for_failure(pmdInputStruct.inputTsData.targetStarCosmicRayMetrics.meanEnergy,        'pmdInputStruct.inputTsData.targetStarCosmicRayMetrics.meanEnergy', ...
    pmdInputStruct, 'pmdInputStruct', 'pmdScienceClass', fieldsAndBounds, true, true);

clear fieldsAndBounds;

%______________________________________________________________________
% fourth level validation
% validate the fields in pmdInputStruct.inputTsData.targetStarCosmicRayMetrics.energyVariance
%______________________________________________________________________

fieldsAndBounds = cell(2,4);
fieldsAndBounds(1,:)  = { 'values';         [];     [];     []};                % TBD
fieldsAndBounds(2,:)  = { 'gapIndicators';  [];     [];     [true, false]};

remove_field_and_test_for_failure(pmdInputStruct.inputTsData.targetStarCosmicRayMetrics.energyVariance,    'pmdInputStruct.inputTsData.targetStarCosmicRayMetrics.energyVariance', ...
    pmdInputStruct, 'pmdInputStruct', 'pmdScienceClass', fieldsAndBounds, true, true);

clear fieldsAndBounds;

%______________________________________________________________________
% fourth level validation
% validate the fields in pmdInputStruct.inputTsData.targetStarCosmicRayMetrics.energySkewness
%______________________________________________________________________

fieldsAndBounds = cell(2,4);
fieldsAndBounds(1,:)  = { 'values';         [];     [];     []};                % TBD
fieldsAndBounds(2,:)  = { 'gapIndicators';  [];     [];     [true, false]};

remove_field_and_test_for_failure(pmdInputStruct.inputTsData.targetStarCosmicRayMetrics.energySkewness,    'pmdInputStruct.inputTsData.targetStarCosmicRayMetrics.energySkewness', ...
    pmdInputStruct, 'pmdInputStruct', 'pmdScienceClass', fieldsAndBounds, true, true);

clear fieldsAndBounds;

%______________________________________________________________________
% fourth level validation
% validate the fields in pmdInputStruct.inputTsData.targetStarCosmicRayMetrics.energyKurtosis
%______________________________________________________________________

fieldsAndBounds = cell(2,4);
fieldsAndBounds(1,:)  = { 'values';         [];     [];     []};                % TBD
fieldsAndBounds(2,:)  = { 'gapIndicators';  [];     [];     [true, false]};

remove_field_and_test_for_failure(pmdInputStruct.inputTsData.targetStarCosmicRayMetrics.energyKurtosis,    'pmdInputStruct.inputTsData.targetStarCosmicRayMetrics.energyKurtosis', ...
    pmdInputStruct, 'pmdInputStruct', 'pmdScienceClass', fieldsAndBounds, true, true);

clear fieldsAndBounds;

%______________________________________________________________________
% fourth level validation
% validate the fields in pmdInputStruct.inputTsData.backgroundCosmicRayMetrics.hitRate
%______________________________________________________________________

fieldsAndBounds = cell(2,4);
fieldsAndBounds(1,:)  = { 'values';         [];     [];     []};                % TBD
fieldsAndBounds(2,:)  = { 'gapIndicators';  [];     [];     [true, false]};

remove_field_and_test_for_failure(pmdInputStruct.inputTsData.backgroundCosmicRayMetrics.hitRate,           'pmdInputStruct.inputTsData.backgroundCosmicRayMetrics.hitRate', ...
    pmdInputStruct, 'pmdInputStruct', 'pmdScienceClass', fieldsAndBounds, true, true);

clear fieldsAndBounds;

%______________________________________________________________________
% fourth level validation
% validate the fields in pmdInputStruct.inputTsData.backgroundCosmicRayMetrics.meanEnergy
%______________________________________________________________________

fieldsAndBounds = cell(2,4);
fieldsAndBounds(1,:)  = { 'values';         [];     [];     []};                % TBD
fieldsAndBounds(2,:)  = { 'gapIndicators';  [];     [];     [true, false]};

remove_field_and_test_for_failure(pmdInputStruct.inputTsData.backgroundCosmicRayMetrics.meanEnergy,        'pmdInputStruct.inputTsData.backgroundCosmicRayMetrics.meanEnergy', ...
    pmdInputStruct, 'pmdInputStruct', 'pmdScienceClass', fieldsAndBounds, true, true);

clear fieldsAndBounds;

%______________________________________________________________________
% fourth level validation
% validate the fields in pmdInputStruct.inputTsData.backgroundCosmicRayMetrics.energyVariance
%______________________________________________________________________

fieldsAndBounds = cell(2,4);
fieldsAndBounds(1,:)  = { 'values';         [];     [];     []};                % TBD
fieldsAndBounds(2,:)  = { 'gapIndicators';  [];     [];     [true, false]};

remove_field_and_test_for_failure(pmdInputStruct.inputTsData.backgroundCosmicRayMetrics.energyVariance,    'pmdInputStruct.inputTsData.backgroundCosmicRayMetrics.energyVariance', ...
    pmdInputStruct, 'pmdInputStruct', 'pmdScienceClass', fieldsAndBounds, true, true);

clear fieldsAndBounds;

%______________________________________________________________________
% fourth level validation
% validate the fields in pmdInputStruct.inputTsData.backgroundCosmicRayMetrics.energySkewness
%______________________________________________________________________

fieldsAndBounds = cell(2,4);
fieldsAndBounds(1,:)  = { 'values';         [];     [];     []};                % TBD
fieldsAndBounds(2,:)  = { 'gapIndicators';  [];     [];     [true, false]};

remove_field_and_test_for_failure(pmdInputStruct.inputTsData.backgroundCosmicRayMetrics.energySkewness,    'pmdInputStruct.inputTsData.backgroundCosmicRayMetrics.energySkewness', ...
    pmdInputStruct, 'pmdInputStruct', 'pmdScienceClass', fieldsAndBounds, true, true);

clear fieldsAndBounds;

%______________________________________________________________________
% fourth level validation
% validate the fields in pmdInputStruct.inputTsData.backgroundCosmicRayMetrics.energyKurtosis
%______________________________________________________________________

fieldsAndBounds = cell(2,4);
fieldsAndBounds(1,:)  = { 'values';         [];     [];     []};                % TBD
fieldsAndBounds(2,:)  = { 'gapIndicators';  [];     [];     [true, false]};

remove_field_and_test_for_failure(pmdInputStruct.inputTsData.backgroundCosmicRayMetrics.energyKurtosis,    'pmdInputStruct.inputTsData.backgroundCosmicRayMetrics.energyKurtosis', ...
    pmdInputStruct, 'pmdInputStruct', 'pmdScienceClass', fieldsAndBounds, true, true);

clear fieldsAndBounds;

%______________________________________________________________________
% second level validation
% validate the fields in pmdInputStruct.cdppTsData
%______________________________________________________________________

if ~isempty(pmdInputStruct.cdppTsData)

    % pmdInputStruct.cdppTsData fields
    fieldsAndBounds = cell(6,4);
    fieldsAndBounds(1,:)  = { 'keplerId';       '> 0';  '< 1e9';    []}; 
    fieldsAndBounds(2,:)  = { 'keplerMag';      '> 0';  '< 20';     []}; 
    fieldsAndBounds(3,:)  = { 'cdpp3Hr';        [];     [];         []};                % TBD
    fieldsAndBounds(4,:)  = { 'cdpp6Hr';        [];     [];         []};                % TBD
    fieldsAndBounds(5,:)  = { 'cdpp12Hr';       [];     [];         []};                % TBD
    fieldsAndBounds(6,:)  = { 'fluxTimeSeries'; [];     [];         []};                % structure

    remove_field_and_test_for_failure(pmdInputStruct.cdppTsData,    'pmdInputStruct.cdppTsData', ...
        pmdInputStruct, 'pmdInputStruct', 'pmdScienceClass', fieldsAndBounds, true, true);

    clear fieldsAndBounds;

    %--------------------------------------------------------------------------
    % third level validation.
    % Validate the structure field pmdInputStruct.cdppTsData.fluxTimeSeries
    %--------------------------------------------------------------------------

    fluxTsFields = { 'values';          ...
                     'gapIndicators';   ...
                     'uncertainties';   ...
                     'filledIndices'       };

    for iField = 1:length(fluxTsFields)
        pmdInputStructFail = pmdInputStruct;
        pmdInputStructFail.cdppTsData(1).fluxTimeSeries = rmfield(pmdInputStructFail.cdppTsData(1).fluxTimeSeries, fluxTsFields{iField});
        try_to_catch_error_condition('a=pmdScienceClass(pmdInputStruct)', fluxTsFields{iField}, pmdInputStructFail,'pmdInputStruct');
    end

    fluxTimeSeries = [pmdInputStruct.cdppTsData.fluxTimeSeries];

    for iField = 1:length(fluxTsFields)
        fluxTimeSeriesFail = rmfield(fluxTimeSeries, fluxTsFields{iField});
        pmdInputStructFail = pmdInputStruct;
        for iTargetStar = 1:length(pmdInputStruct.cdppTsData)
            pmdInputStructFail.cdppTsData(iTargetStar).fluxTimeSeries = fluxTimeSeriesFail(iTargetStar);
        end
        try_to_catch_error_condition('a=pmdScienceClass(pmdInputStruct)', fluxTsFields{iField}, pmdInputStructFail,'pmdInputStruct') ;
    end

end

%______________________________________________________________________
% second level validation
% validate the fields in pmdInputStruct.badPixels
%______________________________________________________________________

if ~isempty(pmdInputStruct.badPixels)

    % pmdInputStruct.badPixels fields
    fieldsAndBounds = cell(6,4);
    fieldsAndBounds(1,:)  = { 'ccdRow';         '>= 0';         '< 1070';       [] };
    fieldsAndBounds(2,:)  = { 'ccdColumn';      '>= 0';         '< 1132';       [] };
    fieldsAndBounds(3,:)  = { 'startMjd';       '>= 54000';     '<= 64000'; 	[] };
    fieldsAndBounds(4,:)  = { 'endMjd';         '>= 54000';     '<= 64000'; 	[] };
    fieldsAndBounds(5,:)  = { 'type';           [];             [];             [] };   % TBD
    fieldsAndBounds(6,:)  = { 'value';          [];             [];             [] };   % TBD

    remove_field_and_test_for_failure(pmdInputStruct.badPixels,    'pmdInputStruct.badPixels', ...
        pmdInputStruct, 'pmdInputStruct', 'pmdScienceClass', fieldsAndBounds, true, true);

    clear fieldsAndBounds;

end

%--------------------------------------------------------------------------
% second level validation.
% Validate the structure field pmdInputStruct.backgroundPolyStruct
%--------------------------------------------------------------------------

% pmdInputStruct.backgroundPolyStruct fields
% fieldsAndBounds = cell(8,4);
% fieldsAndBounds(1,:)  = { 'cadence';                '>= -1';    '< 2e7';    [] };
% fieldsAndBounds(2,:)  = { 'mjdStartTime';           '>= -1';    '<= 64000'; [] };
% fieldsAndBounds(3,:)  = { 'mjdMidTime';             '>= -1';    '<= 64000'; [] };
% fieldsAndBounds(4,:)  = { 'mjdEndTime';             '>= -1';    '<= 64000'; [] };
% fieldsAndBounds(5,:)  = { 'module';                 [];         [];         '[-1 2:4, 6:20, 22:24]''' };
% fieldsAndBounds(6,:)  = { 'output';                 [];         [];         '[-1 1 2 3 4]''' };
% fieldsAndBounds(7,:)  = { 'backgroundPoly';         [];         [];         [] };
% fieldsAndBounds(8,:)  = { 'backgroundPolyStatus';   [];         [];         '[0 1]''' };
% 
% remove_field_and_test_for_failure(pmdInputStruct.backgroundPolyStruct,    'pmdInputStruct.backgroundPolyStruct', ...
%     pmdInputStruct, 'pmdInputStruct', 'pmdScienceClass', fieldsAndBounds, true, true);
% 
% clear fieldsAndBounds;
% 
%--------------------------------------------------------------------------
% third level validation.
% Validate the structure field pmdInputStruct.backgroundPolyStruct.backgroundPoly
%--------------------------------------------------------------------------
% 
% polyFields = { 'offsetx'; ...
%                'scalex';  ...
%                'originx'; ...
%                'offsety'; ...
%                'scaley';  ...
%                'originy'; ...
%                'xindex';  ...
%                'yindex';  ...
%                'type';    ...
%                'order';   ...
%                'message'; ...
%                'coeffs';  ...
%                'covariance' };
% 
% for iField = 1:length(polyFields)
%     pmdInputStructFail = pmdInputStruct;
%     pmdInputStructFail.backgroundPolyStruct(1).backgroundPoly = rmfield(pmdInputStructFail.backgroundPolyStruct(1).backgroundPoly, polyFields{iField});
%     try_to_catch_error_condition('a=pmdScienceClass(pmdInputStruct)', polyFields{iField}, pmdInputStructFail,'pmdInputStruct');
% end
% 
% backgroundPoly = [pmdInputStruct.backgroundPolyStruct.backgroundPoly];
% 
% for iField = 1:length(polyFields)
%     backgroundPolyFail = rmfield(backgroundPoly,polyFields{iField});
%     pmdInputStructFail = pmdInputStruct;
%     for iCadence = 1:length(pmdInputStruct.backgroundPolyStruct)
%         pmdInputStructFail.backgroundPolyStruct(iCadence).backgroundPoly = backgroundPolyFail(iCadence);
%     end
%     try_to_catch_error_condition('a=pmdScienceClass(pmdInputStruct)', polyFields{iField}, pmdInputStructFail,'pmdInputStruct') ;
% end

%--------------------------------------------------------------------------
% second level validation.
% Validate the structure field pmdInputStruct.motionPolyStruct
%--------------------------------------------------------------------------

% pmdInputStruct.motionPolyStruct fields
% fieldsAndBounds = cell(10,4);
% fieldsAndBounds( 1,:)  = { 'cadence';               '>= -1';    '< 2e7';    [] };
% fieldsAndBounds( 2,:)  = { 'mjdStartTime';          '>= -1';    '<= 64000'; [] };
% fieldsAndBounds( 3,:)  = { 'mjdMidTime';            '>= -1';    '<= 64000'; [] };
% fieldsAndBounds( 4,:)  = { 'mjdEndTime';            '>= -1';    '<= 64000'; [] };
% fieldsAndBounds( 5,:)  = { 'module';                [];         [];         '[-1 2:4, 6:20, 22:24]''' };
% fieldsAndBounds( 6,:)  = { 'output';                [];         [];         '[-1 1 2 3 4]''' };
% fieldsAndBounds( 7,:)  = { 'rowPoly';               [];         [];         [] };                  % a structure
% fieldsAndBounds( 8,:)  = { 'rowPolyStatus';         [];         [];         '[0 1]''' };
% fieldsAndBounds( 9,:)  = { 'colPoly';               [];         [];         [] };                  % a structure
% fieldsAndBounds(10,:)  = { 'colPolyStatus';         [];         [];         '[0 1]''' };
% 
% remove_field_and_test_for_failure(pmdInputStruct.motionPolyStruct,    'pmdInputStruct.motionPolyStruct', ...
%     pmdInputStruct, 'pmdInputStruct', 'pmdScienceClass', fieldsAndBounds, true, true);
% 
% clear fieldsAndBounds;

%--------------------------------------------------------------------------
% third level validation.
% Validate the structure field pmdInputStruct.motionPolyStruct.rowPoly and
%                              pmdInputStruct.motionPolyStruct.colPoly 
%--------------------------------------------------------------------------
% 
% for iField = 1:length(polyFields)
% 
%     pmdInputStructFail = pmdInputStruct;
%     pmdInputStructFail.motionPolyStruct(1).rowPoly = rmfield(pmdInputStructFail.motionPolyStruct(1).rowPoly, polyFields{iField});
%     try_to_catch_error_condition('a=pmdScienceClass(pmdInputStruct)', polyFields{iField}, pmdInputStructFail,'pmdInputStruct');
% 
%     pmdInputStructFail = pmdInputStruct;
%     pmdInputStructFail.motionPolyStruct(1).colPoly = rmfield(pmdInputStructFail.motionPolyStruct(1).colPoly,polyFields{iField});
%     try_to_catch_error_condition('a=pmdScienceClass(pmdInputStruct)', polyFields{iField}, pmdInputStructFail,'pmdInputStruct');
% 
% end
% 
% rowPoly = [pmdInputStruct.motionPolyStruct.rowPoly];
% colPoly = [pmdInputStruct.motionPolyStruct.colPoly];
% 
% for iField = 1:length(polyFields)
% 
%     rowPolyFail = rmfield(rowPoly, polyFields{iField});
%     colPolyFail = rmfield(colPoly, polyFields{iField});
% 
%     pmdInputStructFail = pmdInputStruct;
%     for iCadence = 1:length(pmdInputStruct.motionPolyStruct)
%         pmdInputStructFail.motionPolyStruct(iCadence).rowPoly = rowPolyFail(iCadence);
%     end
%     try_to_catch_error_condition('a=pmdScienceClass(pmdInputStruct)', polyFields{iField}, pmdInputStructFail,'pmdInputStruct') ;
% 
%     pmdInputStructFail = pmdInputStruct;
%     for iCadence = 1:length(pmdInputStruct.motionPolyStruct)
%         pmdInputStructFail.motionPolyStruct(iCadence).colPoly = colPolyFail(iCadence);
%     end
%     try_to_catch_error_condition('a=pmdScienceClass(pmdInputStruct)', polyFields{iField}, pmdInputStructFail,'pmdInputStruct') ;
% 
% end

%--------------------------------------------------------------------------
% second level validation.
% Validate the structure field pmdInputStruct.ancillaryEngineeringParameters
%--------------------------------------------------------------------------

% pmdInputStruct.ancillaryEngineeringParameters fields
if ~isempty(pmdInputStruct.ancillaryEngineeringData)

    fieldsAndBounds = cell(5,4);
    fieldsAndBounds(1,:)  = { 'mnemonics';                  [];         [];     {} };
    fieldsAndBounds(2,:)  = { 'modelOrders';                '>= 0';     '<= 5'; [] };
    fieldsAndBounds(3,:)  = { 'interactions';               [];         [];     {} };
    fieldsAndBounds(4,:)  = { 'quantizationLevels';         '>= 0';     [];     [] };   % TBD
    fieldsAndBounds(5,:)  = { 'intrinsicUncertainties';     '>= 0';     [];     [] };   % TBD

    remove_field_and_test_for_failure(pmdInputStruct.ancillaryEngineeringParameters,    'pmdInputStruct.ancillaryEngineeringParameters', ...
        pmdInputStruct, 'pmdInputStruct', 'pmdScienceClass', fieldsAndBounds, true, true);

    clear fieldsAndBounds;

end

%--------------------------------------------------------------------------
% second level validation.
% Validate the structure field pmdInputStruct.ancillaryEngineeringData if it exists.
%--------------------------------------------------------------------------
if ~isempty(pmdInputStruct.ancillaryEngineeringData)
    
    % pmdInputStruct.ancillaryEngineeringData fields
    fieldsAndBounds = cell(3,4);
    fieldsAndBounds(1,:)  = { 'mnemonic';   [];         [];         {} };
    fieldsAndBounds(2,:)  = { 'timestamps'; '>= 54000'; '<= 64000'; [] };
    fieldsAndBounds(3,:)  = { 'values';     [];         [];         [] };           % TBD

    remove_field_and_test_for_failure(pmdInputStruct.ancillaryEngineeringData,    'pmdInputStruct.ancillaryEngineeringData', ...
        pmdInputStruct, 'pmdInputStruct', 'pmdScienceClass', fieldsAndBounds, true, true);
    
    clear fieldsAndBounds;

end % if

%--------------------------------------------------------------------------
% second level validation.
% Validate the structure field pmdInputStruct.ancillaryPipelinearameters
%--------------------------------------------------------------------------
if ~isempty(pmdInputStruct.ancillaryPipelineData)

    % pmdInputStruct.ancillaryPipelineParameters fields
    fieldsAndBounds = cell(3,4);
    fieldsAndBounds(1,:)  = { 'mnemonics';      [];     [];     {} };
    fieldsAndBounds(2,:)  = { 'modelOrders';    '>= 0'; '<= 5'; [] };
    fieldsAndBounds(3,:)  = { 'interactions';   [];     [];     {} };

    remove_field_and_test_for_failure(pmdInputStruct.ancillaryPipelineParameters,    'pmdInputStruct.ancillaryPipelineParameters', ...
        pmdInputStruct, 'pmdInputStruct', 'pmdScienceClass', fieldsAndBounds, true, true);

    clear fieldsAndBounds;

end

%--------------------------------------------------------------------------
% second level validation.
% Validate the structure field pmdInputStruct.ancillaryPipelineData if it exists.
%--------------------------------------------------------------------------
if ~isempty(pmdInputStruct.ancillaryPipelineData)
    
    % pmdInputStruct.ancillaryPipelineData fields
    fieldsAndBounds = cell(4,4);
    fieldsAndBounds(1,:)  = { 'mnemonic';       [];         [];         {} };
    fieldsAndBounds(2,:)  = { 'timestamps';     '>= 54000'; '<= 64000'; [] };
    fieldsAndBounds(3,:)  = { 'values';         [];         [];         [] };       % TBD
    fieldsAndBounds(4,:)  = { 'uncertainties';  [];         [];         [] };       % TBD

    remove_field_and_test_for_failure(pmdInputStruct.ancillaryPipelineData,    'pmdInputStruct.ancillaryPipelineData', ...
        pmdInputStruct, 'pmdInputStruct', 'pmdScienceClass', fieldsAndBounds, true, true);
    
    clear fieldsAndBounds;

end % if

%------------------------------------------------------------

fprintf('\n');
return;

%==========================================================================



