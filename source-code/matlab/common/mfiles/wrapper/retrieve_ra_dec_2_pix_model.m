function raDec2PixData = retrieve_ra_dec_2_pix_model(mjdStart, mjdEnd)
% function raDec2PixData = retrieve_ra_dec_2_pix_model()
% or
% function raDec2PixData = retrieve_ra_dec_2_pix_model([mjdStart, mjdEnd])
% 
% Returns a matlab struct that contains data from the various models necessary
% to run ra_dec_2_pix for any of the times between mjdStart and mjdEnd.  If run
% without arguments, all ra_dec_2_pix data available to FC is retrieved.
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

    import gov.nasa.kepler.mc.fc.RaDec2PixOperations;
    import gov.nasa.kepler.fc.rolltime.RollTimeOperations;
    import gov.nasa.kepler.fc.pointing.PointingOperations;
    import gov.nasa.kepler.fc.geometry.GeometryOperations;
    import gov.nasa.kepler.fc.RaDec2PixModel;

    ops = RaDec2PixOperations();

    if 2 == nargin
        raDec2PixModel = ops.retrieveRaDec2PixModel(mjdStart, mjdEnd);
        pointingModel = retrieve_pointing_model(mjdStart, mjdEnd);
        geometryModel = retrieve_geometry_model(mjdStart, mjdEnd);
        rollTimeModel = retrieve_roll_time_model();
    elseif 0 == nargin
        raDec2PixModel = ops.retrieveRaDec2PixModel();
        pointingModel = retrieve_pointing_model();
        geometryModel = retrieve_geometry_model();
        rollTimeModel = retrieve_roll_time_model();
    else
        error('bad argument list length in retrieve_ra_dec_2_pix_model');
    end
    
    raDec2PixData = struct(...
        'pointingModel', pointingModel, ...
        'geometryModel', geometryModel, ...
        'rollTimeModel', rollTimeModel, ...
        'spiceFileDir',                     char(raDec2PixModel.getSpiceFileDir()), ...
        'spiceSpacecraftEphemerisFilename', char(raDec2PixModel.getSpacecraftEphemerisFilename()), ...
        'planetaryEphemerisFilename',       char(raDec2PixModel.getPlanetaryEphemerisFilename()), ...
        'leapSecondFilename',               char(raDec2PixModel.getLeapsecondFilename()), ...
        'mjdStart',                         raDec2PixModel.getMjdStart(), ...
        'mjdEnd',                           raDec2PixModel.getMjdEnd(), ...
        'HALF_OFFSET_MODULE_ANGLE_DEGREES', raDec2PixModel.getHALF_OFFSET_MODULE_ANGLE_DEGREES(), ...
        'OUTPUTS_PER_ROW',                  raDec2PixModel.getOUTPUTS_PER_ROW(), ...
        'OUTPUTS_PER_COLUMN',               raDec2PixModel.getOUTPUTS_PER_COLUMN(), ...
        'nRowsImaging',                     raDec2PixModel.getNRowsImaging(), ...
        'nColsImaging',                     raDec2PixModel.getNColsImaging(), ...
        'nMaskedSmear',                     raDec2PixModel.getNMaskedSmear(), ...
        'nLeadingBlack',                    raDec2PixModel.getNLeadingBlack(), ...
        'NOMINAL_CLOCKING_ANGLE',           raDec2PixModel.getNOMINAL_CLOCKING_ANGLE(), ...
        'nModules',                         raDec2PixModel.getNModules(), ...
        'mjdOffset',                        raDec2PixModel.getMjdOffset());

    import gov.nasa.kepler.hibernate.dbservice.DatabaseServiceFactory;
    dbInstance = DatabaseServiceFactory.getInstance();
    dbInstance.clear();
SandboxTools.close;
return
