function self = test_constant_pointing(self)
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
    display('test_constant_pointing');

    ra = 300;
    dec = 45;

    mjdsAllInOneQuarter = 55001:55010;
    run_these_tests(ra, dec, mjdsAllInOneQuarter);

    mjdsInTwoQuarters = 54991:55010;
    run_these_tests(ra, dec, mjdsInTwoQuarters);
return

function run_these_tests(ra, dec, mjds)
    raPt   = repmat(290.5, size(mjds));
    decPt  = repmat( 44.5, size(mjds));
    rollPt = repmat(    0, size(mjds));

    raDec2PixModel  = retrieve_ra_dec_2_pix_model();
    raDec2PixObject = raDec2PixClass(raDec2PixModel, 'zero-based');
    [m o r c] = ra_dec_2_pix_absolute(raDec2PixObject, ra, dec, mjds, raPt, decPt, rollPt);
    assert_equals(1, 1);

    raDec2PixModel  = retrieve_ra_dec_2_pix_model(min(mjds), max(mjds));
    raDec2PixObject = raDec2PixClass(raDec2PixModel, 'zero-based');
    [m o r c] = ra_dec_2_pix_absolute(raDec2PixObject, ra, dec, mjds, raPt, decPt, rollPt);
    assert_equals(1, 1);

    ra = 300:309;
    dec = 45:54;
    [m o r c] = ra_dec_2_pix_absolute(raDec2PixObject, ra, dec, mjds, raPt, decPt, rollPt);
    assert_equals(1, 1);
return
