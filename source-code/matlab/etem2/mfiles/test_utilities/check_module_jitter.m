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
outputLocation = '/path/to/etem2/auto/dev/30d-complete/long';
startDateMjd = datestr2mjd('24-Jul-2010 12:00:00');

cadenceDuration = 1793.4912;
raDec2PixObject = raDec2PixClass(retrieve_ra_dec_2_pix_model(), 'one-based');
modules = [2:4 6:20 22:24];
modOutIndex = 1;
cadence = 700;
jitIndex = 1499302;
cornerRow = [1 1 1024 1024 1]';
cornerCol = [1 1100 1100 1 1]';
centerRow = mean(cornerRow);
centerCol = mean(cornerCol);

timeMjd = startDateMjd + (cadence-1)*cadenceDuration/(24*3600);
figure
hold on;
for m = 1:length(modules)
	module = modules(m);
	for output = 1:4
		filename = [outputLocation filesep 'run_long_m' ...
			num2str(module) 'o' num2str(output) 's1/jitterMotion.mat'];
		disp(filename);
		load(filename, 'rowMotion', 'colMotion');
		
		modOut(modOutIndex).deltaRow = rowMotion(jitIndex);
		modOut(modOutIndex).deltaCol = colMotion(jitIndex);
		modOut(modOutIndex).row = centerRow + modOut(modOutIndex).deltaRow;
		modOut(modOutIndex).col = centerCol + modOut(modOutIndex).deltaCol;

		[modOut(modOutIndex).initRa modOut(modOutIndex).initDec] = ...
			pix_2_ra_dec(raDec2PixObject, module, output, centerRow, ...
			centerCol, timeMjd, 1);
		[modOut(modOutIndex).motionRa modOut(modOutIndex).motionDec] = ...
			pix_2_ra_dec(raDec2PixObject, module, output, ...
			modOut(modOutIndex).row, modOut(modOutIndex).col, timeMjd, 1);
		modOut(modOutIndex).deltaRa = modOut(modOutIndex).motionRa - modOut(modOutIndex).initRa;
		modOut(modOutIndex).deltaDec = modOut(modOutIndex).motionDec - modOut(modOutIndex).initDec;

		[modOut(modOutIndex).cornerRa modOut(modOutIndex).cornerDec] = ...
			pix_2_ra_dec(raDec2PixObject, repmat(module, size(cornerRow)), repmat(output, size(cornerRow)), ...
			cornerRow, cornerCol, timeMjd, 1);

		plot(modOut(modOutIndex).cornerRa, modOut(modOutIndex).cornerDec, 'r--');
		quiver(modOut(modOutIndex).initRa, modOut(modOutIndex).initDec, modOut(modOutIndex).deltaRa, modOut(modOutIndex).deltaDec, 1e5);
		text(mean(modOut(modOutIndex).cornerRa), mean(modOut(modOutIndex).cornerDec), num2str(modOutIndex));
		drawnow;
		
		modOutIndex = modOutIndex + 1;
	end
end
hold off

save modOutJitter.mat modOut

figure
hold on;
for i=1:84
	plot(modOut(i).cornerRa, modOut(i).cornerDec, 'r--');
	quiver(mean(mean(modOut(i).initRa)), mean(mean(modOut(i).initDec)), mean(mean(modOut(i).deltaRa)), mean(mean(modOut(i).deltaDec)), 1e5);
	text(mean(modOut(i).cornerRa), mean(modOut(i).cornerDec), num2str(i));
end
hold off

