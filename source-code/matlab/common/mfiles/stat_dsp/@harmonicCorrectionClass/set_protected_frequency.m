function set_protected_frequency( obj, protectedPeriodInSamples )
%
% set_protected_frequency -- determine the frequency which should be protected from
% removal in a time series, and store that information in the harmonicCorrectionClass
% object
%
% obj.set_protected_frequency( protectedPeriodInSamples ) uses the protected period,
%    supplied in units of sample intervals, to determine the frequencies which should not
%    be removed by the harmonicCorrectionClass methods.  These frequencies are converted
%    to periodogram bins, and these bin numbers are stored in the object.
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

% this only makes sense if the flux is set

  if isempty(obj.originalFluxTimeSeries)
      error('common:harmonicCorrectionClass:originalFluxTimeSeriesNotSet', ...
          'set_protected_frequency:  original flux time series not set') ;
  end
  
% trivial case -- if empty, clear the existing values and exit

  if ~exist('protectedPeriodInSamples','var') || isempty(protectedPeriodInSamples)
      obj.protectedIndices = [] ;
      return
  end

% compute the frequency bins in the periodogram

  fHz = obj.get_psd_frequencies ;
  
  samplingFrequencyHz = 1/obj.sampleIntervalSeconds ;
  
% convert the period to seconds from samples, then to a frequency, then to the comb of
% frequencies which correspond to the period to be protected

  protectedPeriodInSeconds = protectedPeriodInSamples * obj.sampleIntervalSeconds ;
  protectedFrequenciesHz = 1/protectedPeriodInSeconds ;
  protectedFrequenciesHz = protectedFrequenciesHz:protectedFrequenciesHz:samplingFrequencyHz/2 ;
  
% find the frequencies which are closest to the protected ones

  protectedIndices = zeros( length(protectedFrequenciesHz),1 ) ;
  for i=1:length(protectedIndices)
      [~, protectedIndices(i)] = min( abs(fHz-protectedFrequenciesHz(i)) );
  end
  
% pad each side of the peak

  pointsToPad = 4 ;
  protectedIndices = repmat(protectedIndices,1,2*pointsToPad+1);
  protectedIndices = protectedIndices - repmat(-pointsToPad:1:pointsToPad,...
      length(protectedFrequenciesHz),1);
  protectedIndices = sort(reshape(protectedIndices,...
      length(protectedFrequenciesHz) * (2*pointsToPad+1),1));
  protectedIndices = protectedIndices(protectedIndices>0 & protectedIndices<length(fHz));

% set property and exit

  obj.protectedIndices = protectedIndices ;
  
return

