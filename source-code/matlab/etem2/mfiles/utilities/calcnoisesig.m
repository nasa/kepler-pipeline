%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function sig = calcnoisesig(dt,starmag,diaradsig1,flux12)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Function Name:  calcnoisesig
% Software level: Heritage Code
% Description: This function returns the total rms system noise (sigma)
% appropriate for Kepler extracted from the DIARAD/SOHO data (after
% adjusting for DIARAD instrument noise) over 'dt' sampling interval.
%
% Input:
%        diaradsig1 - DIARAD instrumental uncertainty in each 3 min measurement
%        dt - sampling interval in hours
%        starmag - Apparent magnitude of target star
%        flux12 - flux from a magnitude 12 star.  If missing set to 5.75e9
% Output:
%       sig -  total rms system  noise
%
% Author: J.Jenkins
%
% H.Chandrasekaran - modified and added comments as part of CVS Matlab
% Utilities directory clean-up effort
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
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
function sig = calcnoisesig(dt, starmag, diaradsig1, flux12);
% dt in hours
if nargin < 4
    flux6pt5 = 5.75e9; % for backward compatability
else
    six_pt_five_hours = 6.5 * 60 * 60;
    flux_6pt5 = flux12 * six_pt_five_hours;    
end

if nargin < 3
    diaradsig1 = .1; % DIARAD instrumental uncertainty in each 3 min measurement
end

flux = flux_6pt5 * mag2b(starmag-12) * dt / 6.5; % flux of star of magnitude = starmag over dt hours

fluxsig = sqrt(flux).^-1*1366.6; % convert to watts /m^2

instrflux = (6e-6 * flux_6pt5).^2 * dt / 6.5; % instrument noise over dt hours

instrsig = sqrt(instrflux)./flux*1366.6; % scaled to w/m^2

diaradsig = diaradsig1/sqrt(20*dt);% there are 20 measurements in an hour; diarad signal over dt hours

sig = sqrt(fluxsig.^2+instrsig.^2-diaradsig^2); % total rms system  noise

return
