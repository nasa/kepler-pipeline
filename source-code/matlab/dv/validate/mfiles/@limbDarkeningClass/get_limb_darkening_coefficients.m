function limbDarkeningModelObject = ...
    get_limb_darkening_coefficients(limbDarkeningModelObject)
% function limbDarkeningModelObject = ...
%   get_limb_darkening_coefficients(limbDarkeningModelObject)
%
% function to retrieve limb darkening coefficients for a given limb darkening
% model and stellar parameter set.
%
%
% INPUTS:
%
% limbDarkeningModelObject with the following fields:
%
%   modelNameString           [string] name of limb darkening model
%                               ex. 'claret_nonlinear_limb_darkening_model'
%                               or  'kepler_nonlinear_limb_darkening_model'
%                               or  'claret_nonlinear_limb_darkening_model_2011'
%
%   log10SurfaceGravity       [scalar] log stellar surface gravity, cm/sec^2
%   effectiveTemp             [scalar] stellar effective temperature, Kelvin
%   log10Metallicity          [struct] log Fe/H metallicity, solar (FEH)
%
%   limbDarkeningCoefficients [array]  empty array preallocated to collect
%                                      the 4 x 1 array of coefficients
%
%
% OUTPUTS:
%
% limbDarkeningModelObject with an additional field:
%
%  limbDarkeningCoefficients  [array] limb darkening coefficients
%
%
% If the model is unknown, a warning will be thrown and the output will be
% an empty limbDarkeningCoefficients struct
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
%    2011-Nov-7, EQ:
%        updated function to include new Claret model (2011)
%    2011-Jan-3, EQ:
%        separate functions added for each valid model; metallicity
%        included as an input for Kepler nonlinear LD model



% extract input fields
modelNameString     = limbDarkeningModelObject.modelNameString;
log10SurfaceGravity = limbDarkeningModelObject.log10SurfaceGravity;
effectiveTemp       = limbDarkeningModelObject.effectiveTemp;
log10Metallicity    = limbDarkeningModelObject.log10Metallicity;

if ~isempty(modelNameString)
    
    if strcmpi(modelNameString, 'claret_nonlinear_limb_darkening_model')
        
        limbDarkeningCoefficients = ...
            get_coeffts_from_atlas_tables(effectiveTemp, log10SurfaceGravity);
        
        limbDarkeningModelObject.limbDarkeningCoefficients = limbDarkeningCoefficients;
        
        
    elseif (strcmpi(modelNameString, 'kepler_nonlinear_limb_darkening_model'))
        
        limbDarkeningCoefficients = ...
            get_coeffts_from_kepler_tables(effectiveTemp, log10SurfaceGravity, log10Metallicity);
        
        limbDarkeningModelObject.limbDarkeningCoefficients = limbDarkeningCoefficients;
        
        
    elseif (strcmpi(modelNameString, 'claret_nonlinear_limb_darkening_model_2011'))
        
        limbDarkeningCoefficients = ...
            get_coeffts_from_claret_2011_tables(effectiveTemp, log10SurfaceGravity, log10Metallicity);
        
        limbDarkeningModelObject.limbDarkeningCoefficients = limbDarkeningCoefficients;
        
        
    else
        
        warning(  'dv:get_limb_darkening_coefficients:InvalidModel', ...
            'The models that are currently supported are ''claret_nonlinear_limb_darkening_model'', ''kepler_nonlinear_limb_darkening_model'' and ''claret_nonlinear_limb_darkening_model_2011'' ');
        return;
        
    end
    
end


return;

