function  pdqScienceObject  = pdqScienceClass(pdqInputStruct, zeroBasedInputFlag)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function  pdqScienceObject  = pdqScienceClass(pdqInputStruct, zeroBasedInputFlag)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% This script implements the constructor for the pdqScienceClass using the
% previously validated input data structure as the template for the class.
% zeroBasedInputFlag can be set to true when debugging in Matlab
% it is absent when invoked from pdq_matlab_controller
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
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

% zeroBasedInputFlag can be set to true when debugging in Matlab
% it is absent when invoked from pdq_matlab_controller
if(~exist('zeroBasedInputFlag','var'))
    zeroBasedInputFlag = true;
end;


% Number of module/outputs
nModuleOutputs = pdqInputStruct.fcConstants.MODULE_OUTPUTS;

if (isempty(pdqInputStruct.inputPdqTsData.pdqModuleOutputTsData) )
    pdqInputStruct.inputPdqTsData = create_input_pdq_timeseries_structure(nModuleOutputs);
else
    inputPdqTsData = create_input_pdq_timeseries_structure(nModuleOutputs);
    pdqModuleOutputTsData = inputPdqTsData.pdqModuleOutputTsData;

    nModulesFromPreviousContact = length(pdqInputStruct.inputPdqTsData.pdqModuleOutputTsData);


    historyCcdModules = cat(1,pdqInputStruct.inputPdqTsData.pdqModuleOutputTsData.ccdModule);
    historyCcdOutputs = cat(1,pdqInputStruct.inputPdqTsData.pdqModuleOutputTsData.ccdOutput);
    historyModOuts = convert_from_module_output(historyCcdModules, historyCcdOutputs);
    missingModOuts = setxor(historyModOuts, (1:nModuleOutputs)');



    for j = 1:nModulesFromPreviousContact

        modOutNumber = historyModOuts(j);
        pdqModuleOutputTsData(modOutNumber) =  pdqInputStruct.inputPdqTsData.pdqModuleOutputTsData(j);
    end
    pdqInputStruct.inputPdqTsData.pdqModuleOutputTsData =  pdqModuleOutputTsData; % array of struct

    %----------------------------------------------------------------------------------------
    % this step is needed becasue of the bug discoverd during testing... For example, the modout 12
    % was not processed during contact 1 and hence it didn't have any metric time series at all.
    % However, in the second contact, that modout 12 was processed and its metric time series had
    % only 6 cadences instead of 8. This gives rise to different modouts having different length
    % metric time series. To avoid this bug, fill in missing modouts with -1 and gap indicators
    %----------------------------------------------------------------------------------------



    if(~isempty(missingModOuts))

        for k = 1:length(missingModOuts)

            [ccdMOdule, ccdOutput] = convert_to_module_output(missingModOuts(k));

            moduleOutputStruct.ccdModule                       = ccdMOdule;   % CCD Module value
            moduleOutputStruct.ccdOutput                       = ccdOutput;   % CCD ouput value (1 - 84)
            nCadences = length(pdqInputStruct.inputPdqTsData.cadenceTimes);

            timeSeriesStruct = struct('values',-1*ones(nCadences,1), 'gapIndicators', true(nCadences,1), 'uncertainties', -1*ones(nCadences,1));

            moduleOutputStruct.backgroundLevels                = timeSeriesStruct;   % Measured background level per CCD module/ouput
            moduleOutputStruct.blackLevels                     = timeSeriesStruct;   % black levels per CCD module/ouput
            moduleOutputStruct.centroidsMeanCols               = timeSeriesStruct;   % mean centroid - column value
            moduleOutputStruct.centroidsMeanRows               = timeSeriesStruct;   % Mean centroid - row value
            moduleOutputStruct.darkCurrents                    = timeSeriesStruct;   % dark current per CCD module/ouput
            moduleOutputStruct.dynamicRanges                   = timeSeriesStruct;   % reported max value - min value in ADU
            moduleOutputStruct.encircledEnergies               = timeSeriesStruct;   % Encircled energy time series
            moduleOutputStruct.meanFluxes                      = timeSeriesStruct;   % mean flux for targets in PDQ list
            moduleOutputStruct.plateScales                     = timeSeriesStruct;   % Results of plate scale algorithm
            moduleOutputStruct.smearLevels                     = timeSeriesStruct;   % smear levels per CCD module/ouput

            pdqInputStruct.inputPdqTsData.pdqModuleOutputTsData(missingModOuts(k)) =  moduleOutputStruct; % array of struct


        end




    end



end


if(zeroBasedInputFlag)
    pdqInputStruct = turn_row_column_arrays_to_1_based(pdqInputStruct);
end


%----------------------------------------------------------------------
% TBD: add additional fields for each stellar target to indicate whether
% the target is a good target or not
% possible future work.....

% numCadence  = length(pdqInputStruct.cadenceTimes);
%
% zArray      = zeros(numCadence, 1);
% zBoolArray  = false(numCadence, 1);
% [pdqInputStruct.stellarPdqTargets.centroidRows] = deal(zArray);
% [pdqInputStruct.stellarPdqTargets.centroidCols] = deal(zArray);
% [pdqInputStruct.stellarPdqTargets.goodTargetIndicator] = deal(zBoolArray);
% [pdqInputStruct.stellarPdqTargets.rawFlux] = deal(zArray);
%----------------------------------------------------------------------



%  input validation successfully completed! instantiate class
pdqScienceObject = class(pdqInputStruct, 'pdqScienceClass');
return







% SUB FUNCTION

%----------------------------------------------------------------------
function pdqInputStruct = turn_row_column_arrays_to_1_based(pdqInputStruct)
%----------------------------------------------------------------------
% Arrays in Matlab are 1 based but arrays in Java are 0 based
% convert row, column values to 1-based by adding 1 to all row/columns
%----------------------------------------------------------------------



%----------------------------------------------------------------------
% Collateral data - add 1 to row & column indices
%----------------------------------------------------------------------

% Determine how many collateral targets are present
numCollateralTargets  = length(pdqInputStruct.collateralPdqTargets);

for j = 1 : numCollateralTargets

    collateralPixelRows = [pdqInputStruct.collateralPdqTargets(j).referencePixels.row]; % horizontal cat
    collateralPixelRows = num2cell(collateralPixelRows+1);
    [pdqInputStruct.collateralPdqTargets(j).referencePixels.row] = deal(collateralPixelRows{:});


    collateralPixelColumns = [pdqInputStruct.collateralPdqTargets(j).referencePixels.column]; % horizontal cat
    collateralPixelColumns = num2cell(collateralPixelColumns+1);
    [pdqInputStruct.collateralPdqTargets(j).referencePixels.column] = deal(collateralPixelColumns{:});

end


%----------------------------------------------------------------------
% Background data - add 1 to row & column indices
% can't avoid this loop as 'deal' function doesn't work for this case
%----------------------------------------------------------------------

numBkgdTargets   = length(pdqInputStruct.backgroundPdqTargets);
for j = 1 : numBkgdTargets

    bkgdPixelRows = [pdqInputStruct.backgroundPdqTargets(j).referencePixels.row];
    bkgdPixelRows = num2cell(bkgdPixelRows+1);

    [pdqInputStruct.backgroundPdqTargets(j).referencePixels.row]    =  deal(bkgdPixelRows{:});


    bkgdPixelColumns = [pdqInputStruct.backgroundPdqTargets(j).referencePixels.column];
    bkgdPixelColumns = num2cell(bkgdPixelColumns + 1);

    [pdqInputStruct.backgroundPdqTargets(j).referencePixels.column]    =  deal(bkgdPixelColumns{:});

end

%----------------------------------------------------------------------
% Stellar data - add 1 to row & column indices
%----------------------------------------------------------------------
numStellarTargets = length(pdqInputStruct.stellarPdqTargets);
for j = 1 : numStellarTargets

    stellarPixelRows = [pdqInputStruct.stellarPdqTargets(j).referencePixels.row]; % horizontal cat
    stellarPixelRows = num2cell(stellarPixelRows+1);
    [pdqInputStruct.stellarPdqTargets(j).referencePixels.row] = deal(stellarPixelRows{:});


    stellarPixelColumns = [pdqInputStruct.stellarPdqTargets(j).referencePixels.column]; % horizontal cat
    stellarPixelColumns = num2cell(stellarPixelColumns+1);
    [pdqInputStruct.stellarPdqTargets(j).referencePixels.column] = deal(stellarPixelColumns{:});
end


return
