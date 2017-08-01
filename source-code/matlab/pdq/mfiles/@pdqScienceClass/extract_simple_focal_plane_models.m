function [gainForAllCadencesAllModOuts, readNoiseForAllCadencesAllModOuts, configMapStruct, requantTableStruct]...
    = extract_simple_focal_plane_models(pdqScienceObject)
%----------------------------------------------------------------------
% function [gainForAllCadencesAllModOuts,
% readNoiseForAllCadencesAllModOuts, configMapStruct,
% requantTableStruct]...
%     = extract_simple_focal_plane_models(pdqScienceObject)
% This function instantiates gain, read noise model, and spacecraft config
% map. These are simple models and contain one value per modout per time
% stamp or 84 such values per time stamp
%----------------------------------------------------------------------
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

gainObject                          = gainClass(pdqScienceObject.gainModel);

gainForAllCadencesAllModOuts        = get_gain(gainObject, pdqScienceObject.cadenceTimes);

readNoiseObject                     = readNoiseClass(pdqScienceObject.readNoiseModel);

readNoiseForAllCadencesAllModOuts   = get_read_noise(readNoiseObject, pdqScienceObject.cadenceTimes);

configMapObject                     = configMapClass(pdqScienceObject.configMaps);


% mnemonicDescriptionPair(:,2)={
%     'configId'
%     'timeStampInCCSDS'
%     'FSWbuildVersionNumber'
%     'FSWreleaseVersionNumber'
%     'FSWupdateVersionNumber'
%     'integrationTimeInFGSframes'
%     'FGSframePeriodInMsec'
%     'readoutPeriodInMsec'
%     'shortCadencePeriodInIntergrations'
%     'longCadencePeriodInShortCadences'
%     'numberOfLCperiodsBetweenBaselines'
%     'numberOfIntegrationsInFFI'
%     'smearRegionStartRow'
%     'smearRegionEndRow'
%     'smearRegionStartColumn'
%     'smearRegionEndColumn'
%     'maskedRegionStartRow'
%     'maskedRegionEndRow'
%     'maskedRegionStartColumn'
%     'maskedRegionEndColumn'
%     'blackRegionStartRow'
%     'blackRegionEndRow'
%     'blackRegionStartColumn'
%     'blackRegionEndColumn'
%     'positionOfFocusMechanism1InDN'
%     'positionOfFocusMechanism2InDN'
%     'positionOfFocusMechanism3InDN'
%     'setPointToControlFPATempInDN'
%     };


configMapStruct = struct('ccdReadTime', [], 'ccdExposureTime', [], 'numberOfExposuresPerLongCadence', []);

configMapStruct.ccdReadTime = get_readout_time(configMapObject, pdqScienceObject.cadenceTimes);

configMapStruct.ccdExposureTime = get_exposure_time(configMapObject, pdqScienceObject.cadenceTimes);

configMapStruct.numberOfExposuresPerLongCadence = ...
    get_number_of_exposures_per_long_cadence_period(configMapObject, pdqScienceObject.cadenceTimes);


% get fixed offset from configmap
requantTableStruct.requantizationTableFixedOffset = get_fixed_offset(configMapObject, pdqScienceObject.cadenceTimes);


% s.requantTables
% ans = 
%           externalId: 1
%             startMjd: 5.5554e+004
%       requantEntries: [65536x1 double]
%     meanBlackEntries: [84x1 double]

% get fixed offset from configmap
requantTableObject = requantTableClass(pdqScienceObject.requantTables);
[meanBlackTables] = get_mean_black_table(requantTableObject, pdqScienceObject.cadenceTimes);

requantTableStruct.meanBlackEntries = meanBlackTables;

return


