function y = generalized_complementary_error_function( params, x, fitInLogSpace )
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% This function builds a generalized complementary error function
%
% Inputs: x - values of x to generate the functional values for
%
%         erfParams - These parameters control the function being built.
%         There are 4 total potential parameters and two of them relate to
%         the mean and standard deviation of a gaussian distribution.
%            params(1): 1 / (sigma * sqrt(2))
%            params(2): mean / (sigma * sqrt(2))
%            params(3): scale parameter equal to 0.5 for gaussian cdf
%            params(4): a shift parameter to completely generalize
%         Minimally, the first two parameters must be specified, in which
%         case params(3) is set to 0.5 and params(4) is set to zero.  If
%         three parameters are specified, then params(4) is set to zero.
%
%         fitInLogSpace - a boolean to specify whether to take the log
%         (useful when you are doing a fit and want to emphasize the tail
%         of a distribution)
%
% Outputs: y - the function values
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
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

% check inputs
if ~exist('params','var') || isempty(params) || length(params) <2
    error('generalized_complementary_error_function:paramsIncorrectlySpecified', ...
        'The params must be specified and have a length of at least 2!' ) ;
end

if ~exist('fitInLogSpace', 'var') || isempty(fitInLogSpace)
    fitInLogSpace = true;
end

% handle optional specifications of params
if isequal(length(params),2)
    params(3) = 0.5;
    params(4) = 0;
elseif isequal(length(params),3)
    params(4) = 0;
end

% compute functional values
if ~fitInLogSpace
    y = params(4) + params(3) * erfc( params(1) * x - params(2) ) ;
else
    y = log10( params(4) + params(3) * erfc( params(1) * x - params(2) ) );
end

return

% seed with [1/sqrt(2), 0, 0.5, 0] for standard normal
