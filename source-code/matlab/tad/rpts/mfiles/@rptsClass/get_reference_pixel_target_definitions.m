function rptsResultsStruct = get_reference_pixel_target_definitions(rptsObject)
% function rptsResultsStruct = get_reference_pixel_target_definitions(rptsObject)
%
% function to create target definitions for stellar, dynamic range, background,
% black, and smear reference pixels.  Target definitions for stellar and dynamic
% range apertures are created by calling TAD/AMA, and each provides an index
% to the existingMasks input table.  Custom target and mask definitions
% are created for background, black, and smear pixels.
%
% INPUT
% rptsObject
%        the following fields are extracted from the object:
%        rptsModuleParametersStruct: [struct]       module parameters
%              moduleOutputImage: [struct array]    image on the module output CCD produced by COA
%               stellarApertures: [struct array]    optimal apertures for selected stellar targets
%          dynamicRangeApertures: [struct array]    optimal 'aperture' for dynamic range targets
%                  existingMasks: [struct array]    input table of mask definitions
%                      debugFlag:                   debug flag
%
% OUTPUTS
% rptsResultsStruct with the following structure fields:
%                  stellarTargetDefinitions: [struct array]
%             dynamicRangeTargetDefinitions: [struct array]
%                backgroundTargetDefinition: [struct array]
%                    blackTargetDefinitions: [struct array]
%                    smearTargetDefinitions: [struct array]
%
%                  backgroundMaskDefinition: [struct array]
%                       blackMaskDefinition: [struct array]
%                       smearMaskDefinition: [struct array]
%
%  *See rptsClass.m for the fields and definitions of above inputs/outputs structures
%   Note: relevant fields in object have already been converted to matlab 1-base in rptsClass.m
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

debugFlag = rptsObject.debugFlag;

close all;
paperOrientationFlag = false;
includeTimeFlag = false;
printJpgFlag = false;

ccdModule     = rptsObject.module;
ccdOutput     = rptsObject.output;
currentModOut = convert_from_module_output(ccdModule, ccdOutput);

%--------------------------------------------------------------------------
% if dynamicRangeApertures are available, create target definitions for
% dynamic range (this function calls TAD/ama)

if (~isempty(rptsObject.dynamicRangeApertures))
    tic
    [dynamicRangeTargetDefinitions] = get_dynamic_range_target_definitions(rptsObject);

    % add results to object
    rptsObject.dynamicRangeTargetDefinitions = dynamicRangeTargetDefinitions;


    nApertures  = length(rptsObject.dynamicRangeApertures);
    nTargetDefs = length(dynamicRangeTargetDefinitions);

    display_rpts_status(['RPTS:get_reference_pixel_target_definitions: ' num2str(nTargetDefs) ' dynamic range target definitions created for ' num2str(nApertures) ' input apertures'], 1);
else
    rptsObject.dynamicRangeTargetDefinitions = [];
    display('RPTS:get_reference_pixel_target_definitions: No dynamic range apertures have been provided; No target/mask definitions created for dynamic range.');
end


%--------------------------------------------------------------------------
% if stellarApertures are available, create stellar, background, smear, and
% black target and mask definitions
%--------------------------------------------------------------------------
if (~isempty(rptsObject.stellarApertures))
    %--------------------------------------------------------------------------
    % create target definitions for stellar targets (this function adds n halos
    % and calls TAD/ama)
    tic
    [stellarTargetDefinitions, stellarIndices] = get_stellar_target_definitions(rptsObject);

    % add results to object
    rptsObject.stellarTargetDefinitions     = stellarTargetDefinitions;
    rptsObject.stellarIndices               = stellarIndices;

    nApertures  = length(rptsObject.stellarApertures);
    nTargetDefs = length(stellarTargetDefinitions);
    display_rpts_status(['RPTS:get_reference_pixel_target_definitions: ' num2str(nTargetDefs) ' stellar target definitions created for ' num2str(nApertures) ' input apertures'], 1);

    %--------------------------------------------------------------------------
    % create target definitions for background pixels (a custom mask is created)
    tic
    [backgroundTargetDefinition, backgroundMaskDefinition, backgroundIndices, ...
        boundingRadius, moduleOutputImageMinusSmear, targetBounds] = ...
        get_background_target_definition(rptsObject, stellarTargetDefinitions);

    % add results to object
    rptsObject.backgroundTargetDefinition   = backgroundTargetDefinition;  % 1-base
    rptsObject.backgroundMaskDefinition     = backgroundMaskDefinition;    % 0-base
    rptsObject.backgroundIndices            = backgroundIndices;

    display_rpts_status(['RPTS:get_reference_pixel_target_definitions: One Background target definition and ' num2str(length([backgroundMaskDefinition.offsets])) ' mask definition offsets created'], 1);

    %--------------------------------------------------------------------------
    % collect smear target and mask definitions (a custom mask is created)
    tic
    [smearTargetDefinitions, smearMaskDefinition] = get_smear_target_definitions(rptsObject);

    % add results to object
    rptsObject.smearTargetDefinitions   = smearTargetDefinitions;
    rptsObject.smearMaskDefinition      = smearMaskDefinition;

    display_rpts_status(['RPTS:get_reference_pixel_target_definitions: ' num2str(length(smearTargetDefinitions)) ' smear target definitions and ' num2str(length([smearMaskDefinition.offsets])) ' mask definition offsets created'], 1);

    %--------------------------------------------------------------------------
    % collect black target and mask definitions (a custom mask is created)
    tic
    [blackTargetDefinitions, blackMaskDefinition] = get_black_target_definitions(rptsObject);

    % add results to object
    rptsObject.blackTargetDefinitions   = blackTargetDefinitions;
    rptsObject.blackMaskDefinition      = blackMaskDefinition;

    display_rpts_status(['RPTS:get_reference_pixel_target_definitions: ' num2str(length(blackTargetDefinitions)) ' black target definitions and ' num2str(length([blackMaskDefinition.offsets])) ' mask definition offsets created'], 1);
else

    % if no stellar apertures are given as input, no background, black or
    % smear pixels are collected.  Set up empty structs for output
    rptsObject.stellarTargetDefinitions     = [];
    rptsObject.backgroundTargetDefinition   = [];
    rptsObject.backgroundMaskDefinition     = [];
    rptsObject.blackTargetDefinitions       = [];
    rptsObject.blackMaskDefinition          = [];
    rptsObject.smearTargetDefinitions       = [];
    rptsObject.smearMaskDefinition          = [];

    display('RPTS:get_reference_pixel_target_definitions: No stellar apertures have been provided; No target/mask definitions created for stellar/background/smear/black. ');
end


%--------------------------------------------------------------------------
% convert row/column target definition outputs from matlab 1-base to java 0-base
% Note that background, smear, and black supermask mask definitions are converted
% to 0-base within their respective get_*_target_defintions algorithms above
%--------------------------------------------------------------------------
[stellarTargetDefinitions, backgroundTargetDefinition, blackTargetDefinitions, ...
    smearTargetDefinitions, dynamicRangeTargetDefinitions] = ...
    convert_rpts_outputs_to_0_base(rptsObject);

% add results to object
rptsObject.stellarTargetDefinitions         = stellarTargetDefinitions;
rptsObject.backgroundTargetDefinition       = backgroundTargetDefinition;
rptsObject.blackTargetDefinitions           = blackTargetDefinitions;
rptsObject.smearTargetDefinitions           = smearTargetDefinitions;
rptsObject.dynamicRangeTargetDefinitions    = dynamicRangeTargetDefinitions;


%--------------------------------------------------------------------------
% plot selected reference pixels and input apertures
%--------------------------------------------------------------------------
if (~isempty(rptsObject.stellarApertures))

    close all;
    plot_reference_pixels(stellarTargetDefinitions, blackTargetDefinitions, ...
        smearTargetDefinitions, backgroundMaskDefinition, blackMaskDefinition, ...
        smearMaskDefinition, rptsObject, targetBounds, boundingRadius, true)

    fileNameStr = ['all_ref_pixels_selected_on_module_'  num2str(ccdModule) '_output_' num2str(ccdOutput) '_modout_' num2str(currentModOut)];
    plot_to_file(fileNameStr, paperOrientationFlag, includeTimeFlag, printJpgFlag);

    %--------------------------------------------------------------------------
    % plot selected reference pixels and input apertures over CCD image
    %--------------------------------------------------------------------------
    figure;
    colormap hot(256);
    imagesc(moduleOutputImageMinusSmear, [0 max(moduleOutputImageMinusSmear(:))/100]);

    hold on
    plot_reference_pixels(stellarTargetDefinitions, blackTargetDefinitions, ...
        smearTargetDefinitions, backgroundMaskDefinition, blackMaskDefinition, ...
        smearMaskDefinition, rptsObject, targetBounds, boundingRadius, false)

    fileNameStr = ['all_ref_pixels_over_module_'  num2str(ccdModule) '_output_' num2str(ccdOutput) '_image'];
    plot_to_file(fileNameStr, paperOrientationFlag, includeTimeFlag, printJpgFlag);
end

%--------------------------------------------------------------------------
% convert structures into struct arrays and create results output structure
%--------------------------------------------------------------------------
rptsResultsStruct = set_result_struct(rptsObject);


%--------------------------------------------------------------------------
% validate fields and bounds of results structure
%--------------------------------------------------------------------------
tic
existingMasks = rptsObject.existingMasks;
fcConstants = rptsObject.fcConstants;

rptsResultsStruct = validate_rpts_results_struct(debugFlag, existingMasks, ...
    fcConstants, rptsResultsStruct);

display_rpts_status('RPTS:get_reference_pixel_target_definitions: Outputs validated, indices converted to Java 0-base, and results struct created', 1);

return