function transitModel = retrieve_model_light_curve_from_ground_truth( inputModelStruct, barycentricTimestamps )
% function transitModel = retrieve_model_light_curve_from_ground_truth( inputModelStruct, barycentricTimestamps )
%
% This functon returns the model transit used by ETEM for the keplerID and
% the planet number contained in inputModelStruct. If no ground truth file
% exists in the current working directory a zero transit model is returned
% and a warning is thrown. If no keplerID and planet number exists for the 
% input Kepler ID in the ground truth data structures a zero transit model
% is returned.
%
% INPUTS: inputModelStruct      = dvResultsStruct.targetResultsStruct(n).planetResultsStruct(m).allTransitsFit
%                               = (e.g.)
%                                   keplerId: 7538292
%                                   planetNumber: m
%                                   transitModelName: 'groundTruth'
%                                   limbDarkeningModelName: 'claret_nonlinear_limb_darkening_model'
%                                   modelChiSquare: -1
%                                   robustWeights: [3800x1 double]
%                                   modelParameters: [11x1 struct]
%                                   modelParameterCovariance: []
%         barycentricTimestamps = array of barycentric timestamps at which to return the model value; [nTimes x 1]
% OUTPUTS: transitModel         = model value at barycentric timestamps. 
%                                 The transit model according to the transitGeneratorClass definition is zero out-of-transit 
%                                 and 1 - the fractional flux in-transit.
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

% hard coded constants
SECONDS_PER_DAY = 3600 * 24;
INTERP_METHOD = 'linear';
groundTruthFilename = 'dvGroundTruth.mat';

% start with a zero light curve
L = zeros(size(barycentricTimestamps));
t = barycentricTimestamps;

% input model identifies target and planet
keplerID = inputModelStruct.keplerId;
planetNumber = inputModelStruct.planetNumber;

% get current working directory contents
D = dir;


% Assume the ETEM ground truth file is located in the current working
% directory. If it is there, read the file. Otherwise throw a warning and
% return a zero light curve.

if( exist('dvGroundTruth.mat', 'file') )

    % load ground truth and search for keplerID and planetNumber matches
    load(groundTruthFilename);

    % find ground truth target index and/or background index matching the
    % KeplerID in the inputModelStruct
    targetIdx = find([dvTargetList.keplerId]==keplerID, 1);
    backgroundIdx = find([dvBackgroundBinaryList.targetKeplerId]==keplerID, 1);

    % load the light curve if it is there
    if( ~isempty(targetIdx))
        
        if( ~isempty(dvTargetList(targetIdx).lightCurveList) )
            
            if( strcmpi({dvTargetList(targetIdx).lightCurveList(1).description},'SOHO-based stellar variability'));
                planetIndex = planetNumber + 1;
            else
                planetIndex = planetNumber;
            end

            if( length(dvTargetList(targetIdx).lightCurveList) >= planetIndex )
                L = dvTargetList(targetIdx).lightCurveList(planetIndex).lightCurve;
                t = dvTargetList(targetIdx).lightCurveList(planetIndex).timeVector;
            else
                if( ~isempty(backgroundIdx) )
                    L = dvBackgroundBinaryList(backgroundIdx).object.transitingStarObject.transitingOrbitObject.lightCurve;
                    t = dvBackgroundBinaryList(backgroundIdx).object.transitingStarObject.transitingOrbitObject.timeVector;
                end
            end

        else
            if( ~isempty(backgroundIdx) )
                L = dvBackgroundBinaryList(backgroundIdx).object.transitingStarObject.transitingOrbitObject.lightCurve;
                t = dvBackgroundBinaryList(backgroundIdx).object.transitingStarObject.transitingOrbitObject.timeVector;
            end
        end
        
        % Adjust ETEM model bias to match definition from transitGeneratorClass.
        % ETEM transit models are the fractional flux --> == 1 out-of-transit and not 1 == the fractional flux in-transit
        % transitGeneratorClass transit models are (fractional Flux - 1), --> ==0 out of transit and <0 in-transit
        L = L - 1;
        
        % Scale ETEM time vector from seconds to MJD (days) then adjust to KJD to interpolate on barycentric timestamps
        t = ( t./SECONDS_PER_DAY ) - kjd_offset_from_mjd;
    end
else    
    warning('DV:centroidTest:groundTruthNotFound',...
        'File dvGroundTruth.mat not found in current working directory. Returning model lightcurve == 0.');
end

if( ~all(L == 0) )
    % interpolate model light curve at requested timestamps
    transitModel = interp1(t, L, barycentricTimestamps, INTERP_METHOD, 'extrap');
end


