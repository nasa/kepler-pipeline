function [koiAndTceStruct,koiOnlyStruct,tceOnlyStruct] = ...
    match_multiplanet_tce_with_multiplanet_koi2( koiDataStruct, dvOutputMatrix, koiIndicator, unitOfWorkKjd )
%
% match_multiplanet_tce_with_multiplanet_koi -- attempt to identify TCEs from TPS with the
% correct planet in the case of multi-planet KOIs
%
% [koiAndTceStruct,koiOnlyStruct,tceOnlyStruct] = match_multiplanet_tce_with_multiplanet_koi( 
%    koisWithTcesStruct, tceStruct ) attempts to match TCEs with the correct planets in a
%    KOI data struct, and produces a data struct which includes the information from both
%    TCE and KOI datalists.  It also produces an ephemeris match figure of merit for each
%    match.  The three returned structs are:  the struct of attempted matches between KOIs
%    and TCEs; a struct of unmatched KOIs (generally when the number of planet candidates
%    on a KOI exceeds the number of TCEs on the same target); and a struct of unmatched
%    TCEs (when the number of TCEs exceeds the number of KOIs on a given target).
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

  keplerIdList = unique( koiDataStruct.keplerId(koiIndicator) ) ;
  koiIndices = find(koiIndicator);
  koiAndTceStruct = struct( 'keplerId', [], 'koiPeriodDays', [], 'koiEpochKjd', [], ...
      'koiDepthPpm', [], 'koiSnr', [], 'tcePeriodDays', [], 'tceEpochKjd', [], ...
      'mes',[], 'ephemerisMatch', [], 'koiNumber', [], 'tceNumber', [] ) ;
  
  koiOnlyStruct = struct( 'keplerId', [], 'koiPeriodDays', [], 'koiEpochKjd', [], ...
      'koiDepthPpm', [], 'koiSnr', [], 'koiNumber', [] ) ;
  
  tceOnlyStruct = struct( 'keplerId', [], 'tcePeriodDays', [], 'tceEpochKjd', [], ...
      'mes', [], 'tceNumber', [], 'koiNumber', [] ) ;
  
% loop over the targets

%   if ~isfield(tceStruct,'tceIndex')
%       tceStruct.tceIndex = zeros(size(tceStruct.keplerId)) ;
%   end
  for iTarget = 1:length(keplerIdList) ;
      
      keplerId = keplerIdList(iTarget) ;
      koiPointer = koiDataStruct.keplerId(koiIndicator) == keplerId ;
      koiPointer = koiIndices(koiPointer);
      tcePointer = find(dvOutputMatrix(:,3) == keplerId) ;
      koiNumber  = floor(koiDataStruct.koiNumber(koiPointer(1))) ;
      
%     though it pains me to do this:  construct a matrix of ephemeris matches between the
%     two sets of information

      ephemerisMatch = zeros( length(koiPointer), length(tcePointer) ) ;
      for iKoi = 1:length(koiPointer)
          for iTce = 1:length(tcePointer)
              thisKoi = koiPointer(iKoi) ;
              thisTce = tcePointer(iTce) ;
              ephemerisMatch( iKoi, iTce ) = ephemeris_match( ...
                  koiDataStruct.epochKjd( thisKoi ), koiDataStruct.periodDays( thisKoi ), ...
                  dvOutputMatrix( thisTce,121 ) - kjd_offset_from_mjd, dvOutputMatrix( thisTce,122 ), ...
                  dvOutputMatrix( thisTce,257 ), unitOfWorkKjd ) ;
          end
      end
      
%     For each KOI, find the TCE which provides the best match for it -- a slightly
%     complicated operation when the # of KOIs and TCEs are not guaranteed to match.  Once
%     done, return a list of unmatched KOIs or TCEs 

      [matchedKoiTceStruct, unmatchedKoiList, unmatchedTceList] = ...
          perform_koi_tce_matching( ephemerisMatch ) ;
            
      koiList = [matchedKoiTceStruct.koiList] ;
      tceList = [matchedKoiTceStruct.tceList] ;
      for iMatch = 1:length(koiList)
          
          thisKoi = koiPointer(koiList(iMatch)) ; % point back into koiDataStruct
          thisTce = tcePointer(tceList(iMatch)) ; % point back into tceStruct
          
          koiAndTceStruct.keplerId = [koiAndTceStruct.keplerId ; keplerId] ;
          koiAndTceStruct.koiPeriodDays = [koiAndTceStruct.koiPeriodDays ; ...
              koiDataStruct.periodDays(thisKoi)] ;
          koiAndTceStruct.koiEpochKjd = [koiAndTceStruct.koiEpochKjd ; ...
              koiDataStruct.epochKjd(thisKoi)] ;
          koiAndTceStruct.koiDepthPpm = [koiAndTceStruct.koiDepthPpm ; ...
              koiDataStruct.depthPpm(thisKoi)] ;
          koiAndTceStruct.koiSnr = [koiAndTceStruct.koiSnr ; ...
              koiDataStruct.snr(thisKoi)] ;
          koiAndTceStruct.koiNumber = [koiAndTceStruct.koiNumber ; ...
              koiDataStruct.koiNumber(thisKoi)] ;
          
          koiAndTceStruct.tcePeriodDays = [koiAndTceStruct.tcePeriodDays ; ...
              dvOutputMatrix(thisTce,122)] ;
          koiAndTceStruct.tceEpochKjd = [koiAndTceStruct.tceEpochKjd ; ...
              dvOutputMatrix(thisTce,121)-kjd_offset_from_mjd] ;
          %koiAndTceStruct.tceDutyCycle = [koiAndTceStruct.tceDutyCycle ; ...
          %    tceStruct.dutyCycle(thisTce)] ;
          koiAndTceStruct.mes = [koiAndTceStruct.mes ; ...
              dvOutputMatrix(thisTce,8)] ;
          koiAndTceStruct.tceNumber = [koiAndTceStruct.tceNumber ; ...
              dvOutputMatrix(thisTce,5)] ;
          
          koiAndTceStruct.ephemerisMatch = [koiAndTceStruct.ephemerisMatch ; ...
              ephemerisMatch( koiList(iMatch), tceList(iMatch) )] ;
          
      end
      
%     now capture the unmatched KOIs or TCEs (there will only be one or the other from
%     each target)

      if ~isempty( unmatchedKoiList )
          
          koiList = koiPointer( unmatchedKoiList ) ;
          koiOnlyStruct.keplerId = [koiOnlyStruct.keplerId ; ...
              koiDataStruct.keplerId( koiList )] ;
          koiOnlyStruct.koiPeriodDays = [koiOnlyStruct.koiPeriodDays ; ...
              koiDataStruct.periodDays( koiList )] ;
          koiOnlyStruct.koiEpochKjd = [koiOnlyStruct.koiEpochKjd ; ...
              koiDataStruct.epochKjd( koiList )] ;
          koiOnlyStruct.koiDepthPpm = [koiOnlyStruct.koiDepthPpm ; 
              koiDataStruct.depthPpm( koiList )] ;
          koiOnlyStruct.koiSnr = [koiOnlyStruct.koiSnr ; ...
              koiDataStruct.snr( koiList )] ;
          koiOnlyStruct.koiNumber = [koiOnlyStruct.koiNumber ; ...
              koiDataStruct.koiNumber( koiList )] ;
          
      end
      
      if ~isempty( unmatchedTceList )
          
          tceList = tcePointer( unmatchedTceList ) ;
          tceOnlyStruct.keplerId = [tceOnlyStruct.keplerId ; ...
              dvOutputMatrix( tceList,3 )] ;
          tceOnlyStruct.tcePeriodDays = [tceOnlyStruct.tcePeriodDays ; ...
              dvOutputMatrix( tceList,122 )] ;
          tceOnlyStruct.tceEpochKjd = [tceOnlyStruct.tceEpochKjd ; ...
              dvOutputMatrix( tceList,121 )-kjd_offset_from_mjd] ;
          %tceOnlyStruct.tceDutyCycle = [tceOnlyStruct.tceDutyCycle ; ...
          %    tceStruct.dutyCycle( tceList )] ;
          tceOnlyStruct.mes = [tceOnlyStruct.mes ; ...
              dvOutputMatrix( tceList,8 )] ;
          tceOnlyStruct.tceNumber = [tceOnlyStruct.tceNumber ; ...
              dvOutputMatrix( tceList,5 )] ;
          tceOnlyStruct.koiNumber = [tceOnlyStruct.koiNumber ; ...
              repmat(koiNumber,length(tceList),1) ] ;
          
      end
      
  end % loop over target stars
  
% sort the matchedKoiTceStruct by matchiness

  koiAndTceStruct = sort_koi_tce_struct_by_matchiness( koiAndTceStruct ) ;

  
return
          
%=========================================================================================      

% subfunction which performs the matching between the KOIs and the TCEs based on their
% ephemeris match parameters

function [matchedKoiTceStruct, unmatchedKoiList, unmatchedTceList] = ...
          perform_koi_tce_matching( ephemerisMatch )
      
% start by figuring whether we have more TCEs or KOIs

  [nKois, nTces] = size( ephemerisMatch ) ;
  nMin = min(nKois,nTces) ;
  
% define the matched KOI-TCE struct

  matchedKoiTceStruct.koiList = zeros(nMin,1) ;
  matchedKoiTceStruct.tceList = zeros(nMin,1) ;
  
% initialize both of the unmatched lists to have everything unmatched

  unmatchedKoiList = 1:nKois ; unmatchedKoiList = unmatchedKoiList(:) ;
  unmatchedTceList = 1:nTces ; unmatchedTceList = unmatchedTceList(:) ;
  
% loop over the items to be matched...

  for iMatch = 1:nMin
      
%     ... find the strongest KOI-TCE match:  first find the TCE which is the best match
%     for each KOI

      [bestMatchForEachKoi,bestTceForEachKoi] = max( ephemerisMatch, [], 2 ) ;
      
%     now find the KOI which has the best match out of the best matches

      [~, koiWithBestMatch] = max( bestMatchForEachKoi ) ;
      
%     now record these for posterity 

      matchedKoiTceStruct.koiList(iMatch) = koiWithBestMatch ;
      matchedKoiTceStruct.tceList(iMatch) = bestTceForEachKoi(koiWithBestMatch) ;
      
%     blank out the koi AND the tce which were just recorded

      ephemerisMatch(matchedKoiTceStruct.koiList(iMatch),:) = -1 ;
      ephemerisMatch(:,matchedKoiTceStruct.tceList(iMatch)) = -1 ;
      unmatchedKoiList(matchedKoiTceStruct.koiList(iMatch)) = -1 ;
      unmatchedTceList(matchedKoiTceStruct.tceList(iMatch)) = -1 ;
      
  end
  
  unmatchedKoiList(unmatchedKoiList <= 0) = [] ;
  unmatchedTceList(unmatchedTceList <= 0) = [] ;
  
return

%========================================================================================

function koiAndTceStruct = sort_koi_tce_struct_by_matchiness( koiAndTceStruct )

% produce the sort key

  [~,sortKey] = sort(koiAndTceStruct.ephemerisMatch,'descend') ;
  
  fieldNames = fieldnames(koiAndTceStruct) ;
  
  fieldNames = fieldNames(:) ;
  fieldNames = fieldNames' ;
  
  for iField = fieldNames
      
      koiAndTceStruct.(iField{1}) = koiAndTceStruct.(iField{1})(sortKey) ;
      
  end
  
return
