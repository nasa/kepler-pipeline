
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

startKeplerId = 7589230;
endKeplerId = startKeplerId + 100;
times = [];
idList = [7589230 7589241 7589247 7589249 7589253 7589262 7589266 7589281 7589285 7589289 7589291 7589292 7589293];
ccdModule = 2;
ccdOutput = 1;
targetListSetName = 'quarter1_spring2009_lc_v2';

[kicsTLS characteristicsTLS] = retrieve_kics_by_kepler_id_sdf(targetListSetName, 'get_chars');
assert(length(characteristicsTLS) > 150000)
assert(abs(length(kicsTLS) -  length(characteristicsTLS)) ./ length(kicsTLS) > .9 );
assert(characteristicsTLS(1).COLUMN_SEASON_0 > 0 && characteristicsTLS(1).COLUMN_SEASON_0 < 1200) ;

[kicsTLS2 characteristicsTLS2] = retrieve_kics_by_kepler_id_sdf(targetListSetName, ccdModule, ccdOutput, 'get_chars');
assert(1292 == length(characteristicsTLS2))
assert_equals(length(kicsTLS2), length(characteristicsTLS2))
assert_equals(29, kicsTLS2(1).getSkyGroupId)
assert(characteristicsTLS2(1).COLUMN_SEASON_0 > 0 && characteristicsTLS2(1).COLUMN_SEASON_0 < 1200) 

kicsRange                    = retrieve_kics_by_kepler_id_sdf(startKeplerId, endKeplerId);
kicsListNoNulls              = retrieve_kics_by_kepler_id_sdf(idList);
kicSingle                    = retrieve_kics_by_kepler_id_sdf(startKeplerId);
kicsListWithNulls            = retrieve_kics_by_kepler_id_sdf(startKeplerId:endKeplerId);
kicsRange                    = retrieve_kics_by_kepler_id_sdf(startKeplerId, endKeplerId, 'get_chars');
kicsListNoNulls              = retrieve_kics_by_kepler_id_sdf(idList,                     'get_chars');
kicSingle                    = retrieve_kics_by_kepler_id_sdf(startKeplerId,              'get_chars');
kicsListWithNulls            = retrieve_kics_by_kepler_id_sdf(startKeplerId:endKeplerId,  'get_chars');

[kicsRange         outCharsRange]     = retrieve_kics_by_kepler_id_sdf(startKeplerId, endKeplerId);
[kicsListNoNulls   outCharsNoNulls]   = retrieve_kics_by_kepler_id_sdf(idList);
[kicSingle         outCharSingles]    = retrieve_kics_by_kepler_id_sdf(startKeplerId);
[kicsListWithNulls outCharsWithNulls] = retrieve_kics_by_kepler_id_sdf(startKeplerId:endKeplerId);
t1=clock(); [kicsRange2         outCharsRange2]         = retrieve_kics_by_kepler_id_sdf(startKeplerId, endKeplerId, 'get_chars'); t2 = clock(); times(end+1)=etime(t2, t1)
t1=clock(); [kicsListNoNulls2   outCharsListNoNulls2]   = retrieve_kics_by_kepler_id_sdf(idList,                     'get_chars'); t2 = clock(); times(end+1)=etime(t2, t1)
t1=clock(); [kicSingle2         outCharsSingle2]        = retrieve_kics_by_kepler_id_sdf(startKeplerId,              'get_chars'); t2 = clock(); times(end+1)=etime(t2, t1)
t1=clock(); [kicsListWithNulls2 outCharsListWithNulls2] = retrieve_kics_by_kepler_id_sdf(startKeplerId:endKeplerId,  'get_chars'); t2 = clock(); times(end+1)=etime(t2, t1)

t1=clock();  kics1          = retrieve_kics_sdf(            2, 1, 54900);                      t2 = clock(); times(end+1)=etime(t2, t1)
t1=clock();  kics2          = retrieve_kics_sdf(            2, 1, 54900, 10, 12);              t2 = clock(); times(end+1)=etime(t2, t1)
t1=clock(); [kics3 outChar] = retrieve_kics_sdf(            2, 1, 54900,         'get_chars'); t2 = clock(); times(end+1)=etime(t2, t1)
t1=clock(); [kics4 outChar] = retrieve_kics_sdf(            2, 1, 54900, 10, 12, 'get_chars'); t2 = clock(); times(end+1)=etime(t2, t1)

t1=clock();  kics5          = retrieve_kics_sdf(2, 1, 54900);                      t2 = clock(); times(end+1)=etime(t2, t1)
t1=clock();  kics6          = retrieve_kics_sdf(2, 1, 54900, 10, 12);              t2 = clock(); times(end+1)=etime(t2, t1)
t1=clock();  kics7          = retrieve_kics_sdf(2, 1, 54900,         'get_chars'); t2 = clock(); times(end+1)=etime(t2, t1)
t1=clock();  kics8          = retrieve_kics_sdf(2, 1, 54900, 10, 12, 'get_chars'); t2 = clock(); times(end+1)=etime(t2, t1)

times
