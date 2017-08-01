function dynablackResultsStruct = B2a_main( dynablackObject, dynablackResultsStruct )
% function dynablackResultsStruct = B2a_main( dynablackObject, dynablackResultsStruct )
%
% This dynablack method sets flags for cadence and each ccd row indicating if Rolling Band Artifact (RBA) is present and
% at what severity level. If a row is scene dependent (bright star located near the trailing black region which affects
% the black measurement) it may be flagged as a rolling band row if it is adjacent to a non-scene dependent row with the
% rolling band flag set. If the scene dependent row is in the interior of a set of scene dependent rows the rba flag will
% not be set but the variability will still be estimated and indicated by the severity level bits.
%
% INPUTS:   dynablackObject         = dynablackClass object
%           dynablackResultsStruct  = dynablack results struct
% OUTPUTS:  dynablackResultsStruct  = dynablack results struct with B2a results field updated
% 
% The rolling band flags are returned in dynablackResultsStruct.B2a_results.flagsRollingBands as
% an nCadence x nRow array of uint8. Only the first 4 bits are used and are defined as follows:
%         bit 0: 1->scene dependent row
%         bit 1: 1->possible rolling band detected
%         bits 3-2: 0-0-> level at 1-2 * threshold for rolling bands (bits 1-0 ==  1-0 or 1-1)
%                   0-0-> level at 0-2 * threshold for scene dependent only (bits 1-0 == 0-1)
%                   0-1-> level at 2-3 * threshold
%                   1-0-> level at 3-4 * threshold
%                   1-1-> level at >4  * threshold
%         bits 3-2 are not set if not scene dependent and not rolling band (bits 1-0 = 0-0)
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

% initialize parameters
initInfo = B2a_parameter_init( dynablackObject, dynablackResultsStruct);

% extract parameters
constants               = initInfo.constants;
nRows                   = length(constants.rows);
nCadences               = constants.nCadences;
rows                    = constants.rows;
trCollatRowRange        = constants.trCollatRowRange;
trCollatIndices         = constants.trCollatIndices;
nTrCollatRows           = constants.nTrCollatRows;
spatialCoadds           = constants.spatialCoadds;
allArpRows              = constants.allArpRows;
allArpRowsIndices       = constants.allArpRowsIndices;
rowsRobust              = constants.rowsRobust;
allArpRowsRobust        = constants.allArpRowsRobust;
collaterRowRangeRobust  = constants.collaterRowRangeRobust;
allArpRowsIndicesRobust = constants.allArpRowsIndicesRobust;
                
% get fit residuals and robust weights from A1 fit
residual = [dynablackResultsStruct.A1_fit_residInfo.LC.full_xLC.regress_resid, dynablackResultsStruct.A1_fit_residInfo.LC.full_xLC.robust_resid]';
robustWt = dynablackResultsStruct.A1_fit_residInfo.LC.fitpix_xLC.robust_weights';

% extract test pulse durations
testPulseDurations = constants.testPulseDurations;
nDurations         = length(testPulseDurations);

% loop over test durations
for iDuration = 1:nDurations
    
    % repurpose testPulseDurations field in constants
    constants.testPulseDurations = testPulseDurations(iDuration);
    disp(['    Flagging RBA for test pulse duration ',num2str(constants.testPulseDurations),' long cadences.']);

    % scan rows for RBA going first forward (low row # to high row # - loop = 0) then in reverse (loop = 1)
    for loop = 0:1

        % initialize flags and info storage
        rbaFlagList = zeros(nTrCollatRows,nCadences,2);
        variationLevelList = zeros(nTrCollatRows,nCadences);
        inRollingBand = false(nCadences,1);

        % set up row sequence
        if loop == 0
            % forward
            rowList = 1:nTrCollatRows;
        else
            % reverse
            rowList = nTrCollatRows:-1:1;
        end

        % scan for rba row-by-row
        for rowIdx = rowList

            rowNum = trCollatRowRange(rowIdx);
            rowNotSceneDep = false;

            % get residual for this row
            if ismember( rowNum, rows( trCollatIndices) )
                % it's a trailing black data point --> a single value per row
                thisIdx = trCollatIndices( rows(trCollatIndices) == rowNum );
                thisResid = residual(thisIdx,:)';
                thisRobustResid = residual( thisIdx + nRows, :)';
                thisPixelsPerValue = spatialCoadds( thisIdx );
            else
                % possibly an arp target --> sum over all columns for this row
                idxIndicators = allArpRows == rowNum;                
                if any(idxIndicators) && all(allArpRowsIndices(idxIndicators,:) > 0)
                    thisResid = sum( residual(allArpRowsIndices(idxIndicators,:),:), 1)';
                    thisRobustResid = sum( residual(allArpRowsIndices(idxIndicators,:) + nRows, :), 1)';
                    thisPixelsPerValue = sum( spatialCoadds(allArpRowsIndices(idxIndicators,:)) );
                else
                    % this row doesn't have any data available - move on to the next for index
                    continue;
                end
            end

            % get the robust weights for this row if available from A1 fit
            if ismember(rowNum, rowsRobust)
                if ismember( rowNum, rowsRobust(collaterRowRangeRobust) )
                    % it's a trailing black data point w/robust weight --> single weight
                    thisIdx = collaterRowRangeRobust( rowsRobust(collaterRowRangeRobust) == rowNum );
                    thisRobustWt = robustWt(thisIdx,:)';
                else
                    % it's an arp target w/robust weights --> weight is mean over columns for this row
                    idxIndicators = allArpRowsRobust == rowNum;
                    thisRobustWt = mean( robustWt(allArpRowsIndicesRobust(idxIndicators,:),:), 1)';
                end
                % if it has a robust weight it must not be scene dependent (i.e. it *was* fit)
                rowNotSceneDep = true;
            else
                thisRobustWt = [];
            end

            % produce flags for this row
            [~, rbaFlags, inRollingBand, variationLevel] = ...
                flag_rba(thisResid, thisRobustResid, thisRobustWt, thisPixelsPerValue, inRollingBand, constants, rowNotSceneDep);

            % collect row results
            rbaFlagList(rowIdx,:,:) = rbaFlags; 
            variationLevelList(rowIdx,:) = variationLevel;
        end

        if loop == 0
            % save forward loop results
            flagsOutForward = squeeze(rbaFlagList(:,:,1)) + squeeze(rbaFlagList(:,:,2)) + 1;
            variationLevelForward = variationLevelList;
            sceneDepForward = squeeze(rbaFlagList(:,:,2));
        else
            % save reverse loop results
            flagsOutReverse = squeeze(rbaFlagList(:,:,1)) + squeeze(rbaFlagList(:,:,2)) + 1;
            variationLevelReverse = variationLevelList;
            sceneDepReverse = squeeze(rbaFlagList(:,:,2));
        end    
    end

    % set output flags to the maximum detected severity
    flagsOut = max( flagsOutForward, flagsOutReverse );
    variationLevel = max( variationLevelForward, variationLevelReverse );
    flagsSceneDep = max(sceneDepForward,sceneDepReverse);

    % parse results from flags
    isRBA                       = bitget(floor( flagsOut(:)./2), 1) > 0;
    numRBA                      = sum( isRBA );
    fractionRBA                 = numRBA/nCadences/nTrCollatRows;
    meanSeverityRBA             = sum( floor( flagsOut(:)/4) .* isRBA ) / max(1,numRBA);
    excludedRows                = constants.excludedRows;
    numSceneDepRows             = length(excludedRows);
    fclcIdx                     = initInfo.fclcIdx;

    fractionSceneDepRows        = numSceneDepRows/nTrCollatRows;    
    isSceneDepRBA               = bitget(floor(flagsSceneDep(:)/2), 1) > 0;
    numSceneDepRBA              = sum( isSceneDepRBA );
    fractionSceneDepRBA         = numSceneDepRBA/nCadences/max(1,numSceneDepRows);
    meanSeveritySceneDepRBA     = sum(floor(abs(flagsSceneDep(:))/4) .* isSceneDepRBA)/max(1,numSceneDepRBA);
    meanSeveritySceneDepNoRBA   = sum(floor(abs(flagsSceneDep(:))/4) .* (1 - isSceneDepRBA))/max(1,numSceneDepRows - numSceneDepRBA);

    % collect results
    rbaResults = struct('numFlags',         numRBA,...
                        'fractionFlags',    fractionRBA,...
                        'meanSeverity',     meanSeverityRBA,...
                        'rowList',          trCollatRowRange,...
                        'relCadenceList',   fclcIdx);

    sceneDepResults = struct('numRows',         numSceneDepRows,...
                             'fractionRows',    fractionSceneDepRows,...
                             'rowList',         excludedRows,...
                             'numRBAflags',     numSceneDepRBA,...
                             'fractionRBAFlags',fractionSceneDepRBA,...
                             'meanRBASeverity', meanSeveritySceneDepRBA,...
                             'meanNoRBASeverity', meanSeveritySceneDepNoRBA);

    results = struct('flagsRollingBands',   uint8(flagsOut),...
                     'variationLevel',      variationLevel,...
                     'RBA',                 rbaResults,...
                     'SceneDep',            sceneDepResults,...
                     'testPulseDurationLc', constants.testPulseDurations);
                 
    % attach results to dynablack results struct             
    dynablackResultsStruct.B2a_results(iDuration) = results;             
                 
end
                 