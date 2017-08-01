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
%         Example:  run(text_test_runner, testPAGClass('test_for_missing_inputs'));
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

clear pagInputStruct;
clear pagScienceClass;

fprintf('\nTest PAG: missing inputs\n');

% load a valid PAG input structure
initialize_soc_variables;
pagTestDataRoot = fullfile(socTestDataRoot, 'ppa', 'MATLAB', 'unit-tests', 'pag');
addpath(pagTestDataRoot);
load pagInputStruct.mat;

%______________________________________________________________________
% top level validation
% validate the structure pagInputStruct
%______________________________________________________________________


% pagInputStruct fields
fieldsAndBounds = cell(6,4);

fieldsAndBounds( 1,:)  = { 'fcConstants';                    []; []; [] };      % structure, do not validate
fieldsAndBounds( 2,:)  = { 'spacecraftConfigMaps';           []; []; [] };      % structure array, do not validate
fieldsAndBounds( 3,:)  = { 'cadenceTimes';                   []; []; [] };      % structure 
fieldsAndBounds( 4,:)  = { 'pagModuleParameters';            []; []; [] };      % structure
fieldsAndBounds( 5,:)  = { 'inputTsData';                    []; []; [] };      % structure array
fieldsAndBounds( 6,:)  = { 'reports';                        []; []; [] };      % structure array


remove_field_and_test_for_failure(pagInputStruct, 'pagInputStruct', pagInputStruct, ...
    'pagInputStruct', 'pagScienceClass', fieldsAndBounds, true, true);

clear fieldsAndBounds;

%--------------------------------------------------------------------------
% second level validation.
% validate the fields in pagInputStruct.cadenceTimes
%--------------------------------------------------------------------------

% pmdInputStruct.cadenceTimes fields
fieldsAndBounds = cell(5,4);

fieldsAndBounds(1,:)   = { 'startTimestamps';   [];     []; 	[] };
fieldsAndBounds(2,:)   = { 'midTimestamps';     [];     [];     [] };
fieldsAndBounds(3,:)   = { 'endTimestamps';     [];     [];     [] };
fieldsAndBounds(4,:)   = { 'gapIndicators';     [];     [];     [true; false] };
fieldsAndBounds(5,:)   = { 'requantEnabled';    [];     [];     [true; false] };

remove_field_and_test_for_failure(pagInputStruct.cadenceTimes, 'pagInputStruct.cadenceTimes', pagInputStruct, ...
    'pagInputStruct', 'pagScienceClass', fieldsAndBounds, true, true);

clear fieldsAndBounds;

%______________________________________________________________________
% second level validation
% validate the structure field pagModuleParameters in pagInputStruct
%______________________________________________________________________

% pagInputStruct.pagModuleParameters fields
fieldsAndBounds = cell(11,4);

fieldsAndBounds( 1,:)  = { 'horizonTime';                                           '>= 0'; '<= 100';       [] }; 
fieldsAndBounds( 2,:)  = { 'trendFitTime';                                          '>= 0'; '<= 30';        [] };
fieldsAndBounds( 3,:)  = { 'minTrendFitSampleCount';                                '>= 0'; '<= 500';       [] };
fieldsAndBounds( 4,:)  = { 'initialAverageSampleCount';                             '>= 0'; '<= 500';       [] };
fieldsAndBounds( 5,:)  = { 'alertTime';                                             '>= 0'; '<= 30';        [] };

fieldsAndBounds( 6,:)  = { 'compressionSmoothingFactor';                            '>= 0'; '<= 1';         [] };
fieldsAndBounds( 7,:)  = { 'compressionFixedLowerBound';                            '>= 0'; '<= 20';        [] };  
fieldsAndBounds( 8,:)  = { 'compressionFixedUpperBound';                            '>= 0'; '<= 20';        [] };   
fieldsAndBounds( 9,:)  = { 'compressionAdaptiveXFactor';                            '>= 0'; '<= 100';       [] };   

fieldsAndBounds(10,:)  = { 'debugLevel';                                            '>= 0'; '<= 5';         [] };
fieldsAndBounds(11,:)  = { 'plottingEnabled';                                       [];     [];             [true false] };

remove_field_and_test_for_failure(pagInputStruct.pagModuleParameters, 'pagInputStruct.pagModuleParameters',...
    pagInputStruct, 'pagInputStruct', 'pagScienceClass', fieldsAndBounds, true, true);

clear fieldsAndBounds;

%______________________________________________________________________
% second level validation
% validate the fields in pagInputStruct.inputTsData  
%______________________________________________________________________

% pagInputStruct.inputTsData fields
fieldsAndBounds = cell(4,4);

fieldsAndBounds(1,:)  = { 'ccdModule';                          []; []; '[2:4, 6:20, 22:24]''' };
fieldsAndBounds(2,:)  = { 'ccdOutput';                          []; []; '[1 2 3 4]''' };
fieldsAndBounds(3,:)  = { 'theoreticalCompressionEfficiency';   []; []; [] };
fieldsAndBounds(4,:)  = { 'achievedCompressionEfficiency';      []; []; [] };

remove_field_and_test_for_failure(pagInputStruct.inputTsData, 'pagInputStruct.inputTsData', ...
    pagInputStruct, 'pagInputStruct', 'pagScienceClass', fieldsAndBounds, true, true);

clear fieldsAndBounds;

%______________________________________________________________________
% third level validation
% validate the fields in pagInputStruct.inputTsData.theoreticalCompressionEfficiency
%                        pagInputStruct.inputTsData.achievedCompressionEfficiency
%______________________________________________________________________

% pagInputStruct.inputTsData.compressionEfficiency fields
fieldsAndBounds = cell(3,4);

fieldsAndBounds(1,:)  = { 'values';         [];     [];     []};                % TBD
fieldsAndBounds(2,:)  = { 'gapIndicators';  [];     [];     [true, false]};
fieldsAndBounds(3,:)  = { 'nCodeSymbols';   [];     [];     []};

for i=1:length(pagInputStruct.inputTsData)
    remove_field_and_test_for_failure(pagInputStruct.inputTsData(i).theoreticalCompressionEfficiency, ...
        ['pagInputStruct.inputTsData(' num2str(i) ').theoreticalCompressionEfficiency'], ...
        pagInputStruct, 'pagInputStruct', 'pagScienceClass', fieldsAndBounds, true, true);
    remove_field_and_test_for_failure(pagInputStruct.inputTsData(i).achievedCompressionEfficiency, ...
        ['pagInputStruct.inputTsData(' num2str(i) ').achievedCompressionEfficiency'], ...
        pagInputStruct, 'pagInputStruct', 'pagScienceClass', fieldsAndBounds, true, true);
end

clear fieldsAndBounds;

%______________________________________________________________________
% second level validation
% validate the fields in pagInputStruct.reports
%______________________________________________________________________

% pagInputStruct.reports fields 
fieldsAndBounds = cell(23,4);

fieldsAndBounds( 1,:) = { 'ccdModule';                          []; []; '[2:4, 6:20, 22:24]''' };
fieldsAndBounds( 2,:) = { 'ccdOutput';                          []; []; '[1 2 3 4]''' };
fieldsAndBounds( 3,:) = { 'blackLevel';                         []; []; [] }; % structure
fieldsAndBounds( 4,:) = { 'smearLevel';                         []; []; [] }; % structure
fieldsAndBounds( 5,:) = { 'darkCurrent';                        []; []; [] }; % structure
fieldsAndBounds( 6,:) = { 'twoDBlack';                          []; []; [] }; % structure array
fieldsAndBounds( 7,:) = { 'ldeUndershoot';                      []; []; [] }; % structure array
fieldsAndBounds( 8,:) = { 'theoreticalCompressionEfficiency';   []; []; [] }; % structure
fieldsAndBounds( 9,:) = { 'achievedCompressionEfficiency';      []; []; [] }; % structure
fieldsAndBounds(10,:) = { 'blackCosmicRayMetrics';              []; []; [] }; % structure
fieldsAndBounds(11,:) = { 'maskedSmearCosmicRayMetrics';        []; []; [] }; % structure
fieldsAndBounds(12,:) = { 'virtualSmearCosmicRayMetrics';       []; []; [] }; % structure
fieldsAndBounds(13,:) = { 'targetStarCosmicRayMetrics';         []; []; [] }; % structure
fieldsAndBounds(14,:) = { 'backgroundCosmicRayMetrics';         []; []; [] }; % structure
fieldsAndBounds(15,:) = { 'brightness';                         []; []; [] }; % structure
fieldsAndBounds(16,:) = { 'encircledEnergy';                    []; []; [] }; % structure
fieldsAndBounds(17,:) = { 'backgroundLevel';                    []; []; [] }; % structure
fieldsAndBounds(18,:) = { 'centroidsMeanRow';                   []; []; [] }; % structure
fieldsAndBounds(19,:) = { 'centroidsMeanColumn';                []; []; [] }; % structure
fieldsAndBounds(20,:) = { 'plateScale';                         []; []; [] }; % structure
fieldsAndBounds(21,:) = { 'cdppMeasured';                       []; []; [] }; % structure
fieldsAndBounds(22,:) = { 'cdppExpected';                       []; []; [] }; % structure
fieldsAndBounds(23,:) = { 'cdppRatio';                          []; []; [] }; % structure

remove_field_and_test_for_failure(pagInputStruct.reports, 'pagInputStruct.reports', ...
    pagInputStruct, 'pagInputStruct', 'pagScienceClass', fieldsAndBounds, true, true);

clear fieldsAndBounds;

%______________________________________________________________________
% third level validation
% validate the fields in pagInputStruct.reports.blackCosmicRayMetrics
%                        pagInputStruct.reports.maskedSmearCosmicRayMetrics
%                        pagInputStruct.reports.virtualSmearCosmicRayMetrics
%                        pagInputStruct.reports.targetStarCosmicRayMetrics
%                        pagInputStruct.reports.backgroundCosmicRayMetrics
%______________________________________________________________________

crString      = { 'blackCosmicRayMetrics', 'maskedSmearCosmicRayMetrics', 'virtualSmearCosmicRayMetrics' ...
                  'targetStarCosmicRayMetrics', 'backgroundCosmicRayMetrics' };
crFieldString = { 'hitRate', 'meanEnergy', 'energyVariance', 'energySkewness', 'energyKurtosis' };        

% pagInputStruct.reports.cosmicRayMetrics fields
fieldsAndBounds = cell(5,4);
fieldsAndBounds( 1,:)  = { 'hitRate';           []; []; [] };
fieldsAndBounds( 2,:)  = { 'meanEnergy';        []; []; [] };
fieldsAndBounds( 3,:)  = { 'energyVariance';    []; []; [] };
fieldsAndBounds( 4,:)  = { 'energySkewness';    []; []; [] };
fieldsAndBounds( 5,:)  = { 'energyKurtosis';    []; []; [] };

nReports = length(pagInputStruct.reports);
for i=1:nReports
    for iCr=1:length(crString)
        remove_field_and_test_for_failure(pagInputStruct.reports(i).(crString{iCr}), ['pagInputStruct.reports(' num2str(i) ').' crString{iCr}], ...
            pagInputStruct, 'pagInputStruct', 'pagScienceClass', fieldsAndBounds, true, true);
    end
end

clear fieldsAndBounds;

%______________________________________________________________________
% third level validation
% validate the fields in pagInputStruct.reports.cdppMeasured
%                        pagInputStruct.reports.cdppExpected
%                        pagInputStruct.reports.cdppRatio
%______________________________________________________________________

magString  = {'mag9', 'mag10', 'mag11', 'mag12', 'mag13', 'mag14', 'mag15'};
hourString = {'threeHour', 'sixHour', 'twelveHour'};

% pagInputStruct.reports.cdppMetrics fields
fieldsAndBounds = cell(7,4);
fieldsAndBounds( 1,:)  = { 'mag9';              []; []; [] };
fieldsAndBounds( 2,:)  = { 'mag10';             []; []; [] };
fieldsAndBounds( 3,:)  = { 'mag11';             []; []; [] };
fieldsAndBounds( 4,:)  = { 'mag12';             []; []; [] };
fieldsAndBounds( 5,:)  = { 'mag13';             []; []; [] };
fieldsAndBounds( 6,:)  = { 'mag14';             []; []; [] };
fieldsAndBounds( 7,:)  = { 'mag15';             []; []; [] };

for i=1:nReports
    remove_field_and_test_for_failure(pagInputStruct.reports(i).cdppMeasured, ['pagInputStruct.reports(' num2str(i) ').cdppMeasured'], ...
        pagInputStruct, 'pagInputStruct', 'pagScienceClass', fieldsAndBounds, true, true);
    remove_field_and_test_for_failure(pagInputStruct.reports(i).cdppExpected, ['pagInputStruct.reports(' num2str(i) ').cdppExpected'], ...
        pagInputStruct, 'pagInputStruct', 'pagScienceClass', fieldsAndBounds, true, true);
    remove_field_and_test_for_failure(pagInputStruct.reports(i).cdppRatio,    ['pagInputStruct.reports(' num2str(i) ').cdppRatio'   ], ...
        pagInputStruct, 'pagInputStruct', 'pagScienceClass', fieldsAndBounds, true, true);
end

clear fieldsAndBounds;

%______________________________________________________________________
% fourth level validation
% validate the fields in pagInputStruct.reports.cdppMeasured.magN (N=9,10,11,12,13,14,15)
%                        pagInputStruct.reports.cdppExpected.magN
%                        pagInputStruct.reports.cdppRatio.magN
%______________________________________________________________________

% pagInputStruct.reports.cdppMetrics fields
fieldsAndBounds = cell(3,4);
fieldsAndBounds( 1,:)  = { 'threeHour';         []; []; [] };
fieldsAndBounds( 2,:)  = { 'sixHour';           []; []; [] };
fieldsAndBounds( 3,:)  = { 'twelveHour';        []; []; [] };

for i=1:nReports
    for iMag=1:length(magString)
        remove_field_and_test_for_failure(pagInputStruct.reports(i).cdppMeasured.(magString{iMag}), ...
            ['pagInputStruct.reports(' num2str(i) ').cdppMeasured.' magString{iMag}], ...
            pagInputStruct, 'pagInputStruct', 'pagScienceClass', fieldsAndBounds, true, true);
        remove_field_and_test_for_failure(pagInputStruct.reports(i).cdppExpected.(magString{iMag}), ...
            ['pagInputStruct.reports(' num2str(i) ').cdppExpected.' magString{iMag}], ...
            pagInputStruct, 'pagInputStruct', 'pagScienceClass', fieldsAndBounds, true, true);
        remove_field_and_test_for_failure(pagInputStruct.reports(i).cdppRatio.(magString{iMag}), ...
            ['pagInputStruct.reports(' num2str(i) ').cdppRatio.'    magString{iMag}], ...
            pagInputStruct, 'pagInputStruct', 'pagScienceClass', fieldsAndBounds, true, true);
    end
end

clear fieldsAndBounds;

%______________________________________________________________________
% third/fourth/fifth level validation
% validate the fields in pagInputStruct.reports.blackLevel
%                        pagInputStruct.reports.smearLevel
%                        pagInputStruct.reports.darkCurrent
%                        pagInputStruct.reports.theoreticalCompressionEfficiency
%                        pagInputStruct.reports.achievedCompressionEfficiency
%                        pagInputStruct.reports.brightness
%                        pagInputStruct.reports.encircledEnergy
%                        pagInputStruct.reports.backgroundLevel
%                        pagInputStruct.reports.centroidsMeanRow
%                        pagInputStruct.reports.centroidsMeanColumn
%                        pagInputStruct.reports.centroidsPlateScale
%                        pagInputStruct.reports.twoDBlack
%                        pagInputStruct.reports.ldeUndershoot
%                        pagInputStruct.reports.blackCosmicRayMetrics.crField 
%                        pagInputStruct.reports.maskedSmearCosmicRayMetrics.crField
%                        pagInputStruct.reports.virtualSmearCosmicRayMetrics.crField
%                        pagInputStruct.reports.targetStarCosmicRayMetrics.crField
%                        pagInputStruct.reports.backgroundCosmicRayMetrics.crField
%                        pagInputStruct.reports.cdppMeasured.magField.hourField
%                        pagInputStruct.reports.cdppExpected.magField.hourField
%                        pagInputStruct.reports.cdppRatio.magField.hourField
%
% Note:  crField   = {'hitRate', 'meanEnergy', 'energyVariance', 'energySkewness', 'energyKurtosis' } 
%        magField  = {'mag9', 'mag10', 'mag11', 'mag12', 'mag13', 'mag14', 'mag15'}
%        hourField = {'threeHour', 'sixHour', 'twelveHour'}
%______________________________________________________________________

% pagInputStruct.reports fields
fieldsAndBounds = cell(11,4);
fieldsAndBounds( 1,:)  = { 'time';                  '>= -1';    '<= 64000'; [] };   
fieldsAndBounds( 2,:)  = { 'value';                 [];         [];         [] };   % TBD
fieldsAndBounds( 3,:)  = { 'meanValue';             [];         [];         [] };   % TBD
fieldsAndBounds( 4,:)  = { 'uncertainty';           [];         [];         [] };   % TBD
fieldsAndBounds( 5,:)  = { 'adaptiveBoundsXFactor'; '>= -1';    '<= 10';    [] };
fieldsAndBounds( 6,:)  = { 'trackAlertLevel';       [];         [];         '[-1 0 1 2]''' };
fieldsAndBounds( 7,:)  = { 'trendAlertLevel';       [];         [];         '[-1 0 1 2]''' };
fieldsAndBounds( 8,:)  = { 'adaptiveBoundsReport';  [];         [];         [] };   % structure
fieldsAndBounds( 9,:)  = { 'fixedBoundsReport';     [];         [];         [] };   % structure
fieldsAndBounds(10,:)  = { 'trendReport';           [];         [];         [] };   % structure
fieldsAndBounds(11,:)  = { 'alerts';                [];         [];         [] };   % structure

for i=1:nReports

    remove_field_and_test_for_failure(pagInputStruct.reports(i).blackLevel, ...
        ['pagInputStruct.reports(' num2str(i) ').blackLevel'], ...
        pagInputStruct, 'pagInputStruct', 'pagScienceClass', fieldsAndBounds, true, true);
    remove_field_and_test_for_failure(pagInputStruct.reports(i).smearLevel, ...
        ['pagInputStruct.reports(' num2str(i) ').smearLevel'], ...
        pagInputStruct, 'pagInputStruct', 'pagScienceClass', fieldsAndBounds, true, true);
    remove_field_and_test_for_failure(pagInputStruct.reports(i).darkCurrent, ...
        ['pagInputStruct.reports(' num2str(i) ').darkCurrent'], ...
        pagInputStruct, 'pagInputStruct', 'pagScienceClass', fieldsAndBounds, true, true);

    remove_field_and_test_for_failure(pagInputStruct.reports(i).theoreticalCompressionEfficiency, ...
        ['pagInputStruct.reports(' num2str(i) ').theoreticalCompressionEfficiency'], ...
        pagInputStruct, 'pagInputStruct', 'pagScienceClass', fieldsAndBounds, true, true);
    remove_field_and_test_for_failure(pagInputStruct.reports(i).achievedCompressionEfficiency, ...
        ['pagInputStruct.reports(' num2str(i) ').achievedCompressionEfficiency'], ...
        pagInputStruct, 'pagInputStruct', 'pagScienceClass', fieldsAndBounds, true, true);

    remove_field_and_test_for_failure(pagInputStruct.reports(i).brightness, ...
        ['pagInputStruct.reports(' num2str(i) ').brightness'], ...
        pagInputStruct, 'pagInputStruct', 'pagScienceClass', fieldsAndBounds, true, true);
    remove_field_and_test_for_failure(pagInputStruct.reports(i).encircledEnergy, ...
        ['pagInputStruct.reports(' num2str(i) ').encircledEnergy'], ...
        pagInputStruct, 'pagInputStruct', 'pagScienceClass', fieldsAndBounds, true, true);

    remove_field_and_test_for_failure(pagInputStruct.reports(i).backgroundLevel, ...
        ['pagInputStruct.reports(' num2str(i) ').backgroundLevel'], ...
        pagInputStruct, 'pagInputStruct', 'pagScienceClass', fieldsAndBounds, true, true);
    remove_field_and_test_for_failure(pagInputStruct.reports(i).centroidsMeanRow, ...
        ['pagInputStruct.reports(' num2str(i) ').centroidsMeanRow'], ...
        pagInputStruct, 'pagInputStruct', 'pagScienceClass', fieldsAndBounds, true, true);
    remove_field_and_test_for_failure(pagInputStruct.reports(i).centroidsMeanColumn, ...
        ['pagInputStruct.reports(' num2str(i) ').centroidsMeanColumn'], ...
        pagInputStruct, 'pagInputStruct', 'pagScienceClass', fieldsAndBounds, true, true);
    remove_field_and_test_for_failure(pagInputStruct.reports(i).plateScale, ...
        ['pagInputStruct.reports(' num2str(i) ').plateScale'], ...
        pagInputStruct, 'pagInputStruct', 'pagScienceClass', fieldsAndBounds, true, true);

    remove_field_and_test_for_failure(pagInputStruct.reports(i).twoDBlack, ...
        ['pagInputStruct.reports(' num2str(i) ').twoDBlack'    ], ...
        pagInputStruct, 'pagInputStruct', 'pagScienceClass', fieldsAndBounds, true, true);
    remove_field_and_test_for_failure(pagInputStruct.reports(i).ldeUndershoot, ...
        ['pagInputStruct.reports(' num2str(i) ').ldeUndershoot'], ...
        pagInputStruct, 'pagInputStruct', 'pagScienceClass', fieldsAndBounds, true, true);

    for iCr=1:length(crString)
        for iCrField=1:length(crFieldString)
            remove_field_and_test_for_failure(pagInputStruct.reports(i).(crString{iCr}).(crFieldString{iCrField}), ...
                ['pagInputStruct.reports(' num2str(i) ').' crString{iCr}, '.' crFieldString{iCrField}], ...
                pagInputStruct, 'pagInputStruct', 'pagScienceClass', fieldsAndBounds, true, true);
        end
    end

    for iMag=1:length(magString)
        for iHour=1:length(hourString)
            remove_field_and_test_for_failure(pagInputStruct.reports(i).cdppMeasured.(magString{iMag}).(hourString{iHour}), ...
                ['pagInputStruct.reports(' num2str(i) ').cdppMeasured.' magString{iMag} '.' hourString{iHour}], ...
                pagInputStruct, 'pagInputStruct', 'pagScienceClass', fieldsAndBounds, true, true);
            remove_field_and_test_for_failure(pagInputStruct.reports(i).cdppExpected.(magString{iMag}).(hourString{iHour}), ...
                ['pagInputStruct.reports(' num2str(i) ').cdppExpected.' magString{iMag} '.' hourString{iHour}], ...
                pagInputStruct, 'pagInputStruct', 'pagScienceClass', fieldsAndBounds, true, true);
            remove_field_and_test_for_failure(pagInputStruct.reports(i).cdppRatio.(magString{iMag}).(hourString{iHour}), ...
                ['pagInputStruct.reports(' num2str(i) ').cdppRatio.' magString{iMag} '.' hourString{iHour}], ...
                pagInputStruct, 'pagInputStruct', 'pagScienceClass', fieldsAndBounds, true, true);
        end
    end


end

clear fieldsAndBounds;
rmpath(pagTestDataRoot);

%------------------------------------------------------------

fprintf('\n');
return;

%==========================================================================



