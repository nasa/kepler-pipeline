%%************************************************************************************************************
% function [module,output]=get_mod_out_from_skyGroup(skyGroup, season, quarter)
%
% returns module/output from a skyGroup (1-84) for a specified season or quarter
%
% Summer = 0
% Fall   = 1
% Winter = 2
% Spring = 3
%
% If skyGroup is an array then <season> and <quarter> must be scalars, and vice versa. Will return <module> and <output> of the same length as <skyGroup> or
% <season>, <quarter>.
%
% Inputs:
%   skyGroup    -- [int array] Skygroup of interest {1:84}
%   season      -- [int array] Season of interest (if [] then uses quarter)
%   quarter     -- [int array] quarter of interest (if [] then uses season)
%
% Outputs:
%   module      -- [int array] array of same length as <season> or <quarter> or <skyGroup> of the requested modules
%   output      -- [int array] array of same length as <season> or <quarter> or <skyGroup> of the requested outputs
%
% 
% Copyright 2017 United States Government as represented by the
% Administrator of the National Aeronautics and Space Administration.
% All Rights Reserved.
% 
% NASA acknowledges the SETI Institute's primary role in authoring and
% producing the Kepler Data Processing Pipeline under Cooperative
% Agreement Nos. NNA04CC63A, NNX07AD96A, NNX07AD98A, NNX11AI13A,
% NNX11AI14A, NNX13AD01A & NNX13AD16A.
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

function [module, output] = get_mod_out_from_skyGroup(skyGroup, season, quarter)

[moduleList,outputList,seasonList,skyGroupList] = fill_sky_group_data();

if (~(isempty(season) || isempty(quarter)))
    error('Only <season> or <quarter> can be non-empty, not both.');
elseif(~isempty(quarter))
    % If using quarter, convert to season
    season = mod(quarter+2,4);
end

if (length(skyGroup) > 1 && (length(season) > 1 || length(quarter) > 1))
    error ('If skyGroup is an array then <season> and <quarter> must be scalars, and vice versa.');
elseif (length(skyGroup) > 1)
    nSkyGroups = length(skyGroup);

    module = zeros(nSkyGroups,1);
    output = zeros(nSkyGroups,1);

    for iSkyGroup = 1 : nSkyGroups

        % select season and make temporary sublists
        skyGroupIndices = find(skyGroupList == skyGroup(iSkyGroup));
        if isempty(skyGroupIndices)
            error(['get_mod_out_from_skyGroup: invalid skyGroup: ',num2str(skyGroup(iSeason))])
        end
        tmod    = moduleList(skyGroupIndices);
        tout    = outputList(skyGroupIndices);
        tseason = seasonList(skyGroupIndices);
 
        % get the right season
        iseason = find(tseason == season);
        if isempty(iseason)
            error(['get_mod_out_from_skyGroup: invalid season: ',num2str(skyGroup)])
        end
        module(iSkyGroup) = tmod(iseason);
        output(iSkyGroup) = tout(iseason);
    end
else
    nSeasons = length(season);

    module = zeros(nSeasons,1);
    output = zeros(nSeasons,1);

    for iSeason = 1 : nSeasons

        % select season and make temporary sublists
        seasonIndices = find(seasonList == season(iSeason));
        if isempty(seasonIndices)
            error(['get_mod_out_from_skyGroup: invalid season: ',num2str(season(iSeason))])
        end
        tmod = moduleList(seasonIndices);
        tout = outputList(seasonIndices);
        tsky = skyGroupList(seasonIndices);
 
        % get the right skyGroup
        isky = find(tsky == skyGroup);
        if isempty(isky)
            error(['get_mod_out_from_skyGroup: invalid sky group: ',num2str(skyGroup)])
        end
        module(iSeason) = tmod(isky);
        output(iSeason) = tout(isky);
    end
end

return



%%************************************************************************************************************
%Internal functions
%%************************************************************************************************************

function [module,output,season,skyGroup] = fill_sky_group_data()
% returns list of mod, out, season, skyGroup mappings

% data from skyGroup.csv
%  mod   out   season skyGroup
skyGroupData = [...
     2     1     2     1
    16     1     3     1
    24     1     0     1
    10     1     1     1
     2     2     2     2
    16     2     3     2
    24     2     0     2
    10     2     1     2
     2     3     2     3
    16     3     3     3
    24     3     0     3
    10     3     1     3
     2     4     2     4
    16     4     3     4
    24     4     0     4
    10     4     1     4
     3     1     2     5
    11     1     3     5
    23     1     0     5
    15     1     1     5
     3     2     2     6
    11     2     3     6
    23     2     0     6
    15     2     1     6
     3     3     2     7
    11     3     3     7
    23     3     0     7
    15     3     1     7
     3     4     2     8
    11     4     3     8
    23     4     0     8
    15     4     1     8
     4     1     2     9
     6     1     3     9
    22     1     0     9
    20     1     1     9
     4     2     2    10
     6     2     3    10
    22     2     0    10
    20     2     1    10
     4     3     2    11
     6     3     3    11
    22     3     0    11
    20     3     1    11
     4     4     2    12
     6     4     3    12
    22     4     0    12
    20     4     1    12
     6     1     2    13
    22     1     3    13
    20     1     0    13
     4     1     1    13
     6     2     2    14
    22     2     3    14
    20     2     0    14
     4     2     1    14
     6     3     2    15
    22     3     3    15
    20     3     0    15
     4     3     1    15
     6     4     2    16
    22     4     3    16
    20     4     0    16
     4     4     1    16
     7     1     2    17
    17     1     3    17
    19     1     0    17
     9     1     1    17
     7     2     2    18
    17     2     3    18
    19     2     0    18
     9     2     1    18
     7     3     2    19
    17     3     3    19
    19     3     0    19
     9     3     1    19
     7     4     2    20
    17     4     3    20
    19     4     0    20
     9     4     1    20
     8     1     2    21
    12     1     3    21
    18     1     0    21
    14     1     1    21
     8     2     2    22
    12     2     3    22
    18     2     0    22
    14     2     1    22
     8     3     2    23
    12     3     3    23
    18     3     0    23
    14     3     1    23
     8     4     2    24
    12     4     3    24
    18     4     0    24
    14     4     1    24
     9     1     2    25
     7     1     3    25
    17     1     0    25
    19     1     1    25
     9     2     2    26
     7     2     3    26
    17     2     0    26
    19     2     1    26
     9     3     2    27
     7     3     3    27
    17     3     0    27
    19     3     1    27
     9     4     2    28
     7     4     3    28
    17     4     0    28
    19     4     1    28
    10     1     2    29
     2     1     3    29
    16     1     0    29
    24     1     1    29
    10     2     2    30
     2     2     3    30
    16     2     0    30
    24     2     1    30
    10     3     2    31
     2     3     3    31
    16     3     0    31
    24     3     1    31
    10     4     2    32
     2     4     3    32
    16     4     0    32
    24     4     1    32
    11     1     2    33
    23     1     3    33
    15     1     0    33
     3     1     1    33
    11     2     2    34
    23     2     3    34
    15     2     0    34
     3     2     1    34
    11     3     2    35
    23     3     3    35
    15     3     0    35
     3     3     1    35
    11     4     2    36
    23     4     3    36
    15     4     0    36
     3     4     1    36
    12     1     2    37
    18     1     3    37
    14     1     0    37
     8     1     1    37
    12     2     2    38
    18     2     3    38
    14     2     0    38
     8     2     1    38
    12     3     2    39
    18     3     3    39
    14     3     0    39
     8     3     1    39
    12     4     2    40
    18     4     3    40
    14     4     0    40
     8     4     1    40
    13     1     2    41
    13     2     3    41
    13     3     0    41
    13     4     1    41
    13     2     2    42
    13     3     3    42
    13     4     0    42
    13     1     1    42
    13     3     2    43
    13     4     3    43
    13     1     0    43
    13     2     1    43
    13     4     2    44
    13     1     3    44
    13     2     0    44
    13     3     1    44
    14     1     2    45
     8     1     3    45
    12     1     0    45
    18     1     1    45
    14     2     2    46
     8     2     3    46
    12     2     0    46
    18     2     1    46
    14     3     2    47
     8     3     3    47
    12     3     0    47
    18     3     1    47
    14     4     2    48
     8     4     3    48
    12     4     0    48
    18     4     1    48
    15     1     2    49
     3     1     3    49
    11     1     0    49
    23     1     1    49
    15     2     2    50
     3     2     3    50
    11     2     0    50
    23     2     1    50
    15     3     2    51
     3     3     3    51
    11     3     0    51
    23     3     1    51
    15     4     2    52
     3     4     3    52
    11     4     0    52
    23     4     1    52
    16     1     2    53
    24     1     3    53
    10     1     0    53
     2     1     1    53
    16     2     2    54
    24     2     3    54
    10     2     0    54
     2     2     1    54
    16     3     2    55
    24     3     3    55
    10     3     0    55
     2     3     1    55
    16     4     2    56
    24     4     3    56
    10     4     0    56
     2     4     1    56
    17     1     2    57
    19     1     3    57
     9     1     0    57
     7     1     1    57
    17     2     2    58
    19     2     3    58
     9     2     0    58
     7     2     1    58
    17     3     2    59
    19     3     3    59
     9     3     0    59
     7     3     1    59
    17     4     2    60
    19     4     3    60
     9     4     0    60
     7     4     1    60
    18     1     2    61
    14     1     3    61
     8     1     0    61
    12     1     1    61
    18     2     2    62
    14     2     3    62
     8     2     0    62
    12     2     1    62
    18     3     2    63
    14     3     3    63
     8     3     0    63
    12     3     1    63
    18     4     2    64
    14     4     3    64
     8     4     0    64
    12     4     1    64
    19     1     2    65
     9     1     3    65
     7     1     0    65
    17     1     1    65
    19     2     2    66
     9     2     3    66
     7     2     0    66
    17     2     1    66
    19     3     2    67
     9     3     3    67
     7     3     0    67
    17     3     1    67
    19     4     2    68
     9     4     3    68
     7     4     0    68
    17     4     1    68
    20     1     2    69
     4     1     3    69
     6     1     0    69
    22     1     1    69
    20     2     2    70
     4     2     3    70
     6     2     0    70
    22     2     1    70
    20     3     2    71
     4     3     3    71
     6     3     0    71
    22     3     1    71
    20     4     2    72
     4     4     3    72
     6     4     0    72
    22     4     1    72
    22     1     2    73
    20     1     3    73
     4     1     0    73
     6     1     1    73
    22     2     2    74
    20     2     3    74
     4     2     0    74
     6     2     1    74
    22     3     2    75
    20     3     3    75
     4     3     0    75
     6     3     1    75
    22     4     2    76
    20     4     3    76
     4     4     0    76
     6     4     1    76
    23     1     2    77
    15     1     3    77
     3     1     0    77
    11     1     1    77
    23     2     2    78
    15     2     3    78
     3     2     0    78
    11     2     1    78
    23     3     2    79
    15     3     3    79
     3     3     0    79
    11     3     1    79
    23     4     2    80
    15     4     3    80
     3     4     0    80
    11     4     1    80
    24     1     2    81
    10     1     3    81
     2     1     0    81
    16     1     1    81
    24     2     2    82
    10     2     3    82
     2     2     0    82
    16     2     1    82
    24     3     2    83
    10     3     3    83
     2     3     0    83
    16     3     1    83
    24     4     2    84
    10     4     3    84
     2     4     0    84
    16     4     1    84];
module = skyGroupData(:,1);
output = skyGroupData(:,2);
season = skyGroupData(:,3);
skyGroup = skyGroupData(:,4);

return

