function diaregObject = diaregClass(diaregInputStruct)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function diaregObject = diaregClass(diaregInputStruct)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% 
% background pixel apertures first lays down a grid of initial positions on
% the module output.  This grid is stretched to have a higher density near
% the edges of the output.  The grid nodes are used as initial positions
% for background apertures, which are then moved slightly to appropriate
% background pixels.
%
% diaregInputStruct is a structure with the following fields:
%   .targetStarStruct(): 1D array of structures describing targets that contain
%       at least the following fields:
%       .pixelTimeSeriesStruct() # of pixels x 1 array of structures
%           descrbing pixels that contain the following fields:
%           .timeSeries() # of cadences x 1 array containing pixel brightness
%               time series.  
%           .uncertainties() # of cadences x 1 array containing pixel
%               uncertainty time series.  
%           .gapList() # of gaps x 1 array containing the index of gaps in
%               .timeSeries
%           .row row of this pixel
%           .column column of this pixel
%           .isInOptimalAperture flag that when true indicates this pixel is in
%               the target's optimal aperture
%       .referenceRow row relative to which the pixels in the target are
%           located, typically the row of the target centroid
%       .referenceColumn column relative to which the pixels in the target are
%           located, typically the column of the target centroid
%       .gapList() # of gaps x 1 array containing the index of target-level gaps in
%           .targetStarStruct
%   .motionPolyStruct(): possibly empty # of cadences array of structures,
%       one for each cadence, containing at least the following fields:
%       .rowCoeff, .columnCoeff: structures describing the row and column
%           motion across the module output as returned by
%           weighted_polyfit2d()
%       If this structure is empty a simple centroid motion detection
%       method is used to fill it. 
%   .motionGaps(): possibly empty list of indices into .motionPolyStruct for which the
%       structure may be invalid.  May be empty
%   .backgroundCoeffStruct() 1 x # of cadences array of polynomial
%       coefficient structs as returned by robust_polyfit2d()
%   .backgroundGaps(): list of indices into .backgroundCoeffStruct for which the
%       structure may be invalid.  May be empty
%   .cosmicRayConfigurationStruct: structure containing various
%       configuration values as returned by build_cr_configuration_struct()
%   .backgroundConfigurationStruct: structure containing various
%       configuration values as returned by build_background_configuration_struct()
%   .diaregConfigurationStruct: structure containing various control
%       paramters for diareg with fields
%       .startCadence, .endCadence start and end cadence for this run of
%           diareg
%       .motionPolynomialOrder order of the motion polynomial output
%       .iterativeRegistration flag indicating if the full iterative dia
%           registration method is invoked
%       .cleanCosmicRays flag to indicate target pixels should be cleaned
%           of cosmic rays before centroiding
%
% output: adds the following field to the diaregObject:
%   .motionCoeffStruct 1 x # of cadences array of polynomial
%       coefficient structs describing image motion as returned by
%       robust_polyfit2d() 
%   The following fields of targetStarStruct are filled in during the
%       operation of diareg: 
%       .rowCentroid(), centroidColumn() 1 x # of cadences array of row and
%           column centroids of the target stars.  
%       adds to each element of pixelTimeSeriesStruct:
%       .crCleanedSeries() same as field .timeSeries with cosmic rays removed
%           from non-gap entries.  
%       .cosmicRayIndices() # of cosmic ray events x 1 array of indices in
%           .crCleanedSeries of cosmic ray events 
%       .cosmicRayDeltas() array of same size as .cosmicRayIndices containing
%           the change in values in .crCleanedSeries from .timeSeries so
%           .timeSeries(.cosmicRayIndices) =
%           .crCleanedSeries(.cosmicRayIndices) + .cosmicRayDeltas
%
%
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

if nargin == 0
    % if no inputs generate an error
    error('PA:diaregClass:EmptyInputStruct',...
        'The constructor must be called with an input structure.');
else
    % check the fields of backgroundConfigurationStruct
    if(~isfield(diaregInputStruct, 'backgroundConfigurationStruct'))
        error('PA:diaregClass:missingField:backgroundConfigurationStruct',...
            'backgroundConfigurationStruct: field not present in the input structure.')
    end
    check_background_configuration_struct(...
        diaregInputStruct.backgroundConfigurationStruct, 'PA:diaregClass');

    % check the fields of cosmicRayConfigurationStruct
    if(~isfield(diaregInputStruct, 'cosmicRayConfigurationStruct'))
        error('PA:diaregClass:missingField:cosmicRayConfigurationStruct',...
            'cosmicRayConfigurationStruct: field not present in the input structure.')
    end
    check_cosmic_ray_configuration_struct(...
        diaregInputStruct.cosmicRayConfigurationStruct, 'PA:diaregClass');

    % check the fields of motionPolyStruct
    if(~isfield(diaregInputStruct, 'motionPolyStruct'))
        error('PA:diaregClass:missingField:motionPolyStruct',...
            'motionPolyStruct: field not present in the input structure.')
    elseif ~isempty(diaregInputStruct.motionPolyStruct)
        if(~isfield(diaregInputStruct.motionPolyStruct, 'rowCoeff'))
            error('PA:diaregClass:missingField:motionPolyStruct:rowCoeff',...
                'rowCoeff: field not present in the input structure.')
        else
            check_poly2d_struct([diaregInputStruct.motionPolyStruct.rowCoeff],...
                'PA:diaregClass');
        end
        if(~isfield(diaregInputStruct.motionPolyStruct, 'columnCoeff'))
            error('PA:diaregClass:missingField:motionPolyStruct:columnCoeff',...
                'columnCoeff: field not present in the input structure.')
        else
            check_poly2d_struct([diaregInputStruct.motionPolyStruct.columnCoeff],...
                'PA:diaregClass');
        end
    end

    % check the fields of backgroundCoeffStruct
    if(~isfield(diaregInputStruct, 'backgroundCoeffStruct'))
        error('PA:diaregClass:missingField:backgroundCoeffStruct',...
            'backgroundCoeffStruct: field not present in the input structure.')
    else
        check_poly2d_struct(diaregInputStruct.backgroundCoeffStruct,...
            'PA:diaregClass');
    end

    % check the fields in each entry of targetStarStruct
    if(~isfield(diaregInputStruct, 'targetStarStruct'))
        error('PA:diaregClass:missingField:targetStarStruct',...
            'targetStarStruct: field not present in the input structure.')
    end
    
    % check_struct does not work on arrays of structures with fields that
    % are arrays, so do these individually
    
    nTargets = length(diaregInputStruct.targetStarStruct);
    for target=1:nTargets
        % check .pixelTimeSeriesStruct
        if(~isfield(diaregInputStruct.targetStarStruct(target), 'pixelTimeSeriesStruct'))
            error('PA:diaregClass:missingField:targetStarStruct:pixelTimeSeriesStruct',...
                'pixelTimeSeriesStruct: field not present in the input structure.')
        end
        % check .timeSeries
        if(~isfield(diaregInputStruct.targetStarStruct(target).pixelTimeSeriesStruct, 'timeSeries'))
            error('PA:diaregClass:missingField:targetStarStruct:pixelTimeSeriesStruct:timeSeries',...
                'timeSeries: field not present in the input structure.')
        end
        % look for Nan or Inf
        if any(any(~isfinite([diaregInputStruct.targetStarStruct(target).pixelTimeSeriesStruct.timeSeries])))
            error('PA:diaregClass:rangeCheck:targetStarStruct:pixelTimeSeriesStruct:timeSeries',...
                'timeSeries: contains a Nan or Inf.')
        end
        % check range
        if ~all(all([diaregInputStruct.targetStarStruct(target).pixelTimeSeriesStruct.timeSeries] > -1e3 ))
            error('PA:diaregClass:rangeCheck:targetStarStruct:pixelTimeSeriesStruct:timeSeries',...
                'timeSeries: not all > -1e3.')
        end
        if ~all(all([diaregInputStruct.targetStarStruct(target).pixelTimeSeriesStruct.timeSeries] <= 1e9 ))
            error('PA:diaregClass:rangeCheck:targetStarStruct:pixelTimeSeriesStruct:timeSeries',...
                'timeSeries: not all <= 1e9.')
        end

        % check .uncertainties
        if(~isfield(diaregInputStruct.targetStarStruct(target).pixelTimeSeriesStruct, 'uncertainties'))
            error('PA:diaregClass:missingField:targetStarStruct:pixelTimeSeriesStruct:uncertainties',...
                'timeSeries: field not present in the input structure.')
        end
        % look for Nan or Inf
        if any(any(~isfinite([diaregInputStruct.targetStarStruct(target).pixelTimeSeriesStruct.uncertainties])))
            error('PA:diaregClass:rangeCheck:targetStarStruct:pixelTimeSeriesStruct:uncertainties',...
                'timeSeries: contains a Nan or Inf.')
        end
        % check range
        if ~all(all([diaregInputStruct.targetStarStruct(target).pixelTimeSeriesStruct.uncertainties] >= 0 ))
            error('PA:diaregClass:rangeCheck:targetStarStruct:pixelTimeSeriesStruct:uncertainties',...
                'uncertainties: not all > -1e3.')
        end
        if ~all(all([diaregInputStruct.targetStarStruct(target).pixelTimeSeriesStruct.uncertainties] <= 1e6 ))
            error('PA:diaregClass:rangeCheck:targetStarStruct:pixelTimeSeriesStruct:uncertainties',...
                'uncertainties: not all <= 1e6.')
        end

        % check .gaplist.  This is complicated since the lists for different
        % pixels are of different lengths so we can't concatenate
        if(~isfield(diaregInputStruct.targetStarStruct(target).pixelTimeSeriesStruct, 'gapList'))
            error('PA:diaregClass:missingField:targetStarStruct:gapList',...
                'gapList: field not present in the input structure.')
        end
        nPixels = length(diaregInputStruct.targetStarStruct(target).pixelTimeSeriesStruct);
        for pixel = 1:nPixels
            % look for Nan or Inf
            if any(~isfinite([...
                    diaregInputStruct.targetStarStruct(target).pixelTimeSeriesStruct(pixel).gapList]))
                error('PA:diaregClass:rangeCheck:targetStarStruct:pixelTimeSeriesStruct:gapList',...
                    'gapList: contains a Nan or Inf.')
            end
            % check range
            if ~all([diaregInputStruct.targetStarStruct(target).pixelTimeSeriesStruct(pixel).gapList] >= 0 )
                error('PA:diaregClass:rangeCheck:targetStarStruct:pixelTimeSeriesStruct:gapList',...
                    'gapList: not all > -1e3.')
            end
            if ~all([diaregInputStruct.targetStarStruct(target).pixelTimeSeriesStruct(pixel).gapList] <= 1e6 )
                error('PA:diaregClass:rangeCheck:targetStarStruct:pixelTimeSeriesStruct:gapList',...
                    'gapList: not all <= 1e6.')
            end
        end

        % check the other fields
        nfields = 1;
        fieldsAndBoundsStruct(nfields).fieldName = 'row';
        fieldsAndBoundsStruct(nfields).binaryCompare = ...
            {' > 0 ', ' <= 1200 '};
        nfields = nfields + 1;
        fieldsAndBoundsStruct(nfields).fieldName = 'column';
        fieldsAndBoundsStruct(nfields).binaryCompare = ...
            {' > 0 ', ' <= 1200 '};
        nfields = nfields + 1;
        fieldsAndBoundsStruct(nfields).fieldName = 'isInOptimalAperture';
        fieldsAndBoundsStruct(nfields).binaryCompare = ...
            {' >= 0 ', ' <= 1 '};
        for pixel = 1:nPixels
            check_struct(diaregInputStruct.targetStarStruct(target).pixelTimeSeriesStruct(pixel), ...
                fieldsAndBoundsStruct, 'PA:diaregClass');
        end
        clear fieldsAndBoundsStruct;

        nfields = 1;
        fieldsAndBoundsStruct(nfields).fieldName = 'referenceRow';
        fieldsAndBoundsStruct(nfields).binaryCompare = ...
            {' > 0 ', ' <= 1200 '};
        nfields = nfields + 1;
        fieldsAndBoundsStruct(nfields).fieldName = 'referenceColumn';
        fieldsAndBoundsStruct(nfields).binaryCompare = ...
            {' > 0 ', ' <= 1200 '};
        nfields = nfields + 1;
        fieldsAndBoundsStruct(nfields).fieldName = 'gapList';
        fieldsAndBoundsStruct(nfields).binaryCompare = ...
            {' > 0 ', ' <= 1e9 '};
        for pixel = 1:nPixels
            check_struct(diaregInputStruct.targetStarStruct(target), ...
                fieldsAndBoundsStruct, 'PA:diaregClass');
        end
        clear fieldsAndBoundsStruct;
    
    end
    
    % check the fields in diaregConfigurationStruct
    if(~isfield(diaregInputStruct, 'diaregConfigurationStruct'))
        error('PA:diaregClass:missingField:diaregConfigurationStruct',...
            'diaregConfigurationStruct: field not present in the input structure.')
    end
    nfields = 1;
    fieldsAndBoundsStruct(nfields).fieldName = 'startCadence';
    fieldsAndBoundsStruct(nfields).binaryCompare = ...
        {' > 0 ', ' <= 1e9 '};
    nfields = nfields + 1;
    fieldsAndBoundsStruct(nfields).fieldName = 'endCadence';
    fieldsAndBoundsStruct(nfields).binaryCompare = ...
        {' > 0 ', ' <= 1e9 '};
    nfields = nfields + 1;
    fieldsAndBoundsStruct(nfields).fieldName = 'motionPolynomialOrder';
    fieldsAndBoundsStruct(nfields).binaryCompare = ...
        {' >= 0 ', ' <= 100 '};
    nfields = nfields + 1;
    fieldsAndBoundsStruct(nfields).fieldName = 'iterativeRegistration';
    fieldsAndBoundsStruct(nfields).binaryCompare = ...
        {' >= 0 ', ' <= 1 '};
    nfields = nfields + 1;
    fieldsAndBoundsStruct(nfields).fieldName = 'cleanCosmicRays';
    fieldsAndBoundsStruct(nfields).binaryCompare = ...
        {' >= 0 ', ' <= 1 '};
    check_struct(diaregInputStruct.diaregConfigurationStruct, fieldsAndBoundsStruct, ...
        'PA:diaregClass');
    clear fieldsAndBoundsStruct;

    % check the fields in diaregInputStruct
    nfields = 1;
    fieldsAndBoundsStruct(nfields).fieldName = 'debugFlag';
    fieldsAndBoundsStruct(nfields).binaryCompare = [];
    nfields = nfields + 1;
    fieldsAndBoundsStruct(nfields).fieldName = 'backgroundGaps';
    fieldsAndBoundsStruct(nfields).binaryCompare = ...
        {' > 0 ', ' <= 1e9 '};
    nfields = nfields + 1;
    fieldsAndBoundsStruct(nfields).fieldName = 'motionGaps';
    fieldsAndBoundsStruct(nfields).binaryCompare = ...
        {' > 0 ', ' <= 1e9 '};
    check_struct(diaregInputStruct, fieldsAndBoundsStruct, ...
        'PA:diaregClass');
    
    % create fields filled in later
    for target=1:nTargets
        nPixels = length(diaregInputStruct.targetStarStruct(target).pixelTimeSeriesStruct);
        for pixel = 1:nPixels
            diaregInputStruct.targetStarStruct(target).pixelTimeSeriesStruct(pixel).crCleanedSeries = ...
                zeros(size(diaregInputStruct.targetStarStruct(1).pixelTimeSeriesStruct(1).timeSeries));
            diaregInputStruct.targetStarStruct(target).pixelTimeSeriesStruct(pixel).cosmicRayIndices = [];
            diaregInputStruct.targetStarStruct(target).pixelTimeSeriesStruct(pixel).cosmicRayDeltas = [];
        end
        diaregInputStruct.targetStarStruct(target).rowCentroid = [];
        diaregInputStruct.targetStarStruct(target).colCentroid = [];
    end
    diaregInputStruct.motionCoeffStruct = [];

    % make the diaregClass object
    diaregObject = class(diaregInputStruct, 'diaregClass');
end



