function [kics outChars] = retrieve_kics(varargin)
%function [kics characteristics] = retrieve_kics(module, output, mjd) 
% or
%function [kics characteristics] = retrieve_kics(module, output, mjd, 'get_chars') 
% or
%function [kics characteristics] = retrieve_kics(module, output, mjd, minKeplerMag, maxKeplerMag)
% or
%function [kics characteristics] = retrieve_kics(module, output, mjd, minKeplerMag, maxKeplerMag, 'get_chars')
% 
% Returns a vector of KIC objects corresponding to the KIC entries
% that fall on the specified module and output on the given MJD time.
%
% If the final argument is the string 'get_chars', the
% characteristics struct for each KIC object is returned as the separate
% output variable "characteristics".  The default is for this not to be done: 
% extracting the characteristics is VERY SLOW, and should not be done if 
% it is not necessary. 
%
% INPUTS:
%     module        -- The module on the Kepler focal plane (a scalar value).
%     output        -- The output on the Kepler focal plane (a scalar value).
%     mjd           -- The MJD of interest (a scalar value)
%     minKeplerMag  -- The minimum Kepler magnitude to get data for (optional: the default is to retrieve all targets).
%     maxKeplerMag  -- The maximum Kepler magnitude to get data for (optional: the default is to retrieve all targets).
%     'get_chars'   -- An optional string argument.  If specified, the characteristics will be fetched.
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

import gov.nasa.kepler.mc.cm.CelestialObjectOperations;
import gov.nasa.kepler.hibernate.pi.ModelMetadataRetrieverLatest;
import gov.nasa.kepler.hibernate.dbservice.DatabaseServiceFactory;
import gov.nasa.kepler.fc.rolltime.RollTimeOperations;

kics = [];

dbService = DatabaseServiceFactory.getInstance();

modelMetadataRetrieverLatest = ModelMetadataRetrieverLatest();
celestialObjectOps = CelestialObjectOperations(modelMetadataRetrieverLatest, true);
rtOps = RollTimeOperations();

% Parse args:
%
if nargin < 3 || nargin > 6
    error('retrieve_kics: incorrect number of arguments');
end
if nargin <= 6
    module = varargin{1};
    output = varargin{2};
    mjd    = varargin{3};
end
if nargin == 4 || nargin == 6
    lastArg = varargin{nargin};
    if strcmp('get_chars', lastArg)
        isGetChars = 1;
    else
        msg = ['retrieve_kics: unsupported usecase-- get_chars was set to "' lastArg '", not "get_chars"'];
        error(msg);
    end
else
    isGetChars = 0;
end
if nargin == 5 || nargin == 6
    minKeplerMag = varargin{4};
    maxKeplerMag = varargin{5};
end

% Run the KicCrud call:
%
season = rtOps.mjdToSeason(mjd);
switch nargin
    case {3, 4}
        kics = celestialObjectOps.retrieveCelestialObjects(module, output, season).toArray();
    case {5, 6}
        kics = celestialObjectOps.retrieveCelestialObjects(module, output, season, minKeplerMag, maxKeplerMag).toArray();
end

if(isempty(kics))
    error('retrieve_kics: No KIC entries found for mod/out=%d/%d, mjd=%d, season=%d', module, output, mjd, season);
end;

% Get the characteristics, if they were requested:
%
outChars=[];

if isGetChars
    timeStringOp1 = 0;
    timeStringOp2 = 0;
    timeWriteToOutChars = 0;
    timeCrudOp = 0;
    
    skyGroup = retrieve_sky_group(kics(1).getKeplerId, mjd);
 
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
 
    import gov.nasa.kepler.hibernate.cm.*;
    charCrud = CharacteristicCrud();
    charMaps = charCrud.retrieveCharacteristicMapsMatlabFriendly(skyGroup.skyGroupId);


    % Make a lookup table of characteristicTypeId --> characteristicName
    %
    charTypes = charCrud.retrieveAllCharacteristicTypes();
    for ict = 1:charTypes.size()
        charType = charTypes.get(ict-1);
        charLookup{charType.getId()} = char(charType.getName());
    end

    for ikic = 1:length(kics) 
        if mod(ikic, 1000) == 0
            msgStr = sprintf('Extracting characteristics: %d of %d', ikic, length(kics));
            disp(msgStr);
        end
        keplerId = int32(kics(ikic).getKeplerId());
        
        % Pull out the contents of the characteristics map for this KIC.  Note, if
        % this map is empty, this loop will (correctly) procede on to 
        % the next KIC.
        %
        charMap = charMaps.get(keplerId);
        if isempty(charMap)
            continue;
        end

        charsArray = charMap.entrySet.toArray;
        
        % Populate this KIC's characteristics struct:
        %
        for ichar = 1:length(charsArray)
            charsElement = charsArray(ichar);
            charLookupIndex = charsElement.getKey();
            key = charLookup{charLookupIndex};
            value = charsElement.getValue;
            outChars(ikic).(key) = value;
        end
    end

end

dbService.clear();
SandboxTools.close;
return
