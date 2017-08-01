function pointing = get_pointing(pointingObject, mjd)
%
% function pointing = get_pointing(pointingObject, mjd)
%
% Get the pointing (ra, dec, and roll) in degrees of the spacecraft
% for the given input vector of MJDs.
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

    % column-vectorize the input mjd:
    %
    mjd = mjd(:);
    
    mjds = get(pointingObject, 'mjds');
    method = get(pointingObject, 'interpolation_method');
    
    if any(mjd < min(mjds))
        error('Matlab:FC:pointingClass:get_pointing', ...
              '%f is below the MJD range of this pointing object: %f - %f', ...
              min(mjd), min(mjds), max(mjds));
    end
    if any(mjd > max(mjds))
        error('Matlab:FC:pointingClass:get_pointing', ...
              '%f is above the MJD range of this pointing object: %f - %f', ...
              max(mjd), min(mjds), max(mjds));
    end

    % generate pointing segments array
    %
    pointingSegments = generate_pointing_segment_array(pointingObject);
    
    % define the return vectors
    %
    ra   = zeros(size(mjd));
    dec  = zeros(size(mjd));
    roll = zeros(size(mjd));
    
    % loop over the pointing segments and get the pointing at the desired
    % mjd timestamps
    %
    nSegments = length(pointingSegments);
    
    for iSegment = 1 : nSegments
        
        startMjd     = pointingSegments(iSegment).startMjd;
        endMjd       = pointingSegments(iSegment).endMjd;
        mjds         = pointingSegments(iSegment).mjds;
        ras          = pointingSegments(iSegment).ras;
        declinations = pointingSegments(iSegment).declinations;
        rolls        = pointingSegments(iSegment).rolls;
        
        if iSegment < nSegments
            isInSegment = mjd >= startMjd & mjd < endMjd;
        else
            isInSegment = mjd >= startMjd & mjd <= endMjd;
        end
        
        if 1 == length(mjds) 
            ra(isInSegment)   = ras;
            dec(isInSegment)  = declinations;
            roll(isInSegment) = rolls;
        else
            ra(isInSegment)   = interp1(mjds, ras, mjd(isInSegment), method);
            dec(isInSegment)  = interp1(mjds, declinations, mjd(isInSegment), method);
            roll(isInSegment) = interp1(mjds, rolls, mjd(isInSegment), method);
        end

    end
    
    pointing = [ra dec roll];
    
return
