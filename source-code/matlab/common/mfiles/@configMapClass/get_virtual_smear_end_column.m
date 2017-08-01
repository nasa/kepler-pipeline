function [virtualSmearEndColumns, closestConfigMapTimeStamps] = get_virtual_smear_end_column(configMapObject, timeStamps)
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function [virtualSmearEndColumns, closestConfigMapTimeStamps] = get_virtual_smear_end_column(configMapObject, timeStamps)
%
%
%
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% define the fields of the configMapClass here....from SOC-MOC ICD
% Mnemonic          Description                                             Units           Type              Notes
% TCSCCFGID         commanded SC configuration ID                           #               UINT32
% Timestamp         Time when SC configuration ID is commanded              CCSDS time      TimeStringXB      yyyyDDDhhmmss
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
%
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

% fields are ...(FGS stands for Fine Guidance Sensor)

% configId
% timeStampInCCSDS
% FSWbuildVersionNumber
% FSWreleaseVersionNumber
% FSWupdateVersionNumber
% integrationTimeInFGSframes
% FGSframePeriodInMsec
% readoutPeriodInMsec
% shortCadencePeriodInIntegrations
% longCadencePeriodInShortCadences
% numberOfLCperiodsBetweenBaselines
% numberOfIntegrationsInFFI
% smearRegionStartRow
% smearRegionEndRow
% smearRegionStartColumn
% smearRegionEndColumn
% maskedRegionStartRow
% maskedRegionEndRow
% maskedRegionStartColumn
% maskedRegionEndColumn
% blackRegionStartRow
% blackRegionEndRow
% blackRegionStartColumn
% blackRegionEndColumn
% positionOfFocusMechanism1InDN
% positionOfFocusMechanism2InDN
% positionOfFocusMechanism3InDN
% setPointToControlFPATempInDN
%
%


% for the invalid time stamps return a -1
allTimeStamps = cat(1, configMapObject.time);

if( ~exist('timeStamps', 'var'))
    timeStamps = allTimeStamps;
end


if(isempty(timeStamps))
    timeStamps = allTimeStamps;
end


nTimeStamps = length(timeStamps);

virtualSmearEndColumns = -1*ones(nTimeStamps,1);
closestConfigMapTimeStamps = -1*ones(nTimeStamps,1);



for jTimeStamp = 1:nTimeStamps

    % look for the time stamp or the nearest time stamp (closest earlier
    % timestamp) and return the structure

    closestTimeIndex = find((allTimeStamps - timeStamps(jTimeStamp)) <= 0, 1,'last');

    if(isempty(closestTimeIndex))
        error('configMapClass:get:invalidTimestamp',...
            ['no match found for the given time stamp ' num2str(timeStamps(jTimeStamp))]);
    end

    closestConfigMapTimeStamps(jTimeStamp) = configMapObject(closestTimeIndex).time;


    allNames = cat(1,configMapObject(closestTimeIndex).entries.name);

    indexMatched = strmatch('smearRegionEndColumn', allNames, 'exact');
    if(~isempty(indexMatched))
        smearRegionEndColumn = configMapObject(closestTimeIndex).entries(indexMatched).value;
    else
        error('configMapClass:get:invalidFieldName',...
            ['no match found for the given field smearRegionEndColumn - for the time stamp ' num2str(timeStamps(jTimeStamp))]);
    end

    virtualSmearEndColumns(jTimeStamp) = smearRegionEndColumn + 1; %  % converts to 1-based column value

end

return