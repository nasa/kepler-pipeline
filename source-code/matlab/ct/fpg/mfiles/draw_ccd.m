function draw_ccd( ccdList )
%
% DRAW_CCD draw the outline of one or more CCDs on the focal plane
%
% draw_ccd( ccdList ) draws the outlines of the list of requested CCDs on a common set of
%    axes.  The coordinates are pixels in the Z'-Y' plane.
%
% Version date:  2009-September-19.
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
%     2008-September-19, PT:
%         changes in support of one-based coordinates.
%     2008-June-24:
%         bugfix:  change ccdlist to ccdList (camel case).
%
%=========================================================================================

% get the module and both outputs on each CCD

  [module,outOdd]  = convert_to_module_output( 2*ccdList-1 ) ;
  [module,outEven] = convert_to_module_output( 2*ccdList   ) ;
    
% loop over CCDs

  for iCCD = 1:length(ccdList)
      
%     get the edges of the CCD in MORC coordinates.  The rows go from 1 to 1044, so the
%     edges of the CCD are rows 0.5 to 1044.5.  Similarly, the edges of the true CCD in
%     column space are all at column 12.5 (outermost edge of column 13, since columns 1 to
%     12 don't actually exist).  
      
      modlist = [module(iCCD) module(iCCD) module(iCCD) module(iCCD)] ;
      outlist = [outOdd(iCCD) outOdd(iCCD) outEven(iCCD) outEven(iCCD)] ;
      rowlist = [0.5 1044.5 1044.5 0.5] ;
      collist = [12.5 12.5 12.5 12.5] ;
      
%     convert the MORC coordinates of the CCD to the global focal plane coordinates
      
      [z,y] = morc_to_focal_plane_coords(modlist,outlist,rowlist,collist,'one-based') ;
      
%     use convhull to order the box edges, and plot the box      
      
      pointIndex = convhull(z,y) ;
      plot(z(pointIndex),y(pointIndex),'k') ;
      hold on
      
  end
  
  hold off
  
% and that's it!

%
%
%
