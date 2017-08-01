%% model_subset 
% Method for content selection of a ModelComponent class object as a 
% function of channel. Used to exclude scene dependent regions from fits.
% Also ensures that fit matrix has no all-zero columns using Subset_predictor_index.
% This reduces but doesn't eliminate possibility of rank deficiency.
% We could fit using the SVD of a rank deficient matrix but haven't implemented that yet. 
% obj.Matrix must be externally defined prior to calling model_subset.
%
%   Revision History:
%
%       Version 0 - 9/18/10     released for Science Office use
%
% 
% <html>
% <style type="text/css"> pre.codeinput {background: #FFFF66; padding: 30px;} </style>
% </html>
% 
%
%%
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
function obj = model_subset(obj, channel_count, subset_index)
%% ARGUMENTS
% 
% * Function returns: obj - initialized object of class DataSubset.
% * Function arguments:
% * |channel_count  -| number of channels in channel list
% * |subset_index   -| a channel_count x obj.Datum_count logical selection matrix
%
%% CODE
%
obj.Subset_datum_index      = subset_index;
obj.Subset_datum_count      = zeros(channel_count,1);
obj.Subset_predictor_index  = false(channel_count,obj.Predictor_count);
obj.Subset_predictor_count  = zeros(channel_count,1);

for k=1:channel_count
   subset_matrix1                   = squeeze(obj.Matrix(k,:,subset_index(k,:)));
   obj.Subset_datum_count(k)        = size(subset_matrix1,2);
   obj.Subset_predictor_index(k,:)  = any(subset_matrix1,2); % selects columns containing nonzero values
   subset_matrix2                   = subset_matrix1(obj.Subset_predictor_index(k,:),:);
   obj.Subset_predictor_count(k)    = size(subset_matrix2,1);
end

return
    
end