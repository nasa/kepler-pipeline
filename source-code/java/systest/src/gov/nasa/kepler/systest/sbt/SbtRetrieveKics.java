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
import gov.nasa.kepler.fc.rolltime.RollTimeOperations;
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
import java.util.Date;
import java.util.LinkedList;
import java.util.List;

public class SbtRetrieveKics extends AbstractSbt {

    private static final String SDF_FILE_NAME_PREFIX = "sbt-rkics";
    private static final boolean REQUIRES_DATABASE = true;
    private static final boolean REQUIRES_FILESTORE = false;

    private final CelestialObjectOperations celestialObjectOperations;

    public static class KicContainer implements Persistable {
        public List<CelestialObjectParameters> kics = new LinkedList<CelestialObjectParameters>();

        public KicContainer(
            List<CelestialObjectParameters> celestialObjectParameters) {
            this.kics = celestialObjectParameters;
        }

    }

    public SbtRetrieveKics() {
        super(REQUIRES_DATABASE, REQUIRES_FILESTORE);
        this.celestialObjectOperations = new CelestialObjectOperations(
            new ModelMetadataRetrieverLatest(), false);
    }

    public String retrieveKics(List<Integer> keplerIds) throws Exception {
        if (! validateDatastores()) {
            return "";
        }
        
        List<CelestialObjectParameters> celestialObjectParameters = celestialObjectOperations.retrieveCelestialObjectParameters(keplerIds);
        StringBuilder err = new StringBuilder();
        for (int i=0; i < keplerIds.size(); i++) {
        	if (celestialObjectParameters.get(i) == null) {
        		err.append(keplerIds.get(i));
        		err.append(',');
        	}
        }
        if (err.length() != 0) {
        	err.setLength(err.length() - 1);
        	throw new IllegalArgumentException("The following Kepler id(s) do not exist: " + err + ".");
        }
        KicContainer kicContainer = new KicContainer(celestialObjectParameters);

        File sdfFile = File.createTempFile(SDF_FILE_NAME_PREFIX, ".sdf");
        String sdfPath = makeSdf(kicContainer, sdfFile);
        return sdfPath;
    }

    public String retrieveKics(int keplerId) throws Exception {
        return retrieveKics(new ArrayList<Integer>(keplerId));
    }

    public String retrieveKics(String targetListSetName) throws Exception {
        if (! validateDatastores()) {
            return "";
        }
        
        List<String> targetListNames = extractTargetListSetNames(targetListSetName);
        List<Integer> keplerIds = new TargetSelectionCrud().retrieveKeplerIdsForTargetListName(targetListNames);
        KicContainer kicContainer = new KicContainer(
            celestialObjectOperations.retrieveCelestialObjectParameters(keplerIds));

        return makeSdf(kicContainer, SDF_FILE_NAME_PREFIX);
    }

    public String retrieveKics(String targetListSetName, int ccdModule,
        int ccdOutput) throws Exception {
        if (! validateDatastores()) {
            return "";
        }
        
        TargetSelectionCrud targetSelectionCrud = new TargetSelectionCrud();
        TargetListSet targetListSet = targetSelectionCrud.retrieveTargetListSet(targetListSetName);

        int skyGroupId = dateToSkyGroupId(targetListSet.getStart(), ccdModule,
            ccdOutput);
        List<String> targetListNames = extractTargetListSetNames(targetListSetName);

        List<Integer> keplerIds = targetSelectionCrud.retrieveKeplerIdsForTargetListNameMatlabFriendly(
            targetListNames, skyGroupId);
        KicContainer kicContainer = new KicContainer(
            celestialObjectOperations.retrieveCelestialObjectParameters(keplerIds));

        return makeSdf(kicContainer, SDF_FILE_NAME_PREFIX);
    }

    public String retrieveKics(int minKeplerId, int maxKeplerId)
        throws Exception {
        if (! validateDatastores()) {
            return "";
        }
        
        KicContainer kicContainer = new KicContainer(
            celestialObjectOperations.retrieveCelestialObjectParameters(
                minKeplerId, maxKeplerId));
        return makeSdf(kicContainer, SDF_FILE_NAME_PREFIX);
    }

    public String retrieveKics(int ccdModule, int ccdOutput, int observingSeason)
        throws Exception {
        if (! validateDatastores()) {
            return "";
        }
        
        TicToc.tic("Retrieving KICs...");
        KicContainer kicContainer = new KicContainer(
            celestialObjectOperations.retrieveCelestialObjectParameters(
                ccdModule, ccdOutput, observingSeason));
        TicToc.toc();
        System.out.println("Retrieved " + kicContainer.kics.size() + " KICs.");

        return makeSdf(kicContainer, SDF_FILE_NAME_PREFIX);
    }

    public String retrieveKics(int ccdModule, int ccdOutput, double mjd)
        throws Exception {
        int observingSeason = new RollTimeOperations().mjdToSeason(mjd);
        return retrieveKics(ccdModule, ccdOutput, observingSeason);
    }

    public String retrieveKics(int ccdModule, int ccdOutput,
        int observingSeason, float minKeplerMag, float maxKeplerMag)
        throws Exception {
        if (! validateDatastores()) {
            return "";
        }
        
        TicToc.tic("Retrieving KICs...");
        KicContainer kicContainer = new KicContainer(
            celestialObjectOperations.retrieveCelestialObjectParameters(
                ccdModule, ccdOutput, observingSeason, minKeplerMag,
                maxKeplerMag));
        TicToc.toc();
        System.out.println("Retrieved " + kicContainer.kics.size() + " KICs.");

        return makeSdf(kicContainer, SDF_FILE_NAME_PREFIX);
    }

    public String retrieveKics(int ccdModule, int ccdOutput, double mjd,
        float minKeplerMag, float maxKeplerMag) throws Exception {
        int observingSeason = new RollTimeOperations().mjdToSeason(mjd);
        return retrieveKics(ccdModule, ccdOutput, observingSeason,
            minKeplerMag, maxKeplerMag);
    }

    private int dateToSkyGroupId(Date date, int ccdModule, int ccdOutput) {
        double startMjd = ModifiedJulianDate.dateToMjd(date);
        int observingSeason = new RollTimeOperations().mjdToSeason(startMjd);
        int skyGroupId = new KicCrud().retrieveSkyGroupId(ccdModule, ccdOutput,
            observingSeason);
        return skyGroupId;
    }

    private List<String> extractTargetListSetNames(String targetListSetName) {
        TargetListSet targetListSet = new TargetSelectionCrud().retrieveTargetListSet(targetListSetName);
        List<TargetList> targetLists = targetListSet.getTargetLists();
        List<String> targetListNames = new ArrayList<String>();
        for (TargetList targetList : targetLists) {
            targetListNames.add(targetList.getName());
        }
        return targetListNames;
    }

    public static void main(String[] args) throws Exception {
        // produces 3864 kics
        SbtRetrieveKics sbt = new SbtRetrieveKics();
        String sbtPath = sbt.retrieveKics(7, 3, 0, 8F, 15F);
        System.out.println(sbtPath);
    }

}
