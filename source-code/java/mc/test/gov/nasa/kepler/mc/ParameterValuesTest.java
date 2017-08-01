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

package gov.nasa.kepler.mc;

import static com.google.common.collect.Lists.newArrayList;
import static org.junit.Assert.assertEquals;
import gov.nasa.kepler.common.Cadence.CadenceType;
import gov.nasa.kepler.hibernate.mc.ObservingLog;
import gov.nasa.kepler.hibernate.mc.ObservingLogModel;
import gov.nasa.spiffy.common.jmock.JMockTest;

import java.util.List;

import org.junit.Before;
import org.junit.Test;

/**
 * @author Miles Cote
 * 
 */
public class ParameterValuesTest extends JMockTest {

    private CadenceType cadenceType = CadenceType.LONG;
    private int startCadence = 100;
    private int endCadence = 200;

    private int quarter = 3;
    private String quarters = String.valueOf(quarter);
    private List<String> quartersList = newArrayList(quarters);

    private String value = "value";
    private List<String> values = newArrayList(value);

    private ObservingLog observingLog = new ObservingLog(-1, -1, -1, -1, -1, quarter, -1, -1, -1);
    private ObservingLog observingLogWithDifferentQuarter = new ObservingLog(-1, -1, -1, -1, -1, quarter + 1, -1, -1, -1);
    private List<ObservingLog> observingLogs = newArrayList(observingLog);

    private ObservingLogModel observingLogModel = mock(ObservingLogModel.class);

    private QuarterToParameterValueMap parameterValues = new QuarterToParameterValueMap(observingLogModel);

    @Before
    public void setUp() {
        allowing(observingLogModel).observingLogsFor(CadenceType.LONG.intValue(), startCadence, endCadence);
        will(returnValue(observingLogs));
    }

    @Test
    public void testGetValue() {
        String actualValue = parameterValues.getValue(quartersList, values, cadenceType, startCadence, endCadence);

        assertEquals(value, actualValue);
    }

    @Test(expected = IllegalArgumentException.class)
    public void testGetValueWithNullQuarters() {
        parameterValues.getValue(null, values, cadenceType, startCadence, endCadence);
    }

    @Test(expected = IllegalArgumentException.class)
    public void testGetValueWithNullValues() {
        parameterValues.getValue(quartersList, null, cadenceType, startCadence, endCadence);
    }

    @Test(expected = IllegalArgumentException.class)
    public void testGetValueWithMoreValuesThanQuarters() {
        parameterValues.getValue(quartersList, newArrayList("a", "b", "c"), cadenceType, startCadence, endCadence);
    }

    @Test(expected = IllegalArgumentException.class)
    public void testGetValueWithNoObservingLogs() {
        observingLogs.clear();

        parameterValues.getValue(quartersList, values, cadenceType, startCadence, endCadence);
    }

    @Test(expected = IllegalArgumentException.class)
    public void testGetValueWithObservingLogsInDifferentQuarters() {
        observingLogs.add(observingLogWithDifferentQuarter);

        parameterValues.getValue(quartersList, values, cadenceType, startCadence, endCadence);
    }

    @Test(expected = IllegalArgumentException.class)
    public void testGetValueWithObservingLogQuarterMissingFromInputQuarters() {
        quartersList = newArrayList(String.valueOf(quarter + 1));

        parameterValues.getValue(quartersList, values, cadenceType, startCadence, endCadence);
    }

    @Test
    public void testGetValueWithAdditionalQCharacters() {
        quartersList = newArrayList("qQqq" + String.valueOf(quarter) + "qQqQ");

        String actualValue = parameterValues.getValue(quartersList, values, cadenceType, startCadence, endCadence);

        assertEquals(value, actualValue);
    }

    @Test
    public void testGetValueWithListOfQuarters() {
        quartersList = newArrayList("1", "3");
        values = newArrayList("differentValue", "value");

        String actualValue = parameterValues.getValue(quartersList, values, cadenceType, startCadence, endCadence);

        assertEquals(value, actualValue);
    }

    @Test
    public void testGetValueWithRangeOfQuarters() {
        quartersList = newArrayList("1", "2:4");
        values = newArrayList("differentValue", "value");

        String actualValue = parameterValues.getValue(quartersList, values, cadenceType, startCadence, endCadence);

        assertEquals(value, actualValue);
    }

}
