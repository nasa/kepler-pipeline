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

package gov.nasa.kepler.hibernate.pdq;

import gov.nasa.kepler.hibernate.AbstractCrud;

import java.util.Arrays;
import java.util.List;

import org.hibernate.Query;

/**
 * Create, remove, and retrieve time series based on
 * {@link PdqDbTimeSeriesEntry}.
 * 
 * @author Forrest Girouard
 */
public class PdqDbTimeSeriesCrud extends AbstractCrud {

    public void create(PdqDbTimeSeries dbTimeSeries) {
        remove(dbTimeSeries.getTargetTableId(), dbTimeSeries.getStartCadence(),
            dbTimeSeries.getEndCadence(), dbTimeSeries.getTimeSeriesType());

        for (int cadence = 0; cadence < dbTimeSeries.getValues().length; cadence++) {
            if (dbTimeSeries.getGapIndicators()[cadence]) {
                continue;
            }
            PdqDbTimeSeriesEntry entry = new PdqDbTimeSeriesEntry(
                dbTimeSeries.getTimeSeriesType(),
                dbTimeSeries.getTargetTableId(), cadence
                    + dbTimeSeries.getStartCadence(),
                dbTimeSeries.getValues()[cadence],
                dbTimeSeries.getUncertainties()[cadence],
                dbTimeSeries.getOriginators()[cadence]);
            getSession().save(entry);
        }
    }

    public void create(List<PdqDbTimeSeries> dbTimeSeriesList) {
        for (PdqDbTimeSeries dbTimeSeries : dbTimeSeriesList) {
            create(dbTimeSeries);
        }
    }

    public void remove(int targetTableId, int startCadence, int endCadence,
        PdqDoubleTimeSeriesType timeSeriesType) {

        String deleteQueryStr = "delete PdqDbTimeSeriesEntry "
            + " where targetTableId = :targetTableIdParam "
            + " and timeSeriesType = :timeSeriesType and "
            + " cadence >= :startCadenceParam and cadence <= :endCadenceParam";
        Query deleteQuery = getSession().createQuery(deleteQueryStr);
        deleteQuery.setParameter("targetTableIdParam", targetTableId);
        deleteQuery.setParameter("timeSeriesType", timeSeriesType);
        deleteQuery.setParameter("startCadenceParam", startCadence);
        deleteQuery.setParameter("endCadenceParam", endCadence);

        deleteQuery.executeUpdate();
    }

    public PdqDbTimeSeries retrieve(int targetTableId, int startCadence,
        int endCadence, PdqDoubleTimeSeriesType timeSeriesType) {

        long[] originators = new long[endCadence - startCadence + 1];
        double[] values = new double[originators.length];
        double[] uncertainties = new double[originators.length];
        boolean[] gapIndicators = new boolean[originators.length];
        Arrays.fill(gapIndicators, true);

        // This query is not sorted, this is good. The code below that
        // repacks the entries into the PdqDbTimeSeries does an
        // implicit counting sort. Which is O(n) rather than a generic sort
        // which would be O(n log n)
        String queryStr = "from PdqDbTimeSeriesEntry where "
            + " timeSeriesType = :timeSeriesTypeParam and "
            + " targetTableId = :targetTableIdParam and "
            + " cadence >= :startCadenceParam and "
            + " cadence <= :endCadenceParam";

        Query q = getSession().createQuery(queryStr);
        q.setParameter("timeSeriesTypeParam", timeSeriesType);
        q.setParameter("targetTableIdParam", targetTableId);
        q.setParameter("startCadenceParam", startCadence);
        q.setParameter("endCadenceParam", endCadence);

        List<PdqDbTimeSeriesEntry> entries = list(q);
        for (PdqDbTimeSeriesEntry entry : entries) {
            int i = entry.getCadence() - startCadence;
            originators[i] = entry.getOriginator();
            values[i] = entry.getValue();
            uncertainties[i] = entry.getUncertainty();
            gapIndicators[i] = false;
        }

        return new PdqDbTimeSeries(timeSeriesType, targetTableId, startCadence,
            endCadence, values, uncertainties, gapIndicators, originators);
    }
}
