function [timeseriesArray] = add_bias_to_timeseries(timeseriesArray, addValue)
%
% function [timeseriesArray] = add_bias_to_timeseries(timeseriesArray, addValue)
% 
% Add the value in 'addValue' to the values field in each of the timeseries
% contained in the array 'timeseriesArray'. If 'addValue' is a scalar then
% this scalar value is added to each time element in each timeseries. If
% 'addValue' is a column vector it must have length equal to the number of
% elements in any one timeseriesArray element 'values'. If addValue is a
% row vector it must have length equal to the number of elements in
% timeseriesArray. If addValue is a metrix it must have dimension nCadences
% x nTimeseries. Each timeseries is assumed to have the following fields at
% a minimum:
% timeseries.values
%           .gapIndicators
%
% Only the values field is updated. All other fields are left unchanged.
% Only ungapped values are considered valid. Any NaNs are treated as gaps. 
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

% extract values and gaps as 2D array
values = [timeseriesArray.values];
gaps = [timeseriesArray.gapIndicators];

% get dimensions
[nCadences, nTimeseries] = size(values);

% save gapped values
% set gapped values equal to NaN in original array
tempGapValues = values(gaps);
values(gaps) = NaN;

% reshape addValue depending on input shape
if(isscalar(addValue))
    addValue = ones(size(values)) .* addValue;
elseif(iscolvector(addValue))
    addValue = repmat(addValue,1,nTimeseries);
elseif(isrowvector(addValue))
    addValue = repmat(addValue,nCadences,1);
end

% add bias term
values = values + addValue;

% restore gapped values
values(gaps) = tempGapValues;

% deal back into timeseries array
valuesCellArray = num2cell(values,1);
[timeseriesArray.values] = deal(valuesCellArray{:});
