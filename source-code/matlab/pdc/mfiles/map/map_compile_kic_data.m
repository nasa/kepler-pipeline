%*******************************************************************************
% function [] = map_compile_kic_data (mapData, mapInput)
%*******************************************************************************
%
% Compiles the Kic data for all targets in this module output and assmebles it in an easily
% accessible struct array.
%
% For 8.0 and later data the KIC information will be in the targetDataStruct. When the KIC
% information is not available then lookup the KICs in the referenced .mat file. This check will
% only occur if mapDebugClass.doFindKicDatabase = TRUE. 
%
% If the KIC information for a target cannot be found in the database or is not already in the
% targetDataStruct and mapDebugClass.doFindKicDatabase = FALSE then a warning is issued to alerts
% and these targets will be removed from the list to generate the Prior PDF from.
%
% Unavailable KIC information will be defined as out of range values as defined below:
%   kepID   -- <=0 or NaN
%   RA      -- <=0 or NaN
%   dec     -- <=0 or NaN
%   kepMag  -- <=0 or NaN
%   effTemp -- <=0 or NaN
%   logRadius  -- <=0 or NaN
% If pdc_convert_70_data_to_80.m is run then all old data will have kic fields pre-filled with NaNs.
% So, if targetDataStruct.kic does not exist then issue an error and state that old data must be
% converted for version 8.0.
%
%
% Kic database file fields:
%       'KEPLER_ID'    'SKY_GROUP_ID'    'RA'    'DEC'    'KEPMAG
%******************************************************************************
%   Inputs:
%       mapInput
%
%******************************************************************************
%   Outputs:
%
%       mapData.kic  -- [kicDataStruct]
%           targetsWhereKicDataNotFound -- [logical array(nTargets)] targets where KIC data is not valid  
%           kicDataStruct  -- [Struct]
%               fields: keplerId    -- [int   array(nTargets)]
%                       ra          -- [float array(nTargets)]
%                       dec         -- [float array(nTargets)]
%                       keplerMag   -- [float array(nTargets)]
%                       effTemp     -- [float array(nTargets)]
%                       logRadius   -- [float array(nTargets)]
%
%******************************************************************************
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

function [] = map_compile_kic_data (mapData, mapInput)

component = 'compileKicData';
mapInput.debug.display(component, 'Compiling KIC data...');

kicDataFile = '$SOC_TESTDATA_ROOT/cm/kic.mat';


% First check to see if structure exists in targetDataStruct
fieldNames = fieldnames(mapInput.targetDataStruct);
if(~any(strcmp('kic', fieldNames)))
    string = [mapInput.debug.runLabel, ...
            ': MAP: kic structure does not exist in targetDataStruct! Pre-8.0 data must be converted for use with MAP'];
    mapInput.debug.display(component, string);
    [mapData.alerts] = add_alert(mapData.alerts, 'error', string);
    error(string)
end

% Construct kic structure
kicDataStruct = struct ( ...
    'keplerId', zeros(mapData.nTargets, 1, 'int32'), ...
    'ra', zeros(mapData.nTargets, 1), ...
    'dec', zeros(mapData.nTargets,1 ), ...
    'keplerMag', zeros(mapData.nTargets,1 ), ...
    'effTemp', zeros(mapData.nTargets,1 ), ...
    'logRadius', zeros(mapData.nTargets,1 ));

% The Kepler ID should be valid for all entries in mapInput.TargetDataStruct.kic
% Collect kepMag, ra and dec for all targets as well to see what is missing
tempKicStruct = [mapInput.targetDataStruct.kic];
keplerIdArray = [tempKicStruct.keplerId]';
kicDataStruct.keplerId = keplerIdArray;
tempRaStruct  = [tempKicStruct.ra]; 
kicDataStruct.ra = [tempRaStruct.value]';
tempDecStruct  = [tempKicStruct.dec]; 
kicDataStruct.dec = [tempDecStruct.value]';
tempKeplerMagStruct  = [tempKicStruct.keplerMag]; 
kicDataStruct.keplerMag = [tempKeplerMagStruct.value]';
tempEffTempStruct  = [tempKicStruct.effectiveTemp]; 
kicDataStruct.effTemp = [tempEffTempStruct.value]';
tempLogRadiusStruct  = [tempKicStruct.radius]; 
kicDataStruct.logRadius = log([tempLogRadiusStruct.value])';

%% Find which targets we need to search in KIC database
% This database only has kepMag Dec and RA in it.
targetsToFindInDatabase  = isnan(kicDataStruct.ra)    | isnan(kicDataStruct.dec);
targetsToFindInDatabase  = targetsToFindInDatabase | isnan(kicDataStruct.keplerMag);
targetsToFindInDatabase  = targetsToFindInDatabase | kicDataStruct.ra < 0;
targetsToFindInDatabase  = targetsToFindInDatabase | kicDataStruct.dec < 0;
targetsToFindInDatabase  = targetsToFindInDatabase | kicDataStruct.keplerMag < 0;

keplerIdsToFindInDatabase = keplerIdArray(targetsToFindInDatabase);

% Search the kic database to fill in missing KIC data but only if this is a diagnostic run or debugRun
if (any(targetsToFindInDatabase) && mapInput.debug.doFindKicDatabase)
    % We need to now access the database and collect the missing information
    % Find the file
    [~, kicDatabasePath] = system(['echo ', kicDataFile]);
    load(strtrim(kicDatabasePath));
    % First just find all targets in this sky group to speed up the search
    % This also includes many targets that are not studied
    % Assume the first targetDataStruct target skygroup is the skygroup we want (This should be
    % a safe assumption)
    skyGroup = kic(kic(:,1) == mapInput.targetDataStruct(1).keplerId,2);
    reducedKic = kic(kic(:,2) == skyGroup,:);

    % Now find entries in reduced KIC matrix corresponding to the Kepler IDs we want
    allTargetIndices = 1 : mapData.nTargets;
    targetIndicesToFindInDatabase = allTargetIndices(targetsToFindInDatabase);
    [~, kicIndices, targetIndices] = ...
                intersect(reducedKic(:,1), keplerIdsToFindInDatabase);
    kicDataStruct.keplerId(targetIndicesToFindInDatabase(targetIndices))  = reducedKic(kicIndices,1);
    kicDataStruct.ra(targetIndicesToFindInDatabase(targetIndices))        = reducedKic(kicIndices,3);
    kicDataStruct.dec(targetIndicesToFindInDatabase(targetIndices))       = reducedKic(kicIndices,4);
    kicDataStruct.keplerMag(targetIndicesToFindInDatabase(targetIndices)) = reducedKic(kicIndices,5);

    % A parity check to confirm target order is preserved
    % Ramdomly pick a target and see if everything agrees
    randomIndex = randi(mapInput.randomStream,mapData.nTargets);
    randomKeplerId = keplerIdArray(randomIndex);
    reducedkicIndex = find(reducedKic(:,1) == randomKeplerId);
    randomRa = reducedKic(reducedkicIndex,3);
    randomDec = reducedKic(reducedkicIndex,4);
    randomKeplerMag = reducedKic(reducedkicIndex,5);

    if (randomKeplerId ~= kicDataStruct.keplerId(randomIndex) || randomRa ~= kicDataStruct.ra(randomIndex) || ...
        randomDec ~= kicDataStruct.dec(randomIndex) || randomKeplerMag ~= kicDataStruct.keplerMag(randomIndex))
        string = [mapInput.debug.runLabel, ': MAP: Target order was not preserved while compiling KIC data!'];
        mapInput.debug.display(component, string);
        [mapData.alerts] = add_alert(mapData.alerts, 'error', string);
        error(string)
    end
end

% Check which targets full kic information could not be obtained for
mapData.targetsWhereKicDataNotFound  = isnan(kicDataStruct.ra)    | isnan(kicDataStruct.dec);
mapData.targetsWhereKicDataNotFound  = mapData.targetsWhereKicDataNotFound | isnan(kicDataStruct.keplerMag);
mapData.targetsWhereKicDataNotFound  = mapData.targetsWhereKicDataNotFound | kicDataStruct.ra < 0 | kicDataStruct.ra > 24; % In hours
mapData.targetsWhereKicDataNotFound  = mapData.targetsWhereKicDataNotFound | abs(kicDataStruct.dec) >= 90; % In degrees
mapData.targetsWhereKicDataNotFound  = mapData.targetsWhereKicDataNotFound | kicDataStruct.keplerMag < 0;
% Only check extra KIC fields if using them in prior
if (mapInput.mapParams.priorEffTempScalingFactor ~= 0)
    mapData.targetsWhereKicDataNotFound  = mapData.targetsWhereKicDataNotFound | kicDataStruct.effTemp < 0;
    mapData.targetsWhereKicDataNotFound  = mapData.targetsWhereKicDataNotFound | isnan(kicDataStruct.effTemp);
end
if (mapInput.mapParams.priorLogRadiusScalingFactor ~= 0)
    mapData.targetsWhereKicDataNotFound  = mapData.targetsWhereKicDataNotFound | isnan(kicDataStruct.logRadius);
end

mapData.kic = kicDataStruct;
        
if (mapInput.debug.query_do_plot(component));
    % Scatter plot
    kicScatterFig = mapInput.debug.create_figure;
    % All targets
    plot3([mapData.kic.ra], [mapData.kic.dec], [mapData.kic.keplerMag], '*b')
    xlabel('Right Assension [degrees]');
    ylabel('Declination [hours]');
    zlabel('Kepler Magnitude');
    title('Scatter plot of RA, Dec and Kepler Magnitdue for all targets in FOV.');
    legend('All Targets');
    grid;
    box on;
    mapInput.debug.save_figure(kicScatterFig, component, 'kic_scatter_plot');
end

mapInput.debug.display(component, 'Finished compiling KIC data.');

return
