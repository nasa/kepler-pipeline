% find high and low zodi channels for a given quarter
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
if ~exist('raDec2PixModel', 'var')
    raDec2PixModel = retrieve_ra_dec_2_pix_model();
    raDec2PixObject = raDec2PixClass(raDec2PixModel, 'zero-based');
end

quarter = 7;
load /path/to/steve_utilities/dateStruct;
qDateStruct = dateStruct(quarter+2);
julianDate = datestr2julian(qDateStruct.startLocal);

zCount = 1;
for m=[2 4 6:20 22:24]
	for o = 1:4
		% get the center of each channel
		[ra dec] = pix_2_ra_dec(raDec2PixObject, m, o, 512, fix(1130/2), qDateStruct.startMjd);
		ze(zCount) = Zodi_Model(ra, dec, julianDate, raDec2PixObject, 3.98);
		zm(zCount) = m;
		zo(zCount) = o;
		zCount = zCount + 1;
	end
end

disp(['quarter ' num2str(quarter)]);

[m ii] = min(ze);
disp(['min zodi of ' num2str(ze(ii)) ' on ' num2str(zm(ii)) '.' num2str(zo(ii)) ]);

[m ii] = max(ze);
disp(['max zodi of ' num2str(ze(ii)) ' on ' num2str(zm(ii)) '.' num2str(zo(ii)) ]);

cc = find(zm == 13 & zo == 1);
disp(['center channel has zodi ' num2str(ze(cc))]);