function [pos vel tdbMinusUtc] = get_state_vector(raDec2PixObject, julianTime, originOfCoordinates)
%
% function [pos vel tdbMinusUtc] = get_state_vector(raDec2PixObject, julianTime, originOfCoordinates)
%
% inputs: julianTime -- floating point julian date
%         originOfCoordinates (optional) -- 'sun' (default) or 'ssb'
%
% outputs: pos -- a three-column vector of the spacecraft position, in km
%          vel -- a three-column vector of the spacecraft velocity, in km/s
%          tdbMinusUtc -- column vector with TDB - UTC differences for each
%                         Julian time, in s
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

% JT, 2012-Nov-20:    add new 'tdbMinusUtc' output vector to support
%                     conversion of barycentric corrected timestamps to
%                     Barycentric Dynamical Time standard.
% PT, 2009-March-31:  add optional originOfCoordinates argument to support
%                     barycentric time correction use case.

    % Handle case of 2 input arguments, no originOfCoordinates specified
    %
    if ( ~exist('originOfCoordinates', 'var') || isempty(originOfCoordinates) )
        originOfCoordinates = 'sun' ;
    end
    
    % handle case where it's not a string but some other variable type (the spice kernel
    % will handle for us the case in which it's an invalid string)
    %
    if (~ischar(originOfCoordinates))
        error('MATLAB:FC:raDec2PixClass:get_state_vector', ...
            'third argument to get_state_vector must be a string') ;
    end

    % Get the location of the SPICE files:
    %
    spiceFileDir               = get(raDec2PixObject, 'spiceFileDir');
    spiceFile                  = get(raDec2PixObject, 'spiceFileName');
    leapsecondsFile            = get(raDec2PixObject, 'leapsecondFileName');
    planetaryEphemerisFile     = get(raDec2PixObject, 'planetaryEphemerisFileName');

    keplerSpiceKernel     = [spiceFileDir '/' spiceFile];
    planetEphemerisKernel = [spiceFileDir '/' planetaryEphemerisFile];
    leapsecondFilename    = [spiceFileDir '/' leapsecondsFile]; 

    keplerSpiceId = '-227';
    spiceEpoch    = 'J2000';

    % Call the MEX function, which performs the state-vector lookup:
    %
    try
        utcTimes = julian2datestr(julianTime)';
%        [pos vel] = keplerStateVector(utcTimes, keplerSpiceId, 'sun', spiceEpoch, keplerSpiceKernel, planetEphemerisKernel, leapsecondFilename);
        [pos vel tdbMinusUtc] = keplerStateVector(utcTimes, keplerSpiceId, originOfCoordinates, ...
            spiceEpoch, keplerSpiceKernel, planetEphemerisKernel, leapsecondFilename);
    catch
        err = lasterror;
        err.message
        error('MATLAB:FC:raDec2PixClass:get_state_vector', 'error caught in get_state_vector');
        rethrow(err);
    end
    
return
