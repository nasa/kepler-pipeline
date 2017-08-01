function self = test_compare_with_old(self)
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
    disp('compare with old');
    %ra  = 300;
    %dec = 45;
    %checkIt(ra, dec);

    %for nPointsPower = 2:6
        %nPoints = 2^nPointsPower;
        %[ra_grid dec_grid] = getRaDecMeshVectors(nPoints);
        %retVals(nPointsPower) = checkIt(ra_grid, dec_grid);
    %end
    %assert_equals(0, any(retVals == 1));
    assert_equals(1, 1);
return

function isGood = checkIt(ra, dec)
    quarter = 1;
    mjd = 55000;
    
    [mods_a outs_a rows_a cols_a] = RADec2Pix(ra, dec, quarter);
    [mods_b outs_b rows_b cols_b] = ra_dec_2_pix(ra, dec, mjd, 0);
    onChip = mods_a ~= -1;
    
    if 0 == sum(onChip)
        isGood = 0;
        return
    end
    
    ra_o = ra(onChip);
    dec_o = dec(onChip);

    quarter = repmat(quarter, size(mods_a(onChip)));
    [ra_a dec_a] = Pix2RADec(mods_a(onChip), outs_a(onChip), rows_a(onChip), cols_a(onChip), quarter);
    [ra_b dec_b] = pix_2_ra_dec(mods_b(onChip), outs_b(onChip), rows_b(onChip), cols_b(onChip), mjd, 0);

    largestRoundTripDifference = max([max(abs(ra_o-ra_a))
                                      max(abs(ra_o-ra_b))
                                      max(abs(dec_o-dec_a))
                                      max(abs(dec_o-dec_b))]);
    isGood = ~any(largestRoundTripDifference < 1e-12) & length(find(onChip ~= 0));
return
