function [temperatures, dTdt] = get_temperature(temperatureFunctionObject, times)
% BASELINE_THERMAL_MODEL uses an exponential model of the form
% T(t) = T_eq + DeltaT * exp( -t/t_thermal) + rate*t to predict a 
% vector of temperatures for a vector of times.  Default mode uses 
% parameters for detector PEDACQ3T.
%
%    [ TEMPERATURES, DTDT] = BASELINE_THERMAL_MODEL( TIMES, VARARGIN)
%
%    TEMPERATURES -- Vector ot temperatures (C)
%    DTDT -- Cooling rate (C/hr)
%    TIMES -- Vector of times in hours
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

% Author: P. R. Gazis  03-NOV-2008
% Modified:            03-NOV-2008

% Initialize various input parameters
detector = temperatureFunctionObject.detector;
tThermal_in = temperatureFunctionObject.tThermal_in;
temp_equilibrium_in = temperatureFunctionObject.temp_equilibrium_in;
deltaT_initial_in = temperatureFunctionObject.deltaT_initial_in;
temp_initial = temperatureFunctionObject.temp_initial;
dTdt_initial = temperatureFunctionObject.dTdt_initial;
linear_rate = temperatureFunctionObject.linear_rate;
verbose = temperatureFunctionObject.verbose;


% Load the default parameters for this detector.  If detector was not 
% specified or cannot be recognized, use values for PEDACQ3T
if( strcmp( detector, 'PEDACQ1T'))
 tThermal = 1.0 / 0.02879;
 temp_equilibrium = 36.95;
 deltaT_initial = 2.488;
elseif( strcmp( detector, 'PEDACQ2T'))
 tThermal = 1.0 / 0.02904;
 temp_equilibrium = 38.46;
 deltaT_initial = 2.479;
elseif( strcmp( detector, 'PEDACQ3T'))
 tThermal = 1.0 / 0.02981;
 temp_equilibrium = 39.73;
 deltaT_initial = 2.426;
elseif( strcmp( detector, 'PEDACQ4T'))
 tThermal = 1.0 / 0.02964;
 temp_equilibrium = 38.04;
 deltaT_initial = 2.442;
elseif( strcmp( detector, 'PEDACQ5T'))
 tThermal = 1.0 / 0.02867;
 temp_equilibrium = 38.58;
 deltaT_initial = 2.488;
elseif( strcmp( detector, 'PEDDRV1T'))
 tThermal = 1.0 / 0.02842;
 temp_equilibrium = 31.80;
 deltaT_initial = 2.515;
elseif( strcmp( detector, 'PEDDRV2T'))
 tThermal = 1.0 / 0.02835;
 temp_equilibrium = 33.81;
 deltaT_initial = 2.538;
elseif( strcmp( detector, 'PEDDRV3T'))
 tThermal = 1.0 / 0.02868;
 temp_equilibrium = 34.67;
 deltaT_initial = 2.499;
elseif( strcmp( detector, 'PEDDRV4T'))
 tThermal = 1.0 / 0.02908;
 temp_equilibrium = 33.25;
 deltaT_initial = 2.484;
elseif( strcmp( detector, 'PEDDRV5T'))
 tThermal = 1.0 / 0.02874;
 temp_equilibrium = 33.55;
 deltaT_initial = 2.493;
else
 tThermal = 1.0 / 0.02981;
 temp_equilibrium = 39.73;
 deltaT_initial = 2.426;
end

% If requested, override default parameters for this detector
if( ~isnan( tThermal_in))
 tThermal = tThermal_in;
end
if( ~isnan( temp_equilibrium_in))
 temp_equilibrium = temp_equilibrium_in;
end
if( ~isnan( deltaT_initial_in))
 deltaT_initial = deltaT_initial_in;
end
if( ~isnan( temp_initial))
 deltaT_initial = temp_initial - temp_equilibrium;
end
if( ~isnan( dTdt_initial))
 deltaT_initial = -dTdt_initial * tThermal;
end

% Generate a vector temperatures for these times
temperatures = ...
 temp_equilibrium + ...
 deltaT_initial * exp( -times / tThermal) + ...
 linear_rate * times;
dTdt = -(deltaT_initial/tThermal) * exp( -times / tThermal) + ...
 linear_rate;

% Report success
if( verbose)
 fprintf( 'baseline_thermal_model: generated %i temperatures/n', ...
   length( temperatures));
end
