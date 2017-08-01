function koiData = parse_koi_text_file( filename, minSesInMesCount, unitOfWork, ...
    koiFlagTableFilename, maxKoiNumber )
%
% parse_koi_data_file -- parse the KOI flat-text data file specified by the user
%
% koiData = parse_koi_data_file( filename, minSesInMesCount, unitOfWork ) will read the 
%    flat-text KOI data file specified by the user and return a struct with the Kepler
%    IDs, periods, and epochs (in days and KJD, respectively) for the KOIs.  The returned
%    information does not include any KOIs which are on the TPS EB list, or which would
%    have too few SES in MES to be detected.
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

% load the data file via importdata

  data = importdata( filename, '|', 2 ) ;
  koi = data.data(:,1) ;
  
% lop off KOIs as needed based on max KOI number

  if exist( 'maxKoiNumber','var' ) && ~isempty( maxKoiNumber )
      koiInRange = koi < maxKoiNumber + 1 ;
      data.data = data.data(koiInRange,:) ;
      koi = koi(koiInRange) ;
  end
  
  keplerId = data.data(:,2) ;
  periodDays = data.data(:,6) ;
  epochKjd = data.data(:,4) + 67 ; % convert from Jason to KJD
  depthPpm = data.data(:,20) ;
  snr = data.data(:,21) ;

  load(koiFlagTableFilename) ;
  [isInFlagTable,flagTableLocation] = ismember( koi, koiFlagTable.koiNumber ) ; 
  flagValue = nan(size(keplerId)) ;
  flagValue(isInFlagTable) = koiFlagTable.qualityFlag(flagTableLocation(isInFlagTable)) ;
  
% correct epochs -- Jason's epoch are often not the earliest possible epoch in the unit of
% work, and occasionally they are prior to the start of the unit of work

  epochTooEarly = epochKjd < unitOfWork(1) ;
  nPeriodsTooEarly = zeros( length(keplerId),1 ) ;
  nPeriodsTooEarly(epochTooEarly) = ceil( (unitOfWork(1) - epochKjd(epochTooEarly)) ./ ...
      periodDays(epochTooEarly) ) ;
  epochKjd = epochKjd + nPeriodsTooEarly .* periodDays ;

  nPeriodsTooLate = floor( (epochKjd-unitOfWork(1)) ./ periodDays ) ;
  epochKjd = epochKjd - nPeriodsTooLate .* periodDays ;
  
% determine whether any of the KOIs have timing such that inadequate #'s of transits will
% occur in the UOW

  nTransitsInUow = floor( (unitOfWork(2) - epochKjd) ./ periodDays ) + 1 ;
  
% determine which of the KOIs are on the EB list

  eclipsingBinaryData = load_eclipsing_binary_catalog ;
  ebKepId = eclipsingBinaryData(:,1) ;
  isEb = ismember( keplerId, ebKepId ) ;
  
% build the logical which will be used to select the data

  goodKoi = nTransitsInUow >= minSesInMesCount & ~isEb & ...
      periodDays > 0 & flagValue == 0 ;
  
% build the return struct

  koiData.keplerId = keplerId( goodKoi ) ;
  koiData.periodDays = periodDays( goodKoi ) ;
  koiData.epochKjd = epochKjd( goodKoi ) ;
  koiData.depthPpm = depthPpm( goodKoi ) ;
  koiData.snr = snr( goodKoi ) ;
  koiData.koiNumber = koi( goodKoi ) ;
  koiData.rejectedKeplerId = keplerId( ~goodKoi ) ;
  
return

