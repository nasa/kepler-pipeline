function [outputsStruct goodnessStruct ] = recalc_goodness_metric(inputsStruct,outputsStruct)
% function [outputsStruct goodnessStruct ] = recalc_goodness_metric(inputsStruct,outputsStruct)
%
%   calculates the goodness metric for inputsStruct,outputsStruct
%   also:
%   - saves it to 'goodnessRecalculated.mat'
%   - creates figures in 'goodness_metric_plots_recalculated'
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

    %% some constants (default, so hardcoded)
    doSavePlots = true;
    doNormalizeFlux = true;
    doCalcEpGoodness = true;
    doSaveResults = true;
    
    %% add defaults, in case old inputsStruct is used
    inputsStruct = pdc_convert_81_data_to_82(inputsStruct);
%     if (~isfield(inputsStruct.goodnessMetricConfigurationStruct,'earthPointScale'))
%         inputsStruct.goodnessMetricConfigurationStruct.earthPointScale = 1;
%     end
%     if (~isfield(inputsStruct.goodnessMetricConfigurationStruct,'earthPointScale'))
%         inputsStruct.goodnessMetricConfigurationStruct.earthPointScale = 1;
%     end
%     pdcModuleParameters.stellarVariabilityRemoveEclipsingBinariesEnabled
    
    %% generate label-based target exclusions
    targetDataStruct = pdc_generate_target_exclusion_list( inputsStruct.targetDataStruct , ...
                                                           inputsStruct.pdcModuleParameters.excludeTargetLabels );

    %% convert outputsStruct.targetResultsStruct to inputsStruct.targetDataStruct
    for i=1:length(targetDataStruct)    
        tempStruct(i).values = outputsStruct.targetResultsStruct(i).correctedFluxTimeSeries.values;
        tempStruct(i).uncertainties = outputsStruct.targetResultsStruct(i).correctedFluxTimeSeries.uncertainties;
        tempStruct(i).gapIndicators = outputsStruct.targetResultsStruct(i).correctedFluxTimeSeries.gapIndicators;
        tempStruct(i).filledIndices = outputsStruct.targetResultsStruct(i).correctedFluxTimeSeries.filledIndices;
        tempStruct(i).keplerId = targetDataStruct(i).keplerId;
    end
    
    %% calculate goodness metric
    goodnessStruct = pdc_goodness_metric( targetDataStruct, ... 
                                          tempStruct, ...
                                          inputsStruct.cadenceTimes, ...
                                          inputsStruct.pdcModuleParameters, ...
                                          inputsStruct.goodnessMetricConfigurationStruct, ...
                                          doNormalizeFlux, ...
                                          doSavePlots, ...
                                          'recalculated', ...
                                          '_recalculated', ...
                                          doCalcEpGoodness );
    %% save output
	if (doSaveResults)
        save('goodnessRecalculated','goodnessStruct');
    end
    
    %% overwrite values in outputsStruct
    for i=1:length(targetDataStruct)
        outputsStruct.targetResultsStruct(i).pdcGoodnessMetric = goodnessStruct(i);
    end

end                               
