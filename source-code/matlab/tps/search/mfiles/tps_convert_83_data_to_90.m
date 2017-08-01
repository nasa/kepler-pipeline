function [ tpsInputStruct ] = tps_convert_83_data_to_90( tpsInputStruct )
%
% tps_convert_83_data_to_90 -- convert TPS inputs from version 8.3 standard to version 9.0
% standard
%
% tpsInputStruct = tps_convert_83_data_to_90( tpsInputStruct ) handles all necessary input
%    field additions, deletions, or modifications needed to allow a data struct from TPS
%    version 8.3 to run in TPS version 9.0 while the latter is under development.
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

%=========================================================================================

% max loop parameter

  if ~isfield( tpsInputStruct.tpsModuleParameters, 'maxFoldingLoopCount' ) 
      tpsInputStruct.tpsModuleParameters.maxFoldingLoopCount = 1000 ;
  end

% internally calculating the max search period so set it -1 by default  
  
  tpsInputStruct.tpsModuleParameters.maximumSearchPeriodInDays = -1 ;
  
% populate the quarterGapIndiators field

  for iTarget = 1:length(tpsInputStruct.tpsTargets)
      quarterInfoPresent = isfield(tpsInputStruct.tpsTargets(iTarget),'diagnostics') && ...
          isfield(tpsInputStruct.tpsTargets(iTarget).diagnostics,'gapIndicators') ;
      if ~isfield( tpsInputStruct.tpsTargets, 'quarterGapIndicators' ) || ...
              isempty( tpsInputStruct.tpsTargets(iTarget).quarterGapIndicators )
        if quarterInfoPresent
          tpsInputStruct.tpsTargets(iTarget).quarterGapIndicators = ...
              tpsInputStruct.tpsTargets(iTarget).diagnostics.gapIndicators ;
        else
          tpsInputStruct.tpsTargets(iTarget).quarterGapIndicators = false(12,1) ;
        end
      end
  end
  

return

