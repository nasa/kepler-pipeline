function [kics outChars] = retrieve_kics_by_kepler_id(varargin)
% [kics characteristics] = retrieve_kics_by_kepler_id(keplerId)
% or
% [kics characteristics] = retrieve_kics_by_kepler_id(targetListSetName, 'get_chars')
% or
% [kics characteristics] = retrieve_kics_by_kepler_id(targetListSetName, module, output, 'get_chars')
% or
% [kics characteristics] = retrieve_kics_by_kepler_id(keplerId, 'get_chars')
% or
% [kics characteristics] = retrieve_kics_by_kepler_id(vectorOfKeplerIds)
% or
% [kics characteristics] = retrieve_kics_by_kepler_id(vectorOfKeplerIds, 'get_chars')
% or
% [kics characteristics] = retrieve_kics_by_kepler_id(minKeplerId, maxKeplerId)
% or
% [kics characteristics] = retrieve_kics_by_kepler_id(minKeplerId, maxKeplerId, 'get_chars')
% 
% Returns a vector of KIC data corresponding to the KIC entries
% as specified by the input args.
%
% If the final argument is the string 'get_chars', the
% characteristics struct for each KIC object is returned as the separate
% output variable "characteristics".  The default is for this not to be done: 
% extracting the characteristics is VERY SLOW, and should not be done if 
% it is not necessary. 
%
% INPUTS:
%     keplerId          -- A single Kepler ID.
%     vectorOfKeplerIds -- A vector of multiple Kepler IDs.
%     minKeplerId       -- The beginning of a range of Kepler IDs.
%     maxKeplerId       -- The end of a range of Kepler IDs.
%     'get_chars'       -- An optional string argument.  If specified, the characteristics will be fetched.
%
%
% OUTPUTS:
%     kics:
%         Returns a vector of KIC Java objects corresponding to the KIC entries
%         whose Kepler IDs match the specified inputs.
%
%         When a characteristic table entry for a field is available, its latest 
%         value overrides the value from the KIC.
%
%         The data in the KIC objects is accessable through the objects getters,
%         e.g.: kics(5).getDec() will return the declination of the 5th KIC entry.
%
%         A complete list of the getters as of 10-October-2007 is:
%             getAlternateId
%             getAlternateSource
%             getAstrophysicsQuality
%             getAvExtinction
%             getBlendIndicator
%             getCatalogId
%             getD51Mag
%             getDec
%             getDecProperMotion
%             getEbMinusVRedding
%             getEffectiveTemp
%             getGalacticLatitude
%             getGalacticLongitude
%             getGalaxyIndicator
%             getGkColor
%             getGMag
%             getGrColor
%             getGredMag
%             getIMag
%             getJkColor
%             getInternalScpId
%             getKeplerId
%             getKeplerMag
%             getLog10Metallicity
%             getLog10SurfaceGravity
%             getParallax
%             getPhotometryQuality
%             getRa
%             getRadius
%             getRaProperMotion
%             getRMag
%             getScpId
%             getSkyGroupId
%             getSource
%             getTotalProperMotion
%             getTwoMassHMag
%             getTwoMassId
%             getTwoMassJMag
%             getTwoMassKMag
%             getUMag
%             getVariableIndicator
%             getZMag
%
%     characteristics:
%         A struct array with nTargets elements, with each element containing a
%         2-column cell array of the characteristics.  Each row contains the 
%         characteristic name in the first column and the characteristics value
%         in the second column.  Empty if 'get_chars' is not specified.
%
%
% 
% Copyright 2017 United States Government as represented by the
% Administrator of the National Aeronautics and Space Administration.
% All Rights Reserved.
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
import gov.nasa.kepler.systest.sbt.SandboxTools;
SandboxTools.displayDatabaseConfig;

import gov.nasa.kepler.hibernate.dbservice.DatabaseServiceFactory;
import gov.nasa.kepler.fc.rolltime.RollTimeOperations;
import gov.nasa.kepler.common.TargetManagementConstants;

customTargetKeplerIdStart = TargetManagementConstants.CUSTOM_TARGET_KEPLER_ID_START;

kics = []; %#ok<NASGU>

dbService = DatabaseServiceFactory.getInstance();

import gov.nasa.kepler.cm.KicOperations;
kicOps = KicOperations();

isGetChars = 0;
if nargin < 1
    error('retrieve_kics_by_kepler_id requires at least one argument, see helptext');
end
lastArg = varargin{nargin};
if ischar(lastArg) && ~strcmp(lastArg, 'get_chars')
    error('retrieve_kics: unsupported usecase-- get_chars was set to %s, not "get_chars"', lastArg);
end

nargin
if nargin == 1
    % Usecases:
    %     kics = retrieve_kics_by_kepler_id(keplerId)
    %     kics = retrieve_kics_by_kepler_id(vectorOfKeplerIds)
    %
    % If the first arg have more than one element, it is a vector of kepler
    % IDs.  Otherwise, it's a single kepler ID.
    %
    keplerIds = lastArg(:)'; % the "(:)'" syntax forces a row vector, which is required for the below.
    isCustomTarget = keplerIds > customTargetKeplerIdStart;
    nonCustomKics = get_kics(keplerIds(~isCustomTarget));
    customTargets = get_custom_targets(keplerIds(isCustomTarget));
    
    kics = javaArray('java.lang.Object', length(keplerIds));

    iCustomTarget = 1;
    for ii = find(isCustomTarget)
        kics(ii) = customTargets(iCustomTarget);
        iCustomTarget = iCustomTarget+1;
    end
    
    iNonCustomTarget = 1;
    for ii = find(~isCustomTarget)
        kics(ii) = nonCustomKics(iNonCustomTarget);
        iNonCustomTarget = iNonCustomTarget+1;
    end
elseif nargin == 2
    % Usecases:
    %     kics = retrieve_kics_by_kepler_id(keplerId, 'get_chars')
    %     kics = retrieve_kics_by_kepler_id(vectorOfKeplerIds, 'get_chars')
    %     kics = retrieve_kics_by_kepler_id(minKeplerId, maxKeplerId)
    %     [kics outChars] = retrieve_kics_by_kepler_id(targetListSetName, 'get_chars')
    if isnumeric(lastArg) 
        %  (minKeplerId, maxKeplerId) usecase:
        %
        minKeplerId = varargin{1};
        maxKeplerId = varargin{2};
        import gov.nasa.kepler.cm.KicOperations;
        kicOps = KicOperations();
        kics = kicOps.retrieveKics(minKeplerId, maxKeplerId).toArray();    
    else
        isGetChars = 1;

        if ischar(varargin{1})       
            % TargetListSetName usecase:
            %
            targetListSetName = varargin{1};
            
            import gov.nasa.kepler.hibernate.cm.TargetSelectionCrud
            targetSelectionCrud = TargetSelectionCrud();
            targetListSet = targetSelectionCrud.retrieveTargetListSet(targetListSetName);
            
            import java.util.ArrayList
            targetListsJavaString = ArrayList();

            targetLists = targetListSet.getTargetLists();
            for ii=0:targetLists.size()-1
                javaString = targetLists.get(ii).toString;
                targetListsJavaString.add(javaString);
            end

            keplerIds = targetSelectionCrud.retrieveKeplerIdsForTargetListName(targetListsJavaString).toArray();
            kics = get_kics(keplerIds);
            kicList = vector_to_array_list(keplerIds);
        else
            % KeplerId vector usecase:
            %
            keplerIds = varargin{1};
            keplerIds = keplerIds(:)'; % the "(:)'" syntax forces a row vector, which is required for the below.

            isCustomTarget = keplerIds > customTargetKeplerIdStart;
            nonCustomKics = get_kics(keplerIds(~isCustomTarget));
            customTargets = get_custom_targets(keplerIds(isCustomTarget));
            
            kics = javaArray('java.lang.Object', length(keplerIds));

            iCustomTarget = 1;
            for ii = find(isCustomTarget)
                kics(ii) = customTargets(iCustomTarget);
                iCustomTarget = iCustomTarget+1;
            end
            
            iNonCustomTarget = 1;
            for ii = find(~isCustomTarget)
                kics(ii) = nonCustomKics(iNonCustomTarget);
                iNonCustomTarget = iNonCustomTarget+1;
            end

            kicList = vector_to_array_list(keplerIds);
        end
    end
elseif nargin == 3
    % Usecase: 
    %     kics = retrieve_kics_by_kepler_id(minKeplerId, maxKeplerId, 'get_chars')
    isGetChars = 1;
    minKeplerId = varargin{1};
    maxKeplerId = varargin{2};
    if ~strcmp(varargin{3}, 'get_chars')
        error('retrieve_kics_by_kepler_id: the three-argument usecase is "kics = retrieve_kics_by_kepler_id(minKeplerId, maxKeplerId, ''get_chars'')"  ');
    end
    
    kicList = vector_to_array_list(minKeplerId:maxKeplerId);
    kics = kicOps.retrieveKics(minKeplerId, maxKeplerId).toArray();
elseif nargin == 4
    % Usecase:
    %    [kics outChars] = retrieve_kics_by_kepler_id(targetListSetName, module, output, 'get_chars')
    isGetChars = 1;
    targetListSetName = varargin{1};
    ccdModule = varargin{2};
    ccdOutput = varargin{3};
    
    import gov.nasa.kepler.hibernate.cm.TargetSelectionCrud;
    import gov.nasa.kepler.common.ModifiedJulianDate;
    import gov.nasa.kepler.fc.rolltime.RollTimeOperations;
    import gov.nasa.kepler.hibernate.cm.KicCrud;
    
    % Get TargetListSet from its name:
    %
    targetSelectionCrud = TargetSelectionCrud();
    targetListSet = targetSelectionCrud.retrieveTargetListSet(targetListSetName);

    % Get the SkyGroupId TargetListSet.Date, module, and output:
    %
    dateFromTargetListSet = targetListSet.getStart();
    mjd = ModifiedJulianDate.dateToMjd(dateFromTargetListSet);
    rtOps = RollTimeOperations();
    season = rtOps.mjdToSeason(mjd);
    kicCrud = KicCrud();
    skyGroupId = kicCrud.retrieveSkyGroupId(ccdModule, ccdOutput, season);
    
    % Get the TargetList names in a Java Collection:
    %
    import java.util.ArrayList
    targetListsJavaString = ArrayList();
    targetLists = targetListSet.getTargetLists();
    for ii=0:targetLists.size()-1
        javaString = targetLists.get(ii).toString;
        targetListsJavaString.add(javaString);
    end
    keplerIds = targetSelectionCrud.retrieveKeplerIdsForTargetListNameMatlabFriendly(targetListsJavaString, skyGroupId).toArray();
    kics = get_kics(keplerIds);
    kicList = vector_to_array_list(keplerIds);
else
    error('retrieve_kics_by_kepler_id: incorrect number of arguments');
end

% Error out if there were no KICs:
%
if isempty(kics)
    if nargin == 1
        error('retrieve_kics_by_kepler_id: No KIC entries found for Kepler ID =%d', lastArg);
    else
        error('retrieve_kics_by_kepler_id: No KIC entries found for Kepler ID range=%d-%d', minKeplerId, maxKeplerId);
    end
end

outChars = repmat(struct(...
    'CHANNEL_SEASON_0', nan, ...
    'CHANNEL_SEASON_1', nan, ...
    'CHANNEL_SEASON_2', nan, ...
    'CHANNEL_SEASON_3', nan, ...
    'COLUMN_SEASON_0', nan, ...
    'COLUMN_SEASON_1', nan, ...
    'COLUMN_SEASON_2', nan, ...
    'COLUMN_SEASON_3', nan, ...
    'MODULE_SEASON_0', nan, ...
    'MODULE_SEASON_1', nan, ...
    'MODULE_SEASON_2', nan, ...
    'MODULE_SEASON_3', nan, ...
    'OUTPUT_SEASON_0', nan, ...
    'OUTPUT_SEASON_1', nan, ...
    'OUTPUT_SEASON_2', nan, ...
    'OUTPUT_SEASON_3', nan, ...
    'ROW_SEASON_0', nan, ...
    'ROW_SEASON_1', nan, ...
    'ROW_SEASON_2', nan, ...
    'ROW_SEASON_3', nan, ...
    'SKY_GROUP_ID', nan, ...
    'CROWDING',     nan, ...
    'KTC_FLAG',     nan, ...
    'SOC_MAG',      nan, ...
    'RA',           nan, ...
    'DEC',          nan), length(kics), 1);

if isGetChars
    import gov.nasa.kepler.hibernate.cm.*;
    charCrud = CharacteristicCrud();
    
    t1 = clock();
    charMaps = charCrud.retrieveCharacteristicMaps(kicList);
    t2 = clock();
    msg = sprintf('time to retreive characteristic maps is %f', etime(t2,t1));
    disp(msg)

    for ikic = 1:length(kics)
        if mod(ikic, 1000) == 0
            msgStr = sprintf('Extracting characteristics: %d of %d', ikic, length(kics));
            disp(msgStr);
        end
        if isempty(kics(ikic))
            continue
        end
        keplerId = int32(kics(ikic).getKeplerId());
        
        % Pull out the contents of the characteristics map for this KIC.  Note, if
        % this map is empty, this loop will (correctly) procede on to
        % the next KIC.
        %
        charMap = charMaps.get(keplerId);
        charsArray = charMap.entrySet.toArray;

        % Populate this KIC's characteristics struct:
        %
        for ichar = 1:length(charsArray)
            charElement = charsArray(ichar);
            key = char(charElement.getKey.toString);
            value = charElement.getValue;

            outChars(ikic).(key) = value;
        end
    end
    
    
end

dbService.clear();
SandboxTools.close;
return


function kics = get_kics(keplerId)
    import gov.nasa.kepler.cm.KicOperations;
    kicOps = KicOperations();
    kicList = vector_to_array_list(keplerId);
    kicsArrayList = kicOps.retrieveKics(kicList);
    kics = kicsArrayList.toArray();
return

function customTargets = get_custom_targets(keplerId)
    import gov.nasa.kepler.hibernate.cm.CustomTargetCrud;
    ctCrud = CustomTargetCrud();
    kicList = vector_to_array_list(keplerId);
    customTargetArrayList = ctCrud.retrieveCustomTargets(kicList);
    customTargets = customTargetArrayList.toArray();
return

function kicList = vector_to_array_list(keplerIdVector)
    import java.util.ArrayList;
    kicList = java.util.ArrayList();
    for ii = 1:length(keplerIdVector)
        kicList.add(int32(keplerIdVector(ii)));
    end
return
