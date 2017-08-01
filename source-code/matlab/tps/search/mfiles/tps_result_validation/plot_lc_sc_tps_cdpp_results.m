% scLcCdpp(1)
% ans =
%                keplerId: 8832417
%               keplerMag: 13.0509996414185
%               ccdModule: 19
%               ccdOutput: 3
%     cdppSc6hrTimeSeries: [14280x1 double]
%            cdppSc6hrRms: 607.884700295744
%     cdppLc6hrTimeSeries: [476x1 double]
%            cdppLc6hrRms: 12871.5817650552
%        fluxTimeSeriesSc: [14280x1 double]
%            gapIndicesSc: [496x1 double]
%        fluxTimeSeriesLc: [476x1 double]
%            gapIndicesLc: []
%             tpsLcRunDir: 'tps-matlab-108-6958'
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


%plot_lc_sc_tps_cdpp_results.m

% plot to file parameters
isLandscapeOrientationFlag = true;
includeTimeFlag = false;
printJpgFlag = true;

%S
close all;
clc;

nScTargets = length(scLcCdpp);

for j = 1:nScTargets
    disp(j)

    keplerId = scLcCdpp(j).keplerId;
    keplerMag = scLcCdpp(j).keplerMag;

    fluxTimeSeriesSc = scLcCdpp(j).fluxTimeSeriesSc;
    gapIndicesSc = scLcCdpp(j).gapIndicesSc;

    nCadencesSc = length(fluxTimeSeriesSc);
    gapIndicatorsSc = false(nCadencesSc,1);
    gapIndicatorsSc(gapIndicesSc) = true;


    fluxTimeSeriesLc = scLcCdpp(j).fluxTimeSeriesLc;
    gapIndicesLc = scLcCdpp(j).gapIndicesLc;

    nCadencesLc = length(fluxTimeSeriesLc);
    gapIndicatorsLc = false(nCadencesLc,1);
    gapIndicatorsLc(gapIndicesLc) = true;




    subplot(2,2,1);
    plot(find(~gapIndicatorsSc), fluxTimeSeriesSc(~gapIndicatorsSc), '.-');
    xlabel('SC');
    ylabel('photo electrons')
    title({ 'SC flux time series'; [num2str(keplerId)  ' '  num2str(keplerMag)]});


    subplot(2,2,2);

    cdppSc6hrTimeSeries =  scLcCdpp(j).cdppSc6hrTimeSeries;
    plot(cdppSc6hrTimeSeries, '.-');
    xlabel('SC');
    ylabel('ppm')
    title({ 'SC 6 hour CDPP time series'; [num2str(keplerId)  ' '  num2str(keplerMag)]});

    subplot(2,2,3);
    plot(find(~gapIndicatorsLc), fluxTimeSeriesLc(~gapIndicatorsLc), '.-');
    xlabel('LC');
    ylabel('photo electrons')
    title({ 'LC flux time series'; [num2str(keplerId)  ' '  num2str(keplerMag)]});


    subplot(2,2,4);

    cdppLc6hrTimeSeries =  scLcCdpp(j).cdppLc6hrTimeSeries;
    plot(cdppLc6hrTimeSeries, '.-');
    xlabel('LC');
    ylabel('ppm')
    title({ 'LC 6 hour CDPP time series'; [num2str(keplerId)  ' '  num2str(keplerMag)]});

    titleStr = ['LC SC CDPP time series ' num2str(keplerId) ' ' num2str(keplerMag)];



    plot_to_file(titleStr, isLandscapeOrientationFlag, includeTimeFlag, printJpgFlag);


end

return;
%%
nScTargets = length(scLcCdpp);

fid = fopen('lc_sc_cdpp.txt', 'wt');

fprintf(fid, '|--------------------------------------------------------------------------------------|\n');
fprintf(fid, '| Kepler Id | Kepler Magnitude | LC 6 hour CDPP | SC 6 hour CDPP | rmsCdppSc/rmsCdppLc |\n');
fprintf(fid, '|           |                  |    in ppm      |    in ppm      |                     |\n');
fprintf(fid, '|--------------------------------------------------------------------------------------|\n');

for j = 1:nScTargets

    fprintf(fid, '|%10d |   %10.4f     |   %10.2f   |  %10.2f    |     %10.3f      |\n',scLcCdpp(j).keplerId, scLcCdpp(j).keplerMag, ...
        scLcCdpp(j).cdppLc6hrRms, scLcCdpp(j).cdppSc6hrRms, scLcCdpp(j).cdppSc6hrRms./scLcCdpp(j).cdppLc6hrRms);
fprintf(fid, '|           |                  |                |                |                     |\n');
end
fprintf(fid, '|--------------------------------------------------------------------------------------|\n');

