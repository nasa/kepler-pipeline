
function flatFieldObject = flatFieldClass(flatFieldData, interpolation_method)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function flatFieldObject = flatFieldClass(flatFieldData)
% or
% function flatFieldObject = flatFieldClass(flatFieldData, interpolation_method)
%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Construct a flatFieldObject from the results of retrieve_flat_field_model.
% The get_flat_field routine extracts the data for the correct timestamp.
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

% Revision record:
% BC - 4/18/14
%       - Repair support for building object with specified rows and columns passed in through flatFieldModel.rows and flatFieldModel.columns.
%       These are assumed to be 0-based.
%       - Move instantiation of flatFieldObject to end.
%       - Pre-allocate space for output in subfunction get_large_flat.m


if nargin < 2
    flatFieldData.interpolation_method = 'linear';
else
    flatFieldData.interpolation_method = interpolation_method;
end

fieldsAndBounds = cell(2,4);
fieldsAndBounds(1,:)  = { 'rows';    []; []; []};
fieldsAndBounds(2,:)  = { 'columns';    []; []; []};

if(isfield(flatFieldData,'rows') &&  isfield(flatFieldData, 'columns'))
    if(~isempty(flatFieldData.rows) && ~isempty(flatFieldData.columns))
        fieldsAndBounds(1,:)  = { 'rows';    '>= 0'; '<= 1069'; []};
        fieldsAndBounds(2,:)  = { 'columns'; '>= 0'; '<= 1131'; []};
    end
end
validate_structure(flatFieldData, fieldsAndBounds, 'flatFieldData');

% Sanity check on non-image data members:
fc_mjd_check(flatFieldData.mjds);
if isfield(flatFieldData, 'rows')
    fc_nonimage_data_check(flatFieldData.rows);
    fc_nonimage_data_check(flatFieldData.columns);
    if (length(flatFieldData.rows) ~= length(flatFieldData.columns))
        error('Matlab:FC:FlatFieldClass', 'row or columns are not the same length');
    end

    % 0-based pixel addresses, since this is still from-java addresses:
    if any(flatFieldData.rows > flatFieldData.ccdRows + 1) || ...
            any(flatFieldData.rows < 0) || ... 
            any(flatFieldData.columns > flatFieldData.ccdColumns + 1) || ...
            any(flatFieldData.columns < 0)
        error('Matlab:FC:FlatFieldClass', 'row or columns arguments are out-of-band');
    end
end


% Transform from zero-based Java row/cols to one-based MATLAB row/cols:
flatFieldData.rows = flatFieldData.rows + 1;
flatFieldData.columns = flatFieldData.columns + 1;

% This loop is unavoidable b/c of the constants(i).array(j) structure of
% the constants structure in the flatFieldData from
% retrieve_flat_field_model (to match module parameters).
nTimes = length(flatFieldData.mjds);
nRows  = length(flatFieldData.flats(1).array);
nCols  = length(flatFieldData.flats(1).array(1).array);

if 0 == nTimes && 0 == nRows && 0 == nCols
    error('MATLAB:flatFieldClass:flatFieldClass', 'No data in constructor, error')
end

% preallocate
flats = zeros(nTimes, nRows, nCols);
uncertainties = zeros(size(flats));

% make rows and columns indices column vectors
flatFieldData.rows = flatFieldData.rows(:);
flatFieldData.columns = flatFieldData.columns(:);

if isempty(flatFieldData.rows)
    newflats = flats;
    newuncertainties = uncertainties;
else
    newflats = zeros(nTimes, length(flatFieldData.rows));
    newuncertainties = zeros(size(newflats));
end

for iTime = 1:nTimes

    % need this loop since we must support models where flats.array(1).array == [1 x 1132] OR [1132 x 1]. i.e can't use [ ]' concatenation
    % and count on getting a 1070 x 1132 2D array
    for iRow = 1:nRows
        flats(iTime, iRow, :) = flatFieldData.flats(iTime).array(iRow).array;
        uncertainties(iTime, iRow, :) = flatFieldData.uncertainties(iTime).array(iRow).array;
    end

    % Get large flat and apply it
    flatPolyStruct = get_flat_poly_struct(flatFieldData, iTime);
    largeFlatImage = get_large_flat(flatPolyStruct);
        
    if isempty(flatFieldData.rows)
        % make whole 1070 x 1132 flat image
        newflats(iTime, :, :) = squeeze(flats(iTime, :, :)) .* largeFlatImage;
        newuncertainties(iTime, :, :) = squeeze(uncertainties(iTime, :, :));                % assumes uncertainties = 0 on all large flat values
    else
        % make partial flat image
        largeFlatIndex = sub2ind(size(largeFlatImage), flatFieldData.rows(:)', flatFieldData.columns(:)');
        pixelsLarge = largeFlatImage(largeFlatIndex)';
        
        pixelsFlat = squeeze(flats(iTime, :, :));
        pixelsUnc = squeeze(uncertainties(iTime, :, :));
        
        % if full 1070 x 1132 was passed in extract the flat values for the rows/cols pairs
        % otherwise assume nPixels x 1 array passed in corresponds to rows/cols pairs passed in
        if isequal(size(pixelsFlat),[flatFieldData.ccdRows,flatFieldData.ccdColumns])        
            pixelsFlat = pixelsFlat(largeFlatIndex);     
            pixelsUnc = pixelsUnc(largeFlatIndex);
        end
        
        newflats(iTime, :) = pixelsFlat(:) .* pixelsLarge(:);
        newuncertainties(iTime, :) = pixelsUnc(:);                                          % assumes uncertainties = 0 on all large flat values
    end
end

% Do a sanity check on the data:
fc_image_data_check(newflats, newuncertainties);

% update fields and make object
flatFieldData.flats = newflats;
flatFieldData.uncertainties = newuncertainties;
flatFieldObject = class(flatFieldData, 'flatFieldClass');

return


function flatPolyStruct = get_flat_poly_struct(flat_field_data, iTimeModelIndex)
flatPolyStruct = struct(...
    'coeffs', ...
    'covariance', ...
    'order', ...
    'type', ...
    'offsetx', ...
    'scalex', ...
    'originx', ...
    'offsety', ...
    'scaley', ...
    'originy' );

flatPolyStruct.coeffs = flat_field_data.coeffs(iTimeModelIndex).array;

tmpCovars = flat_field_data.covars(iTimeModelIndex).array;

flatPolyStruct.covariance = reshape(tmpCovars, sqrt(length(tmpCovars)), sqrt(length(tmpCovars)));

flatPolyStruct.order = flat_field_data.polynomialOrder(iTimeModelIndex);
flatPolyStruct.type = 'standard'; % char(flat_field_data.type(iTimeModelIndex));
flatPolyStruct.offsetx = flat_field_data.offsetX(iTimeModelIndex);
flatPolyStruct.scalex = flat_field_data.scaleX(iTimeModelIndex);
flatPolyStruct.originx = flat_field_data.originX(iTimeModelIndex);
flatPolyStruct.offsety = flat_field_data.offsetY(iTimeModelIndex);
flatPolyStruct.scaley = flat_field_data.scaleY(iTimeModelIndex);
flatPolyStruct.originy = flat_field_data.originY(iTimeModelIndex);
return



function largeScaleFlatModOut = get_large_flat(flatPolyStruct)
    % function largeScaleFlatModOut = get_large_flat(flatPolyStruct)
    %
    % flatPolyStruct should be the reconstructed polynomial fit structure for the module/output

    import gov.nasa.kepler.common.FcConstants;
    firstImageRow = FcConstants.nMaskedSmear + 1; %21
    lastImageRow  = FcConstants.nMaskedSmear + FcConstants.nRowsImaging; %1044
    firstImageColumn = FcConstants.nLeadingBlack + 1; %13
    lastImageColumn  = FcConstants.nColsImaging + FcConstants.nLeadingBlack; %1112
    NCCDROWS   = FcConstants.CCD_ROWS; %1070
    NCCDCOLS   = FcConstants.CCD_COLUMNS; %1132

    [X,Y] = meshgrid(firstImageRow:lastImageRow, firstImageColumn:lastImageColumn);
    [nFitRows, nFitCols] = size(X);

    xvec = X(:);  % grid points in vector form for fitting routine
    yvec = Y(:);
    ngridPoints = length(xvec);
    nRegions = 100;
    nFitInd = ngridPoints/nRegions;  % break evaluation into 100 regions
    
    % pre-allocate for speed
    zModFit = nan(nFitInd * nRegions,1);

%     zModFit=[];  % image for i_th module/output
    for j=1:nRegions
        ind = (1:nFitInd) + (j-1)*nFitInd;
        zt = weighted_polyval2d(xvec(ind), yvec(ind), flatPolyStruct);
%         zModFit = [zModFit; zt];
        zModFit(ind) = zt;
    end
    zModFit = reshape(zModFit, nFitRows, nFitCols)';  % put in active image format
    % note transpose

    % put flat into full-size image, with collateral regions set to one.
    largeScaleFlatModOut = ones(NCCDROWS,NCCDCOLS); % set up full-size image
    largeScaleFlatModOut(firstImageRow:lastImageRow,firstImageColumn:lastImageColumn)=zModFit;
return
