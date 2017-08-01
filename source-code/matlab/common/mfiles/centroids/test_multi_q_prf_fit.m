% script to test multi-quarter PRF fit
% 
% Copyright 2017 United States Government as represented by the
% Administrator of the National Aeronautics and Space Administration.
% All Rights Reserved.
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

% testKepId = 9458613; % KOI-707
% testKepId = 6922244; % Kepler-8
testKepId = 10489525; % KOI-106
% testKepId = 3342970; % KOI-800, low SNR but deep
% testKepId = 10662202; % KOI-750, low SNR medium depth
planetNum = 1;

addpath('/path/to/false_positive/code');
addpath('/path/to/steve_utilities/');

% dvResultsLocation = '/path/to/dvReports_soc8VnV/';
dvResultsLocation = '/path/to/false_positives/results/dvReports_soc8VnV/';
dvOutputName = sprintf('%starget-%09.0f/dv-outputs-0.mat', dvResultsLocation, testKepId);
disp(['loading ' dvOutputName]);
load(dvOutputName);

load('/path/to/steve_utilities/dateStruct.mat');
load('/path/to/false_positives/hires_catalog/ukirt/smallKic_ukirt.mat');

kicIndx = find(newKic.kepid == testKepId);
seedRa = 15*newKic.ra(kicIndx);
seedDec = newKic.dec(kicIndx);

planetResults = outputsStruct.targetResultsStruct.planetResultsStruct(planetNum);
imageData = planetResults.differenceImageResults;

% collect the required PRFs
prfStruct = struct('prf', [], 'ccdModule', [], 'ccdOutput', []);
prfCount = 1;
for i=1:length(planetResults.pixelCorrelationResults)

	% don't add duplicates
	if ismember(planetResults.pixelCorrelationResults(i).ccdModule, [prfStruct.ccdModule]) ...
		& ismember(planetResults.pixelCorrelationResults(i).ccdOutput, [prfStruct.ccdOutput])
		continue;
	end
	
	prfModel = retrieve_prf_model(planetResults.pixelCorrelationResults(i).ccdModule, ...
        planetResults.pixelCorrelationResults(i).ccdOutput);
	prfStruct(prfCount).prf = prfCollectionClass(prfModel.blob, convert_fc_constants_java_2_struct());
	prfStruct(prfCount).ccdModule = planetResults.pixelCorrelationResults(i).ccdModule;
	prfStruct(prfCount).ccdOutput = planetResults.pixelCorrelationResults(i).ccdOutput;
	
	prfCount = prfCount + 1;
end

motionStruct = [];
for i=1:length(imageData)
    quarter = planetResults.pixelCorrelationResults(i).quarter;
    ds = dateStruct(quarter + 2);

    % get the motion polynomials for this quarter
    ts = retrieve_target_data(testKepId, ds.startCadence, ds.endCadence, ...
        'LONG', 'zero-based', 'MOTION_BLOBS', []);
    blobArray = ts.targetTables.modOuts.blobGroups.blobs;
    for b=1:length(blobArray)
       motionStruct = [motionStruct blob_to_struct(blobArray(b).blob)];
    end
end

motionPolynomialData.motionPolynomialStruct = motionStruct;
motionPolynomialData.fcConstants = convert_fc_constants_java_2_struct(); 
motionPolynomialData.pixelBaseCorrection = 1;

raDec2PixModel = retrieve_ra_dec_2_pix_model();
raDec2PixData.raDec2PixObject = raDec2PixClass(raDec2PixModel, 'zero-based');

for i=1:length(imageData)

	diffImageData(i).ccdModule = planetResults.pixelCorrelationResults(i).ccdModule;
	diffImageData(i).ccdOutput = planetResults.pixelCorrelationResults(i).ccdOutput;
	diffImageData(i).ccdRow = [imageData(i).differenceImagePixelStruct.ccdRow]';
	diffImageData(i).ccdColumn = [imageData(i).differenceImagePixelStruct.ccdColumn]';
	d = [imageData(i).differenceImagePixelStruct.meanFluxDifference];
	diffImageData(i).values = [d.value]';
	diffImageData(i).uncertainties = [d.uncertainty]';
	quarter = planetResults.pixelCorrelationResults(i).quarter;
	ds = dateStruct(quarter + 2);
	diffImageData(i).mjd = mean([ds.startMjd, ds.endMjd]);
	
	directImageData(i).ccdModule = diffImageData(i).ccdModule;
	directImageData(i).ccdOutput = diffImageData(i).ccdOutput;
	directImageData(i).ccdRow = diffImageData(i).ccdRow;
	directImageData(i).ccdColumn = diffImageData(i).ccdColumn;
	d = [imageData(i).differenceImagePixelStruct.meanFluxOutOfTransit];
	directImageData(i).values = [d.value]';
	directImageData(i).uncertainties = [d.uncertainty]';
	directImageData(i).mjd = diffImageData(i).mjd;
end

disp('=======================================');
disp('== average of single-quarter results');
disp('=======================================');

rs = new_mqc(testKepId, newKic, [], raDec2PixModel, outputsStruct);

disp('=======================================');
disp('== single multi-quarter fit w/ raDec2Pix');
disp('=======================================');


[directRa, directDec, centroidStatus, ...
	centroidCovariance, rowJacobian, columnJacobian, amplitude, directDiagnostics] ...
    = compute_multi_quarter_prf_fit(directImageData, prfStruct, raDec2PixData, seedRa, seedDec);
directRaSigma = sqrt(centroidCovariance(1,1));
directDecSigma = sqrt(centroidCovariance(2,2));

[diffRa, diffDec, centroidStatus, ...
	centroidCovariance, rowJacobian, columnJacobian, amplitude, diffDiagnostics] ...
    = compute_multi_quarter_prf_fit(diffImageData, prfStruct, raDec2PixData);
diffRaSigma = sqrt(centroidCovariance(1,1));
diffDecSigma = sqrt(centroidCovariance(2,2));

offset = centroidOffsetClass(testKepId);

offset.raDirectCentroid = dataClass(directRa, directRaSigma);
offset.decDirectCentroid = dataClass(directDec, directDecSigma);

offset.raDiffCentroid = dataClass(diffRa, diffRaSigma);
offset.decDiffCentroid = dataClass(diffDec, diffDecSigma);

offset = computeSkyOffset(offset);
printSkyComponentOffset(offset, 'multi-quarter PRF fit: ');
printSkyOffset(offset, 'multi-quarter PRF fit: ');

disp('=======================================');
disp('== single multi-quarter fit w/ motion polynomials');
disp('=======================================');

[directRa, directDec, centroidStatus, ...
	centroidCovariance, rowJacobian, columnJacobian, amplitude, directDiagnostics] ...
    = compute_multi_quarter_prf_fit(directImageData, prfStruct, motionPolynomialData, seedRa, seedDec);
directRaSigma = sqrt(centroidCovariance(1,1));
directDecSigma = sqrt(centroidCovariance(2,2));

[diffRa, diffDec, centroidStatus, ...
	centroidCovariance, rowJacobian, columnJacobian, amplitude, diffDiagnostics] ...
    = compute_multi_quarter_prf_fit(diffImageData, prfStruct, motionPolynomialData);
diffRaSigma = sqrt(centroidCovariance(1,1));
diffDecSigma = sqrt(centroidCovariance(2,2));

offset = centroidOffsetClass(testKepId);

offset.raDirectCentroid = dataClass(directRa, directRaSigma);
offset.decDirectCentroid = dataClass(directDec, directDecSigma);

offset.raDiffCentroid = dataClass(diffRa, diffRaSigma);
offset.decDiffCentroid = dataClass(diffDec, diffDecSigma);

offset = computeSkyOffset(offset);
printSkyComponentOffset(offset, 'multi-quarter PRF fit: ');
printSkyOffset(offset, 'multi-quarter PRF fit: ');

disp('=======================================');
disp('== bootstrap multi-quarter fit w/ raDec2Pix');
disp('=======================================');

tic;
[meanRaOffset, meanDecOffset, centroidFailed, offsetCovariance, ...
    raOffsets, decOffsets, quarterList] ...
    = bootstrap_multi_quarter_prf_fit(directImageData, ...
    diffImageData, prfStruct, raDec2PixData, seedRa, seedDec, 2);

if centroidFailed
    disp('bootstrap fit error');
    meanRaOffset = [];
end
disp(['bootstrap fit took ' num2str(toc/60) ' minutes']);
if isempty(meanRaOffset)
    continue;
end

bootstrapMeanOffset = centroidOffsetClass(testKepId);
bootstrapMeanOffset.raOffsetArcsec = dataClass(meanRaOffset, sqrt(offsetCovariance(1,1)));
bootstrapMeanOffset.decOffsetArcsec = dataClass(meanDecOffset, sqrt(offsetCovariance(2,2)));
bootstrapMeanOffset = computeSkyOffset(bootstrapMeanOffset);

printSkyComponentOffset(bootstrapMeanOffset, 'multi-quarter bootstrap mean fit: ');
printSkyOffset(bootstrapMeanOffset, 'multi-quarter bootstrap mean fit: ');


disp('=======================================');
disp('== bootstrap multi-quarter fit w/ motion polynomials');
disp('=======================================');

tic;
[meanRaOffset, meanDecOffset, centroidFailed, offsetCovariance, ...
    raOffsets, decOffsets, quarterList] ...
    = bootstrap_multi_quarter_prf_fit(directImageData, ...
    diffImageData, prfStruct, motionPolynomialData, seedRa, seedDec, 2);

if centroidFailed
    disp('bootstrap fit error');
    meanRaOffset = [];
end
disp(['bootstrap fit took ' num2str(toc/60) ' minutes']);
if isempty(meanRaOffset)
    continue;
end

bootstrapMeanOffset = centroidOffsetClass(testKepId);
bootstrapMeanOffset.raOffsetArcsec = dataClass(meanRaOffset, sqrt(offsetCovariance(1,1)));
bootstrapMeanOffset.decOffsetArcsec = dataClass(meanDecOffset, sqrt(offsetCovariance(2,2)));
bootstrapMeanOffset = computeSkyOffset(bootstrapMeanOffset);

printSkyComponentOffset(bootstrapMeanOffset, 'multi-quarter bootstrap mean fit: ');
printSkyOffset(bootstrapMeanOffset, 'multi-quarter bootstrap mean fit: ');

