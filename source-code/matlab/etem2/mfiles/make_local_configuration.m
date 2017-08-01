function localConfigurationStruct = make_local_configuration()
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

localConfigurationStruct.numberOfTargetsRequested = 2000; % Number of target stars before downselect

localConfigurationStruct.runStartDate = '24-June-2010 17:29:36.8448'; % start date of current run
localConfigurationStruct.runDuration = 2; % length of run in the units defined in the next field
localConfigurationStruct.runDurationUnits = 'days'; % units of run length paramter: 'days' or 'cadences'

localConfigurationStruct.moduleNumber = 22; % which CCD module, ouput and season, legal values: 2-4, 6-20, 22-24
localConfigurationStruct.outputNumber = 2; % legal values: 1-4
localConfigurationStruct.observingSeason = 1; % 0-3 0-summer,1-fall,2-winter,3-spring

localConfigurationStruct.cadenceType = 'long'; % cadence types, <long> or <short>

% defaults for GSIT-3 30-day run
% localConfigurationStruct.numberOfTargetsRequested = 2000; % Number of target stars before downselect
% 
% localConfigurationStruct.runStartDate = '24-June-2010 17:29:36.8448'; % start date of current run
% localConfigurationStruct.runDuration = 1392; % length of run in the units defined in the next field
% localConfigurationStruct.runDurationUnits = 'cadences'; % units of run length paramter: 'days' or 'cadences'
% 
% localConfigurationStruct.moduleNumber = 4; % which CCD module, ouput and season, legal values: 2-4, 6-20, 22-24
% localConfigurationStruct.outputNumber = 2; % legal values: 1-4
% localConfigurationStruct.observingSeason = 1; % 0-3 0-summer,1-fall,2-winter,3-spring
% 
% localConfigurationStruct.cadenceType = 'long'; % cadence types, <long> or <short>
