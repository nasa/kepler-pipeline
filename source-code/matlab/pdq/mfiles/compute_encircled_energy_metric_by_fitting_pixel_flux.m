function pdqTempStruct = compute_encircled_energy_metric_by_fitting_pixel_flux(pdqTempStruct)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function pdqTempStruct = compute_encircled_energy_metric(pdqTempStruct)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% This function computes the encircled energy  metric defined as the
% distance in pixels at which fluxFraction percent of the energy is
% enclosed. The estimate is based on a polynomial fit to the normalized
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
encircledEnergyPolyOrderMax = pdqTempStruct.encircledEnergyPolyOrderMax;
numCadences                 = pdqTempStruct.numCadences;
targetIndices               = pdqTempStruct.targetIndices;

module                      = pdqTempStruct.ccdModule;
output                      = pdqTempStruct.ccdOutput;
currentModOut               = pdqTempStruct.currentModOut;



centroidRows    = pdqTempStruct.centroidRows;
centroidCols    = pdqTempStruct.centroidCols;

numPixels       = pdqTempStruct.numPixels;


% Module parameters
fluxFraction                = pdqTempStruct.eeFluxFraction;
eePixelsOnlyFlag            = true;


% Generate encircled energy metric for track & trend & bounds check
encircledEnergies               = zeros(numCadences, 1);
encircledEnergiesUncertainties  = zeros(numCadences, 1);
encircledEnergiesBestPolyOrder  = zeros(numCadences, 1);

[nPixels, nPixels]  = size(pdqTempStruct.targetPixelsUncertaintyStruct(1).CtargetPixels);

debugLevel = pdqTempStruct.debugLevel;
if(debugLevel)
    hmesh = figure(1);
    hee = figure(2);
    hcumflux = figure(3);

end

for cadenceIndex = 1 : numCadences

    CnormalizedFlux1   = zeros(nPixels,nPixels);
    TnormalizedFlux    = zeros(nPixels,nPixels);

    % Get values corresponding to this cadence
    cenRow          = centroidRows(:, cadenceIndex);
    cenCol          = centroidCols(:, cadenceIndex);


    sortedDistancesToCentroid  = zeros(sum(numPixels),1);

    % needed for plotting cumulative fluxes
    cumulativeRelativeFluxes   = zeros(sum(numPixels),1);

    normalizedFluxes   = zeros(sum(numPixels),1);

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

        if(isempty(targetRows)) % target gapped perhaps!
            continue;
        end


        if(debugLevel)
            set(0,'CurrentFigure',hmesh);

            rows = targetRows;
            cols = targetColumns;

            % meshplot for a visual check
            minRow = min(rows);
            maxRow = max(rows);
            nUniqueRows = maxRow - minRow +1;
            minCol = min(cols);
            maxCol = max(cols);
            nUniqueCols = maxCol - minCol +1;

            X = repmat((minRow:maxRow)',1, nUniqueCols);
            Y = repmat((minCol:maxCol), nUniqueRows,1);

            Z = zeros(size(X));
            idx = sub2ind(size(X), rows -minRow+1,cols-minCol+1);
            %                Z(idx) = psfValueAtPixel;
            Z(idx) = targetPixelFluxes;
            mesh(X,Y,Z);
        end


        % Determine number of pixels for this target
        numTargetPixels = length(targetPixelFluxes);

        % determine the distance of each pixel from the centroid value
        distancesToCentroid = sqrt( (targetRows - repmat(cenRow(targetsWithValidCentroids(j)),[numTargetPixels,1])).^2 ...
            + (targetColumns - repmat(cenCol(targetsWithValidCentroids(j)),[numTargetPixels,1])).^2 );

        % sort the pixels by distance from the centroid
        [sortedCentroidDistances, sortedIndices] = sort(distancesToCentroid);

        % get fractional cumulative flux for plotting
        cumFluxes = cumsum(targetPixelFluxes(sortedIndices)) ./ sum(targetPixelFluxes);

        % next target's  beginning index
        indexEnd = indexBegin + numTargetPixels - 1;


        sortedDistancesToCentroid(indexBegin:indexEnd)  = sortedCentroidDistances;

        % needed for plotting cumulative fluxes
        cumulativeRelativeFluxes(indexBegin:indexEnd)   = cumFluxes;


        scalingFactor = sum(targetPixelFluxes);
        normalizedFluxes(indexBegin:indexEnd)   = targetPixelFluxes(sortedIndices)./scalingFactor;

        TpixelsToNormalizedFlux = (1/scalingFactor) * eye(numTargetPixels, numTargetPixels);

        CtargetPixelsSorted = CtargetPixel(sortedIndices, sortedIndices);

        CnormalizedFlux1(indexBegin:indexEnd,indexBegin:indexEnd) = CtargetPixelsSorted;
        TnormalizedFlux(indexBegin:indexEnd,indexBegin:indexEnd) = TpixelsToNormalizedFlux;

        indexBegin = indexEnd+1;


    end

    % remove extra elements
    sortedDistancesToCentroid(indexBegin:end)  = [];
    maxSortedDistancesToCentroid = max(sortedDistancesToCentroid);


    % normalize with the same max radius size
    sortedDistancesToCentroid = sortedDistancesToCentroid./maxSortedDistancesToCentroid;


    normalizedFluxes(indexBegin:end)   = [];

    CnormalizedFlux1(indexBegin:end,:) = [];
    CnormalizedFlux1(:, indexBegin:end) = [];

    TnormalizedFlux(indexBegin:end,:) = [];
    TnormalizedFlux(:, indexBegin:end) = [];


    CnormalizedFlux = TnormalizedFlux*CnormalizedFlux1*TnormalizedFlux';

    if(isempty(CnormalizedFlux))

        warning('PDQ:encircledEnergyMetric:noValidCnormalizedFlux', ...
            ['Can''t compute encircled energy metric as the covariance matrix of normalized flux is empty for cadence ' num2str(cadenceIndex)]);
        encircledEnergiesUncertainties(cadenceIndex) = -1;
        encircledEnergies(cadenceIndex) = -1;
        encircledEnergiesBestPolyOrder(cadenceIndex)  = -1;
        continue;


    end


    % sort the centroids once again
    [sortedDistancesToCentroid, newSortOrder] = sort(sortedDistancesToCentroid);

    
    CnormalizedFlux = CnormalizedFlux(newSortOrder, newSortOrder);
    
%    CnormalizedFlux = eye(size(CnormalizedFlux));

    normalizedFluxes = normalizedFluxes(newSortOrder);

    % used for plotting only
    cumulativeRelativeFluxes = cumulativeRelativeFluxes(newSortOrder);

    % fit constrained polynomial
    % constraints are: (1) p(x)|x=1 = 1 (2) p(x)|x=0 = 0 (3) p'(x)|x=1 = 0
    % fit polynomials such that the derivative p'(x) can be modeled as K*x*g(x) where g(x) = (x-1)*q(x), where K is the constant
    % used to normalize the integral obtained as the values of integral(x*g(x)) evaluated at x = 1;


    multTerm = (sortedDistancesToCentroid - 1); % a column vector
    addTerm = 0;

    % determine the best polynomial order for q(x)
    criterionAIC        = zeros(encircledEnergyPolyOrderMax,1);

    y = normalizedFluxes - addTerm;

    warning off all;

    mse = zeros(encircledEnergyPolyOrderMax,1);
    for jPolyOrder = 0:encircledEnergyPolyOrderMax

        A = weighted_design_matrix(sortedDistancesToCentroid, 1, jPolyOrder, 'standard');
        % multiply each column of A with vector multTerm
        A = scalecol( multTerm, A);

        lastwarn('');


        [qPolyCoeffts, stdErrors, mse(jPolyOrder+1)] = lscov(A, y, CnormalizedFlux);

        %plot(sortedDistancesToCentroid,y+addTerm,'x', sortedDistancesToCentroid,A*qPolyCoeffts+addTerm)

        msgstr = lastwarn;

        if(~isempty(msgstr)|| mse(jPolyOrder+1) < 0)

            if(jPolyOrder > 0)
                criterionAIC = criterionAIC(1:jPolyOrder);
            else
                criterionAIC = [];
            end
            break;
        end


        rcondA = rcond(A'*A);
        if rcondA<eps*10
            % condition too poor to continue
            break
        end

        meanSquareError = mse(jPolyOrder+1);

        K = length(qPolyCoeffts);
        n = length(y);

        % criterionAIC(jPolyOrder+1) = 2*K + n*log(meanSquareError) + 2*K*(K+1)/(n-K-1);
        % same as the previous statement
        criterionAIC(jPolyOrder+1) = n*log(meanSquareError) + (2*K*n)/(n-K-1);

    end

    if(isempty(criterionAIC))
        encircledEnergiesUncertainties(cadenceIndex) = -1;
        encircledEnergiesBestPolyOrder(cadenceIndex)  = -1;
        encircledEnergies(cadenceIndex)  = -1;
        continue;
    end

    warning on all;

    criterionAIC = criterionAIC(1:jPolyOrder);

    [minChangeInMSE, kneeIndexPolyOrder] =   max(diff(criterionAIC));

    [minAIC bestPolyOrder] = min(criterionAIC);
    bestPolyOrder = min(bestPolyOrder, kneeIndexPolyOrder);

    bestPolyOrder = bestPolyOrder - 1;

    encircledEnergiesBestPolyOrder(cadenceIndex)  = bestPolyOrder;


    A = weighted_design_matrix(sortedDistancesToCentroid, 1, bestPolyOrder, 'standard');
    % multiply each column of A with vector multTerm
    A = scalecol( multTerm, A);

    % assume the covariance matrix of y is known only up to a scale factor

    [qPolyCoeffts, stdErrors, mse, CeePolyFit] = lscov(A, y,  CnormalizedFlux );



    y1 = A*qPolyCoeffts  + addTerm;

    %=========================

    if(debugLevel)
        nFigColumns = 2;
        nFigRows = min(round(numCadences/nFigColumns),2); % don't need more then 4 plots

        figure(hee);
        set(0,'CurrentFigure',hee);

        figureNumber = mod(cadenceIndex, nFigRows*nFigColumns);
        if(figureNumber == 0)
            figureNumber = nFigRows*nFigColumns;
        end

        subplot(nFigRows, nFigColumns,figureNumber);
        set(gca, 'fontSize', 7);

        h1 = plot(sortedDistancesToCentroid*maxSortedDistancesToCentroid, normalizedFluxes,'bo');
        hold on;
        h2 = plot(sortedDistancesToCentroid*maxSortedDistancesToCentroid, y1,'rp-');
        grid;
        %        legend([h1 h2], {'data'; 'fit using constrained polynomial';}, 0);
        legend([h1 h2], {'data'; 'poly fit'}, 'Location', 'Best');

        xlabel('distances to centroid in pixels');
        ylabel('normalized encircled energy');
        if(figureNumber == 1)
            title({'constrained polynomial fit of encircled energy';
                'vs. distances to centroid';
                ['module ' num2str(module) ' output ', num2str(output)]});
        end
        hold off;
        if(cadenceIndex == numCadences)
            figure(hee);
            set(0,'CurrentFigure',hee);
            drawnow
            fileNameStr = ['encircled_energy_pixel_flux_module_'  num2str(module) '_output_', num2str(output)  '_modout_' num2str(currentModOut) ];
            paperOrientationFlag = true;
            includeTimeFlag = false;
            printJpgFlag = false;

            % add figure caption as user data
            plotCaption = strcat(...
                'In this plot, normalized targets'' pixel fluxes (encircled energy) are plotted as a \n',...
                'function of the distance from the centroid. Also plotted is a constrained polynomial fit \n',...
                'to the data. This plot serves to illustrate how well or how poorly the constrained fit approximates the data\n',...
                'Click on the link to open the figure in Matlab to examine the pixels closely. \n');

            set(hee, 'UserData', sprintf(plotCaption));

            plot_to_file(fileNameStr, paperOrientationFlag, includeTimeFlag, printJpgFlag);
        end

    end
    %=========================


    gPolyCoeffts = flipud(qPolyCoeffts); % polyfit, polyval order the polynomial coeffts in the reverse order
    % get the coeffts of the polynomial p(x)
    gPolyCoeffts = conv([1 0], gPolyCoeffts);
    gPolyCoeffts = conv([1 -1], gPolyCoeffts);
    gPolyCoeffts = gPolyCoeffts(:);
    pPolyCoeffts = polyint(gPolyCoeffts'); % polyint requires a row vector

    pPolyCoeffts = pPolyCoeffts';

    % now scale by normalizingConstant by evaluating the value of the integral at x = 1;

    normalizingConstant = polyval(pPolyCoeffts,1) ;

    pPolyCoeffts = (1/normalizingConstant).*pPolyCoeffts;

    f =  @(x) polyval(pPolyCoeffts,x) - fluxFraction;

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


    %=========================
    if(debugLevel)

        figure(hcumflux);
        set(0,'CurrentFigure',hcumflux);

        figureNumber = mod(cadenceIndex, nFigRows*nFigColumns);
        if(figureNumber == 0)
            figureNumber = nFigRows*nFigColumns;
        end

        subplot(nFigRows, nFigColumns,figureNumber);
        set(gca, 'fontSize', 7);

        h3 = plot(sortedDistancesToCentroid*maxSortedDistancesToCentroid, cumulativeRelativeFluxes,'bo');
        hold on;
        h4 = plot((0:.01:1)*maxSortedDistancesToCentroid,f(0:.01:1)+fluxFraction, 'r-', 'LineWidth', 2);

        plot([xAtFluxFraction,xAtFluxFraction]*maxSortedDistancesToCentroid, [0,1.1], 'color', 'g');
        plot([0, 6], [fluxFraction,fluxFraction],  'color', 'g');

        text(xAtFluxFraction*maxSortedDistancesToCentroid,1.1, ['[' num2str(xAtFluxFraction*maxSortedDistancesToCentroid), ', ' num2str(fluxFraction) ']'], 'fontsize',8);
        grid;
        fprintf('');
        legend([h3 h4], {'data'; 'poly fit'},  'Location', 'Best');

        xlabel('distances to centroid in pixels');
        ylabel('normalized cumulative flux');
        title({'constrained polynomial fit of cumulative flux';
            'vs. distances to centroid';
            ['module' num2str(module) ' output ', num2str(output)]});
        hold off;
        if(cadenceIndex == numCadences)
            figure(hcumflux);
            set(0,'CurrentFigure',hcumflux);
            drawnow
            fileNameStr = ['encircled_energy_cumulative_flux_module_'  num2str(module) '_output_', num2str(output)  '_modout_' num2str(currentModOut) ];
            paperOrientationFlag = true;
            includeTimeFlag = false;
            printJpgFlag = false;

            % add figure caption as user data
            plotCaption = strcat(...
                'In this plot, cumulative normalized targets'' pixel fluxes (encircled energy) are plotted as a \n',...
                'function of the distance from the centroid. Also plotted is a constrained polynomial fit \n',...
                'to the data. This plot serves to illustrate how well or how poorly the constrained fit approximates the data\n',...
                'Click on the link to open the figure in Matlab to examine the pixels closely. \n');

            set(hcumflux, 'UserData', sprintf(plotCaption));

            plot_to_file(fileNameStr, paperOrientationFlag, includeTimeFlag, printJpgFlag);
        end


    end

    %==============================

    % to compute the uncertainty assciated with encircledEnergy calculation
    % , need to compute the derivative of the inverse function x = f(y)
    % i.e.  sortedDistancesToCentroid = f(encircledEnergy)

    % dX/dCk|Xee = (dX/dY) * (dY/dCk) = {1/(dY/dX|Xee)}*{dY/dCk}|Xee
    % where Ck's are the polynomial coefficients, Xee is the value of X at
    % the given encircld energy fraction
    % dy/dx|xee
    % derivative of the polynomial evaluated at Xee

    % tranformation 1
    % normalizingConstant*x*(x-1) multiplying q(x)

    T1 = diag(normalizingConstant*sortedDistancesToCentroid.*(sortedDistancesToCentroid-1));

    T2 = tril(ones(length(sortedDistancesToCentroid)),0);


    B = weighted_design_matrix(sortedDistancesToCentroid, 1, length(pPolyCoeffts)-1, 'standard');

    CintegralPolyFit = (pinv(B))*T2*T1*A*CeePolyFit*A'*T2'*T1'*(pinv(B))';


    x = xAtFluxFraction;
    derivativeOfYwrtX = polyder(pPolyCoeffts);
    derivativeOfYAtX = polyval(derivativeOfYwrtX,x);
    derivativeOfXwrtY = 1./derivativeOfYAtX;


    derivativeOfYwrtCoeffts = (x.^(0:length(pPolyCoeffts)-1)');

    T = derivativeOfXwrtY*derivativeOfYwrtCoeffts;

    encircledEnergiesUncertainties(cadenceIndex) = (sqrt(T'*CintegralPolyFit*T))*maxSortedDistancesToCentroid;



    if(isnan(encircledEnergiesUncertainties(cadenceIndex)))
        warning('PDQ:encircledEnergyMetric:Uncertainties', ...
            'Encircled energy metric uncertainties: are NaNs');
        encircledEnergiesUncertainties(cadenceIndex) = -1;
        encircledEnergies(cadenceIndex) = -1;
        encircledEnergiesBestPolyOrder(cadenceIndex)  = -1;
    end


    if(~isreal(encircledEnergiesUncertainties(cadenceIndex)))
        warning('PDQ:encircledEnergyMetric:Uncertainties', ...
            'Encircled energy metric: uncertainties are complex numbers');
        encircledEnergiesUncertainties(cadenceIndex) = -1;
        encircledEnergies(cadenceIndex) = -1;
        encircledEnergiesBestPolyOrder(cadenceIndex)  = -1;

    end


    if(encircledEnergiesUncertainties(cadenceIndex)/encircledEnergies(cadenceIndex)  > 1.0)

        warning('PDQ:encircledEnergyMetric:invalidEncircledEnergyMetric', ...
            'encircledEnergiesUncertainties(%d)./encircledEnergies(%d) > 1.0 for cadence %d ', cadenceIndex,cadenceIndex, cadenceIndex );

        encircledEnergiesUncertainties(cadenceIndex) = -1;
        encircledEnergies(cadenceIndex) = -1;
        encircledEnergiesBestPolyOrder(cadenceIndex)  = -1;
        continue;
    end
    if(encircledEnergies(cadenceIndex) >= 9.0)

        warning('PDQ:encircledEnergyMetric:invalidEncircledEnergyMetric', ...
            'encircledEnergies(%d) >= 9 pixels for cadence %d ', cadenceIndex,cadenceIndex, cadenceIndex );

        encircledEnergiesUncertainties(cadenceIndex) = -1;
        encircledEnergies(cadenceIndex) = -1;
        encircledEnergiesBestPolyOrder(cadenceIndex)  = -1;
        continue;
    end


end

%
disp([encircledEnergies,encircledEnergiesUncertainties])

pdqTempStruct.encircledEnergies = encircledEnergies;
pdqTempStruct.encircledEnergiesUncertainties = encircledEnergiesUncertainties;
pdqTempStruct.encircledEnergiesBestPolyOrder = encircledEnergiesBestPolyOrder;

warning on all;
% validate outputs here....
close all;

return