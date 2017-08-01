function motionPolys = retrieve_motion_polys(startMjd, endMjd, varargin)
%
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% motion_poly_struct = retrieve_motion_polys(startMjd, endMjd)
%  or
% motion_poly_struct = retrieve_motion_polys(startMjd, endMjd, isLongCadence)
%  or
% motion_poly_struct = retrieve_motion_polys(startMjd, endMjd, ccdModules, ccdOutputs)
%  or
% motion_poly_struct = retrieve_motion_polys(startMjd, endMjd, ccdModules, ccdOutputs, isLongCadence)
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
% This script retrieves the motion polynomial data for an input range of MJDs,
% and an optional list of module/outputs.  If only MJDs are given as arguments,
% data for all 84 module/outputs will be returned.
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

    import gov.nasa.kepler.systest.sbt.SbtRetrieveMotionPolynomials;
    sbt = SbtRetrieveMotionPolynomials();

    [ccdModules ccdOutputs] = convert_to_module_output(1:84);
    isLongCadence = 1;
    
    if nargin == 4 || nargin == 5
        ccdModules = varargin{1};
        ccdOutputs = varargin{2};
    end
    
    if nargin == 3 || nargin == 5
        isLongCadence = varargin{end};
    end
    
    
    allMjds = get_cadence_mjds(startMjd, endMjd, isLongCadence);
    startCadence = allMjds(1).cadenceNumber;
    endCadence = allMjds(end).cadenceNumber;
    
    pathJava = sbt.retrieveMotionPolynomials(startCadence, endCadence, ccdModules, ccdOutputs, isLongCadence);
    path = pathJava.toCharArray()';
    motionPolyDataStruct = sbt_sdf_to_struct(path);

    for ichannel = 1:length(motionPolyDataStruct.motionPolys)

        polyStruct = poly_blob_series_to_struct(motionPolyDataStruct.motionPolys(ichannel).array(1).polyBlobSeries);

        if isempty(polyStruct)
            continue;
        end
        
        for icadence = 1:length(motionPolyDataStruct.motionPolys(ichannel).array)
            motionPolys(ichannel, icadence).cadence       = polyStruct(icadence).cadence;
            motionPolys(ichannel, icadence).mjdStartTime  = polyStruct(icadence).mjdStartTime;
            motionPolys(ichannel, icadence).mjdMidTime    = polyStruct(icadence).mjdMidTime;
            motionPolys(ichannel, icadence).mjdEndTime    = polyStruct(icadence).mjdEndTime;
            
            motionPolys(ichannel, icadence).ccdModule     = polyStruct(icadence).module;
            motionPolys(ichannel, icadence).ccdOutput     = polyStruct(icadence).output;
            
            motionPolys(ichannel, icadence).rowPoly       = polyStruct(icadence).rowPoly;
            motionPolys(ichannel, icadence).rowPolyStatus = polyStruct(icadence).rowPolyStatus;
            motionPolys(ichannel, icadence).colPoly       = polyStruct(icadence).colPoly;
            motionPolys(ichannel, icadence).colPolyStatus = polyStruct(icadence).colPolyStatus;
        end
    end


    import gov.nasa.kepler.hibernate.dbservice.DatabaseServiceFactory;
    dbInstance = DatabaseServiceFactory.getInstance();
    dbInstance.clear();
    SandboxTools.close;
return
