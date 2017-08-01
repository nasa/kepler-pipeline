function plot_focal_plane_metric_comparison_plots(commonStruct, attitude1, attitude2, metricNameString,figureFileName,yUnitsLabel)
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

if(nargin < 6)
    yUnitsLabel = 'degrees';
end
    

ra1 = attitude1.ra;
dec1 = attitude1.dec;
roll1 = attitude1.roll;

ra2 = attitude2.ra;
dec2 = attitude2.dec;
roll2 = attitude2.roll;

metricStruct.ra1  = ra1.values; % an array of structs 1x84
attitudeSolutionRaUncertainties1  = ra1.uncertainties; % an array of structs 1x84
metricStruct.ra2  = ra2.values; % an array of structs 1x84
attitudeSolutionRaUncertainties2  = ra2.uncertainties; % an array of structs 1x84
attitudeSolutionRaUncertainties = sqrt(attitudeSolutionRaUncertainties1.^2 + attitudeSolutionRaUncertainties2.^2);
metricStruct.raUncertainties = attitudeSolutionRaUncertainties;

metricStruct.dec1  = dec1.values; % an array of structs 1x84
attitudeSolutionDecUncertainties1  = dec1.uncertainties; % an array of structs 1x84
metricStruct.dec2  = dec2.values; % an array of structs 1x84
attitudeSolutionDecUncertainties2  = dec2.uncertainties; % an array of structs 1x84
attitudeSolutionDecUncertainties = sqrt(attitudeSolutionDecUncertainties1.^2 + attitudeSolutionDecUncertainties2.^2);
metricStruct.decUncertainties = attitudeSolutionDecUncertainties;


metricStruct.roll1  = roll1.values; % an array of structs 1x84
attitudeSolutionRollUncertainties1  = roll1.uncertainties; % an array of structs 1x84
metricStruct.roll2  = roll2.values; % an array of structs 1x84
attitudeSolutionRollUncertainties2  = roll2.uncertainties; % an array of structs 1x84
attitudeSolutionRollUncertainties = sqrt(attitudeSolutionRollUncertainties1.^2 + attitudeSolutionRollUncertainties2.^2);
metricStruct.rollUncertainties = attitudeSolutionRollUncertainties;


metricStruct.metricNameString = metricNameString;
metricStruct.figureFileName = figureFileName;
printJpgFlag = true;

version1Str = commonStruct.version1Str;
version2Str = commonStruct.version2Str;

close all;
figure(1);


validCadences1 = find(metricStruct.ra1 ~= -1);
validCadences2 = find(metricStruct.ra2 ~= -1);


if(isempty(validCadences1) && isempty(validCadences2))
    return;
end
%---------------------------------------------------------------------------
% plot ra
%---------------------------------------------------------------------------
subplot(3,2,1);
if(~isempty(validCadences1))
    h1 = plot(validCadences1, metricStruct.ra1(validCadences1),'ro-');
end
hold on;

if(~isempty(validCadences2))
    h2 = plot(validCadences2, metricStruct.ra2(validCadences2),'b.--');
end
lastCadence = validCadences2(end)+1;
xlim([0 lastCadence+2]);
set(gca, 'xTick', 0:lastCadence:lastCadence+2, 'xTickLabel', [1 lastCadence]');
set(gca, 'fontsize',8);
legend([h1 h2], {[version1Str ' ra'], [version2Str ' ra']});
xlabel('cadences');
ylabel(yUnitsLabel);

subplot(3,2,2);

plot(validCadences2, metricStruct.raUncertainties(validCadences2),'b.--');
hold on;
h4 = plot(validCadences2, -metricStruct.raUncertainties(validCadences2),'b.--');
h5 = plot(validCadences2, metricStruct.ra1(validCadences2) - metricStruct.ra2(validCadences2),'m.-');
legend([h4 h5], {'uncertainties on ra', 'differences in ra'});


xlim([0 lastCadence+2]);
set(gca, 'xTick', 0:lastCadence:lastCadence+2, 'xTickLabel', [1 lastCadence]');
set(gca, 'fontsize',8);
xlabel('cadences');
ylabel(yUnitsLabel);

%---------------------------------------------------------------------------
% plot dec
%---------------------------------------------------------------------------
subplot(3,2,3);

if(~isempty(validCadences1))
    h1 = plot(validCadences1, metricStruct.dec1(validCadences1),'ro-');
end
hold on;

if(~isempty(validCadences2))
    h2 = plot(validCadences2, metricStruct.dec2(validCadences2),'b.--');
end
lastCadence = validCadences2(end)+1;
xlim([0 lastCadence+2]);
set(gca, 'xTick', 0:lastCadence:lastCadence+2, 'xTickLabel', [1 lastCadence]');
legend([h1 h2], {[version1Str ' dec'], [version2Str ' dec']});
set(gca, 'fontsize',8);

xlabel('cadences');
ylabel(yUnitsLabel);

subplot(3,2,4);

plot(validCadences2, metricStruct.decUncertainties(validCadences2),'b.--');
hold on;
h4 = plot(validCadences2, -metricStruct.decUncertainties(validCadences2),'b.--');
h5 = plot(validCadences2, metricStruct.dec1(validCadences2) - metricStruct.dec2(validCadences2),'m.-');
legend([h4 h5], {'uncertainties on dec', 'differences in dec'});


xlim([0 lastCadence+2]);
set(gca, 'xTick', 0:lastCadence:lastCadence+2, 'xTickLabel', [1 lastCadence]');
set(gca, 'fontsize',8);

xlabel('cadences');
ylabel(yUnitsLabel);

%---------------------------------------------------------------------------
% plot roll
%---------------------------------------------------------------------------
subplot(3,2,5);
if(~isempty(validCadences1))
    h1 = plot(validCadences1, metricStruct.roll1(validCadences1),'ro-');
end
hold on;

if(~isempty(validCadences2))
    h2 = plot(validCadences2, metricStruct.roll2(validCadences2),'b.--');
end
lastCadence = validCadences2(end)+1;
xlim([0 lastCadence+2]);
set(gca, 'xTick', 0:lastCadence:lastCadence+2, 'xTickLabel', [1 lastCadence]');
legend([h1 h2], {[version1Str ' roll'], [version2Str ' roll']});
set(gca, 'fontsize',8);
xlabel('cadences');
ylabel(yUnitsLabel);

subplot(3,2,6);

plot(validCadences2, metricStruct.rollUncertainties(validCadences2),'b.--');
hold on;
h4 = plot(validCadences2, -metricStruct.rollUncertainties(validCadences2),'b.--');
h5 = plot(validCadences2, metricStruct.roll1(validCadences2) - metricStruct.roll2(validCadences2),'m.-');
legend([h4 h5], {'uncertainties on roll', 'differences in roll'});


xlim([0 lastCadence+2]);
set(gca, 'xTick', 0:lastCadence:lastCadence+2, 'xTickLabel', [1 lastCadence]');
set(gca, 'fontsize',8);
xlabel('cadences');
ylabel(yUnitsLabel);


ah1 = annotation('textbox',[0.35 0.95 0.5 0.05], 'LineStyle', 'none');
set(ah1, 'String', metricNameString, 'fontsize', 12)

saveas(gcf, [metricStruct.figureFileName '.fig']);



if(printJpgFlag)
    
    set(gcf, 'PaperPositionMode', 'manual');
    set(gcf, 'PaperUnits', 'inches');
    set(gcf, 'PaperType', 'C');
    
    set(gcf, 'PaperPosition',[0 0 11 8.5]);
    
    %     fprintf('\n\nSaving the plot to a file named %s \n', fileName);
    %     fprintf('Please wait....\n\n');
    
    print('-djpeg', '-zbuffer', [metricStruct.figureFileName '.jpg']);
    
end
