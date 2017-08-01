%% smooth_vsLC
% smoothing routine for DynOBlack parameters which vary smoothly
% but do not produce good fits to temperature and/or time
%
%   Revision History:
%
%       Version 0 - 2/9/10      released for review and comment
%       Version 1 - 4/19/10     Changed interface structures, removed globals
%                               Modified classes for pre-MATLAB V7.6
%                               Added call to FGS_States instead of reading Mathematica output files
% 
% <html>
% <style type="text/css"> pre.codeinput {background: #FFFF66; padding: 30px;} </style>
% </html>
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
function smoothed_vector = smooth_vsLC( input_vector, predictors, interval_starts, interval_ends )
%% ARGUMENTS
% 
% * Function returns: 
% * |smoothed_vector| - smoothed result locally fit to predictors.
% * Function arguments:
% * |input_vector -| data to be smoothed 
% * |predictors -| temperature and time vectors
% * |interval_starts -| locations in input_vector where stepwise intervals start
% * |interval_ends -| locations in input_vector where stepwise intervals end
%
%% LOCAL CONSTANTS
%

lc_max             =  interval_ends(end);
fitRange_max       =  floor(lc_max/400)*100;
fitRange           =  [20, 50, (100:100:fitRange_max)];
range_count        =  length(fitRange);
stdDev_resid       =  zeros(range_count,1);
smoothed_results   =  zeros(range_count,lc_max);
ref_noise          =  std(diff(input_vector))/sqrt(2);
noise_threshold    =  1.5*ref_noise;

%% SMOOTHING 
%

for rangeID=1:range_count
    this_fitRange  =  fitRange(rangeID);
    fitWidth       =  2*this_fitRange+1;
    kernels        =  zeros(lc_max,fitWidth);
    segments       =  zeros(fitWidth,lc_max);

%%
%
   
    for lcID=1:lc_max
        firstLC     =   max(lcID-this_fitRange,1);
        lastLC      =   min(lcID+this_fitRange,lc_max);
        LC_count    =   lastLC-firstLC+1;
        local_model =  [ones(LC_count,1), ...
            (predictors{1}(firstLC:lastLC)-predictors{1}(lcID)), ...
            (predictors{1}(firstLC:lastLC)-predictors{1}(lcID)).^2, ...
            (predictors{2}(firstLC:lastLC)-predictors{2}(lcID)), ...
            (predictors{2}(firstLC:lastLC)-predictors{2}(lcID)).^2];
        local_kerns      =  inv(local_model'*local_model)*local_model';
        kernels(lcID,:)  =  [local_kerns(1,:) zeros(1,fitWidth-LC_count)];
        segments(:,lcID) =  [input_vector(firstLC:lastLC); zeros(fitWidth-LC_count,1)];
    end
    
%%
%

    smoothed_results(rangeID,:) = sum(kernels'.*segments)';
    stdDev_resid(rangeID)=std( input_vector - smoothed_results(rangeID,:)' );

end

selector=max(find(stdDev_resid<noise_threshold));
smoothed_vector=smoothed_results(selector,:);

end