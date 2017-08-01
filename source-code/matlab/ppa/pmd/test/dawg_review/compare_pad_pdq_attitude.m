function [outDir] = compare_pad_pdq_attitude(padDir,pdqDir)
% function [outDir] = compare_pad_pdq_attitude(padDir,pdqDir)
%
% function to generate four figures with PAD & PDQ attitude determination
% overlayed: ra, dec, roll, mar
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

% get PDQ results
load( fullfile(pdqDir, 'pdq-inputs-0.mat')  );
if exist(fullfile(pdqDir, 'pdq-outputs-0.mat'),'file')
    load( fullfile(pdqDir, 'pdq-outputs-0.mat') );
    k2Flag=false;
elseif exist(fullfile(pdqDir,'pdqOutputStruct.mat')) % K2 format
    load( fullfile(pdqDir,'pdqOutputStruct.mat') );
    k2Flag=true;
else
    error('compare_pad_pdq: no PDQ output struct')
end


pdqInputStruct  = inputsStruct;
pdqOutputStruct = outputsStruct;
clear inputsStruct outputsStruct

% get PAD results
load( fullfile(padDir, 'pad-inputs-0.mat')  );
load( fullfile(padDir, 'pad-outputs-0.mat') );

cadenceTimes = inputsStruct.cadenceTimes.midTimestamps;
startMjd= floor(cadenceTimes(1));

gapIndicators = outputsStruct.attitudeSolution.gapIndicators;

pointingObject = pointingClass(inputsStruct.raDec2PixModel.pointingModel);
nominalPointing = get_pointing(pointingObject, cadenceTimes(~gapIndicators));

hf1=figure;
plot(cadenceTimes(~gapIndicators)-startMjd, (nominalPointing(:,1)-outputsStruct.attitudeSolution.ra(~gapIndicators)).*cos(nominalPointing(:, 2)*pi/180)*3600, '.-')
xlabel(['Elapsed Days Since MJD ' num2str(startMjd)], 'fontSize', 12);
ylabel('delta RA * cos(dec) [arcsec]', 'fontSize', 12);
if ~k2Flag
    axis([0 100 -0.2 0.2]);
end


hf2=figure;
plot(cadenceTimes(~gapIndicators)-startMjd, (nominalPointing(:,2)-outputsStruct.attitudeSolution.dec(~gapIndicators))*3600, '.-')
xlabel(['Elapsed Days Since MJD ' num2str(startMjd)], 'fontSize', 12);
ylabel('delta Dec [arcsec]', 'fontSize', 12);
if ~k2Flag
    axis([0 100 -0.2 0.2]);
end

hf3=figure;
plot(cadenceTimes(~gapIndicators)-startMjd, (nominalPointing(:,3)-outputsStruct.attitudeSolution.roll(~gapIndicators))*3600, '.-')
xlabel(['Elapsed Days Since MJD ' num2str(startMjd)], 'fontSize', 12);
ylabel('delta Roll [arcsec]', 'fontSize', 12);
if ~k2Flag
    axis([0 100 -1 1]);
end

hf4=figure;
plot(cadenceTimes(~gapIndicators)-startMjd, outputsStruct.attitudeSolution.maxAttitudeFocalPlaneResidual(~gapIndicators), '.-')
xlabel(['Elapsed Days Since MJD ' num2str(startMjd)], 'fontSize', 12);
ylabel('Max Focal Plane Residual [pixel]', 'fontSize', 12);
if ~k2Flag
    axis([0 100 0 0.1]);
end


pdqCadenceTimes    = pdqOutputStruct.outputPdqTsData.cadenceTimes;
%check that pdq times fit w/in pointing model range
pdqIndices = logical(ones(size(pdqCadenceTimes)));
iearly = find(pdqCadenceTimes < cadenceTimes(1));
pdqIndices(iearly) = false;
ilate = find(pdqCadenceTimes > cadenceTimes(end));
pdqIndices(ilate) =false;


pdqNominalPointing = get_pointing(pointingObject, pdqCadenceTimes(pdqIndices));

figure(hf1)
hold on
plot(pdqCadenceTimes(pdqIndices)-startMjd, (pdqNominalPointing(:,1)-pdqOutputStruct.outputPdqTsData.attitudeSolutionRa.values(pdqIndices)).*cos(pdqNominalPointing(:,2)*pi/180)*3600, 'r*');
legend('PAD', 'PDQ');
grid on;
title('Differences between Nominal Attitude and PAD/PDQ Attitude: RA', 'fontSize', 12)
print(hf1,'-dpng','pad_pdq_attitude_ra')

figure(hf2)
hold on
plot(pdqCadenceTimes(pdqIndices)-startMjd, (pdqNominalPointing(:,2)-pdqOutputStruct.outputPdqTsData.attitudeSolutionDec.values(pdqIndices))*3600, 'r*');
legend('PAD', 'PDQ');
grid on;
title('Differences between Nominal Attitude and PAD/PDQ Attitude: Dec', 'fontSize', 12)
print(hf2,'-dpng','pad_pdq_attitude_dec')

figure(hf3)
hold on
plot(pdqCadenceTimes(pdqIndices)-startMjd, (pdqNominalPointing(:,3)-pdqOutputStruct.outputPdqTsData.attitudeSolutionRoll.values(pdqIndices))*3600, 'r*');
legend('PAD', 'PDQ');
grid on;
title('Differences between Nominal Attitude and PAD/PDQ Attitude: Roll', 'fontSize', 12)
print(hf3,'-dpng','pad_pdq_attitude_roll')

figure(hf4)
hold on
plot(pdqCadenceTimes(pdqIndices)-startMjd, pdqOutputStruct.outputPdqTsData.maxAttitudeResidualInPixels.values(pdqIndices), 'r*');
grid;
legend('PAD', 'PDQ');
title('Maximum Focal Plane Residual of PAD/PDQ Attitude', 'fontSize', 12)
print(hf4,'-dpng','pad_pdq_attitude_mar')

hfu1=figure;
plot(cadenceTimes(~gapIndicators)-startMjd, sqrt(outputsStruct.attitudeSolution.covarianceMatrix11(~gapIndicators))*3600, '.-')
hold on
plot(pdqCadenceTimes(pdqIndices)-startMjd, pdqOutputStruct.outputPdqTsData.attitudeSolutionRa.uncertainties(pdqIndices)*3600, 'r*');
if ~k2Flag
    axis([0 100 0 0.03]);
end
grid;
legend('PAD', 'PDQ');
xlabel(['Elapsed Days Since MJD ' num2str(startMjd)], 'fontSize', 12);
ylabel('Uncertainty of RA [arcsec]', 'fontSize', 12);
title('Uncertainty of PAD/PDQ Attitude: RA', 'fontSize', 12)

hfu2=figure;
plot(cadenceTimes(~gapIndicators)-startMjd, sqrt(outputsStruct.attitudeSolution.covarianceMatrix22(~gapIndicators))*3600, '.-')
hold on
plot(pdqCadenceTimes(pdqIndices)-startMjd, pdqOutputStruct.outputPdqTsData.attitudeSolutionDec.uncertainties(pdqIndices)*3600, 'r*');
if ~k2Flag
    axis([0 100 0 0.03]);
end
grid;
legend('PAD', 'PDQ');
xlabel(['Elapsed Days Since MJD ' num2str(startMjd)], 'fontSize', 12);
ylabel('Uncertainty of Dec [arcsec]', 'fontSize', 12);
title('Uncertainty of PAD/PDQ Attitude: Dec', 'fontSize', 12)

hfu3=figure;
plot(cadenceTimes(~gapIndicators)-startMjd, sqrt(outputsStruct.attitudeSolution.covarianceMatrix33(~gapIndicators))*3600, '.-')
hold on
plot(pdqCadenceTimes(pdqIndices)-startMjd, pdqOutputStruct.outputPdqTsData.attitudeSolutionRoll.uncertainties(pdqIndices)*3600, 'r*');
if ~k2Flag
    axis([0 100 0 0.3]);
end
grid;
legend('PAD', 'PDQ');
xlabel(['Elapsed Days Since MJD ' num2str(startMjd)], 'fontSize', 12);
ylabel('Uncertainty of Roll [arcsec]', 'fontSize', 12);
title('Uncertainty of PAD/PDQ Attitude: Roll', 'fontSize', 12)

outDir = pwd;


