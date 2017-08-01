function [tipData, dvData] = compare_tip_and_dv_output( inputStruct )
%
% function [tipData, dvData] = compare_tip_and_dv_output( inputStruct )
% 
% This function can operate on a single skygroup or on an aggregated set of skygroups. It will produce two data structures, one for the TIP
% "ground truth" data and one for the DV fitted results. If tipPathName is the path to a directory containing TIP .txt files those will be
% loaded and aggregated producing tipData. If tipPathName is the full path to a TIP parameters file then that file will be loaded to produce
% tipData. This may be the file for a few targets, a single skygroup or even the aggregated file for all skygroups. This is the tipData that
% will be operated on. The input argument dvPathName points to the directory the dvOutputMatrix will be read from. If this directory
% contains the dvOutputMatrix referring to a single skygroup then that file is read in the skygroup format. Otherwise, if it contains the
% dvOutputMatrix referring to aggregated results from several skygroups, that file is read in the aggregated skygroup format. The input
% argument expectedMesPathName points to a directory containing the expected-mes files for this data set which are produced by
% produce_expected_mes_of_injected_lightcurves or is the full pathname to a single expected-mes file or is empty. If it is not empty, new
% matched data fileds will be added to the tipData structure and populated with the matching data and returned with the output. 
%
% INPUT:
%       inputStruct             == structure with the following fields:
%           tipPathName                 == [char]; path to directory containing TIP parameters files (*.txt) or the full path to a specific TIP file
%           dvPathName                  == [char]; path to directory containing DV output matrix either single skygroup or aggregate
%           expectedMesPathName         == [char]; path to directory containing 'expected-mes-for-skygroup-#.mat' files or path to a
%                                          specific file. May be empty.
%           expectedMesRootName         == [char]; root filename for expected-mes files. e.g. 'expected-mes-for-skygroup-'. Only needs to be
%                                          non-empty if expectedMesPathName specifies a directory.
%           periodFractionalTolerance   == [double]; fractional period tolerance for matching
%           periodMultiplier            == [double]; multiply TIP period by this factor when searching DV results for matches
%           epochFractionalTolerance    == [double]; epoch tolerance in fraction of period for matching (abs epoch diff mod period / period)
%           epochToleranceDays          == [double]; epoch tolerance in days. This tolerance is applied to epoch matching if it is non-zero.
%                                          Otherwise epochFractionalTolerance is applied to epoch matching.
%           displayHistograms           == [logical]; true == display some distributions of agreement between DV results and TIP ground
%                                          truth
% OUTPUT:   tipData                     == [struct]; data structure containing TIP transit model parmaters, matching indices into tipData and
%                                          matching expected-mes data if requested in inputs (non-empty expectedMesPathName)
%           dvData                      == [struct]; data structure containing DV results and matching indices into dvData
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


% unpack inputs
tipPathName                 = inputStruct.tipPathName;
dvPathName                  = inputStruct.dvPathName;
expectedMesPathName         = inputStruct.expectedMesPathName;
expectedMesRootName         = inputStruct.expectedMesRootName;
displayHistograms           = inputStruct.displayHistograms;
saveFiguresAsJpegs          = inputStruct.saveFiguresAsJpegs;
matchingFractionalTol       = inputStruct.tipModelParamFractionalTolerance;

% check optional inputs and set if missing
if ~isfield(inputStruct,'periodMultiplier')
    inputStruct.periodMultiplier = 1;
end


% load the TIP simulated transit parameters
if isdir(tipPathName)
    % if tipPathName points to a directory attempt to load all *.txt files in that directory as TIP parameters files, aggregate and load as TIP data    
    D = dir([tipPathName,'*.txt']);
    tipFileList = cell(length(D),1);
    for i=1:length(D)
        tipFileList{i} = [tipPathName,D(i).name];
    end
    tipData = aggregate_tip_files( tipFileList );
else
    % otherwise assume tipPathName is the full path to a TIP parameters file and load it as TIP data
    tipData = read_simulated_transit_parameters(tipPathName);
end

% load the DV data
temp = [];
% loop over directories for skygroup
for i = 1:length(inputStruct.dvPathName)    
    if isdir(dvPathName{i})
        % if dvPathName points to a taskfile directory load the output matrix for this skygroup
        % otherwise check for the aggregated dvOutputMatrix assuming dvPathName points at the task files root level
        if exist([dvPathName{i},'dvOutputMatrixSkygroup.mat'],'file')
            disp(['Loading ',dvPathName{i},'dvOutputMatrixSkygroup.mat ...']);
            load([dvPathName{i},'dvOutputMatrixSkygroup.mat']);
            tempMatrix = dvOutputMatrixSkygroup;
        elseif exist([dvPathName{i},'dvOutputMatrix.mat'],'file')
            disp(['Loading ',dvPathName{i},'dvOutputMatrix.mat ...']);
            load([dvPathName{i},'dvOutputMatrix.mat']);
            tempMatrix = dvOutputMatrix;
        end
    else
        % assume dvPathName is the full path to the dvOutputMatrixSkygroup file
        load(dvPathName{i});
        disp(['Loading ',dvPathName{i},' ...']);
        tempMatrix = dvOutputMatrixSkygroup;
    end    
    temp = [temp; tempMatrix]; %#ok<AGROW>
end
% create dv data structure    
dvData = dv_output_matrix2struct( temp, dvOutputMatrixColumns );    

% load the expected-mes-*.mat filenames
if ~isempty(expectedMesPathName) 
    if isdir(expectedMesPathName) && ~isempty(expectedMesRootName)
        D = dir([expectedMesPathName,expectedMesRootName,'*.mat']);
        mesFileList = cell(length(D),1);
        for i=1:length(D)
            mesFileList{i} = [expectedMesPathName,D(i).name];
        end        
    else
        mesFileList = {expectedMesPathName};
    end
else
    mesFileList = {};
end


% find matches between TIP and DV keplerIds, period and epoch
disp('Performing period/epoch matching ...');
tipIdx = match_dv_period_epoch_to_tip(tipData, dvData, inputStruct);
dvLogical = ~isnan(tipIdx);

% set matched indices lists
tipIdx = tipIdx(dvLogical);
dvIdx = find(dvLogical);

% save matched indices lists
tipData.tipMatchIdx = tipIdx;
dvData.dvMatchIdx = dvIdx;

% generate boolean dvMatch in tipData
tipData.dvMatch = false(size(tipData.keplerId));
tipData.dvMatch(tipIdx) = true;

% add fields from expected-mes files to matching tipData keplerIds
if ~isempty(mesFileList)
    
    disp('Adding data from expected-mes files ...');
    
    % initialize fields with nans
    x = nan(size(tipData.keplerId));
    tipData.paMedianInjectedTransitDepth = x;
    tipData.paMeanMedianInjectedTransitDepth = x;    
    tipData.pdcMedianInjectedTransitDepth = x;
    tipData.pdcMeanMedianInjectedTransitDepth = x;
    tipData.pdcMedianInjectedTransitDepthTps = x;
    tipData.pdcMeanMedianInjectedTransitDepthTps = x;    
    tipData.universeMes = x;
    tipData.universeMesMean = x;
    tipData.apertureMes = x;
    tipData.apertureMesMean = x;
    tipData.windowedMes = x;
    tipData.windowedMesMean = x;
    tipData.tpsEpochMjd = x;
    tipData.tpsPeriodDays = x;
    tipData.skyGroupId = x;
    
    tipData.nTransitsInt = x;
    tipData.nTransitsFrac = x;
    tipData.nTransitsFracTps = x;
    tipData.isPlanetCandidateTps = x;
    
    tipData.fitSinglePulseTip = x;
    tipData.fitSinglePulseTps = x;
    tipData.fitSinglePulse9p2 = x;
    
    tipData.tipFilename = cell(length(mesFileList),1);
    tipData.tpsTaskFilesRoot = cell(length(mesFileList),1);
    tipData.tipFileSkygroupId = nan(length(mesFileList),1);
    
    % scan the expected-mes files
    for i = 1:length(mesFileList)

        % load the expected-mes file
        disp(['Loading ',mesFileList{i},' ...']);
        s = load(mesFileList{i});

        % find matching indices in tipData
        idxIntoTip = match_expected_mes_data_to_tip_data(s,tipData,matchingFractionalTol);
        mesLogical = ~isnan(idxIntoTip);
        idxIntoTip = idxIntoTip(mesLogical);
        idxIntoMes = find(mesLogical);
        
        % capture tps root path
        tipData.tpsTaskFilesRoot{i} = s.data.tpsRootPathForSkygroup;
        
        % capture tip *.txt full file path for each mes file
        tipData.tipFilename{i} = s.data.tipFilename;
        
        % capture skygroupId corresponding to tip file
        tipData.tipFileSkygroupId(i) = s.data.skyGroupId;

        % capture skyGroupId for each target
        tipData.skyGroupId(idxIntoTip) = s.data.skyGroupId .* ones(size(idxIntoTip));
        
        % copy other fields to tipData
        tipData.injectedPlanetModelStruct(idxIntoTip) = s.data.transitModelStructArray(idxIntoMes);
        tipData.paMedianInjectedTransitDepth(idxIntoTip) = nanmedian(s.data.paTransitDepthPpm(:,idxIntoMes),1);
        tipData.paMeanMedianInjectedTransitDepth(idxIntoTip) = nanmedian(s.data.paMeanTransitDepthPpm(:,idxIntoMes),1);        
        tipData.pdcMedianInjectedTransitDepth(idxIntoTip) = nanmedian(s.data.pdcTransitDepthPpm(:,idxIntoMes),1);
        tipData.pdcMeanMedianInjectedTransitDepth(idxIntoTip) = nanmedian(s.data.pdcMeanTransitDepthPpm(:,idxIntoMes),1);
        tipData.pdcMedianInjectedTransitDepthTps(idxIntoTip) = nanmedian(s.data.pdcTransitDepthPpmTps(:,idxIntoMes),1);
        tipData.pdcMeanMedianInjectedTransitDepthTps(idxIntoTip) = nanmedian(s.data.pdcMeanTransitDepthPpmTps(:,idxIntoMes),1);
        
        tipData.universeMes(idxIntoTip)     = s.data.universeMes(idxIntoMes);
        tipData.universeMesMean(idxIntoTip) = s.data.universeMesMean(idxIntoMes);
        tipData.apertureMes(idxIntoTip)     = s.data.apertureMes(idxIntoMes);
        tipData.apertureMesMean(idxIntoTip) = s.data.apertureMesMean(idxIntoMes);
        tipData.windowedMes(idxIntoTip)     = s.data.windowedMes(idxIntoMes);
        tipData.windowedMesMean(idxIntoTip) = s.data.windowedMesMean(idxIntoMes);
        tipData.tpsEpochMjd(idxIntoTip)     = s.data.tpsEpochMjd(idxIntoMes);
        tipData.tpsPeriodDays(idxIntoTip)   = s.data.tpsPeriodDays(idxIntoMes);
        
        tipData.nTransitsInt(idxIntoTip)    = s.data.nTransitsInt(idxIntoMes);
        tipData.nTransitsFrac(idxIntoTip)   = s.data.nTransitsFrac(idxIntoMes);
        tipData.nTransitsFracTps(idxIntoTip)= s.data.nTransitsFracTps(idxIntoMes);
        
        tipData.fitSinglePulseTip(idxIntoTip) = s.data.fitSinglePulseTip(idxIntoMes);
        tipData.fitSinglePulseTps(idxIntoTip) = s.data.fitSinglePulseTps(idxIntoMes);
        tipData.fitSinglePulse9p2(idxIntoTip) = s.data.fitSinglePulse9p2(idxIntoMes);
        
        tipData.transitModelDepthPpm(idxIntoTip) = s.data.transitModelDepthPpm(idxIntoMes);
        tipData.transitModelDurationHours(idxIntoTip) = s.data.transitModelDurationHours(idxIntoMes);
        tipData.isPlanetCandidateTps(idxIntoTip) = s.data.isPlanetCandidateTps(idxIntoMes);

        clear s;
    end    
end


% make some distribution plots if so inclined
if displayHistograms
   display_histograms(tipData, dvData, ~isempty(mesFileList), saveFiguresAsJpegs);
end
