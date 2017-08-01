function self = test_new_api(self)
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
    ra = 300:.01:300.10;
    dec = 45:.01:45.10;
    mjd = 55000:55010;

    raDec2PixData = retrieve_ra_dec_2_pix_model(54999, 56001);
    raDec2PixObject = raDec2PixClass(raDec2PixData, 'zero-based');

    raPt   = ra;
    decPt  = dec;
    rollPt = 0.000:0.001:0.010;
    offsets = zeros(size(raPt)) + 0.001;



    [m1 o1 r1 c1] = ra_dec_2_pix(raDec2PixObject,          ra(1), dec(1), mjd);
    [m2 o2 r2 c2] = ra_dec_2_pix_absolute(raDec2PixObject, ra(1), dec(1), mjd, raPt, decPt, rollPt);
    [m3 o3 r3 c3] = ra_dec_2_pix_relative(raDec2PixObject, ra(1), dec(1), mjd, offsets(1), offsets(1), offsets(1));
    [m4 o4 r4 c4] = ra_dec_2_pix_relative(raDec2PixObject, ra(1), dec(1), mjd, offsets, offsets, offsets);

    [m5 o5 r5 c5] = ra_dec_2_pix(raDec2PixObject,          ra(1:2), dec(1:2), mjd);
    [m6 o6 r6 c6] = ra_dec_2_pix_absolute(raDec2PixObject, ra(1:2), dec(1:2), mjd, raPt, decPt, rollPt);
    [m7 o7 r7 c7] = ra_dec_2_pix_relative(raDec2PixObject, ra(1:2), dec(1:2), mjd, offsets(1), offsets(1), offsets(1));
    [m8 o8 r8 c8] = ra_dec_2_pix_relative(raDec2PixObject, ra(1:2), dec(1:2), mjd, offsets, offsets, offsets);

    assert_equals(1, sum(sum(r1 ~= r2)) > 1)
return
