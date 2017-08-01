function plateScaleReport = calculate_plate_scale_metric(pmdScienceObject)
%
% plateScaleReport = calculate_plate_scale_metric(pmdScienceObject)
%
% Calculate the plate scale for the given output.
%
% INPUTS:
%   pmdScienceObject
%
% OUTPUTS:
%   A struct with fields:
%       plateScaleReport    
%           .values:        [float array]    (nCadences x 1)
%           .uncertainties: [float array]    (nCadences x 1)
%           .gapIndicators: [logical array]  (nCadences x 1)
%
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

    raDec2PixObject = raDec2PixClass(pmdScienceObject.raDec2PixModel, 'one-based'); 
    if ~is_one_based(raDec2PixObject)
        error('PMD:calculate_plate_scale', 'Expected one-based raDec2PixObject');
    end

    nCadences = length(pmdScienceObject.motionPolyStruct);
    if nCadences == 0
        error('PMD:calculate_plate_scale', 'Zero cadences in pmdScienceObject.motionPolyStruct -- error');
    end
    
    [gridRows gridCols] = get_pixel_grid(pmdScienceObject.fcConstants);
    nStars = length(gridRows);
    
    FAKE_TARGET_INDEX = 666;
    psStruct = struct( ...
        'numCadences',   nCadences, ...
        'targetIndices', repmat(FAKE_TARGET_INDEX, 1, nStars), ...
        'centroidRows',  [], ...
        'centroidCols',  [], ...
        'centroidUncertaintyStruct', [], ...
        'raStars',       [], ...
        'decStars',      [], ...
        'cadenceTimes',  [], ...
        'TrowColumnToRa', [], ...
        'TrowColumnToDec', []);

    numValidCadences = 0;
    
    gapIndicators = true(1,nCadences);
    
    for icad = 1:nCadences
        mp = pmdScienceObject.motionPolyStruct(icad);
        
        % If either the row or column motion polynomial is bad, the entire
        % motion polynomial struct is bad.
        %
        isMotionPolyBad = ~mp.rowPolyStatus || ~mp.colPolyStatus;
        gapIndicators(icad) = isMotionPolyBad;
            
        % If the motion poly struct is bad, the results of the poly fit will be bad.
        % However, the data must be filled for compute_plate_scale_metric to run.
        %
        if isMotionPolyBad
            psStruct.centroidRows(:, icad) = zeros(nStars, 1) - 1;
            psStruct.centroidCols(:, icad) = zeros(nStars, 1) - 1;
            psStruct.centroidUncertaintyStruct(icad).CcentroidRow    = zeros(nStars, nStars) - 1;
            psStruct.centroidUncertaintyStruct(icad).CcentroidColumn = zeros(nStars, nStars) - 1;

            % Use the midpoint of the radec2pixmodel's MJD range as a
            % field-filling MJD.  
            %
            raDec2PixModelMidMjd = (pmdScienceObject.raDec2PixModel.mjdStart + pmdScienceObject.raDec2PixModel.mjdEnd) / 2.0;
            psStruct.cadenceTimes(icad) =  raDec2PixModelMidMjd;
            
            continue;
        end
        numValidCadences = numValidCadences + 1;

        cadenceTime = mp.mjdMidTime;
        psStruct.cadenceTimes(icad) = cadenceTime;

        gridMod = repmat(mp.module, size(gridRows,1), size(gridRows,2));
        gridOut = repmat(mp.output, size(gridRows,1), size(gridRows,2));

        warning('off', 'Matlab:FC:raDec2PixClass');
        [ras decs] = pix_2_ra_dec(raDec2PixObject, gridMod, gridOut, gridRows, gridCols, cadenceTime);
        psStruct.raStars  = ras(:);
        psStruct.decStars = decs(:);
                
        [rowVals rowUncerts Ar] = weighted_polyval2d(ras, decs, mp.rowPoly);
        [colVals colUncerts Ac] = weighted_polyval2d(ras, decs, mp.colPoly);

        psStruct.centroidRows(:, icad) = rowVals;
        psStruct.centroidCols(:, icad) = colVals;
        psStruct.centroidUncertaintyStruct(icad).CcentroidRow    = Ar * pmdScienceObject.motionPolyStruct(icad).rowPoly.covariance * Ar';
        psStruct.centroidUncertaintyStruct(icad).CcentroidColumn = Ac * pmdScienceObject.motionPolyStruct(icad).colPoly.covariance * Ac';
    end

    % If there were no valid cadences (all bad motion polynomials), return
    % a blank struct.  Otherwise return the plateScaleReport data.
    %
    if ~isempty(psStruct.centroidRows)
        attitudeSolution =  get_pointing(pointingClass(get(raDec2PixObject, 'pointingModel')), psStruct.cadenceTimes(:));
        psResults = compute_plate_scale_metric(psStruct, attitudeSolution, convert_from_module_output(pmdScienceObject.ccdModule, pmdScienceObject.ccdOutput), raDec2PixObject);

        plateScaleReport.values        = psResults.plateScaleResults;
        plateScaleReport.uncertainties = psResults.plateScaleUncertainties;
        plateScaleReport.gapIndicators = psResults.plateScaleGapIndicators;
    else
        plateScaleReport.values        = zeros(1,nCadences) - 1;
        plateScaleReport.uncertainties = zeros(1,nCadences)-1;
        plateScaleReport.gapIndicators = true(1,nCadences);
    end
return
