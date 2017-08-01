% make_DR25_stellar_parameters_catalog_for_FLTI.m
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

% Create a new stellar parameters catalog for FLTI, using Chris Burke's
% completeStructArray.

% Match the format of the old stellar parameters catalog, 
% called tpsV4StellarParametersCatalog.mat
% It contains a struct called stellarParameters, with the following fields
% stellarParameters = 
%
%                     keplerId: [198709x1 double]
%                    keplerMag: [198709x1 double]
%             log10metallicity: [198709x1 double]
%          log10SurfaceGravity: [198709x1 double]
%    stellarRadiusInSolarRadii: [198709x1 double]
%                effectiveTemp: [198709x1 double]
%                      rmsCdpp: [198709x14 single]

% The new catalog file will be called tpsV4StellarParametersCatalogFinal.mat
%===========================================================================

clear

% This is where the old stellar parameters catalog, called tpsV4StellarParametersCatalog.mat
% is found
jcatDir = '/path/to/';

% Load the old stellar catalog
load(strcat(jcatDir,'tpsV4StellarParametersCatalog.mat'));
keplerIdOld = stellarParameters.keplerId;

% Directory containing Chris' completeStructArray
DR25dir = '/path/to/so-products-DR25/';

% Load the completeStructArray
load(strcat(DR25dir,'Complete_Seed_DR25_04-05-2016.mat'));
nStars = length(completeStructArray);
nPulses = 14;

% Create the new struct
stellarParametersNew = struct('keplerId',zeros(nStars,1),'keplerMag',zeros(nStars,1), ...
    'log10metallicity',zeros(nStars,1),'log10SurfaceGravity',zeros(nStars,1), ...
    'stellarRadiusInSolarRadii',zeros(nStars,1),'effectiveTemp',zeros(nStars,1), ...
    'rmsCdpp',single(zeros(nStars,nPulses)) );

% Get data from the completeStructArray
keplerId = double([completeStructArray.keplerId]');
keplerMag = [completeStructArray.kpmag]';
log10SurfaceGravity = [completeStructArray.new3logg]';
stellarRadiusInSolarRadii = [completeStructArray.new3rstar]';
effectiveTemp = [completeStructArray.new3teff]';

% CompleteStructArray contains no entries for metallicity, so populate that
% field with values from the old catalog, which was obtained from the
% database
% New catalog has 198702 entries, old catalog has 198709 entries
[TF,locOld] = ismember(keplerId,keplerIdOld);
log10metallicity = stellarParameters.log10metallicity(locOld);
% If metallicity has NaN, replace it with the solar value
% there were 2855 NaNs
log10metallicity(isnan(log10metallicity)) = 0;

% Get rms cdpp
rmsCdpp1 = zeros(nStars,nPulses);
rmsCdpp2 = zeros(nStars,nPulses);
for iStar = 1:nStars
    rmsCdpp1(iStar,:) = [completeStructArray(iStar).rmsCdpps1];
    rmsCdpp2(iStar,:) = [completeStructArray(iStar).rmsCdpps2];
end

% Logic:
% If any rmsCdpp2 in range of pulseIndexRange have values of -1,
%   then
%       if any of rmsCdpp1 have values of -1, return parameters = NaN
%       else use rmsCdpp1 instead of rmsCdpp2
%   else use rmsCdpp2
rmsCdpp = rmsCdpp2;
for iPulse = 1:nPulses
    idx2 = rmsCdpp2(:,iPulse) == -1;
    idx1 = rmsCdpp1(:,iPulse) == -1;
    rmsCdpp(idx2,iPulse) = rmsCdpp1(idx2,iPulse);
    rmsCdpp(idx1&idx2) = NaN;
end

% Make rmsCdpp single-precision
rmsCdpp = single(rmsCdpp);


% Populate the new struct
stellarParametersNew.keplerId = keplerId;
stellarParametersNew.keplerMag = keplerMag;
stellarParametersNew.log10metallicity = log10metallicity;
stellarParametersNew.log10SurfaceGravity = log10SurfaceGravity;
stellarParametersNew.stellarRadiusInSolarRadii = stellarRadiusInSolarRadii;
stellarParametersNew.effectiveTemp = effectiveTemp;
stellarParametersNew.rmsCdpp = rmsCdpp;

% Clear the old struct and replace it with the new
stellarParametersOld = stellarParameters(locOld);
clear stellarParameters;
stellarParameters = stellarParametersNew;

% Save the new stellar parameters catalog
% save(strcat(DR25dir,'tpsV4StellarParametersCatalogFinal.mat'),'stellarParameters')





