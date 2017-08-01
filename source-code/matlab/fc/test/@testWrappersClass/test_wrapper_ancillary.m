function self = test_wrappers_ancillary(self)
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

    mnemonics_in = cell(1,7);
    mnemonics_in{1} = 'TCSCCFGID';
    mnemonics_in{2} = 'ADATTERRDX';
    mnemonics_in{3} = 'PEDFPAMOD14ST';
    mnemonics_in{4} = 'PEDFPAMOD08T';
    mnemonics_in{5} = 'PEDFPAMOD13ST';
    mnemonics_in{6} = 'PEDPMAT3';
    mnemonics_in{7} = 'PW2SMBI';

%     mnemonics_in = cell(1,3); mnemonics_in{1} = 'mnemonic3'; mnemonics_in{2} = 'mnemonic1'; mnemonics_in{3} = 'mnemonic2';

    [ancillary_default mn_out]   = retrieve_ancillary_data();
    [ancillary_date_range_default mn_out] = retrieve_ancillary_data( 0, 60000);

    ancillary_mnemonics = retrieve_ancillary_data(mnemonics_in);
    ancillary_date_range= retrieve_ancillary_data(mnemonics_in, 0, 60000);

    assert_equals(~isempty(ancillary_default), 1);
    for ii = 1:length(ancillary_default)
        assert_equals(ancillary_default(ii).mnemonic, mn_out{ii});
    end

    assert_equals(~isempty(ancillary_date_range_default), 1);
    for ii = 1:length(ancillary_date_range_default)
        assert_equals(ancillary_date_range_default(ii).mnemonic, mn_out{ii});
    end

    assert_equals(~isempty(ancillary_mnemonics), 1);
    for ii = 1:length(ancillary_mnemonics)
        assert_equals(ancillary_mnemonics(ii).mnemonic, mnemonics_in{ii});
    end


    assert_equals(~isempty(ancillary_date_range), 1);
    for ii = 1:length(ancillary_date_range)
        assert_equals(ancillary_date_range(ii).mnemonic, mnemonics_in{ii});
    end


    % Out of range MJD test:
    %
    [ancillary_OOR mn_out] = retrieve_ancillary_data(-100, -99);
    assert_equals(length(ancillary_OOR), 0);
return
