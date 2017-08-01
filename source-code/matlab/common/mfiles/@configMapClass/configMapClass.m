function configMapObject = configMapClass(configMaps)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function configMapObject = configMapClass(configMaps)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% If new mnemonics are added to the SOC to MOC ICD, then this script needs
% to be updated to reflect those changes.
% The following mnemonics were taken from SOC to MOC ICD KSOC-21171-003
% dated 8/13/2007
%
%
% define the fields of the configMapClass here....from SOC-MOC ICD
% Mnemonic          Description                                             Units           Type              Notes
% TCSCCFGID         commanded SC configuration ID                           #               UINT32
% timestamp         Time when SC configuration ID is commanded              CCSDS time      TimeStringXB      yyyyDDDhhmmss
% GSFSWBLD          FSW version number, build                               #               UINT8
% GSFSWREL          FSW version number, release                             #               UINT8
% GSFSWUPDATE       FSW version number, update                              #               UINT8
% FDMINTPER         commanded integration period                            FGS frames      UINT8             Integration time is commanded in number of FGS frames. So the period of each integration is this number * the FGS frame period + the readout time. FDMINTPER * 0.10379 sec + 0.51895 sec.
% GSprm_FGSPER      FGS frame period                                        msec
% GSprm_ROPER       Readout period                                          msec
% FDMSCPER          commanded short cadence period                          Integrations    UINT8             SC period is commanded in number of integrations. So the period of each SC is this number * the integration period.
% FDMLCPER          commanded long cadence period                           Short Cadences  UINT8             LC period is commanded in number of short cadences. So the period of each LC is this number * the SC period.
% FDMNUMLCPERBL     num of LC periods between baselines                     LongCadences    UINT16            Data collection will always start with a LC baseline. The next LC baseline will be collected this number of LC's later. i.e. a value of 48 should result in 1 LC about every 24hrs.
% FDMLDEFFINUM      num of integrations in a science FFI                    Integrations    UINT16            Number of integrations collected during an FFI
% FDMSMRROWSTART    The science collateral smear region start row           row             UINT16
% FDMSMRROWEND      The science collateral smear region end row             row             UINT16
% FDMSMRCOLSTART    The science collateral smear region start col           col             UINT16
% FDMSMRCOLEND      The science collateral smear region end col             col             UINT16
% FDMMSKROWSTART    The science collateral masked region start row          row             UINT16
% FDMMSKROWEND      The science collateral masked region end row            row             UINT16
% FDMMSKCOLSTART    The science collateral masked region start col          col             UINT16
% FDMMSKCOLEND      The science collateral masked region end col            col             UINT16
% FDMDRKROWSTART    The science collateral black region start row           row             UINT16            Dark = Black
% FDMDRKROWEND      The science collateral black region end row             row             UINT16            Dark = Black
% FDMDRKCOLSTART    The science collateral black region start col           col             UINT16            Dark = Black
% FDMDRKCOLEND      The science collateral black region end col             col             UINT16            Dark = Black
% PEDFOC1POS        Current position of focus mechanism 1                   DN              INT16             dn to um conversion, c0=24.877  c1=-0.035
% PEDFOC2POS        Current position of focus mechanism 2                   DN              INT16             dn to um conversion, c0=34.732  c1=-0.0356
% PEDFOC3POS        Current position of focus mechanism 3                   DN              INT16             dn to um conversion, c0=28.538  c1=-0.0368
% PEDFPAHCSETPT     Commanded set point to control FPA temperature          DN              INT16             dn to deg C conversion, c0=-88.58  c1=6.5034E-4  c2=1.0912E-10, 5500 = -85 (default value)
% bugzilla #738, #928
% FDMLCOFFSET      requantization table LC fixed offset                       # (ADU?)        INT16             offset added to requantized values to keep them positive
% FDMSCOFFSET      requantization table SC fixed offset                       # (ADU?)        INT16             offset added to requantized values to keep them positive
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



if(isempty(configMaps))
    error('configMapClass:emptyConfigMapModel',...
        'configMapClass constructor must be called with valid (non-empty) configmap models')
end


mnemonicDescriptionPair = cell(30,2);
mnemonicDescriptionPair(:,1)={
    'TCSCCFGID'
    'timestamp'
    'GSFSWBLD'
    'GSFSWREL'
    'GSFSWUPDATE'
    'FDMINTPER'
    'GSprm_FGSPER'
    'GSprm_ROPER'
    'FDMSCPER'
    'FDMLCPER'
    'FDMNUMLCPERBL'
    'FDMLDEFFINUM'
    'FDMSMRROWSTART'
    'FDMSMRROWEND'
    'FDMSMRCOLSTART'
    'FDMSMRCOLEND'
    'FDMMSKROWSTART'
    'FDMMSKROWEND'
    'FDMMSKCOLSTART'
    'FDMMSKCOLEND'
    'FDMDRKROWSTART'
    'FDMDRKROWEND'
    'FDMDRKCOLSTART'
    'FDMDRKCOLEND'
    'PEDFOC1POS'
    'PEDFOC2POS'
    'PEDFOC3POS'
    'PEDFPAHCSETPT'
    'FDMLCOFFSET'
    'FDMSCOFFSET'
    };

% validate inputs
validate_configmaps_input_structure(configMaps);


mnemonicDescriptionPair(:,2)={
    'configId'
    'timeStampInCCSDS'
    'FSWbuildVersionNumber'
    'FSWreleaseVersionNumber'
    'FSWupdateVersionNumber'
    'integrationTimeInFGSframes'
    'FGSframePeriodInMsec'
    'readoutPeriodInMsec'
    'shortCadencePeriodInIntegrations'
    'longCadencePeriodInShortCadences'
    'numberOfLCperiodsBetweenBaselines'
    'numberOfIntegrationsInFFI'
    'smearRegionStartRow'
    'smearRegionEndRow'
    'smearRegionStartColumn'
    'smearRegionEndColumn'
    'maskedRegionStartRow'
    'maskedRegionEndRow'
    'maskedRegionStartColumn'
    'maskedRegionEndColumn'
    'blackRegionStartRow'
    'blackRegionEndRow'
    'blackRegionStartColumn'
    'blackRegionEndColumn'
    'positionOfFocusMechanism1InDN'
    'positionOfFocusMechanism2InDN'
    'positionOfFocusMechanism3InDN'
    'setPointToControlFPATempInDN'
    'requantTableLcFixedOffset'
    'requantTableScFixedOffset'
    };

fieldsAndBounds = cell(29,4);

fieldsAndBounds(6,:)  = { 'FDMINTPER'; ' > 0'; '< 1e4'; []};
fieldsAndBounds(7,:)  = { 'GSprm_FGSPER'; ' > 0'; '< 1e6'; []};
fieldsAndBounds(8,:)  = { 'GSprm_ROPER'; ' > 0'; '< 1e6'; []};
fieldsAndBounds(9,:)  = { 'FDMSCPER'; ' > 0'; '< 1e2'; []};
fieldsAndBounds(10,:)  = { 'FDMLCPER'; ' > 0'; '< 1e3'; []};
fieldsAndBounds(11,:)  = { 'FDMNUMLCPERBL'; ' > 0'; '< 1e4'; []};
fieldsAndBounds(12,:)  = { 'FDMLDEFFINUM'; ' > 0'; '< 1e4'; []};

fieldsAndBounds(13,:)  = { 'FDMSMRROWSTART'; ' >= 0'; '<= 1069'; []};
fieldsAndBounds(14,:)  = { 'FDMSMRROWEND'; ' >= 0'; '<= 1069'; []};

fieldsAndBounds(15,:)  = { 'FDMSMRCOLSTART'; ' >= 0'; '<= 1131'; []};
fieldsAndBounds(16,:)  = { 'FDMSMRCOLEND'; ' >= 0'; '<= 1131'; []};

fieldsAndBounds(17,:)  = { 'FDMMSKROWSTART'; ' >= 0'; '<= 1069'; []};
fieldsAndBounds(18,:)  = { 'FDMMSKROWEND'; ' >= 0'; '<= 1069'; []};

fieldsAndBounds(19,:)  = { 'FDMMSKCOLSTART'; ' >= 0'; '<= 1131'; []};
fieldsAndBounds(20,:)  = { 'FDMMSKCOLEND'; ' >= 0'; '<= 1131'; []};

fieldsAndBounds(21,:)  = { 'FDMDRKROWSTART'; ' >= 0'; '<= 1069'; []};
fieldsAndBounds(22,:)  = { 'FDMDRKROWEND'; ' >= 0'; '<= 1069'; []};

fieldsAndBounds(23,:)  = { 'FDMDRKCOLSTART'; ' >= 0'; '<= 1131'; []};
fieldsAndBounds(24,:)  = { 'FDMDRKCOLEND'; ' >= 0'; '<= 1131'; []};
fieldsAndBounds(29,:)  = { 'FDMLCOFFSET'; '>=400000'; '<=420000'; []}; % max value is .05*(2^14)*512, same as in validate_requantization_inputs.m
fieldsAndBounds(39,:)  = { 'FDMSCOFFSET'; '>=100000'; '<=420000'; []}; % ????



% add the description string to each mnemonic in the 'entries' structure
nConfigMaps = length(configMaps);

for jMap = 1:nConfigMaps

    nMnemonics = length(configMaps(jMap).entries);
    invalidMnemonics = -1*ones(nMnemonics,1);
    invalidMnemonicsCounter = 0;
    for kMnemonic = 1:nMnemonics

        mnemonic = configMaps(jMap).entries(kMnemonic).mnemonic;
        indexMatched = strmatch(mnemonic, mnemonicDescriptionPair(:,1), 'exact');
        if(~isempty(indexMatched))
            configMaps(jMap).entries(kMnemonic).name = mnemonicDescriptionPair(indexMatched,2);

            % convert the 'value' which is a str to a numerical value
            numericValue = str2double(configMaps(jMap).entries(kMnemonic).value);

            % validate numeric value
            if(isnan(numericValue) || isinf(numericValue) || ~isreal(numericValue) || isempty(numericValue))

                error('configMapClass:get:invalidNumericValue',...
                    ['new or invalid numeric value for  '  mnemonic  ' found for the given time stamp ' num2str(configMaps(jMap).time)]);

            end


            configMaps(jMap).entries(kMnemonic).value = numericValue;

            % validate only the fields of interest
            if(~isempty(cell2mat(fieldsAndBounds(indexMatched,1))))
                validate_field(numericValue, fieldsAndBounds(indexMatched,:), ['configMaps.(' num2str(jMap) ').entries(' num2str(kMnemonic) ')']);
            end

        else

            %             warning('configMapClass:get:invalidUnexpectedMnemonic',...
            %                 ['new or invalid mnemonic '  mnemonic  ' found for the given time stamp ' num2str(configMaps(jMap).time)]);

            invalidMnemonicsCounter = invalidMnemonicsCounter+1;
            invalidMnemonics(invalidMnemonicsCounter) = kMnemonic;
            configMaps(jMap).entries(kMnemonic).name = [];

            % convert the 'value' which is a str to a numerical value
            configMaps(jMap).entries(kMnemonic).value = [];

        end

    end

    % look for invalid mnemonics
    invalidEntries = invalidMnemonics(invalidMnemonics > 0);
    if(~isempty(invalidEntries))
        configMaps(jMap).entries(invalidEntries) = [];
    end



end

configMapObject = class(configMaps, 'configMapClass');


% from this point onwards we work only with the descriptive 'name' created
% for each mnemonic

return

