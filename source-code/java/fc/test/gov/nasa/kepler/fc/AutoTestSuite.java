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

import gov.nasa.kepler.fc.crosstalk.TestsCrossTalk;
import gov.nasa.kepler.fc.flatfield.TestsFlatField;
import gov.nasa.kepler.fc.flatfield.TestsFlatFieldAft;
import gov.nasa.kepler.fc.focalplanegeometry.TestsGeometryOther;
import gov.nasa.kepler.fc.focalplanegeometry.TestsGeometryPersist;
import gov.nasa.kepler.fc.focalplanegeometry.TestsGeometryRetrieve;
import gov.nasa.kepler.fc.gaintable.TestsGain;
import gov.nasa.kepler.fc.invalidpixels.TestsInvalidPixels;
import gov.nasa.kepler.fc.linearitytable.TestsLinearityTable;
import gov.nasa.kepler.fc.pointing.TestsPointing;
import gov.nasa.kepler.fc.prf.TestsPrf;
import gov.nasa.kepler.fc.psf.TestsPsf;
import gov.nasa.kepler.fc.rolltime.TestsRollTime;
import gov.nasa.kepler.fc.scatteredlight.TestsScatteredLight;
import gov.nasa.kepler.fc.twodblack.TestsTwoDBlack;
import gov.nasa.kepler.fc.undershoot.TestsUndershoot;
import gov.nasa.kepler.fc.vignettingobscuration.TestsVignettingObscuration;
import junit.framework.JUnit4TestAdapter;
import junit.framework.Test;
import junit.framework.TestSuite;

public class AutoTestSuite {

    public static Test suite() {
        TestSuite suite = new TestSuite();

        suite.addTest(new JUnit4TestAdapter(TestsCrossTalk.class));
        suite.addTest(new JUnit4TestAdapter(TestsFcConstants.class));
        suite.addTest(new JUnit4TestAdapter(TestsFlatField.class));
        suite.addTest(new JUnit4TestAdapter(TestsFlatFieldAft.class));
        suite.addTest(new JUnit4TestAdapter(TestsGain.class));
        suite.addTest(new JUnit4TestAdapter(TestsGeometryOther.class));
        suite.addTest(new JUnit4TestAdapter(TestsGeometryPersist.class));
        suite.addTest(new JUnit4TestAdapter(TestsGeometryRetrieve.class));
        suite.addTest(new JUnit4TestAdapter(TestsInvalidPixels.class));
        suite.addTest(new JUnit4TestAdapter(TestsLinearityTable.class));
        // suite.addTest(new JUnit4TestAdapter(TestsModelsSerialize.class));
        suite.addTest(new JUnit4TestAdapter(TestsPointing.class));
        suite.addTest(new JUnit4TestAdapter(TestsPrf.class));
        suite.addTest(new JUnit4TestAdapter(TestsPsf.class));
        suite.addTest(new JUnit4TestAdapter(TestsRollTime.class));
        suite.addTest(new JUnit4TestAdapter(TestsSaturationOperations.class));
        suite.addTest(new JUnit4TestAdapter(TestsScatteredLight.class));
        suite.addTest(new JUnit4TestAdapter(TestsTwoDBlack.class));
        suite.addTest(new JUnit4TestAdapter(TestsUndershoot.class));
        suite.addTest(new JUnit4TestAdapter(TestsVignettingObscuration.class));

        return suite;
    }
}
