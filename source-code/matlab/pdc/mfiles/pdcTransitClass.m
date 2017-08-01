%% classdef pdcTransitClass
%
% Contains methods to construct transits from epoch, period and duration data. Used to gap the transit cadences so that SPSD and outliers don't corrupt known
% transits.
%
% The data is stored in PDC with the following struct:
% 
% pdcInputsStruct.targetDataStruct(:).transits(:)
%
%   'id'                 -- e.g. 901.01 (if this is a KOI) Or something else if it's an eclipsing binary.
%   'eclipsingBinary'       -- flag if is eclipsing binary
%   'epoch'                 -- in BKJD (MJD = BKJD + 54832.5)
%   'period'                -- in days
%   'duration'              -- in hours
%   'transitGapIndicators'  -- the masking cadences for each transit
%
% If the target has no transits then targetDataStruct.transits = []
%
% pdcTransitClass.find_transit_gaps then finds the cadences that should be gapped as:
%
% targetDataStruct(:).transits(:).transitGapIndicators := logical array of length nCadences
% 
% The gap Indicators are just for each KOI. So for targets with multiple KOIs one must take the union of the multiple transitGapIndicator arrays. This is
% acheived with the function pdcTransitClass.find_cumulative_transit_gaps.
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

classdef pdcTransitClass

    %***************************************************************************************************************
    %***************************************************************************************************************
    %***************************************************************************************************************
    %% Static Methods

    methods (Static=true)
        %***************************************************************************************************************
        %
        % flags transits using two methods:
        %
        %   1) for KOIs:
        %       Takes the epoch period and duration for each KOI and finds the cadences needed to gap the targets including an expansion factor to fill past the
        %       transit.
        %
        %   2) for Eclipsing binaries:
        %       Takes the epoch period and duration for each EB and finds the cadences needed to gap the targets including an expansion factor to fill past the
        %       transit. This list is assumed to be included in the KOI list from above.
        %
        %   3) OLD obsolete method (NOT USED):
        %       Uses identify_giant_transits to fidn the transits (since no KOI information necessarily exists). It then remove any single cadence flags (which
        %       are outliers) and then only preserves the periodic signals found with identify_giant_transits.
        %
        % Inputs:
        %   cadenceTimes                -- [cadenceTimesStruct]
        %   targetDataStruct            -- [targetDataStruct] targetDataStruct(:).transits(:) coontains the input transit information
        %   
        %
        % Outputs:
        %   targetDataStruct(:).transits(:).transitGapIndicators -- [logical array(nCadences)] the cadences about each transit
        %   TargetsWithAllCadencesInTransit         -- [logical array(nTargets)] True if all cadences are gapped due to the transit information
        %
        %***************************************************************************************************************

        function [targetDataStruct, TargetsWithAllCadencesInTransit] = find_transit_gaps(cadenceTimes, targetDataStruct)

            TRANSITEXPANSIONFACTOR = 0.5; % How much past the transit to gap (in units of duration)

            nTargets = length(targetDataStruct);
            TargetsWithAllCadencesInTransit = false(length(targetDataStruct));

            % Find the epochs in MJD
            % The conversion is MJD = BKJD + 54832.5
            % Ignores the Barycentric correction of a couple minutes. We are gapping an extra tranit duration on either side so the small correction is
            % insignificant.
            % Also convert time units of period and duration to minutes
            % Compute the median cadence duration in minutes 
            for iTarget = 1 : nTargets

                % If the transit field doesn't exists for any targets the assume none should exist.
                if (~isfield(targetDataStruct(iTarget), 'transits'))
                    targetDataStruct(iTarget).transits = [];
                    continue;
                end

                for iKoi = 1 : length(targetDataStruct(iTarget).transits)
                    
                    % Convert epoch from BKJD to MJD
                    mjdEpoch    = targetDataStruct(iTarget).transits(iKoi).epoch + 54832.5;
                    mjdPeriod   = targetDataStruct(iTarget).transits(iKoi).period;
                    mjdDuration = targetDataStruct(iTarget).transits(iKoi).duration * get_unit_conversion('hour2day');
                    
                    % If any of epoch period or duration does not exist (isnan) then skip this transit
                    % We need all three to locate the transits
                    if (any(isnan(mjdEpoch) | isnan(mjdPeriod) | isnan(mjdDuration)))
                        targetDataStruct(iTarget).transits(iKoi).transitGapIndicators = false(size(cadenceTimes.gapIndicators));
                        continue;
                    end

                    % Find the cadences to gap
                    % Epoch defined as middle of transit
                    
                    % Find the time range for the first transit within the cadence times of the PDC unit of work
                    firstNonGappedCadenceIndex = find(~cadenceTimes.gapIndicators, 1, 'first');
                    lastNonGappedCadenceIndex  = find(~cadenceTimes.gapIndicators, 1, 'last');
                    firstTransitIndex = ceil((cadenceTimes.midTimestamps(firstNonGappedCadenceIndex) - mjdEpoch) / mjdPeriod);
                    lastTransitIndex  = floor((cadenceTimes.midTimestamps(lastNonGappedCadenceIndex) - mjdEpoch) / mjdPeriod);
                    nTransits = lastTransitIndex - firstTransitIndex + 1;
                    % Gap each transit within the cadence range for this unit of work (quarter or month)
                    targetDataStruct(iTarget).transits(iKoi).transitGapIndicators = false(size(cadenceTimes.gapIndicators));
                    for iTransit = 1 : nTransits
                        midTransitTime = mjdEpoch + mjdPeriod * (firstTransitIndex+iTransit-1);
                        firstGappedCadenceTime = midTransitTime -  mjdDuration * (0.5 + TRANSITEXPANSIONFACTOR);
                        lastGappedCadenceTime  = midTransitTime +  mjdDuration * (0.5 + TRANSITEXPANSIONFACTOR);
                    
                        %***
                        % Find the cadence indices that are within the gap range
                        addTheseGaps = cadenceTimes.midTimestamps >= firstGappedCadenceTime & ...
                                                         cadenceTimes.midTimestamps <= lastGappedCadenceTime;
                        targetDataStruct(iTarget).transits(iKoi).transitGapIndicators = targetDataStruct(iTarget).transits(iKoi).transitGapIndicators | addTheseGaps;
                    
                        % Add in the already gapped cadences within the transit range
                        firstCadenceIndex = find(addTheseGaps, 1, 'first');
                        lastCadenceIndex  = find(addTheseGaps, 1, 'last');
                        targetDataStruct(iTarget).transits(iKoi).transitGapIndicators(firstCadenceIndex:lastCadenceIndex) = true;
                    end
                end
            end

            % Check for fully gapped targets
            transitGapIndicators = pdcTransitClass.find_cumulative_transit_gaps (targetDataStruct);
            TargetsWithAllCadencesInTransit = all(transitGapIndicators);


        end

        %***************************************************************************************************************
        % Plot the transit gaps for testing
        function [] = plot_transit_gaps(targetDataStruct)
            figure;
            for iTarget = 1 : length(targetDataStruct)

                for iKoi = 1 : length(targetDataStruct(iTarget).transits)
                    % Nan gaps
                    gaps = targetDataStruct(iTarget).gapIndicators;
                    temp = targetDataStruct(iTarget).values;
                    temp(gaps) = NaN;
                    plot(temp, '-b')
                    hold on
                    transitGapsButNotTargetGaps = find(targetDataStruct(iTarget).transits(iKoi).transitGapIndicators & ...
                                                            ~targetDataStruct(iTarget).gapIndicators);
                    plot(transitGapsButNotTargetGaps, temp(transitGapsButNotTargetGaps), '*r');
                    if (targetDataStruct(iTarget).transits(iKoi).eclipsingBinary)
                        title(['Eclipsing Binary : ', num2str(targetDataStruct(iTarget).transits(iKoi).id),'; Kepler ID ', num2str(targetDataStruct(iTarget).keplerId), '; Transit gaps'])
                    elseif(~isempty(targetDataStruct(iTarget).transits(iKoi).id))
                        title(['KOI: ', num2str(targetDataStruct(iTarget).transits(iKoi).id), '; Kepler ID ', num2str(targetDataStruct(iTarget).keplerId), '; Transit gaps'])
                    else
                        title(['Neither EB or KOI; Kepler ID ', num2str(targetDataStruct(iTarget).keplerId), '; Transit gaps'])
                    end
                    xlabel('Cadence Index');
                    ylabel('Flux [e-/cadence]');
                    hold off;
                    pause;
                end
            end

        end


        %***************************************************************************************************************
        % KOI information can also be in inputsStruct.transit for testing purposes. This function will distribute the KOI information from this struct into each
        % targetDataStruct.
        function [targetDataStruct] = distribute_transits (transitInputStruct, targetDataStruct)

            transitStruct = struct ('id', [], ...
                                    'epoch', [], ... % in Jason Time (BJD - 2454900)
                                    'period', [], ... % in days
                                    'duration', []);   % in hours

            % Distribute the KOIs
            % Do not do any unit conversions, just pass into each targetDataStruct
            for iTarget = 1 : length(targetDataStruct)
                transitsForThisTarget = find([transitInputStruct.keplerId] == targetDataStruct(iTarget).keplerId);
                if (any(transitsForThisTarget))
                    % If the transits field already exists in the targetDataStruct then truncate the added list to it
                    if (isfield(targetDataStruct(iTarget), 'transits') && ~isempty(targetDataStruct(iTarget).transits))
                        startingIndex = length(targetDataStruct(iTarget).transits);
                    else
                        % Does not exist so create
                        targetDataStruct(iTarget).transits = repmat(transitStruct, [length(transitsForThisTarget),1]);
                        startingIndex = 1;
                    end

                    transitIndexToDistribute = 1;
                    for iTransit = startingIndex : length(transitsForThisTarget) + startingIndex - 1
                        targetDataStruct(iTarget).transits(iTransit).id   = transitInputStruct(transitsForThisTarget(transitIndexToDistribute)).id;
                        targetDataStruct(iTarget).transits(iTransit).eclipsingBinary = ...
                                        transitInputStruct(transitsForThisTarget(transitIndexToDistribute)).eclipsingBinary;
                        % Convert from Jason Time to BKJD
                        % JasonTime = BKJD - 67
                        targetDataStruct(iTarget).transits(iTransit).epoch    = transitInputStruct(transitsForThisTarget(transitIndexToDistribute)).epoch + 67;
                        targetDataStruct(iTarget).transits(iTransit).period   = transitInputStruct(transitsForThisTarget(transitIndexToDistribute)).period;
                        targetDataStruct(iTarget).transits(iTransit).duration = transitInputStruct(transitsForThisTarget(transitIndexToDistribute)).duration;
                        transitIndexToDistribute = transitIndexToDistribute + 1;
                    end
                elseif (~isfield(targetDataStruct(iTarget), 'transits'))
                    targetDataStruct(iTarget).transits = [];
                end
            end
        end

        %***************************************************************************************************************
        % Creates a single gapIndicator array for the cumulative gapping for each transit data for each target
        %
        % targetDataStruct(iTarget).transits(:) is an array for each eclipsing binary and KOI for each target. This function will return a single gapIndicator
        % logical array where all the transit type gaps are combined into one.
        %
        % NOTE: pdcTransitClass.find_transit_gaps must already be called before this function otherwise a crash will occur
        %   TODO: protect from crash
        %
        %
        % Inputs:
        %   targetDataStruct    -- [struct] the targets with listed transits
        %   iTarget             -- [int(Optional)] specific target to generate gaps for if empty or not present then generate matrix for all targets
        %
        % Outputs:
        %   cummulativeTransitGapIndicators -- [logical array/matrix] array if for one target, logical matrix if for all targets
        %

        function [cummulativeTransitGapIndicators] = find_cumulative_transit_gaps (targetDataStruct, varargin)

            nTargets = length(targetDataStruct);

            if (~isempty(varargin))
                % Specific target has been request with optional input
                if (length(varargin) > 2)
                    error ('find_cumulative_transit_gaps: only one optional argument permitted')
                end
                % varargin only passes doubles!?
                iTarget = varargin{1};
                if (~isnumeric(iTarget) || iTarget < 0 || iTarget > nTargets || iTarget ~= floor(iTarget))
                    error('find_cumulative_transit_gaps: invalid target index');
                end

                cummulativeTransitGapIndicators = false(length(targetDataStruct(iTarget).values),1);

                % If targetDataStruct(iTarget).transits is empty then there are no KOIs or EBs
                if (isfield(targetDataStruct(iTarget), 'transits'))
                    for iKoi = 1 : length(targetDataStruct(iTarget).transits)
                        % If transitGapIndicators is not present then the gaps haven't been computed yet and this will crash
                        cummulativeTransitGapIndicators = cummulativeTransitGapIndicators | targetDataStruct(iTarget).transits(iKoi).transitGapIndicators;
                    end
                end
            else

                cummulativeTransitGapIndicators = false(length(targetDataStruct(1).values), nTargets);
             
                for iTarget = 1 : nTargets
             
                    % If transits is empty then there are no KOIs or EBs
                    if (isfield(targetDataStruct(iTarget), 'transits'))
                        for iKoi = 1 : length(targetDataStruct(iTarget).transits)
                            cummulativeTransitGapIndicators(:,iTarget) = ...
                                cummulativeTransitGapIndicators(:,iTarget) | targetDataStruct(iTarget).transits(iKoi).transitGapIndicators;
                        end
                    end
                end
            end

        end

        %***************************************************************************************************************
        % 
        % Add some extra gaps on either side of each identified gap.
        %
        % Inputs:
        %   logicalArray     -- [logical array] the gap indicators
        %   nPaddingCadences -- [int] number of extra cadences on either side of each gap to also gap
        %
        % Outputs:
        %   paddedLogicalArray  -- [logical array] the padded logical array!
        %
        function paddedLogicalArray = pad_giant_transits (logicalArray, nPaddingCadences)

            nIndices = length(logicalArray);

            if (~islogical(logicalArray))
                error('pdcTransitClass:pad_giant_transits: logicalArray must be a logical array dummy!');
            end

            if (nIndices < nPaddingCadences*2)
                % Such a short data length, no padding!
                return;
            end

            paddedLogicalArray = logicalArray;
            for i = 1 : nIndices
                if (logicalArray(i))
                    % Include special check if this is near the beginnign or end of the array
                    if (i <= nPaddingCadences)
                        paddedLogicalArray(1:i+nPaddingCadences) = true;
                    elseif(i + nPaddingCadences > nIndices)
                        paddedLogicalArray(i-nPaddingCadences:end) = true;
                    else
                        paddedLogicalArray(i-nPaddingCadences:i+nPaddingCadences) = true;
                    end
                end
            end
        end
                    
        %***************************************************************************************************************
        % This function generate a new light curve that has transits removed using the gap filler
        %
        % NOTE: this function assumes the inputs targetDataStruct already has gaps filled.
        %
        % On the rare occasion that all cadences are flagged as in transit then we cannot remove the transits. Skip such targets.
        %
        % Inputs:
        %   targetDataStruct                -- [targetDataStruct] gap filled targetDataStruct
        %   gapFilledCadenceMidTimestamps   -- [float array(nCadences)] gap fille midTimeStamps (filled from pdc_fill_gaps)
        %
        % Outputs:
        %   transitRemovedValues            -- [float matrix(nCadences x nTargets)] the transit removed flux (using pchip)
        %

        function [transitRemovedValues] = create_transit_removed_flux_values (targetDataStruct, gapFilledCadenceMidTimestamps)

            % Identify the transit gaps for all targets
            transitGapIndicators = pdcTransitClass.find_cumulative_transit_gaps (targetDataStruct);
            TargetsWithAllCadencesInTransit = all(transitGapIndicators);

            % Populate transitRemovedValues with the original flux (gaps filled)
            transitRemovedValues = [targetDataStruct.values];
             
            for iTarget = 1 : length(targetDataStruct)
                
                % Skip targets that do not have any transits to fill
                if (~any(transitGapIndicators(:,iTarget)))
                    continue;
                end

                % Skip targets that are fully in transits
                if (TargetsWithAllCadencesInTransit(iTarget))
                    continue;
                end
             
                % Also, need at leat two valid data points for interp1 to work. 
                if (length(gapFilledCadenceMidTimestamps(~transitGapIndicators(:,iTarget)))<2)
                    continue;
                end

                % Interpolate through each transit
                transitRemovedValues(transitGapIndicators(:,iTarget), iTarget) = ...
                        interp1(gapFilledCadenceMidTimestamps(~transitGapIndicators(:,iTarget)), ...
                                    targetDataStruct(iTarget).values(~transitGapIndicators(:,iTarget)), ...
                                        gapFilledCadenceMidTimestamps(transitGapIndicators(:,iTarget)), 'pchip');
             
                % Check if we need to extrapolate flux value filling. If so, use a linear nearest-neighbor interpolator (pchip does not work well for extrapolation)
                if (transitGapIndicators(1,iTarget))
                    % find first non-gap
                    firstNonGap = find(~transitGapIndicators(:,iTarget),1 , 'first');
                    transitRemovedValues(1:firstNonGap-1, iTarget) = ...
                            interp1(gapFilledCadenceMidTimestamps(~transitGapIndicators(:,iTarget)), ...
                                targetDataStruct(iTarget).values(~transitGapIndicators(:,iTarget)), ...
                                    gapFilledCadenceMidTimestamps(1:firstNonGap-1), 'nearest', 'extrap');
                end
                if(transitGapIndicators(end,iTarget))
                    % find last non-gap
                    lastNonGap = find(~transitGapIndicators(:,iTarget),1 , 'last');
                    transitRemovedValues(lastNonGap+1:end, iTarget) = ...
                            interp1(gapFilledCadenceMidTimestamps(~transitGapIndicators(:,iTarget)), ...
                                targetDataStruct(iTarget).values(~transitGapIndicators(:,iTarget)), ...
                                    gapFilledCadenceMidTimestamps(lastNonGap+1:end), 'nearest', 'extrap');
                end
            end
        end

        %***************************************************************************************************************
        % 
        % Creates a logical array with eclipsing binaries flagged as true.
        %
        % Inputs:
        %   targetDataStruct        -- containing transits information
        %   useHardCatalogAsBackup  -- older taks files do not have the eclipsingBinary flag so use hard-coded catalog as backup
        %
        % Outputs:
        %   ebHere                  -- [logiucal array(nTarget)]
        %   

        function [ebHere] = identify_eclipsing_binaries (targetDataStruct, useHardCatalogAsBackup)

            ebHere = false(length(targetDataStruct),1);
            for iTarget = 1 : length(targetDataStruct)
                if (~isempty(targetDataStruct(iTarget).transits))
                    ebHere(iTarget) = any([targetDataStruct(iTarget).transits(:).eclipsingBinary]);
                end
            end

            % If there are no found eclipsing binaries then this could be a test run with old data where the eclipsing binary flag is not available
            if(~isdeployed && ~any(ebHere ))
                ebCatalog = load_eclipsing_binary_catalog;
                ebHere = ismember([targetDataStruct.keplerId], ebCatalog(:,1));
            end
        end

        %***************************************************************************************************************
        %
        % This will take the inputsStruct and examine the declared transits.
        %
        % Inputs:
        %   inputsStruct    -- the inputs and loaded from pdc-inputs-0.mat
        %
        % Outputs:
        %   NONE, just figures
        %
        function [] = test_transits_in_inputsStruct (inputsStruct)

            % If using channelDataStruct then process this inputsStruct
            inputsStruct = pdcInputClass.process_channelDataStruct (inputsStruct);

            % Find the transit gaps from this fresh inputsStruct
            targetDataStruct = pdcTransitClass.find_transit_gaps (inputsStruct.cadenceTimes, inputsStruct.targetDataStruct);

            % plot the included transits
            pdcTransitClass.plot_transit_gaps (targetDataStruct);
        end

        %*************************************************************
        % This is to test the pdcTransitClass with a short collection of known transits for when the list is not available in pdc-inputs-0.mat
        %
        % Or... to add test transits to the list
        
        function [pdcInputStruct] = create_test_transit_struct (pdcInputStruct)
        
            transitStruct = struct('id', [], ...
                                'eclipsingBinary', [], ... % Eclipsing Binary
                                'keplerId', [], ...
                                'epoch', [], ... % in Jason Time (BJD - 2454900)
                                'period', [], ... % in days
                                'duration', []); % in hours
            
            % Just use a sample of known KOIs from Jason Rowe spreadsheet
            
            % Two large transits one on 7.3 Q10 the other,... not
            
            nKois = 11;
            
            transits = repmat(transitStruct, [nKois,1]);
            
            
            transits(1).id   = 188;
            transits(1).eclipsingBinary     = false;
            transits(1).keplerId = 5357901;
            transits(1).epoch    = 66.50811;
            transits(1).period   = 3.797017;
            transits(1).duration = 2.2378;
            
            transits(2).id   = 1546;
            transits(2).eclipsingBinary     = false;
            transits(2).keplerId = 5475431;
            transits(2).epoch    = 66.93756;
            transits(2).period   = 0.917547;
            transits(2).duration = 1.7196;
            
            % 3 KOIs around one target on mod.out 7.3 for Q10;
            
            transits(3).id   = 829.01;
            transits(3).eclipsingBinary     = false;
            transits(3).keplerId = 5358241;
            transits(3).epoch    = 107.77608;
            transits(3).period   = 18.648952;
            transits(3).duration = 4.0291;
            
            transits(4).id   = 829.02;
            transits(4).eclipsingBinary     = false;
            transits(4).keplerId = 5358241;
            transits(4).epoch    = 71.78461;
            transits(4).period   = 9.751928;
            transits(4).duration = 4.0291;
         
            transits(5).id   = 829.03;
            transits(5).eclipsingBinary     = false;
            transits(5).keplerId = 5358241;
            transits(5).epoch    = 96.84816;
            transits(5).period   = 38.558306;
            transits(5).duration = 5.0162;
            
            % Examples of outliers detected during transits
            
            % Q9 15.3
            transits(6).id   = 144.01;
            transits(6).eclipsingBinary     = false;
            transits(6).keplerId = 4180280;
            transits(6).epoch    = 66.08948;
            transits(6).period   = 4.176260;
            transits(6).duration = 3.6210;
            
            % Q9 12.2
            transits(7).id   = 115.01;
            transits(7).eclipsingBinary     = false;
            transits(7).keplerId = 9579641;
            transits(7).epoch    = 66.14237;
            transits(7).period   = 5.412201;
            transits(7).duration = 2.8202;
            
            % Q9 12.2
            transits(8).id   = 115.02;
            transits(8).eclipsingBinary     = false;
            transits(8).keplerId = 9579641;
            transits(8).epoch    = 72.00315;
            transits(8).period   = 7.125967;
            transits(8).duration = 2.8255;
            
            % Q9 12.2
            transits(9).id   = 115.03;
            transits(9).eclipsingBinary     = false;
            transits(9).keplerId = 9579641;
            transits(9).epoch    = 65.65736;
            transits(9).period   = 3.435844;
            transits(9).duration = 2.6142;
            
            % An eclipsing binary in Q10 2.1
            
            %transits(6).id   = [];
            %transits(6).eclipsingBinary     = true;
            %transits(6).keplerId = 3339538;
            %transits(6).epoch    = 73.474603;
            %transits(6).period   = 14.658044;
            %transits(6).duration = 3.0;
            
            % Here is a known EB that is not in the test Hammer file being used, so add it explicitely here.
            % Primary 
            transits(10).id   = 10480952;
            transits(10).eclipsingBinary     = true;
            transits(10).keplerId = 10480952;
            transits(10).epoch    = 121.8642 - 67 - 0.5108; % Convert to Jason time, includes mystery error of 0.6130 in the epoch
            transits(10).period   = 4.074906;
            transits(10).duration = 4.8899;;
            % Secondary
            transits(11).id   = 10480952;
            transits(11).eclipsingBinary     = true;
            transits(11).keplerId = 10480952;
            transits(11).epoch    = 123.9017 - 67 - 0.5108;
            transits(11).period   = 4.074906;
            transits(11).duration = 4.5476;

            %**
            pdcInputStruct.transits = transits;

        end
        
    end % static methods
        
        
                        
end % classdef pdcTransitClass
        
        

        
        
        
