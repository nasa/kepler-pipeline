% get the ra and dec of pixels inside each module output
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
[ram14o1, decm14o1] = pix_2_ra_dec(14, 1, 500, 500, datestr2mjd('24-June-2010 17:29:36.8448'), 1);
[ram14o2, decm14o2] = pix_2_ra_dec(14, 2, 500, 500, datestr2mjd('24-June-2010 17:29:36.8448'), 1);
[ram14o3, decm14o3] = pix_2_ra_dec(14, 3, 500, 500, datestr2mjd('24-June-2010 17:29:36.8448'), 1);
[ram14o4, decm14o4] = pix_2_ra_dec(14, 4, 500, 500, datestr2mjd('24-June-2010 17:29:36.8448'), 1);

% compute derivative in row and column with respect to phi
[m, o, rowPhim14o10, colPhim14o10] = ra_dec_2_pix_relative(ram14o1, decm14o1, datestr2mjd('24-June-2010 17:29:36.8448'), 0, 0, 0, 1);
[m, o, rowPhim14o1Plus, colPhim14o1Plus] = ra_dec_2_pix_relative(ram14o1, decm14o1, datestr2mjd('24-June-2010 17:29:36.8448'), 0, 0, 1, 1);
drowm14o1 = (rowPhim14o1Plus - rowPhim14o10)/1;
dcolm14o1 = (colPhim14o1Plus - colPhim14o10)/1;

[m, o, rowPhim14o20, colPhim14o20] = ra_dec_2_pix_relative(ram14o2, decm14o2, datestr2mjd('24-June-2010 17:29:36.8448'), 0, 0, 0, 1);
[m, o, rowPhim14o2Plus, colPhim14o2Plus] = ra_dec_2_pix_relative(ram14o2, decm14o2, datestr2mjd('24-June-2010 17:29:36.8448'), 0, 0, 1, 1);
drowm14o2 = (rowPhim14o2Plus - rowPhim14o20)/1;
dcolm14o2 = (colPhim14o2Plus - colPhim14o20)/1;

[m, o, rowPhim14o30, colPhim14o30] = ra_dec_2_pix_relative(ram14o3, decm14o3, datestr2mjd('24-June-2010 17:29:36.8448'), 0, 0, 0, 1);
[m, o, rowPhim14o3Plus, colPhim14o3Plus] = ra_dec_2_pix_relative(ram14o3, decm14o3, datestr2mjd('24-June-2010 17:29:36.8448'), 0, 0, 1, 1);
drowm14o3 = (rowPhim14o3Plus - rowPhim14o30)/1;
dcolm14o3 = (colPhim14o3Plus - colPhim14o30)/1;

[m, o, rowPhim14o40, colPhim14o40] = ra_dec_2_pix_relative(ram14o4, decm14o4, datestr2mjd('24-June-2010 17:29:36.8448'), 0, 0, 0, 1);
[m, o, rowPhim14o4Plus, colPhim14o4Plus] = ra_dec_2_pix_relative(ram14o4, decm14o4, datestr2mjd('24-June-2010 17:29:36.8448'), 0, 0, 1, 1);
drowm14o4 = (rowPhim14o4Plus - rowPhim14o40)/1;
dcolm14o4 = (colPhim14o4Plus - colPhim14o40)/1;

disp('rows:');
disp(['output 1 dr/dphi = ' num2str(drowm14o1) '.']);
disp(['output 2 dr/dphi = ' num2str(drowm14o2) ' should have same sign as output 1.']);
disp(['output 3 dr/dphi = ' num2str(drowm14o3) ' should have opposite sign as output 1.']);
disp(['output 4 dr/dphi = ' num2str(drowm14o4) ' should have opposite sign as output 1.']);

disp('columns:');
disp(['output 1 dc/dphi = ' num2str(dcolm14o1) '.']);
disp(['output 2 dc/dphi = ' num2str(dcolm14o2) ' should have opposite sign as output 1.']);
disp(['output 3 dc/dphi = ' num2str(dcolm14o3) ' should have opposite sign as output 1.']);
disp(['output 4 dc/dphi = ' num2str(dcolm14o4) ' should have same sign as output 1.']);


