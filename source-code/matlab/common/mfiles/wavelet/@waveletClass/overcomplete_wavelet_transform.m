function waveletCoefficients = overcomplete_wavelet_transform( waveletObject, timeSeries, doZeroPadding )
%
% overcomplete_wavelet_transform -- perform OWT on a selected time series
%
% waveletCoefficients = overcomplete_wavelet_transform( waveletObject, timeSeries ) uses
%     the H filter block in the waveletObject to perform the OWT of the timeSeries.  The
%     length of the time series must be the length of the waveletObject's extended flux
%     time series.
%
% waveletCoefficients = overcomplete_wavelet_transform( waveletObject ) performs the OWT
%     on the extended flux time series which is a member of the waveletObject.
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

% handle missing argument
if ~exist( 'timeSeries', 'var' ) || isempty( timeSeries )
    timeSeries = waveletObject.extendedFluxTimeSeries ;
    doZeroPadding = false;
end

% handle missing argument
if ~exist( 'doZeroPadding', 'var' ) || isempty( doZeroPadding )
    doZeroPadding = false;
end

% if the filters aren't built, build them now
if isempty( waveletObject.H )
  waveletObject = set_filter_banks( waveletObject ) ;
end

% extract inputs
quarterIdVector = waveletObject.quarterIdVector;
noiseEstimationByQuarterEnabled = waveletObject.noiseEstimationByQuarterEnabled;
nBands = size(waveletObject.H,2) ;
filterLength = length(waveletObject.h0) ;

% extend the flux if needed
timeSeries = extend_flux( timeSeries, false(size(quarterIdVector)), [], ...
    noiseEstimationByQuarterEnabled, quarterIdVector, doZeroPadding ) ;
    
% need an outer loop over quarters if noiseEstimationByQuarterEnabled
%if noiseEstimationByQuarterEnabled && ~doZeroPadding
%    [~,~,nQuarters] = get_quarter_lengths( quarterIdVector );
%else
%    nQuarters = 1;
%end
nQuarters = size(timeSeries,2);

waveletCoefficients = -1 * ones(length(timeSeries),nBands,nQuarters);
for iQuarter = 1:nQuarters
    % construct the FFT of the initial vector and repmat it to the # of bands
    X = repmat( fft(timeSeries(:,iQuarter)), 1, nBands ) ;
  
    % the wavelet expansion is ALMOST just the IFFT of X multiplied by H ...
    waveletCoefficients(:,:,iQuarter) = real( ifft( X .* waveletObject.H ) ) ;
  
    % except for some circshifts
    for iBand = 1:nBands
        shiftIndex = min( iBand, nBands-1 ) ;
        nShift = filterLength*2.^(shiftIndex-1)- 2.^(shiftIndex-1); 
        waveletCoefficients(:,iBand,iQuarter) = circshift( waveletCoefficients(:,iBand,iQuarter), -nShift ) ;
    end
    
end

return

