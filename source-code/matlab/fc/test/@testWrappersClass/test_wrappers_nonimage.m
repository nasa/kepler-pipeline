function self = test_wrappers_non_image(self)
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
    display('run all non-image wrappers');

    model = retrieve_gain_model();
    model_bin = read_GainModel('/path/to/gain.bin');
    assert_equals(1, isequal(model.constants.array, model_bin.constants.array'));
    assert_equals(1, isequal(model.mjds, model_bin.mjds'));

    model = retrieve_linearity_model(55000, 56000, 2, 1);
    model_bin = read_LinearityModel('/path/to/linearity.bin');
    assert_equals(1, isequal(model.constants.array, model_bin.constants.array'));

    model = retrieve_ra_dec_2_pix_model(55000, 56000);
    model_bin = read_RaDec2PixModel('/path/to/raDec2Pix.bin');
    assert_equals(model.spiceFileDir, model_bin.spiceFileDir)
    assert_equals(model.spiceFileName, model_bin.spiceFileName)
    assert_equals(model.pointingModel.mjds, model_bin.pointingModel.mjds)
    assert_equals(model.pointingModel.declinations, model_bin.pointingModel.declinations)
    assert_equals(model.pointingModel.rolls, model_bin.pointingModel.rolls)
    assert_equals(model.geometryModel.mjds, model_bin.geometryModel.mjds)
    for itime = 1:length(model.geometryModel.constants)
        assert_equals(model.geometryModel.constants(itime).array, model_bin.geometryModel.constants(itime).array')
        assert_equals(model.geometryModel.uncertainty(itime).array, model_bin.geometryModel.uncertainty(itime).array')
    end
    assert_equals(model.rollTimeModel.mjds, model_bin.rollTimeModel.mjds)
    assert_equals(model.rollTimeModel.deltaAngleDegrees, model_bin.rollTimeModel.deltaAngleDegrees)
    assert_equals(model.rollTimeModel.seasons, model_bin.rollTimeModel.seasons)

    model = retrieve_undershoot_model(55000, 56000);
    model_bin = read_UndershootModel('/path/to/undershoot.bin');
    assert_equals(model.mjds, model_bin.mjds)
    for ichan = 1:84
        assert_equals(model.constants.array(ichan).array, model_bin.constants.array(ichan).array)
    end

    model = retrieve_read_noise_model(55000, 56000);
    model_bin = read_ReadNoiseModel('/path/to/readNoise.bin');
    assert_equals(model.mjds, model_bin.mjds)
    assert_equals(model.constants.array, model_bin.constants.array')
return
