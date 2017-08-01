% script to test temperatureFunctionClass
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

% Optional arguments include:
% 'Detector' ('PEDACQ3T') -- Detector ID of the form PEDACQxT or PEDDRVxT
% 'TThermal' (1/0.02981) -- Thermal time constant in hours
% 'Temp_equilibrium' (39.7) -- Equilibrium temperature
% 'DeltaT_initial' (2.426) -- Initial temperature - Temp_equilibrium
% 'Temp_initial' (NaN) -- Initial temperature (if specified, this 
%    overides the value of DeltaT_initial)
% 'DTdt_initial' (NaN)-- Initial dT/dt (should be <0, and if specified, 
%    this overides the value of Temp_initial and DeltaT_initial)
% 'Linear_rate' (0.0) -- Small linear variation in Temp_equilibrium
% 'Verbose' (FALSE) -- Verbose diagnostic mode

% as-delivered defaults
% temperatureFunctionData.detector = 'PEDACQ3T';
% temperatureFunctionData.tThermal_in = 1/0.02981;
% temperatureFunctionData.temp_equilibrium_in = 39.7;
% temperatureFunctionData.deltaT_initial_in = 2.426;
% temperatureFunctionData.temp_initial = NaN;
% temperatureFunctionData.dTdt_initial = NaN;
% temperatureFunctionData.linear_rate = 0.0;
% temperatureFunctionData.verbose = false;

% slow T change
% temperatureFunctionData.detector = 'PEDACQ3T';
% temperatureFunctionData.tThermal_in = 1/0.0002;
% temperatureFunctionData.temp_equilibrium_in = 17;
% temperatureFunctionData.deltaT_initial_in = NaN;
% temperatureFunctionData.temp_initial = 20.3;
% temperatureFunctionData.dTdt_initial = NaN;
% temperatureFunctionData.linear_rate = 0.0;
% temperatureFunctionData.verbose = false;

% fast T change: from 20 to 22 in 72 hours
temperatureFunctionData.detector = 'PEDACQ3T';
temperatureFunctionData.tThermal_in = -1/0.008;
temperatureFunctionData.temp_equilibrium_in = 17;
temperatureFunctionData.deltaT_initial_in = NaN;
temperatureFunctionData.temp_initial = 20;
temperatureFunctionData.dTdt_initial = NaN;
temperatureFunctionData.linear_rate = 0.0;
temperatureFunctionData.verbose = false;

temperatureFunctionObject = temperatureFunctionClass(temperatureFunctionData);

t = 0:60.5;
temps = get_temperature(temperatureFunctionObject, t);
figure;
plot(t, temps);
