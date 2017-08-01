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
modules = [2:4 6:20 22:24];
mergedName = '/path/to/auto/30d/long/merged/mergedCadenceData-';
sourceName = '/path/to/etem2/auto/30d/long/run_long_m';
cadence = 1;
mergedFile = [mergedName num2str(cadence) '.dat'];

myMerge = [];
% load the target pixels over the cadences
for m=1:length(modules)
	mod = modules(m);
	for o=1:4
		sourceFile = [sourceName num2str(mod) 'o' num2str(o) ...
			's1/ssrOutput/quantizedCadenceData.dat'];
		pixnumFile = [sourceName num2str(mod) 'o' num2str(o) 's1/pixelCounts.mat'];
		load(pixnumFile);
		fid = fopen(sourceFile, 'r', 'ieee-be');
		fseek(fid, cadence*bytesPerCadence, 'bof');
		myMerge = [myMerge fread(fid, nTargetPixels, 'uint16')'];
		fclose(fid);
	end
end

% load the background pixels over the cadences
for m=1:length(modules)
	mod = modules(m);
	for o=1:4
		sourceFile = [sourceName num2str(mod) 'o' num2str(o) ...
			's1/ssrOutput/quantizedCadenceData.dat'];
		pixnumFile = [sourceName num2str(mod) 'o' num2str(o) 's1/pixelCounts.mat'];
		load(pixnumFile);
		fid = fopen(sourceFile, 'r', 'ieee-be');
		fseek(fid, cadence*bytesPerCadence, 'bof');
		fseek(fid, 2*nTargetPixels, 'cof');
		myMerge = [myMerge fread(fid, nBackgroundPixels, 'uint16')'];
		fclose(fid);
	end
end

% load the collateral over the cadences
for m=1:length(modules)
	mod = modules(m);
	for o=1:4
		sourceFile = [sourceName num2str(mod) 'o' num2str(o) ...
			's1/ssrOutput/quantizedCadenceData.dat'];
		pixnumFile = [sourceName num2str(mod) 'o' num2str(o) 's1/pixelCounts.mat'];
		load(pixnumFile);
		fid = fopen(sourceFile, 'r', 'ieee-be');
		fseek(fid, cadence*bytesPerCadence, 'bof');
		fseek(fid, 2*(nTargetPixels + nBackgroundPixels), 'cof');
		myMerge = [myMerge fread(fid, nCollateralValues, 'uint16')'];
		fclose(fid);
	end
end

% load the target file for comparison
fid = fopen(mergedFile, 'r', 'ieee-be');
mergedData = fread(fid, inf, 'uint16')';
fclose(fid);
