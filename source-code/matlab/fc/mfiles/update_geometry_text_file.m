function update_geometry_text_file( geometryFilename )
%
% update_geometry_text_file -- add pincushion parameters and, if necessary, plate scale
% parameters to a geometry text file
%
% update_geometry_text_file( geometryFilename ) updates a geometry text file by adding
%    values for the pincushion correction (1 value per mod/out).  If the geometry text
%    file has no values for plate scale, these are added as well (plate scale was
%    originally optional but is now mandatory).  The original file is renamed ('.orig' is
%    appended to the original name), and the new file is saved with the original file
%    name.
%
% Version date:  2009-April-22.
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
%=========================================================================================

% default plate scale, in case the plate scale is missing from the file; default
% pincushion is zero

  defaultPlateScale = 3.9753235 ; 
  defaultPincushion = 0 ;
  
% numbers of parameters

  nMjdParameters = 1 ;
  n321TransformParameters = 3*42 ;
  nOffsetParameters = 3*42 ;
  nPlateScaleParameters = 84 ;
  nPincushionParameters = 84 ;
  
  nOldRequiredParameters = nMjdParameters + n321TransformParameters + nOffsetParameters ;
  nNewRequiredParameters = nOldRequiredParameters + ...
      nPlateScaleParameters + nPincushionParameters ;

% open and read the file values into Matlab

  fileHandle = fopen(geometryFilename,'r') ;
  if (fileHandle == -1)
      error('matlab:fc:updateGeometryTextFile:noSuchFile', ...
          'update_geometry_text_file:  requested file not found') ;
  end
  
  oldValues = fscanf(fileHandle,'%f') ;
  oldValues = oldValues(:) ;
  nOldValues = length(oldValues) ;
  
  fclose(fileHandle) ;
  
% write the existing data out to the duplicate filename

  write_fpg_import_file( [geometryFilename,'.orig'], oldValues ) ;
  
% start writing the new values array 
  
  newValues = zeros(nNewRequiredParameters,1) ;
  newValues(1:nOldValues) = oldValues ;
  
% if the plate scale is missing, append the old default plate scale 84 times

  if (nOldValues == nOldRequiredParameters)
      newValues(nOldRequiredParameters+1:nOldRequiredParameters+84) = defaultPlateScale ;
  end
  
% if the pincushion is missing, append it

  if (nOldValues < nNewRequiredParameters)
      newValues(nOldRequiredParameters+nPlateScaleParameters+1:nNewRequiredParameters) = ...
          defaultPincushion ;
  end
  
% write the updated data to the file

  write_fpg_import_file( geometryFilename, newValues ) ;
  
return 

% and that's it!

%
%
%

%=========================================================================================

% subfunction which writes the geometry file with the desired values

function write_fpg_import_file( geometryFilename, values )

  
% open the file with mode wt, just in case the user is running windows

  fileHandle = fopen(geometryFilename, 'wt') ;
  
% write the MJD with high precision

  fprintf(fileHandle, '%16.10f\n',values(1)) ;

% write the 3-2-1 transform parameters in lines with 3 parameters per line 
      
  fprintf(fileHandle, '%-16.14f %-16.13f %-16.11f\n', values(2:127)) ;
  
% write the offset parameters in lines with 3 parameters per line

  fprintf(fileHandle, '%-16.14f %-16.13f %-16.13f\n', values(128:253)) ;
  
% If there are plate scale parameters, they can be written out with high precision but as
% floats

  if (length(values) > 253)
      fprintf(fileHandle, '%-16.14f\n', values(254:337)) ;
  end
  
% finally, any pincushion parameters should be written out in exponential notation, since
% they are typically tiny

  if (length(values) > 337)
      fprintf(fileHandle, '%-16.14e\n',values(338:end)) ;
  end
  
  fclose(fileHandle) ;
  
return

% and that's it!

%
%
%
