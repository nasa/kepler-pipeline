function extendedFlux = extend_tps_flux( tpsObject )
%
% extend_tps_flux -- extend the flux time series in TPS to a power of 2 length, if
% necessary
%
% extendedFlux = extend_tps_flux( tpsObject ) performs extension of the TPS flux to a
%    power of 2 length, if the length of the flux is not already a power of 2.  This is
%    accomplished via the gap-filling utilities in the PDC CSCI.
%
% Version date:  2010-September-27.
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

% Modification history:
%
%=========================================================================================

% get some stuff we need

  tpsTargets = tpsObject.tpsTargets ;
  nTargets   = length( tpsTargets ) ;
  nCadences  = length( tpsObject.cadenceTimes.cadenceNumbers ) ;
  debugLevel = tpsObject.tpsModuleParameters.debugLevel ;
  gapFillParameters = tpsObject.gapFillParameters ;
  
  displayProgressInterval = 0.1 ; % display progress every 10% or so
  nTargetsProgress        = nTargets * displayProgressInterval ;
  progressReports         = nTargetsProgress:nTargetsProgress:nTargets ;
  progressReports         = unique(floor(progressReports)) ;
  
% determine the next-larger power of 2 -- note that if we should happen to already be at a
% power of 2, then nothing should happen

  n2                = ceil( log2( nCadences ) ) ;
  nCadencesExtended = 2^n2 ;
  
  if isequal(nCadences, nCadencesExtended)
      powerOfTwoFlag = true;
  else
      powerOfTwoFlag = false;
  end
  
% initialize the extendedFlux array

  extendedFlux      = zeros(nCadencesExtended, nTargets) ;
  longGapIndicators = false(nCadencesExtended, 1) ;
  longGapIndicators((nCadences+1):end) = true ;
  
  startTime = clock ;
  if debugLevel >= 0
      disp( '    Extending flux to nearest power of 2 length ...' ) ;
  end
  
% loop over targets and perform the extension

  for iTarget = 1:nTargets
      
      target = tpsTargets(iTarget) ;
      
      if ismember( iTarget, progressReports ) && debugLevel >= 0
          disp( [ '        Flux Extension:  starting target star number ', ...
              num2str(iTarget),' out of ', num2str(nTargets),' total ' ] ) ;
      end
      
      extendedFlux(1:nCadences,iTarget) = target.fluxValue ; 
      
      if ~powerOfTwoFlag
          
% fill outliers to prevent them from entering the flux extension
      
          outlierIndicators = target.outlierIndicators ;
          extendedFlux(outlierIndicators,iTarget) = target.outlierFillValues ;
          
          extendedFlux(:,iTarget) = fill_missing_quarters_via_reflection( ...
              extendedFlux(:,iTarget), longGapIndicators, [],  gapFillParameters) ;
          
          extendedFlux(outlierIndicators,iTarget) = target.fluxValue(outlierIndicators) ;
          
% if the mean or median of the original flux was zero then adjust the extension

         if isequal(mean(extendedFlux(1:nCadences,iTarget)),0)
             extendedFlux(nCadences+1:end,iTarget) = extendedFlux(nCadences+1:end,iTarget) - ...
                 mean(extendedFlux(nCadences+1:end,iTarget)) ;
         end
         
         if isequal(median(extendedFlux(1:nCadences,iTarget)),0)
             extendedFlux(nCadences+1:end,iTarget) = extendedFlux(nCadences+1:end,iTarget) - ...
                 median(extendedFlux(nCadences+1:end,iTarget)) ;
         end
         
      end
      
  end
  
  if debugLevel >= 0
      disp( [ '    ... flux extension complete after ', num2str( etime( clock, startTime ) ), ...
          ' seconds' ] ) ;
  end
  
return

% and that's it!

%
%
%
