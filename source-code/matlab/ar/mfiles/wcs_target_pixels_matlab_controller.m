function outputStruct = wcs_target_pixels_matlab_controller(inputStruct)
%
% outputStruct = wcs_target_pixels_matlab_controller(inputStruct)
%
% DESCRIPTION:
%     The matlab sub-controller to generate WCS values. See main AR 
%     controller ar_matlab_controller.m for inputs and outputs.        
% 
% Copyright 2017 United States Government as represented by the
% Administrator of the National Aeronautics and Space Administration.
% All Rights Reserved.
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

    outputStruct = repmat(initializeOutputStruct(), 1, 0);
    if ~isfield(inputStruct, 'wcsInputs')
        warning('MATLAB:ar:wcs_target_pixels_matlab_controller', ...
                'Exiting WCS controller: no inputStruct.wcsInputs.wcsTargets field');
        return
    end
    nTargets = length(inputStruct.wcsInputs.wcsTargets);
    outputStruct = repmat(initializeOutputStruct(), 1, nTargets);
    if nTargets == 0
        return
    end
    
    if isempty(inputStruct.motionPolyBlobs)
        motionPolyStruct = [];
    else
        motionPolyStruct = poly_blob_series_to_struct(inputStruct.motionPolyBlobs);
    end

    for itarget = 1:nTargets
        if isempty(motionPolyStruct)
            [rotationMatrixPixToSky, plateScale, computedRowOneBased, computedColumnOneBased] = ...
                wcs_from_pix2radec(inputStruct, itarget);
        else
            [rotationMatrixPixToSky, plateScale, computedRowOneBased, computedColumnOneBased] = ...
                wcs_from_motion_polys(inputStruct, motionPolyStruct, itarget);
        end

        wcsTarget = inputStruct.wcsInputs.wcsTargets(itarget);
        pixelRowsZeroBased = [wcsTarget.pixelData.ccdRow];
        pixelColumnsZeroBased = [wcsTarget.pixelData.ccdColumn];

        colCornerOneBased = min(pixelColumnsZeroBased) + 1;
        rowCornerOneBased = min(pixelRowsZeroBased) + 1;
        
        outputStruct(itarget).keplerId = wcsTarget.keplerId;
        
        % ---pixel offsets of image within full frame---
        outputStruct(itarget).subimageReferenceColumn      = make_fits_struct('CRPIX1P',  1);
        outputStruct(itarget).subimageReferenceRow         = make_fits_struct('CRPIX2P',  1);
        outputStruct(itarget).originalImageReferenceColumn = make_fits_struct('CRVAL1P',  colCornerOneBased - 1); % return zero-based pixel coordinates for output
        outputStruct(itarget).originalImageReferenceRow    = make_fits_struct('CRVAL2P',  rowCornerOneBased - 1); % return zero-based pixel coordinates for output
        outputStruct(itarget).plateScaleColumn             = make_fits_struct('CRDELT1P', 1.0);
        outputStruct(itarget).plateScaleRow                = make_fits_struct('CRDELT2P', 1.0);

        % ---subimage pixel and sky reference points ---
        outputStruct(itarget).subimageCoordinateSystemReferenceColumn = make_fits_struct('CRPIX1',  computedColumnOneBased - colCornerOneBased + 1);
        outputStruct(itarget).subimageCoordinateSystemReferenceRow    = make_fits_struct('CRPIX2',  computedRowOneBased    - rowCornerOneBased + 1);

        isRaOrDecNan = isnan(wcsTarget.raDecimalHours) || ...
                       isnan(wcsTarget.decDegrees);
        if isRaOrDecNan
            [ra dec] = run_pix_2_ra_dec(inputStruct.raDec2PixModel, inputStruct.ccdModule, inputStruct.ccdOutput, wcsTarget.rowCentroid + 1, wcsTarget.columnCentroid + 1, refMjd); % wcsTarget row/column centroids are zero-based.
            outputStruct(itarget).outputRaDecsAreCalculated = true;
        else
            ra  = wcsTarget.raDecimalHours * 15.0;
            dec = wcsTarget.decDegrees;
        end
        outputStruct(itarget).subimageReferenceRightAscension = make_fits_struct('CRVAL1',  ra);
        outputStruct(itarget).subimageReferenceDeclination    = make_fits_struct('CRVAL2',  dec);

        %---unit matrix (rotation and reflection) representation--- 
        outputStruct(itarget).unitMatrixDegreesPerPixelColumn = make_fits_struct('CDELT1', -1 * plateScale); % in the sky, RA is column
        outputStruct(itarget).unitMatrixDegreesPerPixelRow    = make_fits_struct('CDELT2',      plateScale); % in the sky, DEC is row
        outputStruct(itarget).unitMatrixRotationMatrix11      = make_fits_struct('PC1_1',  -1 * rotationMatrixPixToSky(1,1));
        outputStruct(itarget).unitMatrixRotationMatrix12      = make_fits_struct('PC1_2',  -1 * rotationMatrixPixToSky(1,2));
        outputStruct(itarget).unitMatrixRotationMatrix21      = make_fits_struct('PC2_1',       rotationMatrixPixToSky(2,1));
        outputStruct(itarget).unitMatrixRotationMatrix22      = make_fits_struct('PC2_2',       rotationMatrixPixToSky(2,2));

        %---alternative representation---
        outputStruct(itarget).alternateRepresentationMatrix11 = make_fits_struct('CD1_1', plateScale*rotationMatrixPixToSky(1,1));
        outputStruct(itarget).alternateRepresentationMatrix12 = make_fits_struct('CD1_2', plateScale*rotationMatrixPixToSky(1,2));
        outputStruct(itarget).alternateRepresentationMatrix21 = make_fits_struct('CD2_1', plateScale*rotationMatrixPixToSky(2,1));
        outputStruct(itarget).alternateRepresentationMatrix22 = make_fits_struct('CD2_2', plateScale*rotationMatrixPixToSky(2,2));
    end

return

function fitsStruct = make_fits_struct(headerKeyword, value)
    fitsStruct = struct('headerKeyword', headerKeyword, 'value', value);
return

function ...
    [rotationMatrixPixToSky, plateScale,  computedRowOneBased, computedColumnOneBased, refMjd] = ...
    wcs_from_motion_polys(inputStruct, motionPolyStruct, itarget)

    targetStruct = inputStruct.wcsInputs.wcsTargets(itarget);
    
    refCadenceIndex = find([motionPolyStruct.cadence] == targetStruct.longCadenceReference);
    refMjd = motionPolyStruct(refCadenceIndex).mjdMidTime;
         
    if ~motionPolyStruct(refCadenceIndex).rowPolyStatus || ~motionPolyStruct(refCadenceIndex).colPolyStatus
        error('MATLAB:ar:wcs_target_pixels_matlab_controller', ...
            'The motion poly for target %d is gapped.  Exiting.', itarget);
    end

    % Interpolate motion polys if the data is short cadence:
    [motionPolyStruct refCadenceIndex] = interpolate_motion_polys_ar(inputStruct.cadenceType, motionPolyStruct, ...
     inputStruct.longCadenceTimesStruct, ...
     inputStruct.cadenceTimesStruct, refCadenceIndex);
    rowPoly = [motionPolyStruct.rowPoly];
    colPoly = [motionPolyStruct.colPoly];

    refRowPoly = rowPoly(refCadenceIndex);
    refColPoly = colPoly(refCadenceIndex);

    isBadRaDec = is_bad_ra_dec(targetStruct.raDecimalHours, targetStruct.decDegrees,...
                    targetStruct.isCustomTarget, targetStruct.keplerId);
    if isBadRaDec
        % targetStruct row/column centroids are zero-based.
        [targetRa targetDec] = run_pix_2_ra_dec(inputStruct.raDec2PixModel, inputStruct.ccdModule, inputStruct.ccdOutput, targetStruct.rowCentroid + 1, targetStruct.columnCentroid + 1, refMjd); % targetStruct row/column centroids are zero-based.
    else
        targetRa  = targetStruct.raDecimalHours * 15.0;
        targetDec = targetStruct.decDegrees;
    end
    
    %originy is the right ascension at the origin of the ccd mod/out?
    %refColPoly The column motion polynomial at the reference cadence.
    decFactor = cos(refColPoly.originy*pi()/180);
    invDec = [1/decFactor 0; 0 1];

    computedRowOneBased    = weighted_polyval2d(targetRa, targetDec, refRowPoly);
    computedColumnOneBased = weighted_polyval2d(targetRa, targetDec, refColPoly);

    %compute local numerical derivatives
    derivativeRowRa  = 10*(weighted_polyval2d(targetRa + 0.05, targetDec,        refRowPoly) - weighted_polyval2d(targetRa - 0.05, targetDec,        refRowPoly));
    derivativeRowDec = 10*(weighted_polyval2d(targetRa,        targetDec + 0.05, refRowPoly) - weighted_polyval2d(targetRa,        targetDec - 0.05, refRowPoly));
    derivativeColRa  = 10*(weighted_polyval2d(targetRa + 0.05, targetDec,        refColPoly) - weighted_polyval2d(targetRa - 0.05, targetDec,        refColPoly));
    derivativeColDec = 10*(weighted_polyval2d(targetRa,        targetDec + 0.05, refColPoly) - weighted_polyval2d(targetRa,        targetDec - 0.05, refColPoly));

    
    [plateScale rotationMatrixPixToSky] = ...
    plate_scale_and_rotation_matrix(derivativeRowRa, derivativeRowDec, ...
                                    derivativeColRa, derivativeColDec, invDec);
return


function ...
    [rotationMatrixPixToSky, plateScale,  computedRowOneBased, computedColumnOneBased] = ...
    wcs_from_pix2radec(inputStruct,  itarget) 

    targetStruct = inputStruct.wcsInputs.wcsTargets(itarget);
    cadenceIndex = find([inputStruct.longCadenceTimesStruct.cadenceNumbers] == targetStruct.longCadenceReference);
    refMjd = inputStruct.longCadenceTimesStruct.midTimestamps(cadenceIndex);
    
    isBadRaDec = is_bad_ra_dec(targetStruct.raDecimalHours, targetStruct.decDegrees, targetStruct.isCustomTarget, targetStruct.keplerId);
             
    raDec2PixObject = raDec2PixClass(inputStruct.raDec2PixModel, 'one-based');
    
    % targetStruct row/column centroids are zero-based.
    if isBadRaDec
        [targetRa targetDec] = pix_2_ra_dec(raDec2PixObject, ...
                                    inputStruct.ccdModule, inputStruct.ccdOutput, ...
                                    targetStruct.rowCentroid + 1, targetStruct.columnCentroid + 1, ...
                                    refMjd);
    else
        targetRa  = targetStruct.raDecimalHours * 15.0;
        targetDec = targetStruct.decDegrees;
    end
    % You can get these out of the config map or FCConstants, but let's not
    % do that.
    % This uses the center of the mod/out because this is how the motion
    % polynomials are generated.
    centerCcdRowOneBased = (21+1044)/2;
    centerCcdColOneBased = (13+1112)/2;
    
    [~, decCenter] = pix_2_ra_dec(raDec2PixObject, ...
                                 inputStruct.ccdModule, inputStruct.ccdOutput, ...
                                 centerCcdRowOneBased, centerCcdColOneBased, ...
                                 refMjd);
    decFactor = cos(decCenter*pi()/180);
    invDec = [1/decFactor 0; 0 1];

    % If we had a better position model then we would use it to generate
    % residuals, but we don't have one so we just assume everything is
    % perfect.
    [~, ~, computedRowOneBased, computedColumnOneBased] = ...
        ra_dec_2_pix(raDec2PixObject, targetRa, targetDec, refMjd);
 
    %compute local numerical derivatives
    gridDelta = 0.05;
    derivativeGridPointRa = [targetRa + gridDelta; targetRa - gridDelta; ...
                             targetRa ; targetRa];
    derivativeGridPointDec = [ targetDec; targetDec; ...
                                targetDec + gridDelta; targetDec - gridDelta];
    mjds = zeros(length(derivativeGridPointRa), 1) + refMjd;
    
    [~, ~, derivativeRows, derivativeCols] = ...
        ra_dec_2_pix(raDec2PixObject, derivativeGridPointRa, derivativeGridPointDec, mjds);
        
    derivativeRowRa  = 10 * (derivativeRows(1) - derivativeRows(2));
    derivativeRowDec = 10 * (derivativeRows(3) - derivativeRows(4));
    derivativeColRa  = 10 * (derivativeCols(1) - derivativeCols(2));
    derivativeColDec = 10 * (derivativeCols(3) - derivativeCols(4));

    [plateScale rotationMatrixPixToSky] = ...
    plate_scale_and_rotation_matrix(derivativeRowRa, derivativeRowDec, ...
                                    derivativeColRa, derivativeColDec, invDec);
return

function wellIsIt = is_bad_ra_dec(ra, dec, isCustomTarget, keplerId)
    if ra == 0 || dec == 0 || isnan(ra) || isnan(dec)
        if isCustomTarget
            wellIsIt = true;
        else
            error('Catalog target %d has invalid RA/DEC.\n', keplerId);
        end
    else
        wellIsIt = false;
    end
return

function [plateScale rotationMatrixPixToSky] = ...
    plate_scale_and_rotation_matrix(derivativeRowRa, derivativeRowDec, ...
                                    derivativeColRa, derivativeColDec, invDec)
    % Calculate plate scale and rotation matrix:
    %
    B = zeros(2);
    B(2, 1) = derivativeRowRa;
    B(2, 2) = derivativeRowDec;
    B(1, 1) = derivativeColRa;
    B(1, 2) = derivativeColDec;
    A = B*invDec;
    Ainv = inv(A);
    plateScale = sqrt(abs(det(Ainv)));
    rotationMatrixPixToSky = Ainv/plateScale;                     
return

function outputStruct = initializeOutputStruct()
    % ---pixel offsets of image within full frame---
    outputStruct.subimageReferenceColumn      = make_fits_struct('CRPIX1P',  1);
    outputStruct.subimageReferenceRow         = make_fits_struct('CRPIX2P',  1);
    outputStruct.originalImageReferenceColumn = make_fits_struct('CRVAL1P',  nan);
    outputStruct.originalImageReferenceRow    = make_fits_struct('CRVAL2P',  nan);
    outputStruct.plateScaleColumn             = make_fits_struct('CRDELT1P', 1.0);
    outputStruct.plateScaleRow                = make_fits_struct('CRDELT2P', 1.0);

    % ---subimage pixel and sky reference points ---
    outputStruct.subimageCoordinateSystemReferenceColumn   = make_fits_struct('CRPIX1',  nan);
    outputStruct.subimageCoordinateSystemReferenceRow      = make_fits_struct('CRPIX2',  nan);
    outputStruct.subimageReferenceRightAscension           = make_fits_struct('CRVAL1',  nan); % ra at crpix1,crpix2
    outputStruct.subimageReferenceDeclination              = make_fits_struct('CRVAL2',  nan); % dec at crpix1,crpix2

    %---unit matrix (rotation and reflection) representation---
    outputStruct.unitMatrixDegreesPerPixelColumn = make_fits_struct('CDELT1', nan);
    outputStruct.unitMatrixDegreesPerPixelRow    = make_fits_struct('CDELT2', nan);
    outputStruct.unitMatrixRotationMatrix11      = make_fits_struct('PC1_1',  nan);
    outputStruct.unitMatrixRotationMatrix12      = make_fits_struct('PC1_2',  nan);
    outputStruct.unitMatrixRotationMatrix21      = make_fits_struct('PC2_1',  nan);
    outputStruct.unitMatrixRotationMatrix22      = make_fits_struct('PC2_2',  nan);

    %---alternative representation---
    outputStruct.alternateRepresentationMatrix11 = make_fits_struct('CD1_1', nan);
    outputStruct.alternateRepresentationMatrix12 = make_fits_struct('CD1_2', nan);
    outputStruct.alternateRepresentationMatrix21 = make_fits_struct('CD2_1', nan);
    outputStruct.alternateRepresentationMatrix22 = make_fits_struct('CD2_2', nan);
    
    outputStruct.keplerId = 0;
    outputStruct.outputRaDecsAreCalculated = false;
return
