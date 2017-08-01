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

package gov.nasa.kepler.ui.proxy;

import gov.nasa.kepler.hibernate.AbstractCrud;
import gov.nasa.kepler.hibernate.Canonicalizable;
import gov.nasa.kepler.hibernate.Constraint;
import gov.nasa.kepler.hibernate.cm.CelestialObject;
import gov.nasa.kepler.hibernate.cm.Kic;
import gov.nasa.kepler.hibernate.cm.KicCrud;
import gov.nasa.kepler.hibernate.cm.SortDirection;
import gov.nasa.kepler.hibernate.dbservice.DatabaseService;
import gov.nasa.kepler.mc.cm.CelestialObjectOperations;

import java.lang.management.ManagementFactory;
import java.util.ArrayList;
import java.util.List;

/**
 * Provides a transactional version of {@link CelestialObjectOperations}.
 * 
 * @author Bill Wohler
 */
public class CelestialObjectOperationsProxy extends AbstractCrud {

    private KicCrud kicCrud;

    /**
     * Creates a new {@link CelestialObjectOperationsProxy} object.
     */
    public CelestialObjectOperationsProxy() {
        this(null);
    }

    /**
     * Creates a new {@link CelestialObjectOperationsProxy} object with the
     * specified database service.
     * 
     * @param databaseService the {@link DatabaseService} to use for the
     * operations
     */
    public CelestialObjectOperationsProxy(DatabaseService databaseService) {
        super(databaseService);
        kicCrud = new KicCrud(databaseService);
    }

    /**
     * Returns the approximate maximum number of {@link Kic}s that can be
     * returned before running out of memory.
     */
    public static int getMaxKicResultSetCount() {

        // The divisor is determined empirically. How small can it be and not
        // cause OutOfMemoryExceptions? It was initially calculated with a heap
        // size of 50 MB and tweaked down at 1 GB. The number appears to become
        // more conservative as the amount of memory increases (which is good
        // since it takes longer to get there).
        return (int) (ManagementFactory.getMemoryMXBean()
            .getHeapMemoryUsage()
            .getMax() / 1350L);
    }

    public List<CelestialObject> retrieveCelestialObjects(
        List<Constraint> constraints, Canonicalizable orderColumn,
        SortDirection sortDirection, int rowCount) {

        // TODO Update to use CelestialObjectOperations, rather than KicCrud:
        getDatabaseService().beginTransaction();
        List<Kic> kics = kicCrud.retrieveKics(constraints, orderColumn,
            sortDirection, rowCount);
        getDatabaseService().flush();
        getDatabaseService().commitTransaction();

        List<CelestialObject> celestialObjects = new ArrayList<CelestialObject>(
            kics);

        return celestialObjects;
    }

    void setKicCrud(KicCrud kicCrud) {
        this.kicCrud = kicCrud;
    }

}
