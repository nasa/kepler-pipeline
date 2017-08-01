function targets = retrieve_target_data(keplerIds, startCadence, endCadence, cadenceType, baseDescription, includeList, excludeList, debugLevel)
%function targets = retrieve_target_data(keplerIds, startCadence, endCadence, cadenceType, baseDescription, includeList, excludeList, debugLevel)
%
% Retrieve raw pixels and pipeline products for the specified keplerIds and
% cadence range.  cadenceType is 'LONG' or 'SHORT'
%
% If the base_description argument is 'zero-based', pixel coordinates
% (including centroids) originate at (0.0, 0.0)
%
% If the base_description argument is 'one-based', pixel coordinates
% (including centroids) originate at (1.0, 1.0)
%
% There are two optional arguments, an include list and an exclude list. 
% If the include list is non-empty, you only get the products listed in 
% that list. If the include list is empty and the exclude list is non-empty, 
% you get everything except for the products listed in the exclude list.
%
% Valid product types are as follows:
%
%    DR
%    CAL
%    PA
%    PDC
%    TPS
%    DV
%    PPA
%    BACKGROUND_BLOBS
%    UNCERTAINTIES_BLOBS
%    MOTION_BLOBS 
%
% DR products consist of raw (uncalibrated) pixels
%
% By default, the include list is empty and the exclude list contains:
%  {'BACKGROUND_BLOBS','MOTION_BLOBS','ANCILLARY'}
%
% EXAMPLE:
%
%  t = retrieve_target_data(10666592,565,7318,'LONG','one-based');
%  plot(find(~t.targets.fluxGroups(1).rawFluxTimeSeries.gapIndicators),t.targets.fluxGroups(1).rawFluxTimeSeries.values(~t.targets.fluxGroups(1).rawFluxTimeSeries.gapIndicators), '.-b');
%  hold
%  plot(find(~t.targets.fluxGroups(1).correctedFluxTimeSeries.gapIndicators),t.targets.fluxGroups(1).correctedFluxTimeSeries.values(~t.targets.fluxGroups(1).correctedFluxTimeSeries.gapIndicators),'.-r');
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

if(nargin < 5)
    error('incorrect number of arguments. See helptext.');
end

DEFAULT_INCLUDE_LIST = {};
DEFAULT_EXCLUDE_LIST = {'BACKGROUND_BLOBS','MOTION_BLOBS','ANCILLARY'};
DEFAULT_DEBUG_LEVEL = 0;

if(nargin == 5)
    includeListArg = DEFAULT_INCLUDE_LIST;
    excludeListArg = DEFAULT_EXCLUDE_LIST;
elseif(nargin == 6)
    includeListArg = includeList;
    excludeListArg = DEFAULT_EXCLUDE_LIST;
elseif(nargin >= 7)
    includeListArg = includeList;
    excludeListArg = excludeList;
end
    
if(nargin == 8)
    debugLevelArg = debugLevel;
else
    debugLevelArg = DEFAULT_DEBUG_LEVEL;
end

numTargets = length(keplerIds);

if(numTargets > 20)
    error('retrieve_target_data: Number of keplerIds must be <= 20 to limit performance impact on the cluster.  Thank you for your cooperation.');
end

import gov.nasa.kepler.systest.sbt.SbtRetrieveTargetData;

pathJava = SbtRetrieveTargetData.retrieveTargetData(keplerIds, startCadence,...
    endCadence, cadenceType, baseDescription, includeListArg, excludeListArg,...
    debugLevelArg);

path = pathJava.toCharArray()';

import gov.nasa.kepler.common.TicToc;
targets = sbt_sdf_to_struct(path);

SandboxTools.close;
