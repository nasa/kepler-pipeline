function figureOfMerit = fit_multi_aperture_model( ...
    apertureModelConfigStruct, apertureModelArray)
%**************************************************************************
% function figureOfMerit = fit_multi_aperture_model( ...
%     apertureModelConfigStruct, apertureModelArray)
%**************************************************************************
% Use the current PRF and motion models to fit an aperture model to the
% observed pixel data on the specified cadence(s).
% 
% If 'apertureModelConfigStruct' is empty, the current PRF model is used in
% the fit. 
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

    fprintf('Fitting multi-aperture model with static kernel parameter vector =\n\t');
    fprintf('%f  ',apertureModelConfigStruct);
    fprintf('\n');
    
    PLOT_APERTURE_MODELS = false;
           
    nApertures = numel(apertureModelArray);
    
    % Update prfModel if parameters were provided.
    if ~isempty(apertureModelConfigStruct)
        apertureModelArray(1).prfModelHandle.set_static_kernel_param_vector( ...
            apertureModelConfigStruct);
    end
    
    for iAperture = 1:nApertures
                
        % Fit the dynamic model to the observed data and compute residuals
        % for all cadences.
        apertureModelArray(iAperture).fit_observations();
                
%         fprintf('apertureModelArray(1).basisVectors(21,:)) = %f\n', ...
%             apertureModelArray(1).basisVectors(21,:));
%         fprintf('apertureModelArray(1).coefficients = %f\n', ...
%             apertureModelArray(1).coefficients);
        
        if PLOT_APERTURE_MODELS && iAperture == 1
            fprintf('Plotting first aperture ...\n');
            
            figure(1);
            apertureModelClass.plot_aperture_model(apertureModelArray(iAperture));

            % >>>>>> THE FOLLOWING NEEDS UPDATING! Currently we are
            % plotting position-invariant kernels, so we just provide row=1
            % and col=1.
            figure(2); 
            scrsz = get(0,'ScreenSize');
            set(gcf, 'Position',[scrsz(3)/2 scrsz(4)/2 scrsz(3)/2 scrsz(4)/2]);   
            apertureModelArray(iAperture).prfModelHandle.staticKernelObject.plot_kernel(1,1, {'Working Kernel'});
        end
        
    end % for iAperture ...
        
    % Evaluate the objective function.
    residuals = apertureModelClass.get_multi_aperture_residuals( ...
            apertureModelArray );
    figureOfMerit = mean(residuals(:));
    
    fprintf('Figure of merit = %f\n', figureOfMerit);
end     
    
  
%********************************** EOF ***********************************

