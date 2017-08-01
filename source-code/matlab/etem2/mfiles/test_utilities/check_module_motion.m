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
outputLocation = '/path/to/etem2/auto/dev/30d-for-jon/long';
% outputLocation = 'output';
startDateMjd = datestr2mjd('24-Jul-2010 12:00:00');

cadenceDuration = 1793.4912;
raDec2PixObject = raDec2PixClass(retrieve_ra_dec_2_pix_model(), 'one-based');
modules = [2:4 6:20 22:24];
% modules = [12];
modOutIndex = 1;
cadence = 1300;
cornerRow = [1 1 1024 1024 1]';
cornerCol = [1 1100 1100 1 1]';

timeMjd = startDateMjd + (cadence-1)*cadenceDuration/(24*3600);
figure
hold on;
for m = 1:length(modules)
	module = modules(m);
	for output = 1:4
		filename = [outputLocation filesep 'run_long_m' ...
			num2str(module) 'o' num2str(output) 's1/motionBasis.mat'];
		disp(filename);
		load(filename);
		for i=1:size(motionBasis1, 1)
			for j=1:size(motionBasis1, 2)
				c = motionBasis1(i,j).designMatrix(1,1);
				modOut(modOutIndex).deltaRow(i,j) = motionBasis1(i,j).designMatrix(cadence,3)/c;
				modOut(modOutIndex).deltaCol(i,j) = motionBasis1(i,j).designMatrix(cadence,2)/c;
				modOut(modOutIndex).initRow(i,j) = motionGridRow(i,j);
				modOut(modOutIndex).initCol(i,j) = motionGridCol(i,j);
				modOut(modOutIndex).row(i,j) = motionGridRow(i,j) + modOut(modOutIndex).deltaRow(i,j);
				modOut(modOutIndex).col(i,j) = motionGridCol(i,j) + modOut(modOutIndex).deltaCol(i,j);
				
				[modOut(modOutIndex).initRa(i,j) modOut(modOutIndex).initDec(i,j)] = ...
					pix_2_ra_dec(raDec2PixObject, module, output, motionGridRow(i,j), ...
					motionGridCol(i,j), timeMjd, 1);
				[modOut(modOutIndex).motionRa(i,j) modOut(modOutIndex).motionDec(i,j)] = ...
					pix_2_ra_dec(raDec2PixObject, module, output, ...
					modOut(modOutIndex).row(i,j), modOut(modOutIndex).col(i,j), timeMjd, 1);
				modOut(modOutIndex).deltaRa(i,j) = modOut(modOutIndex).motionRa(i,j) - modOut(modOutIndex).initRa(i,j);
				modOut(modOutIndex).deltaDec(i,j) = modOut(modOutIndex).motionDec(i,j) - modOut(modOutIndex).initDec(i,j);
				[mod, out, modOut(modOutIndex).predictRow(i,j) modOut(modOutIndex).predictCol(i,j)] ...
					= ra_dec_2_pix(raDec2PixObject, modOut(modOutIndex).initRa(i,j), ...
					modOut(modOutIndex).initDec(i,j), timeMjd, 1);
				modOut(modOutIndex).rowError(i,j) ...
					= modOut(modOutIndex).row(i,j) - modOut(modOutIndex).predictRow(i,j);
				modOut(modOutIndex).colError(i,j) ...
					= modOut(modOutIndex).col(i,j) - modOut(modOutIndex).predictCol(i,j);
				modOut(modOutIndex).errorNorm(i,j) ...
					= norm([modOut(modOutIndex).rowError(i,j) modOut(modOutIndex).colError(i,j)]);
					
			end
		end
		modOut(modOutIndex).meanError = mean(mean(modOut(modOutIndex).errorNorm(i,j)));
		modOut(modOutIndex).maxError = max(max(modOut(modOutIndex).errorNorm(i,j)));
		modOut(modOutIndex).minError = min(min(modOut(modOutIndex).errorNorm(i,j)));
		disp(['mean error: ' num2str(modOut(modOutIndex).meanError) ' error range: ' ...
			num2str(modOut(modOutIndex).minError) ':' num2str(modOut(modOutIndex).maxError)]);

		[modOut(modOutIndex).cornerRa modOut(modOutIndex).cornerDec] = ...
			pix_2_ra_dec(raDec2PixObject, repmat(module, size(cornerRow)), repmat(output, size(cornerRow)), ...
			cornerRow, cornerCol, timeMjd, 1);


		plot(modOut(modOutIndex).cornerRa, modOut(modOutIndex).cornerDec, 'r--');
		quiver(modOut(modOutIndex).initRa, modOut(modOutIndex).initDec, modOut(modOutIndex).deltaRa, modOut(modOutIndex).deltaDec, 0.8);
		text(mean(modOut(modOutIndex).cornerRa), mean(modOut(modOutIndex).cornerDec), num2str(modOutIndex));
		drawnow;
		
		modOutIndex = modOutIndex + 1;
	end
end
hold off
disp(['across FOV: mean error: ' num2str(mean([modOut.meanError])) ', error range: ' ...
	num2str(min([modOut.minError])) ':' num2str(max([modOut.maxError]))]);

save modOut.mat modOut

figure
hold on;
for i=1:84
	plot(modOut(i).cornerRa, modOut(i).cornerDec, 'r--');
	quiver(mean(mean(modOut(i).initRa)), mean(mean(modOut(i).initDec)), mean(mean(modOut(i).deltaRa)), mean(mean(modOut(i).deltaDec)), 1e5);
	text(mean(modOut(i).cornerRa), mean(modOut(i).cornerDec), num2str(i));
end
hold off

