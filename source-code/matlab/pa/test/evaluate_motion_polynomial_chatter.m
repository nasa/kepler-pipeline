function chatterMetrics = evaluate_motion_polynomial_chatter( motionStruct, derivativeBP, cadenceFractionThreshold, targetFractionThreshold, dimString )
% function chatterMetrics = evaluate_motion_polynomial_chatter( motionStruct, derivativeBP, cadenceFractionThreshold, targetFractionThreshold, dimString )
%
% This funtion is used in generating DAWG disnostic metrics for the motion polynomial fits in PA.
% The cadence to cadence chatter of the evaluated motion polynomials is assessed by examining the 
% first derivative approximation (delta row or column / delta cadence) of the fitted row or column
% value. This derivative approximation at the location of each of the 200 PPA targets is compared
% to the derivative breakpoints for each cadence. The metrics are returned  in a 2x2 array. For 
% breakpoint (row): 
% column (1) fraction of targets whose fraction of cadences above breakpoint are above cadenceFractionThreshold
% column (2) fraction of cadences whose fraction of targets above breakpoint are above targetFractionThreshold
%
% INPUTS:   motionStruct                = motionOutputStruct from pa-dawg-motion.mat containing
%                                         fitted motion polynomial values at the PPA target locations.
%                                         motionOutputStruct = 
%                                                       ccdModule: 4
%                                                       ccdOutput: 2
%                                                     rowCadences: [4238x1 double]
%                                                     colCadences: [4238x1 double]
%                                                       fittedRow: [4238x200 double]
%                                                       fittedCol: [4238x200 double]
%                                                     rowResidual: [4238x200 double]
%                                                     colResidual: [4238x200 double]
%           derivativeBP                = list of breakpoints in units of pixels
%           cadenceFractionThreshold    = fraction of cadences needed above breakpoint for target to be counted as above breakpoint
%           targetFractionThreshold     = fraction of targets above breakpoint for cadence to be counted as above breakpoint
%           dimString                   = {'row','column'}
% OUTPUTS:  chatterMetrics              = 2 x 2 array of chatter metrics indicating the fraction of targets/cadences 
%                                         above breakpoint. One row per breakpoint, one column per threshold.
%                                         e.g.
%                                         column (1) == fraction of targets whose fraction of cadences above
%                                         breakpoint are above cadenceFractionThreshold
%                                         column (2) == fraction of cadences whose fraction of targets above
%                                         breakpoint are above targetFractionThreshold
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


chatterMetrics = -ones(length(derivativeBP),2);
                    
if( strcmpi(dimString,'row') )
    fittedData = motionStruct.fittedRow;
    fittedCadences = motionStruct.rowCadences;
elseif( strcmpi(dimString,'column') )
    fittedData = motionStruct.fittedCol;
    fittedCadences = motionStruct.colCadences;
else
    return;
end


[nCadences, nTargets] = size(fittedData);
absDeriv = abs(diff(fittedData)./repmat(diff(fittedCadences),1,nTargets));

for iBP = 1:length(derivativeBP)
    chatterMetrics(iBP,1) = sum(sum(absDeriv > derivativeBP(iBP),1)./nCadences > cadenceFractionThreshold) / nTargets;
    chatterMetrics(iBP,2) = sum(sum(absDeriv > derivativeBP(iBP),2)./nTargets > targetFractionThreshold) / nCadences;
end

