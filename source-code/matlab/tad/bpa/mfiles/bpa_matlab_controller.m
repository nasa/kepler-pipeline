function bpaResultStruct = bpa_matlab_controller(bpaParameterStruct)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function bpaResultStruct = bpa_matlab_controller(bpaParameterStruct)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% 
% master control function for the selection of background apertures
% the input bpaParameterStruct is described in bpaClass.m.
% 
% on completion bpaResultStruct contains the structure 
%   .targetDefinitions a # of targets by 1 structure containing the fields
%       .keplerId kepler ID of the target
%       .maskIndex index (into the input maskDefinitions array) of the 
%           mask assigned to this target
%       .referenceRow, .referenceColumn reference row and column of the
%           mask assigned to this target
%       .excessPixels the number of pixels in the assigned mask that are
%           not in the requested aperture
%       .status status indicating successful mask assignment: 
%           status = -1: no mask assigned
%           status = 0: mask assigned, no problems
%           status = -2: mask assigned but has pixels off the CCD
%   .maskDefinitions a # of masks x 1 array describing the masks with the
%       following fields (only one mask returned in baseline design):
%       .offsets a # of pixels in mask by 1 array of structures with the
%           following fields
%           .row, .column row and column offsets of each pixel in the mask
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

debugFlag = bpaParameterStruct.debugFlag;
durationList = [];

% convert the required inputs from 0-base to 1-base
bpaParameterStruct = convert_bpa_inputs_to_1_base(bpaParameterStruct);

% set values from the focal plane constants
bpaParameterStruct.moduleDescriptionStruct.nRowPix = bpaParameterStruct.fcConstants.nRowsImaging;
bpaParameterStruct.moduleDescriptionStruct.nColPix = bpaParameterStruct.fcConstants.nColsImaging;
bpaParameterStruct.moduleDescriptionStruct.leadingBlack = bpaParameterStruct.fcConstants.nLeadingBlack;
bpaParameterStruct.moduleDescriptionStruct.trailingBlack = bpaParameterStruct.fcConstants.nTrailingBlack;
bpaParameterStruct.moduleDescriptionStruct.virtualSmear = bpaParameterStruct.fcConstants.nVirtualSmear;
bpaParameterStruct.moduleDescriptionStruct.maskedSmear = bpaParameterStruct.fcConstants.nMaskedSmear;

% bpaParameterStruct.moduleDescriptionStruct.nRowPix = 1024;
% bpaParameterStruct.moduleDescriptionStruct.nColPix = 1100;
% bpaParameterStruct.moduleDescriptionStruct.leadingBlack = 12;
% bpaParameterStruct.moduleDescriptionStruct.trailingBlack = 20;
% bpaParameterStruct.moduleDescriptionStruct.virtualSmear = 26;
% bpaParameterStruct.moduleDescriptionStruct.maskedSmear = 20;

% convert the input completeOutputImage field from a java <array <array>>
% to a 2D matlab array
bpaParameterStruct.moduleOutputImage = ...
    struct_to_array2D(bpaParameterStruct.moduleOutputImage);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% create bpaClass
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
tic;
bpaObject = bpaClass(bpaParameterStruct);
duration = toc;

durationElement = length(durationList);
durationList(durationElement + 1).time = duration;
durationList(durationElement + 1).label = 'bpaClass';

if (debugFlag) 
    display(['bpaClass duration: ' num2str(duration) ...
        ' seconds = ' num2str(duration/60) ' minutes']);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% make background aperture target definitions
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
tic;
bpaObject = find_background_apertures(bpaObject);
duration = toc;

durationElement = length(durationList);
durationList(durationElement + 1).time = duration;
durationList(durationElement + 1).label = 'find_background_apertures';

if (debugFlag) 
    display(['find_background_apertures duration: ' num2str(duration) ...
        ' seconds = ' num2str(duration/60) ' minutes']);
end

bpaResultStruct = set_result_struct(bpaObject);
bpaResultStruct.durationList = durationList;

% convert the required outputs to 0-base
bpaResultStruct = convert_bpa_outputs_to_0_base(bpaResultStruct);
