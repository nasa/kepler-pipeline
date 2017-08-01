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
clear;
raDec2PixModel = retrieve_ra_dec_2_pix_model();
raDec2PixObejct = raDec2PixClass(raDec2PixModel, 'one-based');
module = 24;
output = 3;
row = 800;
col = 800;

[ra, dec] = pix_2_ra_dec(raDec2PixObejct, module, output, row, col, datestr2mjd('01-Dec-2009'), 0);
disp(['object model: ra = ' num2str(ra) ' dec = ' num2str(dec)]);

[ra2, dec2] = pix_2_ra_dec(module, output, row-20, col-12, datestr2julian('01-Dec-2009'), 0);
disp(['old model: ra2 = ' num2str(ra2) ' dec2 = ' num2str(dec2)]);

[m o r c] = ra_dec_2_pix(raDec2PixObejct, ra, dec, datestr2mjd('01-Dec-2009'), 0);
disp(['object model: m = ' num2str(m) ' o = ' num2str(o) ' r = ' num2str(r) ' c = ' num2str(c)]);

[m2 o2 r2 c2] = ra_dec_2_pix(ra, dec, datestr2julian('01-Dec-2009'), 0);
disp(['old model: m = ' num2str(m2) ' o = ' num2str(o2) ' r = ' num2str(r2) ' c = ' num2str(c2)]);

zodiValue = Zodi_Model( ra, dec, datestr2julian('01-Dec-2009'), raDec2PixObejct);
zodiValue
