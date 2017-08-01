function unWhitenedFluxTimeSeries = ...
    unwhiten_time_series( whiteningFilterObject, whitenedFluxTimeSeries )
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function unWhitenedFluxTimeSeriesValues = ...
%    unwhiten_time_series( whiteningFilterObject, whitenedFluxTimeSeries )
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% This method un-whitens the fluxTimeSeriesValues by dividing out the 
% whiteningCoefficients, found in whiteningFilterObject, in the wavelet 
% domain.
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

% Get fields from the input object
whiteningCoefficients = whiteningFilterObject.whiteningCoefficients; 
scalingFilterCoeffts = whiteningFilterObject.scalingFilterCoeffts;
nCadences = length(whitenedFluxTimeSeries);
H = whiteningFilterObject.H;
G = whiteningFilterObject.G;

% check inputs
if ~exist('fluxTimeSeriesValues', 'var')
    error('DV:unwhitenTimeSeries:noFluxTimeSeriesInput', ...
        'Need to specify a valid fluxTimeSeries for un-whitening');
end

if length(whiteningCoefficients) < nCadences
    % whiteningCoefficients are not long enough
     error('DV:whitenTimeSeries:incompatibleTimeSeriesLengths', ...
        'whiteningCoefficients are shorter than the fluxTimeSeries');
end

if nCadences < length(whiteningCoefficients) 
    % need to zero pad
    n1 = floor(log2(nCadences));
    n2 = n1 + 1;
    whitenedFluxTimeSeries = ...
        [whitenedFluxTimeSeries; zeros([2^n2 - nCadences, 1])];
end

% generate the waveletObject
waveletObject = waveletClass( scalingFilterCoeffts );
waveletObject = set_extended_flux( waveletObject, whitenedFluxTimeSeries, H, G);
waveletObject = set_custom_whitening_coefficients( waveletObject, whiteningCoefficients);

% Transform to the wavelet domain
owtTimeSeries = overcomplete_wavelet_transform( waveletObject, whitenedFluxTimeSeries);

% divide out the whitening coefficients at each scale, noting that the
% whitening coefficients in the object are actually sigma^(-2) 
owtTimeSeries = owtTimeSeries./sqrt(whiteningCoefficients);

% do the inverst OWT
unWhitenedFluxTimeSeries = reconstruct_time_series_from_wavelets( waveletObject, ...
      owtTimeSeries ) ;

% truncate
unWhitenedFluxTimeSeries = unWhitenedFluxTimeSeries(1:nCadences);
   
return