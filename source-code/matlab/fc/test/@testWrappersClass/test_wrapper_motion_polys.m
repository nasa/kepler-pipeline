function self = test_wrappers_motion_polys(self)
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
    channels = [7 8 21 22 23 24];
    all_mjds = 55000:25:56000;

    one_motion_poly = struct(  ...
        'cadence',       0, ... % cadence #
        'mjd',           0, ... % mjd of the cadence
        'module',        0, ... % module #
        'output',        0, ... % output #
        'rowPoly',       0, ... % row polynomial structure, see help for weighted_polyfit2d for details.
        'rowPolyStatus', 0, ... % flag indicating good or bad status of rowPoly.
        'colPoly',       0, ... % column polynomial structure.
        'colPolyStatus', 0);    % flag indicating good or bad status of colPoly.

    motion_poly_struct = repmat(one_motion_poly, length(channels), length(all_mjds));

    poly.offsetx =  0
    poly.scalex  =  1.76504850942436
    poly.originx =  290.977884472275
    poly.offsety =  0
    poly.scaley  =  2.78540095027221
    poly.originy =  50.6705228930971
    poly.xindex  =  -1
    poly.yindex  =  -1
    poly.type    =  'standard'
    poly.order   =  3
    poly.message =  []
    poly.coeffs  =  11:20;
    poly.covariance =  eye(10);
           
    for ic = 1:length(channels)
        for im = 1:length(all_mjds)
            motion_poly_struct(ic, im).cadence = ic*10000+im;
            motion_poly_struct(ic, im).mjd     = ic*20000+im;
            motion_poly_struct(ic, im).module  = 13;
            motion_poly_struct(ic, im).output  = 3;
            motion_poly_struct(ic, im).rowPoly = poly;
            motion_poly_struct(ic, im).rowPolyStatus = 1;
            motion_poly_struct(ic, im).colPoly = poly;
            motion_poly_struct(ic, im).colPolyStatus = 1;
        end
    end

    blob = struct_to_blob(motion_poly_struct);
    out_struct = blob_to_struct(blob);

    assert(isequalStruct(motion_poly_struct, out_struct));

    start_mjd = 55402;
    end_mjd = 55500;
    motion_polys = retrieve_motion_polys(start_mjd, end_mjd);

    assert(length(mjds) == length(motion_polys));
    for ii = 1:length(motion_polys)
        v = weighted_polyval2d(500, 500, motion_polys(ii).rowPoly);
        assert(~isempty(v));
    end

return
