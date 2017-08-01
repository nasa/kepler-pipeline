function [pdqOutputStruct1, pdqOutputStruct2] = enforce_same_cadence_range_on_pdq_outputs_for_comparison(pdqOutputStructOld, pdqOutputStructNew)
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


cadenceTimes1 = pdqOutputStructOld.outputPdqTsData.cadenceTimes;
cadenceTimes2 = pdqOutputStructNew.outputPdqTsData.cadenceTimes;

[commonCadenceTimes, indexInOld, indexInNew] = intersect(cadenceTimes1, cadenceTimes2);

if(isempty(commonCadenceTimes))
    error('PDQValidation:enforce_same_cadence_range_on_pdq_outputs_for_comparison:noCommonTimeStamps',...
        'PDQValidation:enforce_same_cadence_range_on_pdq_outputs_for_comparison: no common timestamps between the two runs; can''t proceed, so quitting PDQ Validation  ');
end



if(isequal(commonCadenceTimes,cadenceTimes1) && isequal(commonCadenceTimes,cadenceTimes2))
    pdqOutputStruct1 = pdqOutputStructOld;
    pdqOutputStruct2 = pdqOutputStructNew;
    return
end

% if the cadence timestamps are not the same

% for pdqOutputStructOld, keep metrics for only indexInOld, remove the rest

pdqOutputStruct1.outputPdqTsData = keep_metrics_for_common_cadences(pdqOutputStructOld.outputPdqTsData, indexInOld);
pdqOutputStruct2.outputPdqTsData = keep_metrics_for_common_cadences(pdqOutputStructNew.outputPdqTsData, indexInNew);


return


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function  outputPdqTsData = keep_metrics_for_common_cadences(outputPdqTsData, indexToKeep)

nModOuts = length(outputPdqTsData.pdqModuleOutputTsData);
singlePrecisionFlag = true;

for j = 1:nModOuts
    outputPdqTsData.pdqModuleOutputTsData(j).blackLevels  = keep_values_for_common_cadences(outputPdqTsData.pdqModuleOutputTsData(j).blackLevels, indexToKeep,singlePrecisionFlag);
    outputPdqTsData.pdqModuleOutputTsData(j).smearLevels  = keep_values_for_common_cadences(outputPdqTsData.pdqModuleOutputTsData(j).smearLevels, indexToKeep,singlePrecisionFlag);
    outputPdqTsData.pdqModuleOutputTsData(j).darkCurrents  = keep_values_for_common_cadences(outputPdqTsData.pdqModuleOutputTsData(j).darkCurrents, indexToKeep,singlePrecisionFlag);
    outputPdqTsData.pdqModuleOutputTsData(j).backgroundLevels  = keep_values_for_common_cadences(outputPdqTsData.pdqModuleOutputTsData(j).backgroundLevels, indexToKeep,singlePrecisionFlag);
    outputPdqTsData.pdqModuleOutputTsData(j).dynamicRanges  = keep_values_for_common_cadences(outputPdqTsData.pdqModuleOutputTsData(j).dynamicRanges, indexToKeep,singlePrecisionFlag);
    outputPdqTsData.pdqModuleOutputTsData(j).meanFluxes  = keep_values_for_common_cadences(outputPdqTsData.pdqModuleOutputTsData(j).meanFluxes, indexToKeep,singlePrecisionFlag);
    outputPdqTsData.pdqModuleOutputTsData(j).centroidsMeanRows  = keep_values_for_common_cadences(outputPdqTsData.pdqModuleOutputTsData(j).centroidsMeanRows, indexToKeep,singlePrecisionFlag);
    outputPdqTsData.pdqModuleOutputTsData(j).centroidsMeanCols  = keep_values_for_common_cadences(outputPdqTsData.pdqModuleOutputTsData(j).centroidsMeanCols, indexToKeep,singlePrecisionFlag);
    outputPdqTsData.pdqModuleOutputTsData(j).encircledEnergies  = keep_values_for_common_cadences(outputPdqTsData.pdqModuleOutputTsData(j).encircledEnergies, indexToKeep,singlePrecisionFlag);
    outputPdqTsData.pdqModuleOutputTsData(j).plateScales  = keep_values_for_common_cadences(outputPdqTsData.pdqModuleOutputTsData(j).plateScales, indexToKeep,singlePrecisionFlag);
end


outputPdqTsData.cadenceTimes  = outputPdqTsData.cadenceTimes(indexToKeep);
singlePrecisionFlag = false;
outputPdqTsData.attitudeSolutionRa  = keep_values_for_common_cadences(outputPdqTsData.attitudeSolutionRa, indexToKeep,singlePrecisionFlag);
outputPdqTsData.attitudeSolutionDec  = keep_values_for_common_cadences(outputPdqTsData.attitudeSolutionDec, indexToKeep,singlePrecisionFlag);
outputPdqTsData.attitudeSolutionRoll  = keep_values_for_common_cadences(outputPdqTsData.attitudeSolutionRoll, indexToKeep,singlePrecisionFlag);

outputPdqTsData.desiredAttitudeRa  = keep_values_for_common_cadences(outputPdqTsData.desiredAttitudeRa, indexToKeep,singlePrecisionFlag);
outputPdqTsData.desiredAttitudeDec  = keep_values_for_common_cadences(outputPdqTsData.desiredAttitudeDec, indexToKeep,singlePrecisionFlag);
outputPdqTsData.desiredAttitudeRoll  = keep_values_for_common_cadences(outputPdqTsData.desiredAttitudeRoll, indexToKeep,singlePrecisionFlag);

outputPdqTsData.deltaAttitudeRa  = keep_values_for_common_cadences(outputPdqTsData.deltaAttitudeRa, indexToKeep,singlePrecisionFlag);
outputPdqTsData.deltaAttitudeDec  = keep_values_for_common_cadences(outputPdqTsData.deltaAttitudeDec, indexToKeep,singlePrecisionFlag);
outputPdqTsData.deltaAttitudeRoll  = keep_values_for_common_cadences(outputPdqTsData.deltaAttitudeRoll, indexToKeep,singlePrecisionFlag);

singlePrecisionFlag = true;
outputPdqTsData.maxAttitudeResidualInPixels  = keep_values_for_common_cadences(outputPdqTsData.maxAttitudeResidualInPixels, indexToKeep,singlePrecisionFlag);


return
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function  metricStruct = keep_values_for_common_cadences(metricStruct, keepIndex,singlePrecisionFlag)

if(singlePrecisionFlag)
    metricStruct.values = single(metricStruct.values(keepIndex));
    metricStruct.uncertainties = single(metricStruct.uncertainties(keepIndex));
else
    metricStruct.values = metricStruct.values(keepIndex);
    metricStruct.uncertainties = metricStruct.uncertainties(keepIndex);
end

metricStruct.gapIndicators = metricStruct.gapIndicators(keepIndex);

return
