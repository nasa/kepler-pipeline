function [fpgResultsObject, fpgDataObject] = update_fpg( fpgDataObject )
%
% update_fpg -- perform the Focal Plane Geometry fits represented by an object of the
% fpgDataClass.
%
% fpgResultsObject = update_fpg( fpgDataObject ) performs the nonlinear fitting of the
%    Kepler mission focal plane geometry alignment errors, using the fpgFitClass objects
%    which are embedded in the fpgDataObject.  The results are returned as an
%    fpgResultsClass object, fpgResultsObject.
%
% [fpgResultsObject, fpgDataObject] = update_fpg( fpgDataObject ) also returns the updated
%    fpgDataObject to the caller.  This is intended for diagnostic use only.
%
% Version date:  2008-July-02.
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

% Is the vector of fpgFitClass objects present?  If not, we can't do anything

  nFits = length(fpgDataObject.fpgFitObject) ;
  if (nFits == 0)
      error('fpg:updateFpg:fpgFitObjectEmpty',...
          'update_fpg:  the fpgFitObject member of the fpgDataClass object is empty') ;
  end
  
% otherwise, copy the final fit so that we can save its initial conditions for later use

  fpgFitObjectFinal = fpgDataObject.fpgFitObject(nFits) ;
  
% loop over fits

  for iFit = 1:nFits
            
%     perform the current fit

      t0 = clock ;
      disp(['      FPG:  performing fit number ',num2str(iFit),' of ',num2str(nFits)]) ;
      fpgDataObject.fpgFitObject(iFit) = do_fpg_fit( fpgDataObject.fpgFitObject(iFit) ) ;
            
%     copy the initial conditions from this fit to all the subsequent ones; if this is the
%     last fit, reinstate the original initial conditions into the fit object

      if (iFit < nFits)
          
          for jFit = iFit+1:nFits
              fpgDataObject.fpgFitObject(jFit) = update_initial_parameters( ...
                  fpgDataObject.fpgFitObject(jFit), ...
                  fpgDataObject.fpgFitObject(iFit) ) ;
          end
          
      else
          
          fpgDataObject.fpgFitObject(iFit) = update_initial_parameters( ...
              fpgDataObject.fpgFitObject(iFit), fpgFitObjectFinal, true ) ;
          
      end
      t1 = clock ;
      disp(['            completed fit number ',num2str(iFit),' of ',num2str(nFits), ...
          ' in ',num2str(etime(t1,t0)),' seconds']) ;
      
  end % loop over fpgFitObjects
  
% instantiate the fpgResultsClass object with the fit results

  fpgResultsObject = fpgResultsClass( fpgDataObject ) ;
  
% and that's it!

%
%
%