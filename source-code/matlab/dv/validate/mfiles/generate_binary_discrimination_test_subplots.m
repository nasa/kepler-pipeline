function generate_binary_discrimination_test_subplots(dvResultsStruct, iTarget, jPlanet)


% Get figure root directory of the given target.
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
dvFiguresRootDirectory = dvResultsStruct.targetResultsStruct(iTarget).dvFiguresRootDirectory;

% EBD path...
ebdPath = [dvFiguresRootDirectory, filesep, 'planet-', num2str(jPlanet, '%02d'), filesep, 'binary-discrimination-test-results'];

plotCount = 0;
fileNameCell = cell(0);
captionString = '';

keplerId = dvResultsStruct.targetResultsStruct(iTarget).keplerId;
% oddEvenTransitDepthFig = ['.', filesep, ebdPath, filesep, 'odd_even_transit_depths.fig'];   
oddEvenTransitDepthFig = ['.', filesep, ebdPath, filesep, num2str(keplerId, '%09d'), '-', num2str(jPlanet, '%02d'), '-odd-even-transit-depths.fig'];   
if exist(oddEvenTransitDepthFig , 'file')
    plotCount = plotCount + 1;
end
fileNameCell = [fileNameCell; oddEvenTransitDepthFig];

oddEvenTransitEpochFig = ['.', filesep, ebdPath, filesep, num2str(keplerId, '%09d'), '-', num2str(jPlanet, '%02d'), '-odd-even-transit-epochs.fig'];   
if exist(oddEvenTransitEpochFig, 'file')
    plotCount = plotCount + 1;
end
fileNameCell = [fileNameCell; oddEvenTransitEpochFig];

shorterPeriodFig = ['.', filesep, ebdPath, filesep, num2str(keplerId, '%09d'), '-', num2str(jPlanet, '%02d'), '-planet-and-one-with-shorter-period.fig'];   
if exist(shorterPeriodFig, 'file')
    plotCount = plotCount + 1;
end
fileNameCell = [fileNameCell; shorterPeriodFig];

longerPeriodFig  = ['.', filesep, ebdPath, filesep, num2str(keplerId, '%09d'), '-', num2str(jPlanet, '%02d'), '-planet-and-one-with-longer-period.fig'];    
if exist(longerPeriodFig, 'file')
    plotCount = plotCount + 1;
end
fileNameCell = [fileNameCell; longerPeriodFig];


% Start plot
close all

if plotCount >= 1    
    newFig_h = figure('units', 'pixels', 'position', [10 60 930 600]);
end

% Manipulate positions of subplots so that titles are not cropped in
% report.
positions = [
    [0.10 0.54 0.35 0.32]; [0.55 0.54 0.35 0.32];
    [0.10 0.04 0.35 0.32]; [0.55 0.04 0.35 0.32]
    ];

if plotCount == 0
    return
end

captionAddString = {'Top-left: '; ' Top-right: '; ' Bottom-left: ';' Bottom-right: '};
for iPlot = 1:4

    if ~exist(fileNameCell{iPlot}, 'file')
        continue;
    end
        
    newAxes_h = subplot(2,2,iPlot, 'parent', newFig_h);
    captionString = [captionString, captionAddString{iPlot}];
    captionString = make_subplot(fileNameCell, iPlot, newAxes_h, captionString);
    set(newAxes_h, 'Position', positions(iPlot,:));
end

set(newFig_h, 'userData', captionString)
format_graphics_for_dv_report(newFig_h)
% saveas(newFig_h, [ebdPath, filesep, 'subplots.fig'])
saveas(newFig_h, [ebdPath, filesep, num2str(keplerId, '%09d'),'-', num2str(jPlanet, '%02d'),'-eclipsing-binary-discrimination-tests.fig'])
close all



return


% Subfunction
function captionString = make_subplot(fileNameCell, iPlot, newAxes_h, captionString)
        
        origFig_h = hgload(fileNameCell{iPlot});
        ax_h = gca; 
        childrenOfAxes_h = findall(ax_h);
        
        % Find handles of xlabel, ylabel, title, and ax_h
        xlabel_h = get(ax_h, 'xlabel');
        ylabel_h = get(ax_h, 'ylabel');
        title_h = get(ax_h, 'title');
        
        gap_h = (childrenOfAxes_h == xlabel_h) | (childrenOfAxes_h == ylabel_h) | (childrenOfAxes_h == title_h) | (childrenOfAxes_h == ax_h);
        childrenOfAxes_h = childrenOfAxes_h(~gap_h);
        
        copyobj(childrenOfAxes_h, newAxes_h)
        set(newAxes_h, 'xticklabel',  get(ax_h, 'xTickLabel'))
        set(newAxes_h, 'xTick', get(ax_h, 'xTick'))
        set(newAxes_h, 'xTickLabelMode', get(ax_h, 'xTickLabelMode'))
        set(newAxes_h, 'xTickMode', get(ax_h, 'xTickMode'))
        set(newAxes_h, 'xGrid', get(ax_h, 'xGrid'))
        set(newAxes_h, 'yGrid', get(ax_h, 'yGrid'))
        
       
        xlabel(newAxes_h, get(xlabel_h, 'string'))
        ylabel(newAxes_h, get(ylabel_h, 'string'))
        title(newAxes_h, get(title_h, 'string'))
        
        string = get(origFig_h, 'userData');
        captionString = [captionString, string];
        
        return
