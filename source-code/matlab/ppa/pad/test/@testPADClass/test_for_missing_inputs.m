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
%         Example:  run(text_test_runner, testPADClass('test_for_missing_inputs'));
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

clear padInputStruct;
clear padScienceClass;

% load a valid PPA input structure
initialize_soc_variables;
padTestDir = fullfile(socTestDataRoot, 'ppa', 'MATLAB', 'unit-tests', 'pad');
addpath(padTestDir);
load padInputStruct.mat;

%______________________________________________________________________
% top level validation
% validate the structure padInputStruct
%______________________________________________________________________

% padInputStruct fields
fieldsAndBounds = cell(6,4);
fieldsAndBounds(1,:)  = { 'cadenceTimes';           []; []; [] };       % structure
fieldsAndBounds(2,:)  = { 'padModuleParameters';    []; []; [] };       % structure
fieldsAndBounds(3,:)  = { 'fcConstants';            []; []; [] };       % structure, validate only needed fields
fieldsAndBounds(4,:)  = { 'spacecraftConfigMaps';   []; []; [] };       % structure array, do not validate
fieldsAndBounds(5,:)  = { 'raDec2PixModel';         []; []; [] };       % structure, validate only needed fields
fieldsAndBounds(6,:)  = { 'motionBlobs';            []; []; [] };       % structure array

remove_field_and_test_for_failure(padInputStruct, 'padInputStruct', padInputStruct, ...
    'padInputStruct', 'padScienceClass', fieldsAndBounds, true, true);

clear fieldsAndBounds;

%--------------------------------------------------------------------------
% second level validation.
% validate the fields in padInputStruct.cadenceTimes
%--------------------------------------------------------------------------

% padInputStruct.cadenceTimes fields
fieldsAndBounds = cell(5,4);

fieldsAndBounds(1,:)   = { 'startTimestamps';   [];     []; 	[] };
fieldsAndBounds(2,:)   = { 'midTimestamps';     [];     [];     [] };
fieldsAndBounds(3,:)   = { 'endTimestamps';     [];     [];     [] };
fieldsAndBounds(4,:)   = { 'gapIndicators';     [];     [];     [true; false] };
fieldsAndBounds(5,:)   = { 'requantEnabled';    [];     [];     [true; false] };

remove_field_and_test_for_failure(padInputStruct.cadenceTimes, 'padInputStruct.cadenceTimes', padInputStruct, ...
    'padInputStruct', 'padScienceClass', fieldsAndBounds, true, true);

clear fieldsAndBounds;

%______________________________________________________________________
% second level validation
% validate the fields in padInputStruct.padModuleParameters  
%______________________________________________________________________

fieldsAndBounds = cell(23,4);
fieldsAndBounds( 1,:)  = { 'gridRowStart';                      '>= 0';     '< 1070';   [] };
fieldsAndBounds( 2,:)  = { 'gridRowEnd';                        '>= 0';     '< 1070';   [] };
fieldsAndBounds( 3,:)  = { 'gridColStart';                      '>= 0';     '< 1132';   [] };
fieldsAndBounds( 4,:)  = { 'gridColEnd';                        '>= 0';     '< 1132';   [] };

fieldsAndBounds( 5,:)  = { 'horizonTime';                       '>= 0';     '<= 100';   [] }; 
fieldsAndBounds( 6,:)  = { 'trendFitTime';                      '>= 0';     '<= 30';    [] };
fieldsAndBounds( 7,:)  = { 'minTrendFitSampleCount';            '>= 0';     '<= 500';   [] };
fieldsAndBounds( 8,:)  = { 'initialAverageSampleCount';         '>= 0';     '<= 500';   [] };
fieldsAndBounds( 9,:)  = { 'alertTime';                         '>= 0';     '<= 30';    [] };

fieldsAndBounds(10,:)  = { 'deltaRaSmoothingFactor';            '>=  0';    '<= 1';     [] };
fieldsAndBounds(11,:)  = { 'deltaRaFixedLowerBound';            '>= -1';    '<= 1';     [] };
fieldsAndBounds(12,:)  = { 'deltaRaFixedUpperBound';            '>= -1';    '<= 1';     [] };
fieldsAndBounds(13,:)  = { 'deltaRaAdaptiveXFactor';            '>=  0';    '<= 10';    [] };

fieldsAndBounds(14,:)  = { 'deltaDecSmoothingFactor';           '>=  0';    '<= 1';     [] };
fieldsAndBounds(15,:)  = { 'deltaDecFixedLowerBound';           '>= -1';    '<= 1';     [] };
fieldsAndBounds(16,:)  = { 'deltaDecFixedUpperBound';           '>= -1';    '<= 1';     [] };
fieldsAndBounds(17,:)  = { 'deltaDecAdaptiveXFactor';           '>=  0';    '<= 10';    [] };

fieldsAndBounds(18,:)  = { 'deltaRollSmoothingFactor';          '>=  0';    '<= 1';     [] };
fieldsAndBounds(19,:)  = { 'deltaRollFixedLowerBound';          '>= -1';    '<= 1';     [] };
fieldsAndBounds(20,:)  = { 'deltaRollFixedUpperBound';          '>= -1';    '<= 1';     [] };
fieldsAndBounds(21,:)  = { 'deltaRollAdaptiveXFactor';          '>=  0';    '<= 10';    [] };

fieldsAndBounds(22,:)  = { 'debugLevel';                        '>= 0';     '<= 5';     [] };
fieldsAndBounds(23,:)  = { 'plottingEnabled';                   [];         [];         [true false] };

remove_field_and_test_for_failure(padInputStruct.padModuleParameters, 'padInputStruct.padModuleParameters',...
    padInputStruct, 'padInputStruct', 'padScienceClass', fieldsAndBounds, true, true);

clear fieldsAndBounds;

%______________________________________________________________________
% second level validation
% validate the fields in padInputStruct.fcConstants
%______________________________________________________________________

fieldsAndBounds = cell(1,4);
fieldsAndBounds( 1,:) = { 'MODULE_OUTPUTS'; '== 84';    [];    [] };

remove_field_and_test_for_failure(padInputStruct.fcConstants, 'padInputStruct.fcConstants',...
    padInputStruct, 'padInputStruct', 'padScienceClass', fieldsAndBounds, true, true);

clear fieldsAndBounds;

%______________________________________________________________________
% second level validation
% validate the fields in padInputStruct.raDec2PixModel
%______________________________________________________________________

fieldsAndBounds = cell(10,4);
fieldsAndBounds( 1,:) = { 'mjdStart';                           '>= 54000';     '<= 64000'; [] };
fieldsAndBounds( 2,:) = { 'mjdEnd';                             '>= 54000';     '<= 64000'; [] };
fieldsAndBounds( 3,:) = { 'spiceFileDir';                       [];             [];         [] };
fieldsAndBounds( 4,:) = { 'spiceSpacecraftEphemerisFilename';   [];             [];         [] };
fieldsAndBounds( 5,:) = { 'planetaryEphemerisFilename';         [];             [];         [] };
fieldsAndBounds( 6,:) = { 'leapSecondFilename';                 [];             [];         [] };
fieldsAndBounds( 7,:) = { 'pointingModel';                      [];             [];         [] };
fieldsAndBounds( 8,:) = { 'geometryModel';                      [];             [];         [] };
fieldsAndBounds( 9,:) = { 'rollTimeModel';                      [];             [];         [] };
fieldsAndBounds(10,:) = { 'mjdOffset';                          '== 2400000.5'; [];         [] };


remove_field_and_test_for_failure(padInputStruct.raDec2PixModel, 'padInputStruct.raDec2PixModel',...
    padInputStruct, 'padInputStruct', 'padScienceClass', fieldsAndBounds, true, true);

clear fieldsAndBounds;

%______________________________________________________________________
% second level validation
% validate the fields in padInputStruct.motionBlobs
%______________________________________________________________________

% pmdInputStruct.motionBlobs fields
% fieldsAndBounds = cell(5,4);
% fieldsAndBounds( 1,:)  = { 'blobIndices';            [];         [];         [] };                  
% fieldsAndBounds( 2,:)  = { 'gapIndicators';          [];         [];         [true false] };
% fieldsAndBounds( 3,:)  = { 'blobFilenames';          [];         [];         [] };                  
% fieldsAndBounds( 4,:)  = { 'startCadence';           [];         [];         [] };
% fieldsAndBounds( 5,:)  = { 'endCadence';             [];         [];         [] };
% 
% remove_field_and_test_for_failure(padInputStruct.motionBlobs, 'padInputStruct.motionBlobs',...
%     padInputStruct, 'padInputStruct', 'padScienceClass', fieldsAndBounds, true, true);
% 
% clear fieldsAndBounds;

%______________________________________________________________________
% second level validation
% validate the fields in padInputStruct.motionPolyStruct
%______________________________________________________________________

% pmdInputStruct.motionPolyStruct fields
% fieldsAndBounds = cell(10,4);
% fieldsAndBounds( 1,:)  = { 'cadence';                '>= 0';     '< 2e7';    []};
% fieldsAndBounds( 2,:)  = { 'mjdStartTime';           '>= 54000'; '<= 64000'; [] };
% fieldsAndBounds( 3,:)  = { 'mjdMidTime';             '>= 54000'; '<= 64000'; [] };
% fieldsAndBounds( 4,:)  = { 'mjdEndTime';             '>= 54000'; '<= 64000'; [] };
% fieldsAndBounds( 5,:)  = { 'module';                 [];         [];         '[2:4, 6:20, 22:24]''' };
% fieldsAndBounds( 6,:)  = { 'output';                 [];         [];         '[1 2 3 4]''' };
% fieldsAndBounds( 7,:)  = { 'rowPoly';                [];         [];         [] };                  % a structure
% fieldsAndBounds( 8,:)  = { 'rowPolyStatus';          [];         [];         '[0 1]''' };
% fieldsAndBounds( 9,:)  = { 'colPoly';                [];         [];         [] };                  % a structure
% fieldsAndBounds(10,:)  = { 'colPolyStatus';          [];         [];         '[0 1]''' };
% 
% remove_field_and_test_for_failure(padInputStruct.motionPolyStruct, 'padInputStruct.motionPolyStruct',...
%     padInputStruct, 'padInputStruct', 'padScienceClass', fieldsAndBounds, true, true);
% 
% clear fieldsAndBounds;

%--------------------------------------------------------------------------
% third level validation.
% Validate the structure field padInputStruct.motionPolyStruct.rowPoly and
%                              padInputStruct.motionPolyStruct.colPoly 
%--------------------------------------------------------------------------

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
%     padInputStructFail = padInputStruct;
%     padInputStructFail.motionPolyStruct(2,1).rowPoly = rmfield(padInputStructFail.motionPolyStruct(2,1).rowPoly, polyFields{iField});
%     try_to_catch_error_condition('a=padScienceClass(padInputStruct)', polyFields{iField}, padInputStructFail, 'padInputStruct');
% 
%     padInputStructFail = padInputStruct;
%     padInputStructFail.motionPolyStruct(2,1).colPoly = rmfield(padInputStructFail.motionPolyStruct(2,1).colPoly, polyFields{iField});
%     try_to_catch_error_condition('a=padScienceClass(padInputStruct)', polyFields{iField}, padInputStructFail, 'padInputStruct');
% end
% 
% nChannels = size(padInputStruct.motionPolyStruct, 1);
% nCadences = size(padInputStruct.motionPolyStruct, 2);
% rowPoly = [padInputStruct.motionPolyStruct.rowPoly];
% rowPoly = reshape(rowPoly, nChannels, nCadences);
% colPoly = [padInputStruct.motionPolyStruct.colPoly];
% colPoly = reshape(colPoly, nChannels, nCadences);
% 
% for iField = 1:length(polyFields)
% 
%     rowPolyFail = rmfield(rowPoly, polyFields{iField});
%     colPolyFail = rmfield(colPoly, polyFields{iField});
%     
%     padInputStructFail = padInputStruct;
%     for iChannel = 1:nChannels
%         for iCadence = 1:nCadences
%             padInputStructFail.motionPolyStruct(iChannel, iCadence).rowPoly = rowPolyFail(iChannel, iCadence);
%         end
%     end
%     try_to_catch_error_condition('a=padScienceClass(padInputStruct)', polyFields{iField}, padInputStructFail,'padInputStruct') ;
% 
%     padInputStructFail = padInputStruct;
%     for iChannel = 1:nChannels
%         for iCadence = 1:nCadences
%             padInputStructFail.motionPolyStruct(iChannel, iCadence).colPoly = colPolyFail(iChannel, iCadence);
%         end
%     end
%     try_to_catch_error_condition('a=padScienceClass(padInputStruct)', polyFields{iField}, padInputStructFail,'padInputStruct') ;
% 
% end

fprintf('\n');

rmpath(padTestDir);

return;

%==========================================================================


