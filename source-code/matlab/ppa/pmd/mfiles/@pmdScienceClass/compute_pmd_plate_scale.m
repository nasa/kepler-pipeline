function plateScaleTs = compute_pmd_plate_scale(ppaStruct, attitudeSolution, currentModOut, raDec2PixObject)
% 
%
% Plate scale is the ratio of the angular distance between two stars to the
% linear distance between their images on a photographic plate.
%
% Below is code from PDQ plate scale metric computation - will leverage off
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
 




%--------------------------------------------------------------------------
% Find out how many cadences and targets we are processing
numCadences         = ppaStruct.numCadences;
% Find the indices into all stellar targets (if any) on this module/output
targetIndices       = ppaStruct.targetIndices;
numTargets          = length(targetIndices);

% Find out how many targets (if any) we are processing on this module/ouput
% Do not do plate scale with less than 2 stellar targets
if (numTargets < 2)
    % warning message here....
    warning('PDQ:plateScaleMetric:plateScaleCalculation', ...
        ['Can''t compute plate scale metric as there only ' num2str(numtargets) 'available']);
    return;
end


% make sure there no invalid centroids (like -1)
centroidRows        = ppaStruct.centroidRows;
centroidCols        = ppaStruct.centroidCols;


% star positions from catalogs
raStars             = ppaStruct.raStars;
decStars            = ppaStruct.decStars;

% nominalPointing     = ppaStruct.nominalPointing; % triad ra, dec, roll
% raPointing          = nominalPointing(1);
% decPointing         = nominalPointing(2);
% rollPointing        = nominalPointing(3);

% use the just obtained attitude solution instead

raPointing          = attitudeSolution(:,1); % a vector now...
decPointing         = attitudeSolution(:,2);
rollPointing        = attitudeSolution(:,3);

cadenceTimeStamps = ppaStruct.cadenceTimes;


% Local variable for plate scale results
plateScaleUncertainties     = zeros(numCadences, 1);
plateScales                 = zeros(numCadences, 1);

[ccdModule ccdOutput]       = convert_to_module_output(currentModOut);
aberrateFlag                = 1; % default




% For each cadence,
%  1. Measure centroid positions (row, col).
%  2. Get the nominal attitude from FC
%  3. invoke pix_2_ra_dec with measured centroids, cadence time stamps,
%  velocity aberration flag turned on to get centroids in ra and dec
%  4. estimate measured star positions  using
%   [ re ]      [ a  b  ][ rp ]     [ c ]
%   |    |  =   |       ||    |   + [   ]
%   [ ce ]      [ d   e ][ cp ]     [ f ]
%
%                   | a     b |
%   plate scale is  |         | = ae - bd
%                   | d     e |
%
%           [ rp(1) cp(1) 1 ]
%           | rp(2) cp(2) 1 |
%           |  .     .    . |
%           |  .     .    . |
%   A   =   |  .     .    . |
%           |  .     .    . |
%           |  .     .    . |
%           [ rp(N) cp(N) 1 ]
%
%
%           [ a  d  ]
%           [ b  e  ]
%   w   =   [ c  f  ]
%
%
%   b consists of ra, dec of stars (from the catalog)
%           [ r(1) c(1) ]
%           | r(2) c(2) |
%           |  .     .  |
%           |  .     .  |
%   b   =   |  .     .  |
%           |  .     .  |
%           |  .     .  |
%           [ r(N) c(N) ]
%
% predicted star positions (centroids {rp, cp}) for all cadences


% centroidRows, centroidCols have visible silicon as their
% coordinate reference frame unlike reference pixels which have the entire silicon
% (visible + collateral) as their corrdinate frame

[centroidRa, centroidDec, ppaStruct.centroidUncertaintyStruct] = ...
    get_predicted_star_positions(raDec2PixObject,ccdModule, ccdOutput, centroidRows, centroidCols,...
    ppaStruct.centroidUncertaintyStruct, ...
    cadenceTimeStamps, raPointing, decPointing, rollPointing, aberrateFlag);

% transformation of centroid(row, col) covariance matrix of uncertainties
% to centroid(ra, dec) covariance matrix of uncertainties
% numerical jacobian of transformation


for cadenceIndex = 1 : numCadences

    % collect valid centroidRa, centroidDec

    validCentroidRa = centroidRa(:,cadenceIndex);
    validCentroidRa = validCentroidRa(validCentroidRa > -1);
    validCentroidDec = centroidDec(:,cadenceIndex);
    validCentroidDec = validCentroidDec(validCentroidDec > -1);


    if(isempty(validCentroidRa) || isempty(validCentroidDec) || length(validCentroidRa) < 2 || length(validCentroidDec) < 2)
        plateScaleUncertainties(cadenceIndex) = -1;
        plateScales(cadenceIndex) = -1;
        warning('PDQ:plateScaleMetric:Uncertainties', ...
            ['Plate Scale metric: No targets available for modout ' num2str(currentModOut) ' for cadence ' num2str(cadenceIndex)]);
        continue;
    end




    designMatrixRaDec  = [validCentroidRa,validCentroidDec,ones(size(validCentroidDec))]; % design matrix A

    bRa   =  raStars ;
    bDec   = decStars;


    TrowColumnToRa = ppaStruct.centroidUncertaintyStruct(cadenceIndex).TrowColumnToRa;
    TrowColumnToDec = ppaStruct.centroidUncertaintyStruct(cadenceIndex).TrowColumnToDec;


    CcentroidColumn = ppaStruct.centroidUncertaintyStruct(cadenceIndex).CcentroidColumn;
    CcentroidRow = ppaStruct.centroidUncertaintyStruct(cadenceIndex).CcentroidRow;

    % remove rows and columns of invalid centroids
    invalidCentroidRa = find(centroidRa(:,cadenceIndex) == -1);
    if(~isempty(invalidCentroidRa))
        CcentroidColumn(invalidCentroidRa,:) = [];
        CcentroidColumn(:, invalidCentroidRa) = [];

        CcentroidRow(invalidCentroidRa,:) = [];
        CcentroidRow(:, invalidCentroidRa) = [];
        bRa(invalidCentroidRa) = [];
        bDec(invalidCentroidRa) = [];

    end



    %                       [ CcentroidRow        0          ]
    %  Ccentroid =          |                                |
    %                       [    0          CcentroidColumn  ]
    %

    zeroMatrix = zeros(size(CcentroidRow));

    Ccentroid = [CcentroidRow zeroMatrix; zeroMatrix CcentroidColumn];

    CcentroidRowColToRa   = TrowColumnToRa * Ccentroid * TrowColumnToRa';

    CcentroidRowColumnToDec   = TrowColumnToDec * Ccentroid * TrowColumnToDec';


    %     zeroMatrix = zeros(size(CrowToRaDec));
    %
    %     CcentroidRowCol = [CrowToRaDec zeroMatrix ; zeroMatrix CcolumnToRaDec];
    %     TrowColToRaDec =  [TrowToRaDec TcolumnToRaDec];
    %
    %     CcentroidRaDec = TrowColToRaDec * CcentroidRowCol * TrowColToRaDec';
    %
    %     [abcdefCoeffts, stdResidual, mseResidual, Scoeffts ] = lscov(designMatrixRaDec, bRaDec, CcentroidRaDec);
    %
    %     Scoeffts = Scoeffts./mseResidual;

    lastwarn('')  ;


    [abcCoeffts, stdResidual1, mseResidual1, SabcCoeffts ] = lscov(designMatrixRaDec, bRa, CcentroidRowColToRa);
    %     % W typically  contains either counts or inverse variances.
    %     if(any(diag(SabcCoeffts < 0)))
    %         [abcCoeffts, stdResidual1, mseResidual1, SabcCoeffts ] = lscov(designMatrixRaDec, bRa, 1./diag(CcentroidRowColToRa));
    %     end

    if(mseResidual1 > 0)
        SabcCoeffts = SabcCoeffts./mseResidual1;
    end


    msgstr = lastwarn;

    if(~isempty(msgstr))
        plateScaleUncertainties(cadenceIndex) = -1;
        plateScales(cadenceIndex) = -1;
        continue;
    end

    lastwarn('')  ;
    [defCoeffts, stdResidual2, mseResidual2, SdefCoeffts ] = lscov(designMatrixRaDec, bDec, CcentroidRowColumnToDec);
    if(mseResidual2 > 0)
        SdefCoeffts = SdefCoeffts./mseResidual2;
    end


    %     if(any(diag(SdefCoeffts < 0)))
    %         [defCoeffts, stdResidual2, mseResidual2, SdefCoeffts ] = lscov(designMatrixRaDec, bDec, 1./diag(CcentroidRowColumnToDec));
    %     end




    msgstr = lastwarn;

    if(~isempty(msgstr))
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
        plateScales(cadenceIndex) = -1;
        warning('PDQ:plateScaleMetric:NoTargets', ...
            'Plate Scale metric: uncertainties are complex numbers');
        continue;
    end


    plateScales(cadenceIndex) = a*e - b*d ; % any error checking for negative values??

    if(plateScales(cadenceIndex) <= 0)
        error('PDQ:plateScaleMetric:plateScale', ...
            'Plate scale values: zero or negative');
    end

    if(plateScales(cadenceIndex) >= 1.5)
        error('PDQ:plateScaleMetric:plateScale', ...
            'Plate scale values: greater than 1.5');
    end


    if(plateScaleUncertainties(cadenceIndex)/plateScales(cadenceIndex) >= 1)
        error('PDQ:plateScaleMetric:plateScale', ...
            'Plate scale uncertainties are greater than plate scale values for cadence %d ; setting the metric = -1', cadenceIndex );
    end

end


if(~any(plateScaleUncertainties))
    % debug purposes...
    fprintf('');
end


ppaStruct.plateScaleUncertainties = plateScaleUncertainties;
ppaStruct.plateScaleResults = plateScales;

return

