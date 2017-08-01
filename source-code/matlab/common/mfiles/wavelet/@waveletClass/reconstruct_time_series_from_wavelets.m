function reconstructedTimeSeries = reconstruct_time_series_from_wavelets( waveletObject, ...
    waveletCoefficients )
%
% reconstruct_time_series_from_wavelets -- apply the inverse-OWT operation to recover a
% time series from a set of wavelet coefficients
%
% reconstructedTimeSeries = reconstruct_time_series_from_wavelets( waveletObject, 
%     waveletCoefficients ) applies the inverse-OWT operation defined in the waveletObject
%     to the user-supplied waveletCoefficients, returning the resulting time series.
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

% if the object does not have its filters, build them

  if isempty( waveletObject.G )
      waveletObject = set_filter_banks( waveletObject ) ;
  end
  
% check dimensions

  if ~isequal( size(waveletObject.G), size(waveletCoefficients(:,:,1)) )
      error('waveletClass:reconstruct_time_series_from_wavelets:waveletSizeInvalid', ...
          'reconstruct_time_series_from_wavelets: size of waveletCoefficients invalid') ;
  end
  
% get the number of quarter
  if waveletObject.noiseEstimationByQuarterEnabled
      [~,~,nQuarters] = get_quarter_lengths( waveletObject.quarterIdVector );
  else
      nQuarters = 1;
  end
  
  reconstructedTimeSeries = zeros( size(waveletCoefficients,1), nQuarters ) ;
  nBands                  = size( waveletCoefficients, 2 ) ;
  filterLength            = length( waveletObject.h0 ) ;
  
% unfortunately, there's no better way to do this than with a loop, due to the circshifts
% needed on each vector
for iQuarter = 1:nQuarters
    for iBand = 1:nBands
        iFactor = min(iBand,nBands-1) ;
        iShift = filterLength*2^(iFactor-1) - 2^(iFactor-1) ;
        x = circshift( waveletCoefficients(:,iBand,iQuarter), -iShift) ;
        X = fft( x ) ;
        y = real( ifft( X.* waveletObject.G(:,iBand) ) ) ;
        reconstructedTimeSeries(:,iQuarter) = reconstructedTimeSeries(:,iQuarter) + ...
            circshift( y, filterLength-1) *2^-iFactor ;
    end
end
  
return

