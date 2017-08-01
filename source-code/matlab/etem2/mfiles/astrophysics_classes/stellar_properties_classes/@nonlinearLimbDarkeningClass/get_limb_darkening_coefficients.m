function limbDarkeningCoef = get_limb_darkening_coefficients( ...
    nonlinearLimbDarkeningObject, stellarPropertiesStruct)
% function limbDarkeningCoef = get_limb_darkening_coefficients(...
%     nonlinearLimbDarkeningObject, stellarPropertiesStruct)
% 
% sets the limb darkening coefficients for the star described in
% stellarPropertiesStruct.  stellarPropertiesStruct must contain the
% following fields:
%   .logSurfaceGravity log of the surface gravity at the star's surface
%   .effectiveTemperature the effective temperature of the star
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

% get the limb darkening data structure atlasNonlinearLimbDarkeningStruct
load(nonlinearLimbDarkeningObject.limbDarkeningDataPath); 

%%

% set the indices of interest.  We will use the effective temperature and
% log g as input, taking turbulent velocity = 0, log metallicity = 0 as
% defaults, and use the R band for now.
turbulentVIndex = atlasNonlinearLimbDarkeningStruct.turbulentVelocityIndex;
logGIndex = atlasNonlinearLimbDarkeningStruct.logGIndex;
effectiveTIndex = atlasNonlinearLimbDarkeningStruct.effectiveTemperatureIndex;
logMetallicityIndex = atlasNonlinearLimbDarkeningStruct.logMetallicityIndex;
RBandIndex = atlasNonlinearLimbDarkeningStruct.RBandIndex;

% get the coefficient arrays
a1 = atlasNonlinearLimbDarkeningStruct.a1;
a2 = atlasNonlinearLimbDarkeningStruct.a2;
a3 = atlasNonlinearLimbDarkeningStruct.a3;
a4 = atlasNonlinearLimbDarkeningStruct.a4;

% get the indices of the parts these arrays of interest
defaultIndex = find(a1(:,turbulentVIndex) == 0 & a1(:,logMetallicityIndex) == 0);

% restrict to the indices of interest:
a1 = a1(defaultIndex, :);
a2 = a2(defaultIndex, :);
a3 = a3(defaultIndex, :);
a4 = a4(defaultIndex, :);

% create the vectors we want
effectiveTemperatureTable = a1(:, effectiveTIndex);
logGTable = a1(:, logGIndex);
RCoefStruct.a1 = a1(:,RBandIndex);
RCoefStruct.a2 = a2(:,RBandIndex);
RCoefStruct.a3 = a3(:,RBandIndex);
RCoefStruct.a4 = a4(:,RBandIndex);

limbDarkeningCoef = interpolate_limb_darkening_coefficients(...
    RCoefStruct, logGTable, effectiveTemperatureTable, ...
    stellarPropertiesStruct.logSurfaceGravity, ...
    stellarPropertiesStruct.effectiveTemperature);

%%
function limbDarkeningCoef = interpolate_limb_darkening_coefficients(...
    limbDarkStruct, logGData, effectiveTempData, logG, effectiveT)
% perform the interpolations, use the 'Pp' option to turn off warnings
% the options {'Qt','Qbb','Qc','Pp'} extend the default 2 and 3 dimensional
% griddata call with the 'Pp' option which turns off precision warnings.
% The appropriate options for 4D and higher is {'Qt','Qbb','Qc','Qx','Pp'}
limbDarkeningCoef(1) = griddata(logGData, effectiveTempData, limbDarkStruct.a1, ...
    logG, effectiveT, 'linear', {'Qt','Qbb','Qc','Pp'});
limbDarkeningCoef(2) = griddata(logGData, effectiveTempData, limbDarkStruct.a2, ...
    logG, effectiveT, 'linear', {'Qt','Qbb','Qc','Pp'});
limbDarkeningCoef(3) = griddata(logGData, effectiveTempData, limbDarkStruct.a3, ...
    logG, effectiveT, 'linear', {'Qt','Qbb','Qc','Pp'});
limbDarkeningCoef(4) = griddata(logGData, effectiveTempData, limbDarkStruct.a4, ...
    logG, effectiveT, 'linear', {'Qt','Qbb','Qc','Pp'});


