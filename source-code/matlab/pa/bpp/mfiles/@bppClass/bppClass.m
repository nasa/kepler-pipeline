function bppObject = bppClass(bppInputStruct)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function bppObject = bppClass(bppInputStruct)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% 
% background pixel apertures first lays down a grid of initial positions on
% the module output.  This grid is stretched to have a higher density near
% the edges of the output.  The grid nodes are used as initial positions
% for background apertures, which are then moved slightly to appropriate
% background pixels.
%
% bppInputStruct is a structure with the following fields:
%   .backgroundStruct(): 1D array of structures describing background pixels
%   that contain at least the following fields:
%   	.timeSeries() # of cadences x 1 array containing pixel brightness
%               time series.  
%       .uncertainties() # of cadences x 1 array containing uncertainty
%               in pixel brightness.  
%   	.gapList() # of gaps x 1 array containing the index of gaps in
%               .timeSeries
%    	.row, column row, column of this pixel in CCD coordinates
%   .cosmicRayConfigurationStruct: structure containing various
%       configuration values as returned by build_cr_configuration_struct()
%   .backgroundConfigurationStruct: structure containing the following
%       parameters:
%       .fitLowOrder order of the low-order background fit to be done at
%           every cadence used in fit_background_by_cadence()
%       .fitCadenceChunkSize size of a chunk of cadences to be processed at
%           a time appropriate to memory constraints in the background fit
%           used in fit_background_by_time_series() 
%   .cleanCosmicRays flag to indicate that cosmic rays should be
%       cleaned: 0 => do not perform cosmic ray cleaning, 1 => perform
%       cosmic ray cleaning 
%
%   The following fields of backgroundStruct are filled in during the
%       operation of BPP: 
%       .crCleanedSeries() same as field .timeSeries with cosmic rays removed
%          from non-gap entries.  
%       .cosmicRayIndices() # of cosmic ray events x 1 array of indices in
%          .crCleanedSeries of cosmic ray events 
%       .cosmicRayDeltas() array of same size as .cosmicRayIndices containing
%           the change in values in .crCleanedSeries from .timeSeries so
%           .timeSeries(.cosmicRayIndices) =
%               .crCleanedSeries(.cosmicRayIndices) + .cosmicRayDeltas
%   The following field is added to bppObject during the operation of BPP:
%   .backgroundCoeffStruct # of cadences x 1 array of polynomial structures
%       providing the background fit
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
    error('PA:bppClass:EmptyInputStruct',...
        'The constructor must be called with an input structure.');
else
    % check the fields of backgroundConfigurationStruct
    if(~isfield(bppInputStruct, 'backgroundConfigurationStruct'))
        error('PA:bppClass:missingField:backgroundConfigurationStruct',...
            'backgroundConfigurationStruct: field not present in the input structure.')
    end
    
    check_background_configuration_struct(...
        bppInputStruct.backgroundConfigurationStruct, 'PA:bppClass');

    % check the fields of cosmicRayConfigurationStruct
    if(~isfield(bppInputStruct, 'cosmicRayConfigurationStruct'))
        error('PA:bppClass:missingField:cosmicRayConfigurationStruct',...
            'cosmicRayConfigurationStruct: field not present in the input structure.')
    end
    check_cosmic_ray_configuration_struct(...
        bppInputStruct.cosmicRayConfigurationStruct, 'PA:bppClass');

    
    % check the fields in backgroundStruct
    if(~isfield(bppInputStruct, 'backgroundStruct'))
        error('PA:bppClass:missingField:backgroundStruct',...
            'backgroundStruct: field not present in the input structure.')
    end
    
    % check_struct does not work on arrays of structures with fields that
    % are arrays, so do these individually
    
    % check .timeSeries
    if(~isfield(bppInputStruct.backgroundStruct, 'timeSeries'))
        error('PA:bppClass:missingField:backgroundStruct:timeSeries',...
            'timeSeries: field not present in the input structure.')
    end
    % look for Nan or Inf
    if any(any(~isfinite([bppInputStruct.backgroundStruct.timeSeries])))
        error('PA:bppClass:rangeCheck:backgroundStruct:timeSeries',...
            'timeSeries: contains a Nan or Inf.')
    end
    % check range
    % for time series values allow small negative values
    if ~all(all([bppInputStruct.backgroundStruct.timeSeries] > -1e3 ))
        error('PA:bppClass:rangeCheck:backgroundStruct:timeSeries',...
            'PA:bppClass:rangeCheck:backgroundStruct.timeSeries: not all > -1e3.')
    end
    % check for highest conceivable time series value (allowing for the
    % possibility that some background pixels actually contain bright
    % objects)
    if ~all(all([bppInputStruct.backgroundStruct.timeSeries] <= 1e9 ))
        error('PA:bppClass:rangeCheck:backgroundStruct:timeSeries',...
            'PA:bppClass:rangeCheck:backgroundStruct.timeSeries: not all <= 1e9.')
    end
    
    % check .uncertainties
    if(~isfield(bppInputStruct.backgroundStruct, 'uncertainties'))
        error('PA:bppClass:missingField:backgroundStruct:uncertainties',...
            'timeSeries: field not present in the input structure.')
    end
    % look for Nan or Inf
    if any(any(~isfinite([bppInputStruct.backgroundStruct.uncertainties])))
        error('PA:bppClass:rangeCheck:backgroundStruct:uncertainties',...
            'timeSeries: contains a Nan or Inf.')
    end
    % check range
    % uncertainties must be positive (non-definite)
    if ~all(all([bppInputStruct.backgroundStruct.uncertainties] >= 0 ))
        error('PA:bppClass:rangeCheck:backgroundStruct:uncertainties',...
            'PA:bppClass:rangeCheck:backgroundStruct.uncertainties: not all > -1e3.')
    end
    % largest conceivable uncertainty value
    if ~all(all([bppInputStruct.backgroundStruct.uncertainties] <= 1e6 ))
        error('PA:bppClass:rangeCheck:backgroundStruct:uncertainties',...
            'PA:bppClass:rangeCheck:backgroundStruct.uncertainties: not all <= 1e6.')
    end
    
    % check .gaplist.  This is complicated since the lists for different
    % pixels are of different lengths so we can't concatenate
    if(~isfield(bppInputStruct.backgroundStruct, 'gapList'))
        error('PA:bppClass:missingField:backgroundStruct:gapList',...
            'timeSeries: field not present in the input structure.')
    end
    nPixels = length(bppInputStruct.backgroundStruct);
    for pixel = 1:nPixels
        % look for Nan or Inf
        if any(~isfinite([bppInputStruct.backgroundStruct(pixel).gapList]))
            error('PA:bppClass:rangeCheck:backgroundStruct:gapList',...
                'timeSeries: contains a Nan or Inf.')
        end
        % check range
        % gap list is an index
        if ~all([bppInputStruct.backgroundStruct(pixel).gapList] >= 0 )
            error('PA:bppClass:rangeCheck:backgroundStruct:gapList',...
                'PA:bppClass:rangeCheck:backgroundStruct.gapList: not all > -1e3.')
        end
        % larger than the largest possible cadence index
        if ~all([bppInputStruct.backgroundStruct(pixel).gapList] <= 1e6 )
            error('PA:bppClass:rangeCheck:backgroundStruct:gapList',...
                'PA:bppClass:rangeCheck:backgroundStruct.gapList: not all <= 1e6.')
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
    check_struct(bppInputStruct.backgroundStruct, fieldsAndBoundsStruct, ...
        'PA:bppClass');
    
    clear fieldsAndBoundsStruct;

    % check the fields in bppInputStruct
    nfields = 1;
    fieldsAndBoundsStruct(nfields).fieldName = 'debugFlag';
    fieldsAndBoundsStruct(nfields).binaryCompare = [];
    nfields = nfields + 1;
    fieldsAndBoundsStruct(nfields).fieldName = 'cleanCosmicRays';
    fieldsAndBoundsStruct(nfields).binaryCompare = ...
        {' >= 0 ', ' <= 1 '};
    check_struct(bppInputStruct, fieldsAndBoundsStruct, ...
        'PA:bppClass');
end

% create fields filled in later
nPixels = length(bppInputStruct.backgroundStruct);
for pixel = 1:nPixels
    bppInputStruct.backgroundStruct(pixel).crCleanedSeries = ...
        zeros(size(bppInputStruct.backgroundStruct(1).timeSeries));
    bppInputStruct.backgroundStruct(pixel).cosmicRayIndices = [];
    bppInputStruct.backgroundStruct(pixel).cosmicRayDeltas = [];
end
bppInputStruct.backgroundCoeffStruct = [];

% make the bppClass object
bppObject = class(bppInputStruct, 'bppClass');

