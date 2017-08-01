function tpsDawgStructAll = combine_tps_and_dv_dawg_structs( tpsDawgStructPipeline, ...
    tpsDawgStructDv )
%
% combine_tps_and_dv_dawg_structs -- combine the TPS DAWG structs generated in the TPS
% pipeline run and the DV pipeline run
%
% tpsDawgStructAll = combine_tps_and_dv_dawg_structs( tpsDawgStructPipeline,
%    tpsDawgStructDv ) takes the DAWG values from the tpsDawgStructDV and merges them into
%    the values in tpsDawgStructPipeline, placing the merged result into tpsDawgStructAll.
%    The taskfile locations for each entry in the tpsDawgStructDv will, when merged, be
%    set to match the taskfile location for the corresponding target in the
%    tpsDawgStructPipeline, on the theory that even when you are looking at the results
%    for the Nth planet on a target, you really want to look back at the TPS run
%    directory, since it contains the diagnostics etc.
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

%========================================================================================

% strip the pulse duration and unit of work vectors off the DV struct

  tpsDawgStructDv = rmfield(tpsDawgStructDv, {'pulseDurations', 'unitOfWorkKjd'}) ;
  tpsDawgStructFieldNames = fieldnames(tpsDawgStructDv) ;
    

  
  % loop over fields and combine the DV stuff into the pipeline stuff
  
  % copy of tpsDawgStructPipeline
  tpsDawgStructAll = tpsDawgStructPipeline ;
  
  % Strip the taskfile field
  % tpsDawgStructAll = rmfield(tpsDawgStructAll, 'taskfile') ;
  
  for iField = 1:length(tpsDawgStructFieldNames)
      thisFieldName = tpsDawgStructFieldNames{iField} ;
      
      if(strcmp(thisFieldName,'maxMesPulseDurationHours'))
          tpsDawgStructAll.(thisFieldName) = [tpsDawgStructAll.(thisFieldName) , ...
              tpsDawgStructDv.(thisFieldName)];
      elseif(strcmp(thisFieldName,'taskfile'))
          
      else
          
          if(~iscell(tpsDawgStructAll.(thisFieldName))&&...
                  ~isa(tpsDawgStructAll.(thisFieldName),'double')&&...
                  ~islogical(tpsDawgStructAll.(thisFieldName)))
              tpsDawgStructAll.(thisFieldName) = [tpsDawgStructAll.(thisFieldName) ; ...
                  single(tpsDawgStructDv.(thisFieldName))] ;
          else
              tpsDawgStructAll.(thisFieldName) = [tpsDawgStructAll.(thisFieldName) ; ...
                  tpsDawgStructDv.(thisFieldName)] ;
          end
          
      end
      
  end
  
  % find the entries in the pipeline dawg struct which correspond to the targets in the DV
  % dawg struct
  
  [~,loc] = ismember( tpsDawgStructDv.keplerId, tpsDawgStructPipeline.keplerId ) ;
  
  nonZeroLocPointer = find(loc ~= 0) ;
  nonZeroLoc        = loc(nonZeroLocPointer) ;
  
  if (any( loc == 0 ) )
      warn('tps:combineTpsAndDvDawgStructs:zeroLocDetected', ...
          'combine_tps_and_dv_dawg_structs: targets present in DV but not TPS struct!') ;
  end
  
  dvTaskFiles = cell(length(loc),1) ;
  dvTaskFiles(nonZeroLocPointer) = tpsDawgStructPipeline.taskfile(nonZeroLoc) ;
  tpsDawgStructAll.taskfile = [tpsDawgStructAll.taskfile ; dvTaskFiles] ;
  
  return
  
