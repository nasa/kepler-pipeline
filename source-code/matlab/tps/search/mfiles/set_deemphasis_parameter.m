function deemphasisParameter = set_deemphasis_parameter( dataGapLocations, ...
    deemphasisIntervalInCadences, nCadences )
%
% set_deemphasis_parameter -- set the deemphasis parameter for cadences which surround an
% anomalous cadence of some type, using the requested deemphasis interval
%
% demphasisParameter = set_deemphasis_parameter( dataGapLocations,
% deemphasisIntervalInCadences, nCadences ) sets the deemphasisParameter to a vector of
% 1's, with length nCadences, except for cadences indicated by dataGapLocations (set to
% zero), or cadences within deemphasisIntervalInCadences of a dataGapLocation (set to a
% ramp from zero at the dataGapLocation to 1 deemphasisIntervalInCadences away from it).
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

% default initializaton

  deemphasisParameter = ones( nCadences, 1 ) ;
  
% construct the vectors of ramping deemphasis parameter values

  stepSize = 1 / deemphasisIntervalInCadences ;
  deemphasisRampEarly = 1:-stepSize:stepSize ;
  deemphasisRampLate  = fliplr( deemphasisRampEarly ) ;
  deemphasisRampEarly = deemphasisRampEarly(:) ;
  deemphasisRampLate  = deemphasisRampLate(:) ;
  
  
%  nRegions = length( dataGapLocations ) ;
  nRegions = size( dataGapLocations, 1 ) ;
  
  if (nRegions > 0)

%     we will populate a matrix of deemphasis parameter values, one column from each data
%     gap location -- remember to handle the special case where a datagap is close to the
%     start or end of the time series
      
      deemphasisParameterMatrix = ones( nCadences, nRegions ) ;
      for iRegion = 1:nRegions
          
          regionStart = dataGapLocations( iRegion, 1 ) ;
          regionStop  = dataGapLocations( iRegion, 2 ) ;
          deemphasisParameterMatrix( regionStart:regionStop, iRegion ) = 0 ;
          nEarlyCadences = min( regionStart-1, deemphasisIntervalInCadences ) ;
          deemphasisParameterMatrix( regionStart-nEarlyCadences:regionStart-1, iRegion ) = ...
              deemphasisRampEarly(deemphasisIntervalInCadences-nEarlyCadences+1:end) ;
          nLateCadences  = min( nCadences-regionStop, deemphasisIntervalInCadences ) ;
          deemphasisParameterMatrix( regionStop+1:regionStop+nLateCadences, iRegion ) = ...
              deemphasisRampLate(1:nLateCadences) ;
          
      end
      
%     take the minimum value across the columns to use as the deemphasis parameter for
%     this set of data gaps
      
      deemphasisParameter = min( deemphasisParameterMatrix, [], 2 ) ;
      
  end
  
return


