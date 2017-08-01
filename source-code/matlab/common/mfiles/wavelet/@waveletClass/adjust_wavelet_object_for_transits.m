function [waveletObject, newFittedTrend, inTransitIndicator] = adjust_wavelet_object_for_transits( waveletObject, ...
    inTransitIndicator, removeTrendFromFlux, removeTransitsFromFlux ) 
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function waveletObject = adjust_wavelet_object_for_transits( waveletObject, ...
%    trialTransitPulseTrain, nPadCadences, removeTrend ) 
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Decription: This function adjusts the members of the waveletObject to
%             remove the effect of in-transit cadences
% 
%
% Inputs:  
%        waveletObject - an object of the waveletClass
%        trialTransitPulseTrain - a pulse train built using the
%                superResolutionClass
%        nPadCadences - number of cadences to pad on each side of each
%                transit
%        removeTrend - boolean to determine of a trend should be removed
%                from the extended flux
%
% Outputs:
%        waveletObject - an updated object of the waveletClass
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
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

% extract needed info from the waveletObject
extendedFlux = waveletObject.extendedFluxTimeSeries;
gapFillParametersStruct = waveletObject.gapFillParametersStruct;
varianceWindowCadences = waveletObject.varianceWindowCadences;
noiseEstimationByQuarterEnabled = waveletObject.noiseEstimationByQuarterEnabled;
quarterIdVector = waveletObject.quarterIdVector;

if removeTrendFromFlux
    % here we are removing the trend from the extended flux so we should
    % gap/fill outliers and in-transit cadences and get a new trend
    
    % get fill values for in-transit cadences and a new fitted trend
    waveletObject = augment_outlier_vectors( waveletObject, inTransitIndicator, [], [] ) ;

    % extract the trend and outlier info from the object
    newFittedTrend = get( waveletObject, 'fittedTrend' ) ;
    outlierFillValues = get( waveletObject, 'outlierFillValues' );
    outlierIndicators = get( waveletObject, 'outlierIndicators' );
    
    % remove the trend from the flux and the fill values
    extendedFlux = extract_flux( extendedFlux, quarterIdVector, noiseEstimationByQuarterEnabled );
    extendedFlux = extendedFlux - newFittedTrend;
    outlierFillValues = outlierFillValues - newFittedTrend(outlierIndicators);
    
    if removeTransitsFromFlux
        fullOutlierFillVector = zeros( length(outlierIndicators), 1 );
        fullOutlierFillVector( outlierIndicators ) = outlierFillValues;
        extendedFlux( inTransitIndicator ) = fullOutlierFillVector( inTransitIndicator );
        outlierIndicators = outlierIndicators & ~inTransitIndicator;
        outlierFillValues = fullOutlierFillVector( ~inTransitIndicator );
    end
    
    % remove the median
    [extendedFlux, outlierFillValues] = remove_median( extendedFlux, outlierIndicators, ...
        outlierFillValues, quarterIdVector, noiseEstimationByQuarterEnabled );
    
    % set the trend to zero and new fill values in the object
    fittedTrend = zeros(size(newFittedTrend));
    waveletObject = set_outlier_vectors( waveletObject, outlierIndicators, ...
        outlierFillValues, gapFillParametersStruct, fittedTrend ) ;

    % set the new flux in the object
    waveletObject = set_extended_flux( waveletObject, extendedFlux, ...
        noiseEstimationByQuarterEnabled, quarterIdVector ) ;
         
else
    % get the fittedTrend 
    fittedTrend = get( waveletObject, 'fittedTrend' ) ;
    newFittedTrend = fittedTrend ; % trend is not getting updated
    
    % get fill values for the in-transit cadeneces
    waveletObject = augment_outlier_vectors( waveletObject, inTransitIndicator, [], fittedTrend ) ;
    
    if removeTransitsFromFlux
        outlierFillValues = get( waveletObject, 'outlierFillValues' );
        outlierIndicators = get( waveletObject, 'outlierIndicators' );
        
        fullOutlierFillVector = zeros( length(outlierIndicators), 1 );
        fullOutlierFillVector( outlierIndicators ) = outlierFillValues;
        extendedFlux = extract_flux( extendedFlux, quarterIdVector, noiseEstimationByQuarterEnabled );
        extendedFlux( inTransitIndicator ) = fullOutlierFillVector( inTransitIndicator );
        
        % remove the median
        extendedFlux = remove_median( extendedFlux, outlierIndicators, ...
            outlierFillValues, quarterIdVector, noiseEstimationByQuarterEnabled );
        
        % set the new flux in the object
        waveletObject = set_extended_flux( waveletObject, extendedFlux, ...
            noiseEstimationByQuarterEnabled, quarterIdVector ) ;
        
    end
end

% compute new whitening coefficients
waveletObject = set_whitening_coefficients( waveletObject, ...
    varianceWindowCadences, true ) ;

return