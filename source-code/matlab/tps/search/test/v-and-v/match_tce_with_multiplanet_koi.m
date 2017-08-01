function koiAndTceStruct = match_tce_with_multiplanet_koi( koiDataStruct, tceStruct )
%
% match_tce_with_multiplanet_koi -- attempt to identify TCEs from TPS with the correct
% planet in the case of multi-planet KOIs
%
% koiAndTceStruct = match_tce_with_multiplanet_koi( koisWithTcesStruct, tceStruct ) 
%    attempts to match TCEs with the correct planets in a KOI data struct, and produces a
%    data struct which includes the information from both TCE and KOI datalists.  It also
%    produces a metric for the ephemeris match between the TCE and the corresponding KOI,
%    which tells the fraction of transits in the two ephemerides which overlap one
%    another.
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

  nTces = length( unique(koiDataStruct.keplerId) ) ;
  keplerIdList = unique( koiDataStruct.keplerId ) ;
  koiAndTceStruct = struct( 'keplerId', zeros(nTces,1), 'koiPeriodDays', zeros(nTces,1), ...
      'koiEpochKjd', zeros(nTces,1), 'koiDepthPpm', zeros(nTces,1), 'koiSnr', ...
      zeros(nTces,1), 'tcePeriodDays', zeros(nTces,1), 'tceEpochKjd', zeros(nTces,1), ...
      'ephemerisMatch', zeros(nTces,1), 'koiNumber', zeros(nTces,1) ) ;
  
% loop over the targets

  for iTarget = 1:length(keplerIdList) ;
      
%     first do the easy assignments 
      
      koiAndTceStruct.keplerId(iTarget) = keplerIdList(iTarget) ;
      tcePointer = ismember( tceStruct.keplerId, keplerIdList(iTarget) ) ;
      koiAndTceStruct.tcePeriodDays(iTarget) = tceStruct.periodDays(tcePointer) ;
      koiAndTceStruct.tceEpochKjd(iTarget) = tceStruct.epochKjd(tcePointer) ;
      
%     now for the hard part:  locate all the KOIs which have the same KIC number as this
%     TCE

      koiPointer = ismember( koiDataStruct.keplerId, keplerIdList(iTarget) ) ;
      koiIndex = find(koiPointer) ;
      
%     compute the ephemeris match for each KOI compared to the TCE

      ephemerisMatch = zeros(size(koiIndex)) ;
      for iKoi = 1:length(koiIndex)
          thisKoi = koiIndex(iKoi) ;
          ephemerisMatch(iKoi) = ephemeris_match( koiDataStruct.epochKjd(thisKoi), ...
              koiDataStruct.periodDays(thisKoi), tceStruct.epochKjd(tcePointer), ...
              tceStruct.periodDays(tcePointer), ...
              tceStruct.maxMesPulseDurationHours(tcePointer), ...
              tceStruct.unitOfWorkKjd ) ;
      end
      
%     find the one with the best match and latch it 
      
      [~,correctIdentification] = max(ephemerisMatch) ;
      koiIndex = koiIndex(correctIdentification) ;
      koiAndTceStruct.koiPeriodDays(iTarget) = koiDataStruct.periodDays(koiIndex) ;
      koiAndTceStruct.koiEpochKjd(iTarget) = koiDataStruct.epochKjd(koiIndex) ;
      koiAndTceStruct.koiDepthPpm(iTarget) = koiDataStruct.depthPpm(koiIndex) ;
      koiAndTceStruct.koiSnr(iTarget) = koiDataStruct.snr(koiIndex) ;
      koiAndTceStruct.ephemerisMatch(iTarget) = ephemerisMatch(correctIdentification) ;
      koiAndTceStruct.koiNumber(iTarget) = koiDataStruct.koiNumber(koiIndex) ;
      
  end
  
% perform descending sort of ephemeris match

  [~,sortKey] = sort( koiAndTceStruct.ephemerisMatch, 'descend' ) ;
  fieldNames = fieldnames(koiAndTceStruct) ;
  fieldNames = fieldNames(:)' ;
  for thisField = fieldNames
      koiAndTceStruct.(thisField{1}) = koiAndTceStruct.(thisField{1})(sortKey) ;
  end

      
return

