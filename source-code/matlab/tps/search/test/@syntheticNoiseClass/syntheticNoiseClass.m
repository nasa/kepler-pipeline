function syntheticNoiseObject = syntheticNoiseClass( syntheticNoiseStruct )
%
% syntheticNoiseClass -- constructor for syntheticNoiseClass objects
%
% 
% syntheticNoiseObject = syntheticNoiseClass( syntheticNoiseStruct ) returns an object of
%    the syntheticNoiseClass, which is used to generate and manipulate synthetic noise
%    flux time series.  The syntheticNoiseStruct is a struct with the following fields:
%
%  Required fields:
% 
%    nSamples:       minimum length of the flux time series.
%    noiseScalePpm:  scalar which provides overall scaling of the noise in parts per
%                    million.
%
% Optional Fields:
%
%    spectrumArray:  2-d array used to shape the noise time series:  each column
%                    represents the time evolution of one frequency band.  Note that the
%                    number of rows (time steps) and columns (bands) is arbitrary, as the
%                    syntheticNoiseObject will interpolate to reach the correct number of
%                    bands and samples.  The convention is that higher rows are later in
%                    time (ie, allowing non-stationary noise), higher columns represent
%                    higher frequency bands.  
%    randStream:     MATLAB randstream object to be used in random number generation.  If
%                    empty or missing, the constructor will supply one.
%    reset:          logical indicating whether to reset the randstream on instantiation.
%                    If missing or empty, constructor will set to false.
%
% Constructor-supplied fields:  these fields are created or filled in by the constructor
% at instantiation time.  The user does not need to supply them, but if they are present
% they will be used in construction.  This allows a syntheticNoiseClass object to be cast
% as a struct and then turned back into a syntheticNoiseClass object.
%
%    whiteGaussianNoise:  array of white gaussian noise used for all subsequent
%                         operations.
%    coloredNoise:        array of colored noise generated from whiteGaussianNoise 
%                         according to the specifications present in this struct.
%    h0:                  vector of coefficients representing the low-pass filter in the
%                         time domain.
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

% check the mandatory fields and get local variables which are rescaled (in the case of
% the noise scale) or transformed to the next largest power of 2 (in the case of the
% number of samples)

  if ~isfield( syntheticNoiseStruct, 'nSamples' ) || ...
     ~isscalar( syntheticNoiseStruct.nSamples )   || ...
     syntheticNoiseStruct.nSamples <= 0
     error( 'tps:syntheticNoiseClass:nSamplesIllDefined', ...
         'syntheticNoiseClass:  nSamples field in struct argument must be a positive scalar' ) ;
  end
  nSamplesLog2 = log2( syntheticNoiseStruct.nSamples ) ;
  nSamplesPower2 = 2^( ceil( nSamplesLog2 ) ) ;
    
  if ~isfield( syntheticNoiseStruct, 'noiseScalePpm' ) || ...
     ~isscalar( syntheticNoiseStruct.noiseScalePpm )   || ...
     syntheticNoiseStruct.noiseScalePpm <= 0
     error( 'tps:syntheticNoiseClass:noiseScalePpmIllDefined', ...
         'syntheticNoiseClass:  noiseScalePpm field in struct argument must be a positive scalar' ) ;
  end
  noiseScale = syntheticNoiseStruct.noiseScalePpm / 1e6 ;
  
% handle the truly optional arguments now

  if ~isfield( syntheticNoiseStruct, 'spectrumArray' )
      syntheticNoiseStruct.spectrumArray = [] ;
  end
  if ~isfield( syntheticNoiseStruct, 'randStream' )
      syntheticNoiseStruct.randStream = RandStream( 'mt19937ar' ) ;
  end
  if ~isfield( syntheticNoiseStruct, 'reset' )
      syntheticNoiseStruct.reset = false ;
  end
  
% now add the fields which are generally populated by the constructor, but check to see if
% they are already present (we could be rebuilding an object after a previous object was
% cast to a struct)

  if ~isfield( syntheticNoiseStruct, 'whiteGaussianNoise' )
      syntheticNoiseStruct.whiteGaussianNoise = [] ;
  end
  if ~isfield( syntheticNoiseStruct, 'coloredNoise' )
      syntheticNoiseStruct.coloredNoise = [] ;
  end
  if ~isfield( syntheticNoiseStruct, 'h0' )
      syntheticNoiseStruct.h0 = [] ;
  end
  
% fill in some of the things which can be empty at startup

  if isempty( syntheticNoiseStruct.h0 )
      syntheticNoiseStruct.h0 = daubechies_low_pass_scaling_filter( 12 ) ;    
  end
  if isempty( syntheticNoiseStruct.spectrumArray )
      syntheticNoiseStruct.spectrumArray = [1 1 ; 1 1] ;
  end
  
  if syntheticNoiseStruct.reset
      reset( syntheticNoiseStruct.randStream ) ;
  end
  
% if the white gaussian noise is missing, then fill it in, and also clear out the existing
% colored noise and noise wavelet arrays so that the object does not go into an
% inconsistent state

  if isempty( syntheticNoiseStruct.whiteGaussianNoise )
      syntheticNoiseStruct.whiteGaussianNoise = noiseScale * ...
          randn( syntheticNoiseStruct.randStream, nSamplesPower2, 1 ) ;
      syntheticNoiseStruct.coloredNoise = [] ;
  end

% order the fields

  syntheticNoiseStruct = orderfields( syntheticNoiseStruct, ...
      { 'nSamples', 'noiseScalePpm', 'spectrumArray', 'randStream', 'reset', ...
      'whiteGaussianNoise', 'coloredNoise', 'h0' } ) ;
  
% okay, now instantiate the object

  syntheticNoiseObject = class( syntheticNoiseStruct, 'syntheticNoiseClass' ) ;
  
% finally, use the set_spectrum_array function to provide a properly-scaled and
% dimensioned spectrumArray member

  syntheticNoiseObject = set_spectrum_array( syntheticNoiseObject, ...
      syntheticNoiseStruct.spectrumArray ) ;

return

