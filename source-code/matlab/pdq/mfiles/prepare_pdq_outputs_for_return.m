function pdqOutputStruct = prepare_pdq_outputs_for_return(pdqOutputStruct,modOutsProcessed)


% remove the modouts which are empty
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

% pdqOutputStruct
% pdqOutputStruct =
%                       outputPdqTsData: [1x1 struct]
%                   attitudeAdjustments: [1x1 struct]
%               pdqModuleOutputReports: [84x1 struct]
%                      attitudeSolution: [4x3 double]
%     attitudeSolutionUncertaintyStruct: [4x1 struct]
% save pdqOutputStruct.mat pdqOutputStruct
% pdqOutputStruct
% pdqOutputStruct =
%                       outputPdqTsData: [1x1 struct]
%                   attitudeAdjustments: [1x1 struct]
%               pdqModuleOutputReports: [84x1 struct]
%                      attitudeSolution: [4x3 double]
%     attitudeSolutionUncertaintyStruct: [4x1 struct]
% pdqOutputStruct.outputPdqTsData
% ans =
%             pdqModuleOutputTsData: [84x1 struct]
%                      cadenceTimes: [4x1 double]
%                attitudeSolutionRa: [1x1 struct]
%               attitudeSolutionDec: [1x1 struct]
%              attitudeSolutionRoll: [1x1 struct]
%                 desiredAttitudeRa: [1x1 struct]
%                desiredAttitudeDec: [1x1 struct]
%               desiredAttitudeRoll: [1x1 struct]
%     maxAttitudeResidualInPixels: [1x1 struct]
% pdqOutputStruct.outputPdqTsData.attitudeSolutionDec
% ans =
%            values: [4x1 double]
%     gapIndicators: [4x1 double]
%     uncertainties: [4x1 double]
% pdqOutputStruct.pdqModuleOutputReports
% ans =
% 84x1 struct array with fields:
%     ccdModule
%     ccdOutput
%     blackLevel
%     smearLevel
%     darkCurrent
%     backgroundLevel
%     dynamicRange
%     meanFluxe
%     centroidsMeanRow
%     centroidsMeanCol
%     encircledEnergy
%     plateScale

modoutsNotProcessed = find(~modOutsProcessed);

if(~isempty(modoutsNotProcessed))

    pdqOutputStruct.outputPdqTsData.pdqModuleOutputTsData(modoutsNotProcessed) = [];
    pdqOutputStruct.pdqModuleOutputReports(modoutsNotProcessed) = [];

end


return