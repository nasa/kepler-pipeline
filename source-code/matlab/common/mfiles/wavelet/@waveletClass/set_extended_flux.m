function waveletObject = set_extended_flux( waveletObject, flux, ...
    noiseEstimationByQuarterEnabled, quarterIdVector )
%
% set_extended_flux -- add the vector of extended flux values to a waveletClass object
%
% waveletObject = set_extended_flux( waveletObject, flux, noiseEstimationByQuarterEnabled,
%     quarterIdVector) extends the flux and sets it into the wavelotObject
%     member of a waveletClass object.  If the length of the flux is not a power of 2, it
%     will be extended to a power of 2.  If noiseEstimationByQuarterEnabled
%     is true then the flux will be split up according to the quarterIdVect
%     or and each chunk will be extended to the same power of two length.
%
% waveletObject = set_extended_flux( waveletObject, extendedFlux, H, G)
%     sets the extendedFlux but also sets the custom filter banks H and G
%     (optional)
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

% make sure extendedFlux looks all right
if ~isreal( flux ) || ~isvector( flux ) || isempty(flux) || ...
      any( isnan(flux) ) || any( isinf(flux) )
    error('waveletClass:set_extended_flux:extendedFluxNotRealVector', ...
        'set_extended_flux:  extendedFlux must be a real vector of nonzero length' ) ;
end
  
% outlier indicators must be specified, they can all be false
if isempty(waveletObject.outlierIndicators) 
    error('waveletClass:set_extended_flux:outlierVectorsMissing', ...
        'set_extended_flux: outlier vectors must be specified through set_outlier_vectors prior to extending flux' ) ;
end
  
% flux must have the same length as outlierIndicators  
if ~isequal(length(flux), length(waveletObject.outlierIndicators))
    error('waveletClass:set_extended_flux:outlierIndicatorLength', ...
        'set_extended_flux:  the outlierIndicator length must be equivalent to the flux length' ) ;
end
       
% check the other inputs
if ~exist('noiseEstimationByQuarterEnabled','var') || isempty(noiseEstimationByQuarterEnabled)
    noiseEstimationByQuarterEnabled = false ;
    quarterIdVector = -1 * ones( size(flux) );
end
if noiseEstimationByQuarterEnabled 
    if ~exist('quarterIdVector','var') || isempty(quarterIdVector)  
        error('waveletClass:set_extended_flux:quarterIdVectorMissing', ...
            'set_extended_flux:  quarterIdVector must be specified if noiseEstimationByQuarterEnabled is true' ) ;
    end
    if ~isequal(length(flux), length(quarterIdVector))
        error('waveletClass:set_extended_flux:quarterIdVectorLength', ...
            'set_extended_flux:  quarterIdVector must have same length as the input flux' ) ;
    end
end
  
% extract needed info
outlierIndicators = waveletObject.outlierIndicators ;
outlierFillValues = waveletObject.outlierFillValues ;

% if noiseEstimationByQuarterEnabled is true, then make sure we dont have
% any outliers in inter-quarter gaps
if noiseEstimationByQuarterEnabled
    outlierIds = quarterIdVector( outlierIndicators );
    if any( outlierIds == -1 )
        outlierFillValues = outlierFillValues( outlierIds ~= -1 );
        outlierIndicators(quarterIdVector == -1) = false;

        % update the object
        waveletObject.outlierIndicators = outlierIndicators;
        waveletObject.outlierFillValues = outlierFillValues;
    end
end
    
% extend the flux and set it in the object along with the filter banks  
extendedFlux = extend_flux( flux, outlierIndicators, outlierFillValues, ...
    noiseEstimationByQuarterEnabled, quarterIdVector ) ;
  
% copy results to the object
waveletObject.extendedFluxTimeSeries = extendedFlux ;
waveletObject.noiseEstimationByQuarterEnabled = noiseEstimationByQuarterEnabled ;
waveletObject.quarterIdVector = quarterIdVector ;
  
% set the filter banks consistent with extendedFlux length
if ( isempty(waveletObject.G) || isempty(waveletObject.H) ) || ...
    ( ~isequal(length(waveletObject.H),length(extendedFlux)) || ...
    ~isequal(length(waveletObject.G),length(extendedFlux)) )
    waveletObject = set_filter_banks( waveletObject ) ;
end      

% wipe out any whitening coefficients
waveletObject.whiteningCoefficients  = [] ;
waveletObject.varianceWindowCadences = [] ;
  
end

