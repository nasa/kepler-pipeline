function clusterOut = combine_nearby_clusters( clusterIn, clusterProximity )
%
% combine_nearby_clusters -- take clusters of integer values which are close to one
% another and combine them
%
% clusterOut = combine_nearby_clusters( clusterIn, clusterProximity ) takes as input the
%    first output of identify_contiguous_integer_values and a scalar integer-valued
%    argument which defines "nearby."  The clusters which are nearby one another as
%    defined by this argument are combined into a single cluster.  The consolidated
%    clusters are returned to the caller.  The returned cluster cell array is either a row
%    vector or column vector, depending on the shape of clusterIn; similarly, each cluster
%    is either a row- or column-vector.
%
% Version date:  2011-January-05.
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

% default is a column vector.  If the 2nd dimension of clusterIn is 1, then it's either a
% row vector of cells or a single cell.  

  isRowVector = size( clusterIn, 2 ) > 1 ;
  
  clusterOut{1} = clusterIn{1} ;
  nClusterOut   = 1 ;  
  
  for iCluster = 2:length(clusterIn)
      
%     look to see whether each cluster in the input needs to go into a new cluster in the
%     output, or needs to be appended to the old one; while we loop through, look to see
%     if any of the existing clusters are row vectors
      
      thisCluster = clusterIn{iCluster} ;
      if thisCluster(1) <= clusterOut{nClusterOut}(end) + clusterProximity + 1
          clusterOut{nClusterOut} = [clusterOut{nClusterOut}(:) ; thisCluster(:)] ;
      else
          nClusterOut = nClusterOut + 1 ;
          clusterOut{nClusterOut} = thisCluster ;
      end
  end
  
% by default convert to a column vector  
  
  clusterOut = clusterOut(:) ;
  
% if it's a row vector, convert everything to the correct shape  
  
  if isRowVector
      clusterOut = clusterOut' ;
      for iCluster = 1:length(clusterOut)
          clusterOut{iCluster} = clusterOut{iCluster}' ;
      end
  end
      

return

