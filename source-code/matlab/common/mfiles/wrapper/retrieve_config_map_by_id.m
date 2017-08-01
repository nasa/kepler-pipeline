function configMap = retrieve_config_map_by_id(scConfigId)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function configMap = retrieve_config_map_by_id(scConfigId)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
% Retrieve a structures describing the Spacecraft Configuration ID Map. 
% The Spacecraft Configuration ID Map defines the spacecraft and photometer configurations
% for each Spacecraft Configuration ID commanded from the ground. The entries of the 
% Spacecraft Configuration ID Map are defined in SOC-MOC ICD.
%
% Input:
%   scConfigId              Spacecraft Configuration ID
%
% Output:
%   configMap               A structure describing the Spacecraft Configuration ID Map.
%                           It contains the following fields: 
%       .id                 Commanded Spacecraft Configuration ID
%       .time               Time in MJD when Spacecraft Configuration ID is commanded
%       .entries            1 x nEntries array of structures describing the entries of the Spacecraft Configuration
%                           ID Map. nEntries is the number of entries in the Spacecraft Configuration ID Map.
%                           The structure contains the following fields:
%           .mnemonic       A string describing the mnemonic of the entry.
%           .value          A string describing the value of the entry.
%
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

import gov.nasa.kepler.systest.sbt.SandboxTools;
SandboxTools.displayDatabaseConfig;

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Validity check on input
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

if nargin~=1
    error('MATLAB:SBT:wrapper:retrieve_config_map_by_id:wrongNumberOfInputs', 'MATLAB:SBT:wrapper:retrieve_config_map_by_id: must be called with 1 input argument.');
end

if ( isempty(scConfigId) )
    error('MATLAB:SBT:wrapper:retrieve_config_map_by_id:invalidInput', 'scConfigId cannot be empty.');
elseif ( length(scConfigId)>1 )
    error('MATLAB:SBT:wrapper:retrieve_config_map_by_id:invalidInput', 'scConfigId must be a scalar, not a vector');
else
    
end

fieldsAndBounds = {'scConfigId'; '>= 0';  '<= 1e4';  []};
validate_field(scConfigId, fieldsAndBounds, 'MATLAB:SBT:wrapper:retrieve_config_map_by_id:invalidInput');
   
% Define a output structure with empty fields
configMapEmptyFields = struct('id',              [], ...
                              'time',            [], ...
                              'entries',         repmat(struct('mnemonic',  '', ...
                                                               'value',     ''), 1, 28));
                                                 
import gov.nasa.kepler.systest.sbt.SbtConfigMapOperations;

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Retrieve the spacecraft configuration ID map
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

configMapOps = SbtConfigMapOperations();
configMapTable = [];

try
    configMapTable = configMapOps.retrieveSbtConfigMap(scConfigId);
catch
    error('MATLAB:SBT:wrapper:retrieve_config_map_by_id:dataStoreReadException', ...
          'Exception in retrieving configuration ID map from data store.');
end

% When the data retrieved is empty, output a structure with empty fields
if ( isempty(configMapTable) )
    warning('MATLAB:SBT:wrapper:retrieve_config_map_by_id:outputStructWithEmptyFields', ...
            'No configuration ID maps found in the specified time interval. A structure with empty fields is provided for output.');
    configMap = configMapEmptyFields;
    SandboxTools.close;
    return
end

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Generate the output structure
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

% Preallocate the structure
configMap = configMapEmptyFields;

% Assign data to the corresponding fields of the output structure
configMap.id   = configMapTable.getId();
configMap.time = configMapTable.getTime();

% Assign the mnemonic and value of each entry to the corresponding fields of the outpur structure
configMapEntryArray = configMapTable.getEntries();
nConfigMapEntry = length(configMapEntryArray);
for iConfigMapEntry = 1:nConfigMapEntry
    configMap.entries(iConfigMapEntry).mnemonic = char( configMapEntryArray(iConfigMapEntry).getMnemonic() );
    configMap.entries(iConfigMapEntry).value    = char( configMapEntryArray(iConfigMapEntry).getValue() );
end

% Clear Hibernate cache
import gov.nasa.kepler.hibernate.dbservice.DatabaseServiceFactory;
dbService = DatabaseServiceFactory.getInstance();
dbService.clear();

SandboxTools.close;
return
