
function [detrendedFlux, maxDetrendPolyOrder, fittedTrend] = detrend_target_flux_for_harmonics_fit(targetFluxArray, gapIndicatorsArray, dataAnomalyIndicators, conditionedAncillaryDataStruct)
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

[nCadences, nTargets]  = size(targetFluxArray);

if(~isempty(dataAnomalyIndicators))

    attitudeTweakCadences = find(dataAnomalyIndicators.attitudeTweakIndicators);

    if(~isempty(attitudeTweakCadences))

        nTweaks = length(attitudeTweakCadences);

        stepTimeSeries = zeros(nCadences, nTweaks);

        for jTweak = 1:nTweaks

            stepTimeSeries(attitudeTweakCadences(jTweak):end, jTweak) = 1;

        end
    else
        stepTimeSeries = [];
    end

end



if(~isempty(conditionedAncillaryDataStruct))

    nAncillaryTypes = length(conditionedAncillaryDataStruct);

    ancillaryTimeSeries = zeros(nCadences, nAncillaryTypes);

    for jType = 1:nAncillaryTypes

        tempTimeSeries = conditionedAncillaryDataStruct(jType).ancillaryTimeSeries.values;
        ancillaryTimeSeries(:, jType) = tempTimeSeries;

    end
else
    ancillaryTimeSeries = [];
end

t = (1:nCadences)'./nCadences;
tSquared = t.^2;

detrendedFlux = zeros(nCadences, nTargets);
maxDetrendPolyOrder = zeros(nTargets,1);
fittedTrend = zeros(nTargets,1);

dataAnomalyIndicators2 = dataAnomalyIndicators;
dataAnomalyIndicators2.attitudeTweakIndicators(:) = false;
dataAnomalyIndicators2.safeModeIndicators(:) = false;
dataAnomalyIndicators2.coarsePointIndicators(:) = false;
dataAnomalyIndicators2.argabrighteningIndicators(:) = false;
dataAnomalyIndicators2.excludeIndicators(:) = false;




for jTarget = 1:nTargets

    %fprintf('%d/%d\n', jTarget, nTargets)

    originalTimeSeries = targetFluxArray(:, jTarget);
    gapIndicators = gapIndicatorsArray(:, jTarget);


    designMatrix = [ancillaryTimeSeries stepTimeSeries ones(nCadences,1) t tSquared ];
    warning  off all;

    wtCoeffts = lscov(designMatrix(~gapIndicators,:),originalTimeSeries(~gapIndicators));
    warning  on all;


    maxDetrendPolyOrder(jTarget) = max(find(wtCoeffts(end-2:end))~= 0) - 1;

    fittedTrend(~gapIndicators, jTarget) = designMatrix(~gapIndicators,:)*wtCoeffts;

    detrendedFlux(~gapIndicators, jTarget) = originalTimeSeries(~gapIndicators) - designMatrix(~gapIndicators,:)*wtCoeffts;



    residualTimeSeries = originalTimeSeries;
    residualTimeSeries(~gapIndicators) = originalTimeSeries(~gapIndicators) - (designMatrix(~gapIndicators,:)*wtCoeffts);

    discontinuityStruct = detect_regime_shift(residualTimeSeries, gapIndicators,dataAnomalyIndicators2);

    if(discontinuityStruct.foundDiscontinuity)

        % do a simple detrend
        designMatrix = [ones(nCadences,1) t tSquared ];

        warning  off all;
        wtCoeffts = lscov(designMatrix(~gapIndicators,:),originalTimeSeries(~gapIndicators));
        warning  on all;
        fittedTrend(~gapIndicators, jTarget) = designMatrix(~gapIndicators,:)*wtCoeffts;

        detrendedFlux(~gapIndicators, jTarget) = originalTimeSeries(~gapIndicators) - designMatrix(~gapIndicators,:)*wtCoeffts;


        maxDetrendPolyOrder(jTarget) = max(find(wtCoeffts(end-2:end))~= 0) - 1;


        %detrendedFlux(~gapIndicators, jTarget) = originalTimeSeries(~gapIndicators);
        %residualTimeSeries(~gapIndicators) = originalTimeSeries(~gapIndicators);
    end

    %     figure; plot(find(~gapIndicators), [originalTimeSeries(~gapIndicators)  designMatrix(~gapIndicators,:)*wtCoeffts], '.-')
    %     residualTimeSeries(~gapIndicators) =   detrendedFlux(~gapIndicators, jTarget);
    %     figure; plot(find(~gapIndicators), residualTimeSeries(~gapIndicators),'.-')
    %
    %     originalTimeSeries(~gapIndicators) = residualTimeSeries(~gapIndicators);
    %     tic
    %     [harmonicsRemovedTimeSeries, harmonicTimeSeries] = ...
    %         identify_and_remove_phase_shifting_harmonics(originalTimeSeries, gapIndicators);
    %     toc
    %     if(~isempty(harmonicTimeSeries))
    %         hold on;
    %         plot(find(~gapIndicators), harmonicTimeSeries(~gapIndicators), 'r.-')
    %
    %
    %         figure; plot(find(~gapIndicators), [originalTimeSeries(~gapIndicators)  -  harmonicTimeSeries(~gapIndicators)])
    %         originalTimeSeries0 = targetFluxArray(:, jTarget);
    %
    %         figure; plot(find(~gapIndicators), [originalTimeSeries0(~gapIndicators)  -  harmonicTimeSeries(~gapIndicators)])
    %
    %     end
    %
    %     fprintf('')
    %     close all;

end
