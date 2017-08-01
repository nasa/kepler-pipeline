function tppResultStruct = tpp_matlab_controller(tppParameterStruct)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function tppResultStruct = tpp_matlab_controller(tppParameterStruct)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% 
% master control function for target pixel processing
% the input tppParameterStruct is described in tppClass.m, with the
% exception of the following fields:
%   .backgroundBlobStruct blob structure containing background polynomial
%       information, converted to the fields .backgroundCoeffStruct and
%       .backgroundGaps as required by tppClass.m.
%   .motionBlobStruct blob structure containing image motion polynomial
%       information, converted to the fields .motionPolyStruct and
%       .motionGaps as required by tppClass.m.
% 
% on completion tppResultStruct contains the following fields:
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

debugFlag = tppParameterStruct.debugFlag;
durationList = [];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% convert the background blob structure into a background structure
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

startCadence = tppParameterStruct.tppConfigurationStruct.startCadence;
endCadence = tppParameterStruct.tppConfigurationStruct.endCadence;
if ~isempty(tppParameterStruct.backgroundBlobStruct);
    [tppParameterStruct.backgroundCoeffStruct, ...
        tppParameterStruct.backgroundGaps] = blob_to_struct(...
        tppParameterStruct.backgroundBlobStruct, ...
        startCadence, endCadence);
else
    tppParameterStruct.backgroundCoeffStruct = [];
    tppParameterStruct.backgroundGaps = [];
end
tppParameterStruct = rmfield(tppParameterStruct, 'backgroundBlobStruct');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% convert the motion blob structure into a motion structure
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if ~isempty(tppParameterStruct.motionBlobStruct);
    [tppParameterStruct.motionPolyStruct, ...
        tppParameterStruct.motionGaps] = blob_to_struct(...
        tppParameterStruct.motionBlobStruct, ...
        startCadence, endCadence);
else
    tppParameterStruct.motionPolyStruct = [];
    tppParameterStruct.motionGaps = [];
end
tppParameterStruct = rmfield(tppParameterStruct, 'motionBlobStruct');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% create tppClass
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
tic;
tppObject = tppClass(tppParameterStruct);
duration = toc;

durationElement = length(durationList);
durationList(durationElement + 1).time = duration;
durationList(durationElement + 1).label = 'tppClass';

if (debugFlag) 
    display(['tppClass duration: ' num2str(duration) ...
        ' seconds = ' num2str(duration/60) ' minutes']);
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% clean cosmic rays from target pixels 
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if get(tppObject, 'cleanCosmicRays')
    tic;

    tppObject = clean_target_cosmic_rays(tppObject);
    duration = toc;

    durationElement = length(durationList);
    durationList(durationElement + 1).time = duration;
    durationList(durationElement + 1).label = 'clean_target_cosmic_rays';

    if (debugFlag) 
        display(['clean_target_cosmic_rays duration: ' num2str(duration) ...
            ' seconds = ' num2str(duration/60) ' minutes']);
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% remove the background 
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
tic;
tppObject = remove_background(tppObject);
duration = toc;

durationElement = length(durationList);
durationList(durationElement + 1).time = duration;
durationList(durationElement + 1).label = 'remove_background';

if (debugFlag) 
    display(['remove_background duration: ' num2str(duration) ...
        ' seconds = ' num2str(duration/60) ' minutes']);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% id bad pixels
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
tic;
% tppObject = id_bad_pixels(tppObject);
duration = toc;

durationElement = length(durationList);
durationList(durationElement + 1).time = duration;
durationList(durationElement + 1).label = 'id_bad_pixels';

if (debugFlag) 
    display(['id_bad_pixels duration: ' num2str(duration) ...
        ' seconds = ' num2str(duration/60) ' minutes']);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% perform optimal aperture photometry
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
tic;
% tppObject = optimal_aperture_photometry(tppObject);
duration = toc;

durationElement = length(durationList);
durationList(durationElement + 1).time = duration;
durationList(durationElement + 1).label = 'optimal_aperture_photometry';

if (debugFlag) 
    display(['optimal_aperture_photometry duration: ' num2str(duration) ...
        ' seconds = ' num2str(duration/60) ' minutes']);
end

tppResultStruct = set_result_struct(tppObject);
tppResultStruct.durationList = durationList;
tppResultStruct.errorStruct = [];
