function syntheticNoiseObject = set_spectrum_array( syntheticNoiseObject, spectrumArray )
%
% set_spectrum_array -- set the spectrumArray member of a syntheticNoiseClass object
%
% syntheticNoiseObject = set_spectrum_array( syntheticNoiseObject, spectrumArray ) allows
%    the user to specify a desired array of values for the spectrumArray, which is later
%    used to transform the white noise vector into a colored noise vector.  When the
%    spectrumArray member is successfully set, the coloredNoise member is blanked so that
%    an inconsistency between these two members is prevented.
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

% check to make sure that the array is numeric with correct dimensionality

  goodArgument = isnumeric( spectrumArray ) && ~any( isnan( spectrumArray(:) ) ) && ...
      ~any( isinf( spectrumArray(:) ) ) && all( isreal( spectrumArray(:) ) ) && ...
      ndims( spectrumArray ) < 3 ;
  
  if ~goodArgument
      error( 'syntheticNoiseClass:setSpectrumArray:invalidArgument', ...
          'spectrumArray argument is invalid' ) ;
  end
  
% if the argument is a scalar or a vector, expand it into a 2-d array properly

  if isscalar( spectrumArray )
      spectrumArray = repmat(spectrumArray,2,2) ;
  elseif size( spectrumArray, 1 ) == 1
      spectrumArray = repmat(spectrumArray,2,1) ;
  elseif size( spectrumArray, 2 ) == 1
      spectrumArray = repmat(spectrumArray,1,2) ;
  end
  
% scale it

  spectrumArrayVector = spectrumArray(:) ;
  noiseMin            = min( spectrumArrayVector( spectrumArrayVector > 0 ) ) ;
  spectrumArrayVector = spectrumArrayVector / noiseMin ;
  
% replace zeros with a fixed small value

  fixedSmallValue = 1e-12 ;
  spectrumArrayVector(spectrumArrayVector < fixedSmallValue) = fixedSmallValue ;
  spectrumArray = reshape( spectrumArrayVector, size(spectrumArray) ) ;
  
% set it
  
  syntheticNoiseObject.spectrumArray = spectrumArray ;
  syntheticNoiseObject.coloredNoise  = [] ;
 


return

