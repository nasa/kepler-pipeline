function self = test_lots(self)
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
    display('lots');
    close all

    RaDec2PixTest(1, 1, 0);
    Pix2RaDecTest(1, 1, 0);

    RaDec2PixTest(1, 1, 1);
    Pix2RaDecTest(1, 1, 1);

    RaDec2PixTest(1, 100, 0);
    Pix2RaDecTest(1, 100, 0);

    RaDec2PixTest(1, 10, 1);
    Pix2RaDecTest(1, 10, 1);

    RaDec2PixTest(1, 100, 1);
    Pix2RaDecTest(1, 100, 1);

    RaDec2PixTest(100, 1, 1);
    Pix2RaDecTest(100, 1, 1);

    RaDec2PixTest(10, 10, 1);
    Pix2RaDecTest(10, 10, 1);

    assert(1 == 1);
return

function [mod out row col] = RaDec2PixTest(nStars, nTimes, doDva)
    %tic
    % one year
    time = 55001:(400/nTimes):55400;

    raDec2PixData = retrieve_ra_dec_2_pix_model(54999, 56001);
    raDec2PixObject = raDec2PixClass(raDec2PixData, 'zero-based');

    angleRange = 0.1;
    angleStep = angleRange / nStars;

    ra  = (15*19);
    dec =      45;
    if (nStars > 1)
        ra  = ((15*19):angleStep:(15*19+angleRange-angleStep))';
        dec =      (45:angleStep:(45   +angleRange-angleStep))';
    end

    [ mod out row col ] = ra_dec_2_pix(raDec2PixObject, ra, dec, time, doDva);
    %toc;
return

function [ra dec] = Pix2RaDecTest(nStars, nTimes, doDva)
    %tic
    time = 0.055e6:(0.055e6+(nTimes-1));

    raDec2PixData = retrieve_ra_dec_2_pix_model(54999, 56001);
    raDec2PixObject = raDec2PixClass(raDec2PixData, 'zero-based');

    pixelRange = 800;
    pixelStep = pixelRange / nStars;

    rows = 100;
    cols = 100;
    mods = 4;
    outs = 1;
    if (nStars > 1)
        rows = 100:pixelStep:(100+pixelRange-pixelStep);
        cols = 100:pixelStep:(100+pixelRange-pixelStep);
        mods = repmat(mods,size(rows));
        outs = repmat(outs,size(rows));
    end

    [ ra dec ] = pix_2_ra_dec(raDec2PixObject, mods, outs, rows, cols, time, doDva);
    %toc;
return
