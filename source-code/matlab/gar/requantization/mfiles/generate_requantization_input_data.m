function requantInputsStruct = generate_requantization_input_data(debugLevel)

%--------------------------------------------------------------------------
% generate requantModuleParameters
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

requantModuleParameters.guardBandHigh = 0.05;
requantModuleParameters.quantizationFraction = 0.25;
requantModuleParameters.requantTableLength = 65536; % 2^16
requantModuleParameters.requantTableMinValue = 0;
requantModuleParameters.requantTableMaxValue = 8388607; % 2^23-1

fcConstants.BITS_IN_ADC = 14;
fcConstants.nRowsImaging = 1024;
fcConstants.nColsImaging = 1100;
fcConstants.nLeadingBlack = 12;
fcConstants.nTrailingBlack = 20;
fcConstants.nVirtualSmear = 26;
fcConstants.nMaskedSmear = 20;

requantInputsStruct.requantModuleParameters = requantModuleParameters;
requantInputsStruct.fcConstants = fcConstants;

requantInputsStruct.requantModuleParameters.debugFlag = debugLevel;


%--------------------------------------------------------------------------
% generate scConfigParameters
%--------------------------------------------------------------------------

% TCSCCFGID
scConfigParameters.scConfigId = 1;
% timestamp
scConfigParameters.mjd = 55000;

% FDMINTPER
scConfigParameters.fgsFramesPerIntegration = 59;
% GSprm_FGSPER
scConfigParameters.millisecondsPerFgsFrame = 103.79;
% GSprm_ROPER
scConfigParameters.millisecondsPerReadout = 518.95;

% FDMSCPER
scConfigParameters.integrationsPerShortCadence = 9;
% FDMLCPER
scConfigParameters.shortCadencesPerLongCadence = 30;
% FDMNUMLCPERBL
scConfigParameters.longCadencesPerBaseline = 48;
% FDMLDEFFINUM
scConfigParameters.integrationsPerScienceFfi = 270;

% FDMSMRROWSTART
scConfigParameters.smearStartRow = 1047;
% FDMSMRROWEND
scConfigParameters.smearEndRow = 1051;
% FDMSMRCOLSTART
scConfigParameters.smearStartCol = 12;
% FDMSMRCOLEND
scConfigParameters.smearEndCol = 1111;
% FDMMSKROWSTART
scConfigParameters.maskedStartRow = 3;
% FDMMSKROWEND
scConfigParameters.maskedEndRow = 7;
% FDMMSKCOLSTART
scConfigParameters.maskedStartCol = 12;
% FDMMSKCOLEND
scConfigParameters.maskedEndCol = 1111;
% FDMDRKROWSTART
scConfigParameters.darkStartRow = 0;
% FDMDRKROWEND
scConfigParameters.darkEndRow = 1069;
% FDMDRKCOLSTART
scConfigParameters.darkStartCol = 3;
% FDMDRKCOLEND
scConfigParameters.darkEndCol = 7;
% RQFIXEDOFFSET

% The value of the fixed offset should not affect the mean black table values. Can we change the fixed offset to 419405, as I recommended to Jeb?



scConfigParameters.requantFixedOffset = 419405; % = 512 * .05 *(2^14-1), max. co adds = 512 (anything higher causes  ADC roll over as pixel flux exceeds 2^14-1 DN)

requantInputsStruct.scConfigParameters = scConfigParameters;


%--------------------------------------------------------------------------
% generate twoDBlackModels
%--------------------------------------------------------------------------
[modules, outputs] = convert_to_module_output([1:84]');

for j=1:84
    fprintf('retrieving %d twoD black model\n', j);
    requantInputsStruct.twoDBlackModels(j) = retrieve_two_d_black_model(modules(j), outputs(j));
end

fprintf('\n\n');
%--------------------------------------------------------------------------
% generate gainModel
%--------------------------------------------------------------------------
requantInputsStruct.gainModel = retrieve_gain_model();
%--------------------------------------------------------------------------
% generate readNoiseModel
%--------------------------------------------------------------------------
requantInputsStruct.readNoiseModel = retrieve_read_noise_model();


%--------------------------------------------------------------------------
% add debug flag
%--------------------------------------------------------------------------
if(~exist('debugLevel', 'var'))
    debugLevel = 3;
end





return;