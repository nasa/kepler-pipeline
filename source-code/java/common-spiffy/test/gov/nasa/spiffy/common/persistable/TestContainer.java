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

package gov.nasa.spiffy.common.persistable;

import java.util.LinkedList;
import java.util.List;

public class TestContainer implements Persistable{

    private TestParametersFoo fooConfigurationStruct;
    private TestParametersBar barConfigurationStruct;
    private List<TestTimeSeriesContainer> allTimeSeriesData;
    
    boolean b;
    byte by;
    double d;
    float f;
    int i;
    long l;
    short s;
    char c;
    
    boolean[] ba;
    byte[] bya;
    double[] da;
    float[] fa;
    int[] ia;
    long[] la;
    short[] sa;
    char[] ca;

    double[][] da2;
    String[][] sa2;
    
    @SuppressWarnings("unused")
    private String emptyString = "";
    
    public TestContainer() {
    }

    public static TestContainer populatedTestContainerFactory(){
        TestTimeSeries ts1 = new TestTimeSeries(10, false);
        TestTimeSeries ts2 = new TestTimeSeries(20, true);
        List<TestTimeSeries> tsl1 = new LinkedList<TestTimeSeries>();
        tsl1.add(ts1);
        tsl1.add(ts2);

        TestTimeSeries ts3 = new TestTimeSeries(30, true);
        TestTimeSeries ts4 = new TestTimeSeries(40, false);
        List<TestTimeSeries> tsl2 = new LinkedList<TestTimeSeries>();
        tsl2.add(ts3);
        tsl2.add(ts4);
        
        TestTimeSeriesContainer tsc1 = new TestTimeSeriesContainer(tsl1, 100, 500);
        TestTimeSeriesContainer tsc2 = new TestTimeSeriesContainer(tsl2, 200, 400);
        List<TestTimeSeriesContainer> tscl = new LinkedList<TestTimeSeriesContainer>();
        tscl.add(tsc1);
        tscl.add(tsc2);
        
        TestParametersFoo foo = new TestParametersFoo(42, false, "foo", new String[]{"a","b","c"});
        TestParametersBar bar = new TestParametersBar(42.42F, 123.456789123, (short)2);
        TestContainer testContainer = new TestContainer(foo, bar, tscl);
        
        testContainer.b = true;
        testContainer.by = 42;
        testContainer.d = 42.0;
        testContainer.f = (float) 42.0;
        testContainer.i = 42;
        testContainer.l = 42;
        testContainer.s = 42;
        testContainer.c = '4';
        
        testContainer.ba = new boolean[]{true,false,true};
        testContainer.bya = new byte[]{42,(byte) 152,(byte) 162};
        testContainer.sa = new short[]{42,14111,(short) 45000};
        testContainer.da = new double[]{42.0,52.0,62.0};
        testContainer.fa = new float[]{42.0F,52.0F,62.0F};
        testContainer.ia = new int[]{42,52,66};
        testContainer.la = new long[]{42,43,44};
        testContainer.ca = new char[]{'4','5','6'};
        
        testContainer.da2 = new double[][]{{1.0,2.0},{3.0},{4.0,5.0}};
        
        testContainer.sa2 = new String[][]{{"1,1","1,2","1,3"},{"2,1"},{"3,1","3,2","3,3"}};
        
        return testContainer;
    }

    public TestContainer(TestParametersFoo fooConfigurationStruct, TestParametersBar barConfigurationStruct,
        List<TestTimeSeriesContainer> timeSeriesData) {
        this.fooConfigurationStruct = fooConfigurationStruct;
        this.barConfigurationStruct = barConfigurationStruct;
        this.allTimeSeriesData = timeSeriesData;
    }

    public TestParametersFoo getFooConfigurationStruct() {
        return fooConfigurationStruct;
    }

    public void setFooConfigurationStruct(TestParametersFoo fooConfigurationStruct) {
        this.fooConfigurationStruct = fooConfigurationStruct;
    }

    public TestParametersBar getBarConfigurationStruct() {
        return barConfigurationStruct;
    }

    public void setBarConfigurationStruct(TestParametersBar barConfigurationStruct) {
        this.barConfigurationStruct = barConfigurationStruct;
    }

    public List<TestTimeSeriesContainer> getAllTimeSeriesData() {
        return allTimeSeriesData;
    }

    public void setAllTimeSeriesData(List<TestTimeSeriesContainer> timeSeriesData) {
        this.allTimeSeriesData = timeSeriesData;
    }
    
}
