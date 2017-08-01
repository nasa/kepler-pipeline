function plot_MaxMES_cadences(tpsDawgStruct,inputsStruct,pulseDuration)
%function plot_MaxMES_cadences(tpsDawgStruct,inputsStruct,pulseDuration)
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

% Making it a general solution for any quarter
% The tpsDawgStruct is that compiled by PT's code for the dawging
% The inputsStruct is any PA or PDC inputs file for the timestamps
% Pulse duration is the duration for which the code will find the closest
% duration in the code for that quarter and produce the plot

%  - Extract maxMes:
tmpMaxMes = tpsDawgStruct.maxMes;
%   - Set NaNs to 0
tmpMaxMes(~(tmpMaxMes > 0)) = 0;

%   - Find the closest pulse duration

if(size(tpsDawgStruct.rmsCdpp,2) == 3)
    pipelineDurations = [3 6 12];
else
    if(size(tpsDawgStruct.rmsCdpp,2) == 11)
        pipelineDurations = [1.5 2 2.5 3 4 5 6 7.5 9 12 15];
    else
        if(size(tpsDawgStruct.rmsCdpp,2) == 14)
            pipelineDurations = [1.5 2 2.5 3 3.5 4.5 5 6 7.5 9 10.5 12 12.5 15];
        end
    end
end

[min_difference, array_position] = min(abs(pipelineDurations - pulseDuration))

%   Get the set of TCEs with MaxMES >= 7.1

tces = find(tmpMaxMes(:,array_position) >= 7.1);
numTces = size(tces,1)

epochs = tpsDawgStruct.epochKjd(tces,array_position);%+54832.5;
periods = tpsDawgStruct.periodDays(tces,array_position);
duration = pipelineDurations(array_position)/24.

%    figure
%    plot(epochs,periods,'.', 'MarkerSize', 2)

%   - Get times from inputs file

allcadenceTimes = [inputsStruct.cadenceTimes.midTimestamps];
allcadenceNumbers = [inputsStruct.cadenceTimes.cadenceNumbers];
cadenceTimes = allcadenceTimes(allcadenceTimes > 0)-54832.5;
cadenceNumbers = allcadenceNumbers(allcadenceTimes >0);



numMaxMesAtCadences = zeros(size(cadenceTimes,1),1);

figure

for i = 1:numTces

    if(periods(i) > 0)

        phase = mod((cadenceTimes-epochs(i))/periods(i), 1);
        inTransitPhases = duration/periods(i);

        phasesInTransit = (phase <= inTransitPhases) | (phase > (1-inTransitPhases));

    else

        phasesInTransit = abs(cadenceTimes-epochs(i)) < (0.5*duration);

    end

    numMaxMesAtCadences = numMaxMesAtCadences + phasesInTransit;

    %        plot(cadenceTimes,numMaxMesAtCadences,'.')
    %semilogy(cadenceTimes,numMaxMesAtCadences,'.')
    semilogy(cadenceNumbers, numMaxMesAtCadences, '.')

    drawnow

end

% highlight cadences above the average

medianNumber = median(numMaxMesAtCadences);
stdNumber = std(numMaxMesAtCadences);

hold on
plot(cadenceNumbers(abs(numMaxMesAtCadences-medianNumber) > 1*stdNumber), ...
    numMaxMesAtCadences(abs(numMaxMesAtCadences-medianNumber) > 1*stdNumber), 'r.')

xlabel('CIN')
%xlabel('cadence midtimestamp (MJD-54832.5)')
ylabel('number of MaxMES events that fall here')
title(['distribution of MaxMES events for ' num2str(pipelineDurations(array_position)) ' hour duration'])
legend('All points', 'Outliers > 1sigma')

hold off

return