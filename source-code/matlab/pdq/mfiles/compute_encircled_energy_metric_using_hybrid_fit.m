function pdqTempStruct = compute_encircled_energy_metric_using_hybrid_fit(pdqTempStruct)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function pdqTempStruct = compute_encircled_energy_metric_using_hybrid_fit(pdqTempStruct)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% This function computes the encircled energy  metric defined as the
% distance in pixels at which fluxFraction percent of the energy is
% enclosed. The estimate is based on a erf fit to the cumulative
% flux sorted as a function of radius.
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
maxFzeroIterations          = pdqTempStruct.maxFzeroIterations;

numCadences                 = pdqTempStruct.numCadences;
targetIndices               = pdqTempStruct.targetIndices;


% Find out how many targets (if any) we are processing on this module/ouput
numTargets      = length(targetIndices);


centroidRows    = pdqTempStruct.centroidRows;
centroidCols    = pdqTempStruct.centroidCols;

numPixels       = pdqTempStruct.numPixels;

% Module parameters
fluxFraction                = pdqTempStruct.eeFluxFraction;
eePixelsOnlyFlag            = true;


module                      = pdqTempStruct.ccdModule;
output                      = pdqTempStruct.ccdOutput;
currentModOut               = pdqTempStruct.currentModOut;

% Generate encircled energy metric for track & trend & bounds check
encircledEnergies               = zeros(numCadences, 1);
encircledEnergiesUncertainties  = zeros(numCadences, 1);
encircledEnergiesBestPolyOrder  = zeros(numCadences, 1);

[nPixels, nPixels]  = size(pdqTempStruct.targetPixelsUncertaintyStruct(1).CtargetPixels);

debugLevel = pdqTempStruct.debugLevel;

if(debugLevel)
    hmesh = figure(1);
    hee = figure(2);

end


for cadenceIndex = 1 : numCadences


    CcumRelativeFlux1   = zeros(nPixels-numTargets,nPixels-numTargets);
    TcumRelativeFlux    = zeros(nPixels-numTargets,nPixels-numTargets);

    % Get values corresponding to this cadence
    cenRow          = centroidRows(:, cadenceIndex);
    cenCol          = centroidCols(:, cadenceIndex);


    sortedDistancesToCentroid  = zeros(sum(numPixels),1);
    cumulativeRelativeFluxes   = zeros(sum(numPixels),1);

    indexBegin = 1;

    targetsWithValidCentroids = find(cenRow ~= -1);

    if(isempty(targetsWithValidCentroids))

        warning('PDQ:encircledEnergyMetric:noValidCentroids', ...
            ['Can''t compute encircled energy metric as no valid centroids are available for cadence ' num2str(cadenceIndex)]);
        encircledEnergiesUncertainties(cadenceIndex) = -1;
        encircledEnergies(cadenceIndex) = -1;
        encircledEnergiesBestPolyOrder(cadenceIndex)  = -1;
        continue;


    end

    for j = 1:length(targetsWithValidCentroids)


        [targetPixelFluxes, CtargetPixel, targetRows, targetColumns] = ...
            extract_target_pixels_and_uncertainties(pdqTempStruct, cadenceIndex, targetsWithValidCentroids(j),eePixelsOnlyFlag);

% RLM 2/16/11 -- commented due to error calling mesh() with empty matrices
%         if(debugLevel)
%             set(0,'CurrentFigure',hmesh);
%             rows = targetRows;
%             cols = targetColumns;
% 
%             % meshplot for a visual check
%             minRow = min(rows);
%             maxRow = max(rows);
%             nUniqueRows = maxRow - minRow +1;
%             minCol = min(cols);
%             maxCol = max(cols);
%             nUniqueCols = maxCol - minCol +1;
% 
%             X = repmat((minRow:maxRow)',1, nUniqueCols);
%             Y = repmat((minCol:maxCol), nUniqueRows,1);
% 
%             Z = zeros(size(X));
%             idx = sub2ind(size(X), rows-minRow+1,cols-minCol+1);
%             %                Z(idx) = psfValueAtPixel;
%             Z(idx) = targetPixelFluxes;
%             mesh(X,Y,Z);
%         end




        % Determine number of pixels for this target
        numTargetPixels = length(targetPixelFluxes);

        % RLM 2/16/11 -- added:
        if numTargetPixels < 1
           continue; 
        end
        
        % determine the distance of each pixel from the centroid value
        distancesToCentroid = sqrt( (targetRows - repmat(cenRow(targetsWithValidCentroids(j)),[numTargetPixels,1])).^2 ...
            + (targetColumns - repmat(cenCol(targetsWithValidCentroids(j)),[numTargetPixels,1])).^2 );

        % sort the pixels by distance from the centroid
        [sortedCentroidDistances, sortedIndices] = sort(distancesToCentroid);

        % get fractional cumulative flux
        cumFluxes = cumsum(targetPixelFluxes(sortedIndices)) ./ sum(targetPixelFluxes);


        % the last element in this vector is 1 and the corresponding
        % cumulative flux is 1; both elements are not used in the fit as
        % they don't contain any useful information (JJ)
        sortedCentroidDistances = sortedCentroidDistances(1:end-1);

        % next target's  beginning index
        indexEnd = indexBegin + numTargetPixels - 2;


        sortedDistancesToCentroid(indexBegin:indexEnd)  = sortedCentroidDistances;
        cumulativeRelativeFluxes(indexBegin:indexEnd)   = cumFluxes(1:end-1);



        % JJ
        % cumulative flux F(i) = sum(Pi)/sum(Pj), 1<= i <= M, 1<=j<=N, N =
        % total number of pixels ----> eqn(1)
        % dF(i)/dPk = (1/sum(Pj))*U(i-k)  - sum(Pi)/(sum(Pj)^2 ----> eqn(2),
        % where U is the step function and i, j are as defined in eqn(1).
        % This is the chain rule for obtaining the derivative of functions
        % of the form u(x)/v(x).lengt
        % The transformation TpixelsToCumFlux is defined as follows:

        %                         _
        %                         |  dF(1)/dP1   dF(1)/dP2 ..... dF(1)/dPN  ]
        %     TpixelsToCumFlux =  |                                         |
        %                         |  dF(2)/dP1    dF(2)/dP2                 |
        %                         |                                         |
        %                         [                                         ]
        %
        % From eqn(2) we can see that TpixelsToCumFlux is made up of two
        % terms: the first term is a lower triangular matrix, second term
        % is a matrix in which each row is contains the same term (a
        % constant vector)




        term1 = tril(ones(numTargetPixels),0)*1/sum(targetPixelFluxes);

        term2 = repmat(cumFluxes./sum(targetPixelFluxes),1,numTargetPixels);



        TpixelsToCumFlux = term1-term2;

        % remove the last row and column (corresponding to removing last
        % element in sortedCentroidDistances and cumFluxes - otherwise
        % the last row in TpixelsToCumFlux is all zeros leading to problems
        % in chisquare fit
        TpixelsToCumFlux = TpixelsToCumFlux(1:end-1,1:end-1);


        CtargetPixelsSorted = CtargetPixel(sortedIndices, sortedIndices);


        CpixelCumSum = CtargetPixelsSorted';


        % remove the last row and column;
        CpixelCumSum = CpixelCumSum(1:end-1,1:end-1);


        CcumRelativeFlux1(indexBegin:indexEnd,indexBegin:indexEnd) = CpixelCumSum;
        TcumRelativeFlux(indexBegin:indexEnd,indexBegin:indexEnd) = TpixelsToCumFlux;

        indexBegin = indexEnd+1;


    end

    % remove extra elements
    sortedDistancesToCentroid(indexBegin:end)  = [];
    maxSortedDistancesToCentroid = max(sortedDistancesToCentroid);


    % normalize with the same max radius size
    sortedDistancesToCentroid = sortedDistancesToCentroid./maxSortedDistancesToCentroid;


    cumulativeRelativeFluxes(indexBegin:end)   = [];

    CcumRelativeFlux1(indexBegin:end,:) = [];
    CcumRelativeFlux1(:, indexBegin:end) = [];

    TcumRelativeFlux(indexBegin:end,:) = [];
    TcumRelativeFlux(:, indexBegin:end) = [];

    CcumRelativeFlux = TcumRelativeFlux*CcumRelativeFlux1*TcumRelativeFlux';

    % sort the centroids once again
    [sortedDistancesToCentroid, newSortOrder] = sort(sortedDistancesToCentroid);

    CcumRelativeFlux = CcumRelativeFlux(newSortOrder, newSortOrder);

    cumulativeRelativeFluxes = cumulativeRelativeFluxes(newSortOrder);






    %================new=============================================
    CcumRelativeFlux = double(single(CcumRelativeFlux));

    try

        [V, errorFlag] = factor_covariance_matrix(CcumRelativeFlux);

        if errorFlag < 0 % => T = []
            %  not a valid covariance matrix.
            warning('PDQ:encircledEnergyMetric:invalidCcumRelativeFlux', ...
                'factor_covariance_matrix fails for cadence %d ', cadenceIndex );
            encircledEnergiesUncertainties(cadenceIndex) = -1;
            encircledEnergies(cadenceIndex) = -1;
            encircledEnergiesBestPolyOrder(cadenceIndex)  = -1;
            continue;
        end

    catch

        errorThrown = lasterror;
        disp(errorThrown.stack(1))

        warning('PDQ:encircledEnergyMetric:invalidCcumRelativeFlux', ...
            'factor_covariance_matrix fails for cadence %d ', cadenceIndex );

        encircledEnergiesUncertainties(cadenceIndex) = -1;
        encircledEnergies(cadenceIndex) = -1;
        encircledEnergiesBestPolyOrder(cadenceIndex)  = -1;
        continue;

    end
    % V = V';
    Vinv = inv(V);

    %======================================
    % undo premultiplying by Vinv temporarily
    %======================================

    V = eye(size(V));
    Vinv = eye(size(Vinv));
    %======================================

    guessAlpha = [1 0];
    %guessAlpha = 1;


    scaledCumulativeRelativeFluxes = Vinv*cumulativeRelativeFluxes;

    %    hybridModelFun = @(alpha,c0,c1,c2, x) (Vinv*(erf_modified(alpha, x)+ c0.*ones(length(x),1) + c1.*x + c2.*x.^2));
    hybridModelFun = @(alpha, x) (Vinv*(erf_modified(alpha, x)));


    nlinfitOptions = statset('Robust', 'off', 'TolX',1e-20, 'Display', 'off');% do not remove TolX, Jacobian has one column = 0
    warning  off all;
    [beta,rw,Jw,covBeta, mse, robustWeights]   = ...
        kepler_nonlinear_fit(sortedDistancesToCentroid, scaledCumulativeRelativeFluxes,  hybridModelFun, guessAlpha, nlinfitOptions);


    %-----------------------------------------------------------------------
    % now get the distance (solution) at which we reach the encircled energy
    % fraction
    %-----------------------------------------------------------------------


    f =  @(x) erf_modified(beta, x) - fluxFraction;

    %         Exiting fzero: aborting search for an interval containing a sign change
    %             because NaN or Inf function value encountered during search.
    %         (Function value at -2.58615e+037 is -Inf.)
    %         Check function or try again with a different starting value.

    xAtFluxFraction = 0;
    %trialSolution = 0.99;

    fSquared = @(x) f(x).^2;

    trialSolution = fminbnd(fSquared, sortedDistancesToCentroid(1), sortedDistancesToCentroid(end) );


    iterationsCounter = 0;
    failureToConverge = true;
    while (xAtFluxFraction >= 1.0 || xAtFluxFraction <= 0)
        xAtFluxFraction = fzero(f,trialSolution );
        trialSolution = trialSolution/2;

        if(trialSolution < 1e-12)
            trialSolution = 1 - 0.5*rand(1,1);
        end;

        iterationsCounter = iterationsCounter + 1;

        if(iterationsCounter > maxFzeroIterations)
            break;
        end;
        failureToConverge = false;

    end

    if (failureToConverge)
        encircledEnergies(cadenceIndex) = -1;
        encircledEnergiesUncertainties(cadenceIndex) = -1;
        encircledEnergiesBestPolyOrder(cadenceIndex)  = -1;
        continue;
    end

    encircledEnergies(cadenceIndex) = xAtFluxFraction;

    % rescale it back to pixel units
    encircledEnergies(cadenceIndex) = xAtFluxFraction * maxSortedDistancesToCentroid;





    %-----------------------------------------------------------------------
    % plots
    %-----------------------------------------------------------------------

    if(debugLevel)
        nFigColumns = 2;
        nFigRows = min(round(numCadences/nFigColumns),2); % don't need more then 4 plots

        set(0,'CurrentFigure',hee);

        figureNumber = mod(cadenceIndex, nFigRows*nFigColumns);
        if(figureNumber == 0)
            figureNumber = nFigRows*nFigColumns;
        end

        subplot(nFigRows, nFigColumns,figureNumber);
        set(gca, 'fontSize', 7);


        h1 = plot(sortedDistancesToCentroid*maxSortedDistancesToCentroid, cumulativeRelativeFluxes,'bo');
        hold on;
        h2 = plot(sortedDistancesToCentroid*maxSortedDistancesToCentroid, erf_modified(beta, sortedDistancesToCentroid),'rp-');
        plot([xAtFluxFraction,xAtFluxFraction]*maxSortedDistancesToCentroid, [0,1.1], 'color', 'g');
        plot([0, 6], [fluxFraction,fluxFraction],  'color', 'g');

        text(xAtFluxFraction*maxSortedDistancesToCentroid,1.1, ['[' num2str(xAtFluxFraction*maxSortedDistancesToCentroid), ', ' num2str(fluxFraction) ']'], 'fontsize',8);
        grid;

        fprintf('');
        %legend([h1 h2], {'data'; 'fit using constrained polynomial';}, 0);
        legend([h1 h2], {'data'; 'logistic+polynomial fit'}, 'Location', 'Best');

        xlabel('distances to centroid in pixels');
        ylabel('normalized encircled energy');
        title({'logistic+polynomial fit of encircled energy';
            'vs. distances to centroid';
            ['module ' num2str(module) ' output ', num2str(output), ' cadence ' , num2str(cadenceIndex)]});

        hold off;
        if(cadenceIndex == numCadences)
            set(0,'CurrentFigure',hee);
            drawnow
            fileNameStr = ['encircled_energy_cumulative_flux_module_'  num2str(module) '_output_', num2str(output)  '_modout_' num2str(currentModOut) ];

            paperOrientationFlag = true;
            includeTimeFlag = false;
            printJpgFlag = false;

            % add figure caption as user data
            plotCaption = strcat(...
                'In this plot, cumulative normalized targets'' pixel fluxes (encircled energy) are plotted as a \n',...
                'function of the normalized distance from the centroid. Also plotted is a constrained polynomial fit \n',...
                'to the data. This plot serves to illustrate how well or how poorly the constrained fit approximates the data\n',...
                'Click on the link to open the figure in Matlab to examine the pixels closely. \n');

            set(hee, 'UserData', sprintf(plotCaption));

            plot_to_file(fileNameStr, paperOrientationFlag, includeTimeFlag, printJpgFlag);
        end
    end

    %-----------------------------------------------------------------------
    % perform propagation of uncertainties
    %-----------------------------------------------------------------------

    [value, c1, c2, c3, logisticFit, polyFit] = erf_modified(beta, sortedDistancesToCentroid);
    x = xAtFluxFraction;

    derivativeOfYwrtX = 2*beta(1)*( exp(-beta(1)*x)./(1+exp(-beta(1)*x)).^2) + c1*ones(length(x),1) + 2*c2 *x + 3*c3 *x.^2;

    derivativeOfXwrtY = 1./derivativeOfYwrtX;




    derivativeOfYwrtCoeffts = [2*x*exp(-beta(1)*x)./(1+exp(-beta(1)*x)).^2  x-2*x.^2+x.^3]';

    T = derivativeOfXwrtY*derivativeOfYwrtCoeffts;

    encircledEnergiesUncertainties(cadenceIndex) = (sqrt(T'*covBeta*T))*maxSortedDistancesToCentroid;

    if(isnan(encircledEnergiesUncertainties(cadenceIndex)))
        warning('PDQ:encircledEnergyMetric:Uncertainties', ...
            'Encircled energy metric uncertainties: are NaNs');
        encircledEnergiesUncertainties(cadenceIndex) = -1;
        %encircledEnergies(cadenceIndex) = -1;
    end


    if(~isreal(encircledEnergiesUncertainties(cadenceIndex)))
        warning('PDQ:encircledEnergyMetric:Uncertainties', ...
            'Encircled energy metric: uncertainties are complex numbers');
        encircledEnergiesUncertainties(cadenceIndex) = -1;
        %encircledEnergies(cadenceIndex) = -1;

    end


    if(encircledEnergiesUncertainties(cadenceIndex)/encircledEnergies(cadenceIndex)  > 1.0)

        warning('PDQ:encircledEnergyMetric:invalidEncircledEnergyMetric', ...
            'encircledEnergiesUncertainties(%d)./encircledEnergies(%d) > 1.0 for cadence %d ', cadenceIndex,cadenceIndex, cadenceIndex );

        encircledEnergiesUncertainties(cadenceIndex) = -1;
        %encircledEnergies(cadenceIndex) = -1;
        continue;
    end
    if(encircledEnergies(cadenceIndex) >= 9.0)

        warning('PDQ:encircledEnergyMetric:invalidEncircledEnergyMetric', ...
            'encircledEnergies(%d) >= 9 pixels for cadence %d ', cadenceIndex,cadenceIndex, cadenceIndex );

        encircledEnergiesUncertainties(cadenceIndex) = -1;
        encircledEnergies(cadenceIndex) = -1;
        continue;
    end


end

disp([encircledEnergies,encircledEnergiesUncertainties])

pdqTempStruct.encircledEnergies = encircledEnergies;
pdqTempStruct.encircledEnergiesUncertainties = encircledEnergiesUncertainties;



warning on all;
% validate outputs here....
close all;



return

function [value, c1, c2, c3, logisticFit, polyFit] = erf_modified(guessAlpha, x)

% value = erf(alpha*x);

alpha = guessAlpha(1);

c1 = guessAlpha(2);

numerator = 1 - exp(-alpha*x);
denominator = 1 + exp(-alpha*x);

%logisticFit = K*(numerator./denominator);
logisticFit = (numerator./denominator);


% apply the 3 conditions
% at x= 0, f(x) = 0
% at x = 1, f(x) = 1;
% at x = 1, df/dx = 0


logisticAt1 = (1 - exp(-alpha))/(1 + exp(-alpha)); % at x = 1;

derivativeOfLogisticAt1 = 2*alpha*exp(-alpha)/(1+exp(-alpha))^2;

c3 = -derivativeOfLogisticAt1 + c1 - 2 + 2*logisticAt1;
c2 = 1 - logisticAt1 - c1 - c3;

polyFit = c1*x + c2*x.^2 + c3*x.^3;

%value = logisticFit(:) + (1-K)*polyFit(:);
value = logisticFit(:) + polyFit(:);

return
