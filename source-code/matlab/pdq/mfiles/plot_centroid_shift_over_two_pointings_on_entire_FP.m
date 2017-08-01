%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% plot_centroid_shift_over_two_pointings_on_entire_FP.m
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%  Eventually this will go into PDQ reports. Run after a succesful PDQ run.
%  Currently written as a stand alone script - expects certain mat files in
%  the workspace - attitudeSolution Structure, pdqoutputStructure,
%  raDec2PixObject
%
%  Maps the centroid bias over the entire focal plane (assuming PDQ
%  succesfully computed centroid metric for all th e84 modouts) as a quiver
%  plot. Modouts that didn't have any stars/centroids will be empty in the
%  plot.
%
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

clc;
close all;

load  onOffCombinedResults.mat;
EXPECTED_CENTROID_SHIFT = 1;


%   modOutsProcessed             84x1                   84  logical
%   offPointpdqOutputStruct       1x1              6320144  struct
%   onPointpdqOutputStruct        1x1              6306832  struct
%   pdqInputStruct                1x1             56976033  struct
%   onPointpdqOutputStruct               1x1              3473269  struct

raDec2PixObject = raDec2PixClass(pdqInputStruct.raDec2PixModel, 'one-based');

%-------------------------------------------------------------------------
% Step 1:
% plot the 21 ccd modules (bounding boxes)
%-------------------------------------------------------------------------


cadenceIndex = 1;  % for the first cadence, can easily be turned into a parameter

% get the attitude for this time stamp

cadenceTime = onPointpdqOutputStruct.attitudeSolutionUncertaintyStruct(cadenceIndex).cadenceTime;
raNominalPointing      = onPointpdqOutputStruct.attitudeSolutionUncertaintyStruct(cadenceIndex).nominalPointing(1);
decNominalPointing     = onPointpdqOutputStruct.attitudeSolutionUncertaintyStruct(cadenceIndex).nominalPointing(2);
rollNominalPointing    = onPointpdqOutputStruct.attitudeSolutionUncertaintyStruct(cadenceIndex).nominalPointing(3);


[modules,outputs] = convert_to_module_output((1:84)');

% define extreme corners of all the ccd modouts

cornerStarRows      = [1 1024 1 1024]';
cornerStarColumns   = [1  1   1100 1100]';
x = cornerStarColumns;
y = cornerStarRows;

aberrateFlag = 1; % not a boolean

figure;

for j = 1:84

    ccdModules = repmat(modules(j), 4, 1);
    ccdOutput =  repmat(outputs(j), 4,1);

    [raOnPoint, decOnPoint] = pix_2_ra_dec_absolute(raDec2PixObject, ccdModules, ccdOutput, cornerStarRows, cornerStarColumns, cadenceTime, ...
        raNominalPointing, decNominalPointing, rollNominalPointing, aberrateFlag);


    convexHull = convhull(raOnPoint,decOnPoint);
    h1 = plot(raOnPoint(convexHull),decOnPoint(convexHull),'r--',raOnPoint,decOnPoint,'r.','LineWidth',1, 'MarkerFaceColor','r');
    text(mean(raOnPoint(convexHull)),mean(decOnPoint(convexHull)), num2str(j), 'FontSize', 6);

    hold on;
    %set(gca,'XDir','reverse');
    set(gca,'YDir','reverse');

end;

stellarCcdModulesOnPoint = onPointpdqOutputStruct.attitudeSolutionUncertaintyStruct(cadenceIndex).ccdModule;
stellarCcdOutputsOnPoint = onPointpdqOutputStruct.attitudeSolutionUncertaintyStruct(cadenceIndex).ccdOutput;

stellarCcdModulesOffPoint = offPointpdqOutputStruct.attitudeSolutionUncertaintyStruct(cadenceIndex).ccdModule;
stellarCcdOutputsOffPoint = offPointpdqOutputStruct.attitudeSolutionUncertaintyStruct(cadenceIndex).ccdOutput;

plotCount = 0;



% allocate memory for stars on all modouts
nStars = length(onPointpdqOutputStruct.attitudeSolutionUncertaintyStruct(cadenceIndex).raStars);

allCentroids = zeros(nStars,6);

starCount = 0;

for currentModuleOutput = 1:84


    [ccdModule ccdOutput] = convert_to_module_output(currentModuleOutput);
    fprintf(' Current module output = %d {%d %d}\n', currentModuleOutput, ccdModule, ccdOutput);

    stellarIndexOnPoint = find(stellarCcdModulesOnPoint == ccdModule & stellarCcdOutputsOnPoint == ccdOutput);

    if(isempty(stellarIndexOnPoint))
        continue;
    end



    starCentroidRowsOnPoint = onPointpdqOutputStruct.attitudeSolutionUncertaintyStruct(cadenceIndex).centroidRows(stellarIndexOnPoint);
    starCentroidColumnsOnPoint  = onPointpdqOutputStruct.attitudeSolutionUncertaintyStruct(cadenceIndex).centroidColumns(stellarIndexOnPoint);


    % measured star positions on point
    [raOnPoint, decOnPoint] = pix_2_ra_dec_absolute(raDec2PixObject, stellarCcdModulesOnPoint(stellarIndexOnPoint), stellarCcdOutputsOnPoint(stellarIndexOnPoint),  starCentroidRowsOnPoint, starCentroidColumnsOnPoint,cadenceTime, ...
        raNominalPointing, decNominalPointing, rollNominalPointing, aberrateFlag);


    raCatalog = onPointpdqOutputStruct.attitudeSolutionUncertaintyStruct(cadenceIndex).raStars(stellarIndexOnPoint);
    decCatalog = onPointpdqOutputStruct.attitudeSolutionUncertaintyStruct(cadenceIndex).decStars(stellarIndexOnPoint);

    if(abs(raOnPoint-raCatalog) > 1)
        fprintf('Bug .( .( ...');
    end



    %----------------------------------------------------------------------
    % get the bias for this modout from metrics
    %----------------------------------------------------------------------
    %
    %     rowBias = onPointpdqOutputStruct.outputPdqTsData.pdqModuleOutputTsData(currentModuleOutput).centroidsMeanRows.values(cadenceIndex);
    %     columnBias = onPointpdqOutputStruct.outputPdqTsData.pdqModuleOutputTsData(currentModuleOutput).centroidsMeanCols.values(cadenceIndex);

    %----------------------------------------------------------------------
    % measured star positions off point
    %----------------------------------------------------------------------

    stellarIndexOffPoint = find(stellarCcdModulesOffPoint == ccdModule & stellarCcdOutputsOffPoint == ccdOutput);

    if(isempty(stellarIndexOffPoint))
        continue;
    end



    starCentroidRowsOffPoint = offPointpdqOutputStruct.attitudeSolutionUncertaintyStruct(cadenceIndex).centroidRows(stellarIndexOffPoint);
    starCentroidColumnsOffPoint  = offPointpdqOutputStruct.attitudeSolutionUncertaintyStruct(cadenceIndex).centroidColumns(stellarIndexOffPoint);


    % measured star positions on point
    [raOffPoint, decOffPoint] = pix_2_ra_dec_absolute(raDec2PixObject, stellarCcdModulesOffPoint(stellarIndexOffPoint), stellarCcdOutputsOffPoint(stellarIndexOffPoint),  starCentroidRowsOffPoint, starCentroidColumnsOffPoint,cadenceTime, ...
        raNominalPointing, decNominalPointing, rollNominalPointing, aberrateFlag);



    raCatalog = offPointpdqOutputStruct.attitudeSolutionUncertaintyStruct(cadenceIndex).raStars(stellarIndexOffPoint);
    decCatalog = offPointpdqOutputStruct.attitudeSolutionUncertaintyStruct(cadenceIndex).decStars(stellarIndexOffPoint);

    if(abs(raOffPoint-raCatalog) > 1)
        fprintf('Bug .( .( ...');
    end

    nStarsOnCurrentModout = length(stellarIndexOffPoint);



    if(length(starCentroidRowsOnPoint) ~= length(starCentroidRowsOffPoint))

        %------------------------------------------------------------------
        % remove the star centroid which does not appear in both the lists
        %------------------------------------------------------------------
        nOn = length(starCentroidRowsOnPoint);
        nOff = length(starCentroidRowsOffPoint);

        if(nOn > nOff)
            % goal is to find which star is missing from the off set and
            % remove it from the on set

            indexOfStarsNotOnBoth = zeros(nOn,1);
            starCountOnThisModOut = 0;
            for j=1:nOn

                [val, index] = min(abs(starCentroidRowsOnPoint(j) - starCentroidRowsOffPoint));
                if(val > EXPECTED_CENTROID_SHIFT)
                    starCountOnThisModOut = starCountOnThisModOut+1;
                    indexOfStarsNotOnBoth(starCountOnThisModOut) = j;
                end
            end
            indexOfStarsNotOnBoth(starCountOnThisModOut+1:end) = [];
            starCentroidRowsOnPoint(indexOfStarsNotOnBoth) = [];
            starCentroidColumnsOnPoint(indexOfStarsNotOnBoth) = [];
            raOnPoint(indexOfStarsNotOnBoth) = [];
            decOnPoint(indexOfStarsNotOnBoth) = [];

        else

            indexOfStarsNotOnBoth = zeros(nOff,1);
            starCountOnThisModOut = 0;
            for j=1:nOff

                [val, index] = min(abs(starCentroidRowsOffPoint(j) - starCentroidRowsOnPoint));
                if(val > EXPECTED_CENTROID_SHIFT)
                    starCountOnThisModOut = starCountOnThisModOut+1;
                    indexOfStarsNotOnBoth(starCountOnThisModOut) = j;
                end
            end
            indexOfStarsNotOnBoth(starCountOnThisModOut+1:end) = [];
            starCentroidRowsOffPoint(indexOfStarsNotOnBoth) = [];
            starCentroidColumnsOffPoint(indexOfStarsNotOnBoth) = [];
            raOffPoint(indexOfStarsNotOnBoth) = [];
            decOffPoint(indexOfStarsNotOnBoth) = [];

        end

    end


    nStarsOnCurrentModout = length(starCentroidRowsOnPoint);
    allCentroids(starCount+1 : starCount+nStarsOnCurrentModout, :) = ...
        [starCentroidRowsOnPoint starCentroidRowsOffPoint starCentroidColumnsOnPoint starCentroidColumnsOffPoint ...
        repmat(ccdModule, nStarsOnCurrentModout,1) repmat(ccdOutput, nStarsOnCurrentModout,1)];


    starCount = starCount + nStarsOnCurrentModout;

    quiver(raOnPoint, decOnPoint, raOnPoint - raOffPoint, decOnPoint-decOffPoint);


    plotCount = plotCount+1;
    hold on;

    %centroidBias(currentModuleOutput,:) = [currentModuleOutput rowBias columnBias];

    %set(gca,'XDir','reverse');
    set(gca,'YDir','reverse');

    fprintf('');

end

allCentroids(starCount+1:end,:) = [];



xlabel('RA in degrees');
ylabel('DEC in degrees');
title('Centroid shift over the Kepler focal plane');


% % save the plot to a file in TIFF format with 200 dpi resolution
title_str = 'centroid_shift_map';
sFilename = [title_str '.jpg'];
fprintf('\n\nSaving the plot to a file named %s \n',sFilename);
fprintf('Please wait....\n\n');
print('-djpeg','-r300',sFilename);

figure;
plot(sqrt( ( allCentroids(:,1) - allCentroids(:,2) ).^2 + ( allCentroids(:,3) - allCentroids(:,4)).^2), '.-');
mean(sqrt( ( allCentroids(:,1) - allCentroids(:,2) ).^2 + ( allCentroids(:,3) - allCentroids(:,4)).^2))


fprintf('');

