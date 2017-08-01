function self = test_multiple_plate_scales(self)
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
    disp('test multiple plate scales');

    mjd = 55000;

    % Get a star at row=500,col=500 and row=510,col=510 on each output:
    %
    [mod out] = convert_to_module_output(fix(1:.5:84.5)); % 1 1 2 2 .. 84 84
    row = repmat([500 510]', 84, 1); % 500 510 500 510 ... 500 510
    col = repmat([500 510]', 84, 1); % 500 510 500 510 ... 500 510


    % Inject noise into plate scale, make raDec2PixObject:
    %
    raDec2PixModel = retrieve_ra_dec_2_pix_model(54999, 56001);
    plateScale = raDec2PixModel.geometryModel.constants.array(253:253+84-1); 
    plateScaleOffset = 0.01*rand(1,42);               
    plateScaleOffset = repmat(plateScaleOffset, 2, 1);
    plateScaleOffset = plateScaleOffset(:);           
    plateScale = plateScale + plateScaleOffset';
    raDec2PixModel.geometryModel.constants.array(253:253+84-1) = plateScale;
    raDec2PixObject = raDec2PixClass(raDec2PixModel, 'zero-based');

    
    % Transform to ra,dec and back
    [ra dec] = pix_2_ra_dec(raDec2PixObject, mod, out, row, col, mjd, 0);
    [modAfter outAfter rowAfter colAfter] = ra_dec_2_pix(raDec2PixObject, ra, dec, mjd, 0);

    epsilon = 0.01; %pixels
    assert(sum(mod-modAfter) == 0);
    assert(sum(out-outAfter) == 0);
    assert(sum(row-rowAfter) < epsilon/length(row));
    assert(sum(col-colAfter) < epsilon/length(col));
return
