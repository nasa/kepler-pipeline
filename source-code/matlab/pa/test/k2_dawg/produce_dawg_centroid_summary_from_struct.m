function S = produce_dawg_centroid_summary_from_struct( C )
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

MADS_FOR_HISTOGRAMS = 8;
HISTOGRAM_DEFAULT_BINS = 51;
HISTOGRAM_BIN_FACTOR = 500;

% P1 = [1125   240   760   375];
P2 = [1125   705   760   375];

fig_filenames = {'median_centroid_sd_and_rms_uncertainty',...
                 'flux_weighted_SD_vs_magnitude',...
                 'flux_weighted_uncertainty_vs_magnitude',...
                 'prf_SD_vs_magnitude',...
                 'prf_uncertainty_vs_magnitude',...
                 'standard_deviation_col_vs_row',...
                 'uncertainty_col_vs_row',...
                 'flux_weighted_centroid_sd_dist',...
                 'flux_weighted_centroid_unc_dist',...
                 'prf_centroid_sd_dist',...
                 'prf_weighted_centroid_unc_dist'};

% count the channels
nChannels = numel(C);
                 
% initialize summary structure
S(nChannels+1) = C(1);
S = S(1:nChannels);
                    
% Produce summary metrics for each channel.
% median, max, min, mad of the normalized flux, uncertainty over shot noise
% and uncertainty over standard deviation
for i=1:length(C)  
    
    ccdModule = C(i).ccdModule;
    ccdOutput = C(i).ccdOutput;
    
    if( i <= length(C) && ~isempty(ccdModule) && ~isempty(ccdOutput) )
        
        % populate summary metrics
        S(i).ccdModule = ccdModule;
        S(i).ccdOutput = ccdOutput;

        S(i).rowStdFw       = nanmedian(C(i).rowStdFw(C(i).rowStdFw>0));
        S(i).colStdFw       = nanmedian(C(i).colStdFw(C(i).colStdFw>0));
        S(i).rowUncRmsFw    = nanmedian(C(i).rowUncRmsFw(C(i).rowUncRmsFw>0));
        S(i).colUncRmsFw    = nanmedian(C(i).colUncRmsFw(C(i).colUncRmsFw>0));
        S(i).rowStdPrf      = nanmedian(C(i).rowStdPrf(C(i).rowStdPrf>0));
        S(i).colStdPrf      = nanmedian(C(i).colStdPrf(C(i).colStdPrf>0));
        S(i).rowUncRmsPrf   = nanmedian(C(i).rowUncRmsPrf(C(i).rowUncRmsPrf>0));
        S(i).colUncRmsPrf   = nanmedian(C(i).colUncRmsPrf(C(i).colUncRmsPrf>0));     
   end
end


% plot the summary metrics
close all;
plot_dawg_centroid_metrics( S );

% aggregate metrics output for all targets on all channels
keplerId        = [C.keplerId];                                         %#ok<NASGU>
keplerMag       = [C.keplerMag];
rowStdFw        = [C.rowStdFw];
colStdFw        = [C.colStdFw];
rowUncRmsFw     = [C.rowUncRmsFw];
colUncRmsFw     = [C.colUncRmsFw];
rowStdPrf       = [C.rowStdPrf];
colStdPrf       = [C.colStdPrf];
rowUncRmsPrf    = [C.rowUncRmsPrf];
colUncRmsPrf    = [C.colUncRmsPrf];


% produce scatter plots

% flux weighted SD vs kepler mag
figure;
plot(keplerMag,rowStdFw,'.','MarkerSize',4);
hold on;
plot(keplerMag,colStdFw,'r.','MarkerSize',4);
hold off;
grid;
ylabel('\bf\fontsize{12}Standard Deviation (pixels)');
xlabel('\bf\fontsize{12}Kepler Magnitude');
title('\bf\fontsize{12}Flux Weighted Centroid Standard Deviation');
legend('row','column');
set(gcf,'Position',P2);

% flux weighted uncertainty vs kepler mag
figure;
plot(keplerMag,rowUncRmsFw,'.','MarkerSize',4);
hold on;
plot(keplerMag,colUncRmsFw,'r.','MarkerSize',4);
hold off;
grid;
ylabel('\bf\fontsize{12}RMS Uncertainty (pixels)');
xlabel('\bf\fontsize{12}Kepler Magnitude');
title('\bf\fontsize{12}Flux Weighted Centroid Uncertainty');
legend('row','column');
set(gcf,'Position',P2);

% PRF SD vs kepler mag
figure;
plot(keplerMag,rowStdPrf,'.','MarkerSize',4);
hold on;
plot(keplerMag,colStdPrf,'r.','MarkerSize',4);
hold off;
grid;
ylabel('\bf\fontsize{12}Standard Deviation (pixels)');
xlabel('\bf\fontsize{12}Kepler Magnitude');
title('\bf\fontsize{12}PRF Centroid Standard Deviation');
legend('row','column');
set(gcf,'Position',P2);

% PRF uncertainty vs kepler mag
figure;
plot(keplerMag,rowUncRmsPrf,'.','MarkerSize',4);
hold on;
plot(keplerMag,colUncRmsPrf,'r.','MarkerSize',4);
hold off;
grid;
ylabel('\bf\fontsize{12}RMS Uncertainty (pixels)');
xlabel('\bf\fontsize{12}Kepler Magnitude');
title('\bf\fontsize{12}PRF Centroid Uncertainty');
legend('row','column');
set(gcf,'Position',P2);

% column vs row SD
figure;
plot(colStdFw,rowStdFw,'.','MarkerSize',4);
hold on;
plot(colStdPrf,rowStdPrf,'r.','MarkerSize',4);
hold off;
grid;
ylabel('\bf\fontsize{12}Row SD (pixels)');
xlabel('\bf\fontsize{12}Column SD (pixels)');
title('\bf\fontsize{12}Centroid Standard Deviation');
legend('flux weighted','PRF');
set(gcf,'Position',P2);

% column vs row uncertainty
figure;
plot(colUncRmsFw,rowUncRmsFw,'.','MarkerSize',4);
hold on;
plot(colUncRmsPrf,rowUncRmsPrf,'r.','MarkerSize',4);
hold off;
grid;
ylabel('\bf\fontsize{12}Row Uncertainty (pixels)');
xlabel('\bf\fontsize{12}Column Uncertainty (pixels)');
title('\bf\fontsize{12}Centroid Uncertainty');
legend('flux weighted','PRF');
set(gcf,'Position',P2);




% produce summary distributions
stdFw = sqrt(rowStdFw.^2 + colStdFw.^2);
uncRmsFw = sqrt(rowUncRmsFw.^2 + colUncRmsFw.^2);
stdPrf = sqrt(rowStdPrf.^2 + colStdPrf.^2);
uncRmsPrf = sqrt(rowUncRmsPrf.^2 + colUncRmsPrf.^2);

% targets with no centroid produced will have a value of zero for the sd and rms unc
% omit these targets in distributions
stdFw = stdFw(stdFw>0);
uncRmsFw = uncRmsFw(uncRmsFw>0);
stdPrf = stdPrf(stdPrf>0);
uncRmsPrf = uncRmsPrf(uncRmsPrf>0);

figure;
madData = mad(stdFw,1);
medianData = nanmedian(stdFw);
% maxData = max(Ftotal.normalizedFlux);
% minData = min(Ftotal.normalizedFlux);
idx = (stdFw - medianData) < MADS_FOR_HISTOGRAMS * madData;
nData = length(stdFw(idx));
hist(stdFw(idx),max([HISTOGRAM_DEFAULT_BINS, floor(nData/HISTOGRAM_BIN_FACTOR)]));
grid;
ylabel('\bf\fontsize{12}count');
xlabel('\bf\fontsize{12}Standard Deviation (pixels)');
title('\bf\fontsize{12}Flux Weighted Centroid Standard Deviation [sqrt(rowSD^2 + colSD^2)]');
set(gcf,'Position',P2);

figure;
madData = mad(uncRmsFw,1);
medianData = nanmedian(uncRmsFw);
% maxData = max(Ftotal.normalizedFlux);
% minData = min(Ftotal.normalizedFlux);
idx = (uncRmsFw - medianData) < MADS_FOR_HISTOGRAMS * madData;
nData = length(uncRmsFw(idx));
hist(uncRmsFw(idx),max([HISTOGRAM_DEFAULT_BINS, floor(nData/HISTOGRAM_BIN_FACTOR)]));
grid;
ylabel('\bf\fontsize{12}count');
xlabel('\bf\fontsize{12}RMS Uncertainty (pixels)');
title('\bf\fontsize{12}Flux Weighted Centroid Uncertainty [sqrt(rowUnc^2 + colUnc^2)]');
set(gcf,'Position',P2);

figure;
madData = mad(stdPrf,1);
medianData = nanmedian(stdPrf);
% maxData = max(Ftotal.normalizedFlux);
% minData = min(Ftotal.normalizedFlux);
idx = (stdPrf - medianData) < MADS_FOR_HISTOGRAMS * madData;
nData = length(stdPrf(idx));
hist(stdPrf(idx),max([HISTOGRAM_DEFAULT_BINS, floor(nData/HISTOGRAM_BIN_FACTOR)]));
grid;
ylabel('\bf\fontsize{12}count');
xlabel('\bf\fontsize{12}Standard Deviation (pixels)');
title('\bf\fontsize{12}PRF Centroid Standard Deviation [sqrt(rowSD^2 + colSD^2)]');
set(gcf,'Position',P2);

figure;
madData = mad(uncRmsPrf,1);
medianData = nanmedian(uncRmsPrf);
% maxData = max(Ftotal.normalizedFlux);
% minData = min(Ftotal.normalizedFlux);
idx = (uncRmsPrf - medianData) < MADS_FOR_HISTOGRAMS * madData;
nData = length(uncRmsPrf(idx));
hist(uncRmsPrf(idx),max([HISTOGRAM_DEFAULT_BINS, floor(nData/HISTOGRAM_BIN_FACTOR)]));
grid;
ylabel('\bf\fontsize{12}count');
xlabel('\bf\fontsize{12}RMS Uncertainty (pixels)');
title('\bf\fontsize{12}PRF Centroid Uncertainty [sqrt(rowUnc^2 + colUnc^2)]');
set(gcf,'Position',P2);

% save plots to local directory
for i=1:length(fig_filenames)
    figure(i);
    saveas(gcf,fig_filenames{i},'fig');
end

