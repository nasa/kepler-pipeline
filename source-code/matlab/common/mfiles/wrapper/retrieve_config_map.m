function configMaps = retrieve_config_map(startMjd, endMjd)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function configMaps = retrieve_config_map()
% or
% function configMaps = retrieve_config_map(mjd)
% or
% function configMaps = retrieve_config_map(startMjd, endMjd)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
% Retrieve an array of structures describing the Spacecraft Configuration ID Maps. 
% The Spacecraft Configuration ID Map defines the spacecraft and photometer configurations
% for each Spacecraft Configuration ID commanded from the ground. The entries of the 
% Spacecraft Configuration ID Map are defined in SOC-MOC ICD.
%
% Inputs:
%   mjd                     MJD (scalar) of the specified time instant.
% or
%   startMjd                Optional. MJD of the start of the specified time interval. It is set to 54000 if not specified.
%   endMjd                  Optional. MJD of the end of the specified time interval. It is set to 64000 if not specified.
%                           
% Output:
%   configMaps              1 x nConfigMaps array of structures describing the Spacecraft Configuration ID Maps.
%                           nConfigMaps is the number of Spacecraft Configuration ID Maps in the specified time
%                           interval. The structure contains the following fields: 
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

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Validity check on inputs
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

import gov.nasa.kepler.systest.sbt.SandboxTools;
SandboxTools.displayDatabaseConfig;

if ~( nargin==0 || nargin==1 || nargin==2 )
    error('MATLAB:SBT:wrapper:retrieve_config_map:wrongNumberOfInputs', 'MATLAB:SBT:wrapper:retrieve_config_map: must be called with 0, 1 or 2 input arguments.');
end

if nargin==1
    if ( isempty(startMjd) )
        error('MATLAB:SBT:wrapper:retrieve_config_map:invalidInput', 'mjd cannot be empty.');
    elseif ( length(startMjd)>1 )
        error('MATLAB:SBT:wrapper:retrieve_config_map:invalidInput', 'mjd must be single-valued, not a vector');
    else
        fieldsAndBounds = {'mjd'; '>= 54000';  '<= 64000';  []};
        validate_field(startMjd, fieldsAndBounds, 'MATLAB:SBT:wrapper:retrieve_config_map:invalidInput');
        endMjd = startMjd;
    end
end

if ( ~exist('startMjd', 'var') || isempty(startMjd) )
    startMjd = 54000;
    disp(['startMjd is set to ' num2str(startMjd)]);
end

if ( ~exist('endMjd', 'var') || isempty(endMjd) )
    endMjd   = 64000;
    disp(['endMjd is set to ' num2str(endMjd)]);
end
   
sbt_validate_time_interval(startMjd, endMjd, 0, 'MATLAB:SBT:wrapper:retrieve_config_map:invalidInput');

% Define a output structure with empty fields
configMapEmptyFields = struct('id',              [], ...
                              'time',            [], ...
                              'entries',         repmat(struct('mnemonic',  '', ...
                                                               'value',     ''), 1, 28));
                                                 
import gov.nasa.kepler.systest.sbt.SbtConfigMapOperations;

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Retrieve an array of spacecraft configuration ID maps
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

configMapOps = SbtConfigMapOperations();
configMapArray = [];

try
    configMapArray = configMapOps.retrieveSbtConfigMaps(startMjd, endMjd);
catch
    error('MATLAB:SBT:wrapper:retrieve_config_map:dataStoreReadException', ...
          'Exception in retrieving configuration ID maps from data store.');
end

% When the data retrieved is empty, output a structure with empty fields
if ( isempty(configMapArray) )
    warning('MATLAB:SBT:wrapper:retrieve_config_map:outputStructWithEmptyFields', ...
            'No configuration ID maps found in the specified time interval. A structure with empty fields is provided for output.');
    configMaps = configMapEmptyFields;
    SandboxTools.close;
    return
end

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Generate the output array of structures
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

% Preallocate the array of structures
nConfigMaps = length(configMapArray);
configMaps = repmat(configMapEmptyFields, 1, nConfigMaps);

for iConfigMap = 1:nConfigMaps

    % Get one Spacecraft Configuration ID Map from the Array
    configMap = configMapArray(iConfigMap);        
    
    % Assign data to the corresponding fields of the array of structures for the output
    configMaps(iConfigMap).id   = configMap.getId();
    configMaps(iConfigMap).time = configMap.getTime();
    
    % Assign the mnemonic and value of each entry to the corresponding fields of the array of structures for the output
    configMapEntryArray = configMap.getEntries();
    nConfigMapEntry = length(configMapEntryArray);
    for iConfigMapEntry = 1:nConfigMapEntry
        configMaps(iConfigMap).entries(iConfigMapEntry).mnemonic = char( configMapEntryArray(iConfigMapEntry).getMnemonic() );
        configMaps(iConfigMap).entries(iConfigMapEntry).value    = char( configMapEntryArray(iConfigMapEntry).getValue() );
    end

end

% Clear Hibernate cache
import gov.nasa.kepler.hibernate.dbservice.DatabaseServiceFactory;
dbService = DatabaseServiceFactory.getInstance();
dbService.clear();

SandboxTools.close;
return
