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

package gov.nasa.kepler.hibernate.dr;

import gov.nasa.kepler.hibernate.dr.PixelLog.DataSetType;
import gov.nasa.kepler.hibernate.tad.TargetTable.TargetType;
import gov.nasa.spiffy.common.collect.LruCache;

import java.util.List;

/**
 * Caches retrieved {@link PixelLog}s.
 * 
 * @author Miles Cote
 * 
 */
public class PixelLogCache implements PixelLogRetriever {

    private static final int MAX_ITEMS = 10000;
    private static final String SEP = ":";

    static final LruCache<String, Object> lruCache = new LruCache<String, Object>(
        MAX_ITEMS);

    private final PixelLogRetriever pixelLogRetriever;

    public PixelLogCache(PixelLogRetriever pixelLogRetriever) {
        this.pixelLogRetriever = pixelLogRetriever;
    }

    @SuppressWarnings("unchecked")
    @Override
    public List<PixelLog> retrievePixelLog(final int cadenceType,
        final DataSetType dataSetType, final int startCadence,
        final int endCadence) {
        RetrievalMethod method = new RetrievalMethod() {
            @Override
            public Object retrieve() {
                return pixelLogRetriever.retrievePixelLog(cadenceType,
                    dataSetType, startCadence, endCadence);
            }

            @Override
            public String getKey() {
                return cadenceType + SEP + dataSetType + SEP + startCadence
                    + SEP + endCadence;
            }
        };

        return (List<PixelLog>) retrieve(method);
    }

    @SuppressWarnings("unchecked")
    @Override
    public List<PixelLog> retrievePixelLog(final int cadenceType,
        final DataSetType dataSetType, final double mjdStart,
        final double mjdEnd) {
        RetrievalMethod method = new RetrievalMethod() {
            @Override
            public Object retrieve() {
                return pixelLogRetriever.retrievePixelLog(cadenceType,
                    dataSetType, mjdStart, mjdEnd);
            }

            @Override
            public String getKey() {
                return cadenceType + SEP + dataSetType + SEP + mjdStart + SEP
                    + mjdEnd;
            }
        };

        return (List<PixelLog>) retrieve(method);
    }

    @SuppressWarnings("unchecked")
    @Override
    public List<PixelLog> retrievePixelLog(final int cadenceType,
        final int startCadence, final int endCadence) {
        RetrievalMethod method = new RetrievalMethod() {
            @Override
            public Object retrieve() {
                return pixelLogRetriever.retrievePixelLog(cadenceType,
                    startCadence, endCadence);
            }

            @Override
            public String getKey() {
                return cadenceType + SEP + startCadence + SEP + endCadence;
            }
        };

        return (List<PixelLog>) retrieve(method);
    }

    @SuppressWarnings("unchecked")
    @Override
    public List<PixelLog> retrievePixelLog(final int cadenceType,
        final double mjdStart, final double mjdEnd) {
        RetrievalMethod method = new RetrievalMethod() {
            @Override
            public Object retrieve() {
                return pixelLogRetriever.retrievePixelLog(cadenceType,
                    mjdStart, mjdEnd);
            }

            @Override
            public String getKey() {
                return cadenceType + SEP + mjdStart + SEP + mjdEnd;
            }
        };

        return (List<PixelLog>) retrieve(method);
    }

    @SuppressWarnings("unchecked")
    @Override
    public List<PixelLogResult> retrieveTableIdsForCadenceRange(
        final TargetType targetType, final int startCadence,
        final int endCadence) {
        RetrievalMethod method = new RetrievalMethod() {
            @Override
            public Object retrieve() {
                return pixelLogRetriever.retrieveTableIdsForCadenceRange(
                    targetType, startCadence, endCadence);
            }

            @Override
            public String getKey() {
                return targetType + SEP + startCadence + SEP + endCadence;
            }
        };

        return (List<PixelLogResult>) retrieve(method);
    }

    private Object retrieve(RetrievalMethod method) {
        String key = method.getKey();

        Object object = null;
        synchronized (lruCache) {
            object = lruCache.get(key);
            if (object == null) {
                object = method.retrieve();
                lruCache.put(key, object);
            }
        }

        return object;
    }

    private static interface RetrievalMethod {
        public Object retrieve();

        public String getKey();
    }

}
