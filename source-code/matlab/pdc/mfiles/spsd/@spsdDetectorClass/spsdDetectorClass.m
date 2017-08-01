%% classdef spsdDetectorClass
% =========================================================================
% Constructs and maintains data models and detection filters for use in
% SPSD detection.
%
% METHODS:
%
%     spsdDetectorClass( spsdDetectorConfigurationStruct )
%
%         Constructor whose only argument is a parameter structure having
%         the same fields as that listed under PROPERTIES.
%
%
% PROPERTIES:
%
%     parameterStruct        : Configuration parameters for the SPSD
%                              detection filter are contained in the
%                              following fields: 
%         .mode                 : 1 = Model each data window as a linear
%                                     combination of polynomials, steps and
%                                     deltas. (CURRENTLY THE ONLY VALID
%                                     MODE)
%         .windowWidth          : The width in cadences of the larger 
%                                 detection filter. 
%         .sgPolyOrder          : The window data model includes
%                                 sgPolyOrder + 1 polynomial basis
%                                 functions P(n,t), where n =
%                                 0,1,...,sgPolyOrder.  
%         .sgStepPolyOrder      : The window data model includes
%                                 sgStepPolyOrder basis functions 
%                                 P(n,t) * u(t), where n =
%                                 1,...,sgStepPolyOrder and u(t) is a unit
%                                 step fuction. 
%         .minWindowWidth       : The minimum window width to consider in 
%                                 the multi-scale portion of the filter
%                                 design algorithm.
%
%         .shortWindowWidth     | These three parameters define a short- 
%         .shortSgPolyOrder     | timescale model to complement the longer 
%         .shortSgStepPolyOrder | model who's parameters are described
%                                 above. Their interpretations are
%                                 identical.
%
%% ========================================================================
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


classdef spsdDetectorClass < handle
    
    %% ---------------------------- Data ----------------------------------
    properties (Constant)
        MODE_SGFILT = 1;             % (DEFAULT) only polynomial S-G filter 
                                     % terms in model.
                                     
        MODE_SGFILT_COTREND = 2;     % Polynomial S-G filter + temporally 
                                     % local cotrend terms in model (TBD).
                                     
        MODE_PIECEWISE = 3;          % Peicewise polymonial fits of the 
                                     % entire time series (TBD).
                                     
        MODE_PIECEWISE_COTREND = 4;  % Peicewise polymonial + cotrend term 
                                     % fits of the entire time series (TBD).       
    end

    properties (GetAccess = 'public', SetAccess = 'private')
        saveAsStruct    = true;
        
        parameterStruct = [];        % A copy of the constructor input .
        
        filter          = [];        % The detection filter kernel 
                                     % (possibly more than one in future 
                                     % versions).
        longModel = ...
            struct('nComponents', 0, ...   % Number of basis vectors comprising the model
                   'designMatrix', [], ... % Full-length basis vectors in rows
                   'pseudoinverse', []);   % Least squares fit coefficients in columns
                        
        shortModel = ...
            struct('nComponents', 0, ...   % Number of basis vectors comprising the model
                   'designMatrix', [], ... % Reduced-scale basis vectors in rows
                   'pseudoinverse', []);   % Least squares fit coefficients in columns, padded to full length
    end
    
    %% ------------------------- Public Methods ---------------------------
    methods 
        %**
        % Constructor.
        function obj = spsdDetectorClass(spsdDetectorConfigurationStruct)
            if nargin > 0
                obj.parameterStruct = spsdDetectorConfigurationStruct;
            else
                obj.parameterStruct = spsdDetectorClass.get_default_param_struct();
            end
            obj.derive_filter();
        end        
        
        function obj = saveobj(obj)
            if obj.saveAsStruct             
                s.MODE_SGFILT            = obj.MODE_SGFILT;            
                s.MODE_SGFILT_COTREND    = obj.MODE_SGFILT_COTREND;            
                s.MODE_PIECEWISE         = obj.MODE_PIECEWISE;            
                s.MODE_PIECEWISE_COTREND = obj.MODE_PIECEWISE_COTREND;                
                s.saveAsStruct           = obj.saveAsStruct;
                s.parameterStruct        = obj.parameterStruct;   
                s.filter                 = obj.filter;   
                s.longModel              = obj.longModel;   
                s.shortModel             = obj.shortModel;   

                obj = s;
            end
        end

    end
    
    %% ------------------------- Private Methods --------------------------
    methods (Access = 'private')
        derive_filter(obj);
    end
  
    %% ------------------------- Static Methods ---------------------------
    % Unfortunately, static properties are not supported in Matlab 2010b,
    % so we need to define constants inside the static methods.
    methods (Static)
        
        isValid         = validate_input(spsdDetectorConfigurationStruct);
        fieldsAndBounds = get_fields_and_bounds(paramStruct);        
        fieldsAndBounds = get_fields_and_bounds_values(paramStruct);
        
        function ps = get_default_param_struct()
            ps = struct( ...
                'mode',                 1, ...
                'windowWidth',        193, ...
                'sgPolyOrder',          3, ...
                'sgStepPolyOrder',      2, ...
                'minWindowWidth',       9, ...
                'shortWindowWidth',    11, ...
                'shortSgPolyOrder',     1, ...
                'shortSgStepPolyOrder', 1 ...
            );
        end

        %**
        % These functions are only called internally. They are declared
        % 'static' to facilitate testing.
        outVector       = pad_and_weight(inVector, outLength, weight);
        zeroIndices     = find_zeros(f);
        modelStruct     = compute_full_model(paramStruct,paddingLength);
        modelStruct     = compute_model(modelLength, polynomialOrder, ...
                                        discontinuityOrder);

        function obj = loadobj(obj)
            if isstruct(obj)
                newObj = spsdDetectorClass();
                
                newObj.parameterStruct  = obj.parameterStruct;
                newObj.filter           = obj.filter;
                newObj.longModel        = obj.longModel;
                newObj.shortModel       = obj.shortModel;

                obj = newObj;
            end
        end

    end % static methods

end

