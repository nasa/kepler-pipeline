% compute_occurrence_rates
% Needs R2013, readfits from 2010 won't work  
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

% start timer
tic

% Path to functions
addpath /work/eta_earth/common

% Select star type
starType = input ('Star type G, K, or M -- ','s');

% Load stellar catalog
readStarPropTable_csv;
% stars = 
%
%              kepid: [129489x1 int32]
%     tm_designation: {129489x1 cell}
%               teff: [129489x1 int32]
%          teff_err1: [129489x1 int32]
%          teff_err2: [129489x1 int32]
%               logg: 
%          logg_err1: 
%          logg_err2: 
%                feh: 
%           feh_err1: 
%           feh_err2: 
%               mass: 
%          mass_err1: 
%          mass_err2: 
%             radius: 
%        radius_err1: 
%        radius_err2: 
%               dens: 
%          dens_err1: 
%          dens_err2: 
%           prov_sec: {129489x1 cell}
%             kepmag: 
%             nconfp: [129489x1 int32]
%               nkoi: [129489x1 int32]
%               ntce: [129489x1 int32]
%       datalink_dvr: {129489x1 cell}
%       st_delivname: {129489x1 cell}
%    st_vet_date_str: {129489x1 cell}
%                 ra: 
%             ra_str: {129489x1 cell}
%                dec: 
%            dec_str: {129489x1 cell}
%        st_quarters: {129489x1 cell}
%          teff_prov: {129489x1 cell}
%          logg_prov: {129489x1 cell}
%           feh_prov: {129489x1 cell}
%               jmag: 
%           jmag_err: 
%               hmag: 
%           hmag_err: 
%               kmag: 
%           kmag_err: 
%          dutycycle: 
%           dataspan: 
%       mesthres01p5: 
%       mesthres02p0: 
%       mesthres02p5: 
%       mesthres03p0: 
%       mesthres03p5: 
%       mesthres04p5: 
%       mesthres05p0: 
%       mesthres06p0: 
%       mesthres07p5: 
%       mesthres09p0: 
%       mesthres10p5: 
%       mesthres12p0: 
%       mesthres12p5: 
%       mesthres15p0: 
%       rrmscdpp01p5: 
%       rrmscdpp02p0: 
%       rrmscdpp02p5: 
%       rrmscdpp03p0: 
%       rrmscdpp03p5: 
%       rrmscdpp04p5: 
%       rrmscdpp05p0: 
%       rrmscdpp06p0: 
%       rrmscdpp07p5: 
%       rrmscdpp09p0: 
%       rrmscdpp10p5: 
%       rrmscdpp12p0: 
%       rrmscdpp12p5: 
%       rrmscdpp15p0: 

% Apply stellar selection cuts
% G Teff 5300 - 6000 K
% K Teff 3900 - 5300 K
% M Teff 2400 - 3900 K
% logg > 4
% duty cycle > 0.1
% data span > 30 days
keplerId = stars.kepid;
teffStar = stars.teff;
loggStar = stars.logg;
rStar = stars.radius;
kepMag = stars.kepmag;
dataspan = stars.dataspan;
dutycycle = stars.dutycycle;
mStar = stars.mass;

% mesthreshold
mesthres01p5 = stars.mesthres01p5;
mesthres02p0 = stars.mesthres02p0; 
mesthres02p5 = stars.mesthres02p5; 
mesthres03p0 = stars.mesthres03p0; 
mesthres03p5 = stars.mesthres03p5; 
mesthres04p5 = stars.mesthres04p5; 
mesthres05p0 = stars.mesthres05p0; 
mesthres06p0 = stars.mesthres06p0; 
mesthres07p5 = stars.mesthres07p5; 
mesthres09p0 = stars.mesthres09p0; 
mesthres10p5 = stars.mesthres10p5; 
mesthres12p0 = stars.mesthres12p0; 
mesthres12p5 = stars.mesthres12p5; 
mesthres15p0 = stars.mesthres15p0;

% MES thresholds vector for pulse durations
mesThresholds = [mesthres01p5,mesthres02p0,mesthres02p5,mesthres03p0, ...
    mesthres03p5,mesthres04p5,mesthres05p0,mesthres06p0,mesthres07p5, ...
    mesthres09p0,mesthres10p5,mesthres12p0,mesthres12p5,mesthres15p0];

% rmscdpp
rrmscdpp01p5 = stars.rrmscdpp01p5; 
rrmscdpp02p0 = stars.rrmscdpp02p0; 
rrmscdpp02p5 = stars.rrmscdpp02p5; 
rrmscdpp03p0 = stars.rrmscdpp03p0; 
rrmscdpp03p5 = stars.rrmscdpp03p5; 
rrmscdpp04p5 = stars.rrmscdpp04p5; 
rrmscdpp05p0 = stars.rrmscdpp05p0; 
rrmscdpp06p0 = stars.rrmscdpp06p0; 
rrmscdpp07p5 = stars.rrmscdpp07p5; 
rrmscdpp09p0 = stars.rrmscdpp09p0; 
rrmscdpp10p5 = stars.rrmscdpp10p5; 
rrmscdpp12p0 = stars.rrmscdpp12p0; 
rrmscdpp12p5 = stars.rrmscdpp12p5; 
rrmscdpp15p0 = stars.rrmscdpp15p0;

% RMS CDPP and pulse duration grids
cdppGrid = [rrmscdpp01p5,rrmscdpp02p0,rrmscdpp02p5,rrmscdpp03p0, ...
    rrmscdpp03p5,rrmscdpp04p5,rrmscdpp05p0,rrmscdpp06p0,rrmscdpp07p5, ...
    rrmscdpp09p0,rrmscdpp10p5,rrmscdpp12p0,rrmscdpp12p5,rrmscdpp15p0];
% Grid of pulse durations
pulseDurationGrid = [1.5, 2.0, 2.5, 3.0, 3.5, 4.5, 5.0, 6.0, 7.5, 9.0, 10.5, 12.0, 12.5, 15.0];


% stellar selection cuts
gTeffIdx = teffStar > 5300 & teffStar < 6000;
kTeffIdx = teffStar > 3900 & teffStar < 5300;
mTeffIdx = teffStar > 2400 & teffStar < 3900;
loggIdx = loggStar > 4.0;
dutycycleIdx = dutycycle > 0.33;
dataspanIdx = dataspan.*dutycycle > 2*365.25;
hasMassIdx = mStar > 0;

% Total number of stars selected
switch starType
    case 'G'
        goodStarIdx = loggIdx & dutycycleIdx & dataspanIdx & gTeffIdx & hasMassIdx;
    case 'K'
        goodStarIdx = loggIdx & dutycycleIdx & dataspanIdx & kTeffIdx & hasMassIdx;
    case 'M'
        goodStarIdx = loggIdx & dutycycleIdx & dataspanIdx & mTeffIdx & hasMassIdx;
end
nStars = sum(goodStarIdx);

%==========================================================================
% Load the summed v0 contours (accounting for geometric factor)
v0Format = 'M';% input('Format of v0 contours file: M(MATLAB) or F(FITS) -- ','s');
switch v0Format
    case 'F'
        % Do this from R2013, R2010 can't do it.
        loadsumfits
        % info = fitsinfo(gridfitsfile);
        % hdrcell = info.PrimaryData.Keywords;
        % hdrkeys = {hdrcell{:,1}};
        % hdrvalues = {hdrcell{:,2}};
        % PMIN = cell2mat(hdrvalues(strcmp(hdrkeys,'MINPER')));
        % PMAX = cell2mat(hdrvalues(strcmp(hdrkeys,'MAXPER')));
        % NP = cell2mat(hdrvalues(strcmp(hdrkeys,'NPER')));
        % RPMIN = cell2mat(hdrvalues(strcmp(hdrkeys,'MINRP')));
        % RPMAX = cell2mat(hdrvalues(strcmp(hdrkeys,'MAXRP')));
        % NRP = cell2mat(hdrvalues(strcmp(hdrkeys,'NRP')));
        % per1d = linspace(PMIN,PMAX,NP);
        % rp1d = linspace(RPMIN,RPMAX,NRP);
        % [per2d, rp2d]=meshgrid(per1d,rp1d);
        % cumulative_array = fitsread(gridfitsfile,'Primary');
        % ==> sumgeodet2d = cumulative_array(:,:,2);
        % avgdet2d = cumulative_array(:,:,1);
        % usedkics = cell2mat(fitsread(gridfitsfile,'BinaryTable'));
        save('sumv0_Gstars.mat','PMIN', 'PMAX', 'NP', 'RPMIN', 'RPMAX', 'NRP', 'per1d', 'rp1d', 'per2d', 'rp2d', 'sumgeodet2d', 'avgdet2d', 'usedkics');
    case 'M'
        % Use R2010, because it has toolboxes we need
        load('sumv0_Gstars.mat')
end

% Show the completeness contours
figure
imagesc(sumgeodet2d)
colorbar

%==========================================================================
% Make v0 contours

% !!!!! Set 2D binning scheme, same for all targets
minPeriodDays = 20;
maxPeriodDays = 720;
minRadiusEarths = 0.5; % !!!!! This will be smaller for M stars in Groups 3 and 6
maxRadiusEarths = 15;
mesLowerLimit = 3;
mesUpperLimit = 16;

nBins = [70 30]; % binwidth of 10 days, from 20 to 720 days

% Period bins
binWidthPeriod = (maxPeriodDays - minPeriodDays)/nBins(1); % 10 days

% Radius bins
binWidthRadius = (log10(maxRadiusEarths) - log10(minRadiusEarths))/nBins(2);
binEdges = {minPeriodDays:binWidthPeriod:maxPeriodDays log10(minRadiusEarths):binWidthRadius:log10(maxRadiusEarths) };
% yLabelString = ['log_{10}( Radius [Earths] ), bin size =  ',num2str(binWidthRadius,'%6.2f')];

% Calculate grids for contour plots
binEdges1 = binEdges{1};
binEdges2 = binEdges{2};

% Bin centers from binEdges
binCenters1 = (binEdges1(2:end) + binEdges1(1:end-1))./2;
binCenters2 = (binEdges2(2:end) + binEdges2(1:end-1))./2;
binCenters = {binCenters1 binCenters2};
nBins1 = length(binCenters{1});
nBins2 = length(binCenters{2});

% Make 2D meshgrid of binCenters
[xGridCenters,yGridCenters] = meshgrid(binCenters{1},binCenters{2});

% Parameters for detection efficiency as a function of MES,
% for 9.2 DR24 pixel-level transit injection from Jessie Christiansen
% For G stars: a = 103.0113, b = 0.10583, c = 0.78442
A = 103.0113;
B = 0.10583;
C = 0.78442;

% Grid of MES values
deltaMes = 0.01;
mesMin = 3;
mesMax = 20;
mesGrid = mesMin:deltaMes:mesMax;
deteffGrid = C.*gamcdf(mesGrid,A,B);

% 1. Map each point on the period-radius grid to a MES
% MES = (depth/cdpp)*sqrt(nTransits)
rStar = rStar(goodStarIdx);
loggStar = loggStar(goodStarIdx);
dataspan = dataspan(goodStarIdx); % !!!!! in cadences?
cdppGrid = cdppGrid(goodStarIdx,:);
dutycycle = dutycycle(goodStarIdx);

% Compute transit depth, corrected for limb-darkening
% A row of depths (corresponding to radius grid centers) for each star in catalog
fprintf('Computing transit depths over grid of radius bin centers...\n')
depth = zeros(nStars,nBins2);
for iRadius = 1:nBins2
    % Depth as a function of star and planet radius; remember that radius
    % bins are logarithmic
    depth(:,iRadius) = rp_to_tpssquaredepth(rStar,10.^(binCenters2(iRadius)));
end % loop over radius grid
toc

% Compute transit duration and effective number of transits on the period grid
% For each star in catalog, there is corresponding row of durationHours, nTransitsEffective, and cdpp associated with period grid centers
% Interpolate cdpp to transit duration
toc
fprintf('Computing transit durations, number of transits, and cdpp...\n')
durationHours = zeros(nStars,nBins1);
nTransitsEffective = zeros(nStars,nBins1);
cdpp = zeros(nStars,nBins1);
eccentricity = 0;
for iPeriod = 1:nBins1
    
    % Compute duration, number of transits and cdpp grids
    durationHours(:,iPeriod) = transit_duration(rStar,loggStar,binCenters1(iPeriod),eccentricity);
    nTransitsEffective(:,iPeriod) = dataspan./binCenters1(iPeriod);
    
    % Extrapolate cdpp to edge values for transit durations outside the duration grid
    extrapToLeftBoundary = durationHours(:,iPeriod) <= pulseDurationGrid(1);
    if(sum(extrapToLeftBoundary) > 0)
        cdpp( extrapToLeftBoundary , iPeriod ) = cdppGrid( extrapToLeftBoundary , 1);
    end
    extrapToRightBoundary = durationHours(:,iPeriod) >= pulseDurationGrid(end);
    if(sum(extrapToRightBoundary) > 0)
        cdpp( extrapToRightBoundary ,iPeriod ) = cdppGrid( extrapToRightBoundary , end);
    end
    % For each star, interpolate to get cdpp corresponding to the pulse duration that corresponds to this period 
    inds = find( durationHours(:,iPeriod) > pulseDurationGrid(1) & durationHours(:,iPeriod) < pulseDurationGrid(end) );
    for jStar = inds'
        cdpp( jStar , iPeriod ) = interp1( pulseDurationGrid , cdppGrid(jStar,:), durationHours( jStar,iPeriod ) ,'pchip' );
    end
    
end % loop over period grid
toc 

% Loop over targets to get the summed completeness grid
% For each point in the period-radius grid
% calculate the corresponding MES, 
% interpolate to find the detection efficiency, 
% correct for geometric factor,
% and accumulate the completeness sum for each target
tic
sumcompleteness = zeros(nBins1,nBins2);
winfunc1d = ones(nStars,nBins1);
geometricFactor = zeros(nStars,nBins1);
fprintf('Computing completeness grid over star catalog ...\n')
for iStar = 1:nStars
    
    % Completeness grid for this star
    deteff = zeros(nBins1,nBins2);
    MES = zeros(nBins1,nBins2);
    completenessThisStar = zeros(nBins1,nBins2);

    % Loop over period grid
    for iPeriod = 1:nBins1
        
        % Geometric factor is the probability to transit 
        geometricFactor(iStar,iPeriod) = prob_to_transit(rStar(iStar),loggStar(iStar),binCenters1(iPeriod),eccentricity);
        
        % Compute window function for this star at this period
        winfunc1d(iStar,iPeriod) = winfunc1d(iStar,iPeriod) - floatbino(0,nTransitsEffective(iStar,iPeriod),dutycycle(iStar));
        winfunc1d(iStar,iPeriod) = winfunc1d(iStar,iPeriod) - floatbino(1,nTransitsEffective(iStar,iPeriod),dutycycle(iStar));
        winfunc1d(iStar,iPeriod) = winfunc1d(iStar,iPeriod) - floatbino(2,nTransitsEffective(iStar,iPeriod),dutycycle(iStar));
        
        % Clean up negative values
        if( winfunc1d(iStar,iPeriod) < 0 )
            winfunc1d(iStar,iPeriod) = 0.0;
        end
    
        % Loop over radius grid
        for iRadius = 1:nBins2
            
            % MES for this a planet with this period and radius at this target
            % scale nTransits by dutycycle
            % Chris says that nTransitsEffective should be floored at 3 for
            % SNR calculation. Not doing this, for now.
            MES = ( depth(iStar,iRadius)./cdpp(iStar,iPeriod) ) .* sqrt(dutycycle(iStar) .* nTransitsEffective(iStar,iPeriod));
            
            % Interpolate detection efficiency at this MES
            deteff = interp1(mesGrid,deteffGrid,MES,'pchip');
            
            % Completeness at this star
            % Scale by window function
            completenessThisStar(iPeriod,iRadius) = deteff.*geometricFactor(iStar,iPeriod).*winfunc1d(iStar,iPeriod);
            
        end % loop over radius grid
        
    end % loop over period grid
        
    % Accumulate the sum of the 2D completeness contour over all targets
    sumcompleteness = sumcompleteness + completenessThisStar;
    if(mod(iStar,100)==0)
        fprintf('Star # %d\n',iStar)
        toc
    end
    
end % loop over target stars

toc
return


%==========================================================================
% Load planet catalog
 readTableCandidates_wget;
 
%            kepoi_name:
%           kepler_name:
%                    ra: 
%                ra_err: 
%                ra_str:
%                   dec: 
%               dec_err: 
%               dec_str:
%              koi_gmag: 
%          koi_gmag_err: 
%              koi_rmag: 
%          koi_rmag_err: 
%              koi_imag: 
%          koi_imag_err: 
%              koi_zmag: 
%          koi_zmag_err: 
%              koi_jmag: 
%          koi_jmag_err: 
%              koi_hmag: 
%          koi_hmag_err: 
%              koi_kmag: 
%          koi_kmag_err: 
%            koi_kepmag: 
%        koi_kepmag_err: 
%         koi_delivname:
%          koi_vet_stat:
%          koi_quarters:
%       koi_disposition:
%      koi_pdisposition:
%             koi_count: 
%      koi_num_transits: 
%      koi_max_sngle_ev: 
%       koi_max_mult_ev: 
%      koi_bin_oedp_sig: 
%      koi_limbdark_mod:
%        koi_ldm_coeff4: 
%        koi_ldm_coeff3: 
%        koi_ldm_coeff2: 
%        koi_ldm_coeff1: 
%         koi_trans_mod:
%         koi_model_snr: 
%         koi_model_dof: 
%       koi_model_chisq: 
%           koi_time0bk: 
%      koi_time0bk_err1: 
%      koi_time0bk_err2: 
%             koi_eccen: 
%        koi_eccen_err1: 
%        koi_eccen_err2: 
%             koi_longp: 
%        koi_longp_err1: 
%        koi_longp_err2: 
%              koi_prad: 
%         koi_prad_err1: 
%         koi_prad_err2: 
%               koi_sma: 
%          koi_sma_err1: 
%          koi_sma_err2: 
%            koi_impact: 
%       koi_impact_err1: 
%       koi_impact_err2: 
%          koi_duration: 
%     koi_duration_err1: 
%     koi_duration_err2: 
%           koi_ingress: 
%      koi_ingress_err1: 
%      koi_ingress_err2: 
%             koi_depth: 
%        koi_depth_err1: 
%        koi_depth_err2: 
%            koi_period: 
%       koi_period_err1: 
%       koi_period_err2: 
%               koi_ror: 
%          koi_ror_err1: 
%          koi_ror_err2: 
%               koi_dor: 
%          koi_dor_err1: 
%          koi_dor_err2: 
%             koi_incl: 
%        koi_incl_err1: 
%        koi_incl_err2: 
%              koi_teq: 
%         koi_teq_err1: 
%          koi_teq_err2: 
%             koi_steff: 
%        koi_steff_err1: 
%        koi_steff_err2: 
%             koi_slogg: 
%        koi_slogg_err1: 
%        koi_slogg_err2: 
%              koi_smet: 
%         koi_smet_err1: 
%         koi_smet_err2: 
%              koi_srad: 
%         koi_srad_err1: 
%         koi_srad_err2: 
%             koi_smass: 
%        koi_smass_err1: 
%        koi_smass_err2: 
%              koi_sage: 
%         koi_sage_err1: 
%         koi_sage_err2: 
%          koi_sparprov:
%      koi_fwm_stat_sig: 
%           koi_fwm_sra: 
%       koi_fwm_sra_err: 
%          koi_fwm_sdec: 
%      koi_fwm_sdec_err: 
%          koi_fwm_srao: 
%      koi_fwm_srao_err: 
%         koi_fwm_sdeco: 
%     koi_fwm_sdeco_err: 
%          koi_fwm_prao: 
%      koi_fwm_prao_err: 
%         koi_fwm_pdeco: 
%     koi_fwm_pdeco_err: 
%         koi_dicco_mra: 
%     koi_dicco_mra_err: 
%        koi_dicco_mdec: 
%    koi_dicco_mdec_err: 
%        koi_dicco_msky: 
%    koi_dicco_msky_err: 
%         koi_dicco_fra: 
%     koi_dicco_fra_err: 
%        koi_dicco_fdec: 
%    koi_dicco_fdec_err: 
%        koi_dicco_fsky: 
%    koi_dicco_fsky_err: 
%         koi_dikco_mra: 
%     koi_dikco_mra_err: 
%        koi_dikco_mdec: 
%    koi_dikco_mdec_err: 
%        koi_dikco_msky: 
%    koi_dikco_msky_err: 
%         koi_dikco_fra: 
%     koi_dikco_fra_err: 
%        koi_dikco_fdec: 
%    koi_dikco_fdec_err: 
%        koi_dikco_fsky: 
%    koi_dikco_fsky_err: 
%           koi_comment:
%          koi_vet_date:
%      koi_tce_plnt_num: 
%     koi_tce_delivname:
%      koi_datalink_dvs:
%         koi_disp_prov:
%         koi_parm_prov:
%             koi_time0: 
%        koi_time0_err1: 
%        koi_time0_err2: 
%      koi_datalink_dvr:
%         koi_fpflag_nt: 
%         koi_fpflag_ss: 
%         koi_fpflag_co: 
%         koi_fpflag_ec: 
%             koi_insol: 
%        koi_insol_err1: 
%        koi_insol_err2: 
%              koi_srho: 
%         koi_srho_err1: 
%         koi_srho_err2: 
%           koi_fittype:
%                   koi: 
%          koi_vet_year: 
%         koi_vet_month: 
%           koi_vet_day: 
%                  slum: 
%             slum_err1: 
%             slum_err2: 
 
period = koiAll.koi_period; 
koiId = koiAll.koi;
kepmag = koiAll.koi_kepmag; 
disposition = koiAll.koi_disposition;
mes = koiAll.koi_max_mult_ev;
radius = koiAll.koi_prad;
koiName = koiAll.kepoi_name;
kepler_name = koiAll.kepler_name;
koiKeplerId = koiAll.kepid;
num_transits = koiAll.koi_num_transits;
koi_duration = koiAll.koi_duration;
koi_num_transits = koiAll.koi_num_transits;
koi_depth = koiAll.koi_depth;

% planets on selected targets

 % Apply planet selection cuts
 % MES > 15
 koiIsOnGoodGstarIdx = ismember(koiKeplerId,keplerId(goodStarIdx));
 koiIsOnGoodKstarIdx = ismember(koiKeplerId,keplerId(goodKstarIdx));
 koiIsOnGoodMstarIdx = ismember(koiKeplerId,keplerId(goodMstarIdx));
 
 % Dan said that KOI planet radius may have to be changed to be consistent with
 % Q17 stellar table

 % Planets on selected G stars
 idxG = radius > 1.5 & radius < 2.3 & period > 40 & period < 80 & ...
     mes > 15 & koiIsOnGoodGstarIdx;

 % Planets on selected K stars
 idxK1 = radius > 1.5 & radius < 2.3 & period > 40 & period < 80 & ...
     mes > 15 & koiIsOnGoodKstarIdx;
 idxK2 = radius > 1.5 & radius < 2.3 & period > 20 & period < 40 & ...
     mes > 15 & koiIsOnGoodKstarIdx;
 
 % Planets on selected M stars
 idxM = radius > 1.5 & radius < 2.3 & period > 20 & period < 40 & ...
     mes > 15 & koiIsOnGoodMstarIdx;

 %========================================================================
 % planet catalog
 
 planetPeriod = period(idxG);
 planetRadius = radius(idxG);

% Kepler Id of G star sample
% keplerIdGstars = keplerId(goodStarIdx);


% number of detected planets in a bin = (number of expected planets we could detected in bin, if every star had one) * (occurrence rate per star in bin)
% occurrence rate per star in bin = (number of detected planets in bin)/(number of expected planets we could detect in bin, if every star had one)

% period and radius bin edges used for the v0 contours
binEdges{1} = per1d;
binEdges{2} = rp1d;

% Detected planets binned on period-radius grid
binnedDetectedPlanets = hist3([planetPeriod,planetRadius],'Edges',binEdges);

% Compute occurrence rates in bins
occurrenceRates = binnedDetectedPlanets./sumgeodet2d;

% Normalize to one bin per superbin
n2dBins = length(per1d).*length(rp1d);

% Occurrence rate in superbin
occurrenceRateInSuperbin = sum(binnedDetectedPlanets(:))./(sum(sumgeodet2d(:))./n2dBins);


% Indicator for non-empty bins
planetIdx = binnedDetectedPlanets(:) > 0;
nBinsWithPlanets = sum(planetIdx);

% Poisson count error
% (1) assuming binnedDetectedPlanets has counting error, but sumgeodet2d has no counting error
% poissonVarianceInBin = binnedDetectedPlanets(planetIdx)./(sumgeodet2d(planetIdx)).^2;
% (2) propagation of errors
% poissonVarianceInBin = (binnedDetectedPlanets(planetIdx).^2.*sumgeodet2d(planetIdx) + binnedDetectedPlanets(planetIdx).*sumgeodet2d(planetIdx).^2)./(sumgeodet2d(planetIdx).^4);
% (3) Reference on variance of a quotient of independent RVs: http://faculty.ksu.edu.sa/72966/Documents/OR%20Handbook.pdf 
poissonVarianceInBin = (binnedDetectedPlanets(planetIdx)./sumgeodet2d(planetIdx)).^2.*( 1./binnedDetectedPlanets(planetIdx) + 1./sumgeodet2d(planetIdx) );

% Variance of a sum is the sum of the variances
% (1), (2), and (3) give same answer
poissonError = sqrt( sum( poissonVarianceInBin )./nBinsWithPlanets );

fracErrNum = sqrt(binnedDetectedPlanets(planetIdx))./binnedDetectedPlanets(planetIdx);
fracErrDen = sqrt(sumgeodet2d(planetIdx))./sumgeodet2d(planetIdx);
totalFracErr = sqrt(sum(sum(fracErrNum.^2+fracErrDen.^2)));

% Report result
fprintf('Occurrence rate is %8.3f +/- %8.3f\n',occurrenceRateInSuperbin,poissonError)

% Occurrence rate in all bins
figure
imagesc(occurrenceRates)
colorbar

% Occurrence rate as a function of period
figure
hold on
grid on
box on
plot(per1d,sum(binnedDetectedPlanets./sumgeodet2d),'k.-')
xlabel('Period [Days]')
ylabel('Rate')
title('Occurrence Rate marginalized over planet radius')

% Occurrence rate as a function of radius
figure
hold on
grid on
box on
plot(rp1d,sum(binnedDetectedPlanets./sumgeodet2d,2),'r.-')
xlabel('Radius [Earths]')
ylabel('Rate')
title('Occurrence Rate marginalized over planet period')





