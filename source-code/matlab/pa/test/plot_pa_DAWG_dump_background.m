function plot_pa_DAWG_dump_background( Z )
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

mod     = Z.module;
out     = Z.output;
cads    = Z.cadences;
gaps    = Z.gapIndicators;

meanFitVals     = Z.meanFittedValue;
medianNormResid = Z.medianNormalizedResidual;
madNormResid    = Z.madNormalizedResidual;
medianNormUnc   = Z.medianNormalizedPixelUncertainty;
madNormUnc      = Z.madNormalizedPixelUncertainty;
extremeOutliers = Z.extremeOutlierCount;


lowPercentile = .1;
highPercentile = 99.9;


figureBoxDimensions = [475   200];
figureEdgeBuffer = [10 20];

figureBoxPositioner = [0 4 1 1;
                 1 4 1 1;
                 0 3 1 1;
                 1 3 1 1;
                 0 2 1 1;
                 1 2 1 1;
                 2 4 1 1;
                 3 4 1 1;
                 2 3 1 1;
                 3 3 1 1;
                 2 2 1 1];
             

% figure position array
P = ( repmat([figureBoxDimensions,figureBoxDimensions],11,1) + repmat([figureEdgeBuffer,0,0],11,1) ) .* figureBoxPositioner;



figure(1);
set(gcf,'Position',P(1,:));
set(gcf,'Name',['Module ',num2str(mod),', Output ',num2str(out),' - Mean Fitted Background']);
set(gcf,'NumberTitle','off');
set(gcf,'MenuBar','none')
plot(cads(~gaps),meanFitVals(~gaps),'.');
grid;
xlabel('cadence');
ylabel('e- per cadence');
title('Mean Fitted Background');

figure(2);
set(gcf,'Position',P(2,:));
set(gcf,'Name',['Module ',num2str(mod),', Output ',num2str(out),' - Mean Fitted Background']);
set(gcf,'NumberTitle','off');
set(gcf,'MenuBar','none')
low = prctile(meanFitVals,lowPercentile);
high = prctile(meanFitVals,highPercentile);
X = meanFitVals(~gaps);
hist(X(X>low & X<high),101);
xlabel('mean fit value (e-)');
ylabel('occurances');
title('Mean Fitted Background');

figure(3);
set(gcf,'Position',P(3,:));
set(gcf,'Name',['Module ',num2str(mod),', Output ',num2str(out),' - Median Residual']);
set(gcf,'NumberTitle','off');
set(gcf,'MenuBar','none')
plot(cads(~gaps),medianNormResid(~gaps),'.');
xlabel('cadence');
ylabel('median residual (propagated sigma)');
title('Median Residual Normalized to Propagated Uncertainty');

figure(4);
set(gcf,'Position',P(4,:));
set(gcf,'Name',['Module ',num2str(mod),', Output ',num2str(out),' - Median Residual']);
set(gcf,'NumberTitle','off');
set(gcf,'MenuBar','none')
low = prctile(medianNormResid,lowPercentile);
high = prctile(medianNormResid,highPercentile);
X = medianNormResid(~gaps);
hist(X(X>low & X<high),101);
xlabel('median residual (propagated sigma)');
ylabel('occurances');
title('Median Residual Normalized to Propagated Uncertainty');

figure(5);
set(gcf,'Position',P(5,:));
set(gcf,'Name',['Module ',num2str(mod),', Output ',num2str(out),' - MAD Residual']);
set(gcf,'NumberTitle','off');
set(gcf,'MenuBar','none')
plot(cads(~gaps),madNormResid(~gaps),'.');
xlabel('cadence');
ylabel('mad residual (propagated sigma)');
title('Mad Residual Normalized to Propagated Uncertainty');

figure(6);
set(gcf,'Position',P(6,:));
set(gcf,'Name',['Module ',num2str(mod),', Output ',num2str(out),' - MAD Residual']);
set(gcf,'NumberTitle','off');
set(gcf,'MenuBar','none')
low = prctile(madNormResid,lowPercentile);
high = prctile(madNormResid,highPercentile);
X = madNormResid(~gaps);
hist(X(X>low & X<high),101);
xlabel('mad residual (propagated sigma)');
ylabel('occurances');
title('Mad Residual Normalized to Propagated Uncertainty');

figure(7);
set(gcf,'Position',P(7,:));
set(gcf,'Name',['Module ',num2str(mod),', Output ',num2str(out),' - Median Uncertainty']);
set(gcf,'NumberTitle','off');
set(gcf,'MenuBar','none')
plot(cads(~gaps),medianNormUnc(~gaps),'.');
xlabel('cadence');
ylabel('median uncertainty (SD sigma)');
title('Median Pixel Uncertainties Normalized to STD');

figure(8);
set(gcf,'Position',P(8,:));
set(gcf,'Name',['Module ',num2str(mod),', Output ',num2str(out),' - Median Uncertainty']);
set(gcf,'NumberTitle','off');
set(gcf,'MenuBar','none')
low = prctile(medianNormUnc,lowPercentile);
high = prctile(medianNormUnc,highPercentile);
X = medianNormUnc(~gaps);
hist(X(X>low & X<high),101);
xlabel('median uncertainty (SD sigma)');
ylabel('occurances');
title('Median Pixel Uncertainties Normalized to STD');

figure(9);
set(gcf,'Position',P(9,:));
set(gcf,'Name',['Module ',num2str(mod),', Output ',num2str(out),' - MAD Uncertainty']);
set(gcf,'NumberTitle','off');
set(gcf,'MenuBar','none')
plot(cads(~gaps),madNormUnc(~gaps),'.');
xlabel('cadence');
ylabel('mad uncertainty (SD sigma)');
title('Mad Pixel Uncertainties Normalized to STD Background');

figure(10);
set(gcf,'Position',P(10,:));
set(gcf,'Name',['Module ',num2str(mod),', Output ',num2str(out),' - MAD Uncertainty']);
set(gcf,'NumberTitle','off');
set(gcf,'MenuBar','none')
low = prctile(medianNormUnc,lowPercentile);
high = prctile(medianNormUnc,highPercentile);
X = medianNormUnc(~gaps);
hist(X(X>low & X<high),101);
xlabel('mad uncertainty (SD sigma)');
ylabel('occurances');
title('Mad Pixel Uncertainties Normalized to STD Background');

figure(11);
set(gcf,'Position',P(11,:));
set(gcf,'Name',['Module ',num2str(mod),', Output ',num2str(out),' - Extreme Outliers']);
set(gcf,'NumberTitle','off');
set(gcf,'MenuBar','none')
plot(cads(~gaps),extremeOutliers(~gaps),'.');
xlabel('cadence');
ylabel('number');
title('Outliers Greater Then 50 Mad');




