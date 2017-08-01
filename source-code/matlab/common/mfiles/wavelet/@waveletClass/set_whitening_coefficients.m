function waveletObject = set_whitening_coefficients( waveletObject, ...
    varianceWindowCadences, useOutlierFreeFlux )
%
% set_whitening_coefficients -- compute and store the whitening coefficients which
% correspond to the flux time series in a given waveletObject
%
% waveletObject = set_whitening_coefficients( waveletObject, varianceWindowCadences ) sets
%     the whiteningCoefficients member of the waveletObject.  The object's extended flux
%     time series member is used to generate the whitening coefficients.  Argument
%     varianceWindowCadences is the length of the window used to compute the variance of
%     the highest frequency band.
%
% waveletObject = set_whitening_coefficients( waveletObject, varianceWindowCadences,
%     useOutlierFreeFlux) additionally uses outlierIndicators and
%     outlierFillValues when computing the whitening coefficients
%
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

% the object's time series must be defined
if isempty( waveletObject.extendedFluxTimeSeries )
    error('waveletClass:set_whitening_coefficients:extendedFluxTimeSeriesUndefined', ...
        'set_whitening_coefficients: extendedFluxTimeSeries member undefined') ;
end
    
if (~exist( 'useOutlierFreeFlux', 'var' ) || isempty( useOutlierFreeFlux ) ...
      || ~islogical( useOutlierFreeFlux ) )
    waveletObject.useOutlierFreeFlux = false ;
else
    waveletObject.useOutlierFreeFlux = useOutlierFreeFlux ;
end
  
% if the filters aren't yet generated, generate them
if isempty( waveletObject.H )
    waveletObject = set_filter_banks( waveletObject ) ;
end
waveletObject.varianceWindowCadences = varianceWindowCadences ;
  
% perform the OWT of the object's flux time series
if waveletObject.useOutlierFreeFlux
    extendedFlux = remove_outliers( waveletObject.extendedFluxTimeSeries, waveletObject.outlierIndicators, ...
        waveletObject.outlierFillValues, waveletObject.quarterIdVector, ...
        waveletObject.noiseEstimationByQuarterEnabled );
    waveletCoefficients = overcomplete_wavelet_transform( waveletObject, extendedFlux ) ;
else
    waveletCoefficients = overcomplete_wavelet_transform( waveletObject ) ;
end

nCadences = size(waveletCoefficients,1) ;
nBands = size(waveletCoefficients,2) ;
nQuarters = size(waveletCoefficients,3) ;
whiteningCoefficients = zeros( size( waveletCoefficients ) ) ;
scaleToStdFlag = true ;

% loop over quarters
for iQuarter = 1:nQuarters
    % loop over bands and perform the calculation
    for iBand = 1:nBands
        if isequal(iBand,nBands)
            % need median subtraction only on the band containing DC
            subtractMedianFlag = true ;
        else
            subtractMedianFlag = false ;
        end

        decimationFactor= 2^(iBand-1);
        % compute whitening coefficients for all points
        %whiteningCoefficients(:,iBand,iQuarter) = moving_circular_mad(waveletCoefficients(:,iBand,iQuarter),...
        %    varianceWindowCadences*decimationFactor, decimationFactor, ...
        %    subtractMedianFlag, scaleToStdFlag ).^(-2) ;
        
        % compute whitening coefficients without any decimation since the
        % decimation can introduce a bias
        whiteningCoefficients(:,iBand,iQuarter) = moving_circular_mad(waveletCoefficients(:,iBand,iQuarter),...
            varianceWindowCadences*decimationFactor, 1, ...
            subtractMedianFlag, scaleToStdFlag ).^(-2) ;
    end
end
  
% Look for bands that have excessively large whitening coefficients and
% set them to something reasonable if they do
waveletSupportBuffer = 50.0 ;
outlierSigmaMultiplier = 6.0 ;  % 6.0 may need to become a module parameter and tuned
  
% an impulse has support of 2*2^iBand so multiply by buffer to be safe
waveletSupportInCadences = waveletSupportBuffer * 2*2.^(1:nBands) ; 
suspectBandIndicator = waveletSupportInCadences >= nCadences ;

% loop over quarters
for iQuarter = 1:nQuarters
    meanWhiteningCoefficients = mean(whiteningCoefficients(:,:,iQuarter),1) ;
    overallMeanWhiteningCoefficients = median(meanWhiteningCoefficients(~suspectBandIndicator)) ;
    stdWhiteningCoefficients = 1.4826 * mad(meanWhiteningCoefficients(~suspectBandIndicator),1) ;
    badBands = meanWhiteningCoefficients-overallMeanWhiteningCoefficients > outlierSigmaMultiplier*stdWhiteningCoefficients ; 
    badBands = find( badBands & suspectBandIndicator ) ;
    if ~isempty(badBands)
        for i=1:length(badBands)
            whiteningCoefficients(:,badBands(i),iQuarter) = overallMeanWhiteningCoefficients * ones(nCadences,1);
        end
    end
end
  
waveletObject.whiteningCoefficients = whiteningCoefficients ;
waveletObject.haveCustomWhiteningCoefficients = false ;
      
return

