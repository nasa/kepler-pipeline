%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function h0 = daubechies_low_pass_scaling_filter(nLength)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% This function returns the scaling filter associated with Daubechies
% wavelet specified by nLength. Possible values for nLength are 1, 2, 3,
% ..., 45
%
% The length of the scaling filter is 2nLength - 1. The number of vanishing
% moments of  is nLength. Most scaling filters are not symmetrical. For
% some, the asymmetry is very pronounced. The regularity increases with the
% order. The analysis is orthogonal.
%
% References:
% [1]	M.Vetterli and J. Kovacevic, Wavelets and Subband Coding,
%       Prentice-Hall Inc., 1995.
% [2]	C. S. Burrus, R. A. Gopinath, and H. Guo, Introduction to Wavelets
%       and Wavelet Transforms - A Primer, Prentice-Hall Inc., 1998.
% [3]	D. B. Percival and A. T. Walden, Wavelet Methods for Time Series
%       Analysis, Cambridge University Press, 2000.
%       http://www-dsp.rice.edu/software/rwt.shtml
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
function h0 = daubechies_low_pass_scaling_filter(nLength)

%   http://www-dsp.rice.edu/software/rwt.shtml
%   Rice Wavelet Toolbox (RWT)
%   Function computes the Daubechies' scaling and wavelet filters
%   (normalized to sqrt(2)).

if(nLength > 40)
    nLength = 40;
    warning('TPS:daubechies_low_pass_scaling_filter:WrongFilterLength',...
        ['TPS:wavelet:Wavelet scaling filter numerically unstable for length = ' num2str(nLength)]);
    fprintf('Setting the wavelet filter length to 40\n');
end
h0 = daubcqf(round(nLength),'min'); % minimum phase filter

h0 = h0' ;


% switch nLength
%     case 4
%         h0=[0.4829629131445341, 0.8365163037378079,0.2241438680420134,...
%             -0.1294095225512604]';
%     case 12
%         h0=[.111540743350, .494623890398, .751133908021,...
%             .315250351709,-.226264693965,-.129766867567,.097501605587, ....
%             .027522865530,-.031582039318,.000553842201, .004777257511,...
%             -.001077301085]';
%     case 20
%         h0=[.026670057901, .188176800078, .527201188932,...
%             .688459039454, .281172343661,-.249846424327,-.195946274377, ...
%             .127369340336, .093057364604,-.071394147166,-.029457536822, ...
%             .033212674059,.003606553567,-.010733175483, .001395351747,...
%             .001992405295,-.000685856695,-.000116466855,.000093588670,...
%             -.000013264203]';
%     otherwise
%         error('PDC:daubechies_low_pass_scaling_filter:WrongFilterSize',...
%             'The filter size can only be 4,12 or 20!')
%
% end
return
