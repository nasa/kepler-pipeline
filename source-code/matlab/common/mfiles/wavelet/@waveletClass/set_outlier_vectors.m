function waveletObject = set_outlier_vectors( waveletObject, outlierIndicators, ...
    outlierFillValues, gapFillParametersStruct, fittedTrend )
%
% set_outlier_vectors -- add the vector of outlierIndicators and the vector
% of associated fill values
%
% waveletObject = set_outlier_vectors( waveletObject, outlierIndicators,
% outlierFillValues, gapFillParametersStruct ) outlierFillValues must
% contain a fill value for each outlierIndicator.  The gapFillParams
% correspond to those used during the generation of fill values
%
% waveletObject = set_outlier_vectors( waveletObject, outlierIndicators,
% outlierFillValues, fittedTrend )  Optionally specify the fittedTrend that
% was used or determined during the generation of the fill values for
% potential future use
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

% we need to populate the gapFillParams that were used for the fill values
if (~exist( 'gapFillParametersStruct', 'var' ) || isempty( gapFillParametersStruct ))
    error('waveletClass:set_outlier_vectors:noGapFillParams', ...
        'set_outlier_vectors:  Need gapFillParametersStruct used to generate fill values!') ;
end

% put the fittedTrend in the object
if ( exist('fittedTrend', 'var') && ~isempty(fittedTrend) )
    waveletObject.fittedTrend = fittedTrend ;
end

% if there are no outliers then just exit
if ~any(outlierIndicators)
    % always populate the gapFillParams
    waveletObject.gapFillParametersStruct = gapFillParametersStruct ;
    waveletObject.outlierIndicators = outlierIndicators ;
    waveletObject.outlierFillValues = [] ;
    return;
end

% check that there are enough fill values
if length(outlierFillValues) ~= sum(outlierIndicators)
    error('waveletClass:set_outlier_vectors:fillValueMismatch', ...
        'set_outlier_vectors:  Insufficient fill values!') ;
end

% if the fittedTrend is specified then check to make sure it matches the
% length of the outlierIndicators
if ( (exist('fittedTrend', 'var') && ~isempty(fittedTrend)) && ...
        length(fittedTrend) ~= length(outlierIndicators) )
    error('waveletClass:set_outlier_vectors:fittedTrendLength', ...
        'set_outlier_vectors:  Length of fittedTrend doesnt match outlierIndicators!') ;
end    
  
% add the vectors to the object
waveletObject.outlierIndicators = outlierIndicators ;
waveletObject.outlierFillValues = outlierFillValues ;
waveletObject.gapFillParametersStruct = gapFillParametersStruct ;

% if we had whitening coefficients computed using some other set of outlier
% vectors then clear them out since they are no longer valid
if waveletObject.useOutlierFreeFlux
    waveletObject.whiteningCoefficients = [] ;
    waveletObject.useOutlierFreeFlux = [] ;
end

return