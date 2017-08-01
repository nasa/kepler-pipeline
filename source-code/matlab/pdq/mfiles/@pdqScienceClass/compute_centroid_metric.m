function [pdqOutputStruct] = compute_centroid_metric(pdqScienceObject, pdqOutputStruct, nModOuts, modOutsProcessed, raDec2PixObject)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function [pdqOutputStruct] = compute_centroid_metric(pdqScienceObject,
% pdqOutputStruct, nModOuts,raDec2PixObject)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%The centroid metric is calculated as follows:
%
% 1. Use the recently computed pointing to compute the predicted centroid row,
% column positions of target stars (use ra_dec_2_pix on ra, dec of stars)
%
% 2. Compute centroid row metric as the robust mean of predicted centroid
% row positions - measured centroid row positions (do likewise for centroid
% column metric)
%
% Output:
%     The following fields of pdqOutputStruct are modified:
%
%    .outputPdqTsData.pdqModuleOutputTsData(:).centroidsMeanRows
%    .outputPdqTsData.pdqModuleOutputTsData(:).centroidsMeanCols
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

attitudeSolution = pdqOutputStruct.attitudeSolution;
attitudeSolutionUncertaintyStruct = pdqOutputStruct.attitudeSolutionUncertaintyStruct;

fprintf('PDQ:extracting centroid rows, columns from %d pdqTempStruct for computing centroid metric...\n', nModOuts);

meanEeRadiusFromPrf = -ones(nModOuts,1);

for currentModOut = find(modOutsProcessed(:)')

    if(~modOutsProcessed(currentModOut))
        continue;
    end
    sFileName = ['pdqTempStruct_' num2str(currentModOut) '.mat'];

    % check to see the existence ofthe .mat file

    if(~exist(sFileName, 'file'))
        continue;
    end

    load(sFileName, 'pdqTempStruct');

    if(isfield(pdqTempStruct, 'eeRadiusFromPrf' ))
        eeRadiusFromPrf = pdqTempStruct.eeRadiusFromPrf;
        eeRadiusFromPrf = eeRadiusFromPrf(eeRadiusFromPrf>0);
        meanEeRadiusFromPrf(currentModOut)  = mean(eeRadiusFromPrf);
    end



    if (pdqScienceObject.pdqConfiguration.debugLevel)
        plot_target_pixels_and_centroids_frame(pdqTempStruct); % loads pdqTempStruct
    end


    % Find the indices into all stellar targets (if any) on this module/output
    targetIndices       = pdqTempStruct.targetIndices;

    % Check data available flag and return if sufficient data are not available
    % Test for absence of stellar targets and return
    if (isempty(targetIndices))
        % set -1 the metrics and their uncertainties for current cadences and concatenate to input
        % metrics, uncertainties respectively

        continue;
    end

    % Find out how many cadences and targets we are processing
    numCadences         = pdqTempStruct.numCadences;
    % Find the indices into all stellar targets (if any) on this module/output
    targetIndices       = pdqTempStruct.targetIndices;
    numTargets          = length(targetIndices);

    % Find out how many targets (if any) we are processing on this module/ouput
    % Do not compute centroid metric with less than 2 stellar targets

    % commenting out the following three lines per HC & JJ
    %if (numTargets < 2)
    %    continue;
    %end

    % star positions from catalogs
    raStars             = pdqTempStruct.raStars;
    decStars            = pdqTempStruct.decStars;


    % use the just obtained attitude solution instead

    raPointing          = attitudeSolution(:,1);
    decPointing         = attitudeSolution(:,2);
    rollPointing        = attitudeSolution(:,3);

    cadenceTimeStamps = pdqTempStruct.cadenceTimes;

    [ccdModule ccdOutput]       = convert_to_module_output(currentModOut);
    aberrateFlag                = 1; % default

    % predicted star positions (centroids {rp, cp}) for all cadences
    [predictedRows, predictedColumns, TpredRowsStruct, TpredColsStruct]  = ...
        get_predicted_star_positions_II(raDec2PixObject,ccdModule, ccdOutput, raStars, decStars,...
        cadenceTimeStamps, raPointing, decPointing, rollPointing, aberrateFlag);

    % predictedRows, predictedColumns have visible silicon as their
    % coordinate reference frame unlike reference pixels which have the entire silicon
    % (visible + collateral) as their coordinate frame - not true anymore
    % (3/19/2008)


    centroidRows = pdqTempStruct.centroidRows;
    centroidCols = pdqTempStruct.centroidCols;
    centroidRowUncertainties = pdqTempStruct.centroidRowUncertainties;
    centroidColumnUncertainties = pdqTempStruct.centroidColumnUncertainties;


    % Calculate mean centroid time series to be used by PDQ
    % Centroid results are now ready for tracking & trending
    % Read in perviously existing centroid time series


    centroidsRowMetric = zeros(numCadences,1);
    centroidsColumnMetric = zeros(numCadences,1);

    centroidsRowMetricUncertainties = zeros(numCadences,1);
    centroidsColumnMetricUncertainties = zeros(numCadences,1);

    for cadenceIndex = 1 : numCadences

         validIndices = find( min( centroidRows(:,cadenceIndex), ...
                                   predictedRows(:,cadenceIndex) ) > 0 ); % -1 indicates invalid centroid rows/columns

        %if( isempty(validIndices) || length(validIndices) < 2 ) % no targets
        if( isempty(validIndices) ) % no targets
            warning('PDQ:computeCentroidMetric:Notargets', ...
                ['CentroidMetric: Can''t compute centroid metric as no centroids are available for modout ' num2str(currentModOut) ' for cadence ' num2str(cadenceIndex)]);
            centroidsRowMetricUncertainties(cadenceIndex) = 0;
            centroidsRowMetric(cadenceIndex) = -1;
            centroidsColumnMetricUncertainties(cadenceIndex) = 0;
            centroidsColumnMetric(cadenceIndex) = -1;
            continue;

        end

        nValidTargets = length(validIndices);

        if(nValidTargets > 1)

            % use robust mean to filter out bad targets and bad centroids

            diffCentroidRows = centroidRows(validIndices, cadenceIndex) - predictedRows(validIndices, cadenceIndex);

            warning off all;
            [robustCentroidRowMetric, robustRowStats]  = robustfit(ones(nValidTargets,1),diffCentroidRows,[],[],0);
            warning on all;

            centroidsRowMetric(cadenceIndex)    = robustCentroidRowMetric;

            if( any(robustRowStats.w < eps))  % could easily check for 0;  == 0  is valid as robust fit sets the outlier weights to 0.

                badTargetsIndex = find(robustRowStats.w <= eps);
                warning('PDQ:computeCentroidMetric:centroidsRowMetric', ...
                    ['centroidsRowMetric:ignoring bad targets [' num2str(badTargetsIndex') '] on this module ' num2str(ccdModule) ' output ' num2str(ccdOutput)]);
            end

            nGoodRowTargets = length(find(robustRowStats.w > 0));
            TrobustRow = (robustRowStats.w)./nGoodRowTargets;

            diffCentroidCols = centroidCols(validIndices, cadenceIndex) - predictedColumns(validIndices, cadenceIndex);

            warning off all;
            [robustCentroidColumnMetric, robustColumnStats]  = robustfit(ones(nValidTargets,1),diffCentroidCols,[],[],0);
            warning on all;

            centroidsColumnMetric(cadenceIndex) = robustCentroidColumnMetric;

            if( any(robustColumnStats.w < eps))  % could easily check for 0;  == 0 is valid as robust fit sets the outlier weights to 0.

                badTargetsIndex = find(robustColumnStats.w <= eps);
                warning('PDQ:computeCentroidMetric:centroidsColumnMetric', ...
                    ['centroidsColumnMetric:ignoring bad targets [' num2str(badTargetsIndex') '] on this module ' num2str(ccdModule) ' output ' num2str(ccdOutput)]);
            end
            nGoodColTargets = length(find(robustColumnStats.w > 0));
            TrobustColumn = (robustColumnStats.w)./nGoodColTargets;

            % predicted rows have uncertainties associated with them
            TpointingToPredRows = TpredRowsStruct(cadenceIndex).TpointingToPredRows;
            TpointingToPredCols = TpredColsStruct(cadenceIndex).TpointingToPredCols;
            CdeltaAttitudes = attitudeSolutionUncertaintyStruct(cadenceIndex).CdeltaAttitudes;

            CpredRows = TpointingToPredRows * CdeltaAttitudes * TpointingToPredRows';
            CpredCols = TpointingToPredCols * CdeltaAttitudes * TpointingToPredCols';

            % keep only the rows/columns corresponding to validIndices
            CpredRows = CpredRows(validIndices,:);
            CpredRows = CpredRows(:,validIndices);

            CpredCols = CpredCols(validIndices,:);
            CpredCols = CpredCols(:,validIndices);


            % compute uncertainties on the weighted mean metric
            centroidsRowMetricUncertainties(cadenceIndex) = TrobustRow'*diag(diag(CpredRows) + (centroidRowUncertainties(validIndices, cadenceIndex).^2))*TrobustRow;


            centroidsRowMetricUncertainties(cadenceIndex) = sqrt(centroidsRowMetricUncertainties(cadenceIndex));

            centroidsColumnMetricUncertainties(cadenceIndex) = TrobustColumn' *diag(diag(CpredCols) + (centroidColumnUncertainties(validIndices, cadenceIndex).^2))*TrobustColumn;
            centroidsColumnMetricUncertainties(cadenceIndex) = sqrt(centroidsColumnMetricUncertainties(cadenceIndex));


        else


            diffCentroidRows = centroidRows(validIndices, cadenceIndex) - predictedRows(validIndices, cadenceIndex);


            centroidsRowMetric(cadenceIndex)    = diffCentroidRows;

            if( abs(diffCentroidRows) > 0.5)  % bad centroid

                warning('PDQ:computeCentroidMetric:centroidsRowMetric', ...
                    ['centroidsRowMetric:ignoring bad targets [' num2str(validIndices) '] on this module ' num2str(ccdModule) ' output ' num2str(ccdOutput)]);
            end


            diffCentroidCols = centroidCols(validIndices, cadenceIndex) - predictedColumns(validIndices, cadenceIndex);
            centroidsColumnMetric(cadenceIndex) = diffCentroidCols;

            if( abs(diffCentroidCols) > 0.5)  % bad centroid

                warning('PDQ:computeCentroidMetric:centroidsColumnMetric', ...
                    ['centroidsColumnMetric:ignoring bad targets [' num2str(validIndices) '] on this module ' num2str(ccdModule) ' output ' num2str(ccdOutput)]);
            end

            % predicted rows have uncertainties associated with them
            TpointingToPredRows = TpredRowsStruct(cadenceIndex).TpointingToPredRows;
            TpointingToPredCols = TpredColsStruct(cadenceIndex).TpointingToPredCols;
            CdeltaAttitudes = attitudeSolutionUncertaintyStruct(cadenceIndex).CdeltaAttitudes;

            CpredRows = TpointingToPredRows * CdeltaAttitudes * TpointingToPredRows';
            CpredCols = TpointingToPredCols * CdeltaAttitudes * TpointingToPredCols';

            % keep only the rows/columns corresponding to validIndices
            CpredRows = CpredRows(validIndices,:);
            CpredRows = CpredRows(:,validIndices);

            CpredCols = CpredCols(validIndices,:);
            CpredCols = CpredCols(:,validIndices);


            % compute uncertainties on the weighted mean metric
            centroidsRowMetricUncertainties(cadenceIndex) = diag(diag(CpredRows) + (centroidRowUncertainties(validIndices, cadenceIndex).^2));


            centroidsRowMetricUncertainties(cadenceIndex) = sqrt(centroidsRowMetricUncertainties(cadenceIndex));

            centroidsColumnMetricUncertainties(cadenceIndex) = diag(diag(CpredCols) + (centroidColumnUncertainties(validIndices, cadenceIndex).^2));
            centroidsColumnMetricUncertainties(cadenceIndex) = sqrt(centroidsColumnMetricUncertainties(cadenceIndex));


        end

        if(~isreal(centroidsRowMetricUncertainties(cadenceIndex)) || ~isreal(centroidsColumnMetricUncertainties(cadenceIndex)))
            error('PDQ:centroidMetric:Uncertainties', ...
                'Centroid metric: uncertainties are complex numbers');
        end


        if( any((centroidsRowMetricUncertainties(cadenceIndex)./abs(centroidsRowMetric(cadenceIndex)) ) > 1.0))
            warning('PDQ:computeCentroidMetric:centroidsRowMetricUncertainties', ...
                ['centroidsRowMetricUncertainties:centroidsRowMetricUncertainties >> centroidsRowMetric for cadence ' num2str(cadenceIndex)]);
            %    'centroidsRowMetricUncertainties:centroidsRowMetricUncertainties >> centroidsRowMetric; setting the metric to -1; ');
            %             centroidsRowMetricUncertainties(cadenceIndex) = 0;
            %             centroidsRowMetric(cadenceIndex) = -1;

        end

        if( any((centroidsColumnMetricUncertainties(cadenceIndex)./abs(centroidsColumnMetric(cadenceIndex)) ) > 1.0))
            warning('PDQ:computeCentroidMetric:centroidsColumnMetricUncertainties', ...
                ['centroidsColumnMetricUncertainties:centroidsColumnMetricUncertainties >> centroidsColumnMetric for cadence ' num2str(cadenceIndex)]);
            %    'centroidsColumnMetricUncertainties:centroidsColumnMetricUncertainties >> centroidsColumnMetric;setting the metric to -1  ');
            %             centroidsColumnMetricUncertainties(cadenceIndex) = 0;
            %             centroidsColumnMetric(cadenceIndex) = -1;
        end

    end


    centroidsMeanRows  = pdqScienceObject.inputPdqTsData.pdqModuleOutputTsData(currentModOut).centroidsMeanRows;
    centroidsMeanCols  = pdqScienceObject.inputPdqTsData.pdqModuleOutputTsData(currentModOut).centroidsMeanCols;

    if (isempty(centroidsMeanRows.values))

        centroidsMeanRows.values = centroidsRowMetric(:);

        centroidsMeanRows.uncertainties = centroidsRowMetricUncertainties(:);

        centroidsMeanRows.gapIndicators = false(length(centroidsRowMetric), 1);

        % set the gap indicators to true wherever the metric = -1;
        rowMetricGapIndex = find(centroidsRowMetric == -1);
        if(~isempty(rowMetricGapIndex))
            centroidsMeanRows.gapIndicators(rowMetricGapIndex) = true;
        end

    else

        centroidsMeanRows.values = [centroidsMeanRows.values(:); centroidsRowMetric(:)];

        centroidsMeanRows.uncertainties = [centroidsMeanRows.uncertainties(:); centroidsRowMetricUncertainties(:)];

        rowGapIndicators = false(length(centroidsRowMetric),1);

        % set the gap indicators to true wherever the metric = -1;
        % set the gap indicators to true wherever the metric = -1;
        rowMetricGapIndex = find(centroidsRowMetric == -1);
        if(~isempty(rowMetricGapIndex))
            rowGapIndicators(rowMetricGapIndex) = true;
        end

        centroidsMeanRows.gapIndicators = [centroidsMeanRows.gapIndicators(:); rowGapIndicators(:)];

        % Sort time series using the time stamps as a guide
        [allTimes sortedTimeSeriesIndices] = ...
            sort([pdqScienceObject.inputPdqTsData.cadenceTimes(:); ...
            pdqScienceObject.cadenceTimes(:)]);

        centroidsMeanRows.values = centroidsMeanRows.values(sortedTimeSeriesIndices);
        centroidsMeanRows.uncertainties = centroidsMeanRows.uncertainties(sortedTimeSeriesIndices);
        centroidsMeanRows.gapIndicators = centroidsMeanRows.gapIndicators(sortedTimeSeriesIndices);
    end

    if (isempty(centroidsMeanCols.values))

        centroidsMeanCols.values = centroidsColumnMetric(:);
        centroidsMeanCols.uncertainties = centroidsColumnMetricUncertainties(:);
        centroidsMeanCols.gapIndicators = false(length(centroidsColumnMetric),1);

        colMetricGapIndex = find(centroidsColumnMetric == -1);

        if(~isempty(colMetricGapIndex))
            centroidsMeanCols.gapIndicators(colMetricGapIndex) = true;
        end
    else

        centroidsMeanCols.values = [centroidsMeanCols.values(:); centroidsColumnMetric(:)];
        centroidsMeanCols.uncertainties = [centroidsMeanCols.uncertainties(:); centroidsColumnMetricUncertainties(:)];
        colGapIndicators = false(length(centroidsColumnMetric),1);

        colMetricGapIndex = find(centroidsColumnMetric == -1);
        if(~isempty(colMetricGapIndex))
            colGapIndicators(colMetricGapIndex) = true;
        end

        centroidsMeanCols.gapIndicators = [centroidsMeanCols.gapIndicators(:); colGapIndicators(:)];

        % Sort time series using the time stamps as a guide
        [allTimes sortedTimeSeriesIndices] = ...
            sort([pdqScienceObject.inputPdqTsData.cadenceTimes(:); ...
            pdqScienceObject.cadenceTimes(:)]);

        centroidsMeanCols.values = centroidsMeanCols.values(sortedTimeSeriesIndices);
        centroidsMeanCols.uncertainties = centroidsMeanCols.uncertainties(sortedTimeSeriesIndices);
        centroidsMeanCols.gapIndicators = centroidsMeanCols.gapIndicators(sortedTimeSeriesIndices);

    end

    % Copy centroid results to output structure
    pdqOutputStruct.outputPdqTsData.pdqModuleOutputTsData(currentModOut).centroidsMeanRows = centroidsMeanRows;
    pdqOutputStruct.outputPdqTsData.pdqModuleOutputTsData(currentModOut).centroidsMeanCols = centroidsMeanCols;

end

save meanEeRadiusFromPrf.mat meanEeRadiusFromPrf;

return


