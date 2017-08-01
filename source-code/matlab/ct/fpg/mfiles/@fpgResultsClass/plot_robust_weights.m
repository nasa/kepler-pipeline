function figureHandle = plot_robust_weights( fpgResultsObject )
%
% plot_robust_weights -- plot the weights assigned by the robust fitter during FPG
% fitting.
%
% h = plot_robust_weights( fpgResultsObject ) returns a figure handle for a plot of robust
%    weights applied by the fitter during FPG fitting.
%
% Version date:  2008-September-18.
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
%     2008-September-18, PT:
%         bugfix -- min Y value computation had a typo.
%     2008-July-31, PT:
%         handle situation where get_constraint_mod_out returns some zeros (due to
%         constraints which aren't on the focal plane in case where we fit the pointing of
%         the reference cadence)
%
%=========================================================================================

% first step is to get the module and output # of each constraint point

  [mod,out] = get_constraint_point_mod_out( fpgResultsObject.fpgFitClass ) ;
  
% excise zeros from both vectors

  constraintOffFOV = find(mod == 0) ;
  mod(constraintOffFOV) = [] ;
  out(constraintOffFOV) = [] ;
  
% convert from mod/out to channel #

  channel = convert_from_module_output( mod, out ) ;
  
% put the 3 pointing constraints on channel zero
  channel(constraintOffFOV) = 0 ;
  
% plot the weights

  figure ;
  plot(channel, get(fpgResultsObject.fpgFitClass,'robustWeights'), '.') ;
  
% scaling the plot -- the max value should always be 1.00.  The min value should be 0.99
% if the data is all >= 0.99, otherwise it should be the nearest increment of 0.05 below
% the min value.

  minWeight = min(get(fpgResultsObject.fpgFitClass,'robustWeights')) ;
  if (minWeight >= 0.99)
      minY = 0.99 ;
  else
      minY = 0.05 * floor(minWeight ./ 0.05) ;
  end
  
  axis([0 85 minY 1]) ;
  hold off ;
  
  figureHandle = gcf ;
  
% and that's it!

%
%
%
