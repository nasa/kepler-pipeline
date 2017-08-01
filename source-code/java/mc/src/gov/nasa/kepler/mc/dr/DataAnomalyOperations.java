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

package gov.nasa.kepler.mc.dr;

import gov.nasa.kepler.common.Cadence.CadenceType;
import gov.nasa.kepler.hibernate.dr.DataAnomaly;
import gov.nasa.kepler.hibernate.dr.DataAnomaly.DataAnomalyType;
import gov.nasa.kepler.hibernate.dr.DataAnomalyModel;
import gov.nasa.kepler.hibernate.pi.ModelMetadataRetriever;
import gov.nasa.kepler.mc.dr.MjdToCadence.DataAnomalyFlags;
import gov.nasa.kepler.mc.pi.ModelOperationsFactory;
import gov.nasa.kepler.pi.models.ModelOperations;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.TreeSet;

/**
 * This class manages {@link DataAnomaly}s.
 * 
 * @author Miles Cote
 * 
 */
public class DataAnomalyOperations {

    private final ModelOperations<DataAnomalyModel> modelOperations;

    public DataAnomalyOperations(ModelMetadataRetriever modelMetadataRetriever) {
        modelOperations = ModelOperationsFactory.getDataAnomalyInstance(modelMetadataRetriever);
    }

    DataAnomalyOperations(ModelOperations<DataAnomalyModel> modelOperations) {
        this.modelOperations = modelOperations;
    }

    /**
     * @param cadenceType
     * @param startCadence
     * @param endCadence
     * @return a two-dimensional array of data anomaly Types. The first
     * dimension is the cadence and the second dimension is the data anomaly
     * types for that cadence.
     */
    public String[][] retrieveDataAnomalyTypes(CadenceType cadenceType,
        int startCadence, int endCadence) {
        Map<Integer, Set<DataAnomalyType>> cadenceToDataAnomalyTypes = retrieveCadenceToDataAnomalyTypes(
            cadenceType, startCadence, endCadence);

        String[][] dataAnomalyTypeArrays = new String[endCadence - startCadence
            + 1][];
        int cadenceNumber = startCadence;
        for (int i = 0; i < dataAnomalyTypeArrays.length; i++) {
            Set<DataAnomalyType> set = cadenceToDataAnomalyTypes.get(cadenceNumber);
            Iterator<DataAnomalyType> iterator = set.iterator();
            String[] dataAnomalyTypeArray = new String[set.size()];
            for (int j = 0; j < set.size(); j++) {
                dataAnomalyTypeArray[j] = iterator.next()
                    .toString();
            }

            dataAnomalyTypeArrays[i] = dataAnomalyTypeArray;

            cadenceNumber++;
        }

        return dataAnomalyTypeArrays;
    }

    /**
     * @param cadenceType
     * @param startCadence
     * @param endCadence
     * @return an instance of {@code DataAnomalyFlags}. The dimension of all the
     * contained arrays is the number of cadences.
     */
    public DataAnomalyFlags retrieveDataAnomalyFlags(CadenceType cadenceType,
        int startCadence, int endCadence) {

        Map<Integer, Set<DataAnomalyType>> cadenceToDataAnomalyTypes = retrieveCadenceToDataAnomalyTypes(
            cadenceType, startCadence, endCadence);

        boolean[] attitudeTweakIndicators = new boolean[endCadence
            - startCadence + 1];
        boolean[] safeModeIndicators = new boolean[attitudeTweakIndicators.length];
        boolean[] coarsePointIndicators = new boolean[attitudeTweakIndicators.length];
        boolean[] argabrighteningIndicators = new boolean[attitudeTweakIndicators.length];
        boolean[] excludeIndicators = new boolean[attitudeTweakIndicators.length];
        boolean[] earthPointIndicators = new boolean[attitudeTweakIndicators.length];
        boolean[] planetSearchExcludeIndicators = new boolean[attitudeTweakIndicators.length];

        int cadenceNumber = startCadence;
        for (int i = 0; i < attitudeTweakIndicators.length; i++) {
            Set<DataAnomalyType> dataAnomalyTypes = cadenceToDataAnomalyTypes.get(cadenceNumber++);
            if (dataAnomalyTypes != null && dataAnomalyTypes.size() > 0) {
                for (DataAnomalyType dataAnomalyType : dataAnomalyTypes) {
                    switch (dataAnomalyType) {
                        case ATTITUDE_TWEAK:
                            attitudeTweakIndicators[i] = true;
                            break;
                        case SAFE_MODE:
                            safeModeIndicators[i] = true;
                            break;
                        case COARSE_POINT:
                            coarsePointIndicators[i] = true;
                            break;
                        case ARGABRIGHTENING:
                            argabrighteningIndicators[i] = true;
                            break;
                        case EXCLUDE:
                            excludeIndicators[i] = true;
                            break;
                        case EARTH_POINT:
                            earthPointIndicators[i] = true;
                            break;
                        case PLANET_SEARCH_EXCLUDE:
                            planetSearchExcludeIndicators[i] = true;
                            break;
                    }
                }
            }
        }

        return new DataAnomalyFlags(attitudeTweakIndicators,
            safeModeIndicators, coarsePointIndicators,
            argabrighteningIndicators, excludeIndicators, earthPointIndicators,
            planetSearchExcludeIndicators);
    }

    /**
     * @param cadenceType
     * @param startCadence
     * @param endCadence
     * @return a {@link Map} of absolute cadence number to a {@link Set} of
     * {@link DataAnomalyType}s for that cadence number. The map contains an
     * entry for every cadence between startCadence and endCadence (inclusive).
     * If there is no {@link DataAnomalyType} for a particular cadence, then the
     * {@link Map} will contain an empty {@link Set} for that cadence.
     */
    public Map<Integer, Set<DataAnomalyType>> retrieveCadenceToDataAnomalyTypes(
        CadenceType cadenceType, int startCadence, int endCadence) {
        Map<Integer, Set<DataAnomalyType>> cadenceToDataAnomalyTypes = new HashMap<Integer, Set<DataAnomalyType>>();

        // Make sure that a set exists for every cadence.
        for (int cadenceNumber = startCadence; cadenceNumber <= endCadence; cadenceNumber++) {
            cadenceToDataAnomalyTypes.put(cadenceNumber,
                new TreeSet<DataAnomalyType>());
        }

        List<DataAnomaly> dataAnomalies = retrieveDataAnomalies(
            cadenceType.intValue(), startCadence, endCadence);

        for (DataAnomaly dataAnomaly : dataAnomalies) {
            for (int cadenceNumber = dataAnomaly.getStartCadence(); cadenceNumber <= dataAnomaly.getEndCadence(); cadenceNumber++) {
                Set<DataAnomalyType> set = cadenceToDataAnomalyTypes.get(cadenceNumber);
                if (set != null) {
                    set.add(dataAnomaly.getDataAnomalyType());
                }
            }
        }

        return cadenceToDataAnomalyTypes;
    }

    public List<DataAnomaly> retrieveDataAnomalies(int cadenceType,
        int startCadence, int endCadence) {
        List<DataAnomaly> dataAnomalies = new ArrayList<DataAnomaly>();

        DataAnomalyModel model = modelOperations.retrieveModel();
        if (model != null) {
            for (DataAnomaly dataAnomaly : model.getDataAnomalies()) {
                if (dataAnomaly.getCadenceType() == cadenceType
                    && dataAnomaly.getEndCadence() >= startCadence
                    && dataAnomaly.getStartCadence() <= endCadence) {
                    dataAnomalies.add(dataAnomaly);
                }
            }
        }
        return dataAnomalies;
    }
}
