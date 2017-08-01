%% dv_convert_82_data_to_83
%
% function dvDataStruct = dv_convert_82_data_to_83(dvDataStruct)
%
% Update 8.2-era DV input structures to 8.3. This is useful when testing
% with existing data sets.
%%
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

function dvDataStruct = dv_convert_82_data_to_83(dvDataStruct)

% Add planet fit parameters.
if ~isfield(dvDataStruct.planetFitConfigurationStruct, ...
        'defaultAlbedo')
    dvDataStruct.planetFitConfigurationStruct.defaultAlbedo = 0.3;
end % if
if ~isfield(dvDataStruct.planetFitConfigurationStruct, ...
        'reducedParameterFitsEnabled')
    dvDataStruct.planetFitConfigurationStruct.reducedParameterFitsEnabled = false;
end % if
if ~isfield(dvDataStruct.planetFitConfigurationStruct, ...
        'impactParametersForReducedFits')
    dvDataStruct.planetFitConfigurationStruct.impactParametersForReducedFits = [];
end % if
if ~isfield(dvDataStruct.planetFitConfigurationStruct, ...
        'impactParameterSeed')
    dvDataStruct.planetFitConfigurationStruct.impactParameterSeed = 0.1;
end % if
if ~isfield(dvDataStruct.planetFitConfigurationStruct, ...
        'reportSummaryClippingLevel')
    dvDataStruct.planetFitConfigurationStruct.reportSummaryClippingLevel = 4.0;
end % if
if ~isfield(dvDataStruct.planetFitConfigurationStruct, ...
        'reportSummaryBinsPerTransit')
    dvDataStruct.planetFitConfigurationStruct.reportSummaryBinsPerTransit = 5.0;
end % if

% Add empty pixel data file names if necessary.
nTargets = length(dvDataStruct.targetStruct);

for iTarget = 1 : nTargets
    if ~isfield(dvDataStruct.targetStruct(iTarget).targetDataStruct(1), ...
            'pixelDataFileName') || ...
            isempty(dvDataStruct.targetStruct(iTarget).targetDataStruct(1).pixelDataFileName)
        pixelDataDir = 'pixelData';
        if ~exist(pixelDataDir, 'dir')
            mkdir(pixelDataDir);
        end % if
        keplerId = dvDataStruct.targetStruct(iTarget).keplerId;
        targetDir = fullfile(pixelDataDir, sprintf('%09d', keplerId));
        if ~exist(targetDir, 'dir')
            mkdir(targetDir);
        end % if
        nTables = ...
            length(dvDataStruct.targetStruct(iTarget).targetDataStruct);
        for iTable = 1 : nTables
            targetDataStruct = ...
                dvDataStruct.targetStruct(iTarget).targetDataStruct(iTable);
            targetTableId = targetDataStruct.targetTableId;
            quarter = targetDataStruct.quarter;
            pixelDataFileName = ...
                fullfile(targetDir, sprintf('tt%03d-q%02d.mat', ...
                targetTableId, quarter));
            pixelDataStruct = ...
                dvDataStruct.targetStruct(iTarget).targetDataStruct(iTable).pixelDataStruct;  %#ok<NASGU>
            save(pixelDataFileName, 'pixelDataStruct');
            dvDataStruct.targetStruct(iTarget).targetDataStruct(iTable).pixelDataFileName = ...
                pixelDataFileName;
        end % for iTable
        dvDataStruct.targetStruct(iTarget).targetDataStruct = ...
            rmfield(dvDataStruct.targetStruct(iTarget).targetDataStruct, 'pixelDataStruct');
    end % if
end % for iTarget

% Write ancillary engineering data to mat-file if necessary and update file
% name in DV data structure.
if isempty(dvDataStruct.ancillaryEngineeringDataFileName)
    if isfield(dvDataStruct, 'ancillaryEngineeringDataStruct')
        ancillaryEngineeringDataStruct = ...
            dvDataStruct.ancillaryEngineeringDataStruct;                                     %#ok<NASGU>
        dvDataStruct = ...
            rmfield(dvDataStruct, 'ancillaryEngineeringDataStruct');
    else
        ancillaryEngineeringDataStruct = [];                                                 %#ok<NASGU>
    end % if / end
    ancillaryEngineeringDataFileName = 'ancillaryEngineeringData.mat';
    save(ancillaryEngineeringDataFileName, ...
        'ancillaryEngineeringDataStruct');
    dvDataStruct.ancillaryEngineeringDataFileName = ...
        ancillaryEngineeringDataFileName;
end % if

% Correct the TPS module parameters.
dummyStruct.tpsModuleParameters = dvDataStruct.tpsConfigurationStruct;
dummyStruct = tps_convert_82_data_to_83(dummyStruct);
dvDataStruct.tpsConfigurationStruct = dummyStruct.tpsModuleParameters;

% Add new PDC module parameters.
if ~isfield(dvDataStruct.pdcConfigurationStruct, ...
        'mapSelectionMethod')
    dvDataStruct.pdcConfigurationStruct.mapSelectionMethod = ...
        'noiseVariabilityEarthpoints';
end % if
if ~isfield(dvDataStruct.pdcConfigurationStruct, ...
        'mapSelectionMethodCutoff')
    dvDataStruct.pdcConfigurationStruct.mapSelectionMethodCutoff = 0.8;
end % if
if ~isfield(dvDataStruct.pdcConfigurationStruct, ...
        'mapSelectionMethodMultiscaleBias')
    dvDataStruct.pdcConfigurationStruct.mapSelectionMethodMultiscaleBias = 0.1;
end % if

return
