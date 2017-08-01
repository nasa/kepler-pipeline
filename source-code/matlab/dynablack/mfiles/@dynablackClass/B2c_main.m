function dynablackResultsStruct = B2c_main(dynablackObject, dynablackResultsStruct )
% function dynablackResultsStruct = B2c_main(dynablackObject, dynablackResultsStruct )
%
% B2c_main 
% Vestigial Artifact Monitoring.
% Monitors residual uncorrected and unflagged image artifact components.
% 
% * Vertical variation of FGS offsets using trailing black residuals
% * Horizontal variation of vertical coefficients using unapplied vertical fit parameters
% * Undershoot variation using unapplied vertical fit parameters
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


% ARGUMENTS
% 
% * Function returns: |isComplete| - set to 1 upon completion.
% * Function arguments:
% * |Inputs              -| structure containing input parameters. 
% * |.channel_list       -| the list of channels to be analyzed
% * |.parallel_states    -| list of fit parallel states 
% * |.A1frame_states     -| list of A1 fit frame states
% * |.A2frame_states     -| list of A2 fit frame states
% * |.A1column_states    -| list of A1 fit pixel column #s
% * |.A2column_states    -| list of A2 fit pixel column #s
% * |.undershoot_states  -| list of fit undershoot states
% * |.serial_states      -| list of fit serial pixel coefficent #s
% * |.dir_base           -| reference directory
% * |.out_filePrefix     -| output file location and name prefix rel. to dir_base
% * |.model_filename     -| list of model file locations and names rel. to dir_base
% * |.resid_filePrefix   -| list of lists of residual file locations and name prefixes rel. to dir_base
% * |.coeff_filePrefix   -| list of lists of coefficient file locations and name prefixes rel. to dir_base
% * |.B1coeff_filePrefix -| list of B1 residual file locations and name prefixes rel. to dir_base
% * |.B1resid_filePrefix -| list of B1 coefficient file locations and name prefixes rel. to dir_base
%
% the following fields of 'Inputs' define what data is monitored and should have the same length:
%
% * |.monitor_names      -| list of field names of monitored information (user defined)
% * |.monitor_types      -| 1-residuals; 2-coefficients
% * |.monitor_files      -| pointer to data filename list (files in data filename lists are concatenated)
% * |.monitor_modelFiles -| pointer to model filename
% * |.monitor_locExpr    -| for residuals- specific data_subset of interest (see A1b_parameter_init.m)
%                           for coefficents- specific model element structure (see B2c_parameter_init.m)
% * |.monitor_relIndex   -| index of subset of data within that specified by monitor_locExpr
% * |.monitor_domainVal  -| list of values associated with the domain of the information of interest
% * |.monitor_description-| description of the information of interest
% * |.monitor_domainlabel-| label for the domain of the information of interest


% initialize from dynabalck object and results
[Init_Info1, Inputs] = B2c_parameter_init(dynablackObject,dynablackResultsStruct);

% parse control parameters
Constants       = Init_Info1.Constants;
nMonitors       = Constants.Monitor_count;
nCoeffs         = Constants.coeff_count;
monitorNames    = Inputs.monitor_names;
roi             = Init_Info1.roi;

% initialize Monitors struct
Monitors = cell2struct(cell(nMonitors,1),monitorNames,1);

% loop over monitors
for i = 1:nMonitors
    
    % switch on monitor type
    switch Inputs.monitor_types(i)
        
        % --> RESIDUAL MONITOR CASE:
        case 1
            % ---> LOAD RESIDUAL DATA
            combined_residuals_xLC = dynablackResultsStruct.A1_fit_residInfo.LC.full_xLC.regress_resid;
            lc_count = size(combined_residuals_xLC,1);
            
            % ---> CREATE 'Monitored_Residuals' OBJECT
            lc1 = (1:lc_count)'*ones(1,roi.Count(i));
            rows1 = (roi.Rows{i}*ones(1,lc_count))';
            columns1 = (roi.Columns{i}*ones(1,lc_count))';
            frame1 = (roi.Frame{i}*ones(1,lc_count))';
            parallel1 = (roi.Parallel{i}*ones(1,lc_count))';
            resid1 = combined_residuals_xLC(:,roi.Start(i):roi.End(i));
            
            residMonitor_inputs = struct('residuals', resid1, ...
                                            'lc_domain', lc1, ...
                                            'row_domain', rows1, ...
                                            'column_domain', columns1, ...
                                            'FGS_frame_domain', frame1, ...
                                            'FGS_parallel_domain', parallel1, ...
                                            'description', Inputs.monitor_description{i});
            
            Monitors.(monitorNames{i}) = Monitored_Residuals(residMonitor_inputs);
            disp(strcat(' -',monitorNames{i}, ' monitored residuals created'));
            
        % --> COEFFICIENT MONITOR CASE:
        case 2
            % ---> LOAD COEFFICIENT DATA
            combined_coeffs_and_errors_xLC = ...
                [dynablackResultsStruct.A1_fit_results.LC.coeffs_xLC.regress, ...
                    dynablackResultsStruct.A1_fit_results.LC.coeff_errs_xLC.regressCI_hi,...
                    dynablackResultsStruct.A1_fit_results.LC.coeff_errs_xLC.regressCI_lo,...
                    dynablackResultsStruct.A1_fit_results.LC.coeffs_xLC.robust, ...
                    dynablackResultsStruct.A1_fit_results.LC.coeff_errs_xLC.robust_stErr,...
                    zeros(dynablackResultsStruct.A1_fit_results.LC.lc_count,dynablackResultsStruct.A1_fit_results.LC.numCoeffs), ...
                    dynablackResultsStruct.A1_fit_results.LC.coeff_errs_xLC.robust_stats.sigma', ...
                    dynablackResultsStruct.A1_fit_results.LC.coeff_errs_xLC.robust_stats.ols_sigma', ...
                    dynablackResultsStruct.A1_fit_results.LC.coeff_errs_xLC.robust_stats.robust_sigma', ...
                    dynablackResultsStruct.A1_fit_results.LC.coeff_errs_xLC.robust_stats.mad_sigma', ...
                    ones(dynablackResultsStruct.A1_fit_results.LC.lc_count,1).*dynablackResultsStruct.A1_fit_results.LC.rowTimeConstant];
            
            lc_count=size(combined_coeffs_and_errors_xLC,1);
            
            % ---> CREATE 'Monitored_Parameters' OBJECT
            index2 = roi.Index{i};
            error_offset2 = nCoeffs(i);
            lc2 = (1:lc_count)'*ones(1,roi.Count(i));
            domain2 = (roi.Domain{i}'*ones(1,lc_count))';
            data2 = combined_coeffs_and_errors_xLC(:,index2);
            error2 = combined_coeffs_and_errors_xLC(:,index2+error_offset2) - combined_coeffs_and_errors_xLC(:,index2+2*error_offset2)/2;
            description2 = Inputs.monitor_description{i};
            label2 = Inputs.monitor_domainlabel{i};
            
            paramMonitor_inputs = struct('param_data', data2, ...
                                            'param_errors', error2, ...
                                            'B1models', zeros(size(data2)), ...
                                            'lc_domain', lc2, ...
                                            'domain', domain2, ...
                                            'description', description2, ...
                                            'label', label2);
            
            Monitors.(monitorNames{i}) = Monitored_Parameters(paramMonitor_inputs);
            disp(strcat(' -',monitorNames{i}, ' monitored parameters created'));
    end
end

% save results
dynablackResultsStruct.B2c_monitors = Monitors;


