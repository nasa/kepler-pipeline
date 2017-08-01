function [dvResultsStruct] = generate_ebd_test_data_function(dvResultsStruct)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function [dvResultsStruct] = generate_ebd_test_data_function(dvResultsStruct)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% This function generates data for the unit test of eclipsing binary discrimanation (EBD)
% The genarated data update the corresponding fields of dvResultsStruct.
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
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

nTargets = length(dvResultsStruct.targetResultsStruct);

epochValue          = 0.5;      % MJD
depthValue          = 20;       % ppm
durationValue       = 10;       % hour

periodUncertainty   = 1.24;
epochUncertainty    = 1.13;
depthUncertainty    = 1.26;
durationUncertainty = 1.17;

for iTarget = 1:nTargets

    keplerId = dvResultsStruct.targetResultsStruct(iTarget).keplerId;
    nPlanets = length(dvResultsStruct.targetResultsStruct(iTarget).planetResultsStruct);
    
    for jPlanet=1:nPlanets

        planetNumber        = jPlanet;

        periodValue         = 10 + 2*planetNumber;
        oddPeriodValue      = periodValue;
        evenPeriodValue     = periodValue;

        oddEpochValue       = epochValue;
        evenEpochValue      = oddEpochValue + periodValue;

        oddDepthValue       = depthValue;
        evenDepthValue      = oddDepthValue;

        allModelParameters(1)  = struct('name', 'transitDepthPpm',      'value', depthValue,      'uncertainty', depthUncertainty*(1+0.2*rand(1)),    'fitted', true);
        allModelParameters(2)  = struct('name', 'transitEpochMjd',      'value', epochValue,      'uncertainty', epochUncertainty*(1+0.2*rand(1)),    'fitted', true);
        allModelParameters(3)  = struct('name', 'orbitalPeriodDays',    'value', periodValue,     'uncertainty', periodUncertainty*(1+0.2*rand(1)),   'fitted', true);
        allModelParameters(4)  = struct('name', 'transitDurationHours', 'value', durationValue,   'uncertainty', durationUncertainty*(1+0.2*rand(1)), 'fitted', true);

        oddModelParameters(1)  = struct('name', 'transitDepthPpm',      'value', oddDepthValue,   'uncertainty', depthUncertainty*(1+0.2*rand(1)),    'fitted', true);
        oddModelParameters(2)  = struct('name', 'transitEpochMjd',      'value', oddEpochValue,   'uncertainty', epochUncertainty*(1+0.2*rand(1)),    'fitted', true);
        oddModelParameters(3)  = struct('name', 'orbitalPeriodDays',    'value', oddPeriodValue,  'uncertainty', periodUncertainty*(1+0.2*rand(1)),   'fitted', true);
        oddModelParameters(4)  = struct('name', 'transitDurationHours', 'value', durationValue,   'uncertainty', durationUncertainty*(1+0.2*rand(1)), 'fitted', true);

        evenModelParameters(1) = struct('name', 'transitDepthPpm',      'value', evenDepthValue,  'uncertainty', depthUncertainty*(1+0.2*rand(1)),    'fitted', true);
        evenModelParameters(2) = struct('name', 'transitEpochMjd',      'value', evenEpochValue,  'uncertainty', epochUncertainty*(1+0.2*rand(1)),    'fitted', true);
        evenModelParameters(3) = struct('name', 'orbitalPeriodDays',    'value', evenPeriodValue, 'uncertainty', periodUncertainty*(1+0.2*rand(1)),   'fitted', true);
        evenModelParameters(4) = struct('name', 'transitDurationHours', 'value', durationValue,   'uncertainty', durationUncertainty*(1+0.2*rand(1)), 'fitted', true);

        oneModelParameters(1)  = struct('name', 'transitDepthPpm',      'value', depthValue,      'uncertainty', depthUncertainty,                    'fitted', true);
        oneModelParameters(2)  = struct('name', 'transitEpochMjd',      'value', epochValue,      'uncertainty', epochUncertainty,                    'fitted', true);
        oneModelParameters(3)  = struct('name', 'orbitalPeriodDays',    'value', periodValue,     'uncertainty', periodUncertainty,                   'fitted', true);
        oneModelParameters(4)  = struct('name', 'transitDurationHours', 'value', durationValue,   'uncertainty', durationUncertainty,                 'fitted', true);

        oneTransitFit          = struct('keplerId',        keplerId,                                  ...
                                        'planetNumber',    planetNumber,                              ...
                                        'modelParameters', oneModelParameters );
        singleTransitFits      = repmat(oneTransitFit, 1, jPlanet+3);

        dvResultsStruct.targetResultsStruct(iTarget).planetResultsStruct(jPlanet).allTransitsFit.keplerId           = keplerId;
        dvResultsStruct.targetResultsStruct(iTarget).planetResultsStruct(jPlanet).allTransitsFit.planetNumber       = planetNumber;
        dvResultsStruct.targetResultsStruct(iTarget).planetResultsStruct(jPlanet).allTransitsFit.modelParameters    = allModelParameters;
        
        dvResultsStruct.targetResultsStruct(iTarget).planetResultsStruct(jPlanet).oddTransitsFit.keplerId           = keplerId;
        dvResultsStruct.targetResultsStruct(iTarget).planetResultsStruct(jPlanet).oddTransitsFit.planetNumber       = planetNumber;
        dvResultsStruct.targetResultsStruct(iTarget).planetResultsStruct(jPlanet).oddTransitsFit.modelParameters    = oddModelParameters;
        
        dvResultsStruct.targetResultsStruct(iTarget).planetResultsStruct(jPlanet).evenTransitsFit.keplerId          = keplerId;
        dvResultsStruct.targetResultsStruct(iTarget).planetResultsStruct(jPlanet).evenTransitsFit.planetNumber      = planetNumber;
        dvResultsStruct.targetResultsStruct(iTarget).planetResultsStruct(jPlanet).evenTransitsFit.modelParameters   = evenModelParameters;
         
        dvResultsStruct.targetResultsStruct(iTarget).planetResultsStruct(jPlanet).singleTransitFits                 = singleTransitFits;
        for iTransit = 1:length(singleTransitFits)
            
            dvResultsStruct.targetResultsStruct(iTarget).planetResultsStruct(jPlanet).singleTransitFits(iTransit).modelParameters(2).value        = ...
                epochValue + (iTransit-1)^2*periodValue;
            
            dvResultsStruct.targetResultsStruct(iTarget).planetResultsStruct(jPlanet).singleTransitFits(iTransit).modelParameters(1).uncertainty  = ...
                depthUncertainty*(1+0.2*rand(1));
            dvResultsStruct.targetResultsStruct(iTarget).planetResultsStruct(jPlanet).singleTransitFits(iTransit).modelParameters(2).uncertainty  = ...
                epochUncertainty*(1+0.2*rand(1));
            dvResultsStruct.targetResultsStruct(iTarget).planetResultsStruct(jPlanet).singleTransitFits(iTransit).modelParameters(3).uncertainty  = ...
                periodUncertainty*(1+0.2*rand(1));
            dvResultsStruct.targetResultsStruct(iTarget).planetResultsStruct(jPlanet).singleTransitFits(iTransit).modelParameters(4).uncertainty  = ...
                durationUncertainty*(1+0.2*rand(1));
           
        end

    end

end

return
