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
    mjds = 55001:55010;
    modules = 2 + zeros(size(mjds));
    outputs = 1 + zeros(size(mjds));
    rows = 512  + zeros(size(mjds));;
    cols = 512 + zeros(size(mjds));;


    raDec2PixData = retrieve_ra_dec_2_pix_model(54999, 56001);
    raDec2PixObject = raDec2PixClass(raDec2PixData, 'zero-based');

    raPt   = 300.01:0.01:300.10;
    decPt  = 45.01:0.01:45.10;
    rollPt = 0.001:0.001:0.010;
    offsets = zeros(size(raPt)) + 0.001;

    dRaPt   = raPt - raPt(1);
    dDecPt  = decPt - decPt(1);
    dRollPt = rollPt - rollPt(1);
    
    [ra1 dec1] = pix_2_ra_dec(raDec2PixObject, modules, outputs, rows, cols, mjds);
    [ra2 dec2] = pix_2_ra_dec_absolute(raDec2PixObject, modules, outputs, rows, cols, mjds, raPt, decPt, rollPt);
    [ra3 dec3] = pix_2_ra_dec_relative(raDec2PixObject, modules, outputs, rows, cols, mjds, offsets(1), offsets(1), offsets(1));
    [ra4 dec4] = pix_2_ra_dec_relative(raDec2PixObject, modules, outputs, rows, cols, mjds, offsets, offsets, offsets);

    assert_equals(1, sum(sum(ra1 ~= ra2)) > 1)
return
