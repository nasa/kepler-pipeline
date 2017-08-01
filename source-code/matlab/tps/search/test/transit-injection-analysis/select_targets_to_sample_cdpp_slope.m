% select_targets_sampling_cdpp_slope.m
% ====================================
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

% Initialize
clear
close all

% 1. Load stellar parameters catalog
% contains struct stellarParameters
disp('Loading stellar parameters catalog ...')
catalogDir = '/codesaver/work/transit_injection/catalogs/';
if( exist( strcat(catalogDir,'tpsV4AugmentedStellarParametersCatalog.mat'),'file' ) == 2 )
    load(strcat(catalogDir,'tpsV4AugmentedStellarParametersCatalog.mat'))
else
    load(strcat(catalogDir,'tpsV4StellarParametersCatalog'));
    disp('Augmenting stellar parameters with dutyCycle, dataSpanInCadences,isPlanetACandidate, and cdppSlope ...')
end

% 2. Load composite injection target list. We will check that selected
% targets are not among the targets on this list
disp('Loading composite injection targets list ...')
compositeInjectionTargetList = load(strcat(catalogDir,'compositeInjectionTargetList'));

% 3. Load tps_tce_struct for 9.3 V4
disp('Loading TPS 9.3 V4 tceStruct ...')
topDir = '/path/to/mq-q1-q17/pipeline_results/tps-v4/';
load(strcat(topDir,'tps-tce-struct.mat'))

%   A. Check that keplerIds and kepler mags match
keplerId1 = tpsTceStruct.keplerId;
keplerId2 = stellarParameters.keplerId;
% sum(keplerId1~=keplerId2)
keplerMag1 = tpsTceStruct.keplerMag;
keplerMag2 = stellarParameters.keplerMag;
% sum(keplerMag1~=keplerMag2)
%       There are 41 stars for which keplerMags are not equal!
%       35 are NaNs and the other 6 are equal to 2 parts in 10 million, so this is OK

%   B. Add dataSpanInCadences to stellar parameters catalog
if(~(isfield(stellarParameters','dataSpanInCadences')))
    stellarParameters.dataSpanInCadences = tpsTceStruct.dataSpanInCadences;
end

%   C. Add dutyCycle = numValidCadences./dataSpanInCadences to stellar parameters catalog
if(~(isfield(stellarParameters','dutyCycle')))
    stellarParameters.dutyCycle = tpsTceStruct.numValidCadences./tpsTceStruct.dataSpanInCadences;
end

%   D. Add isPlanetACandidate to stellar parameters catalog
if(~(isfield(stellarParameters','isPlanetACandidate')))
    stellarParameters.isPlanetACandidate = tpsTceStruct.isPlanetACandidate;
end

%   E. Add cdppSlope to stellar parameters catalog if it does not already
%   exist.
if( ~(isfield(stellarParameters','cdppSlope')))
    disp('Computing CDPP slopes ...')
    [ ~, cdppSlope ] = get_cdpp_slope(stellarParameters.rmsCdpp);
    stellarParameters.cdppSlope = cdppSlope;
end

% Save the augmented stellar parameters catalog
if( exist( strcat(catalogDir,'tpsV4AugmentedStellarParametersCatalog.mat'),'file' ) == 2 )
    save( strcat(catalogDir,'tpsV4AugmentedStellarParametersCatalog'), 'stellarParameters' )
end


% 4. Selection criteria
disp('Applying selection criteria ... ')
%   A. No planet candidate
%   B. logg > 4 to exclude giants and subgiants Ref. Mamajek, Eric https://www.pas.rochester.edu/~emamajek/IV_standards_PASTEL_logg.txt
minLog10SurfaceGravity = 4;
%   C. Teff < 7500 K
maxEffectiveTemp = 7500;
%   D. full dataspan 17Q
% cadencesPerDay = 48.9390982304706;
% minDataSpanInDays = 1450; % includes 138303 targets
% minDataSpanInCadences = cadencesPerDay*minDataSpanInDays;
minDataSpanInCadences = 71385; % 137971 targets, and none with greater span
%   E. dutyCycle
minDutyCycle = 0.8;
%   F. -0.6 < cdppSlope < +0.4
minCdppSlope = -0.6;
maxCdppSlope = 0.4;
%   Apply selection criteria -- 8213 stars
validTargetInds = find(...
    ~stellarParameters.isPlanetACandidate & ...
    stellarParameters.log10SurfaceGravity > minLog10SurfaceGravity &...
    stellarParameters.effectiveTemp < maxEffectiveTemp & ...
    stellarParameters.dataSpanInCadences == minDataSpanInCadences & ...
    stellarParameters.dutyCycle > minDutyCycle & ...
    stellarParameters.cdppSlope > minCdppSlope & ...
    stellarParameters.cdppSlope < maxCdppSlope & ...
    ~ismember(stellarParameters.keplerId,compositeInjectionTargetList.keplerId) );
fprintf('Found %d targets satisfying the selection criteria ...\n',length(validTargetInds))

% 5. Sample cdppSlope range
disp('Randomly sampling targets in each cdppSlope bin ...')
%   A. Divide cdppSlope range [-0.6,+0.4] into 20 bins of 0.05 dex
%   B. Randomly choose 2 targets per bin
%   C. Check stellar parameters of the 40 stars are representative
%   D. Check that there are no duplicates that overlap the 137 stars we
%     already have

% Create 20 uniformly spaced cdppSlope bins in range [-0.6,+0.4]
nBins = 20;
binEdges = linspace(-0.6,0.4,nBins+1);
% List of cdppSlope for valid targets
cdppSlope = stellarParameters.cdppSlope(validTargetInds);
% Partition the valid targets into the cdppSlope bins
[NN,bin] = histc(cdppSlope,binEdges);
% Loop over the cdppSlope bins, randomly selecting nTargetsPerBin targets
% from each bin
nTargetsPerBin = 2;
targetSubInds = zeros(1,nBins*nTargetsPerBin);
for iBin = unique(bin(:)')
    indsOfAllTargetsInThisBin = find( bin == iBin);
    subIndsOfSelectedTargets = [];
    % Require nTargetsPerBin unique selections!
    while( length(unique(subIndsOfSelectedTargets)) < nTargetsPerBin)
        subIndsOfSelectedTargets = randi(length(indsOfAllTargetsInThisBin),1,nTargetsPerBin);
    end
    fprintf('cdppSlope in bin %d\n',iBin)
    cdppSlope(indsOfAllTargetsInThisBin(subIndsOfSelectedTargets))
    targetSubInds((iBin-1)*2+1:2*iBin) = indsOfAllTargetsInThisBin(subIndsOfSelectedTargets);
    
end

% 6. Verification and validation
disp('Checking indexing: all red points should be marked with blue circles ...')

% Check that we got the indexing correct
figure
hold on
grid on
box on

% Selected targets are identified by their index in the sublist of valid targets, and ordered by cdpp slope bin
plot(cdppSlope(targetSubInds),'r.-')
% Now check -- identify the selected targets by their index in the whole target list, as a check
hold on;plot(stellarParameters.cdppSlope(validTargetInds(targetSubInds)),'bo')
xlabel('Target number')
ylabel('CDPP slope')
title([num2str(nTargetsPerBin*nBins),'Targets with CDPP slope in [-0.6, +0.4]'])
set(gca,'FontSize',12)
set(findall(gcf,'type','text'),'FontSize',12)
plotName = strcat(catalogDir,'cdppSlope_of_selected_targets')
print('-dpng','-r150',plotName)

% keplerId of selected targets
keplerIdOfTargetsSelectedByCdppSlope = stellarParameters.keplerId(validTargetInds(targetSubInds));

% Indicator for selected targets
idx = ismember(stellarParameters.keplerId,keplerIdOfTargetsSelectedByCdppSlope);

% Check that stellar parameters are in the desired ranges
fprintf('Number of targets that are planet candidates: %d -- should be 0\n',sum(stellarParameters.isPlanetACandidate(idx)))
sortedLog10SurfaceGravity = sort(stellarParameters.log10SurfaceGravity(idx));
fprintf('log10 Surface gravity: %7.2f to %7.2f\n',sortedLog10SurfaceGravity(1),sortedLog10SurfaceGravity(end))
sortedLog10Metallicity = sort(stellarParameters.log10metallicity(idx));
fprintf('log10 Metallicity: %7.2f to %7.2f\n',sortedLog10Metallicity(1),sortedLog10Metallicity(end));
sortedKeplerMag = sort(stellarParameters.keplerMag(idx));
fprintf('keplerMag: %7.2f to %7.2f\n',sortedKeplerMag(1),sortedKeplerMag(end))
sortedEffectiveTemp = sort(stellarParameters.effectiveTemp(idx));
fprintf('effectiveTemp: %7.0f to %7.0f\n',sortedEffectiveTemp(1),sortedEffectiveTemp(end))
sortedStellarRadiusInSolarRadii = sort(stellarParameters.stellarRadiusInSolarRadii(idx));
fprintf('stellar radius: %7.2f to %7.2f\n',sortedStellarRadiusInSolarRadii(1),sortedStellarRadiusInSolarRadii(end))
sortedDutyCycle = sort(stellarParameters.dutyCycle(idx));
fprintf('duty cycle: %7.2f to %7.2f\n',sortedDutyCycle(1),sortedDutyCycle(end))
sortedDataSpanInCadences = sort(stellarParameters.dataSpanInCadences(idx));
fprintf('data span: %d to %d\n',sortedDataSpanInCadences(1),sortedDataSpanInCadences(end))
sortedCdppSlope = sort(stellarParameters.cdppSlope(idx));
fprintf('cdpp slope: %7.2f to %7.2f\n',sortedCdppSlope(1),sortedCdppSlope(end))

% 7. Save the catalog
disp('Saving the catalog of targets selected by cdppSlope ...')
save( strcat(catalogDir,'targetsSelectedByCdppSlope'), 'keplerIdOfTargetsSelectedByCdppSlope' )







