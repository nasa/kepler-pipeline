function [fluxVals, prfRowVals, prfColumnVals, fwRowVals, fwColumnVals, midTimestamps, targetData] = compare_pa_flux_and_centroids(keplerIds,invocationMap,taskFileDirectory)
% function [fluxVals, prfRowVals, prfColumnVals, fwRowVals, fwColumnVals, midTimestamps, targetData] = compare_pa_flux_and_centroids(keplerIds,invocationMap,taskFileDirectory)
%
% Retrieve and plot the flux and centroid time series for the kepler IDs provided.
%
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

nTargets = length(keplerIds);


% allocate space
timeSeries = struct('values',[],...
                    'uncertainties',[],...
                    'gapIndicators',[]);

fluxArray       = repmat(timeSeries,nTargets,1);
prfRowArray     = fluxArray;
prfColumnArray  = fluxArray;
fwRowArray      = fluxArray;
fwColumnArray   = fluxArray;

targetData = repmat(struct('row',[],...
                            'column',[],...
                            'inOptimalAperture',[],...
                            'labels',[]),nTargets,1);
                        

legendText = cell(nTargets,1);

timestampsGenerated = false;

for iTarget = 1:length(keplerIds)
    
    disp(['Processing target ',num2str(keplerIds(iTarget)),' ...']);
    load([taskFileDirectory,'pa-outputs-',num2str(invocationMap(iTarget)),'.mat']);
    
    legendText{iTarget} = num2str(keplerIds(iTarget));
    
    % extract flux and centroid data from outputsStruct
    targetIndex = find([outputsStruct.targetStarResultsStruct.keplerId]==keplerIds(iTarget));
        
    fluxArray(iTarget)      = outputsStruct.targetStarResultsStruct(targetIndex).fluxTimeSeries;
    prfRowArray(iTarget)    = outputsStruct.targetStarResultsStruct(targetIndex).prfCentroids.rowTimeSeries;
    prfColumnArray(iTarget) = outputsStruct.targetStarResultsStruct(targetIndex).prfCentroids.columnTimeSeries;
    fwRowArray(iTarget)     = outputsStruct.targetStarResultsStruct(targetIndex).fluxWeightedCentroids.rowTimeSeries;
    fwColumnArray(iTarget)  = outputsStruct.targetStarResultsStruct(targetIndex).fluxWeightedCentroids.columnTimeSeries;    
    
    % extract select targetDataStruct
    load([taskFileDirectory,'pa-inputs-',num2str(invocationMap(iTarget)),'.mat']);
    targetData(iTarget).row = [inputsStruct.targetStarDataStruct(targetIndex).pixelDataStruct.ccdRow];
    targetData(iTarget).column = [inputsStruct.targetStarDataStruct(targetIndex).pixelDataStruct.ccdColumn];
    targetData(iTarget).inOptimalAperture = [inputsStruct.targetStarDataStruct(targetIndex).pixelDataStruct.inOptimalAperture];
    targetData(iTarget).labels = inputsStruct.targetStarDataStruct(targetIndex).labels;
    
    % extract timestamps from inputsStruct (only do this once)
    if( ~timestampsGenerated )        
        midTimestamps = inputsStruct.cadenceTimes.midTimestamps;
        timeGaps = inputsStruct.cadenceTimes.gapIndicators;
        midTimestamps(timeGaps) = NaN;        
        timestampsGenerated = true;
    end    
end


% build 2D array output and set gaps to NaN
fluxVals = [fluxArray.values];
fluxGaps = [fluxArray.gapIndicators];
fluxVals(fluxGaps) = NaN;

prfRowVals = [prfRowArray.values];
prfRowGaps = [prfRowArray.gapIndicators];
prfRowVals(prfRowGaps) = NaN;

prfColumnVals = [prfColumnArray.values];
prfColumnGaps = [prfColumnArray.gapIndicators];
prfColumnVals(prfColumnGaps) = NaN;

fwRowVals = [fwRowArray.values];
fwRowGaps = [fwRowArray.gapIndicators];
fwRowVals(fwRowGaps) = NaN;

fwColumnVals = [fwColumnArray.values];
fwColumnGaps = [fwColumnArray.gapIndicators];
fwColumnVals(fwColumnGaps) = NaN;


% plot flux and centroid time series
figure(1);
plot(midTimestamps,fluxVals);
grid;
xlabel('\bfmid timestamps (mjd)')
ylabel('\bfe-')
title('\bfPA flux');
legendLogical = ~all(isnan(fluxVals));
legend(legendText{legendLogical});

figure(2);
plot(midTimestamps,prfRowVals);
grid;
xlabel('\bfmid timestamps (mjd)')
ylabel('\bfzero-based pixels')
title('\bfPA prf centroid row');
legendLogical = ~all(isnan(prfRowVals));
legend(legendText{legendLogical});

figure(3);
plot(midTimestamps,prfColumnVals);
grid;
xlabel('\bfmid timestamps (mjd)')
ylabel('\bfzero-based pixels')
title('\bfPA prf centroid column');
legendLogical = ~all(isnan(prfColumnVals));
legend(legendText{legendLogical});

figure(4);
plot(midTimestamps,fwRowVals);
grid;
xlabel('\bfmid timestamps (mjd)')
ylabel('\bfzero-based pixels')
title('\bfPA flux weighted centoird row');
legendLogical = ~all(isnan(fwRowVals));
legend(legendText{legendLogical});

figure(5);
plot(midTimestamps,fwColumnVals);
grid;
xlabel('\bfmid timestamps (mjd)')
ylabel('\bfzero-based pixels')
title('\bfPA flux weighted centroid column');
legendLogical = ~all(isnan(fwColumnVals));
legend(legendText{legendLogical});

% plot target pixels for each target
pixelOffset = 0.05;
colors = {'b','r','g','k'};
figure(6);
hold on;

% use two loops to get the legend correct
for iTarget = 1: nTargets    
    offset = (iTarget - 1)*pixelOffset;
    plot(targetData(iTarget).column + offset,...
            targetData(iTarget).row + offset,[colors{iTarget},'.']);
end
for iTarget = 1: nTargets    
    offset = (iTarget - 1)*pixelOffset;
    plot(targetData(iTarget).column(targetData(iTarget).inOptimalAperture) + offset,...
            targetData(iTarget).row(targetData(iTarget).inOptimalAperture) + offset,[colors{iTarget},'o']); 
end

hold off;
xlabel('\bfzero-based column (pixels)')
ylabel('\bfzero-based row (pixels)')
title('\bfPA target apertures');
legend(legendText);
