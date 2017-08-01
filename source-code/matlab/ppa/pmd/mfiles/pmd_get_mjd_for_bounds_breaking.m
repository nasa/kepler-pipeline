function [xAxisLabels,yValues] = pmd_get_mjd_for_bounds_breaking( report, boundsType, ...
    plotRegion ) 
%
% pmd_get_mjd_for_bounds_breaking -- extract the predicted mjds for bounds breaking from
% the PMD reports structure.
%
% [xAxisLabels,yValues] = pmd_get_mjd_for_bounds_breaking(report,boundsType,plotRegion)
%    gets the MJDs for bounds-breaking from the pmdOutputStruct report field.  Argument
%    boundsType can be 0 or 1, indicating adaptive or fixed bounds, respectively.
%    Argument plotRegion can be 1 through 6.  The meaning of these regions is as follows:
%
%    1 == upper left quadrant of dashboard plot (black level, etc)
%    2 == upper right quadrant of dashboard plot (LDE undershoot, 2DBlack)
%    3 == lower left quadrant of dashboard plot (CR metrics)
%    4 == CDPP metrics, 3 hour
%    5 == CDPP metrics, 6 hour
%    6 == CDPP metrics, 12 hour
%
% Version date:  2008-October-17.
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

% based on the boundsType, set the bounds report that we will look for

  if (boundsType == 0)
      boundsReport = 'adaptiveBoundsReport.crossingTime' ;
  else
      boundsReport = 'fixedBoundsReport.crossingTime' ;
  end
  
% based on the plotRegion value, set the values of the axis labels and the names of the
% fields that we shall search

  [xAxisLabels, fieldNames] = get_report_field_names( plotRegion ) ;
  
  yValues = zeros(length(fieldNames),1) ;
% loop over field names and extract values

if ~( plotRegion==2 && isempty(report.ldeUndershoot) )
    
    for iValue = 1:length(yValues)
        cmdstr = ['yValues(iValue) = report.',fieldNames{iValue},'.',boundsReport,' ;'] ;
        eval(cmdstr) ;
    end
    
end

% and that's it!

%
%
%

%=========================================================================================

% subfunction to set the axis labels and field names

function [xAxisLabels, fieldNames] = get_report_field_names( plotRegion )

% this is just a big switch statement

  switch plotRegion
      
      case 1 % upper-left corner of dashboard:  general metrics
          
          xAxisLabels = {'black',  'smear',  'dark',...
                         'bright', 'encirc', 'bkgd',...
                         'row',    'col',    'plate',...
                         'TheoCE', 'AchCE'                } ;
         fieldNames = {'blackLevel','smearLevel','darkCurrent', ...
             'brightness','encircledEnergy','backgroundLevel', ...
             'centroidsMeanRow','centroidsMeanColumn','plateScale', ...
             'theoreticalCompressionEfficiency','achievedCompressionEfficiency' } ;
         
      case 2 % upper-right corner of dashboard:  LDE Undershoot and 2DBlack metrics

          % There were 3 LDE targets and 4 2D black targets...
          xAxisLabels = {'lde1'} ;
          fieldNames = {'ldeUndershoot(1)'} ;
          
      case 3 % lower-left corner of dashboard:  cosmic ray metrics
          
          metricType = {'HitRate' ;'Mean' ;'Var'} ;
          metricArea = {'blk','msk','virt','targ','bkgd'} ;
          metricTypeAll = repmat(metricType,5,1) ;
          metricAreaAll = repmat(metricArea,3,1) ;
          metricAreaAll = metricAreaAll(:) ;
          
          for count = 1:15
              xAxisLabels{count} = [metricAreaAll{count},metricTypeAll{count}] ;
          end
          
          metricType = {'hitRate';'meanEnergy';'energyVariance'} ;
          metricArea = {'black','maskedSmear','virtualSmear','targetStar','background'} ;
          metricTypeAll = repmat(metricType,5,1) ;
          metricAreaAll = repmat(metricArea,3,1) ;
          metricAreaAll = metricAreaAll(:) ;

          for count = 1:15
              fieldNames{count} = [metricAreaAll{count},'CosmicRayMetrics.', ...
                  metricTypeAll{count}] ;
          end
          
      case {4,5,6} % CDPP metrics
          
          metricType = {'Meas' ; 'Exp' ; 'Rat'} ;
          metricMag  = {'Mag09' , 'Mag10' , 'Mag11' , 'Mag12' , 'Mag13' , ...
              'Mag14' , 'Mag15'} ;
          metricTypeAll = repmat(metricType,7,1) ;
          metricMagAll  = repmat(metricMag, 3,1) ;
          metricMagAll = metricMagAll(:) ;
          
          if (plotRegion == 4)
              timeStr = '3hr' ;
          elseif (plotRegion == 5)
              timeStr = '6hr' ;
          else
              timeStr = '12hr' ;
          end
          for count = 1:21
              xAxisLabels{count} = [timeStr,metricTypeAll{count},metricMagAll{count}] ;
          end
          
          metricType = {'cdppMeasured' ; 'cdppExpected' ; 'cdppRatio'} ;
          metricMag  = {'mag9' , 'mag10' , 'mag11' , 'mag12' , 'mag13' , ...
              'mag14' , 'mag15'} ;
          metricTypeAll = repmat(metricType,7,1) ;
          metricMagAll  = repmat(metricMag, 3,1) ;
          metricMagAll = metricMagAll(:) ;
          
          if (plotRegion == 4)
              timeStr = 'threeHour' ;
          elseif (plotRegion == 5)
              timeStr = 'sixHour' ;
          else
              timeStr = 'twelveHour' ;
          end
          
          for count = 1:21
              fieldNames{count} = [metricTypeAll{count},'.', ...
                  metricMagAll{count},'.',timeStr] ;
          end

      otherwise % error
          
          error('pmd:pmdGetMjdForBoundsBreaking:badPlotRegion', ...
              'pmd_get_mjd_for_bounds_breaking:  invalid plotRegion specified') ;
          
  end % switch statement