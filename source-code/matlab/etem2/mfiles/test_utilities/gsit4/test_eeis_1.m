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
dataList.set(1).ffi = '/disk2/gsit4/gsit4_ffis3';
dataList.set(1).lcTargets = 'gsit-4-b-lc1';
dataList.set(1).scTargets = 'gsit-4-b-sc1';
dataList.set(1).fits(1).lc = '/path/to/dr/eeis-1-from-dmc/kplr2009201153500_lcs-targ.fits';
dataList.set(1).fits(2).lc = '/path/to/dr/eeis-1-from-dmc/kplr2009201160454_lcs-targ.fits';
dataList.set(1).fits(3).lc = '/path/to/dr/eeis-1-from-dmc/kplr2009201163447_lcs-targ.fits';
dataList.set(1).fits(1).bkg = '/path/to/dr/eeis-1-from-dmc/kplr2009201153500_lcs-bkg.fits';
dataList.set(1).fits(2).bkg = '/path/to/dr/eeis-1-from-dmc/kplr2009201160454_lcs-bkg.fits';
dataList.set(1).fits(3).bkg = '/path/to/dr/eeis-1-from-dmc/kplr2009201163447_lcs-bkg.fits';
dataList.set(1).fits(1).col = '/path/to/dr/eeis-1-from-dmc/kplr2009201153500_lcs-col.fits';
dataList.set(1).fits(2).col = '/path/to/dr/eeis-1-from-dmc/kplr2009201160454_lcs-col.fits';
dataList.set(1).fits(3).col = '/path/to/dr/eeis-1-from-dmc/kplr2009201163447_lcs-col.fits';
dataList.set(1).scFits(1).sc = '/path/to/dr/eeis-1-from-dmc/kplr2009201150606_scs-targ.fits';
dataList.set(1).scFits(1).col = '/path/to/dr/eeis-1-from-dmc/kplr2009201150606_scs-col.fits';
dataList.set(1).scFits(2).sc = '/path/to/dr/eeis-1-from-dmc/kplr2009201153500_scs-targ.fits';
dataList.set(1).scFits(2).col = '/path/to/dr/eeis-1-from-dmc/kplr2009201153500_scs-col.fits';
dataList.set(1).scFits(3).sc = '/path/to/dr/eeis-1-from-dmc/kplr2009201160454_scs-targ.fits';
dataList.set(1).scFits(3).col = '/path/to/dr/eeis-1-from-dmc/kplr2009201160454_scs-col.fits';
dataList.set(1).scFits(4).sc = '/path/to/dr/eeis-1-from-dmc/kplr2009201163447_scs-targ.fits';
dataList.set(1).scFits(4).col = '/path/to/dr/eeis-1-from-dmc/kplr2009201163447_scs-col.fits';
dataList.set(1).scFits(1).requant = 1;
dataList.set(1).scFits(2).requant = 1;
dataList.set(1).scFits(3).requant = 1;
dataList.set(1).scFits(4).requant = 1;

for set = 1:length(dataList.set)
	ffi = dataList.set(set).ffi;
	lcTargets = dataList.set(set).lcTargets;
	scTargets = dataList.set(set).scTargets;
	fits = dataList.set(set).fits;
	scFits = dataList.set(set).scFits;
	if 0
	for file=1:length(fits)
		retVal = test_gsit4_target_values(ffi, lcTargets, fits(file).lc);
		if any(retVal == 0)
    		disp(['error in target value check: ' fits(file).lc]);
		else
    		disp([fits(file).lc ' succefully validated']);
		end

		retVal = test_gsit4_background_values(ffi, lcTargets, fits(file).bkg);
		if any(retVal == 0)
    		disp(['error in background value check: ' fits(file).bkg]);
		else
    		disp([fits(file).bkg ' succefully validated']);
		end

		retVal = test_gsit4_collateral_values(ffi, fits(file).col);
		if any(retVal == 0)
    		disp(['error in collateral value check: ' fits(file).col]);
		else
    		disp([fits(file).col ' succefully validated']);
		end
	end
	end
	for file=1:length(scFits)
		retVal = test_gsit4_sc_target_values(ffi, scTargets, ...
			scFits(file).sc, scFits(file).requant);
		if any(retVal == 0)
    		disp(['error in target value check: ' scFits(file).sc]);
		else
    		disp([scFits(file).sc ' succefully validated']);
		end

		retVal = test_gsit4_sc_collateral_values(ffi, scTargets, ...
			scFits(file).col, scFits(file).requant);
		if any(retVal == 0)
    		disp(['error in collateral value check: ' scFits(file).col]);
		else
    		disp([scFits(file).col ' succefully validated']);
		end
	end
end
