function skyGroupStruct = retrieve_sky_group(varargin)
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

    % skyGroupStruct = retrieve_sky_group(keplerId, mjd)
    % or
    % skyGroupStruct = retrieve_sky_group(ccdModule, ccdOutput, mjd)
    % 
    % Returns a sky group object that corresponds to the given Kepler ID and 
    % MJD.
    %
    % INPUTS:
    %   keplerId            the Kepler ID
    %   mjd                 the MJD
    % or
    %   ccdModule           the CCD module
    %   ccdOutput           the CCD output
    %   mjd                 the MJD
    %
    % OUTPUTS:
    %   skyGroupStruct
    %       keplerId        the original Kepler ID (not present if the three-argument call is used)
    %       mjd             the original MJD
    %       skyGroupId      the sky group ID
    %       ccdModule       the CCD module
    %       ccdOutput       the CCD output
    %       observingSeason the observing season
    
    import gov.nasa.kepler.systest.sbt.SandboxTools;
    SandboxTools.displayDatabaseConfig;
    
    import gov.nasa.kepler.hibernate.cm.KicCrud;
    kicCrud = KicCrud();

    % Unpack arguments based on argument count:
    switch nargin
        case 2
            keplerId = varargin{1};
            mjd = varargin{2};
            
            if numel(keplerId) > 1
                error('retrieve_sky_group: Only one keplerId can be given at a time.  %d keplerIds were given.', numel(keplerId));
            end
            keplerId = int32(keplerId);
            
            import gov.nasa.kepler.hibernate.pi.ModelMetadataRetrieverLatest;
            import gov.nasa.kepler.mc.cm.CelestialObjectOperations;
            import java.util.Arrays;
            import gov.nasa.kepler.fc.rolltime.RollTimeOperations;

            mmrl = ModelMetadataRetrieverLatest();
            coOps = CelestialObjectOperations(mmrl, false);
            rtOps = RollTimeOperations();
            skyGroupId = coOps.retrieveSkyGroupIdsForKeplerIds(Arrays.asList(keplerId)).get(keplerId);
            observingSeason = rtOps.mjdToSeason(mjd);
            skyGroup = kicCrud.retrieveSkyGroup(int32(skyGroupId), int32(observingSeason));

%             % Retrieve sky group.
%             skyGroup = kicCrud.retrieveSkyGroup(keplerId, mjd);

            if (isempty(skyGroup))
                error('retrieve_sky_group: No sky group found for keplerId=%d, mjd=%d', ...
                    keplerId, mjd);
            end
%             skyGroupId = skyGroup.getSkyGroupId();
            ccdModule = skyGroup.getCcdModule();
            ccdOutput = skyGroup.getCcdOutput();
            observingSeason = skyGroup.getObservingSeason();
            
            skyGroupStruct.keplerId = keplerId;
        case 3
            ccdModule = varargin{1};
            ccdOutput = varargin{2};
            mjd = varargin{3};
            
            if numel(ccdModule) > 1 || numel(ccdOutput) > 1 || length(ccdModule) ~= length(ccdOutput)
                error('retrieve_sky_group: A single CCD module/output pair must be used. %d modules and %d outputs were given.', numel(ccdModule), numel(ccdOutput));
            end
            
            rm = retrieve_roll_time_model();
            observingSeason = rm.seasons(find(rm.mjds <= mjd, 1, 'last' ));

            skyGroupId = kicCrud.retrieveSkyGroupId(ccdModule, ccdOutput, observingSeason);
        otherwise
            error('retrieve_sky_group: incorrect number of arguments. See helptext.');
    end


    % Populate the output struct with the common results.
    skyGroupStruct.mjd = mjd;
    skyGroupStruct.skyGroupId = skyGroupId;
    skyGroupStruct.ccdModule  = ccdModule;
    skyGroupStruct.ccdOutput  = ccdOutput;
    skyGroupStruct.observingSeason = observingSeason;

    % Clear Hibernate cache
    import gov.nasa.kepler.hibernate.dbservice.DatabaseServiceFactory;
    dbInstance = DatabaseServiceFactory.getInstance();
    dbInstance.clear();
SandboxTools.close;
return
