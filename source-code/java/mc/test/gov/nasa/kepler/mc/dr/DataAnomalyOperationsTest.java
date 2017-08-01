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

package gov.nasa.kepler.mc.dr;

import static org.junit.Assert.assertEquals;
import gov.nasa.kepler.common.Cadence.CadenceType;
import gov.nasa.kepler.hibernate.dr.DataAnomaly;
import gov.nasa.kepler.hibernate.dr.DataAnomaly.DataAnomalyType;
import gov.nasa.kepler.hibernate.dr.DataAnomalyModel;
import gov.nasa.kepler.mc.dr.MjdToCadence.DataAnomalyFlags;
import gov.nasa.kepler.pi.models.ModelOperations;
import gov.nasa.spiffy.common.jmock.JMockTest;

import java.util.List;

import org.junit.Test;

import com.google.common.collect.ImmutableList;

/**
 * @author Miles Cote
 * 
 */
public class DataAnomalyOperationsTest extends JMockTest {

    private static final int REVISION = 1;

    @SuppressWarnings("unchecked")
    private ModelOperations<DataAnomalyModel> modelOperations = mock(ModelOperations.class);

    @Test
    public void testRetrieveDataAnomalyFlags() {
        CadenceType cadenceType = CadenceType.LONG;
        int startCadence = 100;
        int endCadence = 102;

        List<DataAnomaly> dataAnomalies = ImmutableList.of(
            new DataAnomaly(DataAnomalyType.SAFE_MODE, cadenceType.intValue(),
                101, 102),
            new DataAnomaly(DataAnomalyType.ATTITUDE_TWEAK,
                cadenceType.intValue(), 102, 102));

        allowing(modelOperations).retrieveModel();
        will(returnValue(new DataAnomalyModel(REVISION, dataAnomalies)));

        DataAnomalyOperations dataAnomalyOperations = new DataAnomalyOperations(
            modelOperations);
        DataAnomalyFlags actualDataAnomalyFlags = dataAnomalyOperations.retrieveDataAnomalyFlags(
            cadenceType, startCadence, endCadence);

        boolean[] attitudeTweakFlags = new boolean[3];
        attitudeTweakFlags[2] = true;
        boolean[] safeModeFlags = new boolean[3];
        safeModeFlags[1] = safeModeFlags[2] = true;
        DataAnomalyFlags expectedDataAnomalyFlags = new DataAnomalyFlags(
            attitudeTweakFlags, safeModeFlags, new boolean[3], new boolean[3],
            new boolean[3], new boolean[3], new boolean[3]);

        assertEquals(expectedDataAnomalyFlags, actualDataAnomalyFlags);
    }

    @Test
    public void testRetrieveDuplicateDataAnomalyFlags() {
        CadenceType cadenceType = CadenceType.LONG;
        int startCadence = 100;
        int endCadence = 102;

        List<DataAnomaly> dataAnomalies = ImmutableList.of(new DataAnomaly(
            DataAnomalyType.SAFE_MODE, cadenceType.intValue(), 101, 102),
            new DataAnomaly(DataAnomalyType.SAFE_MODE, cadenceType.intValue(),
                101, 102));

        allowing(modelOperations).retrieveModel();
        will(returnValue(new DataAnomalyModel(REVISION, dataAnomalies)));

        DataAnomalyOperations dataAnomalyOperations = new DataAnomalyOperations(
            modelOperations);
        DataAnomalyFlags actualDataAnomalyFlags = dataAnomalyOperations.retrieveDataAnomalyFlags(
            cadenceType, startCadence, endCadence);

        boolean[] safeModeFlags = new boolean[3];
        safeModeFlags[1] = safeModeFlags[2] = true;
        DataAnomalyFlags expectedDataAnomalyFlags = new DataAnomalyFlags(
            new boolean[3], safeModeFlags, new boolean[3], new boolean[3],
            new boolean[3], new boolean[3], new boolean[3]);

        assertEquals(expectedDataAnomalyFlags, actualDataAnomalyFlags);
    }

    @Test
    public void testRetrieveCadenceToDataAnomalyFlagsDataAnomalyBracketingCadenceRange() {
        CadenceType cadenceType = CadenceType.LONG;
        int startCadence = 100;
        int endCadence = 102;

        List<DataAnomaly> dataAnomalies = ImmutableList.of(new DataAnomaly(
            DataAnomalyType.SAFE_MODE, cadenceType.intValue(), 101, 103));

        allowing(modelOperations).retrieveModel();
        will(returnValue(new DataAnomalyModel(REVISION, dataAnomalies)));

        DataAnomalyOperations dataAnomalyOperations = new DataAnomalyOperations(
            modelOperations);
        DataAnomalyFlags actualDataAnomalyFlags = dataAnomalyOperations.retrieveDataAnomalyFlags(
            cadenceType, startCadence, endCadence);

        boolean[] safeModeFlags = new boolean[3];
        safeModeFlags[1] = safeModeFlags[2] = true;
        DataAnomalyFlags expectedDataAnomalyFlags = new DataAnomalyFlags(
            new boolean[3], safeModeFlags, new boolean[3], new boolean[3],
            new boolean[3], new boolean[3], new boolean[3]);

        assertEquals(expectedDataAnomalyFlags, actualDataAnomalyFlags);
    }
}
