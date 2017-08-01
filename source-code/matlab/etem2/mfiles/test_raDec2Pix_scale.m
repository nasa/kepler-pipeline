% test raDec2Pix plate scale
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

raDec2PixObject = raDec2PixClass(retrieve_ra_dec_2_pix_model(), 'one-based');
module = 13;
output = 1;
row = 512; 
col = 550;

aberrate = 1;

pixDelta = 0.5;

dateMjd = datestr2mjd('23-Feb-2009');

% compute ra and dec for difference in row
row1 = row - pixDelta;
row2 = row + pixDelta;
[ra1, dec1] = pix_2_ra_dec(raDec2PixObject, module, output, row1, col, dateMjd, aberrate);
[ra2, dec2] = pix_2_ra_dec(raDec2PixObject, module, output, row2, col, dateMjd, aberrate);

raDelta = (ra2 - ra1)*3600; % arc seconds
decDelta = (dec2 - dec1)*3600;

disp(['pixel difference = ' num2str(row2 - row1) ' row corresponds to difference of '...
    num2str(norm([raDelta, decDelta])) ' arc seconds']);

% compute ra and dec for difference in col
col1 = col - pixDelta;
col2 = col + pixDelta;
[ra1, dec1] = pix_2_ra_dec(raDec2PixObject, module, output, row, col1, dateMjd, aberrate);
[ra2, dec2] = pix_2_ra_dec(raDec2PixObject, module, output, row, col2, dateMjd, aberrate);

raDelta = (ra2 - ra1)*3600; % arc seconds
decDelta = (dec2 - dec1)*3600;

disp(['pixel difference = ' num2str(col2 - col1) ' column corresponds to difference of '...
    num2str(norm([raDelta, decDelta])) ' arc seconds']);
