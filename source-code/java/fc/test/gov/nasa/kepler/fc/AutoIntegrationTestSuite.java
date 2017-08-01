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

package gov.nasa.kepler.fc;

import gov.nasa.kepler.fc.importer.TestsImporterGain;
import gov.nasa.kepler.fc.importer.TestsImporterGeometry;
import gov.nasa.kepler.fc.importer.TestsImporterInvalidPixels;
import gov.nasa.kepler.fc.importer.TestsImporterLargeFlat;
import gov.nasa.kepler.fc.importer.TestsImporterLinearity;
import gov.nasa.kepler.fc.importer.TestsImporterPointing;
import gov.nasa.kepler.fc.importer.TestsImporterPrf;
import gov.nasa.kepler.fc.importer.TestsImporterReadNoise;
import gov.nasa.kepler.fc.importer.TestsImporterRollTimes;
import gov.nasa.kepler.fc.importer.TestsImporterSmallFlatFieldImage;
import gov.nasa.kepler.fc.importer.TestsImporterTwoDBlack;
import gov.nasa.kepler.fc.importer.TestsImporterUndershoot;
import junit.framework.JUnit4TestAdapter;
import junit.framework.Test;
import junit.framework.TestSuite;

public class AutoIntegrationTestSuite {
    public static Test suite() {
        TestSuite suite = new TestSuite();

        suite.addTest(new JUnit4TestAdapter(TestsImporterGain.class));
        suite.addTest(new JUnit4TestAdapter(TestsImporterGeometry.class));
        suite.addTest(new JUnit4TestAdapter(TestsImporterInvalidPixels.class));
        suite.addTest(new JUnit4TestAdapter(TestsImporterLargeFlat.class));
        suite.addTest(new JUnit4TestAdapter(TestsImporterLinearity.class));
        suite.addTest(new JUnit4TestAdapter(TestsImporterPointing.class));
        suite.addTest(new JUnit4TestAdapter(TestsImporterPrf.class));
        suite.addTest(new JUnit4TestAdapter(TestsImporterReadNoise.class));
        suite.addTest(new JUnit4TestAdapter(TestsImporterRollTimes.class));
        suite.addTest(new JUnit4TestAdapter(TestsImporterSaturation.class));
        suite.addTest(new JUnit4TestAdapter(
            TestsImporterSmallFlatFieldImage.class));
        suite.addTest(new JUnit4TestAdapter(TestsImporterTwoDBlack.class));
        suite.addTest(new JUnit4TestAdapter(TestsImporterUndershoot.class));

        return suite;
    }
}
