function [flux_uncertainty] = guesstimateFluxUncertainty(flux_optimal, input_run_parameters);
% function [flux_uncertainty] = guesstimateFluxUncertainty(flux_optimal, input_run_parameters);
%
% cheezy estimate of expected uncertainty in a flux measurement, should be
% replaced by error propagation asap  -DAC 16 Dec 2005
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

[ncad,ntarg] = size(flux_optimal);

% parameters from ETEM run
eval(input_run_parameters.runparams_loadstr);
gain = run_params.electrons_per_ADU;

% load targetflux
eval(input_run_parameters.ktargets_loadstr);

% load aperture information
eval(input_run_parameters.optaps_loadstr);

% number of electrons from star in long cadence (note: make row vector)
target_electrons = targetflux' * run_params.int_time * run_params.exp_per_long_cadence;

dark_electrons = repmat(run_params.dark * run_params.int_time * run_params.exp_per_long_cadence, size(target_electrons));

sky_electrons = repmat(run_params.background_star_signal * run_params.int_time * run_params.exp_per_long_cadence, size(target_electrons));

% note: zodi won't add anything, since this routine doesn't access zodi
% model, and zodi_signal is usually=0
zodi_electrons = repmat(run_params.zodi_signal * run_params.int_time * run_params.exp_per_long_cadence, size(target_electrons));

%read_electron_noise = repmat(run_params.read_noise * run_params.exp_per_long_cadence, size(target_electrons));
read_electron_noise = repmat(run_params.read_noise / sqrt(run_params.exp_per_long_cadence), size(target_electrons));

n_pix = sum(wts.*aps); % estimate of the number of pixels used in each star flux estimate

% determine flux uncertainty, replicate number of cadences
flux_uncertainty = repmat(sqrt(target_electrons + n_pix.*(sky_electrons + zodi_electrons + read_electron_noise.^2)),ncad,1);




return

