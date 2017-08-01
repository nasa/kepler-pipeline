function tceStruct = get_tces_from_tps_dawg_struct( tpsDawgStruct )
%
% get_tces_from_tps_dawg_struct -- extract the relevant information about possible
% planetary candidates from a tpsDawgStruct
%
% tceStruct = get_tces_from_tps_dawg_struct( tpsDawgStruct ) returns the TCEs from the
%    struct which is returned by assemble_tps_dawg_struct.  The resulting struct has the
%    same fields as the tpsDawgStruct, but the maxSes, maxMes, rmsCdpp, epochKjd, and
%    periodDays are nTarget x 1 rather than nTarget x nPulseLength; the values for each
%    target are the values corresponding to the pulse length which produces the maximum
%    value of maxMes >= 7.1 out of the set of the pulse lengths with MES/SES >= sqrt(2).
%    if there is no pulse length that has a maxMES >= 7.1 and MES/SES >=
%    sqrt(2) simultaneously, then the values returned will correspond to
%    the pulse length that had maximum maxMES over the whole set for each
%    target.
%
% Version date:  2011-October-06.
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

% Modification History:
%
% 2012-February-10, PT:
%             instead of hard-coding a list of fields to pick through for the value on the
%             max MES pulse, use some struct field logic to do the job on any field which
%             has the correct shape.
% 2011-October-06, PT:
%            use a task file to get the parameters which define detection criteria, rather
%            than having them hard-coded.
% 7/14/2011: SES modified to pull the results from the pulse duration for
%            which MES was above threshold out of the set of all pulse lengths for
%            which MES/SES >= sqrt(2).  If this is not possible, then the pulse with
%            the maximum maxMes over the whole set is returned.
%=========================================================================================

% copy the original struct over to the return struct

  tceStruct = tpsDawgStruct ;
  
% capture the dimensions

  nTargets   = length(tceStruct.keplerId) ;
  nPulses    = size(tceStruct.rmsCdpp,2) ;
    
  maxMesIndex = zeros(nTargets,1) ;

% for each target, find the trial which produced the max MES AND is a true TCE; if none,
% just find the max MES.  We can do this efficiently by forming an intermediate array
% which is the componentwise product of MES and the isPlanetACandidate flag

  [maxMesTrueTce,maxMesIndexTrueTce] = max( tpsDawgStruct.maxMes .* ...
      double( tpsDawgStruct.isPlanetACandidate ), [], 2 ) ;
  [~,maxMesIndexNoTce] = max( tpsDawgStruct.maxMes .* ...
      double( ~tpsDawgStruct.isPlanetACandidate ), [], 2 ) ;
  trueTceFlag = maxMesTrueTce > 0 ;
  maxMesIndex(trueTceFlag) = maxMesIndexTrueTce(trueTceFlag) ;
  maxMesIndex(~trueTceFlag) = maxMesIndexNoTce(~trueTceFlag) ;

% for i=1:nTargets
%     indexAbove = find(tpsDawgStruct.exceedsMesSesRatio(i,:)) ;
%     indexAbove2 = find(tpsDawgStruct.robustStatistic(i,:) >= robustStatisticThreshold) ;
%     indexAbove = intersect(indexAbove, indexAbove2) ;
%     if isempty(indexAbove)
%         if isnan(max(tpsDawgStruct.maxMes(i,:))) || max(tpsDawgStruct.maxMes(i,:))==0
%             % if we just have NaNs then set the index to 1
%             maxMesIndex(i) = 1 ;
%         else
%             maxMesIndex(i) = find(tpsDawgStruct.maxMes(i,:) == max(tpsDawgStruct.maxMes(i,:))) ;
%         end
%     else
%         maxMesIndex(i) = find(tpsDawgStruct.maxMes(i,indexAbove) == max(tpsDawgStruct.maxMes(i,indexAbove))) ;
%         maxMesIndex(i) = indexAbove(maxMesIndex(i)) ;
%         if tpsDawgStruct.maxMes(i,maxMesIndex(i)) < searchTransitThreshold
%             maxMesIndex(i) = find(tpsDawgStruct.maxMes(i,:) == max(tpsDawgStruct.maxMes(i,:))) ;
%         else
%             trueTceFlag(i) = true;
%         end
%     end
% end

% convert the subscripts to linear indices -- this allows us to capture the desired values
% out of the MES matrix, etc, without a loop

  maxMesLinearIndex = sub2ind([nTargets nPulses],1:nTargets,maxMesIndex') ;
  
% get the pieces we want -- in this case, anything which is nTargets x nPulses, we want to
% extract the info for the pulse which had the max MES

  tceStructFieldNames = fieldnames( tceStruct ) ;
  nFields = length( tceStructFieldNames ) ;
  for iField = 1:nFields
      
    thisField = tpsDawgStruct.(tceStructFieldNames{iField}) ;
    if (strcmp(tceStructFieldNames{iField}, 'planetCandidateStruct'))
        %TODO: fix this
        tceStruct.(tceStructFieldNames{iField}) = [];
        continue;
    else
        if isequal( size( thisField ), [nTargets nPulses] )
            tceStruct.(tceStructFieldNames{iField}) = thisField(maxMesLinearIndex)' ;
        end
    end
      
  end

   tceStruct.trueTceFlag = trueTceFlag ;
  
% to finish off, capture the ID # of the pulse with the max MES in each case

  tceStruct.maxMesPulseNumber = maxMesIndex ;
  tceStruct.maxMesPulseDurationHours = ...
      tceStruct.pulseDurations( maxMesIndex ) ;
  
% display the number of targets which had max MES over threshold

  maxMesTargetCount = length( find(any( tpsDawgStruct.isPlanetACandidate, 2 ) )) ;
  disp(['Number of targets with MES above threshold:  ',num2str(maxMesTargetCount)]) ;
  
% display the number of targets with TCEs:

  nTces = length(find(tceStruct.trueTceFlag)) ;
  disp(['Number of TCEs:  ', num2str(nTces)]) ;
  
% display the number of TCEs which were found on the first iteration of the looper

  nTcesFirstIter = length(find( tceStruct.trueTceFlag & tceStruct.searchLoopCount == 1 ) ) ;
  disp(['Number of TCEs found on iteration 1:  ', num2str(nTcesFirstIter)]) ;
  disp(['Number of TCEs found on later iterations:  ', num2str(nTces-nTcesFirstIter)]) ;
  
% display the max # of iterations needed for any TCE

  maxItersWithTce = max( tceStruct.trueTceFlag .* tceStruct.searchLoopCount ) ;
  disp(['Max # of iterations with TCE:  ', num2str(maxItersWithTce)]) ;

% 

return

