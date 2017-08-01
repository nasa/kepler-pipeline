function result = isvalid_transit_injection_parameters_file( tipOutputFile )
% function result = isvalid_transit_injection_parameters_file( tipOutputFile )
%
% This TIP function verifies the tipOutputFile contains the proper data needed to build a simulated transits struct using the function
% build_simulated_transits_struct_from_tip_text_file.m. It verifies that a column heading exists for each of the needed parameters but does
% not check for valid values (other than not allowing NaNs or Inf) or self consistancy of these parameters. If the file is found to be 
% valid result = true. Otherwise result = false.
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

% column headings required by build_simulated_transits_struct_from_tip_text_file.m
headings = {'keplerId',...
    'transitOffsetEnabled',...
    'transitOffsetArcsec',...
    'transitOffsetPhase',...
    'transitSeparationDays',...
    'transitOffsetDepthPpm',...
    'transitDepthPpm',...
    'transitDurationHours',...
    'epochBjd',...
    'eccentricity',...
    'longitudeOfPeriDegrees',...
    'impactParameter',...
    'orbitalPeriodDays',...
    'stellarRadiusRsun',...
    'RplanetOverRstar',...
    'semiMajorAxisOverRstar',...
    'stellarLog10Gravity',...
    'stellarEffectiveTempKelvin',...
    'stellarLog10Metalicity',...
    'stellarRadiusRsun',...
    'transitBufferCadences'};
    
% assume file is good
result = true;

% read the file        
os = read_simulated_transit_parameters( tipOutputFile );

% check fields against required list
tf = ismember(headings, fieldnames(os));

if ~all(tf)
    result = false;
    return;
end

% check for NaNs and Inf in field values
f = fieldnames(os);
for i = 1:length(f)
    if any(isnan(os.(f{i}))) || any(isinf(os.(f{i})))
        result = false;
        return;
    end
end