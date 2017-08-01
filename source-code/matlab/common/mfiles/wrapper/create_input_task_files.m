function create_input_task_files(triggerName, moduleName, taskFileDirName, uowArray, startCadence, endCadence)
%function create_input_task_files(triggerName, moduleName, taskFileDirName, uowArray, startCadence, endCadence)
%
% Create input task files for a unit of work and cadence range.
%
% triggerName: The name of a trigger in the database that contains the pipeline module.
% moduleName: The name of the pipeline module.
% taskFileDirName: The name of the directory in which to create input task files.
% uowArray: The array of keplerIds (tps, dv) or channels (mod/outs for cal, pa, pdc).
% startCadence: The start cadence.
% endCadence: The end cadence.
%
% EXAMPLES:
%
%  create_input_task_files('Planet Search', 'dv', '/path/to/dv_inputs', [11853905, 8191672], 29873, 30667);
%  create_input_task_files('Planet Search', 'tps', '/path/to/tps_inputs', [11853905, 8191672], 29873, 30667);
%  pa is not currently supported because it does not implement AsyncPipelineModule.
%  create_input_task_files('Quarterly LC Mega', 'pdc', '/path/to/pdc_inputs', [19, 20], 29873, 30667);
%  create_input_task_files('Quarterly LC Mega', 'cal', '/path/to/cal_inputs', [19, 20], 29873, 30667);
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

if(nargin < 6)
    error('incorrect number of arguments. See helptext.');
end

import gov.nasa.kepler.systest.sbt.SbtCreateInputTaskFiles;

SbtCreateInputTaskFiles.createInputTaskFiles(triggerName, moduleName, taskFileDirName, uowArray, startCadence, endCadence);

SandboxTools.close;
