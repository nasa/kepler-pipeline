function pdqDeltaQuaternions = retrieve_pdq_delta_quaternions()
%function pdqDeltaQuaternions = retrieve_pdq_delta_quaternions()
% 
% Returns a delta quaternion struct for all the existing PDQ attitude
% adjustments.
%
% Returns a struct similar to the following:
%
%
%  deltaQuaternions: [1xn struct]
%    mjd
%    x
%    y
%    z
%    w
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

import gov.nasa.kepler.hibernate.pdq.PdqCrud;
pdqCrud = PdqCrud();

% retrieve all attitude adjustments in time order
attitudeAdjustments = pdqCrud.retrieveLatestAttitudeAdjustments(0).toArray();

% copy from Java to MATLAB
pdqDeltaQuaternions = copyAttitudeAdjustments(attitudeAdjustments);

% Clear Hibernate cache
import gov.nasa.kepler.hibernate.dbservice.DatabaseServiceFactory;
dbService = DatabaseServiceFactory.getInstance();
dbService.clear();

SandboxTools.close;
return;

% copy the relevant fields from the Java List<AttitudeAdjustment> to the
% MATLAB struct array
function deltaQuaternions = copyAttitudeAdjustments(attitudeAdjustments)

deltaQuaternions = repmat(struct('mjd', [], 'x', [], 'y', [], 'z', [], ...
    'w', []), 1, length(attitudeAdjustments));

for i = 1:length(attitudeAdjustments)
    deltaQuaternions(i).mjd = attitudeAdjustments(i).getRefPixelLog().getMjd();
    deltaQuaternions(i).x = attitudeAdjustments(i).getX();
    deltaQuaternions(i).y = attitudeAdjustments(i).getY();
    deltaQuaternions(i).z = attitudeAdjustments(i).getZ();
    deltaQuaternions(i).w = attitudeAdjustments(i).getW();
end;

return

