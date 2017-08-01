% function [] = examine_pdc_performance_by_skygroup(skyGroupId, mjd, mappingFilename)
%
% Find the predefined (for validation purposes) keplerId's for the given
% skygroup and plot the raw and corrected flux for each of them, along with
% identified and corrected outliers and discontinuities.
%
% Inputs:
%   skyGroupdId     -- [integer] {26, 43, 67, 81}
%   mjd             -- [double] MJD for the quarter to look at
%   mappingFilename
%
% Outputs:
%   Just figures
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

function examine_pdc_performance_by_skygroup(skyGroupId, mjd, quarter, mappingFilename)

% Set constant.
SUPPORTED_SKYGROUPS = [26, 43, 67, 81];

% Check if targets are defined for specified skygroup.
if ~ismember(skyGroupId, SUPPORTED_SKYGROUPS)
    error('Unsupported skyGroupId (%d)', skyGroupId)
end

% Set desired keplerId's for given skygroup.
switch skyGroupId
    case 26
        skyGroupKeplerIds = ...
            [8677400, 9007281, 8805616, 9077348, 8548007, ...
             8547085, 8805663, 8740991, 9007356, 8937786, ...
             8611921, 8873450, 8548407, 8352595, 9009390, ...
             8740378, 8804845, 8870706, 8874063, 9143855, ...
             8939650, 8938628, 8940961, 9143254, 9007918];
    case 43
        skyGroupKeplerIds = ...
            [8750584, 9084835, 9087548, 8816602, 9020092, ...
             9085007, 9340886, 9149959, 9150095, 9340539, ...
             9402241, 9279516, 9278686, 9021593, 9279846, ...
             9340955, 8751392, 9338929, 8621906, 8885841, ...
             9402652, 8953296, 8953257, 8948424, 8953059];
    case 67
        skyGroupKeplerIds = ...
            [5093863, 5615590, 5703010, 5182985, 5008619, ...
             5272590, 5273042, 5181566, 5446484, 5616540, ...
             4830001, 4832452, 5443980, 5616190, 4743097, ...
             5616250, 4650686, 5007473, 5183722, 4918300, ...
             5444392, 5443837, 5269407, 5359678, 5357901];
    case 81
        skyGroupKeplerIds = ...
            [2440128, 3114167, 3230835, 3228959, 3229448, ...
             3848440, 3233980, 2437692, 2155148, 3112707, ...
             2986071, 3441906, 2568708, 2986893, 3539632, ...
             3230948, 3643054, 3234175, 3339055, 3438740, ...
             3338674, 3543270, 3335813, 3233043, 3542573];

    otherwise
        error ('Unsupported Sky Group');

end

%***
% identify the mod.out and task files for this sky group

skyGroupStruct = retrieve_sky_group (skyGroupKeplerIds(1), mjd);
taskDirName = get_taskfiles_from_modout (mappingFilename, 'pdc', [skyGroupStruct.ccdModule skyGroupStruct.ccdOutput], quarter, 'LONG');
cd(taskDirName{1});

[~, ~] = plot_corrected_flux_from_this_task_directory ([], skyGroupKeplerIds, 0);

cd ../..

return
            
