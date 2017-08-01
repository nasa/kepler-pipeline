function pdqTempStruct = compute_plate_scale_metric(pdqTempStruct, attitudeSolution, currentModOut,raDec2PixObject)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function pdqTempStruct = compute_plate_scale_metric(pdqTempStruct, attitudeSolution, currentModOut,raDec2PixObject)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% The ratio of the angular distance between two stars to the
% linear distance between their images on a photographic plate/CCD.
%
% Output:
%     Modifies ...
%         pdqTempStruct.plateScaleGapIndicators 
%         pdqTempStruct.plateScaleResults
%         pdqTempStruct.plateScaleUncertainties
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
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

geometryObject = geometryClass(get(raDec2PixObject,'geometryModel'));
% Find out how many cadences and targets we are processing
numCadences         = pdqTempStruct.numCadences;
% Find the indices into all stellar targets (if any) on this module/output
targetIndices       = pdqTempStruct.targetIndices;
numTargets          = length(targetIndices);

% Local variable for plate scale results
plateScaleUncertainties     = -ones(numCadences, 1);
plateScales                 = -ones(numCadences, 1);


% Find out how many targets (if any) we are processing on this module/ouput
% Do not do plate scale with less than 2 stellar targets
if (numTargets < 2)
    % warning message here....
    warning('PDQ:plateScaleMetric:plateScaleCalculation', ...
        ['Can''t compute plate scale metric as there is only ' num2str(numTargets) ' target available']);
    for cadenceIndex = 1:numCadences
        plateScaleUncertainties(cadenceIndex) = -1;
        plateScales(cadenceIndex) = -1;
        pdqTempStruct.plateScaleResults = plateScales;
        pdqTempStruct.plateScaleUncertainties = plateScaleUncertainties;
    end
    return;
end


% make sure there no invalid centroids (like -1)
centroidRows        = pdqTempStruct.centroidRows;
centroidCols        = pdqTempStruct.centroidCols;


% star positions from catalogs
raStars             = pdqTempStruct.raStars;
decStars            = pdqTempStruct.decStars;


% use the just obtained attitude solution instead
raPointing          = attitudeSolution(:,1); % a vector now...
decPointing         = attitudeSolution(:,2);
rollPointing        = attitudeSolution(:,3);

% RLM 3/31/11 - Introduce pointing error for debugging purposes
% arcsecPerPix = 3.98; % nominal value
% raPointing =  raPointing + 500 * (arcsecPerPix/3600); % Offset by 10 pixels
% -- RLM


% get the timestamps
cadenceTimeStamps = pdqTempStruct.cadenceTimes;

[ccdModule ccdOutput]       = convert_to_module_output(currentModOut);


aberrateFlag                = 1; % default

% For each cadence,
%  1. Measure centroid positions (row, col).
%  2. Get the computed attitude solution
%  3. invoke pix_2_ra_dec with measured centroids, cadence time stamps,
%  velocity aberration flag turned on to get centroids in ra and dec
%  (predicted ra, dec)
%  4. Solve for the constants a,b, de, and e from
%   [ raPredicted  ]      [ a  b  ][ raCatalog  ]     [ c ]
%   [              ]  =   [       ][            ]   + [   ]
%   [ decPredicted ]      [ d   e ][ decCatalog ]     [ f ]
%
%                   | a     b |
%   plate scale is  |         | = ae - bd
%                   | d     e |
%
%           [ raCatalog(1) decCatalog(1) 1 ]
%           | raCatalog(2) decCatalog(2) 1 |
%           |  .     .    .   .   .   .  . |
%           |  .     .    .   .   .   .  . |
%   A   =   |  .     .    .   .   .   .  . |
%           |  .     .    .   .   .   .  . |
%           |  .     .    .   .   .   .  . |
%           [ raCatalog(N) decCatalog(N) 1 ]
%
%
%           [ a  d  ]
%           [ b  e  ]
%   w   =   [ c  f  ]
%
%
%   b consists of predicted ra, dec of stars (centroid row, centroid
%   columns mapped to sky using pix2radec with the just computed attitude
%   solution)
%           [ raPredicted(1) decPredicted(1) ]
%           | raPredicted(2) decPredicted(2) |
%           |  .     .    .   .  .   .   .   |
%           |  .     .    .   .  .   .   .   |
%   b   =   |  .     .    .   .  .   .   .   |
%           |  .     .    .   .  .   .   .   |
%           |  .     .    .   .  .   .   .   |
%           [ raPredicted(N) decPredicted(N) ]
%


[centroidRa, centroidDec, pdqTempStruct.centroidUncertaintyStruct] = ...
    get_predicted_star_positions(raDec2PixObject,ccdModule, ccdOutput, centroidRows, centroidCols,...
    pdqTempStruct.centroidUncertaintyStruct, ...
    cadenceTimeStamps, raPointing, decPointing, rollPointing, aberrateFlag);

% transformation of centroid(row, col) covariance matrix of uncertainties
% to centroid(ra, dec) covariance matrix of uncertainties
% numerical jacobian of transformation


for cadenceIndex = 1 : numCadences

    % collect valid centroidRa, centroidDec

    validIndex = find((centroidRa(:,cadenceIndex)  ~= -1) & (centroidDec(:,cadenceIndex) ~= -1));

    validCentroidRa = centroidRa(:,cadenceIndex);
    validCentroidRa = validCentroidRa(validIndex);
    validCentroidDec = centroidDec(:,cadenceIndex);
    validCentroidDec = validCentroidDec(validIndex);


    if(isempty(validCentroidRa) || isempty(validCentroidDec) || length(validCentroidRa) < 2 || length(validCentroidDec) < 2)
        plateScaleUncertainties(cadenceIndex) = -1;
        plateScales(cadenceIndex) = -1;
        warning('PDQ:plateScaleMetric:Uncertainties', ...
            ['Plate Scale metric: No targets available for modout ' num2str(currentModOut) ' for cadence ' num2str(cadenceIndex)]);
        continue;
    end


    designMatrixRaDec  = [raStars(validIndex),decStars(validIndex),ones(size(validIndex))]; % design matrix A

    bRa   =  validCentroidRa ;
    bDec   = validCentroidDec;


    TrowColumnToRa = pdqTempStruct.centroidUncertaintyStruct(cadenceIndex).TrowColumnToRa;
    TrowColumnToDec = pdqTempStruct.centroidUncertaintyStruct(cadenceIndex).TrowColumnToDec;


    CcentroidColumn = pdqTempStruct.centroidUncertaintyStruct(cadenceIndex).CcentroidColumn;
    CcentroidRow = pdqTempStruct.centroidUncertaintyStruct(cadenceIndex).CcentroidRow;

    % remove rows and columns of invalid centroids
    invalidCentroidRa = find(centroidRa(:,cadenceIndex) == -1);
    if(~isempty(invalidCentroidRa))
        CcentroidColumn(invalidCentroidRa,:) = [];
        CcentroidColumn(:, invalidCentroidRa) = [];

        CcentroidRow(invalidCentroidRa,:) = [];
        CcentroidRow(:, invalidCentroidRa) = [];

    end


    %                       [ CcentroidRow        0          ]
    %  Ccentroid =          |                                |
    %                       [    0          CcentroidColumn  ]
    %

    zeroMatrix = zeros(size(CcentroidRow));

    Ccentroid = [CcentroidRow zeroMatrix; zeroMatrix CcentroidColumn];

    CcentroidRowColumnToRa   = TrowColumnToRa * Ccentroid * TrowColumnToRa';

    CcentroidRowColumnToDec   = TrowColumnToDec * Ccentroid * TrowColumnToDec';

    %----------------------------------------------------------------------
    % RLM 3/23/11 -- As of Q9 many channels have only two stellar targets.
    % Solving for a best fit affine transform (6 coefficients) in this case
    % involves solving an underdetermined system. In this case LSCOV()
    % truncates the right-most column R matrix in its QR decomposition,
    % reducing the problem to solving for a linear transformation. However,
    % a 2x2 linear transformation cannot account for translations, which
    % may be a significant component of the discrepancy between predicted
    % and catalog star position, especially if there are significant
    % pointing errors.
    %
    % With two targets we get a better scaling factor if we simply take the
    % ratio of the angular separations of the predicted and catalog star
    % positions. The uncertainty is set to zero for now, which is what the
    % least squares method was doing anyway in two-star cases.
    %----------------------------------------------------------------------
    if (numel(validIndex) == 2)
        fprintf(['PDQ: compute_plate_scale_metric: cadence ' ...
            num2str(cadenceIndex) ' of module/output ' num2str(ccdModule) ...
            '/' num2str(ccdOutput) ' (modout ' num2str(currentModOut) ...
            ') contains only two valid targets. Computing plate scale ' ...
            'directly ....\n']);
        plate_scale_ratio = plate_scale_ratio_from_two_stars(raStars(validIndex), decStars(validIndex), centroidRa(validIndex), centroidDec(validIndex));

        plateScaleForAll  = get_plate_scale(geometryObject, pdqTempStruct.cadenceTimes(cadenceIndex));
        plateScaleForThisModOut = plateScaleForAll(currentModOut);
        plateScales(cadenceIndex) = plate_scale_ratio * plateScaleForThisModOut;
        plateScaleUncertainties(cadenceIndex) = 0;
    else
        % passing the full covariance matrix to lscov is useless as the
        % off-diagonal elements are close to eps
        try
            warning off all;
            [abcCoeffts, stdResidual1, mseResidual1, SabcCoeffts ] = lscov(designMatrixRaDec, bRa, 1./diag(CcentroidRowColumnToRa), 'orth');
            warning on all;
        catch
            warning('PDQ:compute_plate_scale_metric:CcentroidRowColumnToRa', ...
                ['CcentroidRowColumnToRa not symmetric for cadence ' num2str(cadenceIndex) ', module/output ' num2str(ccdModule) '/' num2str(ccdOutput) ', modout ' num2str(currentModOut) ]);

            plateScaleUncertainties(cadenceIndex) = -1;
            plateScales(cadenceIndex) = -1;

            continue;
        end

        try
            warning off all;
            [defCoeffts, stdResidual2, mseResidual2, SdefCoeffts ] = lscov(designMatrixRaDec, bDec, 1./diag(CcentroidRowColumnToDec), 'orth');
            warning on all;
        catch
            warning('PDQ:compute_plate_scale_metric:CcentroidRowColumnToDec', ...
                ['CcentroidRowColumnToDec not symmetric for cadence ' num2str(cadenceIndex) ', module/output ' num2str(ccdModule) '/' num2str(ccdOutput) ', modout ' num2str(currentModOut) ]);

            plateScaleUncertainties(cadenceIndex) = -1;
            plateScales(cadenceIndex) = -1;

            continue;
        end

        SabCoeffts  = diag(SabcCoeffts(1:2, 1:2)); % a vector
        SdeCoeffts = diag(SdefCoeffts(1:2, 1:2)); % a vector

        Sabde = [SabCoeffts;SdeCoeffts];
        a = abcCoeffts(1);
        b = abcCoeffts(2);
        d   = defCoeffts(1);
        e  = defCoeffts(2);

        TplateScale = [e -d -b a]';


        plateScaleUncertainties(cadenceIndex) = sqrt(TplateScale' * diag(Sabde) * TplateScale);

        if(~isreal(plateScaleUncertainties(cadenceIndex)))
            plateScaleUncertainties(cadenceIndex) = -1;
            warning('PDQ:plateScaleMetric:NoTargets', ...
                'Plate Scale metric: uncertainties are complex numbers for cadence %d ; setting the metric = -1', cadenceIndex );
            continue;
        end

        if((a*e - b*d) > 0)

            plateScaleForAll  = get_plate_scale(geometryObject, pdqTempStruct.cadenceTimes(cadenceIndex));

            plateScaleForThisModOut = plateScaleForAll(currentModOut);
            plateScales(cadenceIndex) = sqrt(a*e - b*d)*plateScaleForThisModOut ; % any error checking for negative values??
        else
            % relative change in area
            warning('PDQ:compute_plate_scale_metric:invalidPlateScaleMetric', ...
                ['Plate scale not > 0.5 and not < 1.5 for cadence ' num2str(cadenceIndex) ', module/output ' num2str(ccdModule) '/' num2str(ccdOutput) ', modout ' num2str(currentModOut) ]);

            plateScaleUncertainties(cadenceIndex) = -1;
            plateScales(cadenceIndex) = -1;

            continue;
        end
        
    end % if (numel(validIndex) == 2)
%-----------------

    fieldsAndBounds = { 'plateScale'; '> 2'; '< 8'; []};  %

    try
        validate_field(plateScales(cadenceIndex), fieldsAndBounds, 'PDQ:compute_plate_scale_metric:invalidPlateScaleMetric');
    catch
        warning('PDQ:compute_plate_scale_metric:invalidPlateScaleMetric', ...
            ['Plate scale not > 0.5 and not < 1.5 for cadence ' num2str(cadenceIndex) ', module/output ' num2str(ccdModule) '/' num2str(ccdOutput) ', modout ' num2str(currentModOut) ]);

        plateScaleUncertainties(cadenceIndex) = -1;
        plateScales(cadenceIndex) = -1;

        continue;
    end

    if(plateScaleUncertainties(cadenceIndex)/plateScales(cadenceIndex) >= 1)
        warning('PDQ:compute_plate_scale_metric:invalidPlateScaleMetric', ...
            'Plate scale uncertainties are greater than plate scale values for cadence %d ', cadenceIndex );
        continue;
    end
end


% PPA also invokes this function and expects the gap indicatorsto be set;
% for PDQ, appending gapIndictaors to pdqTempstruct is not helpful as it is
% difficult to identify to what metric this gap indicators refer to....

gapIndicators = false(numCadences,1);

% set the gap indicators to true wherever the metric = -1;
metricGapIndex = find(plateScales(:) == -1);

if(~isempty(metricGapIndex))
    gapIndicators(metricGapIndex) = true;
end

pdqTempStruct.plateScaleGapIndicators = gapIndicators(:);
pdqTempStruct.plateScaleResults = plateScales;
pdqTempStruct.plateScaleUncertainties = plateScaleUncertainties;

if currentModOut == 13
    fprintf('test');
end

%
%     ytickValues = get(gca, 'ytick');
%     zString = cell(length(ytickValues),1);
%     for jTick = 1:length(ytickValues),
%         zString{jTick}  = num2str(ytickValues(jTick), '%g');
%     end
%     set(gca, 'yticklabel', zString);

return

