function dvResultsStruct = ...
    add_dv_alert(dvResultsStruct, dvComponent, severity, message, ...
    targetNumber, keplerId, planetNumber, targetTableId)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function dvResultsStruct = ...
%     add_dv_alert(dvResultsStruct, dvComponent, severity, message, ...
%     targetNumber, keplerId, planetNumber, targetTableId)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Formats the alerts generated in dv and returns it to dvResultsStruct.
% Uses add_alert.m
%
%  USAGE:
%      dvResultsStruct = add_dv_alert(dvResultsStruct, dvComponent, severity, message, targetNumber, keplerId, planetNumber, targetTableId)  
%      dvResultsStruct = add_dv_alert(dvResultsStruct, dvComponent, severity, message, targetNumber, keplerId, planetNumber)  
%      dvResultsStruct = add_dv_alert(dvResultsStruct, dvComponent, severity, message, targetNumber, keplerId)
%      dvResultsStruct = add_dv_alert(dvResultsStruct, dvComponent, severity, message)
%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% INPUTS:
%
%         dvResultsStruct:      [struct]  dvResults structure
%             dvComponent:      [string]  dv component
%                severity:      [string]  warning or error
%                 message:      [string]  description of the alert
%            targetNumber:      [int]     the nth target in dvResultsStruct
%                keplerId:      [int]     kepler Id number
%            planetNumber:      [int]     planet number of the target
%           targetTableId:      [int]     target table Id number
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% OUTPUT:
%
%           dvResultsStruct.alerts will be updated with formatted alerts.
%           The message of the alerts with look like:
%
% For 8 arguments:
%         message (target=123, keplerId=123, planet=123, targetTable=123, component=bootstrap)
%
% For 7 arguments:
%         message (target=123, keplerId=123, planet=123, component=bootstrap)
%                  
% For 6 arguments:      
%         message (target=123, keplerId=123,component=bootstrap)
%       
% For 4 arguments:
%         message (component=bootstrap)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
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

alerts = dvResultsStruct.alerts;


if nargin == 8

    string = sprintf('%s (target=%d, keplerId=%d, planet=%d, targetTable=%d, component=%s)', ...
        message, targetNumber, keplerId, planetNumber, targetTableId, dvComponent);
    
elseif nargin == 7

    string = sprintf('%s (target=%d, keplerId=%d, planet=%d, component=%s)', ...
        message, targetNumber, keplerId, planetNumber, dvComponent);

elseif nargin == 6

    string = sprintf('%s (target=%d, keplerId=%d, component=%s)', ...
        message, targetNumber, keplerId, dvComponent);

elseif nargin == 4
    
    string = sprintf('%s (component=%s)', ...
        message, dvComponent);
else
    
    string = 'Can''t interpret inputs for alert';

end



alerts = add_alert(alerts, severity, string);

dvResultsStruct.alerts = alerts;

return

    