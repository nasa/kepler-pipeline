function limbDarkeningCoefficients = ...
    get_coeffts_from_atlas_tables(effectiveTemp, log10SurfaceGravity)
% function limbDarkeningCoefficients = ...
%   get_coeffts_from_atlas_tables(effectiveTemp, log10SurfaceGravity)
%
% function to retrieve nonlinear limb darkening coefficients from
% pre-defined Atlas tabular data
%
%
% INPUTS:
%
%   effectiveTemp       [scalar] stellar effective temperature (Kelvin)
%   log10SurfaceGravity [scalar] log of stellar surface gravity (cm/sec^2)
%
%
% This function calls get_nonlinear_limb_darkening_atlas_data which creates
% atlasNonlinearLimbDarkeningData.mat
%
% atlasNonlinearLimbDarkeningStruct =
%                      shortKey: {2x12 cell}
%                           key: {1x12 cell}
%        turbulentVelocityIndex: 1
%                     logGIndex: 2
%     effectiveTemperatureIndex: 3
%           logMetallicityIndex: 4
%                    UBandIndex: 5
%                    BBandIndex: 6
%                    VBandIndex: 7
%                    RBandIndex: 8
%                    IBandIndex: 9
%                    JBandIndex: 10
%                    HBandIndex: 11
%                    KBandIndex: 12
%                            a1: [9550x12 double]
%                            a2: [9550x12 double]
%                            a3: [9550x12 double]
%                            a4: [9550x12 double]
%
% **Note the following are taken as default values:
%   turbulent velocity = 0
%   log metallicity = 0
%   R band values
%
%
% OUTPUTS:
%
%    limbDarkeningCoefficients [array] limb darkening coefficients
%
%--------------------------------------------------------------------------
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

% Modification history:
%
%    2011-Jan-3, EQ:
%        added this function in order to keep the main function
%        get_limb_darkening_coefficients.m (which used to contain the code
%        herein) general for multiple limb darkening models.  Also turned
%        off warnings for the actual interpolation since the use of
%        "griddata" will no longer be supported in future MATLAB releases.


get_nonlinear_limb_darkening_atlas_data();
load atlasNonlinearLimbDarkeningData.mat;


% set the indices of interest using the effective temperature and
% log g as input, and setting turbulent velocity = 0, log metallicity = 0,
% and the use of the R band as defaults
turbulentVIndex             = atlasNonlinearLimbDarkeningStruct.turbulentVelocityIndex;
logGIndex                   = atlasNonlinearLimbDarkeningStruct.logGIndex;
effectiveTemperatureIndex   = atlasNonlinearLimbDarkeningStruct.effectiveTemperatureIndex;
logMetallicityIndex         = atlasNonlinearLimbDarkeningStruct.logMetallicityIndex;
RBandIndex                  = atlasNonlinearLimbDarkeningStruct.RBandIndex;

% get the coefficient arrays
a1 = atlasNonlinearLimbDarkeningStruct.a1;
a2 = atlasNonlinearLimbDarkeningStruct.a2;
a3 = atlasNonlinearLimbDarkeningStruct.a3;
a4 = atlasNonlinearLimbDarkeningStruct.a4;

% get the indices of the parts these arrays of interest
defaultIndex = find(a1(:, turbulentVIndex) == 0 & a1(:, logMetallicityIndex) == 0);

% restrict to the indices of interest:
a1 = a1(defaultIndex, :);
a2 = a2(defaultIndex, :);
a3 = a3(defaultIndex, :);
a4 = a4(defaultIndex, :);

% create the vectors we want
effectiveTempTable      = a1(:, effectiveTemperatureIndex);
logGTable               = a1(:, logGIndex);
RCoefStruct.a1          = a1(:,RBandIndex);
RCoefStruct.a2          = a2(:,RBandIndex);
RCoefStruct.a3          = a3(:,RBandIndex);
RCoefStruct.a4          = a4(:,RBandIndex);


% ensure that the logg and effective temperature are within the valid ranges
% set by the tables
minTeff = min(effectiveTempTable);
maxTeff = max(effectiveTempTable);
minLogg = min(logGTable);
maxLogg = max(logGTable);

effectiveTemp = max(effectiveTemp, minTeff);
effectiveTemp = min(effectiveTemp, maxTeff);

log10SurfaceGravity = max(log10SurfaceGravity, minLogg);
log10SurfaceGravity = min(log10SurfaceGravity, maxLogg);


limbDarkeningCoefficients = interpolate_limb_darkening_coefficients(...
    RCoefStruct, logGTable, effectiveTempTable, log10SurfaceGravity, effectiveTemp);



%--------------------------------------------------------------------------
% sub-function for interpolation
%--------------------------------------------------------------------------
function limbDarkeningCoefficients = interpolate_limb_darkening_coefficients(...
    limbDarkStruct, logGData, effectiveTempData, logG, effectiveT)
% perform the interpolations, use the 'Pp' option to turn off warnings
% the options {'Qt','Qbb','Qc','Pp'} extend the default 2 and 3 dimensional
% griddata call with the 'Pp' option which turns off precision warnings.
% The appropriate options for 4D and higher is {'Qt','Qbb','Qc','Qx','Pp'}

warning off all
limbDarkeningCoefficients(1) = griddata(logGData, effectiveTempData, limbDarkStruct.a1, ...
    logG, effectiveT, 'linear', {'Qt','Qbb','Qc','Pp'});
limbDarkeningCoefficients(2) = griddata(logGData, effectiveTempData, limbDarkStruct.a2, ...
    logG, effectiveT, 'linear', {'Qt','Qbb','Qc','Pp'});
limbDarkeningCoefficients(3) = griddata(logGData, effectiveTempData, limbDarkStruct.a3, ...
    logG, effectiveT, 'linear', {'Qt','Qbb','Qc','Pp'});
limbDarkeningCoefficients(4) = griddata(logGData, effectiveTempData, limbDarkStruct.a4, ...
    logG, effectiveT, 'linear', {'Qt','Qbb','Qc','Pp'});
warning on all


return;

