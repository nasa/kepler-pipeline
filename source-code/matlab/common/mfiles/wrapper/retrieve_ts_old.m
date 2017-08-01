function tsData = retrieve_ts(userFsIdPrefix, varargin)
%
% tsData = retrieve_ts(userFsIdPrefix, varargin)
%
% This script is a general purpose matlab-based retriever for time series in the filestore.
%
%
% INPUTS:
%       userFsIdPrefix -- A string describing the data to be extracted from
%                         the filestore.  Run "retrieve_ts()" (no
%                         arguments) to get the supported userFsIdPrefixes,
%                         or see below for examples.
%
%       varargin -- Different userFsIdPrefixes require different arguments.
%                   E.g., PrfCentroidRows requires a keplerIds vector and a
%                   start/stop cadence pair, but PaLcCosmicRayMeanEnergy
%                   takes a module/output pair and and start/stop cadence
%                   pair as arguments.  See the examples below for
%                   clarification.
%                   
%                   Arbitrary FS IDs of a single type (float time series, 
%                   int time series, or MJD time series), may be specified
%                   by the user if the userFsIdPrefix is:
%                   'user_specified_fs_ids'.  The inputs for this case (excluding userFsIdPrefix) are:
%
%                       fsIdStrings -- a cell array of FS ID strings.  All 
%                                      FS IDs must be of the same FS ID
%                                      type.
%                       fsIdType --    a string specifying the FS ID type.  
%                                      Must be 'ts' (float time series), 
%                                      'tsi' (int time series), 'mts' for 
%                                      MJD times series, or 'blob' for blob 
%                                      time series.
%                       startCadence 
%                       endCadence
%                   see examples below for a concrete example.
%    
%    
%
% OUTPUTS:
%
%       tsData -- A struct (or array of structs, if a multiple-element
%                 array of kepler IDs is given as an input) with the
%                 following fields:
% 
%           tseries:       A N-element vector of the time series data,
%                          where N is the number of requested cadences.
%
%           gapIndicators: A N-element vector of the time series data,
%                          where N is the number of requested cadences.
%
%           startCadence: The first cadence requested.
%
%           endCadence: The last cadence requested.
%
%           validCadences: The inclusive range of valid cadences.
%
%           mjds: A N-element vector of the MJD midpoints of the the
%                 cadences startCadence-endCadence.
%
%
%       If 'ls' was the userFsIdPrefix, tsData will contain a cell vector
%       of the FS IDs in the filestore that match that ls query.
%
%
% Short Cadence Note:
%   Short cadence data can be extracted; the userFsIdPrefix is very similar
%   to the corresponding long cadence case.  Please run this script with no
%   arguments to generate a listing of both long and short cadence use 
%   cases.
%
% Examples:
%
%   Extract the PA flux time series and uncertainties for three keplerIds
%   for the first of 501 cadences and plot the ungapped data points with
%   errorbars:
%
%         keplerIds = [8413815 8348641 8480304];
%         startCadence = 0;
%         endCadence = 500;
%         tsFlux              = retrieve_ts('SapRawFluxLong',       keplerIds, startCadence, endCadence);
%         tsFluxUncertainties = retrieve_ts('SapRawFluxLongUncert', keplerIds, startCadence, endCadence);
%         errorbar(find(~tsFlux(1).gapIndicators), tsFlux(1).tseries(~tsFlux(1).gapIndicators), tsFluxUncertainties(1).tseries(~tsFluxUncertainties(1).gapIndicators))
%
%
%
%   Get the PA PRF centroid row values/uncertainties for three keplerIds for the first
%   501 cadences and plot the ungapped data with errorbars:
%         keplerIds = [8738591 8480097 8415474];
%         tsPrfCentRow       = retrieve_ts('PrfCentroidRows',       keplerIds, startCadence, endCadence);
%         tsPrfCentRowUncert = retrieve_ts('PrfCentroidRowsUncert', keplerIds, startCadence, endCadence);
%         errorbar(find(~tsPrfCentRow(1).gapIndicators), tsPrfCentRow(1).tseries(~tsPrfCentRow(1).gapIndicators), tsPrfCentRowUncert(1).tseries(~tsPrfCentRowUncert(1).gapIndicators))
%
%         tsPrfCentCol       = retrieve_ts('PrfCentroidCols',       keplerIds, startCadence, endCadence);
%         tsPrfCentColUncert = retrieve_ts('PrfCentroidColsUncert', keplerIds, startCadence, endCadence);
%         errorbar(find(~tsPrfCentCol(1).gapIndicators), tsPrfCentCol(1).tseries(~tsPrfCentCol(1).gapIndicators), tsPrfCentColUncert(1).tseries(~tsPrfCentColUncert(1).gapIndicators))
%
%
%
%   Get raw centroid rows/columns:
%         cols = retrieve_ts('CentroidCols', keplerIds, startCadence, endCadence);
%         rows = retrieve_ts('CentroidRows', keplerIds, startCadence, endCadence);
%         plot(rows.tseries(~rows.gapIndicators), cols.tseries(~cols.gapIndicators),'x')
%
%
%
%   Get the flux-weighted centroids and plot them against cadence number 
%   with errorbars, and also on a row/column plot:
%         keplerIds = [8804455 8148841 8609873];
%         fwcRows       = retrieve_ts('FluxWeightedCentroidRows',       keplerIds, startCadence, endCadence);
%         fwcRowsUncert = retrieve_ts('FluxWeightedCentroidRowsUncert', keplerIds, startCadence, endCadence);
%         fwcCols       = retrieve_ts('FluxWeightedCentroidCols',       keplerIds, startCadence, endCadence);
%         fwcColsUncert = retrieve_ts('FluxWeightedCentroidColsUncert', keplerIds, startCadence, endCadence);
%         row = fwcRows(1).tseries(~fwcRows(1).gapIndicators);
%         col = fwcCols(1).tseries(~fwcRows(1).gapIndicators);
%         rowe = fwcRowsUncert(1).tseries(~fwcRowsUncert(1).gapIndicators);
%         cole = fwcColsUncert(1).tseries(~fwcRowsUncert(1).gapIndicators);
%         errorbar(find(~fwcRows(1).gapIndicators), row, rowe)
%         errorbar(find(~fwcCols(1).gapIndicators), col, cole)
%         plot(row,col,'x')
%
%
%
%   Get the SAP centroids and uncertainties for three Kepler IDS, plot them
%   individually with errorbars, and also display a row/column plot:
%         keplerIds = [7875476  8218649 8150327];
%         sapCols       = retrieve_ts('SapCentroidCols',       keplerIds, startCadence, endCadence);
%         sapColsUncert = retrieve_ts('SapCentroidColsUncert', keplerIds, startCadence, endCadence);
%         sapRows       = retrieve_ts('SapCentroidRows',       keplerIds, startCadence, endCadence);
%         sapRowsUncert = retrieve_ts('SapCentroidRowsUncert', keplerIds, startCadence, endCadence);
%         errorbar(find(~sapCols(1).gapIndicators), sapCols(1).tseries(~sapCols(1).gapIndicators), sapColsUncert(1).tseries(~sapCols(1).gapIndicators));
%         errorbar(find(~sapRows(1).gapIndicators), sapRows(1).tseries(~sapRows(1).gapIndicators), sapRowsUncert(1).tseries(~sapRows(1).gapIndicators));
%         plot(sapRows(1).tseries(~sapRows(1).gapIndicators), sapCols(1).tseries(~sapCols(1).gapIndicators),'x')
%
%
%
%   Get the CR mean energy for a mod/out and plot it:
%         startCadence = 0; endCadence = 355;
%         ccdMod = 7; ccdOut = 3;
%         cosmicRayMeanEnergy = retrieve_ts('PaLcCosmicRayMeanEnergy', ccdMod, ccdOut, startCadence, endCadence);
%         plot(cosmicRayMeanEnergy.tseries(~cosmicRayMeanEnergy.gapIndicators),'x-')
%
%
%
%   Get various CAL metrics time series and plot them for mod 7/out 3 for cadences 0-360: 
%         ts = retrieve_ts('CalAchievedCompEfficiency', 7, 3, 0, 360); plot(ts.tseries);
%         ts = retrieve_ts('CalAchievedCompEfficiencyCounts', 7, 3, 0, 360); plot(ts.tseries);
%         ts = retrieve_ts('CalBlackLevel', 7, 3, 0, 360); plot(ts.tseries);
%         ts = retrieve_ts('CalBlackLevelUncert', 7, 3, 0, 360); plot(ts.tseries);
%         ts = retrieve_ts('CalDarkCurrent', 7, 3, 0, 360); plot(ts.tseries);
%         ts = retrieve_ts('CalDarkCurrentUncert', 7, 3, 0, 360); plot(ts.tseries);
%         ts = retrieve_ts('CalSmearLevel', 7, 3, 0, 360); plot(ts.tseries);
%         ts = retrieve_ts('CalSmearLevelUncert', 7, 3, 0, 360); plot(ts.tseries);
%         ts = retrieve_ts('CalTheoreticalCompEff', 7, 3, 0, 360); plot(ts.tseries);
%         ts = retrieve_ts('CalTheoreticalCompEffCounts', 7, 3, 0, 360); plot(ts.tseries);
%
%
%
%   Get PA metrics time series and plot them for mod 7/out 3 and for cadences 0-360
%         ts = retrieve_ts('PaLcCosmicRayMeanEnergy', 7, 3, 0, 360); plot(ts.tseries(~ts.gapIndicators));
%         ts = retrieve_ts('PaBrightness', 7, 3, 0, 360); plot(ts.tseries(~ts.gapIndicators));
%         ts = retrieve_ts('PaBrightnessUncert', 7, 3, 0, 360); plot(ts.tseries(~ts.gapIndicators));
%         ts = retrieve_ts('PaBgCosmicRayEnergyKurtosis', 7, 3, 0, 360); plot(ts.tseries(~ts.gapIndicators));
%         ts = retrieve_ts('PaBgCosmicRayEnergySkewness', 7, 3, 0, 360); plot(ts.tseries(~ts.gapIndicators));
%         ts = retrieve_ts('PaBgEnergyVariance', 7, 3, 0, 360); plot(ts.tseries(~ts.gapIndicators));
%         ts = retrieve_ts('PaBgHitRate', 7, 3, 0, 360); plot(ts.tseries(~ts.gapIndicators));
%         ts = retrieve_ts('PaBgMeanEnergy', 7, 3, 0, 360); plot(ts.tseries(~ts.gapIndicators));
%         ts = retrieve_ts('PaLcEnergyKurtosis', 7, 3, 0, 360); plot(ts.tseries(~ts.gapIndicators));
%         ts = retrieve_ts('PaLcEnergySkewness', 7, 3, 0, 360); plot(ts.tseries(~ts.gapIndicators));
%         ts = retrieve_ts('PaLcEnergyVariance', 7, 3, 0, 360); plot(ts.tseries(~ts.gapIndicators));
%         ts = retrieve_ts('PaLcHitRate', 7, 3, 0, 360); plot(ts.tseries(~ts.gapIndicators));
%         ts = retrieve_ts('PaLcMeanEnergy', 7, 3, 0, 360); plot(ts.tseries(~ts.gapIndicators));
%         ts = retrieve_ts('PaEncircledEnergy', 7, 3, 0, 360); plot(ts.tseries(~ts.gapIndicators));
%         ts = retrieve_ts('PaEncircledEnergyUncert', 7, 3, 0, 360); plot(ts.tseries(~ts.gapIndicators));
%
%
%
%   Get the DR collateral data for mod 7/out 3, coordinate 37 for cadences 0-400:
%         ts = retrieve_ts('DrCollateralLongVirtualSmear', 7, 3, 37, 0, 400);
%         ts = retrieve_ts('DrCollateralLongMaskedSmear', 7, 3, 37, 0, 400)
%         ts = retrieve_ts('DrCollateralLongBlack', 7, 3, 37, 0, 400)
%
%
% 
%   List the available FS IDs for all of Cal:
%        fsids = retrieve_ts('ls', '/cal');
%
%   all of Cal's long cadence calibrated pixels values:
%        fsids = retrieve_ts('ls', '/cal/pixels/SocCal/lct');
%
%   Cal's long candence calibrated pixel uncertainties:
%        fsids = retrieve_ts('ls', '/cal/pixels/SocCalUncertainties/lct');
%
%
%
% Get PPA covariance matrices:
%        ts = retrieve_ts('PpaMaxAttitudeFocalPlaneResidual', 0, 400); plot([ts.mjds.mjdMidTime], ts.tseries(~ts.gapIndicators));
%        ts = retrieve_ts('PpaCovarianceMatrix11', 0, 400); plot([ts.mjds.mjdMidTime], ts.tseries(~ts.gapIndicators));
%        ts = retrieve_ts('PpaCovarianceMatrix12', 0, 400); plot([ts.mjds.mjdMidTime], ts.tseries(~ts.gapIndicators));
%        ts = retrieve_ts('PpaCovarianceMatrix13', 0, 400); plot([ts.mjds.mjdMidTime], ts.tseries(~ts.gapIndicators));
%        ts = retrieve_ts('PpaCovarianceMatrix22', 0, 400); plot([ts.mjds.mjdMidTime], ts.tseries(~ts.gapIndicators));
%        ts = retrieve_ts('PpaCovarianceMatrix23', 0, 400); plot([ts.mjds.mjdMidTime], ts.tseries(~ts.gapIndicators));
%        ts = retrieve_ts('PpaCovarianceMatrix33', 0, 400); plot([ts.mjds.mjdMidTime], ts.tseries(~ts.gapIndicators));
%
%
% Get various PDQ data:
%        startCadence = 0;
%        endCadence = 500;
%        ts = retrieve_ts('PdcSapCorrectedFlux',       9283708, startCadence, endCadence);
%        ts = retrieve_ts('PdcSapCorrectedFluxUncert', 9283708, startCadence, endCadence);
%        ts = retrieve_ts('PdcSapFilledIndices',       9283708, startCadence, endCadence);
%
% Extract arbitrary FS IDs of the same type in a given long cadence range:
%        startCadence = 0;
%        endCadence = 500;
%        fsIdStrings = {'/pa/targets/Sap/FluxWeighted/CentroidRows/long/8804455', '/pa/targets/Sap/FluxWeighted/CentroidRows/long/8148841'};
%        fsIdType = 'ts';
%        ts = retrieve_ts('user_specified_fs_ids', fsIdStrings, fsIdType, startCadence, endCadence)
%        
% Extract arbitrary FS IDs of the same type in a given SHORT cadence range:
%        startCadence = 0;
%        endCadence = 1500;
%        fsIdStrings = {'/pa/targets/Sap/FluxWeighted/CentroidRows/short/8804455', '/pa/targets/Sap/FluxWeighted/CentroidRows/short/8148841'};
%        fsIdType = 'ts';
%        ts = retrieve_ts('user_specified_fs_ids_short', fsIdStrings, fsIdType, startCadence, endCadence)
%
%
% Extract the barycentric time offset for long or short cadence for given Kepler IDs:
%        startCadence = 0;
%        endCadence = 1500;
%        barycentricTimeOffsetLong  = retrieve_ts('PaBarycentricTimeOffsetLong',  1723671, startCadence, endCadence);
%        barycentricTimeOffsetShort = retrieve_ts('PaBarycentricTimeOffsetShort', 3425564, startCadence, endCadence);
%
% Run the script with no args to get help on the contents of varargin.
%
%
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

    % If run without args, print the usage information and exit.
    %
    if nargin < 1
        print_usage();
        tsData = [];
        return
    end

    % Special setting for vararginEndIndex if the user is doing a 'ls' operation:
    %
    if strcmp(userFsIdPrefix, 'ls')
        vararginEndIndex = 1;
    end
    
    % If one of the pre-defined FS ID userFsIdPrefixes is being used, run 
    % convert_argument to get the actual FS IDs and the fsIdType that 
    % corresponds to those FS IDs. If the user is specifying FS IDs, read 
    % the FS IDs and the fsIdType out.
    %
    if strcmp(userFsIdPrefix, 'user_specified_fs_ids') || strcmp(userFsIdPrefix, 'user_specified_fs_ids_short')
        fsIds    = varargin{1};
        fsIdType = varargin{2};
    else
        if strcmp(userFsIdPrefix, 'ls')
            vararginEndIndex = length(varargin);
        else
            vararginEndIndex = length(varargin) - 2;
        end
        [fsIds fsIdType] = convert_argument(userFsIdPrefix, varargin{1:vararginEndIndex});
    end
            
    % Extract the data using get_'fsIdType':
    %
    switch fsIdType
        case 'mts'
            intervalStart = varargin{end-1};
            intervalEnd   = varargin{end};
            
            tsData = repmat(struct('mjds', []), 1, length(fsIds));
            for ifsid = 1:length(fsIds)
                fsId = fsIds{ifsid};
                tsData(ifsid) = get_mts(intervalStart, intervalEnd, fsId);
            end

            % Get MJDs for the given cadence interval:
            %
            mjds = get_mjds(userFsIdPrefix, intervalStart, intervalEnd);
            for ifsid = 1:length(fsIds)
                tsData(ifsid).mjds = mjds;
            end
        case {FLOAT_TIME_SERIES, INT_TIME_SERIES}
            intervalStart = varargin{end-1};
            intervalEnd   = varargin{end};

            tsData = repmat(struct('tseries', [], 'gapIndicators', [], 'startCadence', [], 'endCadence', [], 'validCadences', []), 1, length(fsIds));
            for ifsid = 1:length(fsIds)
                dataType = 'float';
                if strcmp(fsIdType, INT_TIME_SERIES)
                    dataType = 'int';
                end
                fsId = fsIds{ifsid};
                tsDatum = get_ts(intervalStart, intervalEnd, fsId, dataType);
                % Add a empty validCadences field for completely-gapped
                % results:
                %
                if ~isfield(tsDatum, 'validCadences')
                    tsDatum.validCadences = [];
                end
                tsData(ifsid) = tsDatum;
            end
            
            % Get MJDs for the given cadence interval:
            %
            mjds = get_mjds(userFsIdPrefix, intervalStart, intervalEnd);
            for ifsid = 1:length(fsIds)
                tsData(ifsid).mjds = mjds;
            end
        case 'blob'
            for ifsid = 1:length(fsIds)
                fsId = fsIds{ifsid};
                tsData(ifsid) = get_blob_ts(fsId);
            end
        case TIMESERIES_LISTING
            for ifsid = 1:length(fsIds)
                fsId = fsIds{ifsid};
                tsData{ifsid} = ls_ts(fsId);
            end
            for ifsid = 1:length(fsIds)
                printData = tsData{ifsid};
                for its = 1:length(printData)
                    msg = sprintf('%s', printData{its});
                    disp(msg);
                end
            end
        otherwise
            print_usage();
            error('MATLAB:SBT:wrapper:retrieve_ts', 'Type %s is not allowed', type);
    end

return

function mjds = get_mjds(userFsIdPrefix, intervalStart, intervalEnd)
    pixelLogObject = get_pixel_log_object(userFsIdPrefix, intervalStart, intervalEnd);
    mjds = convert_cadence_to_mjd(pixelLogObject, intervalStart:intervalEnd);
return 

function pixelLogObject = get_pixel_log_object(userFsIdPrefix, intervalStart, intervalEnd)
    if regexpi(userFsIdPrefix, 'Short')
        cadenceLogs = retrieve_cadence_logs(0);%, intervalStart, intervalEnd);%, 1);
    else
        cadenceLogs = retrieve_cadence_logs(1);%, intervalStart, intervalEnd);%, 1);
    end
    pixelLogObject = pixelLogClass(cadenceLogs);
return

function print_usage()
% Print the table of usage instructions to the screen
%
    lookupTable = get_fs_id_lookup_table();
    for irow = 1:size(lookupTable, 1)
        rowDescription = sprintf('\tUser arg: %-35s maps to %d args in FsId %-20s', lookupTable{irow, [1 3 2]});
        disp(rowDescription);
    end
    help retrieve_ts
return

function [fsIds fsType] = convert_argument(userSpecifiedArg, varargin)
% [fsIds fsType] = convert_argument(userSpecifiedArg, varargin)
%
% Get the fsId and fsType that corresponds to the userSpecifiedArg, as filled out by the
% varargin arguments.  If the userSpecifiedArg is not in the table given by
% get_fs_id_lookup_table, an error is thrown.
%

    fsIdSprintf = '';
    type = ''; %#ok<NASGU>
    
    lookupTable = get_fs_id_lookup_table();

    % Find the entry in the FSID lookup table that matches the
    % userSpecifiedArg, and generate a FsId Arg from it:
    %
    for ientry = 1:size(lookupTable, 1)
        inputArg   = lookupTable{ientry, 1};
        outputArg  = lookupTable{ientry, 2};
        numSprintf = lookupTable{ientry, 3};
        type       = lookupTable{ientry, 4};

        % If the inputs and number of varargin match, use this outputArg as the
        % fsIdSprintf
        %
        isInputMatch = strcmp(inputArg, userSpecifiedArg);
        isRightArgumentNumber = numSprintf == length(varargin);

        if isInputMatch && isRightArgumentNumber
            fsIdSprintf = outputArg;
            fsType = type;
        end
    end

    if strcmp(fsIdSprintf, '')
        print_usage();
        error('MATLAB:SBT:wrapper:retrieve_ts', ...
              'Argument %s is not found in allowed args with %d inputs. See the above usage message.', ...
              userSpecifiedArg, numSprintf);
    end

    if strcmp(userSpecifiedArg, 'ls')
        fsIds{1} = sprintf(fsIdSprintf, varargin{1});
    else
        if isempty(varargin)
            fsIds{1} = sprintf(fsIdSprintf);
        else
            kepids = varargin{1};
            for ikepid = 1:length(kepids)
                kepid = kepids(ikepid);

                if length(varargin) > 1
                    fsId = sprintf(fsIdSprintf, kepid, varargin{2:end});
                else
                    fsId = sprintf(fsIdSprintf, kepid);
                end
                fsIds{ikepid} = fsId;
            end
        end
    end
return

function lookupTable = get_fs_id_lookup_table()
    lookupTable = {
%         'test',                           '/perf/test-float/kester-test%d:%d',           2, FLOAT_TIME_SERIES,
%         'PRFs',                           '/fc/Prf/data:%d:%d:%d',                       3, FLOAT_TIME_SERIES, % historyId,       ccdModule , ccdOutput),
%         'SmallFlatFieldData',             '/fc/SmallFlatField/data:%d:%d:%d',            3, FLOAT_TIME_SERIES, % historyId,       ccdModule , ccdOutput),
%         'SmallFlatFieldUncertainty',      '/fc/SmallFlatField/uncertainty:%d:%d:%d',     3, FLOAT_TIME_SERIES, % historyId,       ccdModule , ccdOutput),
%         'TwoDBlackData',                  '/fc/TwoDBlack/data:%d:%d:%d',                 3, FLOAT_TIME_SERIES, % historyId,       ccdModule , ccdOutput),
%         'TwoDBlackUncertainty',           '/fc/TwoDBlack/uncertainty:%d:%d:%d',          3, FLOAT_TIME_SERIES, % historyId,       ccdModule , ccdOutput),
%         'TAD',                            '/tad/image:%d:%d:%d',                         3, FLOAT_TIME_SERIES, % targetListSet ,  ccdModule , ccdOutput)
%         'CalMetric',                      '/cal/metrics/%s:%s:%d:%d',                    4, FLOAT_TIME_SERIES,
%         'CalMetricPixel',                 '/cal/metrics/%s:%d:%d:%d',                    4, FLOAT_TIME_SERIES,
%         'CalCrs',                         '/cal/crs/%s:%s:%d:%d:%d',                     5, FLOAT_TIME_SERIES,
%         'CalUncertainty',                 '/cal/uncert/UncertaintyXform/%s:%d:%d:%d',    4, FLOAT_TIME_SERIES,
%         'PixelFitsFile',                  '/dr/pixel/fits/%s',                           1, FLOAT_TIME_SERIES, % fitsName
%         'Blob',                           '/dr/%s/%s',                                   2, 'blob',
%         'MatlabBlob',                     '%s/%s/%d:%d%s',                               5, 'blob', %blobType.pathBase'/' blobType.pathName '/' startCadence PrfFsIdFactory.PRF_SEP endCadencePrfFsIdFactory.PRF_SEP  pipelineTaskId
%         'PaFluxTarget',                   '/pa/targets/%s/%s/%s/%s',                     4, 'mts',
%         'PaTsTarget',                     '/pa/targets/%s/%s/%s',                        3, 'mts',%         PA_TARGETS_PATH timeSeriesType.getName '/' cadenceType.getName '/' keplerId
%         'PaCrTarget',                     '/pa/targets/%s/%d/%d',                        3, 'mts',%         PA_CR_METRICS_PATH ccdModule PixelFsIdFactory.SEP ccdOutput PixelFsIdFactory.SEP targetTableType.shortName PixelFsIdFactory.SEP metricType.getName
%         'PaMetric',                       '/pa/%s/%d/%d/%s',                             4, 'mts',%         PA_METRICS_PATH metricType.getName '/' ccdModule PixelFsIdFactory.SEP ccdOutput
%         'PdcData',                        '/pdc/%s%s/%s/%d',                             4, 'mts', % PDC_PATH fluxType.getName timeSeriesType.getName '/' cadenceType.getName '/' keplerId%         PDC_PATH fluxType.getName timeSeriesType.getName '/' cadenceType.getName '/' keplerId
%         'PdcFilledIndices',               '/pdc/%s/FilledIndices/%s/%d',                 3, 'mts', %PDC_PATH fluxType.getName "/FilledIndices/" cadenceType.getName '/' keplerId%         PDC_PATH fluxType.getName "/FilledIndices/" cadenceType.getName '/' keplerId
%         'PdcOutliers',                    '/pdc/%s/Outliers/%s/%d',                      3, 'mts', %PDC_PATH fluxType.getName "/Outliers/" cadenceType.getName '/' keplerId%         PDC_PATH fluxType.getName "/Outliers/" cadenceType.getName '/' keplerId
%         'PdqData',                        '/pdq/%d/%s',                                  2, 'mts', %         pathPrefix '/'  targetTableId'/'  timeSeriesName%         pathPrefix '/'  targetTableId'/'  timeSeriesName
%         'PdqUncertainties',               '/pdq/%d/%s/uncertainties',                    2, 'mts', %         pathPrefix '/'  targetTableId'/'  timeSeriesNamePDQ_SEP  UNCERTAINTIES%         pathPrefix '/'  targetTableId'/'  timeSeriesNamePDQ_SEP  UNCERTAINTIES
%         'PdqDataModOut',                  '/pdq/%d/%s/%d:%d',                            4, 'mts', %         pathPrefix '/'  targetTableId'/'  timeSeriesName'/'  ccdModulePDQ_SEP  ccdOutput%         pathPrefix '/'  targetTableId'/'  timeSeriesName'/'  ccdModulePDQ_SEP  ccdOutput
%         'PdqUncertaintiesModOut',         '/pdq/%d/%s/%d:%d:uncertainties',              4, 'mts', %         pathPrefix '/'  targetTableId'/'  timeSeriesName'/'  ccdModulePDQ_SEP  ccdOutputPDQ_SEP  UNCERTAINTIES%         pathPrefix '/'  targetTableId'/'  timeSeriesName'/'  ccdModulePDQ_SEP  ccdOutputPDQ_SEP  UNCERTAINTIES
%         'PpaData',                        '/ppa/%s',                                     1, 'mts', %         PPA_PATH_PREFIX '/' timeSeriesType.getName%         PPA_PATH_PREFIX '/' timeSeriesType.getName
% 
        
        'ls',                                   '%s',                                                              1, TIMESERIES_LISTING,
        
        'CalLongCadenceCosmicRayMetric',        '/cal/metrics/CosmicRayMetrics/long:%d:%d:%s:%s',                  4, FLOAT_TIME_SERIES, % mod:out:collateralType:CRMetricType
        'CalShortCadenceCosmicRayMetric',       '/cal/metrics/CosmicRayMetrics/short:%d:%d:%s:%s',                 4, FLOAT_TIME_SERIES, % mod:out:collateralType:CRMetricType
        
        'CalAchievedCompEfficiency',            '/cal/metrics/long:AchievedCompressionEfficiency:%d:%d',           2, FLOAT_TIME_SERIES, % mod:out
        'CalAchievedCompEfficiencyShort',       '/cal/metrics/short:AchievedCompressionEfficiency:%d:%d',          2, FLOAT_TIME_SERIES, % mod:out
        'CalAchievedCompEfficiencyCounts',      '/cal/metrics/long:AchievedCompressionEfficiencyCounts:%d:%d',     2, INT_TIME_SERIES, % mod:out
        'CalAchievedCompEfficiencyCountsShort', '/cal/metrics/short:AchievedCompressionEfficiencyCounts:%d:%d',    2, INT_TIME_SERIES, % mod:out
        'CalBlackLevel',                        '/cal/metrics/long:BlackLevel:%d:%d',                              2, FLOAT_TIME_SERIES, % mod:out
        'CalBlackLevelShort',                   '/cal/metrics/short:BlackLevel:%d:%d',                             2, FLOAT_TIME_SERIES, % mod:out
        'CalBlackLevelUncert',                  '/cal/metrics/long:BlackLevelUncertainties:%d:%d',                 2, FLOAT_TIME_SERIES, % mod:out
        'CalBlackLevelUncertShort',             '/cal/metrics/short:BlackLevelUncertainties:%d:%d',                2, FLOAT_TIME_SERIES, % mod:out
        'CalDarkCurrent',                       '/cal/metrics/long:DarkCurrent:%d:%d',                             2, FLOAT_TIME_SERIES, % mod:out
        'CalDarkCurrentShort',                  '/cal/metrics/short:DarkCurrent:%d:%d',                            2, FLOAT_TIME_SERIES, % mod:out
        'CalDarkCurrentUncert',                 '/cal/metrics/long:DarkCurrentUncertainties:%d:%d',                2, FLOAT_TIME_SERIES, % mod:out
        'CalDarkCurrentUncertShort',            '/cal/metrics/short:DarkCurrentUncertainties:%d:%d',               2, FLOAT_TIME_SERIES, % mod:out
        'CalSmearLevel',                        '/cal/metrics/long:SmearLevel:%d:%d',                              2, FLOAT_TIME_SERIES, % mod:out
        'CalSmearLevelShort',                   '/cal/metrics/short:SmearLevel:%d:%d',                             2, FLOAT_TIME_SERIES, % mod:out
        'CalSmearLevelUncert',                  '/cal/metrics/long:SmearLevelUncertainties:%d:%d',                 2, FLOAT_TIME_SERIES, % mod:out
        'CalSmearLevelUncertShort',             '/cal/metrics/short:SmearLevelUncertainties:%d:%d',                2, FLOAT_TIME_SERIES, % mod:out
        'CalTheoreticalCompEff',                '/cal/metrics/long:TheoreticalCompressionEfficiency:%d:%d',        2, FLOAT_TIME_SERIES, % mod:out
        'CalTheoreticalCompEffShort',           '/cal/metrics/short:TheoreticalCompressionEfficiency:%d:%d',       2, FLOAT_TIME_SERIES, % mod:out
        'CalTheoreticalCompEffCounts',          '/cal/metrics/long:TheoreticalCompressionEfficiencyCounts:%d:%d',  2, INT_TIME_SERIES, % mod:out
        'CalTheoreticalCompEffCountsShort',     '/cal/metrics/short:TheoreticalCompressionEfficiencyCounts:%d:%d', 2, INT_TIME_SERIES, % mod:out
         
        'CalLongCadence',                       '/cal/pixels/SocCal/lct/%d/%d/%d:%d',                              4, FLOAT_TIME_SERIES, % mod/out/row:column
        'CalLongCadenceCollateral',             '/cal/pixels/SocCal/collateral/long/%d/%d/%s:%d',                  4, FLOAT_TIME_SERIES, % mod/out/type:coordinate
        'CalLongCadenceCollateralShort',        '/cal/pixels/SocCal/collateral/short/%d/%d/%s:%d',                 4, FLOAT_TIME_SERIES, % mod/out/type:coordinate
        'CalBackgroundPixels',                  '/cal/pixels/SocCal/bgp/%d/%d/%d:%d',                              4, FLOAT_TIME_SERIES, % mod/out/row:column
        
        'DrCollateralLongBlack',                '/dr/pixel/col/Orig/long/BlackLevel:%d:%d:%d',                     3, INT_TIME_SERIES, %mod:out:coordinate
        'DrCollateralLongBlackShort',           '/dr/pixel/col/Orig/short/BlackLevel:%d:%d:%d',                    3, INT_TIME_SERIES, %mod:out:coordinate
        'DrCollateralLongMaskedSmear',          '/dr/pixel/col/Orig/long/MaskedSmear:%d:%d:%d',                    3, INT_TIME_SERIES, %mod:out:coordinate
        'DrCollateralLongMaskedSmearShort',     '/dr/pixel/col/Orig/short/MaskedSmear:%d:%d:%d',                   3, INT_TIME_SERIES, %mod:out:coordinate
        'DrCollateralLongVirtualSmear',         '/dr/pixel/col/Orig/long/MaskedSmear:%d:%d:%d',                    3, INT_TIME_SERIES, %mod:out:coordinate
        'DrCollateralLongVirtualSmearShort',    '/dr/pixel/col/Orig/short/MaskedSmear:%d:%d:%d',                   3, INT_TIME_SERIES, %mod:out:coordinate
        'DrLongCadencePixels',                  '/dr/pixel/sci/Orig/lct/%d/%d/%d:%d',                              4, INT_TIME_SERIES, %mod/out/row:column
        'DrLongCadencePixels',                  '/dr/pixel/sci/Orig/bgp/%d/%d/%d:%d',                              4, INT_TIME_SERIES, %mod/out/row:column
        'SapRawFluxLong',                       '/pa/targets/SapRawFlux/long/%d',                                  1, FLOAT_TIME_SERIES,
        'SapRawFluxShort',                      '/pa/targets/SapRawFlux/short/%d',                                 1, FLOAT_TIME_SERIES,
        'SapRawFluxLongUncert',                 '/pa/targets/SapRawFluxUncertainties/long/%d',                     1, FLOAT_TIME_SERIES,
        'SapRawFluxShortUncert',                '/pa/targets/SapRawFluxUncertainties/short/%d',                    1, FLOAT_TIME_SERIES,
        

        'PrfCentroidCols',                      '/pa/targets/Sap/Prf/CentroidCols/long/%d',                        1, FLOAT_TIME_SERIES,
        'PrfCentroidColsShort',                 '/pa/targets/Sap/Prf/CentroidCols/short/%d',                       1, FLOAT_TIME_SERIES,
        'PrfCentroidColsUncert',                '/pa/targets/Sap/Prf/CentroidColsUncertainties/long/%d',           1, FLOAT_TIME_SERIES,
        'PrfCentroidColsUncertShort',           '/pa/targets/Sap/Prf/CentroidColsUncertainties/short/%d',          1, FLOAT_TIME_SERIES,
        'PrfCentroidRows',                      '/pa/targets/Sap/Prf/CentroidRows/long/%d',                        1, FLOAT_TIME_SERIES,
        'PrfCentroidRowsShort',                 '/pa/targets/Sap/Prf/CentroidRows/short/%d',                       1, FLOAT_TIME_SERIES,
        'PrfCentroidRowsUncert',                '/pa/targets/Sap/Prf/CentroidRowsUncertainties/long/%d',           1, FLOAT_TIME_SERIES,
        'PrfCentroidRowsUncertShort',           '/pa/targets/Sap/Prf/CentroidRowsUncertainties/short/%d',          1, FLOAT_TIME_SERIES,
        'FluxWeightedCentroidRows',             '/pa/targets/Sap/FluxWeighted/CentroidRows/long/%d',               1, FLOAT_TIME_SERIES,
        'FluxWeightedCentroidRowsShort',        '/pa/targets/Sap/FluxWeighted/CentroidRows/short/%d',              1, FLOAT_TIME_SERIES,
        'FluxWeightedCentroidRowsUncert',       '/pa/targets/Sap/FluxWeighted/CentroidRowsUncertainties/long/%d',  1, FLOAT_TIME_SERIES,
        'FluxWeightedCentroidRowsUncertShort',  '/pa/targets/Sap/FluxWeighted/CentroidRowsUncertainties/short/%d', 1, FLOAT_TIME_SERIES,
        'FluxWeightedCentroidCols',             '/pa/targets/Sap/FluxWeighted/CentroidCols/long/%d',               1, FLOAT_TIME_SERIES,
        'FluxWeightedCentroidColsShort',        '/pa/targets/Sap/FluxWeighted/CentroidCols/short/%d',              1, FLOAT_TIME_SERIES,
        'FluxWeightedCentroidColsUncert',       '/pa/targets/Sap/FluxWeighted/CentroidColsUncertainties/long/%d',  1, FLOAT_TIME_SERIES,        
        'FluxWeightedCentroidColsUncertShort',  '/pa/targets/Sap/FluxWeighted/CentroidColsUncertainties/short/%d', 1, FLOAT_TIME_SERIES,        
        'SapCentroidCols',                      '/pa/targets/Sap/CentroidCols/long/%d',                            1, FLOAT_TIME_SERIES,
        'SapCentroidColsShort',                 '/pa/targets/Sap/CentroidCols/short/%d',                           1, FLOAT_TIME_SERIES,
        'SapCentroidColsUncert',                '/pa/targets/Sap/CentroidColsUncertainties/long/%d',               1, FLOAT_TIME_SERIES,
        'SapCentroidColsUncertShort',           '/pa/targets/Sap/CentroidColsUncertainties/short/%d',              1, FLOAT_TIME_SERIES,
        'SapCentroidRows',                      '/pa/targets/Sap/CentroidRows/long/%d',                            1, FLOAT_TIME_SERIES,
        'SapCentroidRowsShort',                 '/pa/targets/Sap/CentroidRows/short/%d',                           1, FLOAT_TIME_SERIES,
        'SapCentroidRowsUncert',                '/pa/targets/Sap/CentroidRowsUncertainties/long/%d',               1, FLOAT_TIME_SERIES,
        'SapCentroidRowsUncertShort',           '/pa/targets/Sap/CentroidRowsUncertainties/short/%d',              1, FLOAT_TIME_SERIES,
        'CentroidCols',                         '/pa/targets/CentroidCols/long/%d',                                1, FLOAT_TIME_SERIES,
        'CentroidColsShort',                    '/pa/targets/CentroidCols/short/%d',                               1, FLOAT_TIME_SERIES,
        'CentroidColsUncert',                   '/pa/targets/CentroidColsUncertainties/long/%d',                   1, FLOAT_TIME_SERIES,
        'CentroidColsUncertShort',              '/pa/targets/CentroidColsUncertainties/short/%d',                  1, FLOAT_TIME_SERIES,
        'CentroidRows',                         '/pa/targets/CentroidRows/long/%d',                                1, FLOAT_TIME_SERIES,
        'CentroidRowsShort',                    '/pa/targets/CentroidRows/short/%d',                               1, FLOAT_TIME_SERIES,
        'CentroidRowsUncert',                   '/pa/targets/CentroidRowsUncertainties/long/%d',                   1, FLOAT_TIME_SERIES,
        'CentroidRowsUncertShort',              '/pa/targets/CentroidRowsUncertainties/short/%d',                  1, FLOAT_TIME_SERIES,
        
        'PaLcCosmicRayMeanEnergy',              '/pa/metrics/CosmicRay/%d:%d:lct:MeanEnergy',                      2, FLOAT_TIME_SERIES,
        'PaBrightness',                         '/pa/metrics/Brightness/%d:%d',                                    2, FLOAT_TIME_SERIES, % mod:out
        'PaBrightnessUncert',                   '/pa/metrics/BrightnessUncertainties/%d:%d',                       2, FLOAT_TIME_SERIES, % mod:out
        'PaBgCosmicRayEnergyKurtosis',          '/pa/metrics/CosmicRay/%d:%d:bgp:EnergyKurtosis',                  2, FLOAT_TIME_SERIES, % mod:out
        'PaBgCosmicRayEnergySkewness',          '/pa/metrics/CosmicRay/%d:%d:bgp:EnergySkewness',                  2, FLOAT_TIME_SERIES, % mod:out
        'PaBgEnergyVariance'                    '/pa/metrics/CosmicRay/%d:%d:bgp:EnergyVariance',                  2, FLOAT_TIME_SERIES, % mod:out
        'PaBgHitRate',                          '/pa/metrics/CosmicRay/%d:%d:bgp:HitRate',                         2, FLOAT_TIME_SERIES, % mod:out
        'PaBgMeanEnergy',                       '/pa/metrics/CosmicRay/%d:%d:bgp:MeanEnergy',                      2, FLOAT_TIME_SERIES, % mod:out
        'PaLcEnergyKurtosis',                   '/pa/metrics/CosmicRay/%d:%d:lct:EnergyKurtosis',                  2, FLOAT_TIME_SERIES, % mod:out
        'PaLcEnergySkewness',                   '/pa/metrics/CosmicRay/%d:%d:lct:EnergySkewness',                  2, FLOAT_TIME_SERIES, % mod:out
        'PaLcEnergyVariance',                   '/pa/metrics/CosmicRay/%d:%d:lct:EnergyVariance',                  2, FLOAT_TIME_SERIES, % mod:out
        'PaLcHitRate',                          '/pa/metrics/CosmicRay/%d:%d:lct:HitRate',                         2, FLOAT_TIME_SERIES, % mod:out
        'PaLcMeanEnergy',                       '/pa/metrics/CosmicRay/%d:%d:lct:MeanEnergy',                      2, FLOAT_TIME_SERIES, % mod:out
        'PaEncircledEnergy',                    '/pa/metrics/EncircledEnergy/%d:%d',                               2, FLOAT_TIME_SERIES, % mod:out
        'PaEncircledEnergyUncert',              '/pa/metrics/EncircledEnergyUncertainties/%d:%d',                  2, FLOAT_TIME_SERIES, % mod:out

        'PaBarycentricTimeOffsetLong',          '/pa/targets/BarycentricTimeOffset/long/%d',                       1, FLOAT_TIME_SERIES, % keplerID
        'PaBarycentricTimeOffsetShort',         '/pa/targets/BarycentricTimeOffset/short/%d',                      1, FLOAT_TIME_SERIES, % keplerID

        'PpaMaxAttitudeFocalPlaneResidual',      '/ppa/MaxAttitudeFocalPlaneResidual',                             0, FLOAT_TIME_SERIES,
        'PpaCovarianceMatrix13',                 '/ppa/CovarianceMatrix13',                                        0, FLOAT_TIME_SERIES,
        'PpaCovarianceMatrix11',                 '/ppa/CovarianceMatrix11',                                        0, FLOAT_TIME_SERIES,
        'PpaCovarianceMatrix12',                 '/ppa/CovarianceMatrix12',                                        0, FLOAT_TIME_SERIES,
        'PpaCovarianceMatrix23',                 '/ppa/CovarianceMatrix23',                                        0, FLOAT_TIME_SERIES,
        'PpaCovarianceMatrix33',                 '/ppa/CovarianceMatrix33',                                        0, FLOAT_TIME_SERIES,
        'PpaCovarianceMatrix22',                 '/ppa/CovarianceMatrix22',                                        0, FLOAT_TIME_SERIES,
        
        'PdcSapCorrectedFlux',                   '/pdc/SapCorrectedFlux/long/%d',                                  1, FLOAT_TIME_SERIES,   % Kepler ID
        'PdcOapCorrectedFlux',                   '/pdc/OapCorrectedFlux/long/%d',                                  1, FLOAT_TIME_SERIES,   % Kepler ID
        'PdcDiaCorrectedFlux',                   '/pdc/DiaCorrectedFlux/long/%d',                                  1, FLOAT_TIME_SERIES,   % Kepler ID
        'PdcSapCorrectedFluxUncert',             '/pdc/SapCorrectedFluxUncertainties/long/%d',                     1, FLOAT_TIME_SERIES,   % Kepler ID
        'PdcOapCorrectedFluxUncert',             '/pdc/OapCorrectedFluxUncertainties/long/%d',                     1, FLOAT_TIME_SERIES,   % Kepler ID
        'PdcDiaCorrectedFluxUncert',             '/pdc/DiaCorrectedFluxUncertainties/long/%d',                     1, FLOAT_TIME_SERIES,   % Kepler ID
        'PdcSapCorrectedFluxShort',              '/pdc/SapCorrectedFlux/short/%d',                                 1, FLOAT_TIME_SERIES,   % Kepler ID
        'PdcOapCorrectedFluxShort',              '/pdc/OapCorrectedFlux/short/%d',                                 1, FLOAT_TIME_SERIES,   % Kepler ID
        'PdcDiaCorrectedFluxShort',              '/pdc/DiaCorrectedFlux/short/%d',                                 1, FLOAT_TIME_SERIES,   % Kepler ID
        'PdcSapCorrectedFluxUncertShort',        '/pdc/SapCorrectedFluxUncertainties/short/%d',                    1, FLOAT_TIME_SERIES,   % Kepler ID
        'PdcOapCorrectedFluxUncertShort',        '/pdc/OapCorrectedFluxUncertainties/short/%d',                    1, FLOAT_TIME_SERIES,   % Kepler ID
        'PdcDiaCorrectedFluxUncertShort',        '/pdc/DiaCorrectedFluxUncertainties/short/%d',                    1, FLOAT_TIME_SERIES,   % Kepler ID

        'PdcSapFilledIndices',                   '/pdc/sap/FilledIndices/long/%d',                                 1, FLOAT_TIME_SERIES,   % Kepler ID
        'PdcOapFilledIndices',                   '/pdc/oap/FilledIndices/long/%d',                                 1, FLOAT_TIME_SERIES,   % Kepler ID
        'PdcDiaFilledIndices',                   '/pdc/dia/FilledIndices/long/%d',                                 1, FLOAT_TIME_SERIES,   % Kepler ID
        'PdcSapFilledIndicesShort',              '/pdc/sap/FilledIndices/short/%d',                                1, FLOAT_TIME_SERIES,   % Kepler ID
        'PdcOapFilledIndicesShort',              '/pdc/oap/FilledIndices/short/%d',                                1, FLOAT_TIME_SERIES,   % Kepler ID
        'PdcDiaFilledIndicesShort',              '/pdc/dia/FilledIndices/short/%d',                                1, FLOAT_TIME_SERIES,   % Kepler ID

        'PdcSapOutliers',                        '/pdc/sap/Outliers/long/%d',                                      1, FLOAT_TIME_SERIES,   % Kepler ID
        'PdcOapOutliers',                        '/pdc/oap/Outliers/long/%d',                                      1, FLOAT_TIME_SERIES,   % Kepler ID
        'PdcDiaOutliers',                        '/pdc/dia/Outliers/long/%d',                                      1, FLOAT_TIME_SERIES,   % Kepler ID
        'PdcSapOutliersShort',                   '/pdc/sap/Outliers/short/%d',                                     1, FLOAT_TIME_SERIES,   % Kepler ID
        'PdcOapOutliersShort',                   '/pdc/oap/Outliers/short/%d',                                     1, FLOAT_TIME_SERIES,   % Kepler ID
        'PdcDiaOutliersShort',                   '/pdc/dia/Outliers/short/%d',                                     1, FLOAT_TIME_SERIES,   % Kepler ID

        'PdcSapOutliersUncert',                  '/pdc/sap/OutliersUncertainies/long/%d',                          1, FLOAT_TIME_SERIES,   % Kepler ID
        'PdcOapOutliersUncert',                  '/pdc/oap/OutliersUncertainies/long/%d',                          1, FLOAT_TIME_SERIES,   % Kepler ID
        'PdcDiaOutliersUncert',                  '/pdc/dia/OutliersUncertainies/long/%d',                          1, FLOAT_TIME_SERIES,   % Kepler ID
        'PdcSapOutliersUncertShort',             '/pdc/sap/OutliersUncertainies/short/%d',                         1, FLOAT_TIME_SERIES,   % Kepler ID
        'PdcOapOutliersUncertShort',             '/pdc/oap/OutliersUncertainies/short/%d',                         1, FLOAT_TIME_SERIES,   % Kepler ID
        'PdcDiaOutliersUncertShort',             '/pdc/dia/OutliersUncertainies/short/%d',                         1, FLOAT_TIME_SERIES,   % Kepler ID
    };

    for irow = 1:size(lookupTable, 1)
        numPercents = length(regexp(lookupTable{irow, 2}, '%'));
        if numPercents ~= lookupTable{irow, 3}
            error('MATLAB:SBT:wrapper:retrieve_ts', ...
                'Internal error: outputs are not self-consistent in outputs(%d, irow,:) in get_fs_id_lookup_table.  Expected %d, got %d.', ...
                irow, lookupTable{irow, 3}, numPercents);
        end
    end
return

function data = get_ts(intervalStart, intervalEnd, id, dataType)
    import gov.nasa.kepler.hibernate.dbservice.ConfigurationServiceFactory;
    import gov.nasa.kepler.fs.client.FileStoreClientFactory;
    import gov.nasa.kepler.fs.api.FsId;
    
    store = FileStoreClientFactory.getInstance(ConfigurationServiceFactory.getInstance());
    
    idArray = javaArray('gov.nasa.kepler.fs.api.FsId', 1);
    idArray(1) = FsId(id);

    data = [];

    if strcmp(dataType, 'float')
        tsJava = store.readTimeSeriesAsFloat(idArray, intervalStart, intervalEnd, false);
        data = reshape_ts_data(tsJava, dataType);
    elseif strcmp(dataType, 'int')
        tsJava = store.readTimeSeriesAsInt(idArray, intervalStart, intervalEnd, false);
        data = reshape_ts_data(tsJava, dataType);
    else
        error('MATLAB:SBT:wrapper:retrieve_ts', 'Illegal dataType string "%s" is not allowed: must be "int" or "float"', dataType);
    end
return

function data = get_mts(intervalStart, intervalEnd, id)
    import gov.nasa.kepler.hibernate.dbservice.ConfigurationServiceFactory;
    import gov.nasa.kepler.fs.client.FileStoreClientFactory;
    import gov.nasa.kepler.fs.api.FsId;
    
    store = FileStoreClientFactory.getInstance(ConfigurationServiceFactory.getInstance());
    
    idArray = javaArray('gov.nasa.kepler.fs.api.FsId', 1);%length(id));
    idArray(1) = FsId(id);

    tsJava = store.readMjdTimeSeries(idArray, intervalStart, intervalEnd);
    data = reshape_mts_data(tsJava);
return


function dataFileName = get_blob_ts(id)
    import gov.nasa.kepler.hibernate.dbservice.ConfigurationServiceFactory;
    import gov.nasa.kepler.fs.client.FileStoreClientFactory;
    import gov.nasa.kepler.fs.api.FsId;
    import java.io.File;
    
    store = FileStoreClientFactory.getInstance(ConfigurationServiceFactory.getInstance());
    dataFileName = sprintf('%s%s%sblobfile_%s.dat', pwd, filesep, id);
    dataFile = java.io.File(dataFileName);
    
    fsId = FsId(id);
    originator = store.readBlob(fsId, dataFile);
    disp(sprintf('Blob "%s" is from %d, saved to %s', fsId, originator, dataFile));
return


function data = reshape_ts_data(tsJava, dataType)
    if ~strcmp(dataType, 'int') && ~strcmp(dataType, 'float')
        error('MATLAB:SBT:wrapper:retrieve_ts', 'Illegal dataType string "%s" is not allowed: must be "int" or "float"', dataType);
    end
    
%     data = repmat(struct('tseries', [], 'gapIndicators', [], 'startCadence', [], 'endCadence', [], 'validCadences', []), 1, tsJava.length());

    for ii = 1:tsJava.length()        
        if strcmp(dataType, 'float')
            data(ii).tseries = tsJava(ii).fseries;
        elseif strcmp(dataType, 'int')
            data(ii).tseries = tsJava(ii).iseries;
        end
        data(ii).gapIndicators = tsJava(ii).getGapIndicators;
        data(ii).startCadence = tsJava(ii).startCadence;
        data(ii).endCadence = tsJava(ii).endCadence;
        
        for ic = 0:tsJava(ii).validCadences.size()-1 % Java indexing
            startCadence = tsJava(ii).validCadences.get(ic).start;
            endCadence = tsJava(ii).validCadences.get(ic).end;
            data(ii).validCadences(ic+1, :) = [startCadence endCadence];
        end
    end
return

function data = reshape_mts_data(tsJava)
    for ii = 1:tsJava.length()        
        data(ii).mjd = tsJava(ii).mjd;
        data(ii).values = tsJava(ii).values;
        data(ii).startMjd = tsJava(ii).startMjd;
        data(ii).endMjd = tsJava(ii).endMjd;
    end
return

function outputIds = ls_ts(pathPart)
    import gov.nasa.kepler.hibernate.dbservice.ConfigurationServiceFactory;
    import gov.nasa.kepler.fs.client.FileStoreClientFactory;
    import gov.nasa.kepler.fs.api.FsId;

    store = FileStoreClientFactory.getInstance(ConfigurationServiceFactory.getInstance());
    queryString = ['TimeSeries@' pathPart '/*' ];
    ids = store.queryIds(queryString).toArray();
    outputIds = {};
    for iid = 1:ids.length()
        outputIds{iid} = char(ids(iid).toString());
    end
return


function intervals = ls_ts_intervals(fullParts)
    import gov.nasa.kepler.hibernate.dbservice.ConfigurationServiceFactory;
    import gov.nasa.kepler.fs.client.FileStoreClientFactory;
    import gov.nasa.kepler.fs.api.FsId;
    
    store = FileStoreClientFactory.getInstance(ConfigurationServiceFactory.getInstance());

    ids = javaArray('gov.nasa.kepler.fs.api.FsId', length(fullParts));
    for iarg = 1:length(fullParts)
        ids(iarg) = FsId(fullParts{iarg});
    end

    intervalsForIds = store.getCadenceIntervalsForId(ids);
    intervals = [];
    for iinterval = 1:intervalsForIds.length
        interval = intervalsForIds(iinterval);
        for ientry = 1:interval.size()
            intervals(end+1,:) = [interval.get(ientry-1).start interval.get(ientry-1).end];
        end
    end
return

function tsTypeName = FLOAT_TIME_SERIES()
    tsTypeName = 'ts';
return

function tsTypeName = INT_TIME_SERIES()
    tsTypeName = 'tsi';
return

function tsTypeName = TIMESERIES_LISTING()
    tsTypeName = 'ls_ts';
return
