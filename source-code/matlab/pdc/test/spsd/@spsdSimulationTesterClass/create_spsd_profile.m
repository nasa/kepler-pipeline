function profile = create_spsd_profile( ~, d, tDrop, r, tc)
%==========================================================================
% function profile = create_spsd_profile( d, tDrop, r, tc)
%==========================================================================
% Model an SPSD sensitivity profile.  
%
% INPUTS
%     d     : The magnitude of the sensitivity drop in the first cadence.
%             For example, a d of 0.01 is interpreted to mean the
%             sensitivity drops from 1.0 to 0.99. [0,1] 
%     tDrop : The time within the first cadence at which the drop occurs.
%             [0,1) 
%     r     : The fraction of the original drop in sensititvity that is 
%             regained. [0,1] 
%     tc    : The time constant of the (exponential) recovery.
%
%
% NOTES
%     
%     - For convenience, cadences are assigned unit duration.
%     - The sensitivity drop occurs in the first cadence of the model.
%     - The profile is calculated as the time average over each cadence 
%       of the continuous sensitivity function s(t), where s(t) represents
%       the normalized (spatial) average pixel sensitivity within a target
%       aperture.
%
%           s(t) = { 1.0                                   t <= tDrop
%                  { 1 - d + r*d*( 1-exp(-tc(t-tDrop) )),   t >  tDrop
%
%     - Time averages are calculated by integrating s(t) over each (unit)
%       cadence interval.
%
%
%          s(t)
%           ^
%           |
%       1.0 +...
%           |          
%           |         .................  <- (1 - d  + r*d)
%           |     ..''   
%     1 - d +   .'     
%           |
%           +----+----+----+----+----+---> t
%           0   ^1    2    3    4    5 
%               |
%             tDrop
%
%==========================================================================
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
    TOL                = 0.0001; 
    MIN_TIME_CONST     = 0.001;
    
    if tc < MIN_TIME_CONST
        tc = MIN_TIME_CONST;
    end
    
    c1 = 1 - d + r * d;
    c2 = r * d * exp(tc * tDrop) / tc;
    
    recoveryLength = ceil(-log(TOL)/tc);
    profileLength = 1 + recoveryLength;  
    
    profile = ones(profileLength,1);
    profile(1) = tDrop + c1*(1-tDrop) + c2*( exp(-tc) - exp(-tc*tDrop) );
    
    for k = 2:profileLength
        profile(k) = c1 + c2*( exp(-tc*k) - exp(-tc*(k-1)) );
    end

end

