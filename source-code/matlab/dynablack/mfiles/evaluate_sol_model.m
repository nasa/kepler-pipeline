function fittedCurves = evaluate_sol_model( solCoefficients, oneBasedColumns, varargin)
%
% function fittedCurves = evaluate_sol_model( solCoefficients, oneBasedColumns, varargin)
%
% This function evaluates the start of line ringing model for the channels requested as
% an optional list in varargin. The default is to return evaluated models for all 84 
% channels in an nChannel x nColumns array. 
%
% Based on apply_sol_model.m delivered with the dynablack prototype.
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



% check for variable arguments
channelList = 1:84;
if( nargin > 2)
    channelList = varargin{1};
end


% Assume sol ringing model is an n-exponential fit with 4 parameters per exponential
% and that the coefficients are arranged in the following order
paramsPerComponent = 4;

amplitudeIdx = 1;
expScaleIdx  = 2;
sineScaleIdx = 3;
sinePhaseIdx = 4;

% allocate space
fittedCurves = zeros(length(channelList),length(oneBasedColumns));

% evaluate model for each channel
channelIdx = 0;
for iChannel = rowvec(channelList)
    
    channelIdx = channelIdx +1;
    
    % Extract parameters for this channel
    A      = solCoefficients(iChannel,amplitudeIdx:paramsPerComponent:end);
    xScale = abs(solCoefficients(iChannel,expScaleIdx:paramsPerComponent:end));
    lambda = solCoefficients(iChannel,sineScaleIdx:paramsPerComponent:end);
    phi    = solCoefficients(iChannel,sinePhaseIdx:paramsPerComponent:end);
    
    % evaluate the model for each exponential component and sum
    accum = zeros(1,length(oneBasedColumns));
    for i=1:length(A)
        accum = accum + (A(i).*exp(-oneBasedColumns./xScale(i))) .* sin( 2.*pi.*(oneBasedColumns./lambda(i)) + phi(i));
    end
    
    fittedCurves(channelIdx,:) = accum;
    
end
