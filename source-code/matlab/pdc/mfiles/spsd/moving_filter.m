function filteredSignal = moving_filter(signal,windowLength,method)
% -------------------------------------------------------------------------------
% function filteredSignal = moving_filter(signal,windowLength,method)
%
%    performs a moving filter across the signal
%
%    INPUTS:
%        signal:        the input signal, Nx1 or 1xN vector
%        windowLength:  length of the window for the running filter. must be odd
%        method:        'mean' or 'median' (using the nan-versions of these)
%
%    OUTPUTS:
%        filteredSignal: the filtered signal
% -------------------------------------------------------------------------------
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

%% check inputs, and transpose if input is a row-vector
    if (~strcmp(method,'mean') && ~strcmp(method,'median'))
        disp('ERROR: method must be either ''mean'' or ''median''');
        filteredSignal = [];
        return;
    end

    flipResult = false;
    sz = size(signal);
    if (sz(1)<sz(2))
        signal = signal';
        flipResult = true;
    end
    sz = size(signal);
    if (sz(2)>1)
        disp('ERROR: signal must be a row or column vector');
        filteredSignal = [];
        return;
    end
    nPoints = sz(1);
    if (mod(windowLength,2)==0)
        disp('ERROR: windowLength must be odd');
        filteredSignal = [];
        return;
    end
    
%%  create matrix  
    M = zeros(sz(1),windowLength);
    M(:) = nan;
    offset = floor(windowLength/2);
    for i=-offset:offset
        if (i<0)
            b1 = 1;
            e1 = nPoints+i;
            b2 = -i+1;
            e2 = nPoints;            
        elseif (i==0)
            b1 = 1;
            e1 = nPoints;
            b2 = 1;
            e2 = nPoints;
        elseif (i>0)
            b1 = i+1;
            e1 = nPoints;
            b2 = 1;
            e2 = nPoints-i;
        end
        M(b1:e1,i+offset+1) = signal(b2:e2);
    end
    
%% create moving filter
    if (strcmp(method,'mean'))
        filteredSignal = nanmean(M,2);
    elseif (strcmp(method,'median'))
        filteredSignal = nanmedian(M,2);
    end
    
%% transpose if input was a row-vector
    if flipResult
        filteredSignal = filteredSignal';
    end

end