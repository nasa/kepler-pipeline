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
startMjd = 55000;
endMjd = 55100;
saveDirectory = '/path/to/wrapper_mats_test/';

rm_ias = invoke_and_save(saveDirectory, 'retrieve_ra_dec_2_pix_model', startMjd, endMjd);
rm_reg = retrieve_ra_dec_2_pix_model(startMjd, endMjd);
assert(isequalStruct(rm_ias, rm_reg));

rm_ias2 = invoke_and_save(saveDirectory, 'retrieve_ra_dec_2_pix_model');
rm_reg2 = retrieve_ra_dec_2_pix_model();
assert(isequalStruct(rm_ias2, rm_reg2));

readNoiseModel_ias = invoke_and_save(saveDirectory, 'retrieve_read_noise_model', startMjd, endMjd);
readNoiseModel_reg = retrieve_read_noise_model(startMjd, endMjd);
assert(isequalStruct(readNoiseModel_reg, readNoiseModel_ias));

tad_ias = invoke_and_save(saveDirectory, 'retrieve_tad', 2, 1, 'quarter1_spring2009_lc', 1);
tad_reg = retrieve_tad(2, 1, 'quarter1_spring2009_lc', 1);
tad_load = retrieve_tad_testproperties(2, 1, 'quarter1_spring2009_lc', 1);
assert(isequalStruct(tad_ias, tad_reg));
assert(isequalStruct(tad_load, tad_reg));


try 
    [kics_ias chars_ias] =  invoke_and_save(saveDirectory, 'retrieve_kics_by_kepler_id', 7589230, 'get_chars');
catch
    assert(true)
end
[kics_reg chars_reg] =  retrieve_kics_by_kepler_id(7589230, 'get_chars');
% assert(isequalStruct(kics_ias, kics_reg));
% assert(kics_ias.equals(kics_reg));
% assert(isequalwithequalnans(chars_ias, chars_reg)); % chars can contain NaNs
