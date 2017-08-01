function check_transits(location, pixStruct)
%
% Copyright 2017 United States Government as represented by the
% Administrator of the National Aeronautics and Space Administration.
% All Rights Reserved.
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
if nargin < 2
    pixStruct = get_pixel_time_series(location, 'targets');
end

% load the science data
load([location filesep 'scienceTargetList.mat']);
% loop through all the light curve types
for curveType = 1:length(targetScienceProperties)
    % this only works for standard descriptions!!
    switch targetScienceProperties(curveType).description
        case 'SOHO-based stellar variability'
            % do nothing
        otherwise 
            show_transit_info(targetScienceProperties(curveType), targetList, pixStruct);            
    end
end

function show_transit_info(targetProp, targetList, pixStruct);
G = get_physical_constants_mks('gravitationalConstant');
curveNum = 2;
for t=1:length(targetProp.keplerId)
    display('');
    display('#############################################');
    display([targetProp.description ' #' num2str(t)]);
    kId = targetProp.keplerId(t);
    pixStructIndex = find(kId == [pixStruct.keplerId]);
    targetStruct = targetList([targetList.keplerId] == kId);
%     disp('orbit data:');
%     disp(targetStruct.lightCurveList(curveNum).initialData);
%     P = convert_to_mks(targetStruct.lightCurveList(curveNum).initialData.orbitalPeriod, 'day');
%     e = targetStruct.lightCurveList(curveNum).initialData.eccentricity;
%     M = convert_to_mks(targetStruct.lightCurveList(curveNum).initialData.primaryPropertiesStruct.mass, ...
%         targetStruct.lightCurveList(curveNum).initialData.primaryPropertiesStruct.massUnits);
%     a = power(power(P/(2*pi),2) * G*M, 1/3);
%     r0 = a*(1-e);
%     radiusUnits = targetStruct.lightCurveList(curveNum).initialData.primaryPropertiesStruct.radiusUnits;
%     disp(['semi-major axis = ' num2str(a/convert_to_mks(1, radiusUnits)) ...
%         ' closest approach = ' num2str(r0/convert_to_mks(1, radiusUnits))]);
%     
%     disp('primary properties:');
%     disp(targetStruct.lightCurveList(curveNum).initialData.primaryPropertiesStruct);
%     disp('secondary properties:');
%     disp(targetStruct.lightCurveList(curveNum).initialData.secondaryPropertiesStruct);
%     transitLightCurve = targetStruct.compositeLightCurve;
%     cadences = 1:length(transitLightCurve);
%     totalLightCurve = sum(pixStruct(pixStructIndex).pixelValues, 2);
%     figure(2000);
%     clf;
%     plotyy(cadences, totalLightCurve, cadences, transitLightCurve-1);
%     pause
    totalLightCurve = sum(pixStruct(pixStructIndex).pixelValues, 2);
    cadences = 1:length(totalLightCurve);
    figure(2000);
    clf;
    plot(cadences, totalLightCurve);
    pause
end