function tpsDawgStructDv = aggregate_dv_side_tps_dawg_structs( topDir )
%
% aggregate_dv_side_tps_dawg_structs -- perform TPS DAWG struct aggregation within a DV
% task file directory tree
%
% tpsDawgStructDv = aggregate_dv_side_tps_dawg_structs( topDir ) loops over all DV task
%    files under the topDir, aggregating the underlying TPS DAWG structs into a single
%    struct, which is then returned to the caller.
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

  tpsDawgStructDv = [] ;
  MAX_NUM_PLANETS = 10;

% get the top level dv-matlab-* directory list

  topDirList = dir(fullfile(topDir,'dv-matlab-*')) ;
  
  for iTopDir = 1:length(topDirList)
      thisTopDir = fullfile(topDir,topDirList(iTopDir).name) ;
      disp( [' ... ', datestr(now), ...
          ':assembling TPS DAWG information from ',topDirList(iTopDir).name, ...
          ' directory ...' ] ) ;
      
%     get st-# directories

      subDirList = dir(fullfile(thisTopDir,'st-*')) ;
      
      for iSubDir = 1:length(subDirList)
          
          dawgFileName = fullfile(thisTopDir,subDirList(iSubDir).name, ...
              'tps-task-file-dawg-struct-dv.mat') ;
          if exist(dawgFileName,'file')
              load(dawgFileName) ; 
              tpsDawgStruct = correct_shape_of_quarters_present( tpsDawgStruct ) ;
              if isequal(length(tpsDawgStruct),MAX_NUM_PLANETS)
                  % if we hit the max number of planets then the last one
                  % is from the final call to TPS but it is for diagnostic
                  % purposes only - When we combine with the initial TCE
                  % from TPS then we should only have MAX_NUM_PLANETS Total
                  tpsDawgStruct = tpsDawgStruct(1:MAX_NUM_PLANETS-1);
              end
              tpsDawgStructDv = combine_tps_dawg_structs( ...
                  [tpsDawgStructDv(:) ; tpsDawgStruct(:)] ) ;
              clear tpsDawgStruct
          end
          
      end
      
%     let garbage collection catch up

      pause(1) ;
      
  end

return

%========================================================================================

% subfunction which takes the atomic TPS DAWG structs and makes their quartersPresent
% vectors into row vectors

function tpsDawgStruct = correct_shape_of_quarters_present( tpsDawgStruct )

  for iStruct = 1:length(tpsDawgStruct)
      tpsDawgStruct(iStruct).quartersPresent = tpsDawgStruct(iStruct).quartersPresent' ;
  end
  
return

