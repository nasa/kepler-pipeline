function [correlationTimeSeries,normalizationTimeSeries] = ...
    compute_statistics_time_series( waveletObject, trialTransitPulse, ...
    shiftLength, returnComponents, sesIndices )
%
% compute_statistics_time_series -- compute correlation and normalization time series for
% a given trial transit pulse and the flux time series in a waveletObject.
%
% [correlationTimeSeries,normalizationTimeSeries] = compute_statistics_time_series( 
%     waveletObject, trialTransitPulse ) uses the flux time series in the waveletObject
%     and the user-supplied trialTransitPulse to generate the correlation and
%     normalization time series for that combination of flux and transit pulse.
%
% [...] = compute_statistics_time_series( ... , returnComponents ) returns the components
%     of the correlation, normalization, and xComponents time series for each band (ie,
%     arrays rather than vectors are returned).  Default value of returnComponents is
%     false.
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

% the wavelet object must have its whitening coefficients and flux time series defined
if isempty( waveletObject.whiteningCoefficients ) || ...
      isempty( waveletObject.extendedFluxTimeSeries )
    error('waveletClass:compute_statistics_time_series:membersUndefined', ...
        'compute_statistics_time_series:  waveletClass object has undefined members' ) ;
end
  
% if the filters are not defined, define them now
if isempty( waveletObject.H )
    waveletObject = set_filter_banks( waveletObject ) ;
end
  
% define the default value for returnComponents
if ~exist('returnComponents','var') || isempty(returnComponents)
    returnComponents = false ;
end

% extract inputs
w = waveletObject.whiteningCoefficients;
quarterIdVector = waveletObject.quarterIdVector;
noiseEstimationByQuarterEnabled = waveletObject.noiseEstimationByQuarterEnabled;

% compute the OWT of the flux time series and the trial transit pulse if
% they were not specified
x = overcomplete_wavelet_transform( waveletObject ) ;

% zero pad the pulse so its the same length as x
trialTransitPulse(length(trialTransitPulse)+1:length(x)) = 0;
s = overcomplete_wavelet_transform( waveletObject, trialTransitPulse, true ) ;

% calculate needed quantities
nBands = size( s, 2 ) ;
nCadences = length(quarterIdVector);
cadenceNumbers = (1:nCadences)';

% need an outer loop over quarters if noiseEstimationByQuarterEnabled
if noiseEstimationByQuarterEnabled
    [~, observedQuarters, nQuarters] = get_quarter_lengths( quarterIdVector );
else
    nQuarters = 1;
    quarterIdVector = ones(size(quarterIdVector));
    observedQuarters = 1;
end
  
% define default value for sesIndices
if ~exist('sesIndices','var') || isempty(sesIndices)
    sesIndices = cadenceNumbers ;
    sesIndicator = true(nCadences,1);
else
    sesIndicator = false(nCadences,1);
    sesIndicator(sesIndices) = true;
end
nSesIndices = length(sesIndices) ;
  
% allocate storage of appropriate size
if returnComponents
    correlationTimeSeries = zeros( nSesIndices, nBands - 1 ) ;
    normalizationTimeSeries = zeros( nSesIndices, nBands - 1 ) ;
else
    correlationTimeSeries = zeros( nSesIndices, 1 ) ;
    normalizationTimeSeries = zeros( nSesIndices, 1 ) ;
end
  
% loop over bands, computing the terms of the two time series according to the ATBD 
% exclude the final band that goes to DC since this introduces a
% sensitivity to any sort of bias in the flux - it shouldnt be necessary
% anyway for noise estimation and shouldnt cause much (if any) loss of SNR
for iQuarter = 1:nQuarters
    quarterIndicator = quarterIdVector == observedQuarters(iQuarter);
    inputIndicator = sesIndicator(quarterIndicator);
    outputIndicator = ismember(sesIndices,cadenceNumbers(quarterIndicator));
    
    if any(outputIndicator)
        for iBand = 1:nBands-1
            factorOfTwo = 2^( -min( iBand, nBands - 1 ) ) ;
            SNRi = circfilt( flipud( s(:,iBand).^2 ), w(:,iBand,iQuarter) ) ;
            Li = circfilt( flipud( s(:,iBand) ), x(:,iBand,iQuarter) .* w(:,iBand,iQuarter) ) ;

            % apply necessary circular shifts      
            SNRi = circshift( SNRi, shiftLength ) ;
            Li = circshift(Li, shiftLength) ;

            if returnComponents    
                normalizationTimeSeries(outputIndicator,iBand) = SNRi(inputIndicator) * factorOfTwo ;
                correlationTimeSeries(outputIndicator,iBand) = Li(inputIndicator) * factorOfTwo ;
            else
                normalizationTimeSeries(outputIndicator) = normalizationTimeSeries(outputIndicator) + ...
                    SNRi(inputIndicator) * factorOfTwo ;
                correlationTimeSeries(outputIndicator) = correlationTimeSeries(outputIndicator) + Li(inputIndicator) * factorOfTwo ;
                if isequal(iBand,nBands - 1)
                    normalizationTimeSeries(outputIndicator) = sqrt(normalizationTimeSeries(outputIndicator)) ;
                end
            end
        end
    end
end
  
return

