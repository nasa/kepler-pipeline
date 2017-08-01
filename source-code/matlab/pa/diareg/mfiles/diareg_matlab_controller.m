function diaregResultStruct = diareg_matlab_controller(diaregParameterStruct)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function diaregResultStruct = diareg_matlab_controller(diaregParameterStruct)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% 
% master control function for computing image motion on the field of view
% the input diaregParameterStruct is described in diaregClass.m, with the
% exception of the following fields:
%   .backgroundBlobStruct blob structure containing background polynomial
%       information, converted to the fields .backgroundCoeffStruct and
%       .backgroundGaps as required by diaregClass.m.
%   .motionBlobStruct blob structure containing image motion polynomial
%       information, converted to the fields .motionPolyStruct and
%       .motionGaps as required by diaregClass.m.
% 
% on completion diaregResultStruct contains the following fields:
%   .motionCoeffBlob an opaque blob containing the motion polynomial
%   structures
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

debugFlag = diaregParameterStruct.debugFlag;
durationList = [];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% convert the background blob structure into a background structure
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

startCadence = diaregParameterStruct.diaregConfigurationStruct.startCadence;
endCadence = diaregParameterStruct.diaregConfigurationStruct.endCadence;
if ~isempty(diaregParameterStruct.backgroundBlobStruct);
    [diaregParameterStruct.backgroundCoeffStruct, ...
        diaregParameterStruct.backgroundGaps] = blob_to_struct(...
        diaregParameterStruct.backgroundBlobStruct, ...
        startCadence, endCadence);
else
    diaregParameterStruct.backgroundCoeffStruct = [];
    diaregParameterStruct.backgroundGaps = [];
end
diaregParameterStruct = rmfield(diaregParameterStruct, 'backgroundBlobStruct');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% convert the motion blob structure into a motion structure
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if ~isempty(diaregParameterStruct.motionBlobStruct);
    [diaregParameterStruct.motionPolyStruct, ...
        diaregParameterStruct.motionGaps] = blob_to_struct(...
        diaregParameterStruct.motionBlobStruct, ...
        startCadence, endCadence);
else
    diaregParameterStruct.motionPolyStruct = [];
    diaregParameterStruct.motionGaps = [];
end
diaregParameterStruct = rmfield(diaregParameterStruct, 'motionBlobStruct');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% create diaregClass
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
tic;
diaregObject = diaregClass(diaregParameterStruct);
duration = toc;

durationElement = length(durationList);
durationList(durationElement + 1).time = duration;
durationList(durationElement + 1).label = 'diaregClass';

if (debugFlag) 
    display(['diaregClass duration: ' num2str(duration) ...
        ' seconds = ' num2str(duration/60) ' minutes']);
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% clean cosmic rays from target pixels if desired
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if get(diaregObject, 'cleanCosmicRays')
    tic;
    diaregObject = clean_diareg_cosmic_rays(diaregObject);
    duration = toc;

    durationElement = length(durationList);
    durationList(durationElement + 1).time = duration;
    durationList(durationElement + 1).label = 'clean_diareg_cosmic_rays';

    if (debugFlag) 
        display(['clean_diareg_cosmic_rays duration: ' num2str(duration) ...
            ' seconds = ' num2str(duration/60) ' minutes']);
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% remove the background if we have background information
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if ~isempty(get(diaregObject,'backgroundCoeffStruct'))
    tic;
    diaregObject = remove_diareg_background(diaregObject);
    duration = toc;

    durationElement = length(durationList);
    durationList(durationElement + 1).time = duration;
    durationList(durationElement + 1).label = 'remove_diareg_background';

    if (debugFlag) 
        display(['remove_diareg_background duration: ' num2str(duration) ...
            ' seconds = ' num2str(duration/60) ' minutes']);
    end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% compute image motion with centroiding if input motion is empty
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if isempty(get(diaregObject,'motionPolyStruct'))
    tic;
    diaregObject = compute_image_motion(diaregObject);
    duration = toc;

    durationElement = length(durationList);
    durationList(durationElement + 1).time = duration;
    durationList(durationElement + 1).label = 'compute_image_motion';

    if (debugFlag) 
        display(['compute_image_motion duration: ' num2str(duration) ...
            ' seconds = ' num2str(duration/60) ' minutes']);
    end
end


diaregResultStruct = set_result_struct(diaregObject);
diaregResultStruct.durationList = durationList;
diaregResultStruct.errorStruct = [];
