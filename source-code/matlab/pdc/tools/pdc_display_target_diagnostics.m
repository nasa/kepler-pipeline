% function pdc_display_target_diagnostics (outputsStruct, targetIndex)
%
% Displays to the command line diagnostic information for <targetIndex>.
%
% Must be the same target for all outputsStructs given.
%
% Inputs:
%   targetIndex    -- [int] Target Index to display
%   outputsStruct1  -- [outputsStruct] resultant from running pdc_matlab_controller
%   outputsStruct2  -- [outputsStruct optional] Another outputsStruct to also display
%   outputsStruct3  -- [outputsStruct optional] Another outputsStruct to also display
%
% Outputs:
%   none, just text to command window.
%
%---------------------------------------------------------------------------------
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

function pdc_display_target_diagnostics (targetIndex, outputsStruct1, varargin)

    if (~isempty(varargin))
        if (length(varargin) == 1)
            nOutputs = 2;
            outputsStruct2 = varargin{1};
        elseif (length(varargin) == 2)
            nOutputs = 3;
            outputsStruct2 = varargin{1};
            outputsStruct3 = varargin{2};
        else
            error ('Can only display up to three total outputStruct');
        end
    else
        nOutputs = 1;
    end

    nTargets = length(outputsStruct1.targetResultsStruct);

    kepId = outputsStruct1.targetResultsStruct(targetIndex).keplerId;
    if (nOutputs == 2 && (kepId ~= outputsStruct2.targetResultsStruct(targetIndex).keplerId || ...
        nTargets ~= length(outputsStruct2.targetResultsStruct)))
        error('Must give the same target for all outputsStructs given.');
    end
    if (nOutputs == 3 && (kepId ~= outputsStruct3.targetResultsStruct(targetIndex).keplerId || ...
        nTargets ~= length(outputsStruct3.targetResultsStruct)))
        error('Must give the same target for all outputsStructs given.');
    end
    

    display('**********************************************************')
    % basic information
    display(['Module ', num2str(outputsStruct1.ccdModule), '.',num2str(outputsStruct1.ccdOutput)]); 
    display(['Target ', num2str(targetIndex), ' of ', num2str(nTargets)]);


    % Goodness Metric
    pdcGoodTotal_1              = outputsStruct1.targetResultsStruct(targetIndex).pdcGoodnessMetric.total.value;
    pdcGoodCorrelation_1        = outputsStruct1.targetResultsStruct(targetIndex).pdcGoodnessMetric.correlation.value;
    pdcGoodDeltaVariability_1   = outputsStruct1.targetResultsStruct(targetIndex).pdcGoodnessMetric.deltaVariability.value;
    pdcGoodIntroducedNoise_1    = outputsStruct1.targetResultsStruct(targetIndex).pdcGoodnessMetric.introducedNoise.value;
    if (isfield(outputsStruct1.targetResultsStruct(targetIndex).pdcGoodnessMetric, 'earthPointRemoval'))
        pdcGoodEarthPointRemoval_1  = outputsStruct1.targetResultsStruct(targetIndex).pdcGoodnessMetric.earthPointRemoval.value;
    else
        pdcGoodEarthPointRemoval_1  = NaN;
    end
    if (isfield(outputsStruct1.targetResultsStruct(targetIndex).pdcGoodnessMetric, 'spikeRemoval'))
        pdcGoodSpikeRemoval_1  = outputsStruct1.targetResultsStruct(targetIndex).pdcGoodnessMetric.spikeRemoval.value;
    else
        pdcGoodSpikeRemoval_1  = NaN;
    end
    if (isfield(outputsStruct1.targetResultsStruct(targetIndex).pdcGoodnessMetric, 'cdpp'))
        pdcGoodCdpp_1  = outputsStruct1.targetResultsStruct(targetIndex).pdcGoodnessMetric.cdpp.value;
    else
        pdcGoodCdpp_1  = NaN;
    end
    if (isfield(outputsStruct1.targetResultsStruct(targetIndex).pdcGoodnessMetric, 'kepstddev'))
        pdcGoodKepstddev_1  = outputsStruct1.targetResultsStruct(targetIndex).pdcGoodnessMetric.kepstddev.value;
    else
        pdcGoodKepstddev_1  = NaN;
    end
    if (isfield(outputsStruct1.targetResultsStruct(targetIndex).pdcGoodnessMetric, 'rollTweak'))
        pdcGoodRollTweak_1  = outputsStruct1.targetResultsStruct(targetIndex).pdcGoodnessMetric.rollTweak.value;
    else
        pdcGoodRollTweak_1  = NaN;
    end

    if (nOutputs >= 2)
        pdcGoodTotal_2              = outputsStruct2.targetResultsStruct(targetIndex).pdcGoodnessMetric.total.value;
        pdcGoodCorrelation_2        = outputsStruct2.targetResultsStruct(targetIndex).pdcGoodnessMetric.correlation.value;
        pdcGoodDeltaVariability_2   = outputsStruct2.targetResultsStruct(targetIndex).pdcGoodnessMetric.deltaVariability.value;
        pdcGoodIntroducedNoise_2    = outputsStruct2.targetResultsStruct(targetIndex).pdcGoodnessMetric.introducedNoise.value;
        pdcGoodEarthPointRemoval_2  = outputsStruct2.targetResultsStruct(targetIndex).pdcGoodnessMetric.earthPointRemoval.value;
    end

    if (nOutputs == 3)
        pdcGoodTotal_3              = outputsStruct3.targetResultsStruct(targetIndex).pdcGoodnessMetric.total.value;
        pdcGoodCorrelation_3        = outputsStruct3.targetResultsStruct(targetIndex).pdcGoodnessMetric.correlation.value;
        pdcGoodDeltaVariability_3   = outputsStruct3.targetResultsStruct(targetIndex).pdcGoodnessMetric.deltaVariability.value;
        pdcGoodIntroducedNoise_3    = outputsStruct3.targetResultsStruct(targetIndex).pdcGoodnessMetric.introducedNoise.value;
        pdcGoodEarthPointRemoval_3  = outputsStruct3.targetResultsStruct(targetIndex).pdcGoodnessMetric.earthPointRemoval.value;
    end

    format = '%8.3f';
    intFormat = '%8.1i';

    % TODO: This is getting awkward, redo more cleanly
    multiscaleMapUsed = false(nOutputs,1);
    multiscaleMapUsageUnknown = false;
    if (~isfield(outputsStruct1, 'pdcVersion') || outputsStruct1.pdcVersion < 9.0)
        if (isfield(outputsStruct1.targetResultsStruct(targetIndex).dataProcessingStruct, 'multiscaleMapUsed'))
            multiscaleMapUsed(1) = outputsStruct1.targetResultsStruct(targetIndex).dataProcessingStruct.multiscaleMapUsed; 
        else
            multiscaleMapUsageUnknown = true;
        end
    elseif (strcmp(outputsStruct1.targetResultsStruct(targetIndex).pdcProcessingStruct.pdcMethod, 'multiScaleMap')); 
        multiscaleMapUsed(1) = true;
    else
        multiscaleMapUsed(1) = false;
    end
    if (nOutputs >= 2)
        if (~isfield(outputsStruct2, 'pdcVersion') || outputsStruct2.pdcVersion < 9.0)
            multiscaleMapUsed(2) = outputsStruct2.targetResultsStruct(targetIndex).dataProcessingStruct.multiscaleMapUsed; 
        elseif (strcmp(outputsStruct2.targetResultsStruct(targetIndex).pdcProcessingStruct.pdcMethod, 'multiScaleMap')); 
            multiscaleMapUsed(2) = true;
        else
            multiscaleMapUsed(2) = false;
        end
    end
    if (nOutputs == 3)
        if (~isfield(outputsStruct3, 'pdcVersion') || outputsStruct3.pdcVersion < 9.0)
            multiscaleMapUsed(3) = outputsStruct2.targetResultsStruct(targetIndex).dataProcessingStruct.multiscaleMapUsed; 
        elseif (strcmp(outputsStruct3.targetResultsStruct(targetIndex).pdcProcessingStruct.pdcMethod, 'multiScaleMap')); 
            multiscaleMapUsed(3) = true;
        else
            multiscaleMapUsed(3) = false;
        end
    end

    if (nOutputs == 1)
        goodnessString    =  '';
        totalString       = [num2str(pdcGoodTotal_1, format)            ]; 
        correlationString = [num2str(pdcGoodCorrelation_1, format)      ]; 
        variabilityString = [num2str(pdcGoodDeltaVariability_1, format) ]; 
        noiseString       = [num2str(pdcGoodIntroducedNoise_1, format)  ]; 
        epString          = [num2str(pdcGoodEarthPointRemoval_1, format)]; 
        spikeString       = [num2str(pdcGoodSpikeRemoval_1, format)]; 
        cdppString        = [num2str(pdcGoodCdpp_1, format)]; 
        kepstddevString   = [num2str(pdcGoodKepstddev_1, format)]; 
        rollTweakString   = [num2str(pdcGoodRollTweak_1, format)]; 
        msMapString = ...
        [ num2str(multiscaleMapUsed(1), intFormat)];
    elseif(nOutputs == 2)
        goodnessString    = '   1   |   2    ';
        totalString       = [num2str(pdcGoodTotal_1, format),             '  | ', num2str(pdcGoodTotal_2, format)              ]; 
        correlationString = [num2str(pdcGoodCorrelation_1, format),       '  | ', num2str(pdcGoodCorrelation_2, format)        ]; 
        variabilityString = [num2str(pdcGoodDeltaVariability_1, format),  '  | ', num2str(pdcGoodDeltaVariability_2, format)   ]; 
        noiseString       = [num2str(pdcGoodIntroducedNoise_1, format),   '  | ', num2str(pdcGoodIntroducedNoise_2, format)    ]; 
        epString          = [num2str(pdcGoodEarthPointRemoval_1, format), '  | ', num2str(pdcGoodEarthPointRemoval_2, format)  ]; 
        msMapString = ...
        [ num2str(multiscaleMapUsed(1), intFormat), '      | ',  ...
          num2str(multiscaleMapUsed(2), intFormat)];
    elseif(nOutputs == 3)
        goodnessString    = '   1   |   2    |   3     ';
        totalString       = [num2str(pdcGoodTotal_1, format),             '  | ', num2str(pdcGoodTotal_2, format),             '  | ',num2str(pdcGoodTotal_3, format)]; 
        correlationString = [num2str(pdcGoodCorrelation_1, format),       '  | ', num2str(pdcGoodCorrelation_2, format),       '  | ',num2str(pdcGoodCorrelation_3, format)]; 
        variabilityString = [num2str(pdcGoodDeltaVariability_1, format),  '  | ', num2str(pdcGoodDeltaVariability_2, format),  '  | ',num2str(pdcGoodDeltaVariability_3, format)]; 
        noiseString       = [num2str(pdcGoodIntroducedNoise_1, format),   '  | ', num2str(pdcGoodIntroducedNoise_2, format),   '  | ',num2str(pdcGoodIntroducedNoise_3, format)]; 
        epString          = [num2str(pdcGoodEarthPointRemoval_1, format), '  | ', num2str(pdcGoodEarthPointRemoval_2, format), '  | ',num2str(pdcGoodEarthPointRemoval_3, format)]; 
        msMapString = ...
        [ num2str(multiscaleMapUsed(1), intFormat), '      | ',  ...
          num2str(multiscaleMapUsed(2), intFormat), '      | ',  ...
          num2str(multiscaleMapUsed(3), intFormat)];
    end

    display('*************************')
    display(['Goodness:              ', goodnessString]);
    display('-------------------------------------------------------');
    display(['total                = ', totalString]);    
    display(['Correlation          = ', correlationString]); 
    display(['Delta Variability    = ', variabilityString]); 
    display(['Introduced Noise     = ', noiseString]);       
    display(['Earth Point Recovery = ', epString]);          
    display(['Spike Recovery       = ', spikeString]);          
    display(['Roll Tweak           = ', rollTweakString]);          
    display(['Quasi-CDPP           = ', cdppString]);          
    display(['kepstddev            = ', kepstddevString]);          
    display(' ')

    % If multi-scale MAP was used
    if (~multiscaleMapUsageUnknown)
        display(['Multi-Scale MAP used = ', num2str(multiscaleMapUsed)]);
    end
    % Which pdcMethod was chosen
    display(    ['PDC Method Chosen    = ', outputsStruct1.targetResultsStruct(targetIndex).pdcProcessingStruct.pdcMethod]);

    display(' ')


    % Any discontinuities
    if (~isfield(outputsStruct1, 'pdcVersion') || outputsStruct1.pdcVersion < 9.0)
        discontinuitiesDetected = outputsStruct1.targetResultsStruct(targetIndex).dataProcessingStruct.discontinuitiesDetected;
        discontinuitiesRemoved  = outputsStruct1.targetResultsStruct(targetIndex).dataProcessingStruct.discontinuitiesRemoved;
    else
        discontinuitiesDetected = (outputsStruct1.targetResultsStruct(targetIndex).pdcProcessingStruct.numDiscontinuitiesDetected > 0);
        discontinuitiesRemoved  = (outputsStruct1.targetResultsStruct(targetIndex).pdcProcessingStruct.numDiscontinuitiesRemoved  > 0);
    end
    if ( discontinuitiesDetected || discontinuitiesRemoved  )
        display('*************************')
        if (discontinuitiesDetected && ~discontinuitiesRemoved)
            display('An SPSD was detected but not removed.');
        else    
            display('An SPSD was removed.');
        end
        discontinuities = outputsStruct1.targetResultsStruct(targetIndex).discontinuityIndices;
        % Outputs are zero based
        display(['Discontinuity location(s): ', num2str((discontinuities+1))]);
    end

    display('***')
