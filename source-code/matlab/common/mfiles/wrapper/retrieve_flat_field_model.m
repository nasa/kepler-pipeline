function flatFieldData = retrieve_flat_field_model(module, output, startMjd, endMjd, rows, cols)
% function flatFieldData = retrieve_flat_field_model(module, output, startMjd, endMjd, rows, cols)
% or
% function flatFieldData = retrieve_flat_field_model(module, output, startMjd, endMjd)
% or
% function flatFieldData = retrieve_flat_field_model(module, output)
% 
% Returns a matlab FlatFieldData struct that contains data necessary to
% determine the flatField for any pixel on the focal plane at times between
% startMjd and endMjd.  If the rows and cols arguments are specified, only data
% for those (row,column) combinations are retrieved. This struct can be used
% as the argument to the FlatFieldClass constructor to create a FlatFieldClass
% object.
% 
% Rows and cols input args should be one-based.
%
% The data are the flat field values for the individual pixels.
% 
% The six-arg call gets only the pixels on that module/output specified by the row/col vectors (pixels specified pairwise) for the specified time range.
% The four-arg call gets full images for that module/output for the specified time range
% The three-arg call is used for testing, and disables the large-flat
% multiplication
% The two-arg call gets full images for that module/output for the entire mission.
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

import gov.nasa.kepler.systest.sbt.SandboxTools;
SandboxTools.displayDatabaseConfig;

    if nargin ~= 2 && nargin ~= 3 && nargin ~= 4 && nargin ~= 6
        error('bad number of args in retrieve_flat_field_model: usage is retrieve_flat_field_model(module, output, mjdStart, mjdEnd, rows, cols), retrieve_flat_field_model(module, output, mjdStart, mjdEnd), or retrieve_flat_field_model(module, output)');
    end

    % check mod/out for valid range/empty:
    % check row/col for valid range/empty:


    if length(module) > 1 || length(output) > 1 || nargin > 3 && (length(startMjd) > 1 || length(endMjd) > 1)
        error('module, output, startMjd, and endMjd must all be single-valued, not vectors');
    end

    if 6 == nargin && (length(rows) ~= length(cols))
        error('Rows and cols must be same length, if pixels are specified.');
    end

    import gov.nasa.kepler.fc.FlatFieldModel;
    import gov.nasa.kepler.fc.flatfield.FlatFieldOperations;
    ops = FlatFieldOperations();
    
    if nargin == 6
        model = ops.retrieveFlatFieldModel(startMjd, endMjd, module, output, rows-1, cols-1);  %N.B.: -1 for java indexing
    elseif nargin == 4
        model = ops.retrieveFlatFieldModel(startMjd, endMjd, module, output);
        rows = [];
        cols = [];
    elseif nargin == 2 || nargin == 3
        model = ops.retrieveMostRecentFlatFieldModel(module, output);
        rows = [];
        cols = [];
    end
    
    flatFieldData = struct(  ...
        'mjds',          [], ...
        'rows',          [], ...
        'columns',       [], ...
        'flats',         [], ...
        'uncertainties', [],  ...
        'ccdRows',     model.getCcdRows(), ...
        'ccdColumns',  model.getCcdColumns());
    flatFieldData.mjds    = model.getMjds();
    flatFieldData.rows    = rows - 1; % transform to Java-based pixel coords to match the module interface
    flatFieldData.columns = cols - 1; % transform to Java-based pixel coords to match the module interface
    
    % Mimic .array.array construction that comes out of Persistent code:
    %
    flats         = model.getFlats();
    uncertainties = model.getUncertainties();
    
    nTimes = length(flatFieldData.mjds);
    
    for itime=1:nTimes
        
        flatForTime = squeeze(flats(itime, :, :));
        uncertaintyForTime = squeeze(uncertainties(itime, :, :));

        %if nargin ~= 3
        % Add large flat:
        %
        %flatPolyStruct = get_flat_poly_struct(model);
        %flatFieldData.largeFlatPolyStruct = flatPolyStruct;

        flatFieldData.coeffs(itime).array          = model.getCoeffs(itime-1);
        flatFieldData.covars(itime).array          = model.getCovars(itime-1);
        flatFieldData.polynomialOrder(itime)       = model.getPolynomialOrder(itime-1);
        flatFieldData.type{itime}                  = 'standard'; 
        flatFieldData.xIndex(itime)                = model.getXIndex(itime-1);
        flatFieldData.offsetX(itime)               = model.getOffsetX(itime-1);
        flatFieldData.scaleX(itime)                = model.getScaleX(itime-1);
        flatFieldData.originX(itime)               = model.getOriginX(itime-1);
        flatFieldData.yIndex(itime)                = model.getYIndex(itime-1);
        flatFieldData.offsetY(itime)               = model.getOffsetY(itime-1);
        flatFieldData.scaleY(itime)                = model.getScaleY(itime-1);
        flatFieldData.originY(itime)               = model.getOriginY(itime-1);

        if nargin == 6
            nPix = size(flatForTime, 1);
            for ipix = 1:nPix
                flatFieldData.flats(itime).array(ipix).array = flatForTime(ipix);
                flatFieldData.uncertainties(itime).array(ipix).array = uncertaintyForTime(ipix);
            end
        else
            nRows = size(flatForTime, 1);
            for irow = 1:nRows
                flatFieldData.flats(itime).array(irow).array = flatForTime(irow, :);
                flatFieldData.uncertainties(itime).array(irow).array = uncertaintyForTime(irow, :);
            end
        end
    end

    import gov.nasa.kepler.hibernate.fc.HistoryModelName
    flatFieldData.fcModelMetadataLargeFlat = get_model_metadata(model.getFcModelMetadataLargeFlat);
    flatFieldData.fcModelMetadataSmallFlat = get_model_metadata(model.getFcModelMetadataSmallFlat);

    import gov.nasa.kepler.hibernate.dbservice.DatabaseServiceFactory;
    dbInstance = DatabaseServiceFactory.getInstance();
    dbInstance.clear();

SandboxTools.close;
return

