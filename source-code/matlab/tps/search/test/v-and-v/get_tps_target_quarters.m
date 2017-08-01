function quarters = get_tps_target_quarters( tceStruct, keplerId )
%
% get_tps_target_quarters -- determine the quarters of observation for a selected target
% which is processed in TPS-MQ
%
% quarters = get_tps_target_quarters( tceStruct, keplerId ) returns a list of the quarters
%    within which the selected target was observed, based on information from the selected
%    task file directory tree.  For example, for a target observed only on Q1, Q2, and Q4,
%    quarters == [1 ; 2 ; 4].
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

% the quarters can be defined by their cadence numbers, which do not change with time
% except to expand as we add quarters

  quarterTimingStruct = get_quarter_timing_struct ;
  quarterStartCadenceNumbers = [quarterTimingStruct.quarterStartCadenceNumber] ;
  quarterEndCadenceNumbers   = [quarterTimingStruct.quarterEndCadenceNumber] ;
  quarterNumber              = [quarterTimingStruct.quarterNumber] ;
  
% load the task file

  taskFile = get_tps_struct_by_kepid_from_task_dir_tree( tceStruct, keplerId, 'input', ...
      false ) ;
  cadenceNumbers = taskFile.cadenceTimes.cadenceNumbers ;
  gapIndicators  = false( size( cadenceNumbers ) ) ;
  gapIndicators( taskFile.tpsTargets.gapIndices+1 ) = true ;
  
% start by eliminating any quarters which are not present in the cadence times at all

  quarterStartPresent = ismember( quarterStartCadenceNumbers, cadenceNumbers ) ;
  quarterEndPresent   = ismember( quarterEndCadenceNumbers, cadenceNumbers ) ;
  
% handle a couple of error cases

  if any( cadenceNumbers > quarterEndCadenceNumbers(end) ) || ...
          any( cadenceNumbers < quarterStartCadenceNumbers(1) )
      error('tps:getTpsTargetQuarters:invalidQuarters', ...
          'get_tps_target_quarters:  cadence numbers outside valid range present') ;
  end
  if any( quarterStartPresent & ~quarterEndPresent ) || ...
          any( ~quarterStartPresent & quarterEndPresent )
      error('tps:getTpsTargetQuarters:partialQuarters', ...
          'get_tps_target_quarters:  partial quarters present in task file') ;
  end
  
% OK, now finish the job of removing quarters which are absent from the cadence times

  quarterPresent             = quarterStartPresent & quarterEndPresent ;
  quarterStartCadenceNumbers = quarterStartCadenceNumbers( quarterPresent ) ;
  quarterEndCadenceNumbers   = quarterEndCadenceNumbers( quarterPresent ) ;
  quarterNumber              = quarterNumber( quarterPresent ) ;
  quarterStartIndices        = find( ismember( cadenceNumbers, quarterStartCadenceNumbers ) ) ;
  quarterEndIndices          = find( ismember( cadenceNumbers, quarterEndCadenceNumbers ) ) ;
  
% I can't figure out how to do the actual quarter search without a for-loop

  thisQuarterPresent = true( size( quarterNumber ) ) ;
  for iQuarter = 1:length( quarterNumber )
      quarterRange = quarterStartIndices(iQuarter):quarterEndIndices(iQuarter) ;
      thisQuarterPresent(iQuarter) = ~all( gapIndicators(quarterRange) ) ;
  end
  quarters = quarterNumber( thisQuarterPresent ) ;
  quarters = quarters(:) ;

return

