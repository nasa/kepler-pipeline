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
% long_target_fits_file = '/path/to/dr/incoming/kplr2010169033207_lcs-targ.fits';
long_target_fits_file = '/path/to/dr/incoming/kplr2010167034418_lcs-targ.fits';
etemFileHead = '/path/to/etem2/auto/7.5d/long/run_long_m';

% find the cadence number
info = fitsinfo(long_target_fits_file);
for i=1:size(info.PrimaryData.Keywords)
	if strcmp(info.PrimaryData.Keywords{i,1}, 'LC_INTER')
		cadence = info.PrimaryData.Keywords{i,2};
	end	
end	
display(['cadence ' num2str(cadence)]);
nOuts = 12;
modules = [2:4 6:20 22:24];
for i=1:nOuts
	tf = fitsread(long_target_fits_file, 'BinTable', i);
	tv(i).pixelValues = tf{1};
	module = modules(fix((i-1)/4)+1);
	output = mod(i-1, 4)+1;
	etemFile = [etemFileHead num2str(module) 'o' num2str(output) 's1/'];
	etemFile
	values = get_pixel_time_series(etemFile, 'targets');
	nEtemTargetValues(i) = 0;
	etemModOut(i).pixValues = [];
	for n=1:length(values)
		etemModOut(i).target(n).pixelValues = values(n).pixelValues;
		etemModOut(i).pixValues = [etemModOut(i).pixValues etemModOut(i).target(n).pixelValues(cadence, :)];
		nEtemTargetValues(i) = nEtemTargetValues(i) + length(etemModOut(i).target(n).pixelValues(1,:));
	end
	ngargetValues(i) = length(tv(i).pixelValues);
	display(['module ' num2str(module) ' output ' num2str(output) ' etem data == fits data? ' ...
		num2str(all(etemModOut(i).pixValues == tv(i).pixelValues'))]); 
end
