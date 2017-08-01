function self = test_cal_usecase(self)
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
    display('flatfield cal usecase');

    % This test is specifically for one mod/out
    modules = 13;
    outputs =  1;
    start_mjd = 55000;
    end_mjd   = 56000;
    num_pixels = 10000;
    pix_rows = 1 + fix(1070*rand(num_pixels, 1));
    pix_cols = 1 + fix(1132*rand(num_pixels, 1));
    
    for ii=1:length(outputs)
        flatData(ii) = retrieve_flat_field_model(modules(ii), outputs(ii), start_mjd, end_mjd, pix_rows, pix_cols);
        flatObjects(ii) = flatFieldClass(flatData(ii));
    end

    for ii=1:length(outputs)
        result10 = get_flat_field(flatObjects(ii), 54999, pix_rows, pix_cols);
        assert_equals(size(result10, 1), length(pix_rows));

        result11 = get_flat_field(flatObjects(ii), 54999, pix_rows(1:10), pix_cols(1:10));
        assert_equals(size(result11, 1), 10);

        result20 = get_flat_field(flatObjects(ii), 55002, pix_rows, pix_cols);
        assert_equals(size(result20, 1), length(pix_rows));

        result21 = get_flat_field(flatObjects(ii), 55002, pix_rows(1:10), pix_cols(1:10));
        assert_equals(size(result21, 1), 10);

        result30 = get_flat_field(flatObjects(ii), 56002, pix_rows, pix_cols);
        assert_equals(size(result30, 1), length(pix_rows));

        result31 = get_flat_field(flatObjects(ii), 56002, pix_rows(1:10), pix_cols(1:10));
        assert_equals(size(result31, 1), 10);
    end

    flatDataFull = retrieve_flat_field_model(modules(ii), outputs(ii), start_mjd, end_mjd);
    flatObject = flatFieldClass(flatDataFull);
    result40 = get_flat_field(flatObject, 55000);
    result41 = get_flat_field(flatObject, 55000, pix_rows, pix_cols);

    assert_equals(size(result40, 1), 1070);
    assert_equals(size(result40, 2), 1132);

    assert_equals(size(result41, 1), length(pix_rows));
    assert_equals(size(result41, 1), length(pix_cols));
return
