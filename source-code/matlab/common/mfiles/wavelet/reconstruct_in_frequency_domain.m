function multiTimeSeries = reconstruct_in_frequency_domain( waveletCoefficients, ...
    h0 )
%
% reconstruct_in_frequency_domain -- perform multi-resolution reconstruction using
% frequency domain techniques
%
% multiTimeSeries = reconstruct_in_frequency_domain( waveletCoefficients, h0 ) takes a set
%     of wavelet coefficients and the impulse response of the low-pass filter which
%     generated them, and performs the synthesis-bank operation which is the inverse of
%     the wavelet transform.  The resulting timeseries (plural) can be summed to obtain
%     the original timeseries.  This function uses a frequency-domain representation of
%     the synthesis filters, as opposed to reconstruct_multiresolution_timeseries which
%     uses a time-domain representation.
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

% start by constructing the h1, g0, and g1 filters (HPF filter for wavelet transform, and
% LPF and HPF filters for the synthesis operation, respectively)

  nSamples = size( waveletCoefficients, 1 ) ;
  nBands   = size( waveletCoefficients, 2 ) ;
  
  multiTimeSeries = zeros( nSamples, nBands ) ;
  filterLength = length(h0) ;
  
  h1 = flipud(h0).*(-1).^(0:filterLength-1)';
  g0 = flipud(h0);
  g1 = flipud(h1);
  
% construct the frequency-domain versions of the g0 and g1 filters in all frequency bands
% by decimating / duplicating each filter by successive powers of 2

  G0 = zeros(nSamples,nBands-1) ;
  G1 = zeros(nSamples,nBands-1) ;
  
  G0(:,1) = fft(g0, nSamples) ;
  G1(:,1) = fft(g1, nSamples) ;
  
  for iBand = 2:nBands-1
      
      oldG0 = G0(:,iBand-1) ;
      oldG1 = G1(:,iBand-1) ;
      G0(:,iBand) = [oldG0(1:2:end) ; oldG0(1:2:end)] ;
      G1(:,iBand) = [oldG1(1:2:end) ; oldG1(1:2:end)] ;
      
  end
  
% loop over the time series performing the correct set of transformations, including a
% rescaling factor and a final circshift which was empirically determined (!).  Note that
% base-band requires slightly specialized handling since it never got high-pass filtered
% in the OWT

  for iBand = nBands:-1:1
      iFactor = min(iBand,nBands-1) ;
      iShift = filterLength*2^(iFactor-1) - 2^(iFactor-1) ;
      x = circshift( waveletCoefficients(:,iBand), -iShift) ;
      X = fft( x ) ;
     
%     apply the one HPF for all bands except base-band 
      
      if (iBand < nBands )
          X = X .* G1(:,iBand) ;
      end
      
%     apply the appropriate LPFs in succession
      
      for jBand = iBand-1:-1:1
          X = X .* G0(:,jBand) ;
      end
      
%     convert back to time domain, apply empirical circshift and rescale
      
      multiTimeSeries(:,iBand) = circshift( real(ifft(X)), filterLength-1 ) * 2^-iFactor ;
  end
  
return