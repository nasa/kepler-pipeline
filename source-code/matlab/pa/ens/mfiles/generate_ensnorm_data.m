function [targetInputStruct20400] = generate_ensnorm_data
%generate_ensnorm_data.m
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

% This function generates data needed for running ensemble normalization
% prototype
% H.Chandrasekaran 3/15/2007

clear ;
close all;
clc;
fclose all;
nrun = '20400';

% this run is available in \path\to\etem\quarter\1\run20400
% copy that run20400 to pwd, locationstr = pwd
locationstr = [ pwd  ]; 
runstr = ['run' num2str(nrun)];
%runstr = '';


%--------------------------------------------------------------------------

%-do not change the names of  the following as other functions depend
%-----on them
runparams_loadstr = ['load ' locationstr  '/run_params_' runstr ];
optaps_loadstr = ['load ' locationstr  '/optaps_' runstr ];
inject_science_loadstr = ['load ' locationstr  '/inject_science_' runstr ];
ktargets_loadstr = ['load ' locationstr  '/ktargets_' runstr ];
bad_pixel_filename = [locationstr   '/bad_pixel_' runstr ];
% specify input pixel time series file name for
% compute_flux_from_photometric_aperture to read pixel flux from
long_cadence_filename = [locationstr  '/long_cadence_q_black_smear_back_gcr_' runstr '.dat'];

run_parameters.run_number = nrun;
run_parameters.runparams_loadstr = runparams_loadstr;
run_parameters.ktargets_loadstr = ktargets_loadstr;
run_parameters.optaps_loadstr = optaps_loadstr;
run_parameters.inject_science_loadstr = inject_science_loadstr;
run_parameters.long_cadence_filename = long_cadence_filename;
run_parameters.bad_pixel_filename = bad_pixel_filename;
%--------------------------------------------------------------------------


% load aperture information
eval(run_parameters.optaps_loadstr);

% specify output flux file name for compute_flux_from_photometric_aperture to write flux 
raw_flux_filename = 'raw_flux.dat'; 


% invoke 'compute_flux_from_photometric_aperture' which computes flux using
% simple aperture photometry and calculates center of mass centroids
% long cadence data is corrected for black level, smear and background.
[flux_time_series, x_centroid_time_series, y_centroid_time_series] = ...
    compute_flux_from_photometric_aperture(long_cadence_filename, aps, wts,  run_params, raw_flux_filename);

% call Doug's guess uncertainties
[flux_uncertainty] = guesstimateFluxUncertainty(flux_time_series, run_parameters);


% add exaggerated qe variations to flux time series so ensemle
% normalization algorithm can be evaluated
load QEvTtimeseries.mat % obtained from Ball Aerospace, located in svn under so\Released\ETEM\Input
qe_long_cadence = resample(qe,1,2); %resample for cadence interval of 30 minutes, originally samples at 15 min cadences

[ncadences ntargets ] = size(flux_time_series);

qe_long_cadence = qe_long_cadence(1:ncadences);
flux_time_series_qe = zeros(size(flux_time_series));


minQE = min(qe_long_cadence);
maxQE = max(qe_long_cadence);
stdRV = 0.05*(maxQE-minQE);

for j = 1:ncadences
    flux_time_series_qe(j,:) = flux_time_series(j,:) .*(repmat((1 +qe_long_cadence(j)),1,ntargets) + stdRV*randn(1,ntargets)); % randn with std = .05
end;

% create structure
targetInputStruct20400 = repmat(struct('flux', zeros(ncadences,1),'fluxOriginal', zeros(ncadences,1), 'uncertainties', zeros(ncadences,1), 'dataGaps', [],'xcentroid',zeros(ncadences,1), 'ycentroid',zeros(ncadences,1)),ntargets,1);


nSelectTargets = unidrnd(ntargets,fix(ntargets/2),1);
nSelectTargets = unique(nSelectTargets);


%for k = 1:ntargets
for k = 1:length(nSelectTargets)
    j = nSelectTargets(k);
    targetInputStruct20400(k).flux = flux_time_series_qe(:,j);
    targetInputStruct20400(k).fluxOriginal = flux_time_series(:,j);
    targetInputStruct20400(k).uncertainties = flux_uncertainty(:,j);
    targetInputStruct20400(k).xcentroid = x_centroid_time_series(:,j);
    targetInputStruct20400(k).ycentroid = y_centroid_time_series(:,j);
    targetInputStruct20400(k).starNumber = j;

end;

fprintf('');