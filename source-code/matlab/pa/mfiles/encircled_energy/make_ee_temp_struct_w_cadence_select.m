function eeTempStruct = make_ee_temp_struct_w_cadence_select(eeTempStruct,cadenceSelect)
%
%   function eeTempStruct = make_ee_temp_struct_w_cadence_select(eeTempStruct,cadenceSelect)
%
%   Return the same structure as input where data under .targetStar level is only for the cadences listed in [cadenceSelect]
%
%   INPUT/OUTPUT STRUCTURE:
%   eeTempStruct             = structure with the following fields
%       .polyOrder           = fit polynomial order; int
%       .eeFraction          = fit evaluation point; float 	
%       .eeRadius            = # of cadences x 1; float initialized to []
%       .CeeRadius           = # of cadences x 1; float initialized to []
%       .polyCoeff           = # of cadences x 1; cell array of (polyOrder+1)x1 arrays, float; initialized to {}
%       .CpolyCoeff          = # of cadences x 1; cell array of (polyOrder+1)x(polyOrder+1) arrays, float; initialized to {}
%       .mse                 = # of cadences x 1; float; initialized to []
%       .targetStar          = # of encircled energy targets x 1; array of structures with the following fields:
%           .gapList         = # of gaps x 1; int containing the indices of cadence gaps at the target-level
%           .expectedFlux    = expected flux for this target as calculated from the target magnitude; float
%           .cadence         = # of cadences x 1; array of structures with the following fields:
%               .pixFlux     = # of pixels x 1; float 
%               .Cpixflux    = # of pixels x 1; float (OR cell array of # of pixels x # of pixels float)
%               .radius      = # of pixels x 1; float
%               .row         = # of pixels x 1; int
%               .col         = # of pixels x 1; int
%               .gapFlag     = # of pixels x 1; boolean indicating cadence gaps at the pixel-level, 1==gap, 0==no gap
%
%       .encircledEnergyStruct  = structure with the following fields
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

%disp(mfilename('fullpath'));

% number of input cadences defined by target(1).cadence
numCadences = length(eeTempStruct.targetStar(1).cadence);

% cadenceSelect must be an ordered, unique column vector and a subset of the original cadence set
cadenceSelect = intersect(cadenceSelect,1:numCadences);
cadenceSelect = cadenceSelect(:);

for iTarget=1:length(eeTempStruct.targetStar)
    eeTempStruct.targetStar(iTarget).gapList = intersect(eeTempStruct.targetStar(iTarget).gapList, cadenceSelect);
    eeTempStruct.targetStar(iTarget).cadence = eeTempStruct.targetStar(iTarget).cadence(cadenceSelect);
end


