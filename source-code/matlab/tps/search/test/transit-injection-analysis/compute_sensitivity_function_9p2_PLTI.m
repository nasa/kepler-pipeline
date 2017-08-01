% compute_sensitivity_function_9p2_PLTI
% Generate D.0 product for given MES thresholds,
% following the prescription given in the Appendix of Christiansen et al. 2016, astro-ph 1605.05729v1
% Original code from N. Batalha
% revised by Joe Catanzarite, 5/20/2016
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

% Modify to get TIP files for 9.2 and use Chris Burke's completeStructArray for the star properties catalog
% NOTE: add options to select for log10SurfactGravity and for dataSpan

%==========================================================================

% Base directory for scripts
baseDir = '/path/to/matlab/tps/search/test/transit-injection-analysis/';


% Control parameters

% Constants
MIN_PERIOD_DAYS=10.0;
MAX_PERIOD_DAYS=100.0;

% MES bin limits
LEFT_MES1 = 0;
RIGHT_MES1 = 80;
DEL_MES = 0.5;

LEFT_MES2 = -20;
RIGHT_MES2 = 20;

LEFT_MES3 = 5;
RIGHT_MES3 = 40;

LEFT_MES4 = 20;
RIGHT_MES4 = 40;

% Empirically determined offset for gamma-function
MES_CONSTANT = 4.1;

% Thresholds to use
MES_THRESHOLD = [7.1, 15];

% log10SurfaceGravity cut
MIN_LOGG = 4.0;

% Nine hour pulse duration
pulseIndex = 10;

% Option to select only targets with all 17 Q of data. Don't choose this
% option for M stars, as most of them have fewer than 17 Q of data.
% If false, still require 2 years of data
select17Q = logical(input('Select targets with all 17 Q of data? 1 or 0 -- '));

% Duty cycle selection -- better than 50%
selectDutyCycle = logical(input('Select targets with duty cycle > 0.5? 1 or 0 -- '));

% Data coverage -- better than 2 years
selectDataCoverage = logical(input('Select targets with data coverage > 2 years? 1 or 0 -- '));

% Select stars by temperature range
spectralType = input('Select spectral type: M, K, G, F, FGK -- ','s');
switch spectralType
    
    case 'M'
        MIN_TEFF=2500.0;
        MAX_TEFF=3900.0;
        
    case 'K'
        MIN_TEFF=3900.0;
        MAX_TEFF=5000.0;
        
    case 'G'
        MIN_TEFF=5000.0;
        MAX_TEFF=6000.0;
        
    case 'F'
        MIN_TEFF=6000.0;
        MAX_TEFF=7300.0;
        
    case 'FGK'
        MIN_TEFF=3900.0;
        MAX_TEFF=7300.0;
        
end



%==========================================================================
% Get the injection data from the NExScI table

% Load TIP file struct
% load('/path/to/ReadInjectionTable/injection.mat');
% struct: tipData

% The 9.2 detection efficiency table is downloaded from NExScI:
% http://exoplanetarchive.ipac.caltech.edu/docs/DR24-Pipeline-Detection-Efficiency-Table.txt
% Columns
% 1. keplerId
% 2. Sky Group
% 3. Period (days)
% 4. Epoch (BKJD)
% 5. t_depth (ppm)
% 6. t_dur (hours)
% 7. b (impact parameter)
% 8. Rp/Rs
% 9. a/Rs
% 10. offset from source (0 or 1)
% 11. Offset distance
% 12. Expected MES
% 13. Recovered
% 14. Measured MES
% 15. r_period (days) -- r_ means 1-sigma error?
% 16. r_epoch (BKJD)
% 17. r_depth
% 18. r_dur
% 19. r_b
% 20. r_Rp/Rs
% 21. r_a/Rs

% !!!!! Load the 9.2 detection efficiency table
if(~exist('tipData','var'))
    disp('Loading the NExScI 9.2 detection efficiency table...')
    fid = fopen(strcat('/codesaver/work/pixel_level_transit_injection/9p2_analysis/','DR24-Pipeline-Detection-Efficiency-Table.txt'));
    injectionTable = textscan(fid, '%d %d %f %f %f %f %f %f %f %d %f %f %d %s %*s %*s %*s %*s %*s %*s %*s','HeaderLines',4);
    fclose(fid);
    % nInjections = length(injectionTable{1});
    
    % Measured MES is column 14, but is a cell array: change cell entries to numbers
    idx = strcmp(injectionTable{14},'null');
    measuredMES = NaN(size(injectionTable{14}));
    measuredMES(~idx) = str2double(injectionTable{14}(~idx));
    
    % Create a struct named tipData with the injection data
    tipData.keplerId = injectionTable{1};
    tipData.skyGroup = injectionTable{2};
    tipData.period = injectionTable{3};
    tipData.epoch = injectionTable{4};
    tipData.depthPpm = injectionTable{5};
    tipData.durationHrs = injectionTable{6};
    tipData.impactParameter = injectionTable{7};
    tipData.RpOverRstar = injectionTable{8};
    tipData.aOverRstar = injectionTable{9};
    tipData.offsetFromSource = injectionTable{10};
    tipData.offsetDistArcsec = injectionTable{11};
    tipData.expectedMES = injectionTable{12};
    tipData.recovered = injectionTable{13};
    tipData.measuredMES = measuredMES;
end


%==========================================================================
% Load star properties catalog
% load('/path/to/ReadStarProp/starProp_dr24.mat');
% struct: stars

% !!!!! Instead, load the completeStructArray with stellar parameters created by Chris Burke in KSO-416
if(~exist('stars','var'))
    disp('Loading the star properties catalog...')
    load('/path/to/so-products-DR25/Complete_Seed_DR25_04-05-2016.mat');
    stars = completeStructArray;
    clear completeStructArray;
end

% Add an entry for kepid
[stars.kepid] = stars.keplerId;


% Get RA and DEC, other stellar parameters
RAall = [stars.new3ra]';
DECall = [stars.new3dec]';
new3rstarAll = [stars.new3rstar]';
new3teffAll = [stars.new3teff]';
new3loggAll = [stars.new3logg]';
new3ValidKicAll = [stars.new3ValidKic]';
kpmagAll = [stars.kpmag]';
keplerIdAll = [stars.keplerId]';

% Get RMS CDPP, dutyCycle and dataSpan for the 14 pulse durations
nTargetsAll = length(stars);
nPulseDurations = length(stars(1).rmsCdpps2);
rmsCdpp2All = zeros(nTargetsAll,nPulseDurations);
rmsCdpp1All = zeros(nTargetsAll,nPulseDurations);
dataSpansAll = zeros(nTargetsAll,nPulseDurations);
dutyCyclesAll = zeros(nTargetsAll,nPulseDurations);
for iTarget = 1:nTargetsAll
    rmsCdpp2All(iTarget,:) = [stars(iTarget).rmsCdpps2];
    rmsCdpp1All(iTarget,:) = [stars(iTarget).rmsCdpps1];
    dataSpansAll(iTarget,:) = [stars(iTarget).dataSpans1];
    dutyCyclesAll(iTarget,:) = [stars(iTarget).dutyCycles1];
end

%==========================================================================
% Target Selection: include effective temperature, logg and data spans

% Select target stars from catalog to be in desired range of effective
% temperature and log10SurfaceGravity
teffIdx = [stars.new3teff] > MIN_TEFF & [stars.new3teff] < MAX_TEFF;
loggIdx = [stars.new3logg] > MIN_LOGG;

% Data Span selection
if(select17Q)
    % Select targets with data for all 17Q
    dataSpansIdx = dataSpansAll(:,pulseIndex) == median(dataSpansAll(:,pulseIndex));
elseif(~select17Q)
    % No selection on data spans
    % dataSpansIdx = true(size(dataSpansAll(:,pulseIndex)));
    % Require data span to be longer than 2 years
    dataSpansIdx = dataSpansAll(:,pulseIndex) > 2*365.25;
end

% Duty cycle selection
if(selectDutyCycle)
    dutyCyclesIdx = dutyCyclesAll(:,pulseIndex) > 0.5;
end

% Data coverage selection -- minimum of 2 years
if(selectDataCoverage)
    dataCoverageIdx = dutyCyclesAll(:,pulseIndex).*dataSpansAll(:,pulseIndex) > 365.25*2;
end

%==========================================================================
% Select valid tipData entries:
% -- target star is in star prop struct,
% -- injection is in the specified logg range
% -- injection is in the specifed temperature range
% -- injection is selected for dataSpan
% -- injection is on target, i.e. not offsetFromSource
% -- injection is in the specified period range
tipIdx = ismember(tipData.keplerId,[stars(teffIdx).kepid]) & ...
    ismember(tipData.keplerId,[stars(loggIdx).kepid]) & ...
    ismember(tipData.keplerId,[stars(dataSpansIdx).kepid]) & ...
    ismember(tipData.keplerId,[stars(dutyCyclesIdx).kepid]) & ...
    ismember(tipData.keplerId,[stars(dataCoverageIdx).kepid]) & ...
    ~tipData.offsetFromSource == 1 & ...
    tipData.period > MIN_PERIOD_DAYS & tipData.period < MAX_PERIOD_DAYS;

%==========================================================================
% Compute sensitivity function (detection efficiency vs. MES) for MES > MES_THRESHOLD

% Use wider bins at high MES where sampling is sparse
DELMES1 = DEL_MES;
MINMES1 = 3;
MAXMES1 = 16;
DELMES2 = 4;
MINMES2 = MAXMES1;
MAXMES2 = 40;

% Uniform MES Binning Scheme
mesBinEdges1 = MINMES1:DELMES1:MAXMES1;
mesBinEdges2 = MINMES2:DELMES2:MAXMES2;

% Hybrid MES Binning Scheme -- wider bins at high MES, where sampling is sparse
% Expand bin size to 2 for MES > 15
mesBinEdges = [mesBinEdges1,mesBinEdges2(2:end)];
mesBinCenters = mesBinEdges(1:end-1)+diff(mesBinEdges)/2.0;

% Set up MES bins
xedges = mesBinEdges;
midx = mesBinCenters;
midx1 = 0:0.01:MAXMES2;

% Loop over MES_THRESHOLD values
for iThresh = 1:length(MES_THRESHOLD)
    
    fprintf('MES threshold %6.2f\n',MES_THRESHOLD(iThresh));
    
    % Identify targets with *measured* MES greater than MES_THRESHOLD
    highMesIdx = tipData.measuredMES > MES_THRESHOLD(iThresh);
    
    % Compute detection efficiency: count detections with measured MES above threshold
    recoveredIdx = tipData.recovered & highMesIdx;
    nbinmatch=histc(tipData.expectedMES( recoveredIdx & tipIdx ),xedges);
    nbinmatch=nbinmatch(1:end-1);
    nbinnomatch=histc(tipData.expectedMES( ~recoveredIdx & tipIdx),xedges);
    nbinnomatch=nbinnomatch(1:end-1);
    nbin=nbinmatch+nbinnomatch;
    
    % Plot detection efficiency
    figure(1+10*iThresh);
    hold on
    grid on
    box on
    plot(midx,nbinmatch./nbin,'b.-');
    title(['MES > ',num2str(MES_THRESHOLD(iThresh))]);
    hold on;
    
    % Select data for plot
    selectedBinIdx=find(midx>LEFT_MES3 & midx<RIGHT_MES3);
    xdata=midx(selectedBinIdx);
    ydata=nbinmatch(selectedBinIdx)./nbin(selectedBinIdx); %./0.97;
    
    % Eliminate NaNs which occur due to MES bins with no
    % injections
    zz=find(isnan(ydata));
    xdata(zz)=[];
    ydata(zz)=[];
    
    % Choose MES range to average to determine a 'plateau' value
    mesIdx = midx > LEFT_MES4 & midx < RIGHT_MES4 & nbin' > 0;
    
    % normalization of gamma cdf is mean of binned detection efficiency in desired MES range
    % Why adopt a scale factor for the gamma CDF? Better to include it in the
    % model and fit it from the data.
    gammaScaleFactor=mean(nbinmatch(mesIdx)./nbin(mesIdx));
    
    %==========================================================================
    % Fit Gamma CDF to MES > MES_THRESHOLD histogram
    
    for functionType = 1:2
        
        if(functionType == 1) % Gamma CDF
            
            fprintf('Gamma model function\n')
        
            % Gamma function model: 
            % !!!!! Why assume a value of 4.1 for MES_CONSTANT?
            % NOTE: Better to include the parameter in the model and fit it from the data.
            % modelFunction=@(xdata,alp,bet) gamcdf(xdata-MES_CONSTANT,alp,bet);
            modelFunction=@( xdata, alp, bet, gam, delt) delt .* gamcdf( xdata - gam,alp ,bet );
            
            % Objective function to be minimized is sum of squared residuals of data with model
            % NOTE: If we want to model a scale factor for the gamma function, then we should fit for it
            % sumSquaredModelResiduals=@(vec1) sum((modelFunction(xdata,vec1(1),vec1(2))-ydata'/gammaScaleFactor).^2);
            sumSquaredModelResiduals=@(vec1) sum( modelFunction( xdata, vec1(1), vec1(2), vec1(3), vec1(4) ) - ydata' ).^2;
            
            % Fit data to model. Supply initial trial values
            % Very sensitive to alp0, because the fitter won't allow much variation
            alp0 = 7.5;
            bet0 = 0.5;
            gam0 = MES_THRESHOLD(iThresh) - 3; % empirically found 4.1 is about right for MES threshold of 7.1, but not for 15
            delt0 = gammaScaleFactor;
            [modelResiduals,fval,exflg,outstruct]=fminsearch( sumSquaredModelResiduals, [ alp0, bet0, gam0, delt0 ] );
            
            % Report fitted parameters and plot the model function
            fprintf('alpha = %.3f, beta = %.3f, gamma = %.3f, delt = %.3f\n',modelResiduals(1),modelResiduals(2),modelResiduals(3),modelResiduals(4));
            figure(1+10*iThresh)
            hold on;
            plot(midx1,cdf('normal',midx1-MES_THRESHOLD(iThresh),0,1),'g-');
            % plot(midx,gammaScaleFactor*modelFunction(midx,modelResiduals(1),modelResiduals(2)),'r-');
            % Fix model by setting values greater than 1 to 1.
            gammaModel0 = modelFunction(midx1,modelResiduals(1),modelResiduals(2),modelResiduals(3),modelResiduals(4));
            gammaModel0(gammaModel0>1) = 1;
            plot(midx1,gammaModel0,'r-');
            %legend('Injection data','Model','Normal CDF','Location','SouthEast')
            %set(gca,'FontSize',12)
            %set(findall(gcf,'type','text'),'FontSize',12)
            
            % Plot fit residuals
            % stdGamma = std(gammaScaleFactor*modelFunction(xdata,modelResiduals(1),modelResiduals(2)) - ydata');
            gammaModel1 = modelFunction(xdata,modelResiduals(1),modelResiduals(2),modelResiduals(3),modelResiduals(4));
            % Fix model by setting values greater than 1 to 1.
            gammaModel1(gammaModel1>1) = 1; 
            stdGamma = std(gammaModel1 - ydata');
            figure(2+10*iThresh);
            hold on
            grid on
            box on
            title(['Residual: model minus data for MES > ',num2str(MES_THRESHOLD(iThresh))])
            xlabel('Expected MES')
            ylabel('residual')
            % plot(xdata,gammaScaleFactor*modelFunction(xdata,modelResiduals(1),modelResiduals(2))- ydata','r.-');
            plot(xdata,modelFunction(xdata,modelResiduals(1),modelResiduals(2),modelResiduals(3),modelResiduals(4))- ydata','r.-');
            % legend(sprintf('Standard deviation of residuals is %.5f.\n',std(gammaScaleFactor*modelFunction(xdata,modelResiduals(1),modelResiduals(2))- ydata')));
            % set(gca,'FontSize',12)
            % set(findall(gcf,'type','text'),'FontSize',12)
            
        elseif(functionType == 2) % Generalized Logistic Function
            
            fprintf('Generalized logistic model function\n')
            % Generalized logistic function model
            % https://en.wikipedia.org/wiki/Generalised_logistic_function
            % Three parameter model, taking C = 1 in the original model,
            % and defining bet as the MES at which detection efficiency = 1/2
            % Interpretation of parameters
            % alp --> Growth rate
            % bet --> Effective detection threshold.
            % gam --> The asymptote is 2^(gam-1)
            
            % modelFunction=@(xdata,delt,alp,bet,gam) delt * (1 + exp( -alp.* ( xdata - bet ) ) ).^(-gam);
            
            % Define bet as the MES at which det eff = 0, in the model with
            % C = 1
            % modelFunction=@( xdata, alp, bet, gam ) 0.5 * 2 .^ gam * (1 + exp( -alp.* ( xdata - bet ) ) ).^(-gam);
            
            % Add delt, the 4th parameter corresponding to C
            modelFunction=@( xdata, alp, bet, gam, delt ) 0.5 * ( ( delt + 1 ) ./ ( delt + exp( -alp.* ( xdata - bet ) ) ) ) .^ (gam) ;

            % Objective function to be minimized is sum of squared residuals of data with model
            % sumSquaredModelResiduals=@(vec2) sum((modelFunction(xdata,vec2(1),vec2(2),vec2(3),vec2(4))-ydata').^2);
            sumSquaredModelResiduals=@( vec2 ) sum( ( modelFunction( xdata, vec2(1), vec2(2), vec2(3), vec2(4) ) - ydata' ).^2 );
            
            % Fit data to model. Supply initial trial values
            % delt0 = 1.0;
            alp0 = 1.0;
            bet0 = 10;
            gam0 = 0.75;
            delt0 = 1;
            % [modelResiduals,fval,exflg,outstruct]=fminsearch(sumSquaredModelResiduals,[delt0,alp0,bet0,gam0]);
            % !!!!! Fitting for the exponent gamma gives very large (~ 10^7) values of
            % gamma and delta. Fitting instead for 1/gamma gives smaller
            % values of gamma and delta, but doesn't converge due to
            % reaching max # of function evals.
            [modelResiduals,fval,exflg,outstruct]=fminsearch(sumSquaredModelResiduals,[alp0,bet0,gam0,delt0],optimset('MaxFunEvals', 2000));
            
            % Report fitted parameters and plot the model function
            % fprintf('delt = %.3f, alpha = %.3f, beta = %.3f, gamma = %.3f\n',modelResiduals(1),modelResiduals(2),modelResiduals(3),modelResiduals(4));
            fprintf('alpha = %.3f, beta = %.3f, gamma = %.3f, delt =  %.3f\n',modelResiduals(1),modelResiduals(2),modelResiduals(3),modelResiduals(4));
            figure(1+10*iThresh)
            hold on;
            % plot(midx,modelFunction(midx,modelResiduals(1),modelResiduals(2),modelResiduals(3),modelResiduals(4)),'k-');
            plot(midx1,modelFunction(midx1,modelResiduals(1),modelResiduals(2),modelResiduals(3),modelResiduals(4)),'k-');
            % plot(midx,cdf('normal',midx-MES_THRESHOLD(iThresh),0,1),'g-');
            legend('Injection data','Normal CDF','Gamma CDF','Logistic','Location','SouthEast')
            set(gca,'FontSize',12)
            set(findall(gcf,'type','text'),'FontSize',12)
            
            % Plot fit residuals
            % stdLogistic = std(modelFunction(xdata,modelResiduals(1),modelResiduals(2),modelResiduals(3),modelResiduals(4))- ydata');
            stdLogistic = std(modelFunction(xdata,modelResiduals(1),modelResiduals(2),modelResiduals(3),modelResiduals(4)) - ydata');
            figure(2+10*iThresh);
            hold on
            grid on
            box on
            title(['Residual: model minus data for MES > ',num2str(MES_THRESHOLD(iThresh))])
            xlabel('Expected MES')
            ylabel('residual')
            % plot(xdata,modelFunction(xdata,modelResiduals(1),modelResiduals(2),modelResiduals(3),modelResiduals(4))- ydata','k.-');
            plot(xdata,modelFunction(xdata,modelResiduals(1),modelResiduals(2),modelResiduals(3),modelResiduals(4)) - ydata','k.-');
            legend( sprintf('STD residuals: %7.3f -- Gamma CDF',stdGamma),sprintf('STD residuals:  %7.3f -- Logistic',stdLogistic) );
            set(gca,'FontSize',12)
            set(findall(gcf,'type','text'),'FontSize',12)
            
            % Plot the number of detected counts in the MES bins
            figure(3+10*iThresh);
            hold on
            grid on
            box on
            title(['Number of counts in bins for MES > ',num2str(MES_THRESHOLD(iThresh))])
            xlabel('Expected MES')
            ylabel('Counts')
            plot(midx(selectedBinIdx),nbinmatch(selectedBinIdx),'b.-');
            set(gca,'FontSize',12)
            set(findall(gcf,'type','text'),'FontSize',12)
            
        end % if
            
    end % loop over functionType
    
end % loop over MES_THRESHOLD

