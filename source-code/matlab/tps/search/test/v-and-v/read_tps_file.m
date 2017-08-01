function tpsFile = read_tps_file( topDir, dirName, inputOutputFlag, useBinFile )
%
% tpsFile = read_tps_file( topDir, dirName, inputOutputFlag ) -- utility which reads
% either the bin-file or the mat-file from a TPS task file directory and returns its
% contents.  Allowed values for inputOutputFlag are 0 (read input file), 1 (read output
% file), 2 (read diagnostic file).
%
% tpsFile = read_tps_file( ... , useBinFile ) attempts to use the bin-file rather than the
% mat-file if useBinFile is true, and attempts to use the mat-file rather than the
% bin-file if useBinFile is false.  Default is true.
%
% Version date:  2011-May-12.
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

% Modification History:
%
%    2011-May-12, PT:
%        add support for diagnostics files.
%    2010-October-27, PT:
%        allow the user to select whether to use bin-files or mat-files by default.
%
%=========================================================================================

  if ~exist( 'useBinFile', 'var' ) || isempty( useBinFile )
      useBinFile = true ;
  end

  if inputOutputFlag == 0
      
      binFile = 'tps-inputs-0.bin' ;
      matFile = 'tps-inputs-0.mat' ;
      binReader = 'read_TpsInputs' ;
      renameCommand = 'tpsFile = inputsStruct ;' ;
      
  elseif inputOutputFlag == 1
      
      binFile = 'tps-outputs-0.bin' ;
      matFile = 'tps-outputs-0.mat' ;
      binReader = 'read_TpsOutputs' ;
      renameCommand = 'tpsFile = outputsStruct ;' ;
      
  else
      
      binFile = 'dummy.bin' ;
      matFile = 'tps-diagnostic-struct.mat' ;
      binReader = '' ;
      renameCommand = 'tpsFile = tpsDiagnosticStruct ;' ;
      useBinFile = false ;
      
  end
  
  binFile = fullfile( topDir, dirName, binFile ) ;
  matFile = fullfile( topDir, dirName, matFile ) ;
  
  binFileCommand = ['tpsFile = ', binReader, '( ''', binFile, ''' ) ;'] ;
  binFileEval = 'eval( binFileCommand ) ;' ;
  matFileEval = 'load( matFile ) ; eval( renameCommand ) ; ' ;
  
  if useBinFile
      defaultFile = binFile ;
      defaultCmd  = binFileEval ;
      fallbackCmd = matFileEval ;
  else
      defaultFile = matFile ;
      defaultCmd  = matFileEval ;
      fallbackCmd = binFileEval ;
  end
      
  if exist( defaultFile, 'file' )
      eval( defaultCmd ) ;
  elseif exist(binFile,'file') || exist(matFile,'file')
      eval( fallbackCmd ) ;
  else
      tpsFile =[];
  end
  
return