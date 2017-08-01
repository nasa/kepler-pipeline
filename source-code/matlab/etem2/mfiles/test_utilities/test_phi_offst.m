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
allModules = [2:4,6:20,22:24];
offset = 1;

for module = allModules

	for output=1:4
		% get the ra and dec of pixels inside each module output
		[ra(output), dec(output)] = pix_2_ra_dec(module, output, 500, 500, datestr2mjd('24-June-2010 17:29:36.8448'), 1);

		% compute derivative in row and column with respect to phi
		[m, o, rowPhi0(output), colPhi0(output)] = ra_dec_2_pix_relative(ra(output), ...
			dec(output), datestr2mjd('24-June-2010 17:29:36.8448'), 0, 0, 0, 1);
		[m, o, rowPhiPlus(output), colPhiPlus(output)] = ra_dec_2_pix_relative(ra(output), ...
			dec(output), datestr2mjd('24-June-2010 17:29:36.8448'), 0, 0, offset, 1);
		drow(output) = (rowPhiPlus(output) - rowPhi0(output))/offset;
		dcol(output) = (colPhiPlus(output) - colPhi0(output))/offset;
	end

	disp(['module ' num2str(module) ':']);
	disp('rows:');
	disp(['output 1 dr/dphi = ' num2str(drow(1)) '.']);
	disp(['output 2 dr/dphi = ' num2str(drow(2)) ' should have same sign as output 1.']);
	if sign(drow(1)) ~= sign(drow(2))
		disp('ERROR!!!');
	end
	disp(['output 3 dr/dphi = ' num2str(drow(3)) ' should have opposite sign as output 1.']);
	if sign(drow(1)) == sign(drow(3))
		disp('ERROR!!!');
	end
	disp(['output 4 dr/dphi = ' num2str(drow(4)) ' should have opposite sign as output 1.']);
	if sign(drow(1)) == sign(drow(4))
		disp('ERROR!!!');
	end

	disp('columns:');
	disp(['output 1 dc/dphi = ' num2str(dcol(1)) '.']);
	disp(['output 2 dc/dphi = ' num2str(dcol(2)) ' should have opposite sign as output 1.']);
	if sign(dcol(1)) == sign(dcol(2))
		disp('ERROR!!!');
	end
	disp(['output 3 dc/dphi = ' num2str(dcol(3)) ' should have opposite sign as output 1.']);
	if sign(dcol(1)) == sign(dcol(3))
		disp('ERROR!!!');
	end
	disp(['output 4 dc/dphi = ' num2str(dcol(4)) ' should have same sign as output 1.']);
	if sign(dcol(1)) ~= sign(dcol(4))
		disp('ERROR!!!');
	end

end
