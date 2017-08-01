function [discAnalysisStruct, targetsWithUndetectedDiscs] = ...
compare_inserted_and_detected_discontinuities(insertedDiscStruct, ...
detectedDiscStruct, maxStepSize, nBins)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function [discAnalysisStruct] = ...
% compare_inserted_and_detected_discontinuities(insertedDiscStruct, ...
% detectedDiscStruct, maxStepSize, nBins)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Cycle through the inserted discontinuities and determine whether or not
% they were correctly identified by PDC. Summarize and plot the results.
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

% Set defaults if necessary.
MAX_STEP_SIZE = 1e6;
N_BINS = 20;

if ~exist('maxStepSize', 'var')
    maxStepSize = MAX_STEP_SIZE;
end

if ~exist('nBins', 'var')
    nBins = N_BINS;
end

% Cycle through the inserted discontinuities and determine whether or not
% they were correctly identified by PDC.
nDiscs = length(vertcat(insertedDiscStruct.index));
iDisc = 0;

discAnalysisStruct = repmat(struct( ...
    'targetIndex', 0, ...
    'keplerId', 0, ...
    'detectedDisc', false, ...
    'insertedDiscIndex', 0, ...
    'detectedDiscIndex', 0, ...
    'insertedStepSize', 0, ...
    'detectedStepSize', 0), [1, nDiscs]);

for iTarget = 1 : length(insertedDiscStruct)
    
    insertedDisc = insertedDiscStruct(iTarget);
    detectedDisc = detectedDiscStruct(iTarget);
    
    for iCount = 1 : length(insertedDisc.index)
        
        iDisc = iDisc + 1;
        discAnalysisStruct(iDisc).targetIndex = iTarget;
        discAnalysisStruct(iDisc).keplerId = insertedDisc.keplerId;
        
        insertedDiscIndex = insertedDisc.index(iCount);
        insertedStepSize = insertedDisc.discontinuityStepSize(iCount);
        discAnalysisStruct(iDisc).insertedDiscIndex = insertedDiscIndex;
        discAnalysisStruct(iDisc).insertedStepSize = insertedStepSize;
        [tf, loc] = ismember(insertedDiscIndex, detectedDisc.index);
        
        if tf
            discAnalysisStruct(iDisc).detectedDisc = true;
            discAnalysisStruct(iDisc).detectedDiscIndex = ...
                detectedDisc.index(loc);
            discAnalysisStruct(iDisc).detectedStepSize = ...
                detectedDisc.discontinuityStepSize(loc);
        end % if
        
    end % for iCount
    
end % for iTarget

% Summarize and plot the results.
isDetected = [discAnalysisStruct.detectedDisc];
insertedStepSizes = [discAnalysisStruct.insertedStepSize];
detectedStepSizes = [discAnalysisStruct(isDetected).detectedStepSize];

targetsWithUndetectedDiscs = unique([discAnalysisStruct(~isDetected).targetIndex]);

disp(['Detected discontinuities = ', num2str(sum(isDetected)), '/', ...
    num2str(length(isDetected)), ' = ', num2str(sum(isDetected)/length(isDetected))]);

close all
subplot(4, 1, 1)
edges = (0:nBins) * maxStepSize / nBins;
centers = edges(1 : end-1) + maxStepSize / (2 * nBins);
stepSizeHistogram = histc(abs(insertedStepSizes), edges);
bar(centers, stepSizeHistogram(1 : end-1));
title('Histogram of Inserted Steps')
xlabel('Absolute Step Size (e-)')
ylabel('Count')

subplot(4, 1, 2)
detectedStepSizeHistogram = histc(abs(insertedStepSizes(isDetected)), edges);
bar(centers, detectedStepSizeHistogram(1 : end-1));
title('Histogram of Detected Steps')
xlabel('Absolute Step Size (e-)')
ylabel('Count')

subplot(4, 1, 3)
undetectedStepSizeHistogram = histc(abs(insertedStepSizes(~isDetected)), edges);
bar(centers, undetectedStepSizeHistogram(1 : end-1));
title('Histogram of Undetected Steps')
xlabel('Absolute Step Size (e-)')
ylabel('Count')

subplot(4, 1, 4)
bar(centers, detectedStepSizeHistogram(1 : end-1) ./ stepSizeHistogram(1 : end-1))
x = axis;
x(3) = 0;
x(4) = 1;
axis(x);
title('Probability of Detection')
xlabel('Absolute Step Size (e-)')
ylabel('Probability')
pause

close
plot(insertedStepSizes(isDetected), detectedStepSizes, '.')
hold on
plot([-maxStepSize, maxStepSize], [-maxStepSize, maxStepSize], '--r')
hold off
title('Detected vs Inserted Step Sizes (for Detected Discontinuities)')
xlabel('Inserted Step Size (e-)')
ylabel('Detected Step Size (e-)')

% Return.
return
