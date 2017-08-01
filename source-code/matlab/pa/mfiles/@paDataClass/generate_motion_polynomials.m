function [paResultsStruct] = generate_motion_polynomials( paDataObject )
%************************************************************************** 
% function [paResultsStruct] = generate_motion_polynomials( paDataObject )
%************************************************************************** 
% Fit motion polynomials for each long cadence and/or write
% motionPolyStruct to both the state file and PA motion file. This function
% is never called during short-cadence processing.
%
% INPUTS
%     paDataObject
%
% OUTPUTS
%     paResultsStruct
% 
% FILES WRITTEN
%     paStateFileName  : If a valid motionPolyStruct is computed or already
%                        present in the input, any gaps are interpolated.
%                        Otherwise it is set to the empty array. The
%                        current subtask's state file is then updated with
%                        the interpolated (or empty) array. A
%                        motionPolyStruct array is deemed 'valid' if (a) it
%                        contains more than two ungapped polynomial
%                        structures or (b) we are processing a single long
%                        cadence and motionPolyStruct consists of a single,
%                        non-gapped polynomial struct.  
%                        
%     paMotionFileName : Un-interpolated motion polynomials are written to
%                        this file unless it already exists or there are
%                        two few non-gapped cadences int he motion
%                        polynomial array, in which case it is written on
%                        the last call (see finalize.m).
% NOTES
%   - All state files are removed in update_pa_inputs.m on the first call
%     to pa_matlab_controller.m, so the test for existence of the
%     pa_motion.mat file is still valid if we re-run PA in a previously
%     processed directory.
%   - The pa_motion.mat file may be written in one of three places during
%     long-cadence processing (it is not written at all when processing
%     short-cadence): 
%     (1) In update_pa_inputs.m when processingState=BACKGROUND and an
%         input motion blob is provided.
%     (2) In this function when processingState=GENERATE_MOTION_POLYNOMIALS
%     (3) In finalize.m when processingState=AGGREGATE_RESULTS.
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

    ppaTargetCount   = paDataObject.ppaTargetCount;
    fitMinPoints     = paDataObject.motionConfigurationStruct.fitMinPoints;
    paStateFileName  = paDataObject.paFileStruct.paStateFileName;
    paMotionFileName = paDataObject.paFileStruct.paMotionFileName;
    motionPolyStruct = paDataObject.motionPolyStruct;   
    cadenceTimes     = paDataObject.cadenceTimes;
    
    % Initialize the PA output structure
    [paResultsStruct] = initialize_pa_output_structure(paDataObject);
   
    % Fit motion polynomials.
    if isempty(motionPolyStruct) && ppaTargetCount >= fitMinPoints
        
        tic
        display('fitting motion polynomials to ppa target centroids...');

        % Note that calling fit_motion_polynomials() without a target list 
        % argument causes it to read all target results from from the state
        % file. 
        [paResultsStruct, motionPolyStruct] = ...
            fit_motion_polynomials(paDataObject, paResultsStruct);

        duration = toc;
        display(['Motion polynomials computed for PPA targets: ', ...
            num2str(duration), ' seconds = ',  num2str(duration/60), ...
            ' minutes']);
    end
    
    % If the motion blob does not already exist and the motionPolyStruct is
    % non-empty and valid, write the motion blob. Otherwise, set
    % motionPolyStruct = [] to indicate that fitting should be done in the
    % final subtask. Interpolate across gaps in motionPolyStruct.
    % Interpolation requires valid MP structures on at least two cadences.
    % In the special case of one cadence and one valid MP struct, do
    % nothing.
    motionPolyStruct = ...
        get_interp_motion_polys_and_write_uninterp_motion_blob( ...
            motionPolyStruct, paMotionFileName, cadenceTimes, 'LONG');
    
    % Update the current subtask's state file with the interpolated
    % motionPolyStruct (it will be moved to the root task directory before
    % exiting pa_matlab_controller). 
    save(paStateFileName, 'motionPolyStruct', '-append');

end
