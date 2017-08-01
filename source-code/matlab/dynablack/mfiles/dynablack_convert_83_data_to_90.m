function  [inputsStruct] = dynablack_convert_83_data_to_90(inputsStruct)
% 
% function  [inputsStruct] = dynablack_convert_83_data_to_90(inputsStruct)
% 
% This function converts a SOC 8.3 DYNABLACK inputsStruct to one used in the SOC
% 9.0 build.
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


defaultSeason = 3;
dynablackModuleParameters = inputsStruct.dynablackModuleParameters;


% ~~~~~~~~~~~~~~ load default parameter value if module parameter field is not present
% retrieve default module parameters from 'the' single source
defaults = seed_dynablack_module_parameters_with_defaults;
parameterFields = fieldnames(defaults);
for iField = 1:length(parameterFields)
    if ~isfield(dynablackModuleParameters,parameterFields{iField})
        dynablackModuleParameters.(parameterFields{iField}) = defaults.(parameterFields{iField});
    end
end


% ~~~~~~~~~~~~~~ update dataAnomalyTypes to dataAnomalyFlags
if isfield(inputsStruct,'reverseClockedCadenceTimes')    
    allFalse = false(size(inputsStruct.reverseClockedCadenceTimes.cadenceNumbers));    
    if ~isfield(inputsStruct.reverseClockedCadenceTimes,'dataAnomalyFlags')                
        A.attitudeTweakIndicators = allFalse;
        A.safeModeIndicators = allFalse;
        A.coarsePointIndicators = allFalse;
        A.argabrighteningIndicators =allFalse;
        A.excludeIndicators = allFalse;
        A.earthPointIndicators = allFalse;        
        inputsStruct.reverseClockedCadenceTimes.dataAnomalyFlags = A;
    end
end
if isfield(inputsStruct,'cadenceTimes')    
    allFalse = false(size(inputsStruct.cadenceTimes.cadenceNumbers));    
    if ~isfield(inputsStruct.cadenceTimes,'dataAnomalyFlags')                
        A.attitudeTweakIndicators = allFalse;
        A.safeModeIndicators = allFalse;
        A.coarsePointIndicators = allFalse;
        A.argabrighteningIndicators =allFalse;
        A.excludeIndicators = allFalse;
        A.earthPointIndicators = allFalse;        
        inputsStruct.cadenceTimes.dataAnomalyFlags = A;
    end
end


% ~~~~~~~~~~~~~~ make incoming module parameters row vectors if they are column vectors
parameterFields = fields(dynablackModuleParameters);
for iField = 1:length(parameterFields)
    if iscolumn(dynablackModuleParameters.(parameterFields{iField}))
        dynablackModuleParameters.(parameterFields{iField}) = rowvec(dynablackModuleParameters.(parameterFields{iField}));
    end
end

% ~~~~~~~~~~~~~~ force override to default value for some parameters
dynablackModuleParameters.a1NumPredictorRows = defaults.a1NumPredictorRows;
dynablackModuleParameters.a1NumNonlinearPredictorRows = defaults.a1NumNonlinearPredictorRows;
% dynablackModuleParameters.defaultRowTimeConstant = defaults.defaultRowTimeConstant;
dynablackModuleParameters.nearTbMinpix = defaults.nearTbMinpix;
dynablackModuleParameters.a2ColumnPredictorCount = defaults.a2ColumnPredictorCount;
dynablackModuleParameters.a2SmearPredictorCount = defaults.a2SmearPredictorCount;


% ~~~~~~~~~~~~~~ hard code season 3 for testing purposes until season is supplied in the inputsStruct
if( ~isfield(inputsStruct, 'season') )
    inputsStruct.season = defaultSeason;
end

% ~~~~~~~~~~~~~~ load parameters into inputsStruct
inputsStruct.dynablackModuleParameters = dynablackModuleParameters;
