function waveletObject = waveletClass( h0 )
%
% waveletClass -- constructor for waveletClass objects
%
% The waveletClass constructor takes the following arguments:
%
% -> h0:  scaling filter coefficients (for example, Daubechies' 12 tap)
%
% The arguments become members of the class, along with the following:
%
% -> extendedFluxTimeSeries: flux time series extended to power of 2 length
% -> varianceWindowCadences:  number of cadences to use for calculating variance of
%    highest band
% -> H:  nExtendedCadences x mScale array of filter coefficients in the frequency domain,
%    where H(:,i) is the complete filter which, when applied to time series x, produces
%    wavelet vector x_i (in Jenkins notation)
% -> G:  nExtendedCadences x mScale array of synthetis filter bank coefficients in the
%    frequency domain, which can be used as an inverse to G.
% -> whiteningCoefficients:  nExtendedCadences x mScale array of inverseWstd2 coefficients
%    which are the sigmas needed for whitening the extendedFluxTimeSeries.
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

% There are actually two use-cases:  in one of these, there is only one argument, which is
% a struct -- it's a previously-defined waveletClass object which has been cast as a
% struct, and now wants to be cast back as an object...

  if nargin == 1 && isstruct(h0)
      waveletStruct = h0 ;
  else      
      waveletStruct = construct_struct_from_1_member( h0 ) ;
  end
  
  waveletObject = class( waveletStruct, 'waveletClass' ) ;

return

%=========================================================================================

% subfunction which builds wavelectStruct from 1 or 2 members

function waveletStruct = construct_struct_from_1_member( h0 ) 

  waveletStruct.h0 = h0 ;
  
% all other fields are empty

  waveletStruct.H = [] ;
  waveletStruct.G = [] ;
  waveletStruct.extendedFluxTimeSeries = [] ;
  waveletStruct.varianceWindowCadences = [] ;
  waveletStruct.whiteningCoefficients = [] ;
  waveletStruct.outlierIndicators = [] ;
  waveletStruct.outlierFillValues = [] ;
  waveletStruct.useOutlierFreeFlux = [] ;
  waveletStruct.gapFillParametersStruct = [] ;
  waveletStruct.fittedTrend = [] ;
  waveletStruct.haveCustomWhiteningCoefficients = [] ;
  waveletStruct.noiseEstimationByQuarterEnabled = [] ;
  waveletStruct.quarterIdVector = [] ;
  
return

