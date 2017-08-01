function limbDarkeningCoefficients = ...
    get_coeffts_from_kepler_tables(effectiveTemp, log10SurfaceGravity, log10Metallicity)
% function limbDarkeningCoefficients = ...
%   get_coeffts_from_kepler_tables(effectiveTemp, log10SurfaceGravity, log10Metallicity)
%
% function to retrieve nonlinear limb darkening coefficients from
% pre-defined Kepler-band tabular data
%
%
% INPUTS:
%
%   effectiveTemp       [scalar] stellar effective temperature (Kelvin)
%   log10SurfaceGravity [scalar] log of stellar surface gravity (cm/sec^2)
%   log10Metallicity    [struct] log Fe/H metallicity, solar (FEH)
%
%
% OUTPUTS:
%
%    limbDarkeningCoefficients [array] limb darkening coefficients
%
%--------------------------------------------------------------------------
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

% Modification history:
%
%    2011-Jan-3, EQ:
%        initial release to support new Kepler limb darkening model
%        Note the interpolation method will soon change to include
%        the metallicity, and also because griddata will no longer be
%        supported in future Matlab releases.
%
%    2011-Feb-28, EQ:
%       implemented griddatan


% extract the (Teff, logg, Z) arrays from the Kepler band-pass index table
[effectiveTempVector, log10SurfaceGravityVector, metallicityVector] = ...
    get_stellar_parameters_for_kepler_bandpass;


% extract the nonlinear coefficients
[c1Vector, c2Vector, c3Vector, c4Vector] = get_nonlinear_limb_darkening_kepler_data;


% ensure that the logg, effective temperature, and metallicity are within
% the valid ranges set by the tables
minTeff = min(effectiveTempVector);
maxTeff = max(effectiveTempVector);
minLogg = min(log10SurfaceGravityVector);
maxLogg = max(log10SurfaceGravityVector);
minMet  = min(metallicityVector);
maxMet  = max(metallicityVector);

effectiveTemp = max(effectiveTemp, minTeff);
effectiveTemp = min(effectiveTemp, maxTeff);

log10SurfaceGravity = max(log10SurfaceGravity, minLogg);
log10SurfaceGravity = min(log10SurfaceGravity, maxLogg);

log10Metallicity = max(log10Metallicity, minMet);
log10Metallicity = min(log10Metallicity, maxMet);


%--------------------------------------------------------------------------
% perform interpolation with griddatan; default is 'linear' interpolation
%--------------------------------------------------------------------------

x = [log10SurfaceGravityVector, effectiveTempVector, metallicityVector];

xi = [log10SurfaceGravity, effectiveTemp, log10Metallicity];

c1 = griddatan(x, c1Vector, xi);
c2 = griddatan(x, c2Vector, xi);
c3 = griddatan(x, c3Vector, xi);
c4 = griddatan(x, c4Vector, xi);

limbDarkeningCoefficients = [c1 c2 c3 c4];


% if any coeffts are NaNs, recompute with nearest-neighbor interpolation
if any(isnan(limbDarkeningCoefficients))
    
    c1 = griddatan(x, c1Vector, xi, 'nearest');
    c2 = griddatan(x, c2Vector, xi, 'nearest');
    c3 = griddatan(x, c3Vector, xi, 'nearest');
    c4 = griddatan(x, c4Vector, xi, 'nearest');
    
    limbDarkeningCoefficients = [c1 c2 c3 c4];
    
    % if any coeffts are NaNs, error out
    if any(isnan(limbDarkeningCoefficients))
        error('dv:transitGeneratorClass:ldCoefftsNan', ...
            'transitGeneratorClass:  limb darkening coefficient array includes a NaN');
    end
end

return;
