
%compare_hi_lo_fold_resolution
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
clc;
for j=1:100
   
    
    
    
    hiResPeriod1 = testOutputStructHiRes.tpsResults(j).detectedOrbitalPeriodInDays;
    hiResPhase1 = testOutputStructHiRes.tpsResults(j).timeToFirstTransitInDays;
    hiResSigma1 = testOutputStructHiRes.tpsResults(j).maxMultipleEventStatistic;
    
    hiResPeriod2 = testOutputStructHiRes.tpsResults(j+50).detectedOrbitalPeriodInDays;
    hiResPhase2 = testOutputStructHiRes.tpsResults(j+50).timeToFirstTransitInDays;
    hiResSigma2 = testOutputStructHiRes.tpsResults(j+50).maxMultipleEventStatistic;
    
    hiResPeriod3 = testOutputStructHiRes.tpsResults(j+100).detectedOrbitalPeriodInDays;
    hiResPhase3 = testOutputStructHiRes.tpsResults(j+100).timeToFirstTransitInDays;
    hiResSigma3 = testOutputStructHiRes.tpsResults(j+100).maxMultipleEventStatistic;
    
    
    
    loResPeriod1 = testOutputStructLoRes.tpsResults(j).detectedOrbitalPeriodInDays;
    loResPhase1 = testOutputStructLoRes.tpsResults(j).timeToFirstTransitInDays;
    loResSigma1 = testOutputStructLoRes.tpsResults(j).maxMultipleEventStatistic;
    
    loResPeriod2 = testOutputStructLoRes.tpsResults(j+50).detectedOrbitalPeriodInDays;
    loResPhase2 = testOutputStructLoRes.tpsResults(j+50).timeToFirstTransitInDays;
    loResSigma2 = testOutputStructLoRes.tpsResults(j+50).maxMultipleEventStatistic;
    
    loResPeriod3 = testOutputStructLoRes.tpsResults(j+100).detectedOrbitalPeriodInDays;
    loResPhase3 = testOutputStructLoRes.tpsResults(j+100).timeToFirstTransitInDays;
    loResSigma3 = testOutputStructLoRes.tpsResults(j+100).maxMultipleEventStatistic;
    

    
    fprintf('ground truth for target %d\n ', j);
    
     [testInputStruct.tpsTargets(j).insertedPeriodInDays testInputStruct.tpsTargets(j).insertedPhaseInDays testInputStruct.tpsTargets(j).insertedDurationInHours ...
         testInputStruct.tpsTargets(j).insertedTransitDepth]
     
    [hiResPeriod1 hiResPeriod2 hiResPeriod3 loResPeriod1 loResPeriod2 loResPeriod3]
    
    [hiResPhase1 hiResPhase2 hiResPhase3 loResPhase1 loResPhase2 loResPhase3]
    
    [hiResSigma1 hiResSigma2 hiResSigma3  loResSigma1 loResSigma2 loResSigma3]
    
    
    
    pause
    clc
end

