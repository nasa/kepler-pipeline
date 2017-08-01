function [correlationTimeSeries, normalizationTimeSeries, x, s] = ...
    compute_single_pulse_statistics_time_domain( waveletObject, ...
    trialTransitPulseTrain, inTransitCadences )
%
% compute_single_pulse_statistics -- compute correlation and normalization time series for
% a single given trial transit pulse and the flux time series in a waveletObject. 
% (actually computes squared normalization)
%
%
% Inputs:
%        waveletObject:  A waveletObject produced by waveletClass
%        trialTransitPulseTrain: The full pulse train
%        inTransitCadences:  (optional) list of in-transit cadences needed to gap/fill
%            cadences that are not in this transit
%
% Outputs: 
%         correlationTimeSeries: the correlation for either the whole
%             time series or for in-transit cadences.
%         normalizationTimeSeries:  the normalization for either the whole
%             time series or for in-transit cadences.
%         
%=========================================================================================
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

% the wavelet object must have its whitening coefficients and flux time series defined
if isempty( waveletObject.whiteningCoefficients ) || ...
        isempty( waveletObject.extendedFluxTimeSeries )
    error('waveletClass:compute_single_pulse_statistics_time_domain:membersUndefined', ...
        'compute_single_pulse_statistics_time_domain:  waveletClass object has undefined members' ) ;
end
  
% if the filters are not defined, define them now
if isempty( waveletObject.H )
    waveletObject = set_filter_banks( waveletObject ) ;
end
      
%  make sure we have a trialTransitPulseTrain
if ( ~exist('trialTransitPulseTrain','var') || isempty(trialTransitPulseTrain) )
    error('waveletClass:compute_single_pulse_statistics_time_domain:membersUndefined', ...
        'compute_single_pulse_statistics_time_domain: trialTransitPulseTrain missing' ) ;
end
  
% gap/fill in-transit cadences in the extended flux that are not part of 
% this transit to prevent correlation between transits
if ( exist('inTransitCadences','var') && ~isempty(inTransitCadences))
    
    % get inputs
    fittedTrend = waveletObject.fittedTrend ;
    noiseEstimationByQuarterEnabled = waveletObject.noiseEstimationByQuarterEnabled;
    quarterIdVector = waveletObject.quarterIdVector;
    nCadences = length( quarterIdVector );
    
    % set up indicators for out-of-pulse cadences
    outOfPulseIndicator = false(nCadences,1) ;
    outOfPulseIndicator(trialTransitPulseTrain ~= 0) = true ; 
    outOfPulseIndicator(inTransitCadences) = false ; % in-transit cadences that are not in this pulse

    % check for fill values in the waveletObject and use them if they
    % exist
    outlierFillValues = waveletObject.outlierFillValues ;
    outlierIndicators = waveletObject.outlierIndicators ;
    fillValuesTimeSeries = zeros( nCadences, 1 ) ;
    fillValuesTimeSeries(outlierIndicators) = outlierFillValues ;

    gapIndicator = outOfPulseIndicator & ~outlierIndicators ; % this is what needs filled
    filledIndicator = outOfPulseIndicator & outlierIndicators ; % have fill values already for these

    % get gap fill inputs
    timeSeriesWithGaps = waveletObject.extendedFluxTimeSeries ;
    timeSeriesWithGaps = extract_flux(timeSeriesWithGaps, quarterIdVector, noiseEstimationByQuarterEnabled) ;
    gapFillParametersStruct = waveletObject.gapFillParametersStruct ;

    % put in the fill values we already have
    timeSeriesWithGaps(filledIndicator) = fillValuesTimeSeries(filledIndicator) ;

    % fill out-of-pulse cadences we didnt have fill values for and update the object
    timeSeriesWithGapsFilled = fill_short_gaps(timeSeriesWithGaps, gapIndicator, [], 0, ...
        gapFillParametersStruct, [], fittedTrend ) ;

    % turn the pulse train into a single pulse to get rid of extra correlation
    trialTransitPulseTrain(outOfPulseIndicator) = 0 ;

    % apply whitening
    x = apply_whitening_to_time_series( waveletObject, timeSeriesWithGapsFilled ) ;
    s = apply_whitening_to_time_series( waveletObject, trialTransitPulseTrain, true ) ;
    s = s(inTransitCadences);  % window the pulse to prevent correlation as well
    x = x(inTransitCadences);
else
    x = apply_whitening_to_time_series( waveletObject) ;
    s = apply_whitening_to_time_series( waveletObject, trialTransitPulseTrain, true ) ;
end

correlationTimeSeries = x.*s;
normalizationTimeSeries = s.*s;
  
return