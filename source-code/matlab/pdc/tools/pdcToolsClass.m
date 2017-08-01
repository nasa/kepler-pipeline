%% Contains a bunch of small helper functions used during V&V and DAWGing.
%
%%
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

classdef pdcToolsClass

    properties

    end

    methods (Static = true)

        %%********************************************************************************
        % function MJD = fill_MJD_gaps(MJD_WithZeros)
        % Code source: JVC
        %
        %  Interpolates missing MJDs using simple linear interpolation.
        %
        % Inputs:
        %   MJD_WithZeros   -- [float array(nCadences)] e.g. timestamps from cadencesTimes struct
        %
        % Outputs:
        %   MJD             -- [float array(nCadences)] e.g. timestamps in MJD, gaps filled
        %%

        function MJD = fill_MJD_gaps(MJD_WithZeros)
 
            MJD = MJD_WithZeros;
            NumDates = length(MJD_WithZeros);
            RCIOfZeros = find(MJD_WithZeros < 50000);
            RCIOfNonZeros = find(MJD_WithZeros >= 50000);
            AverageInterval = (MJD_WithZeros(RCIOfNonZeros(end)) - MJD_WithZeros(RCIOfNonZeros(1)))/(RCIOfNonZeros(end)-RCIOfNonZeros(1));
            MJD(RCIOfZeros) = AverageInterval*(RCIOfZeros - RCIOfNonZeros(1)) + MJD_WithZeros(RCIOfNonZeros(1));

        end

        %%********************************************************************************
        function [Quarter Month] = quarter_lookup(MJD)

            quarterTable = [[54953.0, 54962.8];...% Q0
                            [54964.0, 54997.5];...% Q1
                            [55002.0, 55091.0];...% Q2
                            [55092.7, 55182.0];...% Q3
                            [55184.8, 55274.8];...% Q4
                            [55275.9, 55370.7];...% Q5
                            [55371.9, 55461.8];...% Q6
                            [55462.7, 55552.1];...% Q7
                            [55556.8, 55642.0];...% Q8
                            [55641.0, 55738.4];...% Q9
                            [55739.3, 55832.7];...% Q10
                            [55833.6, 55930.8]];   % Q11
  
            Quarter = find((quarterTable(:,1) < MJD) & (quarterTable(:,2) > MJD)) - 1;
            Month = ceil((MJD - quarterTable(Quarter + 1,1))/30);

        end

        %%********************************************************************************
        % Code source: JVC
        %  generate square pulse train for transit distortion studies and masking
        %  off known giant transits
        %INPUTS
        %  epoch    -- in MJD
        %  period   -- in days
        %  duration -- in days
        %  MJDs     -- list of MJDs
        %
        %OUTPUTS
        %  

        function transit_pulse_train = generate_transit_pulse_train(epoch, period, duration, MJDs)

            phase = mod((MJDs - epoch)/period + 0.5,1) - 0.5;
            phase_of_transit = 0.5*duration/period;
            transit_pulse_train = zeros(length(MJDs),1);
            transit_pulse_train(find(abs(phase) < phase_of_transit)) = -1;

        end

        %%********************************************************************************
        % function codeString = make_pdc_code_string(dataProcessingStruct)
        %
        % Creates a character string of code names for carious processing flags for PDC.
        %
        function codeString = make_pdc_code_string(dataProcessingStruct)

            codeString = '';
            if dataProcessingStruct.initialVariable, codeString = [codeString 'iV'];,end
            if dataProcessingStruct.finalVariable, codeString = [codeString 'fV'];,end
            if dataProcessingStruct.uncorrectedSystematics, codeString = [codeString 'uS'];,end
            if (isfield(dataProcessingStruct, 'uncorrectedSuspectedDiscontinuity'))
                if dataProcessingStruct.uncorrectedSuspectedDiscontinuity, codeString = [codeString 'uD'];,end
            end
            if dataProcessingStruct.harmonicsFitted, codeString = [codeString 'hF'];,end
            if dataProcessingStruct.harmonicsRestored, codeString = [codeString 'hR'];,end
            if dataProcessingStruct.mapUsed, codeString = [codeString 'mU'];,end
            if dataProcessingStruct.priorUsed, codeString = [codeString 'pU'];,end
            if dataProcessingStruct.discontinuitiesRemoved, codeString = [codeString 'dR'];,end

        end


        %%********************************************************************************
        % Searches a logical array and only keeps the logical trues that are adjacent to at least one other true.
        %
        function [logicalArray] = only_keep_clusters (logicalArray)

            nIndices = length(logicalArray);

            if (~islogical(logicalArray))
                error('pdcToolsClass.only_keep_clusters: logicalArray must be a logical array dummy!');
            end

            if (nIndices == 1)
                % Only one values, so it's not a cluster!
                logicalArray = false;
            end

            for i = 1 : nIndices
                if (logicalArray(i))
                    % Also include special check if this is the first or last index
                    if ((i == 1 || ~logicalArray(i-1)) && (i == nIndices || ~logicalArray(i+1)))
                        logicalArray(i) = false;
                    end
                end
            end
        end

        %***************************************************************************************************************
        % Searches a logical array and only keeps the trues that are periodic at the input period.
        %
        % This function does a very simply folding at the specified period. It then examines the logical array at this folding and only keeps the signals that
        % appear to be consistently flagged at this period.
        %
        % Inputs:
        %   logicalArray    -- [logical array]
        %   periodToKeep    -- [float] the period in datums to keep (probably always will be in cadences, but doesn't have to be!)

        function [logicalArray] = only_keep_periodic_signals (logicalArray, periodToKeep)

            RATIOCUTOFF = 0.75; % If 75% of the folded cadences are true then consider this a periodic signal

            if (~islogical(logicalArray))
                error('pdcToolsClass.only_keep_periodic_signals: logicalArray must be a logical array dummy!');
            end


            % In all likeilihood this will only be run on cadences to label as such
            nCadences = length(logicalArray);

            % This method only works if tyhere is more than one period per unit of work. If the period is too long then just return and do nothing.
            nPeriodsInArray = ceil(nCadences / periodToKeep);
            if (nPeriodsInArray < 2)
                % only a single event at most, no periodicity to observe
                return
            end

            % Fold time series at the period rounded to the nearest datum
            foldedArray = cell(nPeriodsInArray,1);
            for iPeriod = 0 : nPeriodsInArray-1
                % Have to round to the nearest cadence
                foldedArray{iPeriod+1} = logicalArray(round(1+iPeriod*periodToKeep):min(round((1+iPeriod)*periodToKeep),nCadences));
            end

            % Find cadences with most foldings are true
            periodToKeepRoundedUp = ceil(periodToKeep);
            cadenceSum = zeros(periodToKeepRoundedUp,1);
            cadenceTotal = zeros(periodToKeepRoundedUp,1);
            for iPeriod = 1 : nPeriodsInArray
                cadenceSum(1:length(foldedArray{iPeriod})) = cadenceSum(1:length(foldedArray{iPeriod})) + foldedArray{iPeriod};
                cadenceTotal(1:length(foldedArray{iPeriod})) = cadenceTotal(1:length(foldedArray{iPeriod})) + 1;
            end
            trueRatio = cadenceSum ./ cadenceTotal;

            aboveThreshold = false(periodToKeepRoundedUp,1);
            aboveThreshold(trueRatio>RATIOCUTOFF) = true;

            % Reform the logical array only with the period signal
            aboveThresholdExpanded = [];
            roundedPeriodToKeep = round(periodToKeep);
            roundOffErrorPerPeriod =  roundedPeriodToKeep - periodToKeep;
            roundOffError = roundOffErrorPerPeriod;
            for iPeriod = 1 : nPeriodsInArray
                % Since the period is not a integer number of cadences we need to round here in order to keep the expansion in syn with the full data length
                if (roundOffError > 0.5)
                    % One too many cadences
                    aboveThresholdExpanded = [aboveThresholdExpanded; aboveThreshold(1:roundedPeriodToKeep-1)];
                    roundOffError = roundOffError - 1;
                elseif (roundOffError < -0.5)
                    % One too few cadences
                    % Add in the extra cadence as a false
                    aboveThresholdExpanded = [aboveThresholdExpanded; aboveThreshold(1:roundedPeriodToKeep); false];
                    roundOffError = roundOffError + 1;
                else
                    aboveThresholdExpanded = [aboveThresholdExpanded; aboveThreshold(1:roundedPeriodToKeep)];
                end

                % Keep track of the round-off error
                roundOffError = roundOffError + roundOffErrorPerPeriod;
            end

            logicalArray = false(size(logicalArray));
            logicalArray(logical(aboveThresholdExpanded(1:length(logicalArray)))) = true;


        end


    end % static methods

end
