function tpsStruct = get_tps_struct_by_kepid_from_task_dir_tree( tceStruct, keplerId, ...
    fileType, useBinFile )
%
% get_tps_struct_by_kepid_from_task_dir_tree -- get a TPS struct associated with a given
% Kepler ID from the directory tree of pipeline task files
%
% tpsStruct = get_tps_struct_by_kepid_from_task_dir_tree( tceStruct, keplerId, fileType,
%    useBinFile ) digs through the pipeline file tree indicated by the tceStruct, locates
%    the requested struct file based on the keplerId, and returns it.  Full definition of
%    arguments is as follows:
%
%    tceStruct:  struct of the form returned by get_tces_from_tps_dawg_struct.  Note that
%                a struct of the form returned by assemble_tps_dawg_struct may also be
%                used.
%    keplerId:   scalar Kepler ID value.
%    fileType:   optional name of the desired type of file, can be 'input', 'output', or
%                'diagnostic'.  If omitted, 'input' is assumed.
%    useBinFile: optional flag indicating whether a .bin file should be used even if a
%                .mat file is present.  If omitted, 'false' (use .bin file only if .mat
%                file is missing) is assumed.
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

% manage defaults

  if ~exist( 'fileType', 'var' ) || isempty( fileType )
      fileType = 'input' ;
  end
  if ~exist( 'useBinFile', 'var' ) || isempty( useBinFile )
      useBinFile = false ;
  end
  
% assemble directory information for the desired task file

  tpsPointer = find( tceStruct.keplerId == keplerId ) ;
  tpsDirectory = ['tps-matlab',tceStruct.taskfile{tpsPointer(1)}] ;
  
% perform the read, which depends on the fileType

  switch fileType
      
      case 'input'
          tpsStruct = read_tps_file( tceStruct.topDir, tpsDirectory, 0, useBinFile ) ;
      case 'output'
          tpsStruct = read_tps_file( tceStruct.topDir, tpsDirectory, 1, useBinFile ) ;
      case 'diagnostic'
          tpsStruct = read_tps_file( tceStruct.topDir, tpsDirectory, 2, useBinFile ) ;
      otherwise
          
          error('tps:getTpsStructByKepidFromTaskDirTree:invalidFileType', ...
              ['get_tps_struct_by_kepid_from_task_dir_tree: invalid fileType "', ...
              fileType,'"']) ;
          
  end
  
return

