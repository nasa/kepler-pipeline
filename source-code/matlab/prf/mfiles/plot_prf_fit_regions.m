function prfRegionPlotHandle = plot_prf_fit_regions( prfStructureVector )
%
% plot_prf_fit_regions -- plot the regions used to fit the PRFs on a given module /
% output.
%
% prfRegionPlotHandle = plot_prf_fit_regions( prfStructureVector ) plots the regions used
%    for fitting each PRF in a given module/output, given as input the prfStructureVector
%    which is produced as a diagnostic during PRF fitting.
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
%     2008-October-14, PT:
%         add the region number to each region rectangle.
%     2008-October-06, PT:
%         capitalize axis labels and add units.
%
%=========================================================================================

% set the list of colors

  colorList = 'bgymc' ;
  figure ;
  
% loop over fits, plotting the rectangles in the different colors, and plotting the
% locations of the fits

  for iRegion = 1:length(prfStructureVector)
      row = prfStructureVector(iRegion).prfPolyStructure.row ;
      column = prfStructureVector(iRegion).prfPolyStructure.column ;
      rowLimit = prfStructureVector(iRegion).prfPolyStructure.prfConfigurationStruct.rowLimit ;
      columnLimit = prfStructureVector(iRegion).prfPolyStructure.prfConfigurationStruct.columnLimit ;
      
      rowSize = rowLimit(2) - rowLimit(1) ;
      columnSize = columnLimit(2) - columnLimit(1) ;
      rowCenter = mean(rowLimit) ; 
      columnCenter = columnLimit(2) + 0.1 * columnSize ;
      
      rectangle( 'Position',[columnLimit(1) rowLimit(1) columnSize rowSize ], ...
          'FaceColor',colorList(iRegion) ) ;
      
      hold on
      plot(column,row,'ks') ;
      h = text(columnCenter,rowCenter,num2str(iRegion)) ;
      set(h,'FontWeight','bold') ;
      set(h,'FontSize',12) ;
      
  end
  

% add some labels and stuff

  xlabel('Column [pixels]')
  ylabel('Row [pixels]')
  title('Regions Used for PRF Fits')

% get the plot handle

  prfRegionPlotHandle = gcf ;
  
% and that's it!

%
%
%