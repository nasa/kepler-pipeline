function self = test_round_trip(self)
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
    disp('test round trip: RaDec2Pix --> Pix2RaDec --> RaDec2Pix');

    [inRa   inDec] = getRaDecMeshVectors();

    mjd = 55000;

    % Inject noise into plate scale
    raDec2PixModel = retrieve_ra_dec_2_pix_model(54999, 56001);
    plateScale = raDec2PixModel.geometryModel.constants.array(253:253+84-1); 
    plateScaleOffset = 0.01*rand(1,42);               
    plateScaleOffset = repmat(plateScaleOffset, 2, 1);
    plateScaleOffset = plateScaleOffset(:);           
    plateScale = plateScale + plateScaleOffset';


    raDec2PixModel.geometryModel.constants.array(253:253+84-1) = plateScale;

    raDec2PixObject = raDec2PixClass(raDec2PixModel, 'zero-based');

    
    [mod out row col] = ra_dec_2_pix(raDec2PixObject, inRa, inDec, mjd, 0);

    onChip  = (mod ~= -1);
    mod = mod(onChip);
    out = out(onChip);
    row = row(onChip);
    col = col(onChip);
    inRa = inRa(onChip);
    inDec = inDec(onChip);

    [outRa outDec] = pix_2_ra_dec(raDec2PixObject, mod, out, row, col, mjd, 0);

    dRaPix  = (inRa  -  outRa)*3600/3.98; % platescale approx
    dDecPix = (inDec - outDec)*3600/3.98; % platescale approx

    epsilon = 1/60/60/100;
    goodRoundTrip = (abs(dRaPix) < epsilon) & (abs(dDecPix) < epsilon);

    plot(dRaPix, dDecPix, 'x-');

    sum(onChip);
    percentageSuccessfulRoundTrip = sum(goodRoundTrip) / length(goodRoundTrip);
    assert(percentageSuccessfulRoundTrip == 1);
    
    ra=300; dec=45; mjd=55000; 
    [m o r c] = ra_dec_2_pix(raDec2PixObject, ra, dec, mjd, 0); 
    [raOut decOut] = pix_2_ra_dec(raDec2PixObject, m, o, r, c, mjd, 0);
    dRaPix = (ra - raOut)*3600/3.98;    % platescale approx
    dDecPix = (dec - decOut)*3600/3.98; % platescale approx
    assert(ra-raOut < epsilon && dec-decOut < epsilon);

    mjd = 55000;
    diff = 10;
    col_high = 1112-diff;
    col_low  =   12+diff;
    col_mid  = mean([col_high col_low]);
    row_high = 1044-diff;
    row_low  =   20+diff;
    row_mid  = mean([col_high col_low]);

    for ic = 1:84
        [mod out] = convert_to_module_output(ic);
        mm = [mod mod mod mod]';
        oo = [out out out out]';
        rr = [row_low row_low row_high row_high]';
        cc = [col_low col_high col_low col_high]';

        p1 = 290.67;
        p2 = 44.5;
        p3 = 0;

        [ra dec]      = pix_2_ra_dec_absolute(raDec2PixObject, mm, oo, rr, cc, mjd, p1, p2, p3, 0);
        [mp op rp cp] = ra_dec_2_pix_absolute(raDec2PixObject,        ra, dec, mjd, p1, p2, p3, 0);

        assert(all(mp == mm));
        assert(all(op == oo));
        assert(all(cc - cp < 1e-9));
        assert(all(rr - rp < 1e-9));
    end


    [mm oo] = convert_to_module_output(1:84);
    rr = 512 + zeros(size(mm));
    cc = 512 + zeros(size(mm));
    [ra dec] = pix_2_ra_dec(raDec2PixObject, mm, oo, rr, cc, mjd);
    [mmm ooo rrr ccc] = ra_dec_2_pix(raDec2PixObject, ra, dec, mjd);
    assert(all(mm == mmm));
    assert(all(oo == ooo));
    assert(all(rr - rrr < 1e-9));
    assert(all(cc - ccc < 1e-9));
    
    
    


return
