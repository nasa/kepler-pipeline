function z = generate_pa_data_validation_metrics_and_plots( paDataStruct, paResultsStruct )
%**************************************************************************
% function z = generate_pa_data_validation_metrics_and_plots( ...
%     paDataStruct, paResultsStruct )
%**************************************************************************
% Produce data validation summary metrics.
%
% INPUTS:   
%           paDataStruct      = input structure used by the pa_matlab_controller
%           paResultsStruct   = output structure produced by the pa_matlab_controller
% OUTPUTS:
%           z = structure containing one or more of the following
%               fields depending on the particulars of the invocation
%               and the data type (LONG or SHORT cadence)
%                          backgroundOutputStruct
%                          fluxOutputStruct
%                          centroidOutputStruct
%                          motionOutputStruct
%
% All output structures noted above are collected and written to local
% files.Assigning the output (z) is optional when calling this function.
%
% This function is intended to be called from within the
% pa_matlab_controller with inputs of the paDataStruct (not the
% paDataObject, this is not a PA method) and the paResultsStruct. It
% assembled metrics for the following products of PA: 
%
%     background polynomial fits
%     flux time series
%     centroid time series
%     motion polynomial
%
% For long acdence data, background metrics are assembled during the first
% invocation. Flux and centroid metrics are assembled during the second
% through last invocation and motion metrics are assembled during the last
% invocation. The metrics are stored in data structures in a local .mat
% files. The flux and centroid metrics are aggregated across all available
% invoations during the last invocation.
%
% For short cadence data, only the flux and centroid metrics are assembled
% and then aggregated.
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

% DAWG metrics filenames
backgroundDawgFilename  = 'pa-dawg-background.mat';
fluxDawgFilename        = 'pa-dawg-flux.mat';
centroidDawgFilename    = 'pa-dawg-centroid.mat';

% get flags
cadenceType = paDataStruct.cadenceType;
processingBackground = strcmpi(paDataStruct.processingState, 'BACKGROUND');

% retrieve current invocation number - note nInvocations is updated in the
% state file early during update_pa_inputs in the controller. At this
% point, nInvocations = the current invocation number (1-based) so the file
% tag for this invocation will be nInvocations - 1.
paStateFilename = 'pa_state.mat';

if strcmpi(cadenceType,'LONG')

    if processingBackground

        % ~~~~~~~~~~~~~~ do background fit related stuff
        s = load(paStateFilename,'backgroundPolyStruct');
        backgroundMetricsStruct = produce_pa_background_metrics( paDataStruct, s.backgroundPolyStruct );
        save(backgroundDawgFilename,'backgroundMetricsStruct');
        z.backgroundMetricsStruct = backgroundMetricsStruct;
        clear s backgroundMetricsStruct;

    else
        % ~~~~~~~~~~~~~~ do flux related stuff
        fluxOutputStruct = produce_pa_flux_metrics( paDataStruct, paResultsStruct );
        save(fluxDawgFilename,'fluxOutputStruct');
        
        z.fluxOutputStruct = fluxOutputStruct;
        clear fluxOutputStruct  

        % ~~~~~~~~~~~~~~ do centroid related stuff
        centroidOutputStruct = produce_pa_centroid_metrics( paResultsStruct );
        save(centroidDawgFilename,'centroidOutputStruct');

        z.centroidOutputStruct = centroidOutputStruct;
        clear centroidOutputStruct
    end

elseif strcmpi(cadenceType,'SHORT')

    % ~~~~~~~~~~~~~~ do flux related stuff
    fluxOutputStruct = produce_pa_flux_metrics( paDataStruct, paResultsStruct );
    save(fluxDawgFilename,'fluxOutputStruct');

    z.fluxOutputStruct = fluxOutputStruct;
    clear fluxOutputStruct

    % ~~~~~~~~~~~~~~ do centroid related stuff
    centroidOutputStruct = produce_pa_centroid_metrics( paResultsStruct );
    save(centroidDawgFilename,'centroidOutputStruct');

    z.centroidOutputStruct = centroidOutputStruct;
    clear centroidOutputStruct

end

end

