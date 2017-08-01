function pad_draw_ccd( ccdList )
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function pad_draw_ccd( ccdList )
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% This function, modified from draw_ccd, draws the outline of one or more CCDs on the focal plane.
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
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

% get the module and both outputs on each CCD

  [module,outOdd]  = convert_to_module_output( 2*ccdList-1 );
  [module,outEven] = convert_to_module_output( 2*ccdList   );
    
% loop over CCDs

  for iCCD = 1:length(ccdList)
      
%     get the edges of the CCD in MORC coordinates.  The rows go from 0 to 1043, so the
%     edges of the CCD are rows -0.5 to 1043.5.  Similarly, the edges of the true CCD in
%     column space are all at column 11.5 (outermost edge of column 12, since columns 0 to
%     11 don't actually exist).  
      
%     modlist = [module(iCCD) module(iCCD) module(iCCD) module(iCCD)] ;
%     outlist = [outOdd(iCCD) outOdd(iCCD) outEven(iCCD) outEven(iCCD)] ;
%     rowlist = [-0.5 1043.5 1043.5 -0.5] ;
%     collist = [11.5 11.5 11.5 11.5] ;

      modlist     = [module(iCCD)  module(iCCD)  module(iCCD)  module(iCCD)];
      outOddList  = [outOdd(iCCD)  outOdd(iCCD)  outOdd(iCCD)  outOdd(iCCD)];
      outEvenList = [outEven(iCCD) outEven(iCCD) outEven(iCCD) outEven(iCCD)];
      rowlist     = [ 0  1043  1043    0];
      collist     = [12    12  1111 1111];
      
%     convert the MORC coordinates of the CCD to the global focal plane coordinates
      
      [zOdd, yOdd]  = morc_to_focal_plane_coords(modlist,outOddList, rowlist,collist, 'one-based');
      [zEven,yEven] = morc_to_focal_plane_coords(modlist,outEvenList,rowlist,collist, 'one-based');
      
%     use convhull to order the box edges, and plot the box      
      
      pointIndex = convhull(zOdd,yOdd);
      plot(zOdd(pointIndex), yOdd(pointIndex), 'k');
      hold on
      pointIndex = convhull(zEven,yEven);
      plot(zEven(pointIndex),yEven(pointIndex),'k');
      axis('equal');
      
  end
  
% hold off
  
% and that's it!

%
%
%
