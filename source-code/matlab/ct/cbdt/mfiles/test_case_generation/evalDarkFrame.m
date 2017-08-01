function [mA,mB,mC,mD,mE,sA,sB,sC,sD,sE] = evalDarkFrame(ffi)
% function [mA,mB,mC,mD,mE,sA,sB,sC,sD,sE] = evalDarkFrame(ffi)
%
% Evaluate Dark Frame: computes mean (m?) and standard deviation (s?) of each region
%   as defined in KEPLER.DFM.FPA.015
%
% Written by: Douglas Caldwell, 8 May 2006
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

% load CCD fomatting parameters (script sets parameter variables)
CCDFormatParams;

% construct image array indices
% region A
leadBlackRows = 1:(maskSmearSize + scienceImRowSize + virtualSmearSize);
leadBlackCols = 1:leadBlackSize;

% region B
maskSmearRows = 1:maskSmearSize;
maskSmearCols = (leadBlackSize+1):(leadBlackSize+scienceImColSize);

% region C
scienceImRows = (maskSmearSize+1):(maskSmearSize + scienceImRowSize);
scienceImCols = (leadBlackSize+1):(leadBlackSize+scienceImColSize);

% region D
virtualSmearRows = (maskSmearSize + scienceImRowSize + 1):(maskSmearSize + scienceImRowSize + virtualSmearSize);
virtualSmearCols = (leadBlackSize+1):(leadBlackSize+scienceImColSize);

% region E
trailBlackRows = 1:(maskSmearSize + scienceImRowSize + virtualSmearSize);
trailBlackCols = (leadBlackSize + scienceImColSize + 1):(leadBlackSize + scienceImColSize + trailBlackSize);

% step through each region, calculating mean  & std. deviation
% Regions A-E are defined in Ball KEPLER.DFM.FPA.015

 t=(ffi(leadBlackRows,leadBlackCols));
mA = mean(t(:));
sA = std(t(:));

 t=(ffi(maskSmearRows,maskSmearCols));
mB = mean(t(:));
sB = std(t(:));

t=(ffi(scienceImRows,scienceImCols));
mC = mean(t(:));
sC = std(t(:));

 t=(ffi(virtualSmearRows,virtualSmearCols));
mD = mean(t(:));
sD = std(t(:));

 t=(ffi(trailBlackRows,trailBlackCols));
mE = mean(t(:));
sE = std(t(:));

return
 