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

package gov.nasa.kepler.aft.seeder;

import gov.nasa.kepler.aft.descriptor.TestDataSetDescriptor;
import gov.nasa.kepler.aft.descriptor.TestDataSetDescriptorFactory;
import gov.nasa.kepler.dev.seed.ModelImportParameters;

import java.io.File;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * This class seeds all of the types of spice files with one method call.
 * 
 * @author Miles Cote
 * 
 */
public class SpiceSeeder extends DataStoreSeeder {

    private static final Log log = LogFactory.getLog(SpiceSeeder.class);

    public SpiceSeeder(TestDataSetDescriptor testDescriptor) {
        super(testDescriptor);
    }

    @Override
    public void seed() {
        seed(new ModelImportParameters());
    }

    public void seed(ModelImportParameters modelImportParameters) {

        log.info("Seeding for descriptor " + getTestDescriptor()
            + getTestDescriptor().getType());

        String dataDirectory = TestDataSetDescriptorFactory.getLocalDataDir(getTestDescriptor());

        try {
            log.info("Seeding sclk file");
            File dir = new File(dataDirectory,
                modelImportParameters.getSclkPath());
            new SclkSeeder(getTestDescriptor(), dir.getAbsolutePath()).seed();

            log.info("Seeding leap seconds file");
            dir = new File(dataDirectory,
                modelImportParameters.getLeapSecsPath());
            new LeapSecondsSeeder(getTestDescriptor(), dir.getAbsolutePath()).seed();

            log.info("Seeding planetary ephemeris file");
            dir = new File(dataDirectory,
                modelImportParameters.getPlanetaryEphemPath());
            new PlanetaryEphemerisSeeder(getTestDescriptor(),
                dir.getAbsolutePath()).seed();

            log.info("Seeding spacecraft ephemeris file");
            dir = new File(dataDirectory,
                modelImportParameters.getSpacecraftEphemPath());
            new SpacecraftEphemerisSeeder(getTestDescriptor(),
                dir.getAbsolutePath()).seed();
        } catch (Exception e) {
            throw new IllegalArgumentException("Unable to seed spice files", e);
        }
    }
}
