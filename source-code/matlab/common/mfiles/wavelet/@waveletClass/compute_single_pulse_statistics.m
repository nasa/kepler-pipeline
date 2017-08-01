function [correlationTimeSeries,normalizationTimeSeries] = ...
    compute_single_pulse_statistics( waveletObject, trialTransitPulse, ...
    inTransitCadences, returnComponents )
%
% compute_single_pulse_statistics -- compute correlation and normalization time series for
% a single given trial transit pulse and the flux time series in a waveletObject. 
% (actually computes squared normalization)
%
% [correlationTimeSeries,normalizationTimeSeries] = compute_single_pulse_statistics( 
%     waveletObject, trialTransitPulse ) uses the flux time series in the waveletObject
%     and the user-supplied trialTransitPulse to generate the correlation and
%     normalization time series for that combination of flux and transit pulse.
%
% Inputs:
%        waveletObject:  A waveletObject produced by waveletClass
%        trialTransitPulse: one of the pulses produced by generate_trial_transit_pulse
%        trialPulseLocation: (optional)  When specified, the s components
%            will be shifted to effectively shift the pulse location
%        inTransitCadences: (optional) a list of in-transit cadences that
%            when specified will force the calculation to be done only for
%            in-transit cadences and the output produced will pertain only
%            to those cadences
%        xsWaveletComponents: (optional) these components can be specified
%            in which case they wont need to be computed.  If this
%            calculation is done repeatedly, then it is best to compute
%            them for zero lag in the first call then call this function
%            with them and shift the s using trialPulseLocation
%
% Outputs: 
%         correlationTimeSeries: the correlation for either the whole
%             time series or for in-transit cadences.
%         normalizationTimeSeries:  the normalization for either the whole
%             time series or for in-transit cadences.
%         xsWaveletComponents:  x and s at all the scales for a given input
%             trialTransitPulse.
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
    error('waveletClass:compute_single_pulse_statistics:membersUndefined', ...
        'compute_single_pulse_statistics:  waveletClass object has undefined members' ) ;
end
  
% if the filters are not defined, define them now
if isempty( waveletObject.H )
    waveletObject = set_filter_banks( waveletObject ) ;
end
  
% define the default value for returnComponents
if ~exist('returnComponents','var') || isempty(returnComponents)
    returnComponents = false ;
end  

% do the time-frequency decomposition
x = overcomplete_wavelet_transform( waveletObject ) ;
s = overcomplete_wavelet_transform( waveletObject, trialTransitPulse, true) ;
  
% extract inputs
w = waveletObject.whiteningCoefficients;
quarterIdVector = waveletObject.quarterIdVector;
noiseEstimationByQuarterEnabled = waveletObject.noiseEstimationByQuarterEnabled;
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
  
% determine the output length
if ( exist('inTransitCadences','var') && ~isempty(inTransitCadences) )
    outputLength = length(inTransitCadences) ;
    inTransitIndicator = false(nCadences,1);
    inTransitIndicator(inTransitCadences) = true;
else
    outputLength = nCadences ;
    inTransitIndicator = true(nCadences,1);
    inTransitCadences = cadenceNumbers;
end

% allocate storage of appropriate size
if returnComponents
    correlationTimeSeries = zeros( outputLength, nBands - 1 ) ;
    normalizationTimeSeries = zeros( outputLength, nBands - 1 ) ;
else
    correlationTimeSeries = zeros( outputLength, 1 ) ;
    normalizationTimeSeries = zeros( outputLength, 1 ) ;
end
  
% loop over bands, computing the terms of the two time series according to the ATBD 
% exclude the final band that goes to DC since this introduces a
% sensitivity to any sort of bias in the flux - it shouldnt be necessary
% anyway for noise estimation and shouldnt cause much (if any) loss of SNR
for iQuarter = 1:nQuarters
    quarterIndicator = quarterIdVector == observedQuarters(iQuarter);
    inputIndicator = inTransitIndicator(quarterIndicator);
    outputIndicator = ismember(inTransitCadences,cadenceNumbers(quarterIndicator));
    
    if any(outputIndicator)
        for iBand = 1:nBands - 1
            % prepare ingredients
            factorOfTwo = 2^( -min( iBand, nBands - 1 ) ) ;
            sBand = s(inputIndicator,iBand,iQuarter) ;
            xBand = x(inputIndicator,iBand,iQuarter) ;
            wBand = w(inputIndicator,iBand,iQuarter) ;

            % generate outputs
            if returnComponents
                normalizationTimeSeries(outputIndicator,iBand) = factorOfTwo * ( sBand.^2 ).*wBand ;
                correlationTimeSeries(outputIndicator,iBand) = factorOfTwo * xBand.*sBand.*wBand ;  
            else
                normalizationTimeSeries(outputIndicator) = normalizationTimeSeries(outputIndicator) + ...
                    factorOfTwo * ( sBand.^2 ).*wBand ;
                correlationTimeSeries(outputIndicator) = correlationTimeSeries(outputIndicator) + ...
                    factorOfTwo * xBand.*sBand.*wBand ;  
            end
        end
    end
end
  
return