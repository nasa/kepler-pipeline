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

nTrials = 100;
transitDepth = 1e-3;

testKepId = 6922244; % Kepler-8
% testKepId = 10489525; % KOI-106
% testKepId = 3342970; % KOI-800, low SNR but deep
% testKepId = 10662202; % KOI-750, low SNR medium depth
planetNum = 1;

addpath('/path/to/false_positive/code');
addpath('/path/to/steve_utilities/');

dvResultsLocation = '/path/to/dvReports/';
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

raDec2PixModel = retrieve_ra_dec_2_pix_model();
raDec2PixData.raDec2PixObject = raDec2PixClass(raDec2PixModel, 'zero-based');
for i=1:length(imageData)
	ds = dateStruct(i + 2);
	mjd(i) = mean([ds.startMjd, ds.endMjd]);

	[module(i) out(i) row(i) col(i)] = ra_dec_2_pix(raDec2PixData.raDec2PixObject, ...
		seedRa, seedDec, mjd(i));
		
	prfModel = retrieve_prf_model(module(i), out(i));
	prfMasterObject(i) = prfCollectionClass(prfModel.blob, convert_fc_constants_java_2_struct());
	
	[qData(i).directStar qData(i).ccdRow qData(i).ccdCol] = evaluate(prfMasterObject(i), row(i), col(i), ...
		[imageData(i).differenceImagePixelStruct.ccdRow]', [imageData(i).differenceImagePixelStruct.ccdColumn]');
	d = [imageData(i).differenceImagePixelStruct.meanFluxOutOfTransit];

	% normalize so it has the same flux in the aperture
	flux = sum([d.value]);	
	qData(i).directStar = qData(i).directStar/sum(qData(i).directStar);
	qData(i).directStar = flux*qData(i).directStar;
	
	qData(i).transitStar = (1 - transitDepth)*qData(i).directStar;
	
	qData(i).diffStar = qData(i).directStar - qData(i).transitStar;
	
	qData(i).directUncertainties = [d.uncertainty]';
	d = [imageData(i).differenceImagePixelStruct.meanFluxInTransit];
	qData(i).inTransitUncertainties = [d.uncertainty]';
	qData(i).diffUncertainties = sqrt(qData(i).directUncertainties.^2 + qData(i).inTransitUncertainties.^2);
end

for nQuarters = 1:length(qData);
	directRa = zeros(nTrials, 1);
	directRaSigma = zeros(nTrials, 1);
	diffRa = zeros(nTrials, 1);
	diffRaSigma = zeros(nTrials, 1);
	directDec = zeros(nTrials, 1);
	directDecSigma = zeros(nTrials, 1);
	diffDec = zeros(nTrials, 1);
	diffDecSigma = zeros(nTrials, 1);
	for n=1:nTrials
		if ~mod(n,10)
			disp([nQuarters n]);
		end
		if exist('diffImageData', 'var')
    		clear diffImageData directImageData;
		end
		for i=1:nQuarters
			[directStar ccdRow ccdCol] = evaluate(prfMasterObject(i), row(i), col(i));
			d = [imageData(i).differenceImagePixelStruct.meanFluxOutOfTransit];

			directStar = qData(i).directStar;
			directImageData(i).ccdModule = module(i);
			directImageData(i).ccdOutput = out(i);
			directImageData(i).ccdRow = qData(i).ccdRow;
			directImageData(i).ccdColumn = qData(i).ccdCol;
			directImageData(i).values = qData(i).directStar + ...
				qData(i).directUncertainties.*randn(size(qData(i).directUncertainties));
			directImageData(i).uncertainties = qData(i).directUncertainties;
			directImageData(i).mjd = mjd(i);

			diffImageData(i).ccdModule = module(i);
			diffImageData(i).ccdOutput = out(i);
			diffImageData(i).ccdRow = qData(i).ccdRow;
			diffImageData(i).ccdColumn = qData(i).ccdCol;
			diffImageData(i).values = qData(i).diffStar + ...
				qData(i).diffUncertainties.*randn(size(qData(i).diffUncertainties));
			diffImageData(i).uncertainties = qData(i).diffUncertainties;
			diffImageData(i).mjd = mjd(i);
		end

		[directRa(n), directDec(n), centroidStatus, ...
			centroidCovariance, rowJacobian, columnJacobian, amplitude, directDiagnostics] ...
    		= compute_multi_quarter_prf_fit(directImageData, prfMasterObject, raDec2PixData, seedRa, seedDec);
		directRaSigma(n) = sqrt(centroidCovariance(1,1));
		directDecSigma(n) = sqrt(centroidCovariance(2,2));

		[diffRa(n), diffDec(n), centroidStatus, ...
			centroidCovariance, rowJacobian, columnJacobian, amplitude, diffDiagnostics] ...
    		= compute_multi_quarter_prf_fit(diffImageData, prfMasterObject, raDec2PixData);
		diffRaSigma(n) = sqrt(centroidCovariance(1,1));
		diffDecSigma(n) = sqrt(centroidCovariance(2,2));
	end

	save(['multiQStatTest_' num2str(nQuarters) '_quarters_' num2str(nTrials) '_trials.mat'], ...
		'testKepId', 'seedRa', 'seedDec', 'directRa', 'directDec', 'diffRa', 'diffDec', ...
		'directRaSigma', 'directDecSigma', 'diffRaSigma', 'diffDecSigma');
end
