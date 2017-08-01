function [padOutputStruct, nominalPointingStruct] = pad_attitude_reconstruction(padScienceObject, padOutputStruct)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function [padOutputStruct, nominalPointingStruct] = pad_attitude_reconstruction(padScienceObject, padOutputStruct)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% This method determines the reconstructed attitude for PAD.
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Inputs:
%
%         padScienceObject: [object]  an object of padScienceClass
%          padOutputStruct: [struct]  PAD output struct with default values
%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Outputs:
%
%          padOutputStruct: [struct]  PAD output struct with updated values
%    nominalPointingStruct: [struct]  nominal pointing structure
%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%     padOutputStruct is a struct with following fields:
%
%               attitudeSolution: [struct]  reconstructed attitude solution
%                         report: [struct]  report of delta attitude solution
%                 reportFilename: [String]  filename of report
%
%--------------------------------------------------------------------------
%     padOutputStruct.attitudeSolution is a struct with following fields:
%
%                                 ra: [double array]  time series of ra
%                                dec: [double array]  time series of dec
%                               roll: [double array]  time series of roll
%                  covarianceMatrix11: [float array]  time series of covariance matrix element (1,1) 
%                  covarianceMatrix22: [float array]  time series of covariance matrix element (2,2) 
%                  covarianceMatrix33: [float array]  time series of covariance matrix element (3,3) 
%                  covarianceMatrix12: [float array]  time series of covariance matrix element (1,2) 
%                  covarianceMatrix13: [float array]  time series of covariance matrix element (1,3) 
%                  covarianceMatrix23: [float array]  time series of covariance matrix element (2,3) 
%       maxAttitudeFocalPlaneResidual: [float array]  time series of maximum attitude focal plane residual error
%                     gapIndicators: [logical array]  gap indicators of attitude solution time series 
%
%--------------------------------------------------------------------------
%     nominalPointingStruct is a struct with following fields:
%
%                                ra: [double array]  time series of ra
%                               dec: [double array]  time series of dec
%                              roll: [double array]  time series of roll
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

% instantiate raDec2PixClass and pointingClass 
raDec2PixObject = raDec2PixClass(padScienceObject.raDec2PixModel, 'one-based');
pointingObject  = pointingClass(padScienceObject.raDec2PixModel.pointingModel);

% generate attitude solution structure for the input of the mothod pad_attitude_solution()
fprintf('PAD: Generating attitude solution structure ...\n');
attitudeSolutionStruct = pad_generate_attitude_solution_structure(padScienceObject, raDec2PixObject, pointingObject);

% determine reconstructed attitude by calling pad_attitude_solution, which is modified from attitude_solution method in pdqScienceClass
fprintf('PAD: Determining reconstructed attitude solution ...\n');
[padOutputStruct, nominalPointingStruct] = pad_attitude_solution(padScienceObject, attitudeSolutionStruct, padOutputStruct, raDec2PixObject);

% calculate maximum attitude focal plane residual error
fprintf('PAD: Calculating the maximum attitude focal plane residual error ...\n');
padOutputStruct = pad_compute_max_attitude_focal_plane_residual(padScienceObject, padOutputStruct, nominalPointingStruct, raDec2PixObject);

% plot centroid bias over entire focal plane
if ( padScienceObject.padModuleParameters.debugLevel>0 && padScienceObject.padModuleParameters.plottingEnabled==true )

    numCadences = length(padOutputStruct.attitudeSolution.ra);
    
    if numCadences > 5 
        skipFactor = fix((numCadences-1)/5);
        count = 0;
        % make 5 equally cadence spaced plots for the duration of the data
        for cadenceIndex =1:skipFactor:(skipFactor*4+1)
            %for cadenceIndex = 1:length(padScienceObject.cadenceTimes.midTimestamps)
            count = count + 1;
            validFig = pad_plot_centroid_bias_over_entire_focal_plane(padScienceObject, padOutputStruct, nominalPointingStruct, cadenceIndex, raDec2PixObject);
            if validFig
                saveas(1, ['pad_centroids_from_nominal_attitude_and_attitude_solution_' num2str(count) '.fig'])
                saveas(2, ['pad_centroids_from_attitude_solution_and_motion_poly_' num2str(count) '.fig'])
            end
        end

    else 

        for cadenceIndex = 1:numCadences
            validFig = pad_plot_centroid_bias_over_entire_focal_plane(padScienceObject, padOutputStruct, nominalPointingStruct, cadenceIndex, raDec2PixObject);
            if validFig
                saveas(1, ['pad_centroids_from_nominal_attitude_and_attitude_solution_' num2str(cadenceIndex) '.fig'])
                saveas(2, ['pad_centroids_from_attitude_solution_and_motion_poly_' num2str(cadenceIndex) '.fig'])
            end
        end

    end
end

return


