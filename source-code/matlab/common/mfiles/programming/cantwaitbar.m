function h = cantwaitbar(x,tstart,varargin)
% h = cantwaitbar(x,tstart,varargin)
% like the built-in waitbar except that there is an indication of the
% time to go to completion
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

if x > 0

    timeSpent = etime(clock,tstart);

    burnRate = timeSpent/x;

    timeToGo = burnRate * (1 - x);

    timeTitle = ['    time spent:',sprintf('  %2.0f:%2.0f:%2.2f',s2hms(timeSpent)),...
        '    time left:',sprintf('  %2.0f:%2.0f:%2.2f',s2hms(timeToGo))];
else
    timeTitle = '';
end

if nargin>2
    
    if ischar(varargin{1}) % title!
        title = varargin{1};
        if x>0
            title = [title,timeTitle];
        end
        varargin{1} = title;
        
    elseif length(varargin) == 1
        varargin{2} = timeTitle;
        
    elseif ischar(varargin{2}) % title!
        title = varargin{2};
        if x > 0
            title = [title,timeTitle];
            varargin{2} = title;
        end
    end

    h = waitbar(x,varargin{:});
end


return

function hms = s2hms(s)

h = fix(s/3600);

s = s-h*3600;

m = fix(s/60);

s = s - m*60;

hms=[h,m,s];

return


% tstart = clock;
% tnow = clock;
% hj = cantwaitbar(0, tstart, 'jth quarter'); % waitbar to watch progress
% if etime(clock, tnow) > 1
%     tnow = clock;
%     cantwaitbar(j/nQuarters, tstart, hj, 'jth quarter');
% end
% close(hj)


