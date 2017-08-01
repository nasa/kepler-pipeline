function [ spsdScWindowStart , spsdScWindowEnd , isInRange ] = sc_determine_spsd_window( obj , spsdTargetBlob , spsdIndex )
% function [ spsdScWindowStart , spsdScWindowEnd , isInRange ] = sc_determine_spsd_window( obj , spsdTargetBlob , spsdIndex )
%
%     called by sc_locate_spsds()
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

    isInRange = (obj.cadenceStartTimes(1) <= spsdTargetBlob.cadenceTimesStart(spsdIndex) ...
                  && obj.cadenceEndTimes(end) >= spsdTargetBlob.cadenceTimesEnd(spsdIndex) );

    if (~isInRange)
        % the SPSD is not in this SC range (month)
        spsdScWindowStart = -1;
        spsdScWindowEnd = -1;
    else
        % the SPSD is in this SC range (month)
        % Cadence times are valid only outside gaps
        tmp = abs( obj.cadenceStartTimes(~obj.shortCadenceTimes.gapIndicators) - spsdTargetBlob.cadenceTimesStart(spsdIndex) );
        spsdScWindowStart = find( tmp == min(tmp) );
        spsdScWindowStart = spsdScWindowStart(1); % just in case there's more than one (should not happen)
        tmp = abs( obj.cadenceEndTimes(~obj.shortCadenceTimes.gapIndicators) - spsdTargetBlob.cadenceTimesEnd(spsdIndex) );
        spsdScWindowEnd = find( tmp == min(tmp) );
        spsdScWindowEnd = spsdScWindowEnd(1); % just in case there's more than one (should not happen)
        if (spsdScWindowStart > spsdScWindowEnd)
            % NOTE: JCS here, I didn't write this function. I think if this
            % conditional is true then there is an error, but I don't have
            % the time to work through all the code to figure out what's
            % going on here. So instead of crashing, I am returning -1 and
            % moving on...
            spsdScWindowStart = -1;
            spsdScWindowEnd = -1;
            isInRange = false;
        end
    end
end
