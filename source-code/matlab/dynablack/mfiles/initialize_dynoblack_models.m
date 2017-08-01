
function initializedModels = initialize_dynoblack_models( dynablackResultsStruct, varargin )
%
% function initializedModels = initialize_dynoblack_models( dynablackResultsStruct, varargin )
%
% Initialize models used in dynoblack (dynamic 2D black retrieval) based on the dynablack fit results and a small set of configuration
% parameters. Variable argument is dynoblackConfigStruct which has form of defaultConfigStruct.
%
% defaultConfigStruct = struct('stdRatioThreshold', 1.5, ...                    % set noise threshold in fit reconstruction
%                                 'coefficentModelId', 4,...                    % identifies temporal model to use in fit reconstruction
%                                 'modelAutoSelectEnable',true,...              % the 'best model' for each fit parameter is chosen based on
%                                                                               % the chi^2 of the fits
%                                 'useRobustVerticalCoeffs', true,...           % use robust fit results in fit reconstruction
%                                 'useRobustFrameFgsCoeffs', true,...
%                                 'useRobustParallelFgsCoeffs', true,...
%                                 'chi2Threshold', 0.95);
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

defaultConfigStruct = struct('stdRatioThreshold', 1.5, ...
                                'coefficentModelId', 4,...
                                'modelAutoSelectEnable',true,...
                                'useRobustVerticalCoeffs', true,...
                                'useRobustFrameFgsCoeffs', true,...
                                'useRobustParallelFgsCoeffs', true,...
                                'chi2Threshold', 0.95,...
                                'enableDbDataQualityGapping',true,...
                                'enableMmntmDmpFlag',true,...
                                'enableSefiAccFlag',true,...
                                'enableSefiCadFlag',true,...
                                'enableLdeOosFlag',true,...
                                'enableLdeParErFlag',true,...
                                'enableScrcErrFlag',true,...
                                'enableCoarsePointProcessing',false,...
                                'enableExcludeIndicators',true);
                            
% use dynoblackConfigStruct entered as variable argument
if nargin < 2
    dynoblackConfigStruct = defaultConfigStruct;
else
    dynoblackConfigStruct = varargin{1};
end

% set up and initialize input parameters
module  = dynablackResultsStruct.ccdModule;
output  = dynablackResultsStruct.ccdOutput;
channel = convert_from_module_output( module, output );

% add channel number to config struct - used to get mean black from table
dynoblackConfigStruct.channel = channel;

% initialize fitted models
initializedModels = DynOBlack_init( dynoblackConfigStruct, dynablackResultsStruct );

% add information from fit struct as to which cadences and mjds were actually fit
initializedModels.midTimestamps = dynablackResultsStruct.cadenceTimes.midTimestamps;
fclcList = dynablackResultsStruct.A1ModelDump.Inputs.FCLC_list;

% identify FCLC_list entries which meet gapping criteria
gapList = data_quality_gaps(dynablackResultsStruct, dynoblackConfigStruct);
tf = ismember(fclcList, gapList);

% add dynoblack configuration struct,fclc list and gap indicators
initializedModels.dynoblackConfigStruct = dynoblackConfigStruct;
initializedModels.FCLC_list = fclcList;
initializedModels.FCLC_gapIndicators = tf;

end


% ---------- begin subfunctions ---------------

function indexList = data_quality_gaps(is, config)

% extract flags
dbDqGaps = config.enableDbDataQualityGapping;
mD = config.enableMmntmDmpFlag;
sA = config.enableSefiAccFlag;
sC = config.enableSefiCadFlag;
lO = config.enableLdeOosFlag;
lP = config.enableLdeParErFlag;
sE = config.enableScrcErrFlag;
fP = config.enableCoarsePointProcessing;
eI = config.enableExcludeIndicators;

c = is.cadenceTimes;
d = c.dataAnomalyFlags; 

% extract cadence gap indicators
g = c.gapIndicators;

% initialize s/c gap indicators and exclude indicators
s = false(size(g));
f = false(size(g));

if dbDqGaps
    
    % build s/c data quality gap indicators
    if mD; s = s|c.isMmntmDmp; end
    if sA; s = s|c.isSefiAcc; end
    if sC; s = s|c.isSefiCad; end
    if lO; s = s|c.isLdeOos; end
    if lP; s = s|c.isLdeParEr; end
    if sE; s = s|c.isScrcErr; end
    if fP; s = s|~c.isFinePnt; end
    % build data anomaly flags
    if eI; f = f|d.excludeIndicators; end
end

% find relative indices
indexList = find(g | s | f);

end
