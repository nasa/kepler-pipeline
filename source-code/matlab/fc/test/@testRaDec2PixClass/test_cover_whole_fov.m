function self = test_cover_whole_fov(self)
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
    display('cover whole FOV');
    quarter = 1;
    mjd = 55000;

    raDec2PixData = retrieve_ra_dec_2_pix_model(54999, 56001);
    raDec2PixObject = raDec2PixClass(raDec2PixData, 'zero-based');

    [raMesh, decMesh] = getRaDecMeshVectors(10);


    %[modsa outsa rowsa colsa] = RADec2Pix(raMesh, decMesh, quarter);
    [modsb outsb rowsb colsb] = ra_dec_2_pix(raDec2PixObject, raMesh, decMesh, mjd, 0);

%     assert_equals(0, any(0 ~= modsa-modsb));
%     assert_equals(0, any(0 ~= outsa-outsb));
%     assert_equals(0, any(1e-5 < rowsa-rowsb));
%     assert_equals(0, any(1e-5 < colsa-colsb));

    onChip = (modsb ~= -1 & rowsb > 0 & colsb > 0);
    mods = modsb(onChip);
    outs = outsb(onChip);
    rows = rowsb(onChip);
    cols = colsb(onChip);

    [raOut decOut] = pix_2_ra_dec(raDec2PixObject, mods, outs, rows, cols, mjd);
    dRa = raMesh(onChip) - raOut;
    dDec = decMesh(onChip) - decOut;

%     assert_equals(0, any(dRa > 1e-2));
%     assert_equals(0, any(dDec > 1e-2));

    onChipRa  = raMesh(onChip);
    onChipDec = decMesh(onChip);
    offset = ((1:(length(onChipRa)))/length(onChipRa))';
return
