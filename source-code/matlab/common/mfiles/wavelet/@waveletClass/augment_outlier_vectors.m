function waveletObject = augment_outlier_vectors( waveletObject, ...
    outlierIndicators, outlierFillValues, fittedTrend )
%
% augment_outlier_vectors -- add the vector of outlierIndicators and the vector
% of associated fill values
%
% waveletObject = set_outlier_vectors( waveletObject, outlierIndicators )
% sets the outlierIndicators after checking that the length is less than or
% equal to that of the extended flux.  Also determins fill values for
% cadences marked with outlierIndicators by AR gap filling.
%
% waveletObject = set_outlier_vectors( waveletObject, outlierIndicators,
% outlierFillValues ) sets both outlier vectors in the waveletObject. Note
% that outlierFillValues can be empty to force internal determination.
%
% waveletObject = set_outlier_vectors( waveletObject, outlierIndicators,
% outlierFillValues, gapFillParametersStruct )  if outlierFillValues is
% empty then use the gapFillParametersStruct to do the AR fill to estimate
% the fill values internally
%
% waveletObject = set_outlier_vectors( waveletObject, outlierIndicators,
% outlierFillValues, fittedTrend )  use the specified fittedTrend when
% doing the AR fill to estimate the fill values.  This is otherwise
% computationally expensive.
%
%==========================================================================
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

% if there are no new outliers then just exit
if isempty(outlierIndicators) || ~any(outlierIndicators)
    return;
end

% we can only do this if the extended flux is set
if isempty( waveletObject.extendedFluxTimeSeries )
    error('waveletClass:augment_outlier_vectors:extendedFluxNotSet', ...
        'augment_outlier_vectors:  extendedFlux member not set.') ;
end

% check that outlierIndicators is a logical vector whose length is less 
% than or equal to the length of the quarterIdVector
nSamples = length(waveletObject.quarterIdVector) ;
if ~isequal(length(outlierIndicators),nSamples)
    error('waveletClass:augment_outlier_vectors:vectSizeMismatch', ...
        'augment_outlier_vectors:  outlierIndicators should be the same size as quarterIdVector!') ;
end

% if the fittedTrend is specified then check to make sure it matches the
% length of the outlierIndicators
if ( (exist('fittedTrend', 'var') && ~isempty(fittedTrend)) && ...
        length(fittedTrend) ~= nSamples )
    error('waveletClass:augment_outlier_vectors:fittedTrendLength', ...
        'augment_outlier_vectors:  Length of fittedTrend doesnt match outlierIndicators!') ;
end

% if there are fill values then check their length
if (exist('outlierFillValues','var') && ~isempty(outlierFillValues)) ...
        && (length(outlierFillValues) ~= sum(outlierIndicators))
    error('waveletClass:augment_outlier_vectors:fillValueMismatch', ...
        'augment_outlier_vectors:  Insufficient fill values!') ;
end

if ~exist('fittedTrend', 'var')
    fittedTrend = [];
end

% get the full set of outlierIndicators
outlierIndicatorsFull = waveletObject.outlierIndicators | outlierIndicators ;

% get the fill values
if ~exist('outlierFillValues','var') || isempty( outlierFillValues )
    % extract necessary info
    gapFillParametersStruct = waveletObject.gapFillParametersStruct;
    noiseEstimationByQuarterEnabled = waveletObject.noiseEstimationByQuarterEnabled;
    quarterIdVector = waveletObject.quarterIdVector;
    extendedFlux = waveletObject.extendedFluxTimeSeries ;
    flux = extract_flux(extendedFlux, quarterIdVector, noiseEstimationByQuarterEnabled) ;
    
    % if there are no fill values, then generate them internally. If there are outlier
    % chunks longer than a short gap then leave them unfilled.  Re-fill the old
    % outliers as well since their values may have been perturbed by the
    % presence of the transits
    [outlierFillValuesFull, outlierIndicatorsFull, fittedTrend] = fill_outliers( ...
        flux, outlierIndicatorsFull, gapFillParametersStruct, quarterIdVector, ...
        noiseEstimationByQuarterEnabled, fittedTrend );

else
    % if there are fill values specified, then aggregate them with the
    % other existing fill values
    timeSeriesWithGapsFilled = zeros(nSamples,1);
    timeSeriesWithGapsFilled(waveletObject.outlierIndicators) = waveletObject.outlierFillValues;
    timeSeriesWithGapsFilled(outlierIndicators) = outlierFillValues;
    
    % get all the fill values
    outlierFillValuesFull = timeSeriesWithGapsFilled( outlierIndicatorsFull ) ;
end  
  
% add the new vectors to the object
waveletObject.outlierIndicators = outlierIndicatorsFull ;
waveletObject.outlierFillValues = outlierFillValuesFull ;
waveletObject.fittedTrend = fittedTrend ;

% if we had whitening coefficients computed using some other set of outlier
% vectors then clear them out since they are no longer valid
if waveletObject.useOutlierFreeFlux
    waveletObject.whiteningCoefficients = [] ;
    waveletObject.useOutlierFreeFlux = [] ;
end

return