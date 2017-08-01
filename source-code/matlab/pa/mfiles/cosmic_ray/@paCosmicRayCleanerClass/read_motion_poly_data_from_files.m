function [motionPolyStruct, motionPolyGapIndicators] ...
    = read_motion_poly_data_from_files( taskDir, gaps )
%**************************************************************************
% function read_motion_poly_data_from_files( obj, taskDir )
%**************************************************************************
% If motion polynomials are available, read the struct from the
% pa_state.mat file and derive target position and focus time series. 
%
% This function is not called in the pipeline, but is provided to
% facilitate off-line testing. It is called only when the constructor is
% passed a paDataStruct and task directory name.
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
    paStateFileName                 = 'pa_state.mat';
    paMotionFileName                = 'pa_motion.mat';
    motionPolyVariableName          = 'motionPolyStruct';
    motionBlobVariableName          = 'inputStruct';
    
    motionPolyStruct = struct([]);
    motionPolyGapIndicators = [];

    % Extract motion polynomial struct from pa_state file, if available.
    stateFileName = fullfile(taskDir, paStateFileName);
    if exist(stateFileName,'file')
        s = load(stateFileName, motionPolyVariableName);
        if isfield(s, motionPolyVariableName)
            if ~isempty(s.motionPolyStruct)
                motionPolyStruct = s.motionPolyStruct;
            end
        end
    end

    if isempty(motionPolyStruct)
        fprintf('Motion polynomials are unavailable.\n'); 
        return;        
    end
    
    % Read motion blob, if available, to obtain motion polynomial 
    % status at each cadence. If no blob file is available, assume
    % that motion polynomials were interpolated only on gapped
    % cadences.
    motionBlobFileName = fullfile(taskDir, paMotionFileName);
    if exist(motionBlobFileName,'file')
        s = load(motionBlobFileName, motionBlobVariableName);
        if isfield(s, motionBlobVariableName)
            motionPolyGapIndicators = ~([s.inputStruct.rowPolyStatus] ...
                & [s.inputStruct.colPolyStatus]);
        end
    end
    
    if isempty(motionPolyGapIndicators)
        fprintf(['Motion polynomial status flags are not available.', ...
            ' Assuming interpolation over gapped cadences.\n']);
        motionPolyGapIndicators = ~([motionPolyStruct.rowPolyStatus] ...
            & [motionPolyStruct.colPolyStatus]);
        motionPolyGapIndicators(gaps) = 1;        
    end

end
        
%********************************** EOF ***********************************
