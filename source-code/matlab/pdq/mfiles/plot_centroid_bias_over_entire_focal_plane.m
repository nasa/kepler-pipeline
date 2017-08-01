function plot_centroid_bias_over_entire_focal_plane(pdqOutputStruct, cadenceIndex, modOutsProcessed, raDec2PixObject)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function plot_centroid_bias_over_entire_focal_plane(pdqOutputStruct,
% cadenceIndex, modOutsProcessed, raDec2PixObject)
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

%-------------------------------------------------------------------------
% Step 1:
% plot the 21 ccd modules (bounding boxes)
%-------------------------------------------------------------------------


% get the attitude for this time stamp

cadenceTime = pdqOutputStruct.attitudeSolutionUncertaintyStruct(cadenceIndex).cadenceTime;
raNominalPointing      = pdqOutputStruct.attitudeSolutionUncertaintyStruct(cadenceIndex).nominalPointing(1);
decNominalPointing     = pdqOutputStruct.attitudeSolutionUncertaintyStruct(cadenceIndex).nominalPointing(2);
rollNominalPointing    = pdqOutputStruct.attitudeSolutionUncertaintyStruct(cadenceIndex).nominalPointing(3);


[modules,outputs] = convert_to_module_output((1:84)');

% define extreme corners of all the ccd modouts

cornerStarRows      = [1 1024 1 1024]';
cornerStarColumns   = [1  1   1100 1100]';

aberrateFlag = 1; % not a boolean

h = figure;

for j = 1:84

    ccdModules = repmat(modules(j), 4, 1);
    ccdOutput =  repmat(outputs(j), 4,1);

    [raAber, decAber] = pix_2_ra_dec_absolute(raDec2PixObject, ccdModules, ccdOutput, cornerStarRows, cornerStarColumns, cadenceTime, ...
        raNominalPointing, decNominalPointing, rollNominalPointing, aberrateFlag);

    convexHull = convhull(raAber,decAber);
    plot(raAber(convexHull),decAber(convexHull),'r--',raAber,decAber,'r.','LineWidth',1, 'MarkerFaceColor','r');
    text(mean(raAber(convexHull)),mean(decAber(convexHull)), num2str(j), 'FontSize', 6);

    hold on;
    %set(gca,'XDir','reverse');
    set(gca,'YDir','reverse');

end;

stellarCcdModules = pdqOutputStruct.attitudeSolutionUncertaintyStruct(cadenceIndex).ccdModule;
stellarCcdOutputs = pdqOutputStruct.attitudeSolutionUncertaintyStruct(cadenceIndex).ccdOutput;


plotCount = 0;

centroidBias = zeros(84,3);


% allocate memory for stars on all modouts
nStars = length(pdqOutputStruct.attitudeSolutionUncertaintyStruct(cadenceIndex).raStars);

raMeasuredTrue = zeros(nStars,2);
decMeasuredTrue = zeros(nStars,2);

starCount = 0;

centroidBiasMapPlotStruct = repmat(struct('ra', [], 'dec', [], 'uInDeciPixels', [], 'vInDeciPixels', []), 84,1);

for currentModuleOutput = find(modOutsProcessed(:)')


    [ccdModule ccdOutput] = convert_to_module_output(currentModuleOutput);
    %fprintf(' Current module output = %d {%d %d}\n', currentModuleOutput, ccdModule, ccdOutput);

    stellarIndex = find(stellarCcdModules == ccdModule & stellarCcdOutputs == ccdOutput);

    if(isempty(stellarIndex)||length(stellarIndex)<2)
        continue;
    end

    starCentroidRows = pdqOutputStruct.attitudeSolutionUncertaintyStruct(cadenceIndex).centroidRows(stellarIndex);
    starCentroidColumns  = pdqOutputStruct.attitudeSolutionUncertaintyStruct(cadenceIndex).centroidColumns(stellarIndex);

    % measured star positions
    [raAber, decAber] = pix_2_ra_dec_absolute(raDec2PixObject, stellarCcdModules(stellarIndex), stellarCcdOutputs(stellarIndex),  starCentroidRows, starCentroidColumns,cadenceTime, ...
        raNominalPointing, decNominalPointing, rollNominalPointing, aberrateFlag);


    %----------------------------------------------------------------------
    % get the bias for this modout from metrics
    %----------------------------------------------------------------------

    rowBias = pdqOutputStruct.outputPdqTsData.pdqModuleOutputTsData(currentModuleOutput).centroidsMeanRows.values(cadenceIndex);
    columnBias = pdqOutputStruct.outputPdqTsData.pdqModuleOutputTsData(currentModuleOutput).centroidsMeanCols.values(cadenceIndex);

    %----------------------------------------------------------------------
    % get the ra, dec from catalog
    %----------------------------------------------------------------------

    raCatalog = pdqOutputStruct.attitudeSolutionUncertaintyStruct(cadenceIndex).raStars(stellarIndex);
    decCatalog = pdqOutputStruct.attitudeSolutionUncertaintyStruct(cadenceIndex).decStars(stellarIndex);

    if(abs(raAber-raCatalog) > 1)
        warning('PDQ:plotCentroidBias:aberratedRa', ...
            ['plotCentroidBias:aberrated Ra > catalog Ra for module ' num2str(ccdModule) 'ccdOutput ' num2str(ccdOutput)]);
    end

    nStarsOnCurrentModout = length(stellarIndex);
    raMeasuredTrue(starCount+1: nStarsOnCurrentModout+starCount, :)  = [raAber raCatalog];
    decMeasuredTrue(starCount+1: nStarsOnCurrentModout+starCount, :)  = [decAber decCatalog];


    starCount = starCount + nStarsOnCurrentModout;

    uInDeciPixels = (raAber - raCatalog)*(3600/3.98).*cos(deg2rad(decCatalog))*10;
    vInDeciPixels = (decAber-decCatalog)*3600/3.98*10;

    quiver(raAber, decAber, uInDeciPixels, vInDeciPixels, 0); % last parametr 0 is to turn autoscale off



    centroidBiasMapPlotStruct(currentModuleOutput).ra = raAber;
    centroidBiasMapPlotStruct(currentModuleOutput).dec = decAber;
    centroidBiasMapPlotStruct(currentModuleOutput).uInDeciPixels = uInDeciPixels;
    centroidBiasMapPlotStruct(currentModuleOutput).vInDeciPixels = vInDeciPixels;

    plotCount = plotCount+1;
    hold on;

    centroidBias(currentModuleOutput,:) = [currentModuleOutput rowBias columnBias];

    %set(gca,'XDir','reverse');
    set(gca,'YDir','reverse');

    fprintf('');

end

xlabel('RA in degrees');
ylabel('DEC in degrees');
titleStr = sprintf('Centroid bias over the Kepler focal plane for cadence %d in units of decipixels (1/10 pixel)', cadenceIndex);
title(titleStr);
axis equal;



xTickValues = get(gca, 'xTick');
yTickValues = get(gca, 'yTick');

nTicks = length(xTickValues);

xLocation = 0.5*(xTickValues(nTicks-2) +xTickValues(nTicks-1));

quiver(xLocation, yTickValues(1), 1, 0, 0, 'LineWidth',2, 'color','b');
text(xLocation+1.2, yTickValues(1), '= 0.1 pixel');
% % save the plot to a file in TIFF format with 200 dpi resolution
fileNameStr = ['centroid_bias_map_across_the_focal_plane_for_cadence_' num2str(cadenceIndex) ];


%--------------------------------------------------------------------------
% Set plot caption for general use.
% The official version of this caption is in centroid-bias-map.tex.
%--------------------------------------------------------------------------
plotCaption = strcat(...
    'The centroid bias map is a quiver plot (velocity plot) that displays {row centroid bias, column centroid bias} \n',...
    'as arrows at the positions {ra, dec} of stars. For example, the first vector is defined by components \n',...
    '{row centroid bias(1), column centroid bias(1)} and is displayed at the point {ra(1), dec(1)}.\n\n',...
    'In this plot, the quivers/arrows are plotted without automatic scaling. The measured centroid positions \n',...
    '{centroid rows, centroid columns} on the focal plane are transformed to {ra, dec} using pix_2_ra_dec at the \n',...
    'nominal attitude. \n\n',...
    'The centroid bias components are computed in units of (1/10th) of pixel (1 pixel spans 3.98 arc sec) as  \n',...
    '    u = (ra - raCatalog)*(3600/3.98)*cos(deg2rad(decCatalog))*10 \n',...
    '    v = (dec - decCatalog)*(3600/3.98)*10\n\n',...
    'The length of the arrows are in units of 1/10th of a pixel. This means a quiver/arrow with a length equal to \n',...
    '1 tick mark spacing in x or y axis will equal 5*(1/10) = 0.5 pixel ( x- axis markers are 5 degrees apart).\n');

set(h, 'UserData', sprintf(plotCaption));

paperOrientationFlag = false;
includeTimeFlag = false;
printJpgFlag = false;
plot_to_file(fileNameStr, paperOrientationFlag, includeTimeFlag, printJpgFlag);

save centroidBiasMapPlotStruct.mat centroidBiasMapPlotStruct;

return


