%plot_tps_input_flux_for_tce.m
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

function plot_tps_input_flux_for_tce(inputsStruct, outputsStruct)


clc;
close all;

% outputsStruct = read_TpsOutputs('tps-outputs-0.bin');
% inputsStruct = inputsStructSmall;
% outputsStruct = outputStructSmall;

% if x axis has to be in days, uncomment the following code

% cadenceTimeStamps = cat(1, inputsStruct.cadenceTimes.midTimestamps);
% cadenceDurationInMinutes = ( (diff(cadenceTimeStamps)*24*60)); % in
% cadencesPerDay = (24*60)/cadenceDurationInMinutes;




ispIndex = find([outputsStruct.tpsResults.isPlanetACandidate]);

nResults = length(outputsStruct.tpsResults);

nTargets = length(inputsStruct.tpsTargets);


ispIndex = unique(mod(ispIndex, nTargets));

zeroIndex = find(ispIndex == 0);
if(~isempty(zeroIndex))
    ispIndex(zeroIndex) = nTargets;
    ispIndex = sort(ispIndex);
end



for j = ispIndex(:)'

    gapIndices = inputsStruct.tpsTargets(j).gapIndices;
    fillIndices = inputsStruct.tpsTargets(j).fillIndices;
    outlierIndices = inputsStruct.tpsTargets(j).outlierIndices;

    allGapIndices = [gapIndices(:); fillIndices(:); outlierIndices(:)];
    allGapIndices = allGapIndices+1;

    flux = inputsStruct.tpsTargets(j).fluxValue;

    %----------------------------------------------------------------------
    % figure 1
    %----------------------------------------------------------------------
    h1 = plot(flux, '.-');
    hold on;

    h2 = plot(allGapIndices, flux(allGapIndices), 'mo');
    hold on;
    legend([h1; h2], {'input flux time series '; 'gaps'});

    keplerId = inputsStruct.tpsTargets(j).keplerId;
    keplerMag = inputsStruct.tpsTargets(j).diagnostics.keplerMag;

    % find out which trial period led to max(maxMultipleEventStatistics)
    targetIndex = (j:nTargets:nResults)';
    [maxMes, maxIndex] = max(cat(1, outputsStruct.tpsResults(j:nTargets:nResults).maxMultipleEventStatistic));

    index = targetIndex(maxIndex);
    period = outputsStruct.tpsResults(index).detectedOrbitalPeriodInDays;
    phase =  outputsStruct.tpsResults(index).timeToFirstTransitInDays;
    module = inputsStruct.tpsTargets(j).diagnostics.ccdModule;
    output = inputsStruct.tpsTargets(j).diagnostics.ccdOutput;

    matchedFilterUsed = outputsStruct.tpsResults(j).matchedFilterUsed;
    if(matchedFilterUsed)
        titleStr1 = sprintf('Kepler Id = %d, KeplerMag = %5.2f, Mod/Out = %d/%d, Simple Matched Filter', keplerId, keplerMag, module, output);
    else
        titleStr1 = sprintf('Kepler Id = %d, KeplerMag = %5.2f, Mod/Out = %d/%d, Wavelet Matched Filter', keplerId, keplerMag, module, output);

    end
    %   titleStr2 = sprintf('Period(days) = %5.2f, Phase(days) = %5.2f', period, phase);



    orbitalperiodInDays1 = outputsStruct.tpsResults(j).detectedOrbitalPeriodInDays;
    phaseInDays1 = outputsStruct.tpsResults(j).timeToFirstTransitInDays;
    maxMultipleEventSigma1 = outputsStruct.tpsResults(j).maxMultipleEventStatistic;

    orbitalperiodInDays2 = outputsStruct.tpsResults(j+nTargets).detectedOrbitalPeriodInDays;
    phaseInDays2 = outputsStruct.tpsResults(j+nTargets).timeToFirstTransitInDays;
    maxMultipleEventSigma2 = outputsStruct.tpsResults(j+nTargets).maxMultipleEventStatistic;

    orbitalperiodInDays3 = outputsStruct.tpsResults(j+2*nTargets).detectedOrbitalPeriodInDays;
    phaseInDays3 = outputsStruct.tpsResults(j+2*nTargets).timeToFirstTransitInDays;
    maxMultipleEventSigma3 = outputsStruct.tpsResults(j+2*nTargets).maxMultipleEventStatistic;


    titleStr2 = ['3 hr trial transit: period (days) = ' num2str(orbitalperiodInDays1),  '; phase(days) = ', num2str(phaseInDays1) ' multiple event sigma = ', num2str(maxMultipleEventSigma1)];
    titleStr3 = ['6 hr trial transit: period (days) = ' num2str(orbitalperiodInDays2),  '; phase(days) = ', num2str(phaseInDays2) ' multiple event sigma = ', num2str(maxMultipleEventSigma2)];
    titleStr4 = ['12 hr trial transit: period (days) = ' num2str(orbitalperiodInDays3),  '; phase(days) = ', num2str(phaseInDays3) ' multiple event sigma = ', num2str(maxMultipleEventSigma3)];

    %   titleStr3 = sprintf('Mod/Out = %d/%d',  module, output);
    title({titleStr1; titleStr2; titleStr3; titleStr4})

    xlabel('cadences');

    %xlabel(['in days (' num2str(cadencesPerDay)  ' cadences /day)']);
    ylabel('in photo electrons');

    titleStr5 = 'input flux time series';

    title({titleStr1; titleStr2; titleStr3; titleStr4; titleStr5})



    ha = [];

    ha(1)=gca;

    %----------------------------------------------------------------------
    % figure 2
    %----------------------------------------------------------------------

    if(isfield(outputsStruct.tpsResults(index), 'correlationTimeSeries'))

        ct = outputsStruct.tpsResults(index).correlationTimeSeries;
        nt = outputsStruct.tpsResults(index).normalizationTimeSeries;

        ses = ct./nt;
        figure;
        h1 = plot(ses, '.-');
        hold on;

        sesGapIndicators = outputsStruct.tpsResults(index).deemphasizeAroundSafeModeTweakIndicators;
        sesGapIndicators(sesGapIndicators) = true;

        h2 = plot(find(sesGapIndicators), ses(sesGapIndicators), 'ro');
        legend([h1; h2], {'SES time series '; 'gaps + deemphasized cadences'});


        titleStr5 = 'SES time series';
        title({titleStr1; titleStr2; titleStr3; titleStr4; titleStr5})

        ha(2)=gca;

        linkaxes(ha,'x');

        ht = (outputsStruct.tpsResults(j).harmonicTimeSeries);
    end


    %----------------------------------------------------------------------
    % figure 3
    %----------------------------------------------------------------------
    if(isfield(outputsStruct.tpsResults(index), 'harmonicTimeSeries'))
        if(length(unique(ht)) > 1) % all -1 means no harmonics were extracted from this flux time series

            ft = inputsStruct.tpsTargets(j).fluxValue;
            mft = (ft -median(ft))./median(ft);

            figure;
            h1 = plot( mft, '.-');
            hold on;
            h2 = plot(ht, 'ro-');
            ha(3) = gca;
            linkaxes(ha,'x');

            titleStr5 = 'relative flux time series / harmonic time series in red';
            legend([h1; h2], {'relative flux'; 'harmonic time series'});
            title({titleStr1; titleStr2; titleStr3; titleStr4; titleStr5})

        end
    end


    %----------------------------------------------------------------------
    % figure 4
    %----------------------------------------------------------------------
    if(isfield(outputsStruct.tpsResults(index), 'harmonicTimeSeries'))
        if(length(unique(ht)) > 1) % all -1 means no harmonics were extracted from this flux time series

            figure; plot(mft-ht, '.-')
            titleStr5 = 'residual flux time series';
            title({titleStr1; titleStr2; titleStr3; titleStr4; titleStr5})
            ha(4) = gca;
            linkaxes(ha,'x');

        end
    end

    %----------------------------------------------------------------------
    % figure 5
    %----------------------------------------------------------------------
    figure;
    allGapsIndex = find(sesGapIndicators);

    h1 = plot(outputsStruct.tpsResults(j).cdppTimeSeries, 'r.-');
    hold on;
    plot(allGapsIndex, outputsStruct.tpsResults(j).cdppTimeSeries(allGapsIndex), 'kx');

    hold on; h2 = plot(outputsStruct.tpsResults(j+nTargets).cdppTimeSeries, 'g.-');
    plot(allGapsIndex, outputsStruct.tpsResults(j+nTargets).cdppTimeSeries(allGapsIndex), 'kx');

    hold on; h3 = plot(outputsStruct.tpsResults(j+2*nTargets).cdppTimeSeries, 'm.-');
    h4 = plot(allGapsIndex, outputsStruct.tpsResults(j+2*nTargets).cdppTimeSeries(allGapsIndex), 'kx');

    legend([h1; h2; h3; h4], {'3 hour CDPP'; '6 hour CDPP'; '12 hour CDPP'; 'gaps + deemphasized cadences'});
    titleStr5 = 'CDPP time series';
    title({titleStr1; titleStr2; titleStr3; titleStr4; titleStr5})
    %----------------------------------------------------------------------
    % figure 6
    %----------------------------------------------------------------------
    if(isfield(outputsStruct.tpsResults(index), 'correlationTimeSeries'))

        figure;
        ses = ct./nt;
        titleStr1 = ['histogram of single event statistics for ' num2str(inputsStruct.tpsModuleParameters.trialTransitPulseInHours(maxIndex)) ' hour trial transit'];
        titleStr2 = ['histogram mean = ' num2str(mean(ses)) 'histogram std = ' num2str(std(ses))];
        [binCounts1, binLocations1] = hist(ses, 250);
        h1 = bar(binLocations1, binCounts1, 'b');
        hold on;
        %[binCounts2, binLocations2] = hist(ct(~sesGapIndicators)./nt(~sesGapIndicators), 250);
        binWidth = unique(single(diff(binLocations1)));
        h2 = bar(binLocations1, histc(ct(~sesGapIndicators)./nt(~sesGapIndicators), binLocations1 - binWidth/2), 'r');

        legend([h1(1); h2(1);], {'SES'; 'SES excluding gaps'});
        title({titleStr1; titleStr2})

    end
    pause;
    close all;

end

return

%%
printJpgFlag = true;
paperOrientationFlag = false;
includeTimeFlag = false;

fileNameStr = [num2str(keplerId) ' figure ' num2str(gcf)];
plot_to_file(fileNameStr, paperOrientationFlag, includeTimeFlag, printJpgFlag);

%%


% nTargets = length(inputsStruct.tpsTargets);
% to = tpsIspOutputStruct;
% for j=1:length(ispIndex)
%     index = [j j+nTargets j+nTargets]';
%     mes = [to.tpsResults(index).maxMultipleEventStatistic]';
%     period =  [to.tpsResults(index).detectedOrbitalPeriodInDays]';
%     phase =  [to.tpsResults(index).timeToFirstTransitInDays]';
%     [mes period phase],
%     pause
% end