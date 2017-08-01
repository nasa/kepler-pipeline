function quarterStitchingObject = undo_median_normalization( quarterStitchingObject )
%
% undo_median_normalization -- remove median normalization of time series
%
% quarterStitchingObject = undo_median_normalization( quarterStitchingObject ) uses the
%    medianValue field in the timeSeriesStruct member of the quarterStitching object to
%    remove the median normaliztion from each time series, quarter-by-quarter.  This is
%    done only when medianNormalizationFlag is set to false; for medianNormalizationFlag
%    set to true, no action is taken.
%
% Version date:  2011-July-28.
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
%    2011-July-28, PT:
%        Use abs(median) to undo normalization, as that is now what is used to perform
%        normalization, per KSOC-1745.
%
%=========================================================================================

% do this only if median normalization was not originally requested

  if ~quarterStitchingObject.quarterStitchingParametersStruct.medianNormalizationFlag
      
%     loop over targets and segments and remove the normalization
      
      for iTarget = 1:length( quarterStitchingObject.timeSeriesStruct )
          
          thisTimeSeriesStruct = quarterStitchingObject.timeSeriesStruct(iTarget) ;
          for iSegment = 1:length( thisTimeSeriesStruct.dataSegments )
              
              segmentStart = thisTimeSeriesStruct.dataSegments{iSegment}(1) ;
              segmentEnd   = thisTimeSeriesStruct.dataSegments{iSegment}(2) ;
              medianValue = abs(thisTimeSeriesStruct.medianValues(iSegment)) ;
              if medianValue > sqrt(eps('double'))
                  thisTimeSeriesStruct.values(segmentStart:segmentEnd) = ...
                      thisTimeSeriesStruct.values(segmentStart:segmentEnd) * ...
                      medianValue ;
                  thisTimeSeriesStruct.uncertainties(segmentStart:segmentEnd) = ...
                      thisTimeSeriesStruct.uncertainties(segmentStart:segmentEnd) * ...
                      medianValue ;
              end
              
          end
          quarterStitchingObject.timeSeriesStruct(iTarget) = thisTimeSeriesStruct ;
          
      end
      
  end

return

