function prfCollectionObject = expand_coefficient_matrices( prfCollectionObject )
%
% expand_coefficient_matrices -- pad coefficient matrices out to the same order
%
% prfCollectionObject = expand_coefficient_matrices( prfCollectionObjet ) expands the
%    coefficient matrices of a prfCollectionClass object such that they all have identical
%    order.  The maxOrder field of the underlying prfClass objects is also updated.
%
% Version date:  2008-October-21.
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

% get the maxOrder of all the prfClass objects

  maxOrderVector = zeros(6,1) ;
  for count = 1:length(prfCollectionObject.prfCornerObject)
      maxOrderVector(count) = get(prfCollectionObject.prfCornerObject(count),'maxOrder') ;
  end
  maxOrderVector(6) = get(prfCollectionObject.prfCenterObject,'maxOrder') ;
  
  maxOrder = max(maxOrderVector) ; minOrder = min(maxOrderVector) ;
  
% we only need to do anything if the orders are not the same

  if ( maxOrder ~= minOrder )
      
%     loop over prfClass objects and expand them if need be.  Note that when we are done
%     none of the prfClass objects will still have its polyStructs, if they had them in
%     the first place!  We ensure this by calling prfClass with the coefficient matrix
%     regardless of whether it was expanded

      prfObjectVector = [prfCollectionObject.prfCornerObject ; ...
          prfCollectionObject.prfCenterObject] ;
      for iPrf = 1:length(prfObjectVector)
                 
%         one wrikle to this is that the prfClass object can optionally have its
%         polyStruct representation of the PRF filled or empty.  Handle that dichotomy now

          polyStruct = get(prfObjectVector(iPrf), 'polyStruct') ;
          prfSpecification.type = get(prfObjectVector(iPrf), 'type') ;
          if ~isempty(polyStruct)
              newPrfData = extend_polyStruct_order( polyStruct, maxOrder ) ;
          else
              oldCoeffMatrix = get(prfObjectVector(iPrf),'coefficientMatrix') ;
              if (maxOrderVector(iPrf) < maxOrder)
                  newPrfData = expand_coefficient_matrix( oldCoeffMatrix, ...
                      maxOrderVector(iPrf), maxOrder ) ;
              else
                  newPrfData = oldCoeffMatrix ;
              end
          end
          prfObjectVector(iPrf) = prfClass(newPrfData, prfSpecification) ;
      end
      prfCollectionObject.prfCornerObject = prfObjectVector(1:5) ;
      prfCollectionObject.prfCenterObject = prfObjectVector(6) ;
      
  end % maxOrder conditional
  
% and that's it!

%
%
%

%=========================================================================================

% function which expands the order of all matrices in polyStruct to the desired maxOrder

function polyStructNew = extend_polyStruct_order( polyStructOld, maxOrder )

% start by copying the old to the new

  polyStructNew = polyStructOld ;
  
% determine the number of coefficients required for a 2-D polynomial of the given order

  nCoeffs = sum(1:maxOrder+1) ;
  zeroVector = zeros(nCoeffs,1) ;
  zeroMatrix = zeros(nCoeffs) ;
  
% loop over polyStructs

  for iSubCol = 1:size(polyStructOld,3)
      for iSubRow = 1:size(polyStructOld,2)
          for iPixel = 1:size(polyStructOld,1)
              
              thisPoly = polyStructOld(iPixel,iSubRow,iSubCol).c ;
              newPoly = thisPoly ;
              thisPolyOrder = thisPoly.order ;
              newPoly.order = maxOrder ;
              newPoly.coeffs = zeroVector ;
              oldCoeffs = thisPoly.coeffs ;
              newPoly.coeffs(1:length(oldCoeffs)) = oldCoeffs ;
              newPoly.covariance = zeroMatrix ;
              oldCovariance = thisPoly.covariance ;
              newPoly.covariance(1:size(oldCovariance,1),1:size(oldCovariance,2)) = ...
                  oldCovariance ;
              polyStructNew(iPixel,iSubRow,iSubCol).c = newPoly ;
              polyStructNew(iPixel,iSubRow,iSubCol).order = maxOrder ;
              
          end
      end
  end