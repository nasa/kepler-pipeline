function create_star_music(keplerIdList)
% create_star_music.m
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
clc;

%starId = 12218858;
%starId = 7583208;
%starId = 8647777;


load pdcKeplerIdStruct.mat


for iStar = 1:length(keplerIdList)

    starId = keplerIdList(iStar);

    disp(starId)

    foundTarget = false;


    for j=1:84;
        if(~isempty(intersect(pdcKeplerIdStruct(j).keplerId, starId)))
            modOut = j;
            foundTarget = true;
            break;
        end;
    end

    if(~foundTarget)
        continue;
    end


    eval(['cd ' pdcKeplerIdStruct(modOut).pdcRunDir]);


    targetIndex = find(pdcKeplerIdStruct(modOut).keplerId ==starId);


    load pdc-inputs-0.mat
    load pdc-outputs-0.mat

    desatGapIndices = [];

    filledIndices = outputsStruct.targetResultsStruct(targetIndex).correctedFluxTimeSeries.filledIndices;
    gapIndices = find(outputsStruct.targetResultsStruct(targetIndex).correctedFluxTimeSeries.gapIndicators); % 0 - based indexing
    outlierIndices = (outputsStruct.targetResultsStruct(targetIndex).outliers.indices) ;

    gapIndices =  sort([desatGapIndices; gapIndices; filledIndices+1; outlierIndices+1]);

    paFluxTimeSeries = inputsStruct.targetDataStruct(targetIndex).values;

    nCadences = length(paFluxTimeSeries);

    gapIndicators = false(nCadences,1);

    gapIndicators(gapIndices) = true;

    % fil gapIndicators
    debugFlag = false;
    gapFillParametersStruct = inputsStruct.gapFillConfigurationStruct;

    gapFillParametersStruct.cadenceDurationInMinutes = median(abs(diff(inputsStruct.cadenceTimes.startTimestamps)))*24*60;

    paFluxTimeSeries = fill_short_data_gaps(paFluxTimeSeries, gapIndicators, ...
        debugFlag, gapFillParametersStruct);

    gapIndicators = false(nCadences,1);

    % now detrend pre-PDC flux time series and gap fill;

    nTimeSteps = (1:nCadences)';
    indexOfAvailable = find(~gapIndicators);
    maxDetrendPolyOrder = 5;
    [fittedTrend, fittedPolyOrder,polynomialCoefficients, structureS, scalingCenteringMu] = ...
        fit_trend(nTimeSteps, indexOfAvailable,  paFluxTimeSeries,  maxDetrendPolyOrder);

    paFluxTimeSeries(indexOfAvailable) = paFluxTimeSeries(indexOfAvailable) - fittedTrend(indexOfAvailable);

    medianFlux = median(paFluxTimeSeries);
    relativeFluxTimeSeries = (paFluxTimeSeries - medianFlux)./medianFlux;



    % extract harmonics

    [harmonicsRemovedTimeSeries, harmonicTimeSeries, indexOfGiantTransits, harmonicModelStruct] = ...
        identify_and_remove_phase_shifting_harmonics(relativeFluxTimeSeries, gapIndicators, gapFillParametersStruct);

    nSamplesLong = 61320;

    if(~isempty(harmonicModelStruct.harmonicFrequenciesInHz))
        harmonicTimeSeries = build_harmonic_time_series_from_model(harmonicModelStruct, nSamplesLong);
    else
        fprintf('no harmonics found for star %d\n', starId);
    end


    cd ..

    fileNameStr = ['harmonics_keplerId_' num2str(starId) '.mat'];

    pdcRunDir = pdcKeplerIdStruct(modOut).pdcRunDir;


    eval(['save ' fileNameStr ' harmonicModelStruct relativeFluxTimeSeries medianFlux harmonicTimeSeries starId pdcRunDir']);


    wavFileNameStr = ['harmonics_keplerId_' num2str(starId) '.wav'];

    wavwrite(harmonicTimeSeries, wavFileNameStr);


end
