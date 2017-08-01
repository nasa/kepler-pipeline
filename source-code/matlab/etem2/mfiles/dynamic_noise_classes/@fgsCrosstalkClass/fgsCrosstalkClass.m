function fgsCrosstalkObject = fgsCrosstalkClass(fgsCrosstalkData, runParamsObject)

% There is one .mat file for each mod/out. Within the .mat file there are the full 
% set of fgs cross-talk coefficients as delivered by Jeff K, along with a 3D array 
% of coefficients called coeffPlanes, which is 1070x1132x7. The coefficient planes 
% can be used to reconstruct a temperature and time dependent 2D black using the formula:
%     modelBlack = coeffPlanes(:,:,1)+coeffPlanes(:,:,2)+T*coeffPlanes(:,:,3)+t*coeffPlanes(:,:,4);
% where T is the temperature minus some reference value in degrees C and "t" 
% is the time minus some reference value in hours. The constructed black is 
% appropriate for a Long Cadence of 270 coadds.
% 
% In Jeff K's notation the model is given by:
%       DN( pixel N_.. )  = DN_Ref + K0 + KT * (T-T_Ref) + KS * (t-t_Ref),
% where DN_Ref = coeffPlanes(:,:,1)
% K0 = coeffPlanes(:,:,2)
% KT = coeffPlanes(:,:,3)
% KS = coeffPlanes(:,:,4)
% CoeffPlanes(:,:,5:7) are the uncertainties on the coefficients K0,KT, KS  respectively.
% 
% The model is based on the current FS-TVAC version of the 2D black for 
% each mod/out. A decent model 2D black representing stable flight data 
% can be constructed from coeffPlanes(:,:,1)+coeffPlanes(:,:,2).
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

dataLocation = fgsCrosstalkData.dataLocation;
module = get(runParamsObject, 'moduleNumber');
output = get(runParamsObject, 'outputNumber');
filename = sprintf('fgs_xtalk_therm_coeff_%02d%d.mat', module, output);
load([dataLocation filesep filename]);

fgsCrosstalkData.coeffPlanes = coeffPlanes(:,:,1:4);

fgsCrosstalkObject = class(fgsCrosstalkData, 'fgsCrosstalkClass', runParamsObject);
