function background = adjusted_background_pixel_matlab_controller(inputStruct)
%
% background = adjustedBackgroundPixelClass(inputStruct)
%
% DESCRIPTION:
%     The matlab controller to generate new background pixel values, using 
%     the background polynomials. See main AR controller 
%     ar_matlab_controller.m for inputs and outputs. 
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




    % Read the cadences from inputStruct to allocate the background struct size:
    %
    cadenceTimes = inputStruct.cadenceTimesStruct;
    nCadences = length(cadenceTimes.cadenceNumbers);

    % Preallocate output struct:
    %
    initBackgroundStruct = struct('ccdRow', [], ...
                                  'ccdColumn', [], ...
                                  'background', [], ...
                                  'backgroundGaps', [], ...
                                  'backgroundUncertainties', [], ...
                                  'backgroundUncertaintyGaps', []);

    % Return the empty background struct now if there are no pixels
    % specified in the inputs:
    %
    isPixelInputsEmpty = isempty(inputStruct.backgroundInputs.pixelCoordinates);
    if isPixelInputsEmpty
        background = repmat(initBackgroundStruct, 1, 0);
        return;
    end

    rowsZeroBased    = [inputStruct.backgroundInputs.pixelCoordinates.ccdRow];
    columnsZeroBased = [inputStruct.backgroundInputs.pixelCoordinates.ccdColumn];
    rowsOneBased = rowsZeroBased + 1;
    columnsOneBased = columnsZeroBased + 1;
    
    nPixels = length(rowsZeroBased);
    background = repmat(initBackgroundStruct, 1, nPixels);
    

    % Read inputs from inputStruct:
    %
    debugFlag       = inputStruct.debugFlag;
    ccdModule       = inputStruct.ccdModule;
    ccdOutput       = inputStruct.ccdOutput;
    backgroundBlobs = inputStruct.backgroundInputs.backgroundBlobs;
    configMapObject = configMapClass(inputStruct.configMaps);
    cadenceType     = inputStruct.cadenceType;

    % Generate the adjusted background pixel values from the pixel coordinates
    %
    backgroundValues = zeros(nCadences, nPixels);
    backgroundUncertainties = zeros(size(backgroundValues));
    backgroundGaps = zeros(nCadences, 1);
    backgroundUncertaintyGaps = zeros(size(backgroundGaps));

    % scale for cadence type, fill data gaps and interpolate polynomial at cadenceTimes.midTimestamps
    % needs full cadenceTimes structure from PA inputsStruct
    backgroundPolyStruct = poly_blob_series_to_struct(backgroundBlobs);
    backgroundPolyStruct = fill_background_polynomial_struct_array(backgroundPolyStruct, configMapObject, cadenceTimes, cadenceType);

    for icadence = 1:nCadences
        backgroundPoly = backgroundPolyStruct(icadence).backgroundPoly;

        switch cadenceType
            case {'LONG', 'long', 'SHORT', 'short'}
                [vals uncerts] = weighted_polyval2d(rowsOneBased(:), columnsOneBased(:), backgroundPoly);
%             case {'FFI', 'ffi'}
%                 % TODO do something else, maybe this?
%                 % TODO Bruce says FFIs are currently not supported in the PA code (which this calls):
%                        Quote from email:
%                               If [users] really want a full frame of background values we could generate them
%                               from the background polynomials but I will have to modify
%                               fill_background_polynomial_struct to support cadenceType = 'FFI'.
%
%                 [rows cols] = meshgrid(CCD_ROWS, CCD_COLUMNS);
%                 [vals uncerts] = weighted_polyval2d(rows, cols, backgroundPoly);
            otherwise
                error('Illegal value of cadenceType: %s', cadenceType);
        end
        % Insert vals and uncerts row-wise into the backgroundValues and
        % backgroundUncertainties matrices:
        %
        backgroundValues(icadence, :) = vals(:);
        backgroundUncertainties(icadence, :) = uncerts(:);
    end

    % Package the data into per-pixel structs in the output struct:
    %
    for ipixel = 1:nPixels
        background(ipixel).ccdRow = rowsZeroBased(ipixel);
        background(ipixel).ccdColumn = columnsZeroBased(ipixel);
        
        background(ipixel).background = backgroundValues(:,ipixel);
        background(ipixel).backgroundUncertainties = backgroundUncertainties(:,ipixel);

        background(ipixel).backgroundGaps = cadenceTimes.gapIndicators;
        background(ipixel).backgroundUncertaintyGaps = cadenceTimes.gapIndicators;
    end
    
return
