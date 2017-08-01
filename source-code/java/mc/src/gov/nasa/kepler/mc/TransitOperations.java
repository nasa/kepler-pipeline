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

package gov.nasa.kepler.mc;

import gov.nasa.kepler.hibernate.mc.EbTransitParameterModel;
import gov.nasa.kepler.hibernate.mc.TransitParameterModel;
import gov.nasa.kepler.hibernate.pi.ModelMetadataRetriever;
import gov.nasa.kepler.hibernate.pi.ModelMetadataRetrieverLatest;
import gov.nasa.kepler.mc.pi.ModelOperationsFactory;
import gov.nasa.kepler.pi.models.ModelOperations;

import java.util.ArrayList;
import java.util.Collection;
import java.util.Collections;
import java.util.List;
import java.util.Map;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

import com.google.common.collect.Lists;
import com.google.common.collect.Maps;

import static gov.nasa.kepler.hibernate.mc.TransitParameterModel.NULL;

/**
 * Generates Transit objects from the database models.
 * 
 * @author Forrest Girouard
 * @author Sean McCauliff
 *
 */
public class TransitOperations {

    private static final Log log = LogFactory.getLog(TransitOperations.class);
    
    private final ModelMetadataRetriever modelMetadataRetriever;
    
    public TransitOperations(ModelMetadataRetriever explicitRetriever) {
        if (explicitRetriever == null) {
            throw new NullPointerException("modelMetadataRetriever");
        }
        this.modelMetadataRetriever = explicitRetriever;
    }
    
    public TransitOperations() {
        modelMetadataRetriever = new ModelMetadataRetrieverLatest();
    }
    
    public Map<Integer, List<Transit>> getTransits(Collection<Integer> keplerIds) {

        ModelOperations<TransitParameterModel> modelOperations = getTransitParameterModelOperations();
        TransitParameterModel transitParameterModel = modelOperations.retrieveModel();
        Map<Integer, Map<String, Map<String, String>>> transitByKeplerIdByKoiId = 
            TransitParameterModel.parseModel(transitParameterModel);
        log.info(transitByKeplerIdByKoiId.size() + " Kepler Ids have transit model parameters.");

        ModelOperations<EbTransitParameterModel> ebModelOperations = getEbTransitParameterModelOperations();
        EbTransitParameterModel ebTransitParameterModel = ebModelOperations.retrieveModel();
        Map<Integer, Map<String, Map<String, String>>> ebTransitByKeplerIdByKoiId =
            EbTransitParameterModel.parseModel(ebTransitParameterModel);
        log.info(ebTransitByKeplerIdByKoiId.size() + " Kepler Ids have eclipsing binary transit model parameters.");

        Map<Integer, List<Transit>> rv = Maps.newHashMapWithExpectedSize(keplerIds.size() * 2);
        for (Integer keplerId : keplerIds) {
            List<Transit> transitsForKeplerId = Lists.newArrayList();
            transitsForKeplerId.addAll(constructTransitsFromModel(keplerId, transitByKeplerIdByKoiId.get(keplerId), false));
            transitsForKeplerId.addAll(constructTransitsFromModel(keplerId, ebTransitByKeplerIdByKoiId.get(keplerId), true));
            rv.put(keplerId, transitsForKeplerId);
        }
        return rv;
    }


    private List<Transit> constructTransitsFromModel(
        int keplerId,
        Map<String, Map<String, String>> transitParametersByKoiId, boolean eb) {
        
        if (transitParametersByKoiId == null ||
            transitParametersByKoiId.isEmpty()) {
            return Collections.emptyList();
        }

        List<Transit> transits = new ArrayList<Transit>();

        for (String koiId : transitParametersByKoiId.keySet()) {
            Map<String, String> parameters = transitParametersByKoiId.get(koiId);

            double epoch = returnDoubleOrDefault(parameters, TransitParameterModel.EPOCH_NAME); 

            float period = returnFloatOrDefault(parameters, TransitParameterModel.PERIOD_NAME);
            
            float duration = returnFloatOrDefault(parameters, TransitParameterModel.DURATION_NAME);
            
            transits.add(new Transit(keplerId, koiId, eb, epoch, period, duration));
        }

        return transits;
    }

    private double returnDoubleOrDefault(Map<String, String> m, String key) {
        if (m == null) {
            return Double.NaN;
        }
        String value = m.get(key);
        if (value == null || value.equals(NULL) ) {
            return Double.NaN;
        }
        return Double.parseDouble(value);
    }
    
    private float returnFloatOrDefault(Map<String, String> m, String key) {
        if (m == null) {
            return Float.NaN;
        }
        String value = m.get(key);
        if (value == null || value.equals(NULL)) {
            return Float.NaN;
        }
        return Float.parseFloat(value);
    }
    
    protected ModelOperations<TransitParameterModel> getTransitParameterModelOperations() {
        return ModelOperationsFactory.getTransitParameterInstance(modelMetadataRetriever);
    }

    protected ModelOperations<EbTransitParameterModel> getEbTransitParameterModelOperations() {
        return ModelOperationsFactory.getEbTransitParameterInstance(modelMetadataRetriever);
    }

}
