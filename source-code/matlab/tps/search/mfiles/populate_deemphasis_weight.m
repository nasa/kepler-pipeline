function tpsResult = populate_deemphasis_weight( tpsResult, superResolutionFactor, ...
    cadencesToDeemphasize )
%
% populate_deemphasis_weight -- set the tpsResult deemphasis weight vectors
%
% tpsResult = populate_deemphasis_weight( tpsResult, superResolutionFactor, 
%    cadencesToDeemphasize ) sets the tpsResult vectors deemphasisWeightSuperResolution
%    and deemphasisWeight.  The tpsResult deemphasisParameter vector is used for this
%    purpose, as is the list of cadencesToDeemphasze in the input arguments.  Note that,
%    since the deemphasisParameter vector is not updated with the list of cadences which
%    are deemphasized, this function allows the user to set a "custom" list of deemphasis
%    weights which includes a "permanent" list of deemphasized cadences (in the
%    deemphasisParameter vector in tpsResult) and a "temporary" set (in the
%    cadencesToDeemphasize vector).
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

%=========================================================================================

% construct the regular and super-resolution parameter vectors using the permanent
% parameter values and the local deemphais vector

  if ~exist( 'cadencesToDeemphasize', 'var' ) 
      cadencesToDeemphasize = [] ;
  end
  [deemphasisParameterSuperResolution, deemphasisParameter] = ...
      collect_cadences_to_deemphasize( tpsResult.deemphasisParameter, ...
      superResolutionFactor, cadencesToDeemphasize ) ;
  
% now set the weights based on the local vectors, which include both permanent and
% temporary deemphasis locations

  tpsResult.deemphasisWeightSuperResolution = ...
    convert_deemphasis_parameter_to_weight( deemphasisParameterSuperResolution ) ;
  tpsResult.deemphasisWeight = ...
    convert_deemphasis_parameter_to_weight( deemphasisParameter ) ;


return

