function paDataStruct = pa_convert_80_data_to_70(paDataStruct)
%
% function paDataStruct = pa_convert_80_data_to_70(paDataStruct)
%
% Regress 8.0-era PA input structures to 7.0. This is useful when regression testing
% with most recent V&V data sets.
%
% INPUTS:       paDataStruct    = SOC 8.0 paInputsStruct
% OUTPUTS:      paDataStruct    = SOC 7.0 paInputsStruct
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

ancillaryConfigurationStruct = struct('mnemonics',[],...
                                        'modelOrders',[],...
                                        'quantizationLevels',[],...
                                        'intrinsicUncertainties',[],...
                                        'interactions',[]);

attitudeSolutionStruct = struct('ra',[],...
                                'dec',[],...
                                'roll',[],...
                                'maxAttitudeFocalPlaneResidual',[],...
                                'covarianceMatrix11',[],...
                                'covarianceMatrix22',[],...
                                'covarianceMatrix33',[],...
                                'covarianceMatrix12',[],...
                                'covarianceMatrix13',[],...
                                'covarianceMatrix23',[],...
                                'gapIndicators',[]);


% remove unnecessary fields if present
if isfield(paDataStruct.paConfigurationStruct, 'reactionWheelMedianFilterLength')
    paDataStruct.paConfigurationStruct = ...
        rmfield(paDataStruct.paConfigurationStruct, 'reactionWheelMedianFilterLength');
end

if isfield(paDataStruct, 'reactionWheelAncillaryEngineeringConfigurationStruct')
    paDataStruct = rmfield(paDataStruct, 'reactionWheelAncillaryEngineeringConfigurationStruct' );    
end

if isfield(paDataStruct, 'oapAncillaryEngineeringConfigurationStruct')
    paDataStruct.ancillaryEngineeringConfigurationStruct = paDataStruct.oapAncillaryEngineeringConfigurationStruct;
end

if isfield(paDataStruct.gapFillConfigurationStruct, 'removeEclipsingBinariesOnList')
    paDataStruct.gapFillConfigurationStruct.removeShortPeriodEclipsingBinaries = ...
        paDataStruct.gapFillConfigurationStruct.removeEclipsingBinariesOnList;
    paDataStruct.gapFillConfigurationStruct = ...
        rmfield(paDataStruct.gapFillConfigurationStruct, 'removeEclipsingBinariesOnList'); 
end

% remove ancillary engineering data if present
if isfield(paDataStruct, 'ancillaryEngineeringDataStruct')
    paDataStruct.ancillaryEngineeringDataStruct = [];
end

% add necessary fields and default values if not present
if ~isfield(paDataStruct, 'ancillaryEngineeringConfigurationStruct')
    paDataStruct.ancillaryEngineeringConfigurationStruct = ancillaryConfigurationStruct;
end

if ~isfield(paDataStruct, 'attitudeSolutionStruct')
    paDataStruct.attitudeSolutionStruct = attitudeSolutionStruct;
end

return
