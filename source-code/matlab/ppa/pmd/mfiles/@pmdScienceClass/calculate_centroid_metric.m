function centroidReport = calculate_centroid_metric(pmdScienceObject)
%
% centroidReport = calculate_centroid_metric(pmdScienceObject)
% 
% Calculate the offsets of the centroids, as determined by the motion polynomial, for the 
% CCD module/output of the pmdScienceObject.
%
% INPUTS:
%   pmdScienceObject
%
% OUTPUTS:
%    centroidReport
%       .centroidsMeanRow
%           .values:        [float array]    (nCadences x 1)
%           .uncertainties: [float array]    (nCadences x 1)
%           .gapIndicators: [logical array]  (nCadences x 1)
%       .centroidsMeanColumn
%           .values:        [float array]    (nCadences x 1)
%           .uncertainties: [float array]    (nCadences x 1)
%           .gapIndicators: [logical array]  (nCadences x 1)
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

    nCadences = length(pmdScienceObject.motionPolyStruct);
    if nCadences == 0
        error('PMD:calculate_centroid', 'Zero cadences in pmdScienceObject.motionPolyStruct -- error');
    end
    
    % Set up outputs:
    %
    centroidReport.centroidsMeanRow.values           = -1 + zeros(nCadences, 1);
    centroidReport.centroidsMeanRow.uncertainties    = -1 + zeros(nCadences, 1);
    centroidReport.centroidsMeanRow.gapIndicators    = true(nCadences, 1);
    centroidReport.centroidsMeanColumn.values        = -1 + zeros(nCadences, 1);
    centroidReport.centroidsMeanColumn.uncertainties = -1 + zeros(nCadences, 1);
    centroidReport.centroidsMeanColumn.gapIndicators = true(nCadences, 1);

    validate_mod_outs(pmdScienceObject)

    raDec2PixObject = raDec2PixClass(pmdScienceObject.raDec2PixModel, 'one-based'); 
    if ~is_one_based(raDec2PixObject)
        error('PMD:calculate_centroid_metric', 'Expected one-based raDec2PixObject');
    end


    % Set up a output-spanning grid of stars
    %
    [gridRows gridCols] = get_pixel_grid(pmdScienceObject.fcConstants);

    % Get the ra/dec of the star grid at the first cadence of the pmdScienceObject data.
    %
    % (motionPolyStruct(1).module and  motionPolyStruct(1).output are unique if validate_mod_outs passed):
    %
    mpMods = repmat(pmdScienceObject.motionPolyStruct(1).module, size(gridRows));
    mpOuts = repmat(pmdScienceObject.motionPolyStruct(1).output, size(gridRows));
    
    motionPolyStatus = [pmdScienceObject.motionPolyStruct.rowPolyStatus] & ...
                       [pmdScienceObject.motionPolyStruct.colPolyStatus];
    firstGoodMotionPoly = find(motionPolyStatus, 1, 'first');
    isAllMotionPolysBad = isempty(firstGoodMotionPoly);
    if isAllMotionPolysBad
        warning('PMD:calculate_centroid_metric', 'All cadences are gapped-- returning an all-gapped structure.');
        return
    end
    firstMjd = pmdScienceObject.motionPolyStruct(firstGoodMotionPoly).mjdMidTime;

    warning('off', 'Matlab:FC:raDec2PixClass');
    [starRa starDec] = pix_2_ra_dec(raDec2PixObject, mpMods, mpOuts, gridRows, gridCols, firstMjd); % Set to return the unaberrated ra/dec

    % Preallocate values for zero-cadence data
    %
    meanRows   = repmat(-1,   nCadences, 1);
    uncertRows = repmat(-1,   nCadences, 1);
    gapRows    = repmat(true, nCadences, 1);
    meanCols   = repmat(-1,   nCadences, 1);
    uncertCols = repmat(-1,   nCadences, 1);
    gapCols    = repmat(true, nCadences, 1);

    for icad = 1:nCadences
        mp = pmdScienceObject.motionPolyStruct(icad);

        gapRows(icad) = ~logical(mp.rowPolyStatus);
        gapCols(icad) = ~logical(mp.colPolyStatus);
        isCadenceGapped = gapRows(icad) || gapCols(icad);

        % Run radec2pix at the specified cadence time if the cadence is not
        % gapped.  If gapped, use the first MJD
        %
        mjd = mp.mjdMidTime;
        if isCadenceGapped
            mjd = firstMjd;
        end
        warning('off', 'Matlab:FC:raDec2PixClass');
        [junkMod junkOutput starRow starCol] = ra_dec_2_pix(raDec2PixObject, starRa, starDec, mjd);

        [mpRow mpRowUncert Ar] = weighted_polyval2d(starRa, starDec, mp.rowPoly);
        [mpCol mpColUncert Ac] = weighted_polyval2d(starRa, starDec, mp.colPoly);

        warning('off','MATLAB:divideByZero')
        meanRows(icad)   = mean(starRow - mpRow);
        uncertRows(icad) = sqrt(mean(mean(Ar * mp.rowPoly.covariance * Ar')));
        if length(mp.rowPoly(1).coeffs) == 1 && mp.rowPoly(1).coeffs == 0
            uncertRows(icad) = -1;
            disp(' ');
            disp(['Warning: invalid motion polynomial for row at cadence ' num2str(icad) '.']);
        end

        meanCols(icad)   = mean(starCol - mpCol);
        uncertCols(icad) = sqrt(mean(mean(Ac * mp.colPoly.covariance * Ac')));
        if length(mp.colPoly(1).coeffs) == 1 && mp.colPoly(1).coeffs == 0
            uncertCols(icad) = -1;
            disp(' ');
            disp(['Warning: invalid motion polynomial for column at cadence ' num2str(icad) '.']);
        end
    end

    centroidReport.centroidsMeanRow.values        = meanRows(:);
    centroidReport.centroidsMeanRow.uncertainties = uncertRows(:);
    centroidReport.centroidsMeanRow.gapIndicators = gapRows(:);

    centroidReport.centroidsMeanColumn.values        = meanCols(:);
    centroidReport.centroidsMeanColumn.uncertainties = uncertCols(:);
    centroidReport.centroidsMeanColumn.gapIndicators = gapCols(:);
return
