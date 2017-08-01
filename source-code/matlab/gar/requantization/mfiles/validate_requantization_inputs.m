function requantizationInputStruct = validate_requantization_inputs(requantizationInputStruct)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function requantizationInputStruct = validate_requantization_inputs(requantizationInputStruct)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% This function first checks for the presence of expected fields in the
% input structure and each parameter is checked to see whether it is within
% appropriate range.
%
% Input: A data structure 'requantizationInputStruct' with the following fields:
%     requantModuleParameters: [1x1 struct]
%                 scConfigParameters: [1x1 struct]
%                    twoDBlackModels: [1x84 struct]
%                          gainModel: [1x1 struct]
%                     readNoiseModel: [1x1 struct]
%                        fcConstants: [1x1 struct]
% ........................................................
% requantizationInputStruct.requantModuleParameters
% ........................................................
%                                  guardBandHigh: 0.0500
%                           quantizationFraction: 0.2500
%     expectedSmearMaxBlackCorrectedPerReadInAdu: 533
%     expectedSmearMinBlackCorrectedPerReadInAdu: 0.4400
%            rssOutOriginalQuantizationNoiseFlag: 1
%                                      debugFlag: 3
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
%                        REQUANT_TABLE_LENGTH: 65536 (2^16)
%                     REQUANT_TABLE_MIN_VALUE: 0
%                     REQUANT_TABLE_MAX_VALUE: 8388607 (2^23-1)
%                     MEAN_BLACK_TABLE_LENGTH: 84
%                  MEAN_BLACK_TABLE_MIN_VALUE: 0
%                  MEAN_BLACK_TABLE_MAX_VALUE: 16383 (2^14-1)
%                              MODULE_OUTPUTS: 84
%
% There are other fields in fcConstants which have been omitted here...
%
% Comments: This function generates an error under the following scenarios:
%          (1) when invoked with no inputs
%          (2) when any of the fields are missing
%          (3) when any of the fields are NaNs/Infs or outside the
%          appropriate bounds
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
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

if nargin == 0
    % generate error and return
    error('GAR:validateRequantizationInputs:EmptyInputStruct',...
        'validate_requantization_inputs must be called with an input structure.')
end

% to avoid getting error message like Error: Error using ==> class Field
% names and parent classes for class requantizationTableClass cannot be
% changed without clear classes - order the fields
requantizationInputStruct = orderfields(requantizationInputStruct);

fieldsAndBounds = cell(6,4);
fieldsAndBounds(1,:)  = { 'requantModuleParameters'; []; []; []};
fieldsAndBounds(2,:)  = { 'scConfigParameters'; []; []; []};
fieldsAndBounds(3,:)  = { 'twoDBlackModels'; []; []; []};
fieldsAndBounds(4,:)  = { 'gainModel'; []; []; []};
fieldsAndBounds(5,:)  = { 'readNoiseModel'; []; []; []};
fieldsAndBounds(6,:)  = { 'fcConstants'; []; []; []};

validate_structure(requantizationInputStruct, fieldsAndBounds,'requantizationInputStruct');

clear fieldsAndBounds;
%------------------------------------------------------------
fieldsAndBounds = cell(9,4);
fieldsAndBounds(1,:)  = { 'guardBandHigh'; '>= 0'; '< 0.5'; []};
fieldsAndBounds(2,:)  = { 'quantizationFraction'; '> 0'; '< .5'; []};
fieldsAndBounds(3,:)  = { 'expectedSmearMaxBlackCorrectedPerReadInAdu'; '>=0'; '<= 1e3'; []};
fieldsAndBounds(4,:)  = { 'expectedSmearMinBlackCorrectedPerReadInAdu'; '>= 0'; '<=1e2'; []};
fieldsAndBounds(5,:)  = { 'rssOutOriginalQuantizationNoiseFlag'; []; []; [true, false]};
fieldsAndBounds(6,:)  = { 'inflationFactorForBufferZone'; '>= 0'; '<= 1.5'; []};
fieldsAndBounds(7,:)  = { 'twoDBlackTrimPercentage'; '>= 0'; '<= 10'; []};
fieldsAndBounds(8,:)  = { 'trimPercentageForBlackResiduals'; '>= 0'; '<= 25'; []};
fieldsAndBounds(9,:)  = { 'debugFlag'; '>= 0'; '<= 3'; []};


validate_structure(requantizationInputStruct.requantModuleParameters, fieldsAndBounds,'requantizationInputStruct.requantModuleParameters');

clear fieldsAndBounds;
%------------------------------------------------------------
fieldsAndBounds = cell(23,4);
fieldsAndBounds(1,:)  = { 'scConfigId'; []; []; []};
fieldsAndBounds(2,:)  = { 'mjd'; '> 54000'; '< 64000'; []};% use mjd
fieldsAndBounds(3,:)  = { 'fgsFramesPerIntegration'; []; []; []}; % don't care about this parameter
fieldsAndBounds(4,:)  = { 'millisecondsPerFgsFrame'; []; []; []};% don't care about this parameter
fieldsAndBounds(5,:)  = { 'millisecondsPerReadout'; '> 0'; '< 1e6'; []};
fieldsAndBounds(6,:)  = { 'integrationsPerShortCadence'; '> 0'; '< 1000' ; []};
fieldsAndBounds(7,:)  = { 'shortCadencesPerLongCadence'; '> 0'; '< 1000'; []};
fieldsAndBounds(8,:)  = { 'longCadencesPerBaseline'; []; []; []};% don't care about this parameter
fieldsAndBounds(9,:)  = { 'integrationsPerScienceFfi'; []; []; []};% don't care about this parameter
fieldsAndBounds(10,:)  = { 'smearStartRow'; '>=1044' ; '<= 1069'; []}; % row,columns are 0 based
fieldsAndBounds(11,:)  = { 'smearEndRow'; '>=1044' ; '<= 1069'; []};% virtual smear region rows
fieldsAndBounds(12,:)  = { 'smearStartCol'; '>=12'; '<= 1111'; []};
fieldsAndBounds(13,:)  = { 'smearEndCol'; '>=12'; '<= 1111'; []};
fieldsAndBounds(14,:)  = { 'maskedStartRow'; '>= 0'; '<= 19'; []};% masked smear region rows
fieldsAndBounds(15,:)  = { 'maskedEndRow'; '>= 0'; '<= 19'; []}; % masked smear region rows
fieldsAndBounds(16,:)  = { 'maskedStartCol'; '>=12'; '<= 1111'; []};
fieldsAndBounds(17,:)  = { 'maskedEndCol'; '>=12'; '<= 1111'; []}; % smear columns
fieldsAndBounds(18,:)  = { 'darkStartRow'; '>= 0'; '<=1069'; []}; % dark => black
fieldsAndBounds(19,:)  = { 'darkEndRow'; '>= 0'; '<=1069'; []}; % dark => black
fieldsAndBounds(20,:)  = { 'darkStartCol'; []; [];  '[0:11, 1112:1131]''';}; % includes both leading and trailing black
fieldsAndBounds(21,:)  = { 'darkEndCol'; []; [];  '[0:11, 1112:1131]''';}; % includes both leading and trailing black
fieldsAndBounds(22,:)  = { 'lcRequantFixedOffset'; '>=400000'; '<=420000'; []}; % max value is .05*(2^14)*512
fieldsAndBounds(23,:)  = { 'scRequantFixedOffset'; '>=0'; '<=420000'; []}; % revisit later; this offset should be below lcRequantOffset

validate_structure(requantizationInputStruct.scConfigParameters, fieldsAndBounds,'requantizationInputStruct.scConfigParameters');

clear fieldsAndBounds;
%------------------------------------------------------------
fieldsAndBounds = cell(14,4);
fieldsAndBounds(1,:)  = { 'BITS_IN_ADC'; '==14'; []; []};
fieldsAndBounds(2,:)  = { 'nRowsImaging'; '== 1024'; []; []};
fieldsAndBounds(3,:)  = { 'nColsImaging'; '== 1100'; []; []};
fieldsAndBounds(4,:)  = { 'nLeadingBlack'; '==12'; []; []};
fieldsAndBounds(5,:)  = { 'nTrailingBlack'; '==20'; []; []};
fieldsAndBounds(6,:)  = { 'nVirtualSmear'; '==26'; []; []};
fieldsAndBounds(7,:)  = { 'nMaskedSmear'; '== 20'; []; []};
fieldsAndBounds(8,:)  = { 'REQUANT_TABLE_LENGTH'; '==2^16'; []; []};
fieldsAndBounds(9,:)  = { 'REQUANT_TABLE_MIN_VALUE'; '==0'; []; []};
fieldsAndBounds(10,:)  = { 'REQUANT_TABLE_MAX_VALUE'; '==2^23-1'; []; []};
fieldsAndBounds(11,:)  = { 'MEAN_BLACK_TABLE_LENGTH'; '== 84'; []; []};
fieldsAndBounds(12,:)  = { 'MEAN_BLACK_TABLE_MIN_VALUE'; '==0'; []; []};
fieldsAndBounds(13,:)  = { 'MEAN_BLACK_TABLE_MAX_VALUE'; '==2^14-1'; []; []};
fieldsAndBounds(14,:)  = { 'MODULE_OUTPUTS'; '== 84'; []; []};

validate_structure(requantizationInputStruct.fcConstants, fieldsAndBounds,'requantizationInputStruct.fcConstants');

clear fieldsAndBounds;
%------------------------------------------------------------

fieldsAndBounds = cell(5,4);
fieldsAndBounds(1,:)  = { 'mjds'; '> 54000'; '< 64000'; []};% use mjd
fieldsAndBounds(2,:)  = { 'rows'; []; []; []};
fieldsAndBounds(3,:)  = { 'columns'; []; []; []};
fieldsAndBounds(4,:)  = { 'blacks'; []; []; []};
fieldsAndBounds(5,:)  = { 'uncertainties'; []; []; []};

nStructures = length(requantizationInputStruct.twoDBlackModels);

if(nStructures ~= requantizationInputStruct.fcConstants.MODULE_OUTPUTS)
    error('GAR:validateRequantizationInputs:numberOfBlack2DModels',...
        ['Number of black2D models expected = 84 but found only ' num2str(nStructures)]);
end


for j = 1:nStructures

    nMjds = length(requantizationInputStruct.twoDBlackModels(j).mjds);
    if(nMjds ~= 1)
        error('GAR:validateRequantizationInputs:mjdsInBlack2DModels',...
            ['Expected only one mjd but found ' num2str(nMjds)]);
    end

    validate_structure(requantizationInputStruct.twoDBlackModels(j), fieldsAndBounds,'requantizationInputStruct.twoDBlackModels');
end

clear fieldsAndBounds;
%------------------------------------------------------------
fieldsAndBounds = cell(2,4);
fieldsAndBounds(1,:)  = { 'mjds'; '> 54000'; '< 64000'; []};% use mjd
fieldsAndBounds(2,:)  = { 'constants'; []; []; []};


nGainModels = length(requantizationInputStruct.gainModel.constants.array);

if(nGainModels ~= requantizationInputStruct.fcConstants.MODULE_OUTPUTS)
    error('GAR:validateRequantizationInputs:gainModel',...
        ['gainModel contains values for only ' num2str(nGainModels) ' modouts but expected values for all 84 modouts']);
end


nMjds = length(requantizationInputStruct.gainModel.mjds);
if(nMjds ~= 1)
    error('GAR:validateRequantizationInputs:mjdsInGainModel',...
        ['Expected only one mjd but found ' num2str(nMjds)]);
end

validate_structure(requantizationInputStruct.gainModel, fieldsAndBounds,'requantizationInputStruct.gainModel');

clear fieldsAndBounds;
%------------------------------------------------------------
fieldsAndBounds = cell(2,4);
fieldsAndBounds(1,:)  = { 'mjds'; '> 54000'; '< 64000'; []};% use mjd
fieldsAndBounds(2,:)  = { 'constants'; []; []; []};


nreadNoiseModels = length(requantizationInputStruct.readNoiseModel.constants.array);

if(nreadNoiseModels ~= requantizationInputStruct.fcConstants.MODULE_OUTPUTS)
    error('GAR:validateRequantizationInputs:readNoiseModel',...
        ['readNoiseModel contains values for only ' num2str(nreadNoiseModels) ' modouts but expected values for all 84 modouts']);
end


nMjds = length(requantizationInputStruct.readNoiseModel.mjds);
if(nMjds ~= 1)
    error('GAR:validateRequantizationInputs:mjdsInReadNoiseModel',...
        ['Expected only one mjd but found ' num2str(nMjds)]);

end

validate_structure(requantizationInputStruct.readNoiseModel, fieldsAndBounds,'requantizationInputStruct.readNoiseModel');

clear fieldsAndBounds;

return
