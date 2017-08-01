function ccdObject = make_motion_basis(ccdObject)
%
% Copyright 2017 United States Government as represented by the
% Administrator of the National Aeronautics and Space Administration.
% All Rights Reserved.
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

motionBasisFileName = get(ccdObject.ccdPlaneObjectList(1), 'motionBasisFilename');
if exist(motionBasisFileName, 'file')    
    for plane=1:length(ccdObject.ccdPlaneObjectList)
        ccdObject.ccdPlaneObjectList(plane) = ...
            load(ccdObject.ccdPlaneObjectList(plane), 'motionBasis');
    end
    load(motionBasisFileName, 'motionGridRow', 'motionGridCol');
    ccdObject.motionGridRow = motionGridRow;
    ccdObject.motionGridCol = motionGridCol;
else
    runDurationCadences = get(ccdObject.runParamsClass, 'runDurationCadences');
    exposuresPerCadence = get(ccdObject.runParamsClass, 'exposuresPerCadence');
    numChains = get(ccdObject.runParamsClass, 'numChains');
    simulationFramesPerExposure = ...
        get(ccdObject.runParamsClass, 'simulationFramesPerExposure');
    integrationTime = get(ccdObject.runParamsClass, 'integrationTime');
    transferTime = get(ccdObject.runParamsClass, 'transferTime');
    numVisibleRows = get(ccdObject.runParamsClass, 'numVisibleRows');
    numVisibleCols = get(ccdObject.runParamsClass, 'numVisibleCols');
    motionGridResolution = get(ccdObject.runParamsClass, 'motionGridResolution');
    motionPolyOrder = get(ccdObject.runParamsClass, 'motionPolyOrder');
    timeVector = get(ccdObject.runParamsClass, 'timeVector');

    % build time interpolation vector simulating the readout chains/frames
    numSamples = round(runDurationCadences*exposuresPerCadence);

    % comment from ETEM:
    % The computations of t_resampleA looks like the integration time is divided 
    % up into 5 sections (one for each "chain" of electronics on the FS) with 
    % the and the read or transfer (xfer) time is then taken into account.  
    % The result is t_resampleA is a matrix with 5 rows (one for each "chain" 
    % where each row has identical elements, namely, the time midpoint of the 
    % one-fifth of the integration time that corresponds to that chain.
    % The int_time/5/2 gives the 1/2 of 1/5 offset to demark the midpoint of the
    % time interval.
    timeResampleA = repmat(integrationTime/numChains/2 ...
        + (0:(numChains-1))'*integrationTime/numChains, 1, numSamples);

    % comment from ETEM:
    % The computation of t_resampleB generates a 5xLCS matrix where each column
    % contains the starting time of the individual integrations.  The time
    % differences from one column to the next are equal to int_time+xfer_time.
    timeResampleB = repmat((0:numSamples-1) * (integrationTime + transferTime), ...
        numChains, 1);

    % comment from ETEM:
    % t_resample, then, is a matrix 5xLCS where each of the 5 rows represents the 
    % midpoint of integration time after being divided into 5 segments for the
    % entire simulation.

    timeResample = timeResampleA + timeResampleB;

    clear timeResampleA timeResampleB

    % reshape timeResample into a 1D vector of time samples
    % in ETEM the next line is
    % timeResample = reshape(timeResample, size(timeResample, 1)*size(timeResample, 2), 1);
    % which seems to be the same thing
    % also convert to days and add the simulation start time
    timeResample = timeResample(:)/(24*3600) + timeVector(1);

    % compute row and column of motion grid
    [motionGridCol motionGridRow] = ...
        meshgrid(linspace(1, numVisibleCols-1, motionGridResolution), ...
        linspace(1, numVisibleRows-1, motionGridResolution));
    ccdObject.motionGridRow = motionGridRow;
    ccdObject.motionGridCol = motionGridCol;

    h = waitbar(0, 'making motion basis');
    % first get the global ccd motions
    for r=1:motionGridResolution
        for c=1:motionGridResolution
            % first get the global ccd motions
            [globalRowMotion, globalColMotion] = ...
                get_motion(ccdObject, motionGridRow(r, c), motionGridCol(r, c), timeResample);
            % then get the motions for each ccd plane object
            for plane=1:length(ccdObject.ccdPlaneObjectList)
                rowMotion = globalRowMotion;
                colMotion = globalColMotion;
                motionObjectList = get(ccdObject.ccdPlaneObjectList(plane), 'motionObjectList');
                for m=1:length(motionObjectList)
                    [planeRowMotion, planeColMotion] = get_motion(motionObjectList(m), ...
                        motionGridRow(r, c), motionGridCol(r, c), timeResample);
                    rowMotion = rowMotion + planeRowMotion;
                    colMotion = colMotion + planeColMotion;
                end
                % make design matrix, setting column motion to x and row motion
                % to y
                designMatrix = make_binned_design_matrix(colMotion, rowMotion, ...
                    motionPolyOrder, ...
                    exposuresPerCadence*simulationFramesPerExposure)/simulationFramesPerExposure;
                ccdObject.ccdPlaneObjectList(plane) = ...
                    set_motion_design_matrix(ccdObject.ccdPlaneObjectList(plane), ... 
                    designMatrix, r, c);
            end
            waitbar(r*c/(motionGridResolution*motionGridResolution));
        end
    end
    close(h);

    for plane=1:length(ccdObject.ccdPlaneObjectList)
        save(ccdObject.ccdPlaneObjectList(plane), 'motionBasis');
    end
    save(motionBasisFileName, 'motionGridRow', 'motionGridCol', '-append');
end

