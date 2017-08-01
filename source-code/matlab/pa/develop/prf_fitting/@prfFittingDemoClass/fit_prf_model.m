function prfModelObject = fit_prf_model(obj)
%************************************************************************** 
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
    maxIter  = obj.params.optimization.maxIter;
    tolFun   = obj.params.optimization.tolFun;
    tolX     = obj.params.optimization.tolX;
    skParams = obj.params.staticKernelParams;
    
    
    %----------------------------------------------------------------------
    % Construct the aperture model array and fit each aperture to the
    % observed data using the current PRF model. 
    %----------------------------------------------------------------------
    obj.initialize_aperture_array();
%     for iAperture = 1:numel(obj.apertureModelArray)                        
%         obj.apertureModelArray(iAperture).fit_observations();
%     end    
               
    %----------------------------------------------------------------------
    % Replace observed pixels with simulated data, if desired, and
    % initialize the static correction kernel. 
    %----------------------------------------------------------------------
    if obj.params.flags.useSimulatedData
        fprintf('Replacing observed apertures with simulated data ...\n');
                
        % Create the static kernel object for use in the simulation
        if obj.params.simulation.applyStaticKernel
            simulationStaticKernelObj = ...
                staticKernelClass(obj.params.simulation.staticKernelParams);
        else
            simulationStaticKernelObj = [];
        end
        
        % Construct a new PRF model to use for the simulation.
        prfModelObject = prfModelClass(obj.prfModelObject);
        prfModelObject.set_static_kernel_object(simulationStaticKernelObj);
        
        % Simulate pixels for each aperture using the current state of the
        % PRF model. 
        for iAperture = 1:numel(obj.apertureModelArray)
            fprintf('\tSimulating observations for aperture %d ...\n', iAperture);
            
            obj.apertureModelArray(iAperture).set_observed_pixels( ...
                obj.apertureModelArray(iAperture).simulate_pixels(...
                    prfModelObject ...
                ) ...
            );
        end
    end
                    
    %----------------------------------------------------------------------
    % Find the minimizing parameters for the static PRF correction kernel
    % model.
    %----------------------------------------------------------------------   
    fprintf('Fitting the static PRF correction kernel ...\n');
    
    % Perform the minimization
    objectiveFunction = @(x) apertureModelClass.fit_multi_aperture_model(x, obj.apertureModelArray);
    options = optimset( ...
        'MaxIter', maxIter, ...
        'Display', 'iter', ...
        'FunValCheck', 'on',...
        'TolFun', tolFun, ...    % Stop if the function value changes by less than this amount.
        'TolX', tolX ...       % Stop if the param vector moves by less than this amount.
    );
                   
    if license('test', 'Optimization_toolbox')
        % Constrained fit.
        
%        [lb, ub] = obj.prfModelObject.staticKernelObject.get_parameter_bounds
        
        [recoveredParams, figureOfMerit ] = ...
            fmincon(objectiveFunction, ...
            skParams.paramVector, ...
            [], ...                 % A
            [], ...                 % b
            [], ...                 % Aeq
            [], ...                 % beq
            [0.5; 0.5; -0.9], ...  % lb
            [Inf; Inf;  0.9], ...  % ub
            [], ...                 % nonlcon
            options);
    else
        % Unconstrained fit.
        [recoveredParams, figureOfMerit ] = ...
            fminsearch(objectiveFunction, skParams.paramVector, options);
    end
            
    
    % Because a normalization is performed when evaluating the dynamic PRF,
    % fminsearch may find a kernel that fits some multiple of the applied 
    % kernel. We therefore normalize the recovered kernel before doing the
    % final fit.
    apertureModelClass.fit_multi_aperture_model( recoveredParams, obj.apertureModelArray);

    %----------------------------------------------------------------------
    % Find the minimizing parameters for the dynamic PRF correction kernel
    % model.
    %----------------------------------------------------------------------   

    %----------------------------------------------------------------------
    % Construct a new PRF model object (not a handle) and return it.
    %----------------------------------------------------------------------   
    prfModelObject = prfModelClass(obj.prfModelObject);
    
end


%********************************** EOF ***********************************

