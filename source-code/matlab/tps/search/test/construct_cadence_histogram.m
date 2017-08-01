function [outlierStruct,cadencesToOutput, numMaxMesAtCadences]  = construct_cadence_histogram(tceStruct, ...
    inputsStruct, dynamicallyUpdateFlag, targetIndicator, useCINFlag, ...
    generateOutlierStruct)

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function outlierStruct = construct_cadence_histogram(tceStruct, ...
%     inputsStruct, targetIndicator)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
% Inputs:
%        1) tceStruct:  The tceStruct constructed from the tpsDawgStruct
%        2) inputsStruct:  A dummy TPS input from the run
%        3) dynamicallyUpdateFlag: boolean to specify whether the plot
%        should be dynamically updated.  It takes longer to plot if
%        dynamically updating.
%        4) targetIndicator: A logical vector equal in length to
%        tceStruct.keplerId that tells which targets to use for the
%        construction of the cadence histogram - typically this would be
%        all the TCE's or a set of false alarms.
%        5) useCINFlag: if true, the x-axis will be CIN.  If false, it will
%        be in KJD.
%        6) generateOutlierStruct: if true, generate the output.
%
% Outputs:
%         outlierStruct: A struct that contains information for the points
%         above various sigma cuts such as the associated kepler Id's, the
%         number of targets contributing, the number of points above x
%         sigma, and the outlier cadence numbers.
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
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



pipelineDurations = tceStruct.pulseDurations;
numTces = sum(targetIndicator);

epochs = tceStruct.epochKjd(targetIndicator);
periods = tceStruct.periodDays(targetIndicator);
pulseNumbers = tceStruct.maxMesPulseNumber(targetIndicator);
gapIndicators  = inputsStruct.cadenceTimes.gapIndicators ;
midTimeStamps = inputsStruct.cadenceTimes.midTimestamps;

% interpolate across gaps
midTimeStamps(gapIndicators) = interp1( find(~gapIndicators), ...
    midTimeStamps(~gapIndicators), find(gapIndicators), 'linear', 'extrap');
midTimeStamps = midTimeStamps - kjd_offset_from_mjd;
cadenceNumbers = inputsStruct.cadenceTimes.cadenceNumbers;
numCadences = length(cadenceNumbers);

numMaxMesAtCadences = zeros(numCadences,1);
figure

for i = 1:numTces
    if(periods(i) > 0)
        
        duration=pipelineDurations(pulseNumbers(i))/24;
        phase = mod((midTimeStamps-epochs(i))/periods(i), 1);
        inTransitPhases = duration/periods(i);
        phasesInTransit = (phase <= inTransitPhases) | (phase > (1-inTransitPhases));
    else
        phasesInTransit = abs(midTimeStamps-epochs(i)) < (0.5*duration);
    end
    
    numMaxMesAtCadences = numMaxMesAtCadences + phasesInTransit;

    % update plot if we are dynamically plotting
    if dynamicallyUpdateFlag
        if useCINFlag
            semilogy(cadenceNumbers, numMaxMesAtCadences, '.')
        else
            semilogy(midTimeStamps,numMaxMesAtCadences,'.')
        end
        drawnow
    end
end

if useCINFlag
    semilogy(cadenceNumbers, numMaxMesAtCadences, '.')
    cadencesToOutput = cadenceNumbers;
else
    semilogy(midTimeStamps,numMaxMesAtCadences,'.')
    cadencesToOutput = midTimeStamps;
end
drawnow

% highlight cadences above the average

medianNumber = median(numMaxMesAtCadences);
stdNumber = std(numMaxMesAtCadences);

hold on
if useCINFlag
    plot(cadenceNumbers(abs(numMaxMesAtCadences-medianNumber) > 2*stdNumber), ...
        numMaxMesAtCadences(abs(numMaxMesAtCadences-medianNumber) > 2*stdNumber), 'g.')
    plot(cadenceNumbers(abs(numMaxMesAtCadences-medianNumber) > 3*stdNumber), ...
        numMaxMesAtCadences(abs(numMaxMesAtCadences-medianNumber) > 3*stdNumber), 'r.')
    xlabel('Time (CIN)')
else
    plot(midTimeStamps(abs(numMaxMesAtCadences-medianNumber) > 2*stdNumber), ...
        numMaxMesAtCadences(abs(numMaxMesAtCadences-medianNumber) > 2*stdNumber), 'g.')
    plot(midTimeStamps(abs(numMaxMesAtCadences-medianNumber) > 3*stdNumber), ...
        numMaxMesAtCadences(abs(numMaxMesAtCadences-medianNumber) > 3*stdNumber), 'r.')
    xlabel('Time (KJD)')
end 

ylabel('Counts')
title(['Histogram of Cadences Contributing to MES'])
legend('All points', 'Outliers > 2sigma', 'Outliers > 3sigma')
hold off

% Now generate the struct with outlier information
if generateOutlierStruct
    fprintf('Generating outlier information struct...Please continue waiting.\n');
    sigmaFactors=[1,2,3,4,5];
    tces = find(targetIndicator);
    for j=1:length(sigmaFactors)
        counter=0;
        indicator=numMaxMesAtCadences-medianNumber > sigmaFactors(j)*stdNumber;
        numRedPoints = length(midTimeStamps(numMaxMesAtCadences-medianNumber > sigmaFactors(j)*stdNumber));
        redKeplerIdTemp=[];
        for i = 1:numTces
            if(periods(i) > 0)
                duration=pipelineDurations(pulseNumbers(i))/24;
                phase = mod((midTimeStamps-epochs(i))/periods(i), 1);
                inTransitPhases = duration/periods(i);

                phasesInTransit = (phase <= inTransitPhases) | (phase > (1-inTransitPhases));

            else
                phasesInTransit = abs(midTimeStamps-epochs(i)) < (0.5*duration);

            end

            if sum(ismember(find(phasesInTransit),find(indicator)))>0
                counter=counter+1;
                redKeplerIdTemp(counter)=tceStruct.keplerId(tces(i));
                redKeplerIdTemp=redKeplerIdTemp(:);
            end
        end
        outlierStruct.sigmaFactor(j) = sigmaFactors(j);
        outlierStruct.keplerIdsOfContributors(j).values=redKeplerIdTemp;
        outlierStruct.numTCEsContributing(j)=counter;
        outlierStruct.numRedPoints(j)=numRedPoints;
        outlierStruct.redCadencesNumbers(j).values = cadenceNumbers(indicator);
    end
end

return
