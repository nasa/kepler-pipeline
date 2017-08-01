function M = produce_pa_motion_metrics( inputsStruct )
%**************************************************************************
% function M = produce_pa_motion_metrics( inputsStruct )
%**************************************************************************
% Assemble diagnostic metrics for the motion polynomial fits on a
% cadence by cadence basis.
%
% INPUTS:
%           paDataStruct      = input structure used by the pa_matlab_controller
% OUTPUTS:
%           M
%               .ccdModule      = ccd module number
%               .ccdOutput      = ccd output number
%               .rowCadences    = absolute cadence numbers for the valid row polynomial fits,[nCadencesx1]
%               .colCadences    = absolute cadence numbers for the valid column polynomial fits,[nCadencesx1]
%               .fittedRow      = row polynomial evaluated at KIC ra and dec,[nCadencesxnPpaTargets]
%               .fittedCol      = column polynomial evaluated at KIC ra and dec,[nCadencesxnPpaTargets]
%               .rowResidual    = row residual to polynomial fit,[nCadencesxnPpaTargets]
%               .colResidual    = column residual to polynomial fit,[nCadencesxnPpaTargets]
%               .rowOrder       = row motion polynomial order as selected by AIC - same order is used for all valid cadences
%               .colOrder       = column motion polynomial order as selected by AIC - same order is used for all valid cadences
%
%**************************************************************************
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

disp('PA:Produce dawg metrics for motion polynomials.');

% units conversion
DEGREES_PER_DAY = 360;
HOURS_PER_DAY = get_unit_conversion('day2hour');
DEGREES_PER_HOUR = DEGREES_PER_DAY / HOURS_PER_DAY;

paRootTaskDir = char(get_cwd_parent);

% get cadence numbers
cadences = inputsStruct.cadenceTimes.cadenceNumbers(:);

% load the motion polynomials
load(fullfile(paRootTaskDir, 'pa_motion.mat'));

% get the ppa centroids
load(fullfile(paRootTaskDir, 'pa_state.mat'),'ppaTargetStarResultsStruct');


ra = [ppaTargetStarResultsStruct.raHours].*DEGREES_PER_HOUR;
dec = [ppaTargetStarResultsStruct.decDegrees];
mod = inputsStruct.ccdModule;
out = inputsStruct.ccdOutput;

prfCentroids = [ppaTargetStarResultsStruct.prfCentroids];
prfR = [prfCentroids.rowTimeSeries];
prfC = [prfCentroids.columnTimeSeries];

prfRowVal = [prfR.values];
%     prfRowGap = [prfR.gapIndicators];
%     prfRowUnc = [prfR.uncertainties];
prfColVal = [prfC.values];
%     prfColGaps = [prfC.gapIndicators];
%     prfColUnc = [prfC.uncertainties];


% get arrays of motion polynomial 
rowPoly = [inputStruct.rowPoly];
colPoly = [inputStruct.colPoly];
validRowPoly = logical([inputStruct.rowPolyStatus]);
validColPoly = logical([inputStruct.colPolyStatus]);
rowPoly = rowPoly(validRowPoly);
colPoly = colPoly(validColPoly);

% would like to get the covariance also but weighted_polyval2d doesn't seem
% to want to return it without erroring out
%     [fittedRow, CfittedRow] = weighted_polyval2d(ra(:),dec(:),rowPoly(:));
%     [fittedCol, CfittedCol] = weighted_polyval2d(ra(:),dec(:),colPoly(:));

if ~isempty(rowPoly)
    fittedRow = weighted_polyval2d(ra(:),dec(:),rowPoly(:));
    rowResidual = prfRowVal(validRowPoly,:) - fittedRow';
    rowOrder = rowPoly(1).order;
else
    fittedRow = [];
    rowResidual = [];
    rowOrder = [];
end

if ~isempty(colPoly)
    fittedCol = weighted_polyval2d(ra(:),dec(:),colPoly(:));
    colResidual = prfColVal(validColPoly,:) - fittedCol';
    colOrder = colPoly(1).order;
else
   fittedCol = [];
   colResidual = [];
   colOrder = [];
end


% save outputs
M.ccdModule = mod;
M.ccdOutput = out;
M.rowCadences = cadences(validRowPoly);
M.colCadences = cadences(validColPoly);
M.fittedRow = fittedRow';
M.fittedCol = fittedCol';
M.rowResidual = rowResidual;
M.colResidual = colResidual;
M.rowOrder = rowOrder;
M.colOrder = colOrder;

