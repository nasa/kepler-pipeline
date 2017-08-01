%% test retrieve_ancillary_data()
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

constants;

plotYOffsetLarge = 100;
plotYOffset = 50;

startMjd = datestr2mjd('October 19 2000');
endMjd = startMjd + 10000;

% prepare the keyword list
nModules = length(IDX_MOD_OUTS);
modoutTempKeywords = cell( nModules, 1 );
for k=1:nModules
    modoutTempKeywords(k) = { ['PEDFPAMOD' num2str( IDX_MOD_OUTS(k), '%02d') 'T' ]};
end
 
%LDE driver and acquisition temperature
nLDEDrvBoards = 5;
nLDEAcqBoards = 5;
ldeDrvTempKeywords = cell(nLDEDrvBoards, 1);
ldeAcqTempKeywords = cell(nLDEAcqBoards, 1);
for k=1:nLDEDrvBoards
    ldeDrvTempKeywords(k) = { ['PEDDRV' num2str( k, '%1d') 'T' ]};
end
for k=1:nLDEAcqBoards
    ldeAcqTempKeywords(k) = { ['PEDACQ' num2str( k, '%1d') 'T' ]};
end

%[ancillaryData, mnemonics] = retrieve_ancillary_data(modoutTempKeywords, startMjd, endMjd);
[ancillaryDataFpa] = retrieve_ancillary_data(modoutTempKeywords, startMjd, endMjd);

[ancillaryDataDrv] = retrieve_ancillary_data(ldeDrvTempKeywords, startMjd, endMjd);

[ancillaryDataAcq] = retrieve_ancillary_data(ldeAcqTempKeywords, startMjd, endMjd);

% check data validity
[nRows, nCols] = size(ancillaryDataFpa);

if ~( nCols == nModules && nRows == 1)
    error('Number of FPA temperature series not equal to number of modouts');
end

[nRows, nCols] = size(ancillaryDataDrv);
drvNo= 5;
if ~( nCols == drvNo && nRows == 1)
    error('Number of Drv temperature series not equal to number of modouts');
end

[nRows, nCols] = size(ancillaryDataAcq);
acqNo = 5;
if ~( nCols == acqNo && nRows == 1)
    error('Number of Drv temperature series not equal to number of modouts');
end

% plot the three sets of temperature data
fpaNo = nModules;
nFpaSamples = length(ancillaryDataFpa(1).values);
fpaTempVals = zeros(nFpaSamples, nModules);
fpaTempTS  = zeros(nFpaSamples, nModules);
for k = 1:nModules
    fpaTempVals(:, k) = ancillaryDataFpa(k).values;
    fpaTempTS(:, k) = ancillaryDataFpa(k).timestamps;
end

yAxisTicks = zeros(1, fpaNo);
yAxisTickLabels = cell(1, fpaNo);

fig1 = figure('Tag', 'FpaPlot'); hold on;
for k = 1:nModules
    plot( fpaTempTS(:, k), fpaTempVals(:, k) + (k-1)*plotYOffsetLarge );
    yMed = median(fpaTempVals(:, k));
    yAxisTicks(1, k) = yMed + (k - 1) * plotYOffsetLarge;
    yAxisTickLabels(1, k) = { ['Series ' num2str(k, '%1d') ': ' num2str( yMed )]};   
end

set(gca,'YTick', yAxisTicks);
set(gca,'YTickLabel',yAxisTickLabels);
xlabel('Time stamps')
ylabel('Temperatures');
xlim([ min(fpaTempTS(:)),  max(fpaTempTS(:))])
title('Plots of FPA temperature values against time stamps');
hold off;
%% Driver and acquisition board temperature

% LDE Driver boardfs

nDrvSamples = length(ancillaryDataDrv(1).values);
drvTempVals = zeros(nDrvSamples, drvNo);
drvTempTS  = zeros(nDrvSamples, drvNo);
for k = 1:drvNo
    drvTempVals(:, k) = ancillaryDataDrv(k).values;
    drvTempTS(:, k) = ancillaryDataDrv(k).timestamps;
end

yAxisTicks = zeros(1, acqNo);
yAxisTickLabels = cell(1, acqNo);

fig3 = figure('Tag', 'DrvAcqPlot');

for k =1:drvNo
    subplot(2, 1, 1), hold on,
    plot(drvTempTS(:, k), drvTempVals(:, k) + (k-1)*plotYOffset ); 
    yMed = median(drvTempVals(:, k));
    yAxisTicks(1, k) = yMed + (k - 1) * plotYOffset;
    yAxisTickLabels(1, k) = { ['Series ' num2str(k, '%1d') ': ' num2str( yMed )]}; 
end

set(gca,'YTick', yAxisTicks);
set(gca,'YTickLabel',yAxisTickLabels);
xlabel('Time stamps')
ylabel('Temperatures');
xlim([ min(drvTempTS(:)),  max(drvTempTS(:))])
title('LDE driver board temperature');
hold off;

% Acquisition board

nAcqSamples = length(ancillaryDataAcq(1).values);
acqTempVals = zeros(nAcqSamples, acqNo);
acqTempTS  = zeros(nAcqSamples, acqNo);
for k = 1:acqNo
    acqTempVals(:, k) = ancillaryDataAcq(k).values;
    acqTempTS(:, k) = ancillaryDataAcq(k).timestamps;
end

yAxisTicks = zeros(1, acqNo);
yAxisTickLabels = cell(1, acqNo);

for k = 1:acqNo
    subplot(2, 1, 2); hold on;
    plot( acqTempTS(:, k), acqTempVals(:, k) + (k - 1) * plotYOffset );
    yAxisTicks(1, k) = median(acqTempVals(:, k)) + (k - 1) * plotYOffset;
    yAxisTickLabels(1, k) = { ['Series ' num2str(k, '%1d') ': ' num2str( median(acqTempVals(:, k)) )]};
end

set(gca,'YTick', yAxisTicks);
set(gca,'YTickLabel',yAxisTickLabels);
xlabel('Time stamps')
ylabel('Temperatures');
xlim([ min(acqTempTS(:)),  max(acqTempTS(:))])
title('LDE acquisition board temperature');
hold off;
