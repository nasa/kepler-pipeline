function stellarVariability = generate_stellar_variability_curves(sohoSolarVariabilityObject)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function stellarVariability = create_light_curve(sohoSolarVariabilityObject)
%
% (based on ETEM1 Generate_Stellar_Variability)
%
% Description:
% This function takes solar irradiance data measurements and new stellar
% rotation period as input parameters to compute stellar variability for
% the new rotation period. See figure 7.2 in the ATBD. 'hscale' is an array
% obtained from figure 7.2 which accounts for the variation in power of the
% solar variability curves between solar max and solar min in different
% time scales. This hscale is used to introduce stellar variability for the
% new star with a different rotation period by scaling the wavelet
% coefficients in each scale appropriately and reconstructing the stellar
% variabilty time series.
% ~~~~~~~~~~~~~~~~~~~ NOTE ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% By uncommenting a line inside the code, this function can also add system
% noise appropriate for Kepler instrument and return this as the output
% data.
%
% Inputs:
%       StellarRotationMin - Minimum star rotation period in 'Solar
%       Rotation Period' units (a fraction)
%       StellarRotationMax - Maximum star rotation period in 'Solar
%       Rotation Period' units (a fraction)
%       SamplingFreq - number of samples per day
%       xxxSimulationDays - simulation duration in days (not used)
%       Ncurves - number of transit signatures to generate
%
% Loads:
%       solnew.mat loads soln.dat
%       soln data containd DIARAD/SOHO measurements that have been edited, filled
%       in by reflection, variance adjusted, binned to 15 min intervals, extended
%       to 2^17 points
%       ikeep - a logical array which indicates data gap by zeros
%       noisesig - noise signal, calcnoisesig returns total system noise adjusted for DIARAD
%       instrument uncertainty for 15 minute sampling interval
%
% Output:
%       An array ('Ncurves') of structures with the 'i'th structure
%       defined as follows:
%       stellarVariability(i).timeSeries - solar variabilty for the new
%       star with a different rotation period
%       stellarVariability(i).StarRotationPeriod - StarRotationPeriod as a
%       fraction of solar rotation period
%       stellarVariability(i).ikeep  - logical array indicating which
%       samples are 'original' and which are 'gap filled' 
%
% Calls:
%         daubh0
%         OvercompleteWaveletTransform
%         scalerow
%         InverseOvercompleteWaveletTransform
%         evenextend
%         zpad
%         calcnoisesig
%
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

% get the parameters of this run
runParamsObject = sohoSolarVariabilityObject.runParamsClass;
startTime = get(runParamsObject, 'runStartTime'); % start time in julian days
numCadences = get(runParamsObject, 'runDurationCadences'); % # of cadences in this run
cadenceDuration = get(runParamsObject, 'cadenceDuration'); % duration of a cadence in seconds
fluxOfMag12Star = get(runParamsObject, 'fluxOfMag12Star'); % for noise calculation

SamplingFreq = 24*3600/cadenceDuration; % samples per day
StellarRotationMin = sohoSolarVariabilityObject.stellarRotationRange(1);
StellarRotationMax = sohoSolarVariabilityObject.stellarRotationRange(2);
Ncurves = sohoSolarVariabilityObject.numRotationSpeeds;

% add waitbar to show progress
handle = waitbar(0,'Generating Stellar Variability Time Series: OWT ....');

% show 50%, since inside OWT there is no wait bar....
waitbar(0.5,handle);
%--------------------------------------------------------------------------
% preliminaries
Solar_Rotation_Days = 26.6; % days
load(sohoSolarVariabilityObject.sohoDataFilePath); %load "solnew.mat"
nsol = length(soln);

% compute total rms system noise from the DIARAD/SOHO data (after
% adjusting for DIARAD instrument noise) over the sampling interval
fs = 24/SamplingFreq; % number of samples in an hour
noisesig = calcnoisesig(fs, 12, 0.1, fluxOfMag12Star);    

m = log2(nsol)-floor(log2(12))+1; % number of scales in the OWT

hscale = [...
    0.92548;
    0.96531;
    1.037;
    1.0972;
    1.3218;
    2.1057;
    4.5344;
    7.7989;
    11.224;
    repmat(11.224,m-9,1)];

hscale = sqrt(hscale);
hscale = hscale - min(hscale);
hscale = hscale/max(hscale); % now all the values are between 0 and 1

hscale0 = hscale;

h0 = daubh0(12);

% solnew.mat loads soln.dat
% soln data containd DIARAD/SOHO measurements that have been edited, filled
% in by reflection, variance adjusted, binned to 15 min intervals, extended
% to 2^17 points

wsoln0 = OvercompleteWaveletTransform(soln, h0, m-1);

close(handle);
%--------------------------------------------------------------------------

% initilaize and allocate memory for an array of structures
timeSeries = zeros(nsol,1);
StarRotationPeriod = 0.0;

stellarVariability = repmat(struct('timeSeries',timeSeries,'StarRotationPeriod',StarRotationPeriod),1,Ncurves);

% y = linspace(a,b,n) generates a row vector y of n points linearly spaced
% between and including a and b.
% stellar rotation periods array

Period_Range = linspace(StellarRotationMin, StellarRotationMax, Ncurves);

n1 = length(Period_Range);


handle = waitbar(0,'Generating Stellar Variability Time Series...');

for j = 1:Ncurves


    StellarRotationPeriod = Period_Range(j);

    % interpolation factor
    interpfac = 1/StellarRotationPeriod; % Stellar Rotation Period in units of Solar Rotation Period

    % see figure 7.2 in the ATBD and equation 7.10 which states that
    % photometric variability = Stellar_Rotation^(-1.5)= interpfact(i)^1.5

    % hscale accounts for the variation in power of the solar variability
    % curves between solar max and solar min. hscale is used to introduce
    % solar variabilty for the new star with a different rotation period

    hscale = 1 + hscale0*(interpfac^1.5 - 1); % -1 makes sure that for sun hscale reamins 1

    wsoln = scalerow(hscale(:)',wsoln0);

    solnm = InverseOvercompleteWaveletTransform(wsoln, h0);

    t = (0:nsol-1)'/(nsol-1);

    % tnew may contain more or less number of samples because of resampling
    tnew = (0:interpfac:nsol-1)'/(nsol-1);

    solnew = interp1(t,solnm(1:nsol),tnew,'*linear');

    ikeepnew = interp1(t,ikeep(1:nsol) > 0,tnew,'*linear') == 1;

    %   noise is not added to this stellar variability
    %   uncomment this line if noise is to be added....
    %   solout = solnew + randn(size(solnew))*noisesig;
    new_length = length(tnew);
    
    % the median of the soln time series loaded from solnew.mat was 1366.6
    % This needs mean==1 & variance scaled appropriately, so add & divide mean.
    stellarVariability(j).timeSeries = (solnew + 1366.6)/1366.6; 
    stellarVariability(j).StarRotationPeriod = StellarRotationPeriod;
    stellarVariability(j).ikeep = ikeepnew;

    waitbar(j/Ncurves,handle);

end
close(handle);

return
