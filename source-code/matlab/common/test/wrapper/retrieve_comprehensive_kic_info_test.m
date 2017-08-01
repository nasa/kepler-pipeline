
% Don't forget to:
%     export KEPLER_CONFIG_PATH=/path/to/dist/etc/kepler.properties
% before starting matlab
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

oneId = 7589230;
manyIds = [7589230 7589241 7589247];
mjd = 55101;
season = 2;
seasons = 0:3;
oneChannel = 83;
manyChannels = [1 2 13 82 83];
ccdMod = 10;
ccdOut =  3;
ccdMods = [ 9 11 12 13 10];
ccdOuts = [ 1  1  2  3  3];

% Case 1:
oneKeplerId   = retrieve_comprehensive_kic_info(oneId);
manyKeplerIds = retrieve_comprehensive_kic_info(manyIds);

assert(27 == oneKeplerId.skyGroup);
assert(all([0 1 2 3] == oneKeplerId.season));
assert(true == isequalStruct(oneKeplerId, manyKeplerIds(1)));
assert(false == isequalStruct(oneKeplerId, manyKeplerIds(2)));
assert(false == isequalStruct(oneKeplerId, manyKeplerIds(3)));

% Case 2:
oneKeplerIdWithTime    = retrieve_comprehensive_kic_info(oneId, mjd);
manyKeplerIdsWithTime  = retrieve_comprehensive_kic_info(manyIds, mjd);
oneChannelWithSeason   = retrieve_comprehensive_kic_info(oneId, season);
manyChannelsWithSeason = retrieve_comprehensive_kic_info(manyIds, season);
oneChannelWithMjd      = retrieve_comprehensive_kic_info(oneChannel, mjd);
manyChannelsWithMjd    = retrieve_comprehensive_kic_info(manyChannels, mjd);

assert(true == isequalStruct(oneKeplerIdWithTime,  manyKeplerIdsWithTime(1)));
assert(true == isequalStruct(oneChannelWithSeason, manyChannelsWithSeason(1)));
assert(true == isequalStruct(oneChannelWithMjd,    manyChannelsWithMjd(end)));



% Case 3:
oneModOutWithSeason   = retrieve_comprehensive_kic_info(ccdMod,  ccdOut,  season);
manyModOutsWithSeason = retrieve_comprehensive_kic_info(ccdMods, ccdOuts, season);
oneModOutWithMjd      = retrieve_comprehensive_kic_info(ccdMod,  ccdOut,  mjd);
manyModOutsWithMjd    = retrieve_comprehensive_kic_info(ccdMods, ccdOuts, mjd);

assert(true == isequalStruct(oneModOutWithSeason, manyModOutsWithSeason(end)));
assert(true == isequalStruct(oneModOutWithMjd, manyModOutsWithMjd(end)));
assert(oneModOutWithSeason.skyGroup == 31);
assert(manyModOutsWithSeason(1).skyGroup == (manyModOutsWithSeason(2).skyGroup - 8))
assert(manyModOutsWithSeason(2).skyGroup == (manyModOutsWithSeason(3).skyGroup - 5))


% Check fieldnames
fieldNamesOneKeplerId            = sort(fieldnames(oneKeplerId)); 
fieldNamesManyKeplerIds          = sort(fieldnames(manyKeplerIds));
fieldNamesOneKeplerIdWithTime    = sort(fieldnames(oneKeplerIdWithTime));  
fieldNamesManyKeplerIdsWithTime  = sort(fieldnames(manyKeplerIdsWithTime));
fieldNamesOneChannelWithSeason   = sort(fieldnames(oneChannelWithSeason)); 
fieldNamesManyChannelsWithSeason = sort(fieldnames(manyChannelsWithSeason));
fieldNamesOneChannelWithMjd      = sort(fieldnames(oneChannelWithMjd));    
fieldNamesManyChannelsWithMjd    = sort(fieldnames(manyChannelsWithMjd));  
fieldNamesOneModOutWithSeason    = sort(fieldnames(oneModOutWithSeason)); 
fieldNamesManyModOutsWithSeason  = sort(fieldnames(manyModOutsWithSeason));
fieldNamesOneModOutWithMjd       = sort(fieldnames(oneModOutWithMjd));    
fieldNamesManyModOutsWithMjd     = sort(fieldnames(manyModOutsWithMjd));  

assert(true == isequal(fieldNamesOneKeplerId, fieldNamesOneKeplerId));
assert(true == isequal(fieldNamesOneKeplerId, fieldNamesManyKeplerIds));
assert(true == isequal(fieldNamesOneKeplerId, fieldNamesOneKeplerIdWithTime));
assert(true == isequal(fieldNamesOneKeplerId, fieldNamesManyKeplerIdsWithTime));
assert(true == isequal(fieldNamesOneKeplerId, fieldNamesOneChannelWithSeason));
assert(true == isequal(fieldNamesOneKeplerId, fieldNamesManyChannelsWithSeason));
assert(true == isequal(fieldNamesOneKeplerId, fieldNamesOneChannelWithMjd));
assert(true == isequal(fieldNamesOneKeplerId, fieldNamesManyChannelsWithMjd));
assert(true == isequal(fieldNamesOneKeplerId, fieldNamesOneModOutWithSeason));
assert(true == isequal(fieldNamesOneKeplerId, fieldNamesManyModOutsWithSeason));
assert(true == isequal(fieldNamesOneKeplerId, fieldNamesOneModOutWithMjd));
assert(true == isequal(fieldNamesOneKeplerId, fieldNamesManyModOutsWithMjd));

% Roundtrip test for season arg:
%
for season = 0:3
    seasonToMjd = retrieve_comprehensive_kic_info(oneId, season);
    mjdToSeason = retrieve_comprehensive_kic_info(oneId, seasonToMjd.mjd);

    assert_equals(seasonToMjd.season, season);
    assert_equals(mjdToSeason.season, season);
end


% Large number of targets case:
%
ppa_targets = retrieve_kepler_ids_by_label('quarter2_summer2009_lc', 'labels', {'PPA_STELLAR'});
ppa_keps = [ppa_targets.keplerId];
tic
ppa_kicinfo = retrieve_comprehensive_kic_info(ppa_keps);
time_running_ppa_targets = toc;
assert(time_running_ppa_targets < 1000);
