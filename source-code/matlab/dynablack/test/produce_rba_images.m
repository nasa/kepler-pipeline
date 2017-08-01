function result = produce_rba_images(inputsStruct, rbaResults)
% function result = produce_rba_images(inputsStruct, rbaResults)
%
% This is a utility function to plot variation and rolling band flag images.
%
% INPUT:
% inputsStruct      ==  dynabalck inputsStruct
% rbaResults        ==  rolling band results struct stored as 'inputStruct' in dynablack_rba.mat. This can also be produced
%                       from the dynablack blob using the dynablack utility, extract_rba_flags_from_dynablack_blob.m
% OUTPUT:
% result            == dummy is always set to true
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


result = true;

nCadences = length(inputsStruct.cadenceTimes.cadenceNumbers);
nRow = inputsStruct.fcConstants.CCD_ROWS;

for i=1:length(rbaResults)
    figure(1);
    v = nan(nRow,nCadences);
    rows = rbaResults(i).RBA.rowList;
    cadenceList = rbaResults(i).RBA.relCadenceList;
    v(rows,cadenceList) = rbaResults(i).variationLevel;
    imagesc(v);
    axis xy
    caxis([0 10]);
    colorbar;
    xlabel('\bf\fontsize{14}cadence');
    ylabel('\bf\fontsize{14}row');
    title(['\bf\fontsize{16}Normalized Variation - Test Pulse ',num2str(rbaResults(i).testPulseDurationLc),' LC ']);
    a(1) = gca;
    
    figure(2);
    v = nan(nRow,nCadences);
    v(rows,cadenceList) = double(bitget(rbaResults(i).flagsRollingBands,3)) + ...
        2 .* double(bitget(rbaResults(i).flagsRollingBands,4));
    imagesc(v);
    axis xy
    colorbar;
    xlabel('\bf\fontsize{14}cadence');
    ylabel('\bf\fontsize{14}row');
    title(['\bf\fontsize{16}2-bit Level - Test Pulse ',num2str(rbaResults(i).testPulseDurationLc),' LC ']);
    a(2) = gca;
    
    figure(3);
    v = nan(nRow,nCadences);
    v(rows,cadenceList) = double(bitget(rbaResults(i).flagsRollingBands,2));
    imagesc(v);
    axis xy
    xlabel('\bf\fontsize{14}cadence');
    ylabel('\bf\fontsize{14}row');
    title(['\bf\fontsize{16}RBA - Test Pulse ',num2str(rbaResults(i).testPulseDurationLc),' LC ']);
    a(3) = gca;
    
    figure(4);
    v = nan(nRow,nCadences);
    v(rows,cadenceList) = double(bitget(rbaResults(i).flagsRollingBands,1));
    imagesc(v);
    axis xy
    xlabel('\bf\fontsize{14}cadence');
    ylabel('\bf\fontsize{14}row');
    title(['\bf\fontsize{16}Scene Dependent - Test Pulse ',num2str(rbaResults(i).testPulseDurationLc),' LC ']);
    a(4) = gca;
    
    linkaxes(a);    
    pause;    
end

