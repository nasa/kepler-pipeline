function [motionConfigurationStruct, rowAic, columnAic] = ...
select_motion_polynomial_orders(centroidRows, centroidRowUncertainties, ...
centroidColumns, centroidColumnUncertainties, gapArray, targetRa, targetDec, ...
motionConfigurationStruct)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function [motionConfigurationStruct, rowAic, columnAic] = ...
% select_motion_polynomial_orders(centroidRows, centroidRowUncertainties, ...
% centroidColumns, centroidColumnUncertainties, gapArray, targetRa, targetDec, ...
% motionConfigurationStruct)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Use Akaike Informtion Criterion (AIC) to select the optimal order for the
% row and column motion polynomials. These are the fits of row and column
% centroids to the target right ascensions and declinations. RA and DEC are
% both specified in units of degrees.
%
% 12/2/1020
% Formerly:
% AIC was implemented by stepping through the fit order starting from order
% zero and stopping when a local minima was determined (i.e. looking for the
% first increase in the AIC metric) or the maximum order was reached. AIC
% was computed for all cadences at each model order and the effective AIC
% metric for each model order was determined from the median AIC over
% cadences.
% Currently:
% AIC for a decimated set of cadences is determined for each model order,
% zero through maximum order. The order which gives the minimum AIC metric
% is determined for each cadence and the mode of this set of model orders
% is selected as optimal for the full (undecimated) data set. Also, the AIC
% metric is calculated using a robust estimate of the number of data points
% (sum of the robust weights from robustFit) rather than simply the integer
% count of the number of data points.
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


% Get the fit maximum order and decimation factor
aicDecimationFactor = motionConfigurationStruct.aicDecimationFactor;
fitMaxOrder         = motionConfigurationStruct.fitMaxOrder;

% Decimate incoming data over cadences.
centroidRows                = centroidRows(1:aicDecimationFactor:end,:);
centroidRowUncertainties    = centroidRowUncertainties(1:aicDecimationFactor:end,:);
centroidColumns             = centroidColumns(1:aicDecimationFactor:end,:);
centroidColumnUncertainties = centroidColumnUncertainties(1:aicDecimationFactor:end,:);
gapArray                    = gapArray(1:aicDecimationFactor:end,:);

% Initialize the AIC results for the row and column polynomials.
nCadences   = size(gapArray,1);
rowAic      = nan(nCadences,fitMaxOrder + 1);
columnAic   = nan(nCadences,fitMaxOrder + 1);

% Use AIC over a decimated set of cadences to determine optimal motion
% polynomial orders. Select the mode of the optimal order per cadence as
% the optimal order for the full (undeciamted) data set. Throw an error if
% the motion polynomials cannot even be computed for the zero order.
for order = 0 : fitMaxOrder

    nParams = (order + 1) * (order + 2) / 2;
    
    motionConfigurationStruct.rowFitOrder = order;
    motionConfigurationStruct.columnFitOrder = order;
    
    [rowMotionCoeffStruct, columnMotionCoeffStruct,...
        motionGapIndicators, rowChiSquare,...
        nRowCentroids, columnChiSquare,...
        nColumnCentroids, rowRobustWeightArray,...
        columnRobustWeightArray] = ...
                                    fit_motion_polynomials_by_cadence(centroidRows, centroidRowUncertainties, ...
                                                                        centroidColumns, centroidColumnUncertainties,...
                                                                        targetRa, targetDec, ...  
                                                                        gapArray, motionConfigurationStruct);

    % update gapIndicators
    motionGapIndicators = motionGapIndicators | nParams >= nRowCentroids - 1 | nParams >= nColumnCentroids - 1;
    
    % stop fitting if all gapped - throw error if order == 0
    if all(motionGapIndicators)
        if 0 == order 
            error('Common:selectMotionPolynomialOrders:invalidFit', ...
                'Unable to fit motion polynomials for any cadence')
        else
            break;
        end
    end

    
    % Calculate AIC for all cadences.
    % Use robust estimate of the number of data points
    warning off all;    
    robustNumRowCentroids = sum(rowRobustWeightArray,2);    
    aicForRowCentroids = robustNumRowCentroids .* ...
        (log((2 * pi) * rowChiSquare ./ robustNumRowCentroids) + 1) + ...
        2 * nParams * (nParams + 1) ./ (robustNumRowCentroids - nParams - 1);    
    rowAic(:,order + 1) = aicForRowCentroids;
    
    robustNumColumnCentroids = sum(columnRobustWeightArray,2);    
    aicForColumnCentroids = robustNumColumnCentroids .* ...
        (log((2 * pi) * columnChiSquare ./ robustNumColumnCentroids) + 1) + ...
        2 * nParams * (nParams + 1) ./ (robustNumColumnCentroids - nParams - 1);    
    columnAic(:,order + 1) = aicForColumnCentroids;
    warning on all;
    
end % for

% Set the optimum row and column motion polynomial fit orders as the mode
% of the cadence by cadence optimal order
[dummy, iMinRowAic] = min(rowAic,[],2);                                                                                     %#ok<*ASGLU>
motionConfigurationStruct.rowFitOrder = mode(iMinRowAic) - 1;
[dummy, iMinColumnAic] = min(columnAic,[],2);
motionConfigurationStruct.columnFitOrder = mode(iMinColumnAic) - 1;

% collapse row and column aic arrays into median vector across cadences to
% be returned for use in diagnostic plots
rowAic = nanmedian(rowAic);
columnAic = nanmedian(columnAic);

% Return.
return
