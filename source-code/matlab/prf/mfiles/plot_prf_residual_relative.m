function residualRelativePlotHandle = plot_prf_residual_relative( row, column, ...
    value, residuals, rowSize, columnSize )
%
% residualRelativePlotHandle = plot_prf_residual_relative( row, column, residuals,
%    rowSize, colSize plots the fit residuals for a PRF as a set of color-coded dots
%    representing the residual of each pixel used in the fit relative to the RMS width of
%    the distribution. The color code is as follows:
%
%    Green dot  ==                    |residual| <= 1 * std(residuals)
%    Blue dot   == 1*std(residuals) < |residual| <= 2 * std(residuals)
%    Yellow dot == 2*std(residuals) < |residual| <= 3 * std(residuals)
%    Red dot    == 3*std(residuals) < |residual|
%
% Arguments rowSize and columnSize indicate the # of pixels that the PRF is fitted over in
% row and in column, respectively (typically this is 11 x 11).  These arguments are
% optional.  Row and column are in "prf natural units" -- the minimum possible row or
% column value is 0.5, the center of the first row/column pixel is at 1.0, etc.
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

% assign rowSize and columnSize if they are absent; if they are present, increment by 1,
% since 11 rows of pixels ==> the max pixel "row" value is 11.5, etc.

  if (nargin < 5)
      rowSize = ceil(max(row)) ;
  else
      rowSize = rowSize + 1 ;
  end
  if (nargin < 6)
      columnSize = ceil(max(column)) ;
  else
      columnSize = columnSize + 1 ;
  end
  
  residuals = residuals ./ value ;
  
% compute a poor man's RMS for non-Gaussian distributions -- find the values which contain
% 68% of the data, half the difference between them, and that's the RMS

  sortedResiduals = sort(residuals) ;
  residualLowIndex = round(0.17 * length(residuals)) ;
  residualHighIndex = round(0.83 * length(residuals)) ;
  residualRMS = 0.5*(sortedResiduals(residualHighIndex)-sortedResiduals(residualLowIndex)) ;
  disp(residualRMS) ;
  
% perform the first plot, including setting the plot limits

  plotIndices = find( abs(residuals) <= residualRMS );
  plot(column(plotIndices), row(plotIndices), 'g.') ;
  axis([0 columnSize 0 rowSize]) ;
  xlabel('Column [pixels]') ;
  ylabel('row [pixels]') ;
  title('PRF Fit Pixel Relative Quality Display') ;
  hold on
  
% second plot

  plotIndices = find( residualRMS < abs(residuals) & abs(residuals) <= 2*residualRMS );
  plot(column(plotIndices), row(plotIndices), 'b.') ;
  
% third plot

  plotIndices = find( 2*residualRMS < abs(residuals) & abs(residuals) <= 3*residualRMS );
  plot(column(plotIndices), row(plotIndices), 'y.') ;

% fourth plot

  plotIndices = find( 3*residualRMS < abs(residuals) );
  plot(column(plotIndices), row(plotIndices), 'r.') ;
  
% legend

  legend('0->1\sigma','1\sigma->2\sigma','2\sigma->3\sigma','>3\sigma') ;
  
% return the plot handle

  residualRelativePlotHandle = gcf ; 
