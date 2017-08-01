function kicsMatlab = convert_kics_java_to_matlab(kicsJava, getCharacteristics)
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
    kicsMatlab = getKicStruct(length(kicsJava));

    t1 = clock();
    for ii = 1:length(kicsJava)        
        kicJava = kicsJava(ii);
        if isempty(kicJava)
            continue
        end

        % KeplerId, RA, and Dec are gauranteed to have values in kicJava.  The rest
        % of the fields have to be wrapped in double() calls to handle
        % null values.
        %
        kicsMatlab(ii).keplerId            = kicJava.keplerId;
        kicsMatlab(ii).ra                  = kicJava.ra.value;
        kicsMatlab(ii).dec                 = kicJava.dec.value;
        
        kicsMatlab(ii).galacticLatitude    = double(kicJava.galacticLatitude.value);
        kicsMatlab(ii).galacticLongitude   = double(kicJava.galacticLongitude.value);
        kicsMatlab(ii).avExtinction        = double(kicJava.avExtinction.value);
        kicsMatlab(ii).d51Mag              = double(kicJava.d51Mag.value);
        kicsMatlab(ii).decProperMotion     = double(kicJava.decProperMotion.value);
        kicsMatlab(ii).ebMinusVRedding     = double(kicJava.ebMinusVRedding.value);
        kicsMatlab(ii).gkColor             = double(kicJava.gkColor.value);
        kicsMatlab(ii).gMag                = double(kicJava.gMag.value);
        kicsMatlab(ii).grColor             = double(kicJava.grColor.value);
        kicsMatlab(ii).gredMag             = double(kicJava.gredMag.value);
        kicsMatlab(ii).iMag                = double(kicJava.iMag.value);
        kicsMatlab(ii).jkColor             = double(kicJava.jkColor.value);
        kicsMatlab(ii).keplerMag           = double(kicJava.keplerMag.value);
        kicsMatlab(ii).log10Metallicity    = double(kicJava.log10Metallicity.value);
        kicsMatlab(ii).log10SurfaceGravity = double(kicJava.log10SurfaceGravity.value);
        kicsMatlab(ii).parallax            = double(kicJava.parallax.value);
        kicsMatlab(ii).radius              = double(kicJava.radius.value);
        kicsMatlab(ii).raProperMotion      = double(kicJava.raProperMotion.value);
        kicsMatlab(ii).rMag                = double(kicJava.rMag.value);
        kicsMatlab(ii).totalProperMotion   = double(kicJava.totalProperMotion.value);
        kicsMatlab(ii).twoMassHMag         = double(kicJava.twoMassHMag.value);
        kicsMatlab(ii).twoMassJMag         = double(kicJava.twoMassJMag.value);
        kicsMatlab(ii).twoMassKMag         = double(kicJava.twoMassKMag.value);
        kicsMatlab(ii).uMag                = double(kicJava.uMag.value);
        kicsMatlab(ii).zMag                = double(kicJava.zMag.value);
        kicsMatlab(ii).alternateSource     = double(kicJava.alternateSource.value);
        kicsMatlab(ii).effectiveTemp       = double(kicJava.effectiveTemp.value);

        kicsMatlab(ii).blendIndicator      = double(kicJava.blendIndicator.value);
        kicsMatlab(ii).catalogId           = double(kicJava.catalogId.value);
        kicsMatlab(ii).photometryQuality   = double(kicJava.photometryQuality.value);
        kicsMatlab(ii).astrophysicsQuality = double(kicJava.astrophysicsQuality.value);
        kicsMatlab(ii).galaxyIndicator     = double(kicJava.galaxyIndicator.value);
        kicsMatlab(ii).internalScpId       = double(kicJava.internalScpId.value);
        kicsMatlab(ii).alternateId         = double(kicJava.alternateId.value);
        kicsMatlab(ii).scpId               = double(kicJava.scpId.value);
        kicsMatlab(ii).twoMassId           = double(kicJava.twoMassId.value);
        kicsMatlab(ii).variableIndicator   = double(kicJava.variableIndicator.value);
        kicsMatlab(ii).skyGroupId          = double(kicJava.skyGroupId);

        kicsMatlab(ii).source              = kicJava.alternateSource.value;
        if mod(ii, 1000) == 0
            t2 = clock();
            disp(sprintf('converting java to matlab: %12d/%d, time for this loop: %.2f seconds', ii, length(kicsJava), etime(t2, t1)));
            t1 = clock();
        end
    end

    if getCharacteristics
        kicsMatlab = retrieve_characteristics_for_kics(kicsMatlab);
    end
return

function kicsOut = retrieve_characteristics_for_kics(kicsOut)
    import java.util.ArrayList
    keplerIdsArrayList = ArrayList();
    
    % Unpack the kic IDs into a separate Java ArrayList:
    %
    for ii=1:length(kicsOut)
        keplerIdsArrayList.add(int32(kicsOut(ii).keplerId));
    end

    import gov.nasa.kepler.hibernate.cm.CharacteristicCrud;
    characteristicCrud = CharacteristicCrud();
    keplerIdToCharacteristicMap = characteristicCrud.retrieveCharacteristicMaps(keplerIdsArrayList);

    t1 = clock();
    for ii=1:length(kicsOut)
        % Must use int32 for the HashMap.get method to see the keplerId as
        % an Integer.
        %
        keplerId = int32(kicsOut(ii).keplerId);
        characteristicMap = keplerIdToCharacteristicMap.get(keplerId);
        if isempty(characteristicMap)
            continue;
        end

        iterator = characteristicMap.entrySet().iterator();
        while iterator.hasNext()
            entry = iterator.next();
            characteristic = [entry.getKey().toString().toCharArray()]';
            value = entry.getValue();

            numCharacteristics = size(kicsOut(ii).characteristics, 1);
            kicsOut(ii).characteristics{numCharacteristics+1, 1} = characteristic;
            kicsOut(ii).characteristics{numCharacteristics+1, 2} = value;
        end
        
        % Sort characteristics and values:
        %
        [bsort isort] = sort({kicsOut(ii).characteristics{:,1}});
        kicsOut(ii).characteristics = {kicsOut(ii).characteristics{isort,1}; kicsOut(ii).characteristics{isort,2}}';

        if mod(ii, 1000) == 0
            t2 = clock();
            disp(sprintf('retrieving characteristics: %12d/%d, time for this loop: %.2f seconds', ii, length(kicsOut), etime(t2, t1)));
            t1 = clock();
        end
    end
return

function kicStruct = getKicStruct(structLength)

    kicStruct = struct( ...
        'dec', [], ...
        'galacticLatitude', [], ...
        'galacticLongitude', [], ...
        'ra', [], ...
        'avExtinction', [], ...
        'd51Mag', [], ...
        'decProperMotion', [], ...
        'ebMinusVRedding', [], ...
        'gkColor', [], ...
        'gMag', [], ...
        'grColor', [], ...
        'gredMag', [], ...
        'iMag', [], ...
        'jkColor', [], ...
        'keplerMag', [], ...
        'log10Metallicity', [], ...
        'log10SurfaceGravity', [], ...
        'parallax', [], ...
        'radius', [], ...
        'raProperMotion', [], ...
        'rMag', [], ...
        'totalProperMotion', [], ...
        'twoMassHMag', [], ...
        'twoMassJMag', [], ...
        'twoMassKMag', [], ...
        'uMag', [], ...
        'zMag', [], ...
        'alternateId', [], ...
        'alternateSource', [], ...
        'astrophysicsQuality', [], ...
        'blendIndicator', [], ...
        'catalogId', [], ...
        'effectiveTemp', [], ...
        'galaxyIndicator', [], ...
        'internalScpId', [], ...
        'photometryQuality', [], ...
        'scpId', [], ...
        'twoMassId', [], ...
        'variableIndicator', [], ...
        'keplerId', [], ...
        'skyGroupId', [], ...
        'source', [], ...
        'characteristics', {});
    kicStruct(structLength).dec = nan;
return
