function waveletObject = set_filter_banks( waveletObject, nBands )
%
% set_filter_banks:  compute decomposition and synthesis filter banks
%
% waveletObject = set_filter_banks( waveletObject ) computes the decomposition and
%     synthesis filter banks, H and G, in the frequency domain, and sets them as members
%     of the waveletClass object.
%
% waveletObject = set_filter_banks( waveletObject, mScale ) allows the user to select a
%     number of frequency bands, rather than using the number of bands determined by the
%     length of the extended flux time series and the length of the time-domain filter,
%     h0.
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

% we can only do this if the extended flux is set

  if isempty( waveletObject.extendedFluxTimeSeries )
      error('waveletClass:set_filter_banks:extendedFluxNotSet', ...
          'set_filter_banks:  extendedFlux member not set.') ;
  end
  
  nSamples     = length(waveletObject.extendedFluxTimeSeries) ;
  filterLength = length(waveletObject.h0) ;
  
% determine the optimum number of bands, if not user-specified

  if ~exist( 'nBands', 'var') || isempty( nBands ) || nBands == 0 
      nBands = get( waveletObject, 'nBands' ) ;
  end
  
% construct the 4 basis vectors

  h0 = waveletObject.h0 ;
  h1 = flipud(h0).*(-1).^(0:filterLength-1)';
  g0 = flipud(h0);
  g1 = flipud(h1);
  
% construct the FFT of each of the vectors, with appropriate padding -- note that here we
% explicitly show which are low-pass and which are high-pass

  HL = fft( h0, nSamples ) ;
  HH = fft( h1, nSamples ) ;
  GL = fft( g0, nSamples ) ;
  GH = fft( g1, nSamples ) ;
  
% define the filters

  waveletObject.G = zeros(nSamples,nBands) ;
  waveletObject.H = zeros(nSamples,nBands) ;
  
% define 2 vectors which will hold the product of the low-pass filters

  GLProduct = ones(nSamples,1) ;
  HLProduct = ones(nSamples,1) ;
  
% loop over bands

  for iBand = 1:nBands
      
%     on the last band, the GH and HH vectors have to be set to one, since the lowest band
%     sees only low-pass filters all the way down

      if iBand == nBands
          HH = ones(nSamples,1) ;
          GH = ones(nSamples,1) ;
      end
      
      waveletObject.G(:,iBand) = GH .* GLProduct ;
      waveletObject.H(:,iBand) = HH .* HLProduct ;
      
%     increment the products of the low-pass filters

      GLProduct = GLProduct .* GL ;
      HLProduct = HLProduct .* HL ;
      
%     convert the elemental filters to the next band down in frequency 

      GL = [GL(1:2:end) ; GL(1:2:end)] ;
      HL = [HL(1:2:end) ; HL(1:2:end)] ;
      GH = [GH(1:2:end) ; GH(1:2:end)] ;
      HH = [HH(1:2:end) ; HH(1:2:end)] ;
      
  end

return