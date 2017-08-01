% script to display optimal and mask apertures
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
tDefs = amaResultStruct.targetDefinitions;
aps = inputsStruct.apertureStructs;


for i=1:length(aps)
	minRow = 1e6;
	maxRow = -1;
	minCol = 1e6;
	maxCol = -1;

	apRow = aps(i).referenceRow + 1 + [aps(i).offsets.row];
	apCol = aps(i).referenceColumn + 1 + [aps(i).offsets.column];
	img = zeros(1060, 1170);
	for r=1:length(apRow)
		img(apRow(r), apCol(r)) = img(apRow(r), apCol(r)) + 1;
	end

	minRow = min([apRow, minRow]);
	maxRow = max([apRow, maxRow]);
	minCol = min([apCol, minCol]);
	maxCol = max([apCol, maxCol]);

	tDefIndex = find([tDefs.keplerId] == aps(i).keplerId);
	for t=1:length(tDefIndex)
		mask = maskDefinitions(tDefs(tDefIndex(t)).maskIndex + 1);
		tRow = tDefs(tDefIndex(t)).referenceRow + 1 + [mask.offsets.row];
		tCol = tDefs(tDefIndex(t)).referenceColumn + 1 + [mask.offsets.column];

		minRow = min([tRow, minRow]);
		maxRow = max([tRow, maxRow]);
		minCol = min([tCol, minCol]);
		maxCol = max([tCol, maxCol]);

		for j=1:length(tRow)
			img(tRow(j), tCol(j)) = img(tRow(j), tCol(j)) + 1;
		end
	end
	img = img(minRow:maxRow, minCol:maxCol);
	
	imagesc(img);
	colorbar;
	title(['ap: ' num2str(i) ' KeplerID ' num2str(aps(i).keplerId) ' tDefs: ' num2str(tDefIndex)]);
	pause;
	clear img
end
