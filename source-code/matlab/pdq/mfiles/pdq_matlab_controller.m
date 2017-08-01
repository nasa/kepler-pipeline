function pdqOutputStruct = pdq_matlab_controller(pdqInputStruct)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function pdqOutputStruct = pdq_matlab_controller(pdqInputStruct)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
% This function forms the MATLAB side of the science interface and it
% receives inputs via the structure pdqInputStruct. It first calls the
% validate_pdq_input_structure with pdqInputStruct as input where the
% fields of the input structure are validated. Then it invokes the class
% constructor for the pqdScienceClass Then it invokes the method
% process_reference_pixels() on this object and obtains pdqOutputStruct as
% output. Relevant fields returned to the Java side of the controller.
%
% If debugLevel > 0, then two plots are produced:
%
% (1) the first plot displays all the pixels (stellar, background, and
% collateral pixels) one module output at a time on a 2D plot where
% columns, rows form the x, y axes.
% (2) the second plot displays the stellar target pixels and their fluxes
% on a 3D mesh plot one target at a time. All the stellar targets are
% displayed with a pause command set to 0.5 sec.
%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
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
warning on all;

close all;

clc;

% Trim stellar target apertures if processing K2 data (indicated by
% the presence of a preliminary attitude solution in the input struct).
if isfield(pdqInputStruct, 'preliminaryAttitudeSolutionStruct')
    fprintf('PDQ: Trimming stellar target apertures...\n');
    pdqInputStruct = trim_stellar_target_apertures(pdqInputStruct, 5);
end

%----------------------------------------------------------------------
% validate inputs
%----------------------------------------------------------------------

fprintf('PDQ: Validating input structure..\n');
tic
% step 1
pdqInputStruct = validate_pdq_input_structure(pdqInputStruct);

timeTakenToValidate = toc;
fprintf('PDQ: Validating input structure took %f seconds\n',timeTakenToValidate);



%----------------------------------------------------------------------
% step 0 - sanity check, optional, hands-on, step through each plot
%----------------------------------------------------------------------

if(isfield(pdqInputStruct.pdqConfiguration, 'debugLevel'))
%     if(pdqInputStruct.pdqConfiguration.debugLevel)
        % plot_target_and_bkgd_pixels(pdqInputStruct);
        % plot_all_pixels(pdqInputStruct);
        % plot_mesh_target_pixel_flux(pdqInputStruct);
        print_summary_all_pixels(pdqInputStruct);
        print_gap_summary_all_pixels(pdqInputStruct);
        close all;
%     end
end


% step 2
fprintf('\nPDQ: Instantiating pdqScienceClass..\n');
pdqScienceObject = pdqScienceClass(pdqInputStruct);

%----------------------------------------------------------------------
% processing step ..
%----------------------------------------------------------------------

fprintf('\nPDQ: Processing reference pixels for the entire focal plane...\n');
% step 3
[pdqOutputStruct, modOutsWithMetrics] = process_reference_pixels(pdqScienceObject);



%----------------------------------------------------------------------
% prepare outputs for writing to binary file
% also validate outputs before sending the outputs to module interface
%----------------------------------------------------------------------

fprintf('\nPDQ: Preparing output structure to return to module interface...\n');
pdqOutputStruct = prepare_pdq_outputs_for_return(pdqOutputStruct,modOutsWithMetrics);

fprintf('PDQ: Validating output struture ...\n');
validate_pdq_output_structure(pdqOutputStruct);

save pdqOutputStruct.mat pdqOutputStruct ;

if(isfield(pdqInputStruct.pdqConfiguration, 'debugLevel'))
    if(pdqInputStruct.pdqConfiguration.debugLevel)
        fprintf('PDQ: Constructing validation plots...\n');
        construct_pdq_pipeline_run_validation_plots_type_1(pdqOutputStruct);
        construct_pdq_pipeline_run_validation_plots_type_2(pdqOutputStruct);
        plot_mosaic_of_all_calibrated_target_pixels(pdqInputStruct);
    end
end


%----------------------------------------------------------------------
% move image files regardless of debugLevel
%----------------------------------------------------------------------

fprintf('PDQ: Moving figures to separate directories ...\n');
move_image_files_to_separate_directories(modOutsWithMetrics);


fprintf('PDQ: Printing delta quaternion report as a text file...\n');
print_delta_quaternion_report(pdqOutputStruct,pdqScienceObject);

% Generate an XML delta quaternion file if processing K2 data (indicated by
% the presence of a preliminary attitude solution in the input struct).
if isfield(pdqInputStruct, 'preliminaryAttitudeSolutionStruct')
    fprintf('PDQ: Writing delta quaternion XML file...\n');
    write_delta_quaternion_xml_file( pdqOutputStruct, pdqInputStruct.pdqTimestampSeries );
end

fprintf('PDQ: Printing bounds crossings report as a text file...\n');
print_alerts_report(pdqOutputStruct);


% Channels should be reported as "Not Processed" only if they contain no
% valid reference data OR every cadence is on the list of excluded
% cadences (from a conversation with Doug Caldwell). If every new cadence
% is excluded PDQ won't get this far anyway, so we don't need to consider
% it here.
validReferencePixelsAvailable = valid_reference_data_available(pdqScienceObject);

pdqOutputStruct = print_report_generator_reports(pdqInputStruct, ...
    pdqOutputStruct, validReferencePixelsAvailable);



return





%javaaddpath c:\path\to\dist\lib\soc-classpath.jar
%s.raDec2PixModel.spiceFileDir = '\path\to\dist\cache\spice\'
