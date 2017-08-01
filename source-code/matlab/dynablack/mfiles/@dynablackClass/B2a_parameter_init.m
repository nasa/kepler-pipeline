function initInfo = B2a_parameter_init( dynablackObject, dynablackResultsStruct )
%
% function initInfo = B2a_parameter_init( dynablackObject )
%
% Initialization routine for RBA flagger. Called by B2a_main.
% 
% INPUTS:           dynablackObject = data object in dynblackClass
%            dynablackResultsStruct = results from dynablack fits A1, A2, B1a and B1b
% OUTPUTS:                 initInfo = structure containing the following fields;
%                                       .channel            channel number [1-84]
%                                       .fclcIdx            relative long cadence index list
%                                       .Constants          structure containing the following fields:
%                                           .rowsRobust                     rows associated with robust weights; used in B2a_main
%                                           .rows                           rows associated with residuals weights; used in B2a_main
%                                           .spatialCoadds                  number of pixels for each value; used in B2a_main
%                                           .nFlagVariables                 number of flag variables in suspect data flag; used in B2a_main
%                                           .meanThreshold                  used in flag_RBA, flag_RBA_in_scene_dep_region, RBA_severity
%                                           .meanSigmaThreshold             used in flag_RBA, flag_RBA_in_scene_dep_region
%                                           .varianceThreshold              used in flag_RBA, flag_RBA_in_scene_dep_region, RBA_severity
%                                           .transitDepthThreshold          used in flag_RBA, flag_RBA_in_scene_dep_region, RBA_severity
%                                           .transitDepthErrorThreshold     used in flag_RBA, flag_RBA_in_scene_dep_region, RBA_severity
%                                           .transitDepthSigmaThreshold     used in flag_RBA, flag_RBA_in_scene_dep_region, RBA_severity
%                                           .robustWeightLoThresh           used in flag_RBA, RBA_severity
%                                           .robustWeightHiThresh           used in flag_RBA, RBA_severity
%                                           .testPulseDurations             transit duration for square wave transit model; used in flag_RBA, flag_RBA_in_scene_dep_region, RBAflag_postprocess
%                                           .cleaningScale                  used for filtering spurious flags; used in RBAflag_postprocess
%                                           .allArpRows                     rows containing all ARP pixels; used in B2a_main
%                                           .allArpRowsIndices              index for rows containing all ARP pixels; used in B2a_main
%                                           .trCollatRowRange               range of collateral rows included ; used in B2a_main, RBA_severity RBAflag_postprocess
%                                           .nRows                          number of rows; used in B2a_main, RBAflag_postprocess
%                                           .trCollatIndices                collateral range in full residuals; used in B2a_main
%                                           .allArpRowsRobust               rows containing all ARP pixels in robust weight data; used in B2a_main
%                                           .allArpRowsIndicesRobust        index for rows containing all ARP pixels in robust weight data; used in B2a_main
%                                           .collaterRowRangeRobust         range of collateral rows included in rob. wt. data; used in B2a_main
%                                           .nCcdColumns                    total columns in FFI; used in RBAflag_postprocess
%                                           .nCcdRows                       total rows in FFI;; used in B2a_main
%                                           .severityQuantiles              quantiles to report in severity parameters; used in RBA_severity
%                                           .nCadences                      number of LCs ; used in B2a_main, RBAflag_postprocess
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


% unpack rba flagging configuration parameters
rbaFlagConfigurationStruct      = dynablackObject.rbaFlagConfigurationStruct;
pixelNoiseThresholdAduPerRead   = rbaFlagConfigurationStruct.pixelNoiseThresholdAduPerRead;
pixelBiasThresholdAduPerRead    = rbaFlagConfigurationStruct.pixelBiasThresholdAduPerRead;
cleaningScale                   = rbaFlagConfigurationStruct.cleaningScale;
testPulseDurations              = rbaFlagConfigurationStruct.testPulseDurations;
durationEarthOnSunLC            = rbaFlagConfigurationStruct.durationEarthOnSunLC;
nFlagVariables                  = rbaFlagConfigurationStruct.numberOfFlagVariables;
severityQuantiles               = rbaFlagConfigurationStruct.severityQuantiles;
meanSigmaThreshold              = rbaFlagConfigurationStruct.meanSigmaThreshold;
robustWeightThreshold           = rbaFlagConfigurationStruct.robustWeightThreshold;
transitDepthSigmaThreshold      = rbaFlagConfigurationStruct.transitDepthSigmaThreshold;     

% extract ccd dimensions from fcConstants
nCcdRows    = dynablackObject.fcConstants.CCD_COLUMNS;
nCcdColumns = dynablackObject.fcConstants.CCD_COLUMNS;

% extract run parameters
fclcIdx = find(~dynablackObject.cadenceTimes.gapIndicators);
channel = convert_from_module_output( dynablackObject.ccdModule, dynablackObject.ccdOutput );

% extract model component objects
rowModel   = dynablackResultsStruct.A1ModelDump.FCLC_Model.rows;
rowModelNl = dynablackResultsStruct.A1ModelDump.FCLC_Model.rows_nl;

% extract data subset objects and temporal coadds from A2 model
trailingCollat      = dynablackResultsStruct.A1ModelDump.ROI.trailingCollat;
trailingArp         = dynablackResultsStruct.A1ModelDump.ROI.trailingArp;
leadingArp          = dynablackResultsStruct.A1ModelDump.ROI.leadingArp;
readsPerLongCadence = dynablackResultsStruct.A2ModelDump.Constants.readsPerLongCadence;

% compute derived constants for output struct
meanThreshold           = pixelBiasThresholdAduPerRead * readsPerLongCadence;
varianceThreshold       = pixelNoiseThresholdAduPerRead ^ 2 * readsPerLongCadence;
nCadences               = length(fclcIdx);
spatialCoadds           = rowModel.Matrix(2,:);
robustWeightLoThresh    = robustWeightThreshold;
robustWeightHiThresh    = sqrt(robustWeightThreshold);
transitDepthThreshold   = meanThreshold;
transitDepthErrorThreshold = meanThreshold;


% develop row dependency of residuals and identify which rows are:
%       a) trailing black collateral included as-is
%       b) excluded due to scene-dependent effects
%       c) assembled from sums of ARP pixels

% extract rows which contribute to non-linear robust fit
rows        = rowModelNl.Matrix(1,:);
rowsRobust  = rows(rowModel.Subset_datum_index);

% find trailing collateral (black) indices, row range and number of column coadds
firstTrCollatIdx    = trailingCollat.First;
lastTrCollatIdx     = trailingCollat.Last;
trCollatIndices     = firstTrCollatIdx:lastTrCollatIdx;
trCollatColumnRange = trailingCollat.Column_min:trailingCollat.Column_max;
nTrCollatColumns    = trailingCollat.Column_count;

% arp rows are the rows in the trailing collateral row range which do *not* 
% correspond to trailing black data (so they must be arp data)
trCollatRowRange = min(rows(trCollatIndices)):max(rows(trCollatIndices));
nTrCollatRows    = length(trCollatRowRange);
allArpRows       = setdiff( trCollatRowRange, rows(trCollatIndices) );
nArpRows         = length(allArpRows);

% find trailing arp indices, columns and build arp row indices for each coadded trailing collateral column
firstTrArpIdx = trailingArp.First;
lastTrArpIdx  = trailingArp.Last;
trArpIndices  = firstTrArpIdx:lastTrArpIdx;

trArpColumns = trailingArp.Columns;
lastLeadingArpIdx = leadingArp.Last;

% build arp row indices array (nArpRows x nTrCollatColumns)
allArpRowsIndices = zeros(nArpRows,nTrCollatColumns);
for k = 1:nArpRows
    idx = find( rows(trArpIndices) == allArpRows(k));
    if ~isempty(idx)
        allArpRowsIndices(k,1:nTrCollatColumns) = idx( ismember(trArpColumns(idx), trCollatColumnRange)) + lastLeadingArpIdx;
    end
end

firstCollatRobustWtIdx = find( find(rowModel.Subset_datum_index) >= firstTrCollatIdx, 1, 'first');
collaterRowRangeRobust = firstCollatRobustWtIdx:length(rowsRobust);
excludedRows = setdiff(rows,rowsRobust);
allArpRowsRobust = setdiff(trCollatRowRange, unique([rowsRobust(collaterRowRangeRobust), excludedRows]));

nallArpRowsRobust = length(allArpRowsRobust);
firstTbArpRobustWtIdx = find( find(rowModel.Subset_datum_index) >= firstTrArpIdx, 1, 'first');
lastTbArpRobustWtIdx = find( find(rowModel.Subset_datum_index) <= lastTrArpIdx, 1, 'last');
tbArpRobustWtIdx = firstTbArpRobustWtIdx:lastTbArpRobustWtIdx;

% TODO: account for the case firstTbArpRobustWtIdx > lastTbArpRobustWtIdx,as well as empty-set possibilities
% Maybe ok according to JK - 20120307

trailingArpCols = trailingArp.Columns(rowModel.Subset_datum_index(trArpIndices));
allArpRowsIndicesRobust = zeros(nallArpRowsRobust,nTrCollatColumns);

for k = 1:nallArpRowsRobust
    idx = find( rowsRobust(tbArpRobustWtIdx) == allArpRowsRobust(k));    
    if ~isempty( idx )
        commonColumnLogical = ismember(trailingArpCols(idx), trCollatColumnRange);
        if any( commonColumnLogical )
            allArpRowsIndicesRobust(k,:) = idx( commonColumnLogical ) + firstTbArpRobustWtIdx - 1;            
        end
    end
end

% build constants struct for output
constants = struct('nCadences',nCadences,...
                    'nCcdRows',nCcdRows,...
                    'nCcdColumns',nCcdColumns,...
                    'severityQuantiles',severityQuantiles,...
                    'nFlagVariables',nFlagVariables,...
                    'testPulseDurations',testPulseDurations,...
                    'durationEarthOnSunLC',durationEarthOnSunLC,...
                    'cleaningScale',cleaningScale,...
                    'meanThreshold',meanThreshold,...
                    'varianceThreshold',varianceThreshold,...
                    'meanSigmaThreshold',meanSigmaThreshold,...
                    'transitDepthThreshold',transitDepthThreshold,...
                    'transitDepthErrorThreshold',transitDepthErrorThreshold,...
                    'transitDepthSigmaThreshold',transitDepthSigmaThreshold,...
                    'robustWeightLoThresh',robustWeightLoThresh,...
                    'robustWeightHiThresh',robustWeightHiThresh,...
                    'rows',rows,...
                    'spatialCoadds',spatialCoadds,...
                    'trCollatIndices',trCollatIndices,...
                    'trCollatRowRange',trCollatRowRange,...
                    'nTrCollatRows',nTrCollatRows,...
                    'allArpRows',allArpRows,...
                    'allArpRowsIndices',allArpRowsIndices,...
                    'rowsRobust',rowsRobust,...
                    'collaterRowRangeRobust',collaterRowRangeRobust,...
                    'excludedRows',excludedRows,...
                    'allArpRowsRobust',allArpRowsRobust,...
                    'allArpRowsIndicesRobust',allArpRowsIndicesRobust);

% build output struct
initInfo = struct('constants',constants,...
                    'channel',channel,...
                    'fclcIdx',fclcIdx);
                
                
