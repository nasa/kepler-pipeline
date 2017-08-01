function designMat = build_design_matrix(obj, targetIndex, cadences, ...
                                         frequencies, samplingTimes)
%**************************************************************************
% designMat = build_design_matrix(obj, targetIndex, cadences, ...
%                                 frequencies, samplingTimes)
%**************************************************************************
% Assemble the design matrix for the harmonic & motion model. 
%
% INPUTS:
%     targetIndex   : A single target index.
%     cadences      : An M-length array of relative cadences indices to
%                     include in the model
%     frequencies   : An N-length array of frequencies (Hz) to include in 
%                     the model.
%     samplingTimes : An array of timestamps (MJD) corresponding to each of
%                     the cadence indices in 'cadences'.
%
% OUTPUTS:
%     designMat     : An M x (N+3) matrix of column basis vectors.
%
%       D = [ cos(w1*t1) sin(w1*t1) ... cos(wN*t1) sin(wN*t1) dx1 dy1 ds1 ]
%           [ cos(w1*t2) sin(w1*t2) ... cos(wN*t2) sin(wN*t2) dx2 dy2 ds2 ]
%           [     :          :              :          :       :   :   :  ]
%           [ cos(w1*tM) sin(w1*tM) ... cos(wN*tM) sin(wN*tM) dxM dyM dsM ]
%
%**************************************************************************
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
    nHarmonics   = numel(frequencies); % 0 or more.
    nAncillaryTs = numel(obj.ancillaryTimeSeries);

    nBasisVectors = 2*nHarmonics + nAncillaryTs;
    nCadences = numel(cadences);
    
    if nCadences > 0 && nBasisVectors > 0
        designMat = zeros(nCadences, nBasisVectors);
        if nHarmonics > 0 
            t = samplingTimes(cadences); % Time in seconds.
        end
        
        bvCounter = 0;
        for i = 1:nHarmonics
            w = 2 * pi * frequencies(i); % Frequency in rad/sec.
            designMat(:,bvCounter + 1) = cos(w * t);
            designMat(:,bvCounter + 2) = sin(w * t);
            bvCounter = bvCounter + 2;
        end
        
        for i = 1:nAncillaryTs
            ancillaryMat = obj.ancillaryTimeSeries{i};
            designMat(:, bvCounter + 1) = ancillaryMat(cadences, targetIndex);
            bvCounter = bvCounter + 1;
        end
    else
        designMat = [];
    end
    
end

%********************************** EOF ***********************************