/*
 * Copyright 2017 United States Government as represented by the
 * Administrator of the National Aeronautics and Space Administration.
 * All Rights Reserved.
 * 
 * This file is available under the terms of the NASA Open Source Agreement
 * (NOSA). You should have received a copy of this agreement with the
 * Kepler source code; see the file NASA-OPEN-SOURCE-AGREEMENT.doc.
 * 
 * No Warranty: THE SUBJECT SOFTWARE IS PROVIDED "AS IS" WITHOUT ANY
 * WARRANTY OF ANY KIND, EITHER EXPRESSED, IMPLIED, OR STATUTORY,
 * INCLUDING, BUT NOT LIMITED TO, ANY WARRANTY THAT THE SUBJECT SOFTWARE
 * WILL CONFORM TO SPECIFICATIONS, ANY IMPLIED WARRANTIES OF
 * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, OR FREEDOM FROM
 * INFRINGEMENT, ANY WARRANTY THAT THE SUBJECT SOFTWARE WILL BE ERROR
 * FREE, OR ANY WARRANTY THAT DOCUMENTATION, IF PROVIDED, WILL CONFORM
 * TO THE SUBJECT SOFTWARE. THIS AGREEMENT DOES NOT, IN ANY MANNER,
 * CONSTITUTE AN ENDORSEMENT BY GOVERNMENT AGENCY OR ANY PRIOR RECIPIENT
 * OF ANY RESULTS, RESULTING DESIGNS, HARDWARE, SOFTWARE PRODUCTS OR ANY
 * OTHER APPLICATIONS RESULTING FROM USE OF THE SUBJECT SOFTWARE.
 * FURTHER, GOVERNMENT AGENCY DISCLAIMS ALL WARRANTIES AND LIABILITIES
 * REGARDING THIRD-PARTY SOFTWARE, IF PRESENT IN THE ORIGINAL SOFTWARE,
 * AND DISTRIBUTES IT "AS IS."
 * 
 * Waiver and Indemnity: RECIPIENT AGREES TO WAIVE ANY AND ALL CLAIMS
 * AGAINST THE UNITED STATES GOVERNMENT, ITS CONTRACTORS AND
 * SUBCONTRACTORS, AS WELL AS ANY PRIOR RECIPIENT. IF RECIPIENT'S USE OF
 * THE SUBJECT SOFTWARE RESULTS IN ANY LIABILITIES, DEMANDS, DAMAGES,
 * EXPENSES OR LOSSES ARISING FROM SUCH USE, INCLUDING ANY DAMAGES FROM
 * PRODUCTS BASED ON, OR RESULTING FROM, RECIPIENT'S USE OF THE SUBJECT
 * SOFTWARE, RECIPIENT SHALL INDEMNIFY AND HOLD HARMLESS THE UNITED
 * STATES GOVERNMENT, ITS CONTRACTORS AND SUBCONTRACTORS, AS WELL AS ANY
 * PRIOR RECIPIENT, TO THE EXTENT PERMITTED BY LAW. RECIPIENT'S SOLE
 * REMEDY FOR ANY SUCH MATTER SHALL BE THE IMMEDIATE, UNILATERAL
 * TERMINATION OF THIS AGREEMENT.
 */

package gov.nasa.kepler.systest.sbt;

import gov.nasa.kepler.common.ModifiedJulianDate;
import gov.nasa.kepler.common.TicToc;
import gov.nasa.kepler.common.persistable.MatPersistableOutputStream;
import gov.nasa.kepler.fc.rolltime.RollTimeOperations;
import gov.nasa.kepler.hibernate.cm.CharacteristicCrud;
import gov.nasa.kepler.hibernate.cm.CharacteristicType;
import gov.nasa.kepler.hibernate.cm.KicCrud;
import gov.nasa.kepler.hibernate.cm.TargetList;
import gov.nasa.kepler.hibernate.cm.TargetListSet;
import gov.nasa.kepler.hibernate.cm.TargetSelectionCrud;
import gov.nasa.kepler.hibernate.pi.ModelMetadataRetrieverLatest;
import gov.nasa.kepler.mc.cm.CelestialObjectOperations;
import gov.nasa.kepler.mc.cm.CelestialObjectParameters;
import gov.nasa.spiffy.common.persistable.Persistable;

import java.io.File;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Iterator;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;

public class SbtRetrieveCharacteristics extends AbstractSbt {

    private static final String SDF_FILE_NAME = "/tmp/sbt-retrieve-characteristics.sdf";
    private static final boolean REQUIRES_DATABASE = true;
    private static final boolean REQUIRES_FILESTORE = true;

    private static final String MAT_FILE_PREFIX = "retrieve-characteristics-";
    private static final String MAT_FILE_SUFFIX = ".mat";

    public static class CharacteristicMapsContainer implements Persistable {
        public List<Integer> keplerIds = new ArrayList<Integer>();
        public List<Integer> startIndices = new ArrayList<Integer>();
        public List<Integer> endIndices = new ArrayList<Integer>();
        public List<String> characteristicTypes = new ArrayList<String>();
        public List<Double> characteristicValues = new ArrayList<Double>();
    }

    public static class OneTargetCharacteristics implements Persistable {
        public int keplerId;
        public String[] types;
        public double[] values;

        public OneTargetCharacteristics(int keplerId, List<String> types,
            List<Double> values) throws Exception {
            this.keplerId = keplerId;
            if (types.size() != values.size()) {
                throw new Exception(
                    "Types and Values must have same length in OneTargetCharacteristics constructor.");
            }

            this.types = new String[types.size()];
            this.values = new double[values.size()];
            for (int ii = 0; ii < types.size(); ++ii) {
                this.types[ii] = types.get(ii);
                this.values[ii] = values.get(ii);
            }
        }
    }

    public static class CharacteristicsContainer implements Persistable {
        public List<OneTargetCharacteristics> characteristics = new ArrayList<OneTargetCharacteristics>();

        public CharacteristicsContainer(
            Map<Integer, Map<CharacteristicType, Double>> characteristicMaps)
            throws Exception {

            Integer[] keplerIds = characteristicMaps.keySet()
                .toArray(new Integer[0]);
            Arrays.sort(keplerIds);
            for (Integer keplerId : keplerIds) {
                Map<CharacteristicType, Double> characteristicMap = characteristicMaps.get(keplerId);

                List<String> names = new ArrayList<String>();
                List<Double> values = new ArrayList<Double>();
                for (CharacteristicType characteristicType : characteristicMap.keySet()) {
                    names.add(characteristicType.getName());
                    values.add(characteristicMap.get(characteristicType));
                }

                System.out.println(keplerId);

                OneTargetCharacteristics otc = new OneTargetCharacteristics(
                    keplerId, names, values);
                this.characteristics.add(otc);
            }
        }
    }

    public static class Results {
        public List<String> matPaths = new LinkedList<String>();
        public int numCharacteristics;
    }

    public static Results retrieveCharacteristicMaps(int ccdModule,
        int ccdOutput, int observingSeason, float minKeplerMag,
        float maxKeplerMag, String matDir, int matChunkSize) throws Exception {

        CharacteristicCrud characteristicCrud = new CharacteristicCrud();
        CelestialObjectOperations celestialObjectOperations = new CelestialObjectOperations(
            new ModelMetadataRetrieverLatest(), false);

        System.out.println("Retrieving Characteristics...");
        List<CelestialObjectParameters> originalCelestialObjectParameters = celestialObjectOperations.retrieveCelestialObjectParameters(
            ccdModule, ccdOutput, observingSeason, minKeplerMag, maxKeplerMag);
        Map<Integer, Map<CharacteristicType, Double>> characteristicMaps = characteristicCrud.retrieveCharacteristicMaps(CelestialObjectOperations.toKeplerIdList(originalCelestialObjectParameters));
        System.out.println("...DONE Retrieving Characteristics (found "
            + characteristicMaps.size() + ")");

        Results r = ConvertToResults(characteristicMaps, matChunkSize, matDir);
        return r;
    }

    public static Results retrieveCharacteristicMaps(int ccdModule,
        int ccdOutput, int observingSeason, String matDir, int matChunkSize)
        throws Exception {

        KicCrud kicCrud = new KicCrud();
        int skyGroupId = kicCrud.retrieveSkyGroupId(ccdModule, ccdOutput,
            observingSeason);

        CharacteristicCrud characteristicCrud = new CharacteristicCrud();

        System.out.println("Retrieving characteristics...");
        Map<Integer, Map<CharacteristicType, Double>> characteristicMaps = characteristicCrud.retrieveCharacteristicMaps(skyGroupId);
        System.out.println("...DONE Retrieving characteristics (found "
            + characteristicMaps.size() + ")");

        Results r = ConvertToResults(characteristicMaps, matChunkSize, matDir);
        return r;
    }

    public static Results ConvertToResults(
        Map<Integer, Map<CharacteristicType, Double>> characteristicMaps,
        int matChunkSize, String matDir) throws Exception {
        Results r = new Results();
        r.numCharacteristics = characteristicMaps.size();
        int chunkNum = 0;
        CharacteristicMapsContainer c = new CharacteristicMapsContainer();

        int iMatlabStartIndex = 1;
        int iMatlabEndIndex = -1;

        Integer[] sortedKeplerIds = characteristicMaps.keySet()
            .toArray(new Integer[0]);
        Arrays.sort(sortedKeplerIds);
        for (Integer keplerId : sortedKeplerIds) {
            c.keplerIds.add(keplerId);

            Map<CharacteristicType, Double> typeAndValue = characteristicMaps.get(keplerId);
            List<String> types = getCharacteristicTypes(typeAndValue);
            List<Double> values = getCharacteristicValues(typeAndValue);
            iMatlabEndIndex = iMatlabStartIndex + types.size() - 1;

            c.characteristicTypes.addAll(types);
            c.characteristicValues.addAll(values);
            c.startIndices.add(iMatlabStartIndex);
            c.endIndices.add(iMatlabEndIndex);

            iMatlabStartIndex = iMatlabEndIndex + 1;

            if (c.keplerIds.size() >= matChunkSize) {
                saveMat(matDir, chunkNum, r.matPaths, c);
                chunkNum++;
                c = new CharacteristicMapsContainer();
                iMatlabStartIndex = 1;
                iMatlabEndIndex = -1;
            }
        }

        // save final (partial) chunk
        saveMat(matDir, chunkNum, r.matPaths, c);

        return r;
    }

    public SbtRetrieveCharacteristics() {
        super(REQUIRES_DATABASE, REQUIRES_FILESTORE);
    }

    private static List<String> getCharacteristicTypes(
        Map<CharacteristicType, Double> typeAndValue) {
        List<String> characteristicTypes = new ArrayList<String>();

        Iterator<CharacteristicType> iterator = typeAndValue.keySet()
            .iterator();
        while (iterator.hasNext()) {
            String characteristicType = iterator.next()
                .toString();
            characteristicTypes.add(characteristicType);
        }

        return characteristicTypes;
    }

    private static List<Double> getCharacteristicValues(
        Map<CharacteristicType, Double> typeAndValue) {
        List<Double> characteristicValues = new ArrayList<Double>();

        Iterator<CharacteristicType> iterator = typeAndValue.keySet()
            .iterator();
        while (iterator.hasNext()) {
            Double characteristicValue = typeAndValue.get(iterator.next());
            characteristicValues.add(characteristicValue);
        }

        return characteristicValues;
    }

    private static void saveMat(String matDir, int chunkNum,
        List<String> matPaths, CharacteristicMapsContainer c) throws Exception {
        System.out.println("Processing chunk: " + chunkNum + " containing "
            + c.keplerIds.size() + " items.");

        String matPath = MAT_FILE_PREFIX + chunkNum + MAT_FILE_SUFFIX;
        File outFile = new File(matDir, matPath);
        MatPersistableOutputStream mpos = new MatPersistableOutputStream(
            outFile);
        System.out.println("Saving: " + matPath);
        mpos.save(c);
        System.out.println("...DONE Saving .mat file");

        matPaths.add(matPath);
    }

    public String retrieveCharacteristics(int ccdModule, int ccdOutput,
        int observingSeason) throws Exception {
        if (! validateDatastores()) {
            return "";
        }
        
        TicToc.tic("Retrieving characteristics...");

        KicCrud kicCrud = new KicCrud();
        int skyGroupId = kicCrud.retrieveSkyGroupId(ccdModule, ccdOutput,
            observingSeason);

        CharacteristicCrud characteristicCrud = new CharacteristicCrud();
        Map<Integer, Map<CharacteristicType, Double>> characteristicMaps = characteristicCrud.retrieveCharacteristicMaps(skyGroupId);
        CharacteristicsContainer container = new CharacteristicsContainer(
            characteristicMaps);

        TicToc.toc();

        return makeSdf(container, SDF_FILE_NAME);
    }

    public String retrieveCharacteristics(int ccdModule, int ccdOutput,
        double mjd) throws Exception {
        int observingSeason = new RollTimeOperations().mjdToSeason(mjd);
        return retrieveCharacteristics(ccdModule, ccdOutput, observingSeason);
    }

    public String retrieveCharacteristics(int ccdModule, int ccdOutput,
        int observingSeason, float minKeplerMag, float maxKeplerMag)
        throws Exception {
        if (! validateDatastores()) {
            return "";
        }
        
        TicToc.tic("Retrieving characteristics...");

        CelestialObjectOperations celestialObjectOperations = new CelestialObjectOperations(
            new ModelMetadataRetrieverLatest(), false);
        List<CelestialObjectParameters> originalCelestialObjectParameters = celestialObjectOperations.retrieveCelestialObjectParameters(
            ccdModule, ccdOutput, observingSeason, minKeplerMag, maxKeplerMag);
        List<Integer> keplerIds = CelestialObjectOperations.toKeplerIdList(originalCelestialObjectParameters);
        CharacteristicsContainer container = containerFromKeplerIds(keplerIds);

        TicToc.toc();

        return makeSdf(container, SDF_FILE_NAME);
    }

    public String retrieveCharacteristics(int ccdModule, int ccdOutput,
        double mjd, float minKeplerMag, float maxKeplerMag) throws Exception {
        int observingSeason = new RollTimeOperations().mjdToSeason(mjd);
        return retrieveCharacteristics(ccdModule, ccdOutput, observingSeason,
            minKeplerMag, maxKeplerMag);
    }

    public String retrieveCharacteristics(String targetListSetName,
        int ccdModule, int ccdOutput) throws Exception {
        if (! validateDatastores()) {
            return "";
        }
        
        TicToc.tic("Retrieving characteristics...");

        TargetSelectionCrud targetSelectionCrud = new TargetSelectionCrud();
        TargetListSet targetListSet = targetSelectionCrud.retrieveTargetListSet(targetListSetName);

        // Get the sky group from the mod/out/targetListSetName:
        Double mjd = ModifiedJulianDate.dateToMjd(targetListSet.getStart());
        int season = new RollTimeOperations().mjdToSeason(mjd);
        int skyGroupId = new KicCrud().retrieveSkyGroupId(ccdModule, ccdOutput,
            season);

        List<String> targetListNames = getTargetListNames(targetListSetName);

        List<Integer> keplerIds = targetSelectionCrud.retrieveKeplerIdsForTargetListNameMatlabFriendly(
            targetListNames, skyGroupId);
        CharacteristicsContainer container = containerFromKeplerIds(keplerIds);

        TicToc.toc();

        return makeSdf(container, SDF_FILE_NAME);
    }

    public String retrieveCharacteristics(String targetListSetName)
        throws Exception {
        if (! validateDatastores()) {
            return "";
        }
        
        TicToc.tic("Retrieving characteristics...");

        List<Integer> keplerIds = targetListSetNameToKeplerIds(targetListSetName);
        CharacteristicsContainer container = containerFromKeplerIds(keplerIds);

        TicToc.toc();

        return makeSdf(container, SDF_FILE_NAME);
    }

    public String retrieveCharacteristics(List<Integer> keplerIds)
        throws Exception {
        if (! validateDatastores()) {
            return "";
        }
        
        TicToc.tic("Retrieving characteristics...");
        CharacteristicsContainer container = containerFromKeplerIds(keplerIds);
        TicToc.toc();

        return makeSdf(container, SDF_FILE_NAME);
    }

    public String retrieveCharacteristics(int minKeplerId, int maxKeplerId)
        throws Exception {
        List<Integer> keplerIds = new ArrayList<Integer>();
        for (int keplerId = minKeplerId; keplerId <= maxKeplerId; ++keplerId) {
            keplerIds.add(keplerId);
        }
        return retrieveCharacteristics(keplerIds);
    }

    private CharacteristicsContainer containerFromKeplerIds(
        List<Integer> keplerIds) throws Exception {
        Map<Integer, Map<CharacteristicType, Double>> characteristicsMap = new CharacteristicCrud().retrieveCharacteristicMaps(keplerIds);
        CharacteristicsContainer container = new CharacteristicsContainer(
            characteristicsMap);
        return container;
    }

    private List<String> getTargetListNames(String targetListSetName) {
        TargetSelectionCrud targetSelectionCrud = new TargetSelectionCrud();
        TargetListSet targetListSet = targetSelectionCrud.retrieveTargetListSet(targetListSetName);
        List<String> targetListNames = new ArrayList<String>();
        for (TargetList targetList : targetListSet.getTargetLists()) {
            targetListNames.add(targetList.getName());
        }
        return targetListNames;
    }

    private List<Integer> targetListSetNameToKeplerIds(String targetListSetName) {
        List<String> targetListNames = getTargetListNames(targetListSetName);
        List<Integer> keplerIds = new TargetSelectionCrud().retrieveKeplerIdsForTargetListName(targetListNames);
        return keplerIds;
    }

    public static void main(String[] args) throws Exception {
        SbtRetrieveCharacteristics sbt = new SbtRetrieveCharacteristics();
        String path = sbt.retrieveCharacteristics(7, 3, 55006.0, 11.0f, 12.0f);
        // sbt.retrieveCharacteristics(7, 3, 55006.0);
        // String path = sbt.retrieveCharacteristics(7, 3, 0, 10.4f, 10.5f);
        System.out.println(path);
        // System.out.println(sbt.retrieveCharacteristics(7, 3, 0, 10.4f,
        // 10.5f));
    }

}
