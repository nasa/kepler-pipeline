% script to drive overnight runner for TPS
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

% default initialization

  if ~exist( 'tpsOutputStructArray' , 'var' )
      firstTarget = 1 ;
  end
  
% set the date and time for termination here

  terminationTime = datenum([2011 7 12 7 0 0]) ; % 2011 jul 12 at 7 AM
  
% perform the loop

  for ii = firstTarget:length( tpsInputStructArray )
      
      timeNow = now ;
      if timeNow >= terminationTime
          break ;
      end
      
      tpsDiagnosticName = ['tps-diagnostic-struct-',num2str(ii),'.mat'] ;
      tpsDawgName       = ['tps-task-file-dawg-struct-',num2str(ii),'.mat'] ;
      if ~exist( 'tpsOutputStructArray', 'var' )
          tpsOutputStructArray = tps_matlab_controller( tpsInputStructArray(ii) ) ;
          tpsResultsArray = tpsOutputStructArray.tpsResults ;
      else
          tpsOutputStructArray = [ tpsOutputStructArray ...
              tps_matlab_controller( tpsInputStructArray(ii) ) ] ;
          tpsResultsArray = [tpsResultsArray tpsOutputStructArray(ii).tpsResults] ;
      end
      
%     rename the diagnostic and DAWG task files so that they don't get lost      
      
      load tps-diagnostic-struct ;
      load tps-task-file-dawg-struct ;
      save( tpsDiagnosticName, 'tpsDiagnosticStruct' ) ;
      save( tpsDawgName,       'tpsDawgStruct' ) ;
      clear tpsDiagnosticStruct tpsDawgStruct ;
      
  end
  
% if we didn't make it all the way through, update firstTarget index.  Actually, update it
% no matter what, so an acciental 2nd launching of this script won't overwrite the
% existing results.
  
if exist( 'tpsOutputStructArray', 'var' )
    firstTarget = length( tpsOutputStructArray ) + 1 ;
end
