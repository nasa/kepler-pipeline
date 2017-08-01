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
etemFileHead = '/path/to/etem2/auto/7.5d/long/run_long_m';

load configuration_files/maskDefinitions.mat

display(['cadence ' num2str(cadence)]);
modules = [2:4 6:20 22:24];
nOuts = 4*length(modules);
dataPos = 1;
count = 1;
for i=1:nOuts
	tf = fitsread(longTargetFitsFile, 'BinTable', i);
	tv(i).pixelValues = tf{1};
	
	module = modules(fix((i-1)/4)+1);
	output = mod(i-1, 4)+1;
	etemFile = [etemFileHead num2str(module) 'o' num2str(output) 's1/'];
	etemFile

	targetDef = get_target_definitions(etemFile, 'targets');
	nTargets = length(targetDef);
	nPixels = 0;
	for t=1:nTargets
		mask = maskDefinitions(targetDef(t).maskIndex);
		nPixels = nPixels + length([mask.offsets.row]);
	end
	etemTargetData = etemData(dataPos:dataPos+nPixels-1);
	
	status(count) = all(etemTargetData' == tv(i).pixelValues');
	display(['targets: module ' num2str(module) ' output ' num2str(output) ' etem data == fits data? ' ...
		num2str(status(count))]); 
	
	dataPos = dataPos + nPixels;
	count = count + 1;
end

for i=1:nOuts
	bf = fitsread(longBackFitsFile, 'BinTable', i);
	bv(i).pixelValues = bf{1};
	
	module = modules(fix((i-1)/4)+1);
	output = mod(i-1, 4)+1;
	etemFile = [etemFileHead num2str(module) 'o' num2str(output) 's1/'];
	etemFile

	backDef = get_target_definitions(etemFile, 'background');
	nTargets = length(backDef);
	nPixels = 4*nTargets;
	etemTargetData = etemData(dataPos:dataPos+nPixels-1);
	
	status(count) = all(etemTargetData' == bv(i).pixelValues');
	display(['background: module ' num2str(module) ' output ' num2str(output) ' etem data == fits data? ' ...
		num2str(status(count))]); 
		
	dataPos = dataPos + nPixels;
	count = count + 1;
end

nCol = 1100 + 1100 + 1070;

for i=1:nOuts
	cf = fitsread(longColFitsFile, 'BinTable', i);
	cv(i).pixelValues = cf{1};
	
	module = modules(fix((i-1)/4)+1);
	output = mod(i-1, 4)+1;
	etemFile = [etemFileHead num2str(module) 'o' num2str(output) 's1/'];
	etemFile

	etemTargetData = etemData(dataPos:dataPos+nCol-1);
	
	status(count) = all(etemTargetData' == cv(i).pixelValues');
	display(['collateral: module ' num2str(module) ' output ' num2str(output) ' etem data == fits data? ' ...
		num2str(status(count))]); 
		
	dataPos = dataPos + nCol;
	count = count + 1;
end

if all(status == 1)
	display('perfect match');
else
	display('error: mismatch somewhere');
end
