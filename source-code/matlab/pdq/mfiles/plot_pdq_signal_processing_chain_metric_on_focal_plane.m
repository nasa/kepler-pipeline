function plot_pdq_signal_processing_chain_metric_on_focal_plane(pdqMetricStruct, modOutsProcessed, newCadenceIndex, spChainStruct, fcConstantsStruct)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function plot_pdq_metric_on_focal_plane(pdqMetricStruct, modOutsProcessed)
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

% Close all figures.
close all;

printModOutLabels = true;

% Set the number of CCD module outputs.
nModOuts = length(modOutsProcessed);

% Get all CCD module outputs in sequence.
[modules, outputs] = convert_to_module_output(1: nModOuts);


ccdModuleSpChainPair = [fcConstantsStruct.signalProcessingChainMapKeys fcConstantsStruct.signalProcessingChainMapValues] ;

southWestCoordinates = zeros(2,1);

%-----------------------------------------------------------------------------
% get the coordinates of NW, SE corner to reposition the origin at NW corner; the function
% morc_to_focal_plane_coords puts the origin at the center
%-----------------------------------------------------------------------------

for iModOut = 1 : nModOuts
    
    % Get the CCD module and output.
    module = modules(iModOut);
    output = outputs(iModOut);
    
    % Get the edges of the mod out in MORC coordinates.  The rows go from 0
    % to 1043, so the edges of the mod out are rows -0.5 to 1043.5.
    % Similarly, the edges of the true mod out in column space are at column
    % 11.5 (outermost edge of column 12, since columns 0 to 11 don't actually
    % exist) and 1111.5.
    modlist = repmat(module, [1, 4]);
    outlist = repmat(output, [1, 4]);
    rowlist = [-0.5 1043.5 1043.5 -0.5];
    collist = [11.5 11.5 1111.5 1111.5];
    
    % Convert the MORC coordinates of the mod out to the global focal plane
    % coordinates.
    [z, y] = morc_to_focal_plane_coords(modlist, outlist, ...
        rowlist, collist, 'one-based');
    
    if(min(z) < southWestCoordinates (1))
        southWestCoordinates (1) = min(z);
    end
    if(min(y) < southWestCoordinates (2))
        southWestCoordinates (2) = min(y);
    end
    
    
end

%-----------------------------------------------------------------------------
% create a scaled version of the focal plane
%-----------------------------------------------------------------------------

focalPlaneSide = ceil(abs(southWestCoordinates(1))/100) + 2 ;
focalPlane = Inf(ceil(2.5*focalPlaneSide), ceil(2.5*focalPlaneSide));
offsetForSPChain = round(0.5*focalPlaneSide);

offsetSwX = (southWestCoordinates(1)/100) - offsetForSPChain;
offsetSwY = (southWestCoordinates(2)/100) ;



%-----------------------------------------------------------------------------
% collect the coords for dynamic range
%-----------------------------------------------------------------------------
for iModOut = 53 : 72
    
    module = modules(iModOut);
    output = outputs(iModOut);
    
    rows = (100:100:1000)';
    cols = (100:100:1000)';
    
    modlist = repmat(module, length(rows), 1);
    outlist = repmat(output, length(rows),1);
    
    [z, y] = morc_to_focal_plane_coords(modlist, outlist, rows, cols, 'one-based');
    
    
    moduleIndex = find(ccdModuleSpChainPair(:,1) == module);
    
    spChain = ccdModuleSpChainPair(moduleIndex,2);
    
    spChainStruct(spChain, output).yCoords = round(y./100 - offsetSwX + 4 - 1.75*offsetForSPChain);
    
    spChainStruct(spChain, output).zCoords = round(z./100 - offsetSwY + 4);
    
    
end
%---------------------------------------------------------------------------------------------------
% Loop throught all module outputs.
%-----------------------------------------------------------------------------

for iModOut = 1 : nModOuts
    
    if(modOutsProcessed(iModOut))
        
        % Get the CCD module and output.
        module = modules(iModOut);
        output = outputs(iModOut);
        
        metricValues = pdqMetricStruct.metric(iModOut).values(newCadenceIndex);
        metricValues = metricValues(metricValues ~= -1);
        
        % Convert the MORC coordinates of the mod out to the global focal plane
        % coordinates.
        
        rows = (100:100:1000)';
        cols = (100:100:1000)';
        
        modlist = repmat(module, length(rows), 1);
        outlist = repmat(output, length(rows),1);
        
        [z, y] = morc_to_focal_plane_coords(modlist, outlist, rows, cols, 'one-based');
        if(~isempty(metricValues))
            
            focalPlane(round(y./100 - offsetSwX + 4), round(z./100 - offsetSwY + 4)) = max(metricValues);
            
            % plot analog signal processing chain
            
            
            moduleIndex = find(ccdModuleSpChainPair(:,1) == module);
            
            spChain = ccdModuleSpChainPair(moduleIndex,2);
            
            spModOuts = spChainStruct(spChain, output).modouts;
            
            % now get the max over these modouts
            
            spModOuts = spModOuts(modOutsProcessed(spModOuts));
            
            spChainMetricValues = cat(2,pdqMetricStruct.metric(spModOuts).values);
            spChainMetricValues = max(spChainMetricValues(newCadenceIndex,:));
            spChainMetricValues = spChainMetricValues(:);
            spChainMetricValues = max(spChainMetricValues(spChainMetricValues ~= -1));
            
            
            yCoords = spChainStruct(spChain, output).yCoords;
            zCoords = spChainStruct(spChain, output).zCoords;
            
            
            focalPlane(yCoords, zCoords) = spChainMetricValues;
            
            
        else
            focalPlane(round(y./100 - offsetSwX + 4), round(z./100 - offsetSwY + 4)) = NaN;
            
        end
    else
        
        % Get the CCD module and output.
        module = modules(iModOut);
        output = outputs(iModOut);
        
        
        % Convert the MORC coordinates of the mod out to the global focal plane
        % coordinates.
        
        rows = (100:100:1000)';
        cols = (100:100:1000)';
        
        modlist = repmat(module, length(rows), 1);
        outlist = repmat(output, length(rows),1);
        
        [z, y] = morc_to_focal_plane_coords(modlist, outlist, rows, cols, 'one-based');
        focalPlane(round(y./100 - offsetSwX + 4), round(z./100 - offsetSwY + 4)) = NaN;
        
    end
    
end




%--------------------------------------------------------------------------

%-----------------------------------------------------------------------------
% plot  over the entire focal plane
%-----------------------------------------------------------------------------


h1 = figure;
imagesc(focalPlane);
colormap('jet');
colorbar;


%--------------------------------------------------------------------------
% Jon's code snippet to set the background to something other than 0
%--------------------------------------------------------------------------


% choose a colormap and set the first (lowest) value to a pleasing gray
cmap = colormap(gca);

% get the image data from the image object
im = focalPlane;

% move all NaN from 0 to 1/1024th less than the minimum in the image
% move all Inf from 1/1024th to slightly more than the max


minForNaN =  min(im(isfinite(im))) - 10*( max(im(isfinite(im)))  - min(im(isfinite(im))) )/length(cmap);
maxForInf =  max(im(isfinite(im))) + 10*( max(im(isfinite(im)))  - min(im(isfinite(im))) )/length(cmap) ;

if(any(any(isnan(im))))
    im(isnan(im)) = minForNaN;
    cmap(1,:)=[.75,.75,.75];
end

im(isinf(im)) = maxForInf;
cmap(end,:)=[1 1 1];

% replace the cdata for the image
imagesc(im);
colormap(cmap);
colorbar;

hold on;



set(gca, 'fontsize', 10);
set(gca, 'ydir', 'normal');

titleStr =  pdqMetricStruct.titleStr;
title(titleStr);

%set(gca, 'ydir', 'normal');
set(gca, 'Xticklabel', '');
set(gca, 'yticklabel', '');

offsetSwX = (southWestCoordinates(1)/100);
offsetSwY = (southWestCoordinates(2)/100) - offsetForSPChain;


% Loop throught all module outputs.
for iModOut = 1 : nModOuts
    
    % Get the CCD module and output.
    module = modules(iModOut);
    output = outputs(iModOut);
    
    % Get the edges of the mod out in MORC coordinates.  The rows go from 0
    % to 1043, so the edges of the mod out are rows -0.5 to 1043.5.
    % Similarly, the edges of the true mod out in column space are at column
    % 11.5 (outermost edge of column 12, since columns 0 to 11 don't actually
    % exist) and 1111.5.
    modlist = repmat(module, [1, 4]);
    outlist = repmat(output, [1, 4]);
    rowlist = [-0.5 1043.5 1043.5 -0.5];
    collist = [11.5 11.5 1111.5 1111.5];
    
    
    
    % Convert the MORC coordinates of the mod out to the global focal plane
    % coordinates.
    [z, y] = morc_to_focal_plane_coords(modlist, outlist, ...
        rowlist, collist, 'zero-based');
    
    % Use convhull to order the box edges.
    pointIndex = convhull(z,y);
    
    % Set the grid for displaying the mod, out labael
    zg = min(z) + (max(z)-min(z))/2 ;
    yg = min(y) + (max(y)-min(y))/2;
    zg = fix(zg/100) - offsetSwX + 2;
    yg = fix(yg/100) - offsetSwY + 4;
    
    
    % Plot the bounding box for the mod out, with dashed lines to demarcate
    % the metric grid.
    
    set(0,'CurrentFigure',h1);
    plot(z(pointIndex)/100 - offsetSwX + 4, y(pointIndex)/100 - offsetSwY + 4, 'k:');
    hold on;
    
    if((iModOut >= 53)&&(iModOut <= 72)) % collect co-ordinates
        
        plot(z(pointIndex)/100 - offsetSwX + 4, y(pointIndex)/100 - offsetSwY - 1.75*offsetForSPChain + 4 , 'k:');
        text(zg, yg - 1.75*offsetForSPChain, num2str(output), 'FontSize', 8, 'color', 'k');
        
    end
    
    if printModOutLabels
        figure(h1);
        set(0,'CurrentFigure',h1);
        text(zg, yg, [num2str(module), ', ', num2str(output)], 'FontSize', 8, 'color', 'k');
    end
end



hold on;
%--------------------------------------------------------------------------
% print signal processing chain text string
%--------------------------------------------------------------------------

moduleSpacing = floor(focalPlaneSide*0.4); % focal plane side has 2.5 modules

firstModuleCenter = moduleSpacing/2 + 2;


nChains = length(fcConstantsStruct.signalProcessingChains);
xPositions = firstModuleCenter + (0:nChains-1)'.*moduleSpacing;

yPositions = repmat(offsetForSPChain, nChains,1);

spChainStr = {'V', 'IV', 'III', 'II', 'I'};

for j = 1:nChains
    
    text(xPositions(j), yPositions(j), spChainStr(j), 'FontSize', 10,'FontWeight', 'bold', 'color', 'k');
    
end



%--------------------------------------------------------------------------
% set plot caption for report generator and/or for general use
%--------------------------------------------------------------------------
paperOrientationFlag = false;
includeTimeFlag = false;
printJpgFlag = false;




set(0,'CurrentFigure',h1);


plotCaption = strcat(...
    ['This plot depicts the variation of the  ' pdqMetricStruct.name ', which is computed as the max over all the cadences  \n'],...
    ['for the current contact for a given module/output, in ' pdqMetricStruct.units ' across the focal plane.\n'], ...
    '\n',...
    'The dynamic range for each analog signal processing chain is plotted at the bottom of the above figure. The units are \n',...
    'still in ADU. This metric for each chain comprising of modouts 1, 2, 3, and 4 is computed as the maximum of the dynamic  \n',...
    'range metric for that chain and for that modout.\n',...
    '\n',...
    'The analog signal processing chain I includes CCD Modules 10, 15, and 20.\n',...
    'The analog signal processing chain II includes CCD Modules 4, 9, 14, 19, and 24.\n',...
    'The analog signal processing chain III includes CCD Modules 3, 8, 13, 18, and 23.\n',...
    'The analog signal processing chain IV includes CCD Modules 2, 7, 12, 17, and 22.\n',...
    'The analog signal processing chain V includes CCD Modules 6, 11, and 16.\n');

set(h1, 'UserData', sprintf(plotCaption));
plot_to_file(report_filename_safe(titleStr{1}), paperOrientationFlag, includeTimeFlag, printJpgFlag);

close all

return
