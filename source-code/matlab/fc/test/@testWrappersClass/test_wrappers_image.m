function self = test_wrappers_image(self)
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
    display('run all image wrappers');

    model = retrieve_two_d_black_model(2, 1);
	model_bin = read_TwoDBlackModel('/path/to/twoDBlack.bin');
    object = twoDBlackClass(model);
    object_bin = twoDBlackClass(model_bin);
    assert_equals(1, isequal(object, object_bin));
    
    model = retrieve_flat_field_model(2, 1, 0);
    model_bin = read_FlatFieldModel('/path/to/flat.bin');
    %assert_equals(1, isequal(model.flats, model_bin.flats));
    %assert_equals(1, isequal(model.uncertainties, model_bin.uncertainties));
    assert_equals(1, isequal(model.mjds, model_bin.mjds));

    
    mjd1 = 54525;
    mjd2 = 54526;
    rows = 100:110;
    cols = 800:810;
    model = retrieve_two_d_black_model(2, 1, mjd1, mjd2);
	model_bin = read_TwoDBlackModel('/path/to/twoDBlack.bin');
    object = twoDBlackClass(model);
    object_bin = twoDBlackClass(model_bin);
    blacks = get_two_d_black(object, mjd1, rows, cols);
    blacks_bin = get_two_d_black(object_bin, mjd1, rows, cols);
    assert_equals(1, isequal(blacks, blacks_bin));

    model = retrieve_flat_field_model(2, 1, mjd1, mjd2);
	model_bin = read_TwoDBlackModel('/path/to/flat.bin');
%     object = flatFieldClass(model);
%     object_bin = flatFieldClass(model_bin);
%     assert_equals(1, isequal(object, object_bin));

    
    model = retrieve_two_d_black_model(2, 1, mjd1, mjd2, rows, cols);
	model_bin = read_TwoDBlackModel('/path/to/twoDBlack.bin');
    object = twoDBlackClass(model);
    object_bin = twoDBlackClass(model_bin);
    blacks = get_two_d_black(object, mjd1, rows, cols);
    blacks_bin = get_two_d_black(object_bin, mjd1, rows, cols);
    assert_equals(1, isequal(blacks, blacks_bin'));

    model = retrieve_flat_field_model(2, 1, mjd1, mjd2, rows, cols);
    model_bin = read_TwoDBlackModel('/path/to/twoDBlack.bin');
    object = twoDBlackClass(model);
    object_bin = twoDBlackClass(model_bin);
    blacks = get_two_d_black(object, mjd1, rows, cols);
    blacks_bin = get_two_d_black(object_bin, mjd1, rows, cols);
    assert_equals(1, isequal(blacks, blacks_bin'));
return
