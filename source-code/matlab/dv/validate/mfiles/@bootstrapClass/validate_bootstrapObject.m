function [validBootstrapObject dvResultsStruct] = ...
    validate_bootstrapObject(bootstrapObject, dvResultsStruct)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function [validBootstrapObject dvResultsStruct] = ...
%       validate_bootstrapObject(bootstrapObject, dvResultsStruct)                      
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Validates the bootstrapObject. The definition of a valid bootstrapObject
% is one in which all the fields in the object warrants construction of the
% histogram and therefore the calling of bootstrap.c
%
% When  a bootstrapObject is labeled as invalid, it means that a histogram
% need not be constructed and appropriate warning messages should be
% thrown and passed on to alerts struct in dvResultsStruct.
%
% The only case in which an invalid bootstrapObject does not throw a
% warning message is when nullTailMaxSigma is less than or equal to
% searchTransitThreshold. In this case, boostrap significance in
% dvResultsStruct is populated with 0.
% 
% A valid boostrapObject signals perform_dv_matlab_controller to proceed
% with bootstrap.c and histogram construction.
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

validBootstrapObject = true;
iTarget = bootstrapObject.targetNumber;
iPlanet = bootstrapObject.planetNumber;
convolutionMethodEnabled = bootstrapObject.convolutionMethodEnabled;
isResultStructAvailable = true;
singleEventStatistics = bootstrapObject.singleEventStatistics;
nPulses = length(singleEventStatistics);

if ~exist('dvResultsStruct','var')
    dvResultsStruct = [];
    isResultStructAvailable = false;
end

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Check if target was flagged as an eclipsing binary
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
if isResultStructAvailable
    if dvResultsStruct.targetResultsStruct(iTarget).planetResultsStruct(iPlanet).planetCandidate.suspectedEclipsingBinary
        validBootstrapObject = false;
        messageString = 'Planet is suspected to be an eclipsing binary, will not proceed with bootstrap';
        warning(messageString) %#ok<WNTAG>

        dvResultsStruct = add_dv_alert(dvResultsStruct, 'bootstrap', ...
            'warning', messageString, bootstrapObject.targetNumber, ...
            bootstrapObject.keplerId, bootstrapObject.planetNumber);

        return
    end
end

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Check validity of observedTransitCount
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
if bootstrapObject.observedTransitCount == 0
    validBootstrapObject = false;
    messageString = 'Observed transit count information not available, will not proceed with bootstrap';
    warning(messageString) %#ok<WNTAG>
    
    if isResultStructAvailable
        dvResultsStruct = add_dv_alert(dvResultsStruct, 'bootstrap', ...
            'warning', messageString, bootstrapObject.targetNumber, ...
            bootstrapObject.keplerId, bootstrapObject.planetNumber);
    end

    return
end

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Check validity of singleEventStatistics
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
if isequal(length(singleEventStatistics),0)
    validBootstrapObject = false;
    messageString = 'Null statistics are empty!  Will not proceed with bootstrap';
    warning(messageString) %#ok<WNTAG>
    
    if isResultStructAvailable
        dvResultsStruct = add_dv_alert(dvResultsStruct, 'bootstrap', ...
            'warning', messageString, bootstrapObject.targetNumber, ...
            bootstrapObject.keplerId, bootstrapObject.planetNumber);
    end

    return
end

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Make sure there are null statistics after deemphasis
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
nValidStatistics = 0;
for i=1:nPulses
    nValidStatistics = nValidStatistics + sum(singleEventStatistics(i).deemphasisWeights.values~=0);
end
if isequal(nValidStatistics,0)
    validBootstrapObject = false;
    messageString = 'Null statistics are entirely de-weighted!  Will not proceed with bootstrap';
    warning(messageString) %#ok<WNTAG>
    
    if isResultStructAvailable
        dvResultsStruct = add_dv_alert(dvResultsStruct, 'bootstrap', ...
            'warning', messageString, bootstrapObject.targetNumber, ...
            bootstrapObject.keplerId, bootstrapObject.planetNumber);
    end

    return
end
    

if ~convolutionMethodEnabled
    planetMes = dvResultsStruct.targetResultsStruct(iTarget).planetResultsStruct(iPlanet).planetCandidate.maxMultipleEventSigma;
    %~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~   
    % Check if nullTailMax is <= searchTransitThreshold
    %~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    if (bootstrapObject.nullTailMaxSigma <= bootstrapObject.searchTransitThreshold)

        validBootstrapObject = false;
        dvResultsStruct.targetResultsStruct(bootstrapObject.targetNumber).planetResultsStruct(bootstrapObject.planetNumber).planetCandidate.significance = 0;
        messageString = 'Max multiple event statistics from residuals less than search transit threshold.  Not generating histogram.  Setting bootstrap significance=0';
        warning(messageString) %#ok<WNTAG>
        dvResultsStruct = add_dv_alert(dvResultsStruct, 'bootstrap', ...
            'warning', messageString, bootstrapObject.targetNumber, ...
            bootstrapObject.keplerId, bootstrapObject.planetNumber);
        return
    end
    
    %~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    % Check Histogram Limits
    %~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    if (bootstrapObject.nullTailMaxSigma == bootstrapObject.nullTailMinSigma || ...
           bootstrapObject.nullTailMaxSigma < bootstrapObject.nullTailMinSigma )
        validBootstrapObject = false;
        messageString = 'Histogram limits yield zero histogram bins!';
        warning(messageString) %#ok<WNTAG>

        if isResultStructAvailable
            dvResultsStruct = add_dv_alert(dvResultsStruct, 'bootstrap', ...
                'warning', messageString, bootstrapObject.targetNumber, ...
                bootstrapObject.keplerId, bootstrapObject.planetNumber);
        end
        return
    end

    %~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    % Check validity of singleEventStatistics. 0 pulse widths means
    % invalid SES
    %~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    numberPulseWidths = bootstrapObject.numberPulseWidths;

    if numberPulseWidths == 0;
        validBootstrapObject = false;
        messageString = 'Invalid single event statistics time series, will not proceed with histogram generation';
        warning(messageString) %#ok<WNTAG>

        dvResultsStruct = add_dv_alert(dvResultsStruct, 'bootstrap', ...
            'warning', messageString, bootstrapObject.targetNumber, ...
            bootstrapObject.keplerId, bootstrapObject.planetNumber);

        return
    end

    %~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    % Check number of transits limit.
    %~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    if (bootstrapObject.observedTransitCount > bootstrapObject.bootstrapMaxAllowedTransitCount && ...
            bootstrapObject.bootstrapMaxAllowedTransitCount ~= -1)
        validBootstrapObject = false;
        messageString = 'Number of observed Transits is larger than the bootstrapMaxAllowedTransitCount!';
        warning(messageString) %#ok<WNTAG>

        dvResultsStruct = add_dv_alert(dvResultsStruct, 'bootstrap', ...
            'warning', messageString, bootstrapObject.targetNumber, ...
            bootstrapObject.keplerId, bootstrapObject.planetNumber);
        return
    end

    %~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    % Check MES limit
    %~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    if (planetMes > bootstrapObject.bootstrapMaxAllowedMes && ...
            bootstrapObject.bootstrapMaxAllowedMes ~= -1)
        validBootstrapObject = false;
        messageString = 'MES for this planet is larger than bootstrapMaxAllowedMES!';
        warning(messageString) %#ok<WNTAG>

        dvResultsStruct = add_dv_alert(dvResultsStruct, 'bootstrap', ...
            'warning', messageString, bootstrapObject.targetNumber, ...
            bootstrapObject.keplerId, bootstrapObject.planetNumber);
        return
    end

end
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

return

