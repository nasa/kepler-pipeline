function inputStruct = inputs_from_pa_data_struct( paDataStruct, ...
     targetIndices, cadenceIndicators)
%**************************************************************************
% inputStruct = inputs_from_pa_data_struct( paDataStruct, ...
%    targetIndices, cadenceIndicators, catalog)
%**************************************************************************
% Construct a valid apertureModelClass input structure from the information
% contained in a paDataStruct. Target indices must be specified. Cadence
% indices may be specified as well. If target structs contain the 'kics'
% field, a catalog is constructed from them. Otherwise an empty matrix is
% assigned to the catalog field of the input struct.
%
% INPUTS
%     paDataStruct      : A PA input object or struct, which MUST have the
%                         field 'motionPolyStruct'. If it doesn't, this
%                         function will throw an error. 
%     targetIndices     : An array of target indices. The union of pixels
%                         comprising the masks of the specified targets is
%                         the "aperture".
%     cadenceIndicators : A logical array indicating cadences to model with
%                         values of 'true'. If not specified, all cadences
%                         are modeled. 
%
% OUTPUTS
%     inputStruct       : An apertureModelClass input structure. See
%                         apertureModelClass for an up-to-date definition
%                         of this structure. 
%
% NOTES
%   - Multiple target indices may be desired if the target masks overlap or
%     contain flux contributions from a common star.  
%   - Missing RA and Dec field (indicated by NaN values) are filled for
%     each target by a call to fill_missing_target_ra_dec(). Note that
%     passing targets with NaN-valued raHours and decDegrees fields to the
%     apertureModelClass constructor will result in an error.
%   - Note that apertureModelInputStruct.cadences will be the empty array
%     because cadenceIndicators is used by this function to prune the
%     target array
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
                         
    % If a paDataClass object was passed, cast it to 'struct' before
    % proceeding. 
    if ~isstruct(paDataStruct)
        paDataStruct = struct(paDataStruct);
    end
    
    % Determine if we are runnign K2 data
    processingK2Data = paDataStruct.cadenceTimes.startTimestamps(1) > ...
                   paDataStruct.fcConstants.KEPLER_END_OF_MISSION_MJD;

    
    % Model all cadences by default. 
    if ~exist('cadenceIndicators', 'var') || isempty(cadenceIndicators)
        cadenceIndicators = ...
            true(length(paDataStruct.cadenceTimes.startTimestamps), 1);
    end
    
    targetArray = paDataStruct.targetStarDataStruct(targetIndices);

    %----------------------------------------------------------------------
    % Construct a local catalog from the 'kics' fields of each target. Note
    % that duplicated entries are ok because they are pruned in
    % apertureModelClass.initialize_contributing_stars().
    %----------------------------------------------------------------------
    if ~exist('catalog', 'var') || isempty(catalog)
        if isfield(targetArray, 'kics')
            catalog = [targetArray.kics];
        else
            catalog = [];
        end
    end    

    %----------------------------------------------------------------------
    % Construct the prf and motion model objects.
    %----------------------------------------------------------------------
    prfModelParams = ...
        prfModelClass.default_param_struct_from_pa_inputs(paDataStruct);
    prfModelObject = prfModelClass( prfModelParams );    
    motionModelObject = ...
        motionModelClass(paDataStruct.motionPolyStruct(cadenceIndicators));
    
    %----------------------------------------------------------------------
    % Prune cadences from target array and fill missing RA and Dec values.
    %----------------------------------------------------------------------
    for iTarget = 1:numel(targetArray)
        
        targetStruct = targetArray(iTarget);
        
        % Prune cadences.
        for iPixel = 1 : numel(targetStruct.pixelDataStruct);
            targetStruct.pixelDataStruct(iPixel).values = ...
                targetStruct.pixelDataStruct(iPixel).values(cadenceIndicators);
            targetStruct.pixelDataStruct(iPixel).uncertainties = ...
                targetStruct.pixelDataStruct(iPixel).uncertainties(cadenceIndicators);
            targetStruct.pixelDataStruct(iPixel).gapIndicators = ...
                targetStruct.pixelDataStruct(iPixel).gapIndicators(cadenceIndicators);
        end

        % Replace NaN-valued RAs and Decs of custom targets with the
        % equivalent RA/Dec of the aperture centroid.
        targetStruct = fill_missing_target_ra_dec( ...
            targetStruct, motionModelObject.get_motion_polynomials, ...
            paDataStruct.fcConstants, processingK2Data);
        
        targetArray(iTarget) = targetStruct;
    end

    %----------------------------------------------------------------------
    % Obtain the twelfth magnitude refernce flux from fcConstants. This is
    % used in converting between flux and magnitude.
    %----------------------------------------------------------------------
    obj.twelfthMagFlux = ...
        paDataStruct.fcConstants.TWELFTH_MAGNITUDE_ELECTRON_FLUX_PER_SECOND;
    
    %----------------------------------------------------------------------
    % Create the input struct.
    %----------------------------------------------------------------------
    inputStruct                   = struct;
    inputStruct.configStruct      = paDataStruct.apertureModelConfigurationStruct;
    inputStruct.targetArray       = targetArray;    
    inputStruct.midTimestamps     = paDataStruct.cadenceTimes.midTimestamps(cadenceIndicators);
    inputStruct.catalog           = catalog;
    inputStruct.prfModelObject    = prfModelObject;
    inputStruct.motionModelObject = motionModelObject;             
    inputStruct.debugLevel        = paDataStruct.paConfigurationStruct.debugLevel;
end

