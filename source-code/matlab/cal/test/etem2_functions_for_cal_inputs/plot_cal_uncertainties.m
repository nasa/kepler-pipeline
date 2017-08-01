function [meanPropUnc, sdPropUnc, empiricalUnc, expectedFractionalSD] = plot_cal_uncertainties(calOutputStruct, fieldName, varargin)
%
% function [meanPropUnc, sdPropUnc, empiricalUnc, expectedFractionalSD] = plot_cal_uncertainties(calOutputStruct, fieldName, varargin)
%
% This function plots the mean uncertainties as propagated through the CAL transformations from primitive uncertainty estimates and the empirical
% uncertainties estimated as the standard deviation of the mean value data across cadences as a function of the mean of the mean value data across 
% cadences. The mean uncertainties and the empirical uncertainties are returned as vectors. The input parameter "fieldName" defines which
% timeseries to access in the calOutputStruct.
% e.g. plot_cal_uncertainties(calPhotometricOutput,'targetAndBackgroundPixels');
%
% INPUT:    calOutputStruct      = output structure from cal_matlab_controller.m; struct
%           fieldname            = field name containing time series to plot; string
%           varargin             = {1} = expectedFractionalSD == standard deviation of the standard deviation of nCadences Monte Carlo runs drawn
%                                        from a unit variance Normal distribution. This is what the standard deviation of the uncertainty residuals
%                                        will be compared to. 
%                                  e.g. Based on 1e5 Monte Carlo runs.
%                                   For nCadences = 100, expectedFractionalSD = 0.071058
%                                   For nCadences = 200, expectedFractionalSD = 0.050052
%                                   For nCadences = 500, expectedFractionalSD = 0.031704
%                                   For nCadences = 3000, expectedFractionalSD = 0.012944
%                                  If varagin is empty, the expected FractionlSD is generated within this function using a Monte Carlo simulation where the 
%                                  number of Monte Carlo runs is defined by the constant numMonteCarloInstances (1e6, default)
%
% OUTPUT:   meanPropUnc          = propagated uncertainty for each pixel index averaged across cadences; [nIndices x 1], double
%           sdPropUnc            = standard deviation of propagated uncertainty for each pixel index across cadences; [nIndices x 1], double
%           empiricalUnc         = inperical uncertainty for each pixel index based on Monte Carlo of pixel values across cadences; [nIndices x 1], double
%           expectedFractionalSD = standard deviation of the standard deviation of numMonteCarloInstances Monte Carlo runs drawn from
%                                  a unit standard deviation normal distribution. This is the expected value for
%                                  std((empiricalUnc - meanPropUnc)./meanPropUnc)
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

numMonteCarloInstances = 1e4;       % s/b >=1e4. Set to lower value if running out of memory or if more speed is needed.

if(ispc)
    positionVector = [600 100 1000 800];
else
    positionVector = [800 200 1000 1000];
end

P = find_sub_struct(calOutputStruct, fieldName );

if(isfield(P,'values') && ~isempty(P(1).values))
    
    valueArray = [P.values];
    uncertaintyArray = [P.uncertainties];
    gapArray = [P.gapIndicators];
    
    [numCadences, numIndices] = size(valueArray); 
    
     
    % compile statistics along cadences dimension (1==rows)
    meanValues      = mean(valueArray,1);
    empiricalUnc    = std( valueArray,1);
    meanPropUnc     = mean(uncertaintyArray,1);
    sdPropUnc       = std( uncertaintyArray,1);
    
    
    % compensate for gaps
    gaps = false(size(gapArray,2),1);
    
    if(any(any(gapArray)))
        for j=1:numIndices
            if(all(gapArray(:,j)))
                gaps(j)=true;
            else        
                meanValues(j)   = mean(valueArray(~gapArray(:,j),j),1);
                empiricalUnc(j) = std( valueArray(~gapArray(:,j),j),1);
                meanPropUnc(j)  = mean(uncertaintyArray(~gapArray(:,j),j),1);
                sdPropUnc(j)    = std( uncertaintyArray(~gapArray(:,j),j),1);
            end
        end
    end        
    
    meanValues      = meanValues(~gaps);
    empiricalUnc    = empiricalUnc(~gaps);
    meanPropUnc     = meanPropUnc(~gaps);
    sdPropUnc       = sdPropUnc(~gaps);
    
else
    disp(['No data for ',fieldName]);
    empiricalUnc = [];
    meanPropUnc = [];
    sdPropUnc = [];
    return;
end

clear valueArray uncertaintyArray gapArray

if(~isempty(varargin))
    expectedFractionalSD = varargin{1};
else
    expectedFractionalSD = std(std(randn(numCadences,numMonteCarloInstances)));
end

L = length(meanValues);

if( L~=0 && length(empiricalUnc) == L && length(meanPropUnc) == L )
    
    % don't calculate ratio with zero valued empirical uncertainties
    nonzeroIndices = find(meanPropUnc~=0);
    
    normalizedUncertaintyDifference = ...
        (meanPropUnc(nonzeroIndices) - empiricalUnc(nonzeroIndices) )./ empiricalUnc(nonzeroIndices);
    
    figure;
    set(gcf,'Name',fieldName);
    set(gcf,'NumberTitle','off');
    set(gcf,'Position',positionVector);
    
    subplot(2,2,1);
    plot( meanValues, empiricalUnc,'b.',...
          meanValues, meanPropUnc, 'r.');
    grid;
    title('\bfUncertainty vs Mean Value');
    xlabel('mean value');
    ylabel('uncertainty');
    legend('empirical','propagated',2);
    
    subplot(2,2,2);
    plot( meanValues(nonzeroIndices), normalizedUncertaintyDifference, '.');
    grid;
    title('\bfNormalized Residual Uncertainties vs Mean Value');
    xlabel('mean value');
    ylabel('normalized residual');
    
    meanNormUncDiff = mean(normalizedUncertaintyDifference);
    stdNormUncDiff = std(normalizedUncertaintyDifference);
    
%     inlierIdx = find(abs(normalizedUncertaintyDifference-meanNormUncDiff)<1*stdNormUncDiff);
%     
%     meanNormUncDiff = mean(normalizedUncertaintyDifference(inlierIdx));
%     stdNormUncDiff = std(normalizedUncertaintyDifference(inlierIdx));
    
    
    
    subplot(2,2,3);
    histfit( normalizedUncertaintyDifference, 101);
    grid;
    title('\bfResidual Uncertainties Distribution - Fit to Normal');
    xlabel('normalized residual');
    ylabel('occurances');
    

   
    
    subplot(2,2,4);
    text(.1,.9,['\fontsize{12}\bfmeasured mean    = ',num2str(meanNormUncDiff)]);    
    text(.1,.8,['\fontsize{12}measured width   = ',num2str(2 * stdNormUncDiff)]);
    text(.1,.7,['\fontsize{12}expected width   = ',num2str(2 * expectedFractionalSD)]);    
    text(.1,.6,['\fontsize{12}width difference = ',num2str(2 *  (stdNormUncDiff - expectedFractionalSD) )]);
    text(.1,.5,['\fontsize{12}\bffractional width difference = ',...
        num2str((stdNormUncDiff - expectedFractionalSD)/expectedFractionalSD)]);    
    
    disp(['Data Product: ',fieldName]);
    disp(['measured distribution mean  = ',num2str(meanNormUncDiff)]);
    disp(['measured distribution width = ',num2str(2 * stdNormUncDiff)]);
    disp(['expected distribution width = ',num2str(2 * expectedFractionalSD)]);    
    disp(['        absolute difference = ',num2str(2 * (stdNormUncDiff - expectedFractionalSD) )]);
    disp(['      fractional difference = ',num2str((stdNormUncDiff - expectedFractionalSD)/expectedFractionalSD)]);
    disp(' ');
    
end
