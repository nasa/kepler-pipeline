function pmd_plot_track_trend_summary(report, alertString, titleString)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function pmd_plot_track_trend_summary(report, alertString, titleString)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% This function generates PMD track and trend summary plot.
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

xR1 = [   0  10  20   0  10  20  0 10 20  0 10 20];
yR1 = [ 110 110 110 100 100 100 90 90 90 80 80 80];
xR2 = [  40  50  60  40  50  60 40 50 60 40 50 60];
yR2 = [ 110 110 110 100 100 100 90 90 90 80 80 80];
xR3 = [  0 10 20  0 10 20  0 10 20  0 10 20  0 10 20  0 10 20  0 10 20 ];
yR3 = [ 50 50 50 40 40 40 30 30 30 20 20 20 10 10 10 10 10 10  0  0  0 ];
xR4 = [ 40 50 60 40 50 60 40 50 60 40 50 60 40 50 60 40 50 60 40 50 60 ];
yR4 = [ 60 60 60 50 50 50 40 40 40 30 30 30 20 20 20 10 10 10  0  0  0 ];

set(gca, 'xtick', [], 'ytick', [], 'FontSize', 6);
title(titleString);
rectangle('Position', [0,  0, 70, 120], 'FaceColor', 'w', 'LineStyle', 'none');

plot_metrics_alert_level(report, alertString, xR1( 1),  yR1( 1), 'blackLevel','black','level'         );
plot_metrics_alert_level(report, alertString, xR1( 2),  yR1( 2), 'smearLevel','smear','level'         );
plot_metrics_alert_level(report, alertString, xR1( 3),  yR1( 3), 'darkCurrent','dark','current'        );

plot_metrics_alert_level(report, alertString, xR1( 4),  yR1( 4), 'brightness'         );
plot_metrics_alert_level(report, alertString, xR1( 5),  yR1( 5), 'encircledEnergy','encircled','energy'    );
plot_metrics_alert_level(report, alertString, xR1( 6),  yR1( 6), 'backgroundLevel','background','level');

plot_metrics_alert_level(report, alertString, xR1( 7),  yR1( 7), 'centroidsMeanRow','centroids','mean row');
plot_metrics_alert_level(report, alertString, xR1( 8),  yR1( 8), 'centroidsMeanColumn','centroids','mean column');
plot_metrics_alert_level(report, alertString, xR1( 9),  yR1( 9), 'plateScale','plate','scale'         );

plot_metrics_alert_level(report, alertString, xR1(10),  yR1(10), 'theoreticalCompressionEfficiency', 'theoretical','CE');
plot_metrics_alert_level(report, alertString, xR1(11),  yR1(11), 'achievedCompressionEfficiency',    'achieved','CE'   );

plot_metrics_array_alert_level(report, alertString, xR2, yR2);

text(5,68,'Cosmic Ray Metrics')
text(1.5,63,'Hit Rate') ;
text(12,63,'Mean') ;
text(21,63,'Variance') ;
plot_cosmic_ray_alert_level(report, alertString, xR3( 1), yR3( 1), 'black',        'hitRate',        'black'        );
plot_cosmic_ray_alert_level(report, alertString, xR3( 2), yR3( 2), 'black',        'meanEnergy',     'black'           );
plot_cosmic_ray_alert_level(report, alertString, xR3( 3), yR3( 3), 'black',        'energyVariance', 'black'       );

plot_cosmic_ray_alert_level(report, alertString, xR3( 4), yR3( 4), 'maskedSmear',  'hitRate',        'masked','smear'  );
plot_cosmic_ray_alert_level(report, alertString, xR3( 5), yR3( 5), 'maskedSmear',  'meanEnergy',     'masked','smear'     );
plot_cosmic_ray_alert_level(report, alertString, xR3( 6), yR3( 6), 'maskedSmear',  'energyVariance', 'masked','smear' );

plot_cosmic_ray_alert_level(report, alertString, xR3( 7), yR3( 7), 'virtualSmear', 'hitRate',        'virtual','smear' );
plot_cosmic_ray_alert_level(report, alertString, xR3( 8), yR3( 8), 'virtualSmear', 'meanEnergy',     'virtual','smear'    );
plot_cosmic_ray_alert_level(report, alertString, xR3( 9), yR3( 9), 'virtualSmear', 'energyVariance', 'virtual','smear');

plot_cosmic_ray_alert_level(report, alertString, xR3(10), yR3(10), 'targetStar',   'hitRate',        'target','star'   );
plot_cosmic_ray_alert_level(report, alertString, xR3(11), yR3(11), 'targetStar', 	 'meanEnergy',     'target','star'      );
plot_cosmic_ray_alert_level(report, alertString, xR3(12), yR3(12), 'targetStar',   'energyVariance', 'target','star'  );

plot_cosmic_ray_alert_level(report, alertString, xR3(13), yR3(13), 'background',   'hitRate',        'background'   );
plot_cosmic_ray_alert_level(report, alertString, xR3(14), yR3(14), 'background',   'meanEnergy',     'background'      );
plot_cosmic_ray_alert_level(report, alertString, xR3(15), yR3(15), 'background',   'energyVariance', 'background'  );

text(48,78,'CDPP Metrics') ;
text(43,73,'3 hr') ;
text(53,73,'6 hr') ;
text(62,73,'12 hr') ;

text(35.5,64,'M09') ;
text(35.5,54,'M10') ;
text(35.5,44,'M11') ;
text(35.5,34,'M12') ;
text(35.5,24,'M13') ;
text(35.5,14,'M14') ;
text(35.5,04,'M15') ;
plot_cdpp_alert_level(report, alertString, xR4( 1), yR4( 1), 'mag9',  'threeHour',  ' '  );
plot_cdpp_alert_level(report, alertString, xR4( 2), yR4( 2), 'mag9',  'sixHour',    ' '  );
plot_cdpp_alert_level(report, alertString, xR4( 3), yR4( 3), 'mag9',  'twelveHour', ' ' );

plot_cdpp_alert_level(report, alertString, xR4( 4), yR4( 4), 'mag10', 'threeHour',  ' ' );
plot_cdpp_alert_level(report, alertString, xR4( 5), yR4( 5), 'mag10', 'sixHour',    ' ' );
plot_cdpp_alert_level(report, alertString, xR4( 6), yR4( 6), 'mag10', 'twelveHour', ' ');

plot_cdpp_alert_level(report, alertString, xR4( 7), yR4( 7), 'mag11', 'threeHour',  ' ' );
plot_cdpp_alert_level(report, alertString, xR4( 8), yR4( 8), 'mag11', 'sixHour',    ' ' );
plot_cdpp_alert_level(report, alertString, xR4( 9), yR4( 9), 'mag11', 'twelveHour', ' ');

plot_cdpp_alert_level(report, alertString, xR4(10), yR4(10), 'mag12', 'threeHour',  ' ' );
plot_cdpp_alert_level(report, alertString, xR4(11), yR4(11), 'mag12', 'sixHour',    ' ' );
plot_cdpp_alert_level(report, alertString, xR4(12), yR4(12), 'mag12', 'twelveHour', ' ');

plot_cdpp_alert_level(report, alertString, xR4(13), yR4(13), 'mag13', 'threeHour',  ' ' );
plot_cdpp_alert_level(report, alertString, xR4(14), yR4(14), 'mag13', 'sixHour',    ' ' );
plot_cdpp_alert_level(report, alertString, xR4(15), yR4(15), 'mag13', 'twelveHour', ' ');

plot_cdpp_alert_level(report, alertString, xR4(16), yR4(16), 'mag14', 'threeHour',  ' ' );
plot_cdpp_alert_level(report, alertString, xR4(17), yR4(17), 'mag14', 'sixHour',    ' ' );
plot_cdpp_alert_level(report, alertString, xR4(18), yR4(18), 'mag14', 'twelveHour', ' ');

plot_cdpp_alert_level(report, alertString, xR4(19), yR4(19), 'mag15', 'threeHour',  ' ' );
plot_cdpp_alert_level(report, alertString, xR4(20), yR4(20), 'mag15', 'sixHour',    ' ' );
plot_cdpp_alert_level(report, alertString, xR4(21), yR4(21), 'mag15', 'twelveHour', ' ');



return




function plot_alert_level(alertLevel, xPos, yPos, nameString1, nameString2)

colorCode = {'c' 'g' 'y' 'r'};
width     = 10;
height    = 10;
rectangle('Position', [xPos, yPos, width, height], 'FaceColor', colorCode{alertLevel+2}, 'LineStyle', '-');
if (isempty(deblank(nameString2)))
   text(xPos+1, yPos+4, nameString1, 'FontSize', 7);
else
   text(xPos+1, yPos+6, nameString1,'FontSize',7) ;
   text(xPos+1, yPos+3, nameString2,'FontSize',7) ;
end


function plot_metrics_alert_level(report, alertString, xPos, yPos, metricString, nameString1, nameString2)

if ~exist('nameString1', 'var')
    nameString1 = metricString;
end
if ~exist('nameString2', 'var')
    nameString2 = ' ' ;
end
eval(['alertLevel = report.' metricString '.' alertString ';']);
plot_alert_level(alertLevel, xPos, yPos, nameString1, nameString2);


function plot_metrics_array_alert_level(report, alertString, xPos, yPos)

nLdeUndershoot = length(report.ldeUndershoot);
for iLdeUndershoot = 1:min(6,nLdeUndershoot)
    eval(['alertLevel = report.ldeUndershoot(' num2str(iLdeUndershoot) ').' alertString ';']);
    plot_alert_level(alertLevel, xPos(iLdeUndershoot), yPos(iLdeUndershoot), 'ldeUnder-', ['shoot ',num2str(iLdeUndershoot)]);
end

nTwoDBlack = length(report.twoDBlack);
for iTwoDBlack = 1:min(6,nTwoDBlack)
    eval(['alertLevel = report.twoDBlack(' num2str(iTwoDBlack) ').' alertString ';']);
    plot_alert_level(alertLevel, xPos(3+iTwoDBlack),   yPos(3+iTwoDBlack),   'twoDBlack', num2str(iTwoDBlack));
end




function plot_cosmic_ray_alert_level(report, alertString, xPos, yPos, crString, fieldString, nameString1, nameString2)

eval(['alertLevel = report.' crString 'CosmicRayMetrics.' fieldString '.' alertString ';']);
if ~exist('nameString2', 'var')
    nameString2 = ' ' ;
end
plot_alert_level(alertLevel, xPos, yPos, nameString1, nameString2);


function plot_cdpp_alert_level(report, alertString, xPos, yPos, magString, hourString, nameString)

colorCode = {'c' 'g' 'y' 'r'};
width     = 3;
height    = 10;
eval(['alertLevel = report.cdppMeasured.' magString '.' hourString '.' alertString ';']);
rectangle('Position', [xPos,   yPos, width, height], 'FaceColor', colorCode{alertLevel+2}, 'LineStyle', '-');
text(xPos+0.5, yPos+3, 'measured', 'FontSize', 5);
eval(['alertLevel = report.cdppExpected.' magString '.' hourString '.' alertString ';']);
rectangle('Position', [xPos+3, yPos, width, height], 'FaceColor', colorCode{alertLevel+2}, 'LineStyle', '-');
text(xPos+3.5, yPos+3, 'expected', 'FontSize', 5);
eval(['alertLevel = report.cdppRatio.'    magString '.' hourString '.' alertString ';']);
rectangle('Position', [xPos+6, yPos, width, height], 'FaceColor', colorCode{alertLevel+2}, 'LineStyle', '-');
text(xPos+7,   yPos+3, 'ratio', 'FontSize', 5);
text(xPos+2, yPos+6, nameString, 'FontSize', 5);

