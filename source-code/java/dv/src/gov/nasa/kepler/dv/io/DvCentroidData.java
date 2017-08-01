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

package gov.nasa.kepler.dv.io;

import gov.nasa.kepler.common.Cadence.CadenceType;
import gov.nasa.kepler.common.pi.FluxTypeParameters.FluxType;
import gov.nasa.kepler.fs.api.FsId;
import gov.nasa.kepler.fs.api.TimeSeries;
import gov.nasa.kepler.mc.CompoundTimeSeries.Centroids;
import gov.nasa.kepler.mc.fs.PaFsIdFactory.CentroidType;
import gov.nasa.spiffy.common.CentroidTimeSeries;
import gov.nasa.spiffy.common.persistable.Persistable;

import java.util.HashSet;
import java.util.Map;
import java.util.Set;

/**
 * Centroid time series data, both flux weighted and PRF-based.
 * 
 * @author Forrest Girouard
 */
public class DvCentroidData implements Persistable {

    private CentroidTimeSeries fluxWeightedCentroids = new CentroidTimeSeries();
    private CentroidTimeSeries prfCentroids = new CentroidTimeSeries();

    /**
     * Creates a {@link DvCentroidData}. For use only by serialization, mock
     * objects, and Hibernate.
     */
    public DvCentroidData() {
    }

    /**
     * Creates a new immutable {@link DvCentroidData} object.
     */
    public DvCentroidData(CentroidTimeSeries fluxWeightedCentroids,
        CentroidTimeSeries prfCentroids) {

        if (fluxWeightedCentroids == null) {
            throw new NullPointerException(
                "fluxWeightedCentroids can't be null");
        }
        if (prfCentroids == null) {
            throw new NullPointerException("prfCentroids can't be null");
        }
        this.fluxWeightedCentroids = fluxWeightedCentroids;
        this.prfCentroids = prfCentroids;
    }

    public static Set<FsId> getRequiredFsIds(FluxType fluxType, int keplerId) {

        Set<FsId> fsIds = new HashSet<FsId>();

        fsIds.addAll(Centroids.getAllFsIds(fluxType,
            CentroidType.FLUX_WEIGHTED, CadenceType.LONG, keplerId));

        return fsIds;
    }

    public static Set<FsId> getOptionalFsIds(FluxType fluxType, int keplerId) {

        Set<FsId> fsIds = new HashSet<FsId>();

        fsIds.addAll(Centroids.getAllFsIds(fluxType, CentroidType.PRF,
            CadenceType.LONG, keplerId));

        return fsIds;
    }

    public static DvCentroidData getInstance(FluxType fluxType, int keplerId,
        int length, Map<FsId, TimeSeries> timeSeries) {

        CentroidTimeSeries fluxWeightedCentroids = Centroids.getInstance(
            fluxType, CentroidType.FLUX_WEIGHTED, CadenceType.LONG, length,
            keplerId, timeSeries);
        CentroidTimeSeries prfCentroids = Centroids.getInstance(
            fluxType, CentroidType.PRF, CadenceType.LONG, length, keplerId,
            timeSeries);

        return new DvCentroidData(fluxWeightedCentroids, prfCentroids);
    }

    public boolean isPopulated() {
        return fluxWeightedCentroids != null
            && !fluxWeightedCentroids.isEmpty() && prfCentroids != null;
    }

    public CentroidTimeSeries getFluxWeightedCentroids() {
        return fluxWeightedCentroids;
    }

    public CentroidTimeSeries getPrfCentroids() {
        return prfCentroids;
    }

    @Override
    public int hashCode() {
        final int prime = 31;
        int result = 1;
        result = prime
            * result
            + (fluxWeightedCentroids == null ? 0
                : fluxWeightedCentroids.hashCode());
        result = prime * result
            + (prfCentroids == null ? 0 : prfCentroids.hashCode());
        return result;
    }

    @Override
    public boolean equals(Object obj) {
        if (this == obj) {
            return true;
        }
        if (obj == null) {
            return false;
        }
        if (getClass() != obj.getClass()) {
            return false;
        }
        DvCentroidData other = (DvCentroidData) obj;
        if (fluxWeightedCentroids == null) {
            if (other.fluxWeightedCentroids != null) {
                return false;
            }
        } else if (!fluxWeightedCentroids.equals(other.fluxWeightedCentroids)) {
            return false;
        }
        if (prfCentroids == null) {
            if (other.prfCentroids != null) {
                return false;
            }
        } else if (!prfCentroids.equals(other.prfCentroids)) {
            return false;
        }
        return true;
    }
}
