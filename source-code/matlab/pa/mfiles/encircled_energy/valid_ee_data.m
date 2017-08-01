function result = valid_ee_data(inputStruct, iCadence)
%
% Check the validity of the input data set for encircled energy calculation.
% INPUT:    inputStruct = data structure with the following fields:
%               .pixFlux         = nx1 array, pixel data from all targets
%               .Cpixflux        = nx1 array, uncertainties of PixFlux or nxn covariance matix
%               .radius          = nx1 array, distance in pixels from corresponding target centroid for each pixel
%               .row             = nx1 array, pixel row coordinate
%               .col             = nx1 array, pixel column coordinate
%               .startTarget     = nTargetx1 array, starting index in nx1 arrays for target
%               .stopTarget      = nTargetx1 array, ending index in nx1 arrays for target
%               .expectedFlux    = nTargetsx1 array containing the expected flux for each target
%           iCadence    = relative cadence number for the unito of work (1-based)
% OUTPUT:   result      = logical indicating if the input data is valid
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

% unpack data
pixFlux     = inputStruct.pixFlux;
Cpixflux    = inputStruct.Cpixflux;
radius      = inputStruct.radius;
row         = inputStruct.row;
col         = inputStruct.col;

% VALID DATA CRITERIA
% not null      : pixFlux, radius, row, col, Cpixflux must not be empty
% allVectors    : pixFlux, radius, row, col must be vectors. Cpixflux is
%                 either a vector or a square matrix.
% sameLength    : pixFlux, radius, row, col must be of the same length.
%                 Cpixflux must be either of same length of of same size
%                 square.
% no NaNs       : pixFlux, radius, row, col, Cpixflux
% no Infs       : pixFlux, radius, row, col, Cpixflux
% real values   : pixFlux, radius, row, col, Cpixflux
% non-negative  : pixFlux, radius, row, col
%                 if Cpixflux is a vector, Cpixflux >=0
% covariance    : if Cpixflux is a matrix, must be a covariance matrix -->
%                 square, real and Hermitian (A==A')

result = false;

notNull     = ~isempty(pixFlux) &&...
              ~isempty(Cpixflux) &&...
              ~isempty(radius) &&...
              ~isempty(row) &&...
              ~isempty(col);
if( ~notNull )
    warning(['PA:',mfilename,':NullDataInput'],...
        ['Encircled energy input data is empty. Gapping metric for relative cadence ',num2str(iCadence),'.']);
    return;
end

allVectors  = isvector(pixFlux) &&...
              (isvector(Cpixflux) || all_columns_equal(size(Cpixflux) ) )&&...
              isvector(radius) &&...
              isvector(row) &&...
              isvector(col);  
if( ~allVectors )
    warning(['PA:',mfilename,':NonVectorDataInput'],...
        ['Input data must be vectors. Gapping eeMetric for relative cadence ',num2str(iCadence),'.']);
    return;
end          
          
dataLength  = length(pixFlux);          
sameLength  = ((isvector(Cpixflux) && length(Cpixflux) == dataLength) ||...
                all(size(Cpixflux) == dataLength) ) &&...
              length(radius) == dataLength &&...
              length(row) == dataLength &&...
              length(col) == dataLength;
if( ~sameLength )
    warning(['PA:',mfilename,':UnequalLengthDataInput'],...
        ['Input data must be of same length. Gapping eeMetric for relative cadence ',num2str(iCadence),'.']);
    return;
end              
          
noNaNs      = ~any(isnan(pixFlux)) && ...
              ~any(isnan(radius))  && ...
              ~any(isnan(row))     && ...
              ~any(isnan(col))     && ...
              ~any(any(isnan(Cpixflux)));
if( ~noNaNs )
    warning(['PA:',mfilename,':NaNsInDataInput'],...
        ['Input data must not contain NaNs. Gapping eeMetric for relative cadence ',num2str(iCadence),'.']);
    return;
end             

allFinite   = ~any(isinf(pixFlux)) && ...
              ~any(isinf(radius))  && ...
              ~any(isinf(row))     && ...
              ~any(isinf(col))     && ...
              ~any(any(isinf(Cpixflux)));
if( ~allFinite )
    warning(['PA:',mfilename,':InfDataInput'],...
        ['Input data must be finite. Gapping eeMetric for relative cadence ',num2str(iCadence),'.']);
    return;
end              

allReal     = isreal(pixFlux)   && ...
              isreal(radius)    && ...
              isreal(row)       && ...
              isreal(col)       && ...
              isreal(Cpixflux);
if( ~allReal )
    warning(['PA:',mfilename,':ImaginaryDataInput'],...
        ['Input data must be real. Gapping eeMetric for relative cadence ',num2str(iCadence)],'.');
    return;
end             


allNonNeg   = all(radius  >= 0) && ...
              all(row     >= 0) && ...
              all(col     >= 0);                % REMOVE 4/1/08 ------ all(pixFlux >= 0) && ...
                   
% variances must be non-negative          
if(isvector(Cpixflux))
    % if Cpixflux is a vector of uncertainties = sqrt(variance)
    allNonNeg = allNonNeg && all(Cpixflux >= 0);
    covarianceOK = true;
else
    % if Cpixflux is a covariance matrix - variances lie along the diagonal
    allNonNeg = allNonNeg && all(diag(Cpixflux) > 0);

    if( isequal(Cpixflux, Cpixflux') )
        covarianceOK =  true;      
    end    
end


if( ~allNonNeg)
    warning(['PA:',mfilename,':NegativeDataInput'],...
        ['Input data for radius, row, col must be non-negative. Gapping eeMetric for relative cadence ',num2str(iCadence),'.']);
    return;
end

if( ~covarianceOK)
    warning(['PA:',mfilename,':BadCovarianceDataInput'],...
        ['Input data for Cpixflux negative variance or not a covariance matrix. Gapping eeMetric for relative cadence ',num2str(iCadence),'.']);
    return;
end   
   

result = true;

