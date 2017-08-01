function display_geometry_fits( ccdList, currentGeometry, fittedGeometry, ...
    geometryChangeStructVector, filePointer )
%
% display_geometry_fits -- display information about the Quasar geometry fits to the
% Matlab command window
%
% display_geometry_fits( ccdList, currentGeometry, fittedGeometry,
%    geometryChangeStructVector ) sends to the Matlab command window a set of tables about
%    the fitted geometry for the selected ccds.
%
% display_geometry_fits( ..., filePointer ) sends the output to the selected file (via a
% Matlab file pointer) rather than to the display.
%
% Version date:  2009-February-18.
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
%    2009-February-18, PT:
%        replace disp statements with fprintf statements so that output can go to display
%        or a file.
%
%=========================================================================================

% handle the case of a missing file pointer -- default it to standard output

  if (nargin == 4)
      filePointer = 1 ;
  end
  
% display the top lines

  fprintf(filePointer,'\n') ;
  fprintf(filePointer,...
      '============== Quasar Image Fitter:  Fit Results ===========================\n') ;
  fprintf(filePointer,'\n') ;

% display the header for 3-2-1 angles table

  fprintf(filePointer,...
      ' CCD # | Angle # | Current     | Fitted      | Change      | Uncertainty \n') ;
  fprintf(filePointer,...
      '       |         | Value       | Value       | in Value    | in Value\n') ;
  fprintf(filePointer,...
      '       |         | (deg)       | (deg)       | (deg)       | (deg)\n') ;
  fprintf(filePointer,...
      '       |         |             |             |             | \n') ;
  fprintf(filePointer,...
      '============================================================================\n') ;

% loop over ccds and do the displaying

  nCcd = length(ccdList) ;
  for ccdIndex = 1:nCcd
      
      ccdNumber = ccdList(ccdIndex) ;
      angle1Index = 3*ccdNumber ;
      currentValues = currentGeometry.constants(1).array(angle1Index-2:angle1Index) ;
      fittedValues  = fittedGeometry.constants(1).array(angle1Index-2:angle1Index) ;
      geometryChangeStruct = geometryChangeStructVector(ccdIndex) ;
      
       fprintf(filePointer,...
           '   %02d  |    %1d    | %+11.8f | %+11.8f | %+11.8f | %12.9f\n', ...
           ccdNumber, 3, currentValues(1), fittedValues(1), ...
           geometryChangeStruct.angle3ChangeDegrees.value, ...
           geometryChangeStruct.angle3ChangeDegrees.uncertainty) ;
      fprintf(filePointer, ...
           '   %02d  |    %1d    | %+11.8f | %+11.8f | %+11.8f | %12.9f\n', ...
           ccdNumber, 2, currentValues(2), fittedValues(2), ...
           geometryChangeStruct.angle2ChangeDegrees.value, ...
           geometryChangeStruct.angle2ChangeDegrees.uncertainty) ;
      fprintf(filePointer, ...
           '   %02d  |    %1d    | %+11.6f | %+11.6f | %+11.8f | %12.9f\n', ...
           ccdNumber, 1, currentValues(3), fittedValues(3), ...
           geometryChangeStruct.angle1ChangeDegrees.value, ...
           geometryChangeStruct.angle1ChangeDegrees.uncertainty) ;
      if (ccdIndex < nCcd)
        fprintf(filePointer,...
          '----------------------------------------------------------------------------\n') ;
      end
        
  end % loop over ccd #
  
% now display the row, column, rotation values

  fprintf(filePointer, ...
      '============================================================================\n') ;
  fprintf(filePointer,...
      ' CCD # |  Degree  |  Change     | Uncertainty \n') ;
  fprintf(filePointer,...
      '       |    of    |  in Value   | in Value    \n') ;
  fprintf(filePointer,...
      '       | Freedom  |  (pixels)   | (pixels)    \n') ;
  fprintf(filePointer,...
      '       |          |             |             \n') ;
  fprintf(filePointer,...
      '============================================================================\n') ;

  for ccdIndex = 1:nCcd
      ccdNumber = ccdList(ccdIndex) ;
      geometryChangeStruct = geometryChangeStructVector(ccdIndex) ;
      
      fprintf(filePointer, ...
          '   %02d  | Row      | %+011.7f | %11.7f\n', ...
          ccdNumber, geometryChangeStruct.rowChangePixels.value, ...
          geometryChangeStruct.rowChangePixels.uncertainty) ;
      fprintf(filePointer, ...
          '   %02d  | Column   | %+011.7f | %11.7f\n', ...
          ccdNumber, geometryChangeStruct.columnChangePixels.value, ...
          geometryChangeStruct.columnChangePixels.uncertainty) ;
      fprintf(filePointer, ...
          '   %02d  | Rotation | %+011.7f | %11.7f\n', ...
          ccdNumber, geometryChangeStruct.rotationChangePixels.value, ...
          geometryChangeStruct.rotationChangePixels.uncertainty) ;
      if (ccdIndex < nCcd)
        fprintf(filePointer,...
          '----------------------------------------------------------------------------\n') ;
      end
      
  end % loop over ccd #
  
% finally, display chisq and chisq/ndof

  fprintf(filePointer,...
      '============================================================================\n') ;
  fprintf(filePointer,' CCD # |  chisq  | ndof | chisq/ndof\n') ;
  fprintf(filePointer,'       |         |      | \n') ;
  fprintf(filePointer,...
      '============================================================================\n') ;
  for ccdIndex = 1:nCcd
      ccdNumber = ccdList(ccdIndex) ;
      geometryChangeStruct = geometryChangeStructVector(ccdIndex) ;
      chisq = geometryChangeStruct.chisq ;
      ndof  = geometryChangeStruct.ndof ;
      if (ndof == 0)
          cOverN = 0 ;
      else
          cOverN = chisq/ndof ;
      end
      fprintf(filePointer,'   %02d  | %07.3f | %04d | %f\n', ...
          ccdNumber, chisq, ndof, cOverN) ;
  end % loop over ccd #
  
  fprintf(filePointer,'\n') ;
  
return

% and that's it!

%
%
%
