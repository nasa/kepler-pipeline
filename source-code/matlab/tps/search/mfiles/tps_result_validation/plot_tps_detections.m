% plot to file parameters
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

function plot_tps_detections(inputsStruct, tpsOutputStruct)


isLandscapeOrientationFlag = true;
includeTimeFlag = false;
printJpgFlag = true;
close all;

nTargets = length(inputsStruct.tpsTargets);
isp = find([tpsOutputStruct.tpsResults.isPlanetACandidate]);
isp = unique(mod(isp,nTargets));

ispResetIndex = find(isp == 0);

if(~isempty(ispResetIndex))
    isp(ispResetIndex) = nTargets;

end

cadencesPerDay = inputsStruct.tpsModuleParameters.cadencesPerDay;

for j = 1:length(isp),

    xaxisInDays = (1:length(inputsStruct.tpsTargets(isp(j)).fluxValue))./cadencesPerDay;

    subplot(2,1,1);

    % do not plot gaps
    
    nCadences = length(xaxisInDays);
    gapIndicators = false(nCadences, 1);
    gapIndicators(inputsStruct.tpsTargets(isp(j)).gapIndices) = true;
    
    
    
    plot(xaxisInDays(~gapIndicators), inputsStruct.tpsTargets(isp(j)).fluxValue(~gapIndicators), '.-'),
    keplerId = inputsStruct.tpsTargets(isp(j)).keplerId;

    orbitalperiodInDays1 = tpsOutputStruct.tpsResults(isp(j)).detectedOrbitalPeriodInDays;
    phaseInDays1 = tpsOutputStruct.tpsResults(isp(j)).timeToFirstTransitInDays;
    maxMultipleEventSigma1 = tpsOutputStruct.tpsResults(isp(j)).maxMultipleEventStatistic;

    orbitalperiodInDays2 = tpsOutputStruct.tpsResults(isp(j)+nTargets).detectedOrbitalPeriodInDays;
    phaseInDays2 = tpsOutputStruct.tpsResults(isp(j)+nTargets).timeToFirstTransitInDays;
    maxMultipleEventSigma2 = tpsOutputStruct.tpsResults(isp(j)+nTargets).maxMultipleEventStatistic;

    orbitalperiodInDays3 = tpsOutputStruct.tpsResults(isp(j)+2*nTargets).detectedOrbitalPeriodInDays;
    phaseInDays3 = tpsOutputStruct.tpsResults(isp(j)+2*nTargets).timeToFirstTransitInDays;
    maxMultipleEventSigma3 = tpsOutputStruct.tpsResults(isp(j)+2*nTargets).maxMultipleEventStatistic;


    titleStr1 = [' target keplerId = ' num2str(keplerId)];
    titleStr2 = ['1 hr trial transit: period (days) = ' num2str(orbitalperiodInDays1),  '; phase(days) = ', num2str(phaseInDays1) ' multiple event sigma = ', num2str(maxMultipleEventSigma1)];
    titleStr3 = ['2 hr trial transit: period (days) = ' num2str(orbitalperiodInDays2),  '; phase(days) = ', num2str(phaseInDays2) ' multiple event sigma = ', num2str(maxMultipleEventSigma2)];
    titleStr4 = ['3 hr trial transit: period (days) = ' num2str(orbitalperiodInDays3),  '; phase(days) = ', num2str(phaseInDays3) ' multiple event sigma = ', num2str(maxMultipleEventSigma3)];


    xlabel(['in days (' num2str(cadencesPerDay)  ' cadences /day)']);
    ylabel('in photo electrons');

    titleStr = num2str(keplerId);
    title({titleStr1;titleStr2; titleStr3; titleStr4});



    subplot(2,1,2);
    medianFlux = median(inputsStruct.tpsTargets(isp(j)).fluxValue);

    relativeFlux = (inputsStruct.tpsTargets(isp(j)).fluxValue - medianFlux)./medianFlux;

    plot(xaxisInDays(~gapIndicators), relativeFlux(~gapIndicators), '.-'),
    title(['Relative flux time series kepler Id = ' num2str(keplerId)]);



    plot_to_file(titleStr, isLandscapeOrientationFlag, includeTimeFlag, printJpgFlag);

end
close all;