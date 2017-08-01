function [timeoutDirs, errorDirs, noLogDirs] = tps_folding_times_and_errors( ...
    tpsDawgStruct, targetFailureStruct )
%
% tps_folding_time_and_errors -- study TPS folding time execution, timeouts, and errors
%
% [timeoutDirs,errorDirs,noLogDirs] = tps_folding_times_and_errors( tpsDawgStruct,
%    targetFailureStruct ) determines the median, 99 percentile, and max total folding
%    time for a TPS run, and displays same; it returns the directories which correspond to
%    targets which timed out, a separate list of directories corresponding to targets
%    which failed due to an error, and a third list of directories corresponding to
%    targets which failed and produced no log file.
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

% start with folding time information

  foldingTime = sum(tpsDawgStruct.foldingWallTimeHours,2) ;
  foldingTimeMedian = median(foldingTime) ;
  foldingTime99 = quantile(foldingTime,0.99) ;
  foldingTimeMax = max(foldingTime) ;
  
% now examine the error directories:  the directory information is from the original
% worker directories, so we need to build the correct directory filespec from the top dir
% in the dawg struct and the end of the filespec in the target failure struct

  nFailures = length(targetFailureStruct) ;
  errorCase = false(nFailures,1) ;
  timeoutCase = false(nFailures,1) ;
  noLogCase = false(nFailures,1) ;
  if nFailures > 0
      targetFailureStruct(1).correctedDir = '' ;

      for iFailure = 1:length(targetFailureStruct)
          dirPointer = strfind( targetFailureStruct(iFailure).directory, 'tps-matlab') ;
          specificDir = targetFailureStruct(iFailure).directory(dirPointer:end) ;
          slashPointer = strfind( specificDir, '/' ) ;
          logFile = [specificDir, '.log'] ;
          logFile(slashPointer) = '-' ;
          fullDir = fullfile(tpsDawgStruct.topDir,specificDir) ;
          fullFilename = fullfile(fullDir,logFile) ;
          if exist(fullFilename,'file')
              noLogCase(iFailure) = false ;
              timeoutTestCommand = ['tail -10 ',fullFilename,' | grep -q "timed out"'] ;
              timeoutTest = system(timeoutTestCommand) ;
              if ~timeoutTest % note that grep retval has opposite meaning of MATLAB logicals
                  timeoutCase(iFailure) = true ;
                  errorCase(iFailure) = false ;
              else
                  timeoutCase(iFailure) = false ;
                  errorCase(iFailure) = true ;
              end
          else
              noLogCase(iFailure) = true ;
              timeoutCase(iFailure) = false ;
              errorCase(iFailure) = false ;
          end
          targetFailureStruct(iFailure).correctedDir = fullDir ;
      end

    % build the return structs

      errorDirs = cell(sum(errorCase),1) ;
      timeoutDirs = cell(sum(timeoutCase),1) ;
      noLogDirs = cell(sum(noLogCase),1) ;

    % populate the return structs  

      errorList = find(errorCase) ; 
      for iError = 1:length(errorList)
          errorDirs{iError} = targetFailureStruct(errorList(iError)).correctedDir ;
      end
      timeoutList = find(timeoutCase) ; 
      for iTimeout = 1:length(timeoutList)
          timeoutDirs{iTimeout} = targetFailureStruct(timeoutList(iTimeout)).correctedDir ;
      end
      noLogList = find(noLogCase) ; 
      for iNoLog = 1:length(noLogList)
          noLogDirs{iNoLog} = targetFailureStruct(noLogList(iNoLog)).correctedDir ;
      end
  else
      timeoutDirs = [] ;
      errorDirs = [] ;
      noLogDirs = [] ;
  end

% display the folding time information at the end  
  
  disp( ['Median folding time         == ', num2str(foldingTimeMedian), ' hours'] ) ;
  disp( ['99 %-ile folding time       == ', num2str(foldingTime99), ' hours'] ) ;
  disp( ['Max successful folding time == ', num2str(foldingTimeMax), ' hours'] ) ;
  
return

