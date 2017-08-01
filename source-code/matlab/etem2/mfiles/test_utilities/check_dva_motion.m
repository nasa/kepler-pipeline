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
startDateMjd = datestr2mjd('24-Jul-2010 12:00:00');

cadenceDuration = 1793.4912;
raDec2PixObject = raDec2PixClass(retrieve_ra_dec_2_pix_model(), 'one-based');
modules = [2:4 6:20 22:24];
modOutIndex = 1;
cadence = 1;
cornerRow = [1 1 1024 1024 1]';
cornerCol = [1 1100 1100 1 1]';

rowSpacing = [1 512 1024];
colSpacing = [1 550 1100];
[colGrid rowGrid] = meshgrid(colSpacing, rowSpacing);

timeMjd = startDateMjd + (cadence-1)*cadenceDuration/(24*3600);
deltaTime = 30;
figure
hold on;
for m = 1:length(modules)
	module = modules(m);
	for output = 1:4
		for i=1:size(rowGrid, 1)
			for j=1:size(rowGrid, 2)
				[modOut(modOutIndex).catalogRa(i,j) modOut(modOutIndex).catalogDec(i,j)] = ...
					pix_2_ra_dec(raDec2PixObject, module, output, rowGrid(i,j), ...
					colGrid(i,j), timeMjd, 0);
				[modOut(modOutIndex).initRa(i,j) modOut(modOutIndex).initDec(i,j)] = ...
					pix_2_ra_dec(raDec2PixObject, module, output, rowGrid(i,j), ...
					colGrid(i,j), timeMjd, 1);
				[modOut(modOutIndex).motionRa(i,j) modOut(modOutIndex).motionDec(i,j)] = ...
					pix_2_ra_dec(raDec2PixObject, module, output, ...
					rowGrid(i,j), colGrid(i,j), timeMjd + deltaTime, 1);
				modOut(modOutIndex).deltaRa(i,j) = modOut(modOutIndex).motionRa(i,j) ...
                    - modOut(modOutIndex).initRa(i,j);
				modOut(modOutIndex).deltaDec(i,j) = modOut(modOutIndex).motionDec(i,j) ...
                    - modOut(modOutIndex).initDec(i,j);

                [mod, out, modOut(modOutIndex).initRow(i,j), modOut(modOutIndex).initCol(i,j)] ...
                    = ra_dec_2_pix(raDec2PixObject, ...
                    modOut(modOutIndex).catalogRa(i,j), modOut(modOutIndex).catalogDec(i,j), ...
                    timeMjd, 1);
                [mod, out, modOut(modOutIndex).motionRow(i,j), modOut(modOutIndex).motionCol(i,j)] ...
                    = ra_dec_2_pix(raDec2PixObject, ...
                    modOut(modOutIndex).catalogRa(i,j), modOut(modOutIndex).catalogDec(i,j), ...
                    timeMjd + deltaTime, 1);
                modOut(modOutIndex).dvaRow(i,j) = modOut(modOutIndex).motionRow(i,j) ...
                    - modOut(modOutIndex).initRow(i,j);
                modOut(modOutIndex).dvaCol(i,j) = modOut(modOutIndex).motionCol(i,j) ...
                    - modOut(modOutIndex).initCol(i,j);
                
				[modOut(modOutIndex).newMotionRa(i,j) modOut(modOutIndex).newMotionDec(i,j)] = ...
					pix_2_ra_dec(raDec2PixObject, module, output, ...
					rowGrid(i,j) + modOut(modOutIndex).dvaRow(i,j), ...
                    colGrid(i,j) + modOut(modOutIndex).dvaCol(i,j), ...
                    timeMjd + deltaTime, 1);
				modOut(modOutIndex).newDeltaRa(i,j) = modOut(modOutIndex).newMotionRa(i,j) ...
                    - modOut(modOutIndex).initRa(i,j);
				modOut(modOutIndex).newDeltaDec(i,j) = modOut(modOutIndex).newMotionDec(i,j) ...
                    - modOut(modOutIndex).initDec(i,j);
            end
		end
		[modOut(modOutIndex).cornerRa modOut(modOutIndex).cornerDec] = ...
			pix_2_ra_dec(raDec2PixObject, repmat(module, size(cornerRow)), repmat(output, size(cornerRow)), ...
			cornerRow, cornerCol, timeMjd, 1);

		plot(modOut(modOutIndex).cornerRa, modOut(modOutIndex).cornerDec, 'r--');
		quiver(modOut(modOutIndex).initRa, modOut(modOutIndex).initDec, ...
            modOut(modOutIndex).newDeltaRa, modOut(modOutIndex).newDeltaDec, 0.8);
		text(mean(modOut(modOutIndex).cornerRa), mean(modOut(modOutIndex).cornerDec), num2str(modOutIndex));
		drawnow;
		
		modOutIndex = modOutIndex + 1;
	end
end
hold off

save modOutDva.mat modOut

figure
hold on;
for i=1:84
	plot(modOut(i).cornerRa, modOut(i).cornerDec, 'r--');
	quiver(mean(mean(modOut(i).initRa)), mean(mean(modOut(i).initDec)), mean(mean(modOut(i).deltaRa)), mean(mean(modOut(i).deltaDec)), 1e5);
	text(mean(modOut(i).cornerRa), mean(modOut(i).cornerDec), num2str(i));
end
hold off

figure
hold on;
for i=1:84
	plot(modOut(i).cornerRa, modOut(i).cornerDec, 'r--');
	quiver(modOut(i).initRa, modOut(i).initDec, modOut(i).newDeltaRa, modOut(i).newDeltaDec, 0.8);
	text(mean(modOut(i).cornerRa), mean(modOut(i).cornerDec), num2str(i));
end
hold off
set(gca, 'YDir', 'reverse');
