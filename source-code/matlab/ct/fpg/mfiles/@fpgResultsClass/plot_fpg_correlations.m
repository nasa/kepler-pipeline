function [figureHandleImage, figureHandle3D, figureHandleGlobal] = plot_fpg_correlations( ...
    fpgResultsObject )
%
% plot_fpg_correlations -- produce plots related to the internal correlations of the FPG
% fit
%
% [h1, h2, h3] = plot_fpg_correlations( fpgResultsObject ) returns the figure handles of 3
%    Matlab figures:  an image which uses false-color (greyscale, actually) to represent
%    the correlations between the FPG parameters; a 3-D plot of the correlations; and a
%    bar graph of the global correlation coefficients of the FPG parameters.
%
% Version date:  2009-May-02.
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
%    2009-May-02, PT:
%        support for multiple plate scale / pincushion parameters
%    2009-April-23, PT:
%        support for pincushion parameter.
%
%=========================================================================================

% generate the correlation matrix

  fpgFitObject = fpgResultsObject.fpgFitClass ;
  correlationMatrix = covariance_to_correlation( get(fpgFitObject,'parValueCovariance' ) );
  
% find the necessary boundaries between different parameter types

  lastGeometryParameter = max(get(fpgFitObject,'geometryParMap')) ;
  plateScaleParameter = get(fpgFitObject,'plateScaleParMap') ;
  pointingParameters = [get(fpgFitObject,'cadenceRAMap') ...
                        get(fpgFitObject,'cadenceDecMap') ...
                        get(fpgFitObject,'cadenceRollMap')] ;
  firstPointingParameter = min(pointingParameters) ;
  lastPointingParameter  = max(pointingParameters) ;
  numParameters = size(correlationMatrix,1) ;
                            
%=========================================================================================
% plot the image first
%=========================================================================================
  
  figure ;
  colormap gray ;
  imagesc(correlationMatrix) ;
  hold on
  
% draw the lines between the different parameter families

  if any(plateScaleParameter ~= 0) 
      
      plot([min(plateScaleParameter(:)) - 0.5 min(plateScaleParameter(:)) - 0.5], ...
           [0.5 numParameters + 0.5],'r') ;
      plot([0.5 numParameters + 0.5], ...
          [min(plateScaleParameter(:)) - 0.5 min(plateScaleParameter(:)) - 0.5],'r') ;
      
  end
  
  if (lastPointingParameter ~= 0)
      
      lowLimit = max(lastGeometryParameter, max(plateScaleParameter(:))) ;
      plot([lowLimit + 0.5 lowLimit + 0.5],[0.5 numParameters + 0.5],'r') ;
      plot([0.5 numParameters + 0.5],[lowLimit + 0.5 lowLimit + 0.5],'r') ;
      
  end
      
  colorbar ;
  hold off
  title('FPG Fit Paramater Correlations') ;
  figureHandleImage = gcf ;
  
%=========================================================================================
% plot the 3-D plot
%=========================================================================================

  figure ; surf(correlationMatrix) ; title('FPG Fit Parameter Correlation') ;
  figureHandle3D = gcf ;

%=========================================================================================
% plot the global correlations
%=========================================================================================

% get the correlation coefficients

  rho = global_correlation( get(fpgFitObject,'parValueCovariance' ) ) ;
  
% produce the bar plot

  figure ;
  bar(rho) ;
  hold on
  title('FPG Fit Parameter Total Correlation') ;
  
% draw lines to indicate the division between different types of parameters
                            
  if any(plateScaleParameter ~= 0)
      
      plot([min(plateScaleParameter(:)) - 0.5 min(plateScaleParameter(:)) - 0.5],[0 1],'r') ;
      
  end
  
  if (lastPointingParameter ~= 0)
      
      lowLimit = max(lastGeometryParameter, max(plateScaleParameter(:))) ;
      plot([lowLimit + 0.5 lowLimit + 0.5],[0 1],'r') ;
      
  end
  hold off
  figureHandleGlobal = gcf ;
  
% and that's it!

%
%
%
