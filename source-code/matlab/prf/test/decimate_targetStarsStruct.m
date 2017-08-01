function targetIndex = decimate_targetStarsStruct( prfCreationObject, nStarsMin, keepUnused )
%
% decimate_targetStarsStruct -- reduce the # of stars in the targetStarsStruct
% sub-structure of the prfInputStruct structure.
%
% targetIndex = decimate_targetStarsStruct( prfCreationObject ) takes the
%    prfCreationObject and reduces the population of its targetStarsStruct such that the
%    only stars left in the structure are the ones which are going to be used for the PRF
%    fit.  It is assumed that the prfCreationObject has had background subtraction
%    completed prior to execution of decimate_targetStarsStruct.  A vector of indices into
%    targetStarsStruct for the stars to be kept is returned.
%
% targetIndex = decimate_targetStarsStruct( prfCreationObject, nStars ) uses a
%    user-selected decimation value rather than the minimum # of stars required for PRF
%    fitting.
%
% targetIndex = decimate_targetStarsStruct( prfCreationObject, nStars, keepUnused ) only
%    removes stars that are within the crowding and magnitude screens of the PRF fitter
%    and only within the regions of the mod/out used for the fit.  This leaves most of the
%    stars intact, but reduces the # of stars used in PRF fitting so that PRF fitting is
%    faster.
%
% Version date:  2008-October-19.
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
%=========================================================================================

  [nRegions, regionMinSize, regionStepSize, minStars] = ...
      get_multiple_prf_parameters( prfCreationObject ) ;

  if ( ~exist('nStarsMin','var') || isempty(nStarsMin) )
      nStarsMin = minStars ;
  end
  
  if ( ~exist('keepUnused','var') || isempty(keepUnused) )
      keepUnused = false ;
  end
  
  regionFractionVector = [] ;
  nStarsVector = [] ;
  selectedTargetMatrix = [] ;

% perform the normal star selection procedure which is usually part of fit_prf

  for iRegion = 1:nRegions
      foundEnoughStars = false ;
      for regionFraction = regionMinSize:regionStepSize:1

          prfCreationObject = set_row_column_limits(prfCreationObject, iRegion, ...
              regionFraction) ;
          prfCreationObject = compute_downselection(prfCreationObject) ;
          [selectedTargets,nStars] = get_selected_target_info(prfCreationObject) ;
          if (nStars >= minStars)
              foundEnoughStars = true ;
              break ;
          end

      end % end of regionFraction loop
      
      if (~foundEnoughStars)
          error('prf:decimateTargetStarsStruct:tooFewStars', ...
              'decimate_targetStarsStruct: too few stars for PRF computation') ;
      end

%     save the target information

      selectedTargetMatrix = [selectedTargetMatrix selectedTargets(:)] ;
      nStarsVector = [nStarsVector nStars] ;
      regionFractionVector = [regionFractionVector regionFraction] ;
      
  end % loop over regions
    
% Go through the selectedTargetsMatrix, column by column, and randomly select minStars out
% of the target stars in each column which are to be kept

  keepStars = [] ;
  for iRegion = 1:nRegions
      starTargets = find(selectedTargetMatrix(:,iRegion)==1) ;
      targetRandomOrder = randperm(length(starTargets)) ;
      nStarsToKeep = min([nStarsMin length(targetRandomOrder)]);
      keepStars = [keepStars ; starTargets(targetRandomOrder(1:nStarsToKeep))] ;
  end
  
% if we want to keep the unused star targets, find them and add them now

  if (keepUnused)
      unusedStars = find(all(~selectedTargetMatrix,2)) ;
      keepStars = [keepStars ; unusedStars(:)] ;
  end
  targetIndex = keepStars ;
  
% and that's it!

%
%
%
