% TODO: document this class (MARTIN!!!!!)
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

classdef pdcDebugClass
    
    properties (GetAccess = 'public', SetAccess = 'public')
        storeIntermediates;
        targetsToMonitor = [];
        preparation = struct( 'plotInputs', false, ...
                              'plotGapFilling', false, ...
                              'plotNormalization', false, ...
                              'plotCoarseMap', false, ...
                              'plotHarmonics', false, ...
                              'plotSpsds', false, ...
                              'plotOutliers', false );
        dispCleanTargets;
        map = struct( 'plotSystematics', false );
        finishing = struct( 'plotGoodnessMetric', false, ...
                            'plotGapFilling', false, ...
                            'plotHarmonics', false, ...
                            'plotDenormalization', false, ...
                            'plotFluxFractionCrowdingMetric', false, ...
                            'plotOutlierPropagation', false, ...
                            'plotPou', false );
        intermediateTimeSeries;
        intermediateTimeSeriesLabels;
    end % properties
    
    methods
        % constructor
        function obj = pdcDebugClass()
            obj.storeIntermediates = false;
            obj.preparation.plotInputs = true;
            obj.preparation.plotGapFilling = true;
            obj.preparation.plotNormalization = true;
            obj.preparation.plotCoarseMap = true;
            obj.preparation.plotHarmonics = true;
            obj.preparation.plotSpsds = true;
            obj.preparation.plotOutliers = true;
            obj.dispCleanTargets = true;
            obj.map.plotSystematics = true;
            obj.finishing.plotGoodnessMetric = true;
            obj.finishing.plotGapFilling = true;
            obj.finishing.plotHarmonics = true;
            obj.finishing.plotDenormalization = true;
            obj.finishing.plotOutlierPropagation = true;            
            obj.finishing.plotFluxFractionCrowdingMetric = true;
            obj.finishing.plotPou = true;
            obj.intermediateTimeSeries = cell(0);
            obj.intermediateTimeSeriesLabels = cell(0);
        end % pdcDebugClass()
        
        function obj = set_preparation_plots( obj , flag )
            obj.preparation.plotInputs = flag;
            obj.preparation.plotGapFilling = flag;
            obj.preparation.plotNormalization = flag;
            obj.preparation.plotCoarseMap = flag;
            obj.preparation.plotHarmonics = flag;
            obj.preparation.plotSpsds = flag;
            obj.preparation.plotOutliers = flag;
        end % set_preparation_plots
        
        function obj = set_finishing_plots( obj , flag )
            obj.finishing.plotGoodnessMetric = flag;
            obj.finishing.plotGapFilling = flag;
            obj.finishing.plotHarmonics = flag;
            obj.finishing.plotDenormalization = flag;
            obj.finishing.plotOutlierPropagation = flag;            
            obj.finishing.plotFluxFractionCrowdingMetric = flag;
            obj.finishing.plotPou = flag;
        end % set_finishing_plots
        
        function obj = add_intermediate( obj , name , inTargetDataStruct )
            if (obj.storeIntermediates)
                obj.intermediateTimeSeriesLabels{length(obj.intermediateTimeSeriesLabels)+1} = name;
                obj.intermediateTimeSeries{length(obj.intermediateTimeSeriesLabels)} = [inTargetDataStruct(obj.targetsToMonitor).values];
            end
        end % add_intermediate
        
    end % methods
    
end % classdef
