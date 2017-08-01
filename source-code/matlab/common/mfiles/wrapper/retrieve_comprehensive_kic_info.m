function outputStruct = retrieve_comprehensive_kic_info(varargin)    
% SIGNATURES:
%     outputStruct = retrieve_comprehensive_kic_info(keplerIds)
%     outputStruct = retrieve_comprehensive_kic_info(keplerIds, MJD)
% 
%     outputStruct = retrieve_comprehensive_kic_info(keplerId,        seasonNumber)
%     outputStruct = retrieve_comprehensive_kic_info(keplerIdsVector, seasonNumber)
% 
%     outputStruct = retrieve_comprehensive_kic_info(ccdModules, ccdOutputs, seasonNumber)
%     outputStruct = retrieve_comprehensive_kic_info(ccdModules, ccdOutputs, MJD)
%     outputStruct = retrieve_comprehensive_kic_info(channelNumbers, seasonNumber)
%     outputStruct = retrieve_comprehensive_kic_info(channelNumbers, MJD)   
% 
%  INPUTS:
%      The inputs keplerIds, ccdModules/ccdOutputs, and channelNumbers can either be scalars or vectors.
%      The inputs MJD and seasonNumber must be single-element scalars.
%        
%      The input seasonNumber is 0, 1, 2, or 3 (summer, fall, winter, or spring).
%
%
%  OUTPUTS:
%      outputStruct(nKeplerIds)
%          skyGroup
%          ra
%          dec
%          ccdModule
%          ccdOutput
%          ccdRow
%          ccdColumn
%          season
%          mjd
%
%      Each output is a single value if all arguments are scalar, otherwise
%      it is a vector.
%
%  EXAMPLES:
%      Running for one or multiple Kepler IDs:
%          out = retrieve_comprehensive_kic_info(7589230)
%          out = retrieve_comprehensive_kic_info([7589230 7589241 7589247])
% 
%      One or multiple kepler IDs with an MJD:
%          oneKeplerIdWithTime    = retrieve_comprehensive_kic_info(oneId, mjd);
%          manyKeplerIdsWithTime  = retrieve_comprehensive_kic_info(manyIds, mjd);
% 
%      One or multiple kepler IDs with a season:
%          oneChannelWithSeason   = retrieve_comprehensive_kic_info(oneId, season);
%          manyChannelsWithSeason = retrieve_comprehensive_kic_info(manyIds, season);
%      Since a given season corresponds to several ranges in MJD over the
%      Kepler mission, the MJD returned is the earliest MJD for the first occurrance of that season after MJD 55000.
%      To avoid returning an MJD exactly at the time a roll was executed, 10.0 is added to the returned MJD.
%
%      One or multiple channels with an MJD:
%          oneChannelWithMjd      = retrieve_comprehensive_kic_info(oneChannel, mjd);
%          manyChannelsWithMjd    = retrieve_comprehensive_kic_info(manyChannels, mjd);
%
%      One or multiple module/output pairs a season:
%          oneModOutWithSeason   = retrieve_comprehensive_kic_info(ccdMod,  ccdOut,  season);
%          manyModOutsWithSeason = retrieve_comprehensive_kic_info(ccdMods, ccdOuts, season);
%
%      One or multiple module/output pairs an MJD:
%          oneModOutWithMjd      = retrieve_comprehensive_kic_info(ccdMod,  ccdOut,  mjd);
%          manyModOutsWithMjd    = retrieve_comprehensive_kic_info(ccdMods, ccdOuts, mjd);
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




    raDec2PixModel = retrieve_ra_dec_2_pix_model();
    raDec2PixObject = raDec2PixClass(raDec2PixModel,'one-based');

    switch nargin        
        case 1
            %     outputStruct = retrieve_comprehensive_kic_info(keplerId)
            %     outputStruct = retrieve_comprehensive_kic_info(keplerIdsVector)
            %
            % Since no time argument was given, do all 4 seasons:
            %
            keplerIds = varargin{1};

            kics = retrieve_kics_by_kepler_id(keplerIds);
            outputStruct = preallocate_output_struct(length(keplerIds));
            
            for ii = 1:length(kics)
                outputStruct(ii).ra = 15 .* kics(ii).ra.value;
                outputStruct(ii).dec = kics(ii).dec.value;
            end
            
            for iseason = 1:4
                seasonZeroIndex = find(raDec2PixModel.rollTimeModel.seasons == 0, 1);
                currentSeasonIndex = seasonZeroIndex + iseason - 1;
                mjd = season_index_to_mjd(raDec2PixModel.rollTimeModel, currentSeasonIndex);
                season = raDec2PixModel.rollTimeModel.seasons(currentSeasonIndex);

                [mods outs rows cols] = ra_dec_2_pix(raDec2PixObject, [outputStruct.ra], [outputStruct.dec], mjd);

                for ikeplerid = 1:length(keplerIds)
                    outputStruct(ikeplerid).ccdModule(iseason) = mods(ikeplerid);
                    outputStruct(ikeplerid).ccdOutput(iseason) = outs(ikeplerid);
                    outputStruct(ikeplerid).ccdRow(   iseason) = rows(ikeplerid);
                    outputStruct(ikeplerid).ccdColumn(iseason) = cols(ikeplerid);
                    outputStruct(ikeplerid).season(   iseason) = season;
                    outputStruct(ikeplerid).mjd(      iseason) = mjd;
                    outputStruct(ikeplerid).skyGroup = kics(ikeplerid).skyGroupId;
                end

            end

        case 2
            %     outputStruct = retrieve_comprehensive_kic_info(keplerId,        mjd)
            %     outputStruct = retrieve_comprehensive_kic_info(keplerIdsVector, mjd)
            %     outputStruct = retrieve_comprehensive_kic_info(keplerId,        seasonNumber)
            %     outputStruct = retrieve_comprehensive_kic_info(keplerIdsVector, seasonNumber)
            %
            %     outputStruct = retrieve_comprehensive_kic_info(channelNumber, seasonNumber)
            %     outputStruct = retrieve_comprehensive_kic_info(channelNumber, mjd)
            %
            if all(varargin{1} <= 84) && all(varargin{1} >= 1)
                channelNumbers = varargin{1};
            else
                keplerIds = varargin{1};
            end
            
            dateArg = varargin{2};
            if length(dateArg) ~= 1
                error('Matlab:common:wrapper:retrieve_comprehensive_kic_info', 'dateArg must be a scalar, not a vector: exit');
            end
            
            if dateArg > 20
                mjd = dateArg;
            else
                seasonNumber = dateArg;
            end

            if exist('keplerIds') && exist('mjd') %#ok<EXIST>
                outputStruct = get_by_kepler_ids_and_mjd(keplerIds, raDec2PixObject, mjd);
            elseif exist('keplerIds')      && exist('seasonNumber') %#ok<EXIST>
                outputStruct = get_by_kepler_ids_and_season_number(keplerIds, raDec2PixObject, seasonNumber);
            elseif exist('channelNumbers') && exist('mjd') %#ok<EXIST>
                outputStruct = get_by_channels_and_mjd(raDec2PixModel.rollTimeModel, channelNumbers, mjd);
            elseif exist('channelNumbers') && exist('seasonNumber') %#ok<EXIST>
                outputStruct = get_by_channels_and_season(raDec2PixModel.rollTimeModel, channelNumbers, seasonNumber);
            else
                error('Matlab:SBT:retrieve_comprehensive_kic_info', 'Illegal arguments. See helptext for allowed syntax');
            end
        case 3
            %     outputStruct = retrieve_comprehensive_kic_info(ccdModule, ccdOutput, seasonNumber)
            %     outputStruct = retrieve_comprehensive_kic_info(ccdModule, ccdOutput, mjd)
            %
            ccdModules = varargin{1};
            ccdOutputs = varargin{2};
            channelNumbers = convert_from_module_output(ccdModules, ccdOutputs);

            dateArg = varargin{3};
            if length(dateArg) ~= 1
                error('Matlab:common:wrapper:retrieve_comprehensive_kic_info', 'dateArg must be a scalar, not a vector: exit');
            end
            if dateArg > 20
                mjd = dateArg;
            else
                seasonNumber = dateArg;
            end            

            if exist('mjd')
                outputStruct = retrieve_comprehensive_kic_info(channelNumbers, mjd);
            elseif exist('seasonNumber')
                outputStruct = retrieve_comprehensive_kic_info(channelNumbers, seasonNumber);
            else
                error('Matlab:SBT:retrieve_comprehensive_kic_info', 'Illegal arguments. See helptext for allowed syntax');
            end
    end
return

function season = mjd_to_season(rollTimeModel, mjd)
    mjdIndex = find(rollTimeModel.mjds <= mjd, 1, 'last');
    season = double(rollTimeModel.seasons(mjdIndex));
return

function mjd = season_index_to_mjd(rollTimeModel, seasonIndex)
    mjd = rollTimeModel.mjds(seasonIndex) + 10; % Add 10 to MJD to avoid roll boundry
return

function mjd = season_to_mjd(rollTimeModel, seasonNumber)
    seasonIndex = find(rollTimeModel.seasons == seasonNumber & rollTimeModel.mjds >= 55000, 1, 'first');
    mjd = season_index_to_mjd(rollTimeModel, seasonIndex);
return

function outputStruct = get_by_kepler_ids_and_mjd(keplerIds, raDec2PixObject, mjd)
    kics = retrieve_kics_by_kepler_id(keplerIds);
    for ii = 1:length(kics)
        ra(ii) = 15 .* [kics(ii).ra.value];
        dec(ii) = [kics(ii).dec.value];
    end
    [mods outs rows cols] = ra_dec_2_pix(raDec2PixObject, ra, dec, mjd);

    outputStruct = make_output_struct_from_kepler_ids(raDec2PixObject, keplerIds, mjd, ra, dec, mods, outs, rows, cols);
return

function outputStruct = get_by_kepler_ids_and_season_number(keplerIds, raDec2PixObject, seasonNumber)
    kics = retrieve_kics_by_kepler_id(keplerIds);
    for ii = 1:length(kics)
        ra(ii) = 15 .* [kics(ii).ra.value];
        dec(ii) = [kics(ii).dec.value];
    end
    mjd = season_to_mjd(get(raDec2PixObject, 'rollTimeModel'), seasonNumber);
    [mods outs rows cols] = ra_dec_2_pix(raDec2PixObject, ra, dec, mjd);

    outputStruct = make_output_struct_from_kepler_ids(raDec2PixObject, keplerIds, mjd, ra, dec, mods, outs, rows, cols);
return

function outputStruct = get_by_channels_and_mjd(rollTimeModel, channels, mjd)
    [ccdModule ccdOutput] = convert_to_module_output(channels);
    season = mjd_to_season(rollTimeModel, mjd);

    for ichan = 1:length(channels)
        skyGroup = mod_out_season_to_sky_group(ccdModule(ichan), ccdOutput(ichan), season);

        outputStruct(ichan).ra  = [];
        outputStruct(ichan).dec = [];
        
        outputStruct(ichan).ccdModule = ccdModule(ichan);
        outputStruct(ichan).ccdOutput = ccdOutput(ichan);
        outputStruct(ichan).ccdRow    = [];
        outputStruct(ichan).ccdColumn = [];
        outputStruct(ichan).season    = season;
        outputStruct(ichan).mjd       = mjd;
        outputStruct(ichan).skyGroup  = skyGroup;
    end
return

function outputStruct = get_by_channels_and_season(rollTimeModel, channels, seasonNumber)
    mjd = season_to_mjd(rollTimeModel, seasonNumber);
    outputStruct = get_by_channels_and_mjd(rollTimeModel, channels, mjd);
return

function skyGroup = mod_out_season_to_sky_group(ccdModule, ccdOutput, observingSeason)
    import gov.nasa.kepler.hibernate.cm.KicCrud;
    kicCrud = KicCrud();
    skyGroup = kicCrud.retrieveSkyGroupId(ccdModule, ccdOutput, observingSeason);

    if (isempty(skyGroup))
        error('retrieve_sky_group: No sky group found for ccdModule=%d, ccdOutput=%d, season=%d', ...
            ccdModule, ccdOutput, observingSeason);
    end;
return

function outputStruct = make_output_struct_from_kepler_ids(raDec2PixObject, keplerIds, mjd, ra, dec, mods, outs, rows, cols)
    iseason = 1;
    season = mjd_to_season(get(raDec2PixObject, 'rollTimeModel'), mjd);
    
    for ikeplerid = 1:length(keplerIds)
        outputStruct(ikeplerid).ra  = ra(ikeplerid);
        outputStruct(ikeplerid).dec = dec(ikeplerid);

        outputStruct(ikeplerid).ccdModule(iseason) = mods(ikeplerid);
        outputStruct(ikeplerid).ccdOutput(iseason) = outs(ikeplerid);
        outputStruct(ikeplerid).ccdRow(   iseason) = rows(ikeplerid);
        outputStruct(ikeplerid).ccdColumn(iseason) = cols(ikeplerid);
        outputStruct(ikeplerid).season(   iseason) = season;
        outputStruct(ikeplerid).mjd(      iseason) = mjd;

        skyGroupStruct = retrieve_sky_group(keplerIds(ikeplerid), mjd);
        outputStruct(ikeplerid).skyGroup = skyGroupStruct.skyGroupId;
    end
return

function outputStruct = preallocate_output_struct(numEntries)
    outputStruct = repmat(struct( ...
        'skyGroup', [], ...
        'ra', [], ...
        'dec', [], ...
        'ccdModule', [], ...
        'ccdOutput', [], ...
        'ccdRow', [], ...
        'ccdColumn', [], ...
        'season', [], ...
        'mjd', []), 1, numEntries);
return
