function plot_calibrated_target_pixels_in_different_stages(pdqTempStruct)
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

close all;
ccdModule = pdqTempStruct.ccdModule;
ccdOutput = pdqTempStruct.ccdOutput;
currentModOut = pdqTempStruct.currentModOut;

h = figure;
set(gca, 'fontsize', 8);

h1 = plot(pdqTempStruct.targetPixels, 'b.-');

hold on;


h2 = plot(pdqTempStruct.darkCorrectedTargetPixels, 'r-');
h3 = plot(pdqTempStruct.smearCorrectedTargetPixels, 'k-');
h4 = plot(pdqTempStruct.targetPixelsBlackCorrected*pdqTempStruct.gainForAllCadencesAllModOuts(pdqTempStruct.currentModOut), 'm:');



bkgdLevels  = (pdqTempStruct.bkgdLevels);
nTargets = size(bkgdLevels,1);

z = zeros(size(pdqTempStruct.targetPixels));

startIndex = 1;

for j = 1: nTargets

    stopIndex = startIndex -1 + pdqTempStruct.numPixels(j);
    z(startIndex:stopIndex,:) = repmat(bkgdLevels(j,:),pdqTempStruct.numPixels(j),1);
    startIndex = stopIndex +1;
end

%h5 = plot(z, '-', 'color', [0.6 0.2 0]);
h5 = plot(z, 'g-');


legend([h1(1) h2(1) h3(1) h4(1) h5(1)], {'calibrated taget pixels'; 'dark corrected'; ...
    'smear corrected'; 'black corrected, gain adjusted '; 'estimated bkgd'}, 'Location', 'Best');

title(['target pixels after different stages of calibration for module '  num2str(ccdModule) ' output ' num2str(ccdOutput) ' modout ' num2str( currentModOut)]);

titleStr = ['target_pixels_after_different_stages_of_calibration_for_module_'  num2str(ccdModule) '_output_' num2str(ccdOutput) '_modout_' num2str( currentModOut) ];



% add figure caption as user data
plotCaption = strcat(...
    'In this plot, PDQ stellar pixels in various stages of calibration are plotted. \n',...
    'This plot is useful for verifying whether all the the calibration steps \n',...
    'were performed correctly.\n',...
    'Click on the link to open the figure in Matlab to examine the pixels closely. \n');

set(h, 'UserData', sprintf(plotCaption));

paperOrientationFlag = false;
includeTimeFlag = false;
printJpgFlag = false;

plot_to_file(titleStr, paperOrientationFlag, includeTimeFlag, printJpgFlag);

close all;
return

