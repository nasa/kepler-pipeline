function [idx] = match_expected_mes_data_to_tip_data(s,tipData, varargin)
%
% function [idx] = match_expected_mes_data_to_tip_data(s,tipData, varargin)
%
% Match the entries from the expected-mes data with those in the tipData. Since the model parmaeters in the expected-mes data struct came
% directly from TIP these should match exactly. Also, assuming there are no duplicate entries in the original TIP data there should be at
% most one match. Assume incoming structure is s.data. Variable argument is a fractional tolerance on the field values.
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


% extract optional tolerance
if nargin > 2
    fractionalTolerance = varargin{1};
else
    fractionalTolerance = 0;
end


% idx has size of expected-mes data
% entries of idx are NaN or index into tipData which matches expected-mes data in that position

% match on keplerId, period, epoch, duration, depth, ses
mesTipKeplerId      = s.data.keplerId;
mesTipPeriodDays    = s.data.tipPeriodDays;
mesTipEpochBjd      = s.data.tipEpochBjd;
mesTipDurationHours = s.data.tipDurationHours;
mesTipDepthPpm      = s.data.tipDepthPpm;
mesTipSes           = s.data.tipSes;

tipKeplerId         = tipData.keplerId;
tipPeriodDays       = tipData.orbitalPeriodDays;
tipEpochBjd         = tipData.epochBjd;
tipDurationHours    = tipData.transitDurationHours;
tipDepthPpm         = tipData.transitDepthPpm;
tipSes              = tipData.singleEventStatistic;


idx = nan(size(mesTipKeplerId));

for i = 1:length(mesTipKeplerId)    
    tf = ismember(tipKeplerId, mesTipKeplerId(i));
    if any(tf)
        tf = tf & match(tipPeriodDays, mesTipPeriodDays(i),fractionalTolerance);
        if any(tf)
            tf = tf & match(tipEpochBjd, mesTipEpochBjd(i),fractionalTolerance);
            if any(tf)
                tf = tf & match(tipDepthPpm, mesTipDepthPpm(i),fractionalTolerance);
                if any(tf)
                    tf = tf & match(tipDurationHours, mesTipDurationHours(i),fractionalTolerance);
                    if any(tf)
                        tf = tf & match(tipSes, mesTipSes(i),fractionalTolerance);
                        if any(tf)
                            index = find(tf);
                            if length(index) > 1
                                error('More than one tipData match found.')
                            else
                                idx(i) = index;
                            end
                        end
                    end
                end
            end
        end
    end
end

return;


% matching sub funtion
function tf = match(v,s,tol)

if s == 0
    tf = true(size(v));
else
    tf = abs( (v - s)./s ) <= tol;
end

return

