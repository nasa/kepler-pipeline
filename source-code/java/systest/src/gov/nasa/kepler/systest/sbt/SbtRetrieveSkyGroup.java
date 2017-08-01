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

import gov.nasa.kepler.common.TicToc;
import gov.nasa.kepler.fc.rolltime.RollTimeOperations;
import gov.nasa.kepler.hibernate.cm.KicCrud;
import gov.nasa.kepler.hibernate.cm.SkyGroup;
import gov.nasa.kepler.hibernate.pi.ModelMetadataRetrieverLatest;
import gov.nasa.kepler.mc.cm.CelestialObjectOperations;
import gov.nasa.spiffy.common.persistable.Persistable;

import java.util.Arrays;

public class SbtRetrieveSkyGroup extends AbstractSbt {
    private static final String SDF_FILE_NAME = "/tmp/sbt-retrieve-sky-group.sdf";
    private static final boolean REQUIRES_DATABASE = true;
    private static final boolean REQUIRES_FILESTORE = false;

    public static class SbtSkyGroup implements Persistable {
        public int skyGroupId;
        public int ccdModule;
        public int ccdOutput;
        public int observingSeason;
        public double mjd;
        public int keplerId;

        public SbtSkyGroup(SkyGroup skyGroup, int keplerId, double mjd) {
            this.skyGroupId = skyGroup.getSkyGroupId();
            this.ccdModule = skyGroup.getCcdModule();
            this.ccdOutput = skyGroup.getCcdOutput();
            this.observingSeason = skyGroup.getObservingSeason();

            this.mjd = mjd;
            this.keplerId = keplerId;
        }

        public SbtSkyGroup(int skyGroupId, int ccdModule, int ccdOutput,
            int observingSeason, double mjd, int keplerId) {
            this.skyGroupId = skyGroupId;
            this.ccdModule = ccdModule;
            this.ccdOutput = ccdOutput;
            this.observingSeason = observingSeason;
            this.mjd = mjd;
            this.keplerId = keplerId;
        }

        public SbtSkyGroup(int skyGroupId, int ccdModule, int ccdOutput,
            int observingSeason, double mjd) {
            this.skyGroupId = skyGroupId;
            this.ccdModule = ccdModule;
            this.ccdOutput = ccdOutput;
            this.observingSeason = observingSeason;
            this.mjd = mjd;
            this.keplerId = -666;
        }
    }

    public SbtRetrieveSkyGroup() {
        super(REQUIRES_DATABASE, REQUIRES_FILESTORE);
    }

    public String retrieveSkyGroup(int keplerId, double mjd) throws Exception {
        if (! validateDatastores()) {
            return "";
        }
        TicToc.tic("Retrieving sky group...");

        int skyGroupId = new CelestialObjectOperations(
            new ModelMetadataRetrieverLatest(), false).retrieveSkyGroupIdsForKeplerIds(
            Arrays.asList(keplerId))
            .get(keplerId);
        int observingSeason = new RollTimeOperations().mjdToSeason(mjd);
        SkyGroup skyGroup = new KicCrud().retrieveSkyGroup(skyGroupId,
            observingSeason);

        SbtSkyGroup sbtSkyGroup = new SbtSkyGroup(skyGroupId,
            skyGroup.getCcdModule(), skyGroup.getCcdOutput(), observingSeason,
            mjd, keplerId);

        System.out.println("...DONE Retrieving sky group.");

        return makeSdf(sbtSkyGroup, SDF_FILE_NAME);
    }

    public String retrieveSkyGroup(int ccdModule, int ccdOutput, double mjd)
        throws Exception {
        if (! validateDatastores()) {
            return "";
        }
        TicToc.tic("Retrieving sky group...");
        RollTimeOperations ops = new RollTimeOperations();
        int observingSeason = ops.mjdToSeason(mjd);
        int skyGroupId = new KicCrud().retrieveSkyGroupId(ccdModule, ccdOutput,
            observingSeason);
        SbtSkyGroup sbtSkyGroup = new SbtSkyGroup(skyGroupId, ccdModule,
            ccdOutput, observingSeason, mjd);
        System.out.println("...DONE Retrieving sky group.");

        return makeSdf(sbtSkyGroup, SDF_FILE_NAME);
    }

    public static void main(String[] args) throws Exception {
        SbtRetrieveSkyGroup sbt = new SbtRetrieveSkyGroup();
        double mjd = 55005.0;
        String a = sbt.retrieveSkyGroup(1723671, mjd);
        String b = sbt.retrieveSkyGroup(2, 4, mjd);
        String c = sbt.retrieveSkyGroup(100002100, mjd);
        System.out.println(a + b + c);

        System.out.println("done");
    }
}
