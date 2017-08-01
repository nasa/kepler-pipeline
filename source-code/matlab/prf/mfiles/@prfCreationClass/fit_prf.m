function [prfCreationObject, durationList, prfFitResultsStruct] = fit_prf( prfCreationObject, ...
    durationList, debugFlag ) 
%
% fit_prf -- perform the PRF fitting process
%
% [prfCreationObject, durationList, prfFitResults] = fit_prf(prfCreationObject,
%     durationList, debugFlag) performs the fit one or more PRFs based on the data and
%     parameters in the prfCreationObject.  The fitting process includes the selection of
%     stars as well as the PRF fit itself.  The prfFitResultsStruct structure has the
%     following fields:
%   
%     regionFractionVector
%     nStarsVector
%     selectedTargetMatrix
%     prfCollectionStruct
%     prfStructureVector
%
% Version date:  2008-October-14.
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

% start by getting the parameters which are relevant to the single/multiple
% prf fit

  [nRegions, regionMinSize, regionStepSize, minStars] = ...
      get_multiple_prf_parameters( prfCreationObject ) ;

  regionFractionVector = [] ;
  nStarsVector = [] ;
  selectedTargetMatrix = [] ;

% loop over the # of regions -- for one fit per mod/out, nRegions is set to 1;
% within that, loop over region fraction values, set the row/column ranges and perform the
% downselection

  for iRegion = 1:nRegions
      % set the PRF-dependent parameters in the configuration struct
      ccdChannel = prfCreationObject.ccdChannel;
      commandStr = ['prfCreationObject.prfConfigurationStruct.magnitudeRange(1) ' ...
          ' = prfCreationObject.prfConfigurationStruct.minimumMagnitudePrf' ...
          num2str(iRegion) '(ccdChannel);'];
%       disp(commandStr);
      eval(commandStr);
      commandStr = ['prfCreationObject.prfConfigurationStruct.magnitudeRange(2) ' ...
          ' = prfCreationObject.prfConfigurationStruct.maximumMagnitudePrf' ...
          num2str(iRegion) '(ccdChannel);'];
      eval(commandStr);
%       disp(commandStr);
      commandStr = ['prfCreationObject.prfConfigurationStruct.crowdingThreshold ' ...
          ' = prfCreationObject.prfConfigurationStruct.crowdingThresholdPrf' ...
          num2str(iRegion) '(ccdChannel);'];
%       disp(commandStr);
      eval(commandStr);
      commandStr = ['prfCreationObject.prfConfigurationStruct.contourCutoff ' ...
          ' = prfCreationObject.prfConfigurationStruct.contourCutoffPrf' ...
          num2str(iRegion) '(ccdChannel);'];
%       disp(commandStr);
      eval(commandStr);      
      
      foundEnoughStars = false ;
      for regionFraction = regionMinSize:regionStepSize:1

          tic ;
          prfCreationObject = set_row_column_limits(prfCreationObject, iRegion, ...
              regionFraction) ;
        
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%       compute downselection, this region and this regionFraction 
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
          prfCreationObject = compute_downselection(prfCreationObject) ;
          [selectedTargets,nStars] = get_selected_target_info(prfCreationObject) ;
          if (nStars >= minStars)
              foundEnoughStars = true ;
              break ;
          end

      end % end of regionFraction loop

%   now -- if there weren't enough stars even at 100% of the mod/out, throw an error and
%   exit

      if (~foundEnoughStars)
          error('prf:prfMatlabController:tooFewStars', ...
              'too few stars for PRF computation') ;
      end
      duration = toc;    
    
      durationElement = length(durationList);
      durationList(durationElement + 1).time = duration;
      durationList(durationElement + 1).label = 'compute down-selection';

      if (debugFlag) 
          display(['compute down-selection, region ',num2str(iRegion),': ', ...
              num2str(duration),' seconds = ' num2str(duration/60) ' minutes']);
          display(['region fraction:  ',num2str(regionFraction)]); 
      end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%     compute the prf 
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

      tic;
      [prfCreationObject prfStructure] = compute_prf(prfCreationObject);
      duration = toc;

      durationElement = length(durationList);
      durationList(durationElement + 1).time = duration;
      durationList(durationElement + 1).label = 'compute prf';

      if (debugFlag) 
          display(['compute prf, region ',num2str(iRegion),': ', ...
              num2str(duration),' seconds = ' num2str(duration/60) ' minutes']);
      end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%     Accumulate information over all regions
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
      regionFractionVector(iRegion) = regionFraction ;
      nStarsVector(iRegion) = nStars ;
      selectedTargetMatrix = [selectedTargetMatrix selectedTargets(:)] ;
      prfCollectionStruct(iRegion).polyStruct = prfStructure.prfPolyStructure.polyCoeffStruct ;
      prfCollectionStruct(iRegion).residualMean = prfStructure.prfPolyStructure.residualMean ;
      prfCollectionStruct(iRegion).residualStandardDeviation = prfStructure.prfPolyStructure.residualStandardDeviation ;
      prfCollectionStruct(iRegion).row = prfStructure.prfPolyStructure.row;
      prfCollectionStruct(iRegion).column = prfStructure.prfPolyStructure.column ;
      prfCollectionStruct(iRegion).prfConfigurationStruct = prfStructure.prfPolyStructure.prfConfigurationStruct ;
      prfStructureVector(iRegion) = prfStructure ;
    
  end % loop over iRegion

% package results for output

  prfFitResultsStruct.regionFractionVector = regionFractionVector ;
  prfFitResultsStruct.nStarsVector         = nStarsVector ;
  prfFitResultsStruct.selectedTargetMatrix = selectedTargetMatrix ;
  prfFitResultsStruct.prfCollectionStruct  = prfCollectionStruct ;
  prfFitResultsStruct.prfStructureVector   = prfStructureVector ;
  
%  