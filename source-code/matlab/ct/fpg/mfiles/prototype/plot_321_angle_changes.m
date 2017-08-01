function plot_321_angle_changes( fitterArgs, initialParValues, finalParValues, covariance )
%
% plot_321_angle_changes( fitterArgs, initialParValues, finalparValues, covariance ) -- 
%    plot the change in the "3" angles, the "2" angles, and the "1" angles of the fitted
%    3-2-1 tranformation from FPG for all CCDs.  
%
% version date:  2008-May-28.
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
%    2008-may-28, PT:
%        move the main functionality to plot_fpg_fit_results, leaving this function just
%        to pre-organize the data and apply labels.  Support of engineering notation
%        scaling tools.
%    2008-may-20, PT:
%        change to 6 plots per page, with error bar plots on left and bar charts of error
%        bar values on right.
%
%=========================================================================================

% do the plot via the plot_fpg_fit_results function

  figure ;
  prefixStrings = plot_fpg_fit_results( fitterArgs, finalParValues-initialParValues, ...
      covariance ) ;
 
% apply labels where appropriate

  subplot(3,2,1) 
  title('Changes in 3-2-1 Xfrm Angles')
  ylabel(['3 Angle [',prefixStrings{1,1},'^{\circ}]']) ;
  subplot(3,2,3) 
  ylabel(['2 Angle [',prefixStrings{2,1},'^{\circ}]']) ;
  subplot(3,2,5) 
  ylabel(['1 Angle [',prefixStrings{3,1},'^{\circ}]']) ;
  xlabel('CCD #') ;
  
  subplot(3,2,2)
  title('Uncertainties in 3-2-1 Xfrm Angles')
  ylabel(['3 Angle [',prefixStrings{1,2},'^{\circ}]']) ;
  subplot(3,2,4) 
  ylabel(['2 Angle [',prefixStrings{2,2},'^{\circ}]']) ;
  subplot(3,2,6) 
  ylabel(['1 Angle [',prefixStrings{3,2},'^{\circ}]']) ;
  xlabel('CCD #') ;
  
% and that's it!

%
%
%

%=========================================================================================