function inputsStruct = add_zodi_to_target_pixels(inputsStruct, backgroundStruct1, backgroundStruct2)
%
% function inputsStruct = add_zodi_to_target_pixels(inputsStruct, backgroundStruct1, backgroundStruct2)
% 
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

maxColumn = 1132;
maxRow = 1070;
gridSize = 20;


% build a grid over all ccd rows and columns
ccdRows = repmat(1:gridSize:maxRow,length(1:gridSize:maxColumn),1);
ccdColumns = repmat((1:gridSize:maxColumn)',1,length(1:gridSize:maxRow));

% get the background difference over the grid
D = get_median_background_difference(ccdRows(:),ccdColumns(:),backgroundStruct1,backgroundStruct2);

% scale for SC
if ( strcmpi(inputsStruct.cadenceType,'short') )
    D = D./30;
end

% plot
h = figure;
plot3(ccdRows(:),ccdColumns(:),D,'.');
hold on;

% get all the target pixel locations
pixelStruct = [inputsStruct.targetStarDataStruct.pixelDataStruct];
row = [pixelStruct.ccdRow];
col = [pixelStruct.ccdColumn];

% find median background difference for these pixel locations
% median is taken over cadences
% approximates the zodi that is added between backgroundStruct1 and
% backgroundStruct2
D = get_median_background_difference(row(:),col(:),backgroundStruct1,backgroundStruct2);

% scale for SC
if ( strcmpi(inputsStruct.cadenceType,'short') )
    D = D./30;
end

% plot the median at the pixel locations
plot3(row(:),col(:),D,'r.');
grid on;
xlabel('ccdRow');
ylabel('ccdColumn');
zlabel('( e- )');
title('Zodi Estimated From Background Difference');
hold off;
legend('difference over ccd','difference at target pixels');

saveas(h,'zodi_estimate.fig');


for i=1:length([inputsStruct.targetStarDataStruct])
    targetPixelRow = [inputsStruct.targetStarDataStruct(i).pixelDataStruct.ccdRow];
    targetPixelCol = [inputsStruct.targetStarDataStruct(i).pixelDataStruct.ccdColumn];
    tf = ismember([row(:),col(:)],[targetPixelRow(:),targetPixelCol(:)],'rows');
    
    medianZodiForTarget = D(tf);
    
    % add zodi to target pixel timeseries
    for j=1:length(inputsStruct.targetStarDataStruct(i).pixelDataStruct)
        inputsStruct.targetStarDataStruct(i).pixelDataStruct(j).values = ...
            inputsStruct.targetStarDataStruct(i).pixelDataStruct(j).values + medianZodiForTarget(j);
    end   
end