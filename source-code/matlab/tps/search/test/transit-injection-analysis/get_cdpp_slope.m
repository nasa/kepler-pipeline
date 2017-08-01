function cdppSlope = get_cdpp_slope(rmsCdpp2,rmsCdpp1)

% Function get_cdpp_slope, for each target
% Inputs: 
%   rmsCdpp2 (from DV) -- nStars x nPulses double
%   notValidRmsCdpp -- from DV
%   rmsCdpp1 (from TPS) -- nStars x nPulses double
%   notValidRmsCdpp -- from TPS
% Output: fitted slope of rmsCdpp vs right-hand section of pulseDurationsHours
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

% Pulse durations in hours
pulseDurationsHours = [1.5, 2.0, 2.5, 3.0, 3.5, 4.5 , 5.0, 6.0, 7.5, 9.0, 10.5, 12.0, 12.5, 15.0];

% Pulse range for fit
% Last 6 pulses for consistency with Chris Burke
pulseIndexRange = 9:14;

% Number of targets
nTargets = size(rmsCdpp2,1);

% robustfit inputs
xFeatures = log10(pulseDurationsHours(1,pulseIndexRange)');

% Use robust regression
parameters = zeros(nTargets,2);
stats = cell(1,nTargets);
for iTarget = 1:nTargets
    
    % Logic:
    % If any rmsCdpp2 in range of pulseIndexRange have values of -1,
    %   then
    %       if any of rmsCdpp1 have values of -1, return parameters = NaN
    %       else use rmsCdpp1 instead of rmsCdpp2
    %   else use rmsCdpp2
    
    % set robustfit inputs
    if(any( rmsCdpp2(iTarget,pulseIndexRange) == -1 ) )
        fprintf('Target %d has -1s in last 6 pulse lengths of rmsCdpp2\n',iTarget)
        if( any( rmsCdpp1(iTarget,pulseIndexRange) == -1 ) )
            fprintf('%d has -1s in rmsCdpp1\n',iTarget)
            parameters(iTarget,:) = [NaN,NaN];
        else
            yTarget = log10(rmsCdpp1(iTarget,pulseIndexRange)') ;
            % Robustfit defaults to including an offset and a slope in the fit
            % !!!!! Switching to ordinary least squares, since robustfit was generating
            % frequent warnings about iteration limits
            [parameters(iTarget,:), stats{iTarget}] = robustfit(xFeatures,yTarget,'ols');
        end
    else
        yTarget = log10(rmsCdpp2(iTarget,pulseIndexRange)') ;
        % Robustfit defaults to including an offset and a slope in the fit
        % !!!!! Switching to ordinary least squares, since robustfit was generating
        % frequent warnings about iteration limits
        [parameters(iTarget,:), stats{iTarget}] = robustfit(xFeatures,yTarget,'ols');
    end
    
    % Indicate progress
    if mod(iTarget,1000) == 0
        fprintf('Target %d\n',iTarget);
    end
    
end % for

% cdpp offset and slope
% cdppOffset = parameters(:,1);
cdppSlope = parameters(:,2);


