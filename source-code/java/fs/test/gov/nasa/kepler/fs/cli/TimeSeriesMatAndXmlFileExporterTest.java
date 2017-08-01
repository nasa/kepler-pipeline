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

package gov.nasa.kepler.fs.cli;

import static org.junit.Assert.assertTrue;
import gov.nasa.kepler.fs.api.DoubleTimeSeries;
import gov.nasa.kepler.fs.api.FloatMjdTimeSeries;
import gov.nasa.kepler.fs.api.FloatTimeSeries;
import gov.nasa.kepler.fs.api.FsId;
import gov.nasa.kepler.fs.api.IntTimeSeries;
import gov.nasa.kepler.fs.api.TimeSeries;
import gov.nasa.kepler.fs.xmlbean.FloatMjdTimeSeriesExportDocument;
import gov.nasa.kepler.fs.xmlbean.TimeSeriesExportDocument;
import gov.nasa.spiffy.common.io.Filenames;

import java.io.BufferedWriter;
import java.io.File;
import java.io.FileWriter;
import java.io.IOException;

import org.apache.xmlbeans.XmlException;
import org.junit.Before;
import org.junit.Test;

/**
 * @author Sean McCauliff
 * 
 */
public class TimeSeriesMatAndXmlFileExporterTest {

    private File testRoot;

    /**
     * @throws java.lang.Exception
     */
    @Before
    public void setUp() throws Exception {
        testRoot = new File(Filenames.BUILD_TEST,
            "TimeSeriesMatFileExporterTest");
        testRoot.mkdirs();

    }

    @Test
    public void testTimeSeriesMatFileExporter() throws Exception {
        int[] idata1 = new int[1024];
        int[] idata2 = new int[1024];
        boolean[] gaps = new boolean[1024];
        gaps[32] = true;
        gaps[555] = true;

        incrementFill(idata1, 234215);
        incrementFill(idata2, 6666666);
        IntTimeSeries its1 = new IntTimeSeries(
            new FsId("/matlab-export-test/1"), idata1, 0, idata1.length - 1,
            gaps, 7);
        IntTimeSeries its2 = new IntTimeSeries(new FsId(
            "/matlab-export-test/longer/2"), idata2, 0, idata2.length - 1,
            gaps, 8);
        float[] fdata = new float[1024];
        incrementFill(fdata, 888.0f);
        FloatTimeSeries fts1 = 
            new FloatTimeSeries(new FsId("/float/1"), fdata, 0, fdata.length-1, gaps, 909090);
        double[] ddata = new double[1024];
        incrementFill(ddata, 999.0f);
        DoubleTimeSeries dts1 = 
            new DoubleTimeSeries(new FsId("/double/1"), ddata, 0, ddata.length-1, gaps, 4445555);
        TimeSeries[] allSeries = new TimeSeries[4];
        allSeries[0] = its1;
        allSeries[1] = dts1;
        allSeries[2] = its2;
        allSeries[3] = fts1;

        
        
        TimeSeriesMatFileExporter exporter = new TimeSeriesMatFileExporter();

        File outputFile = new File(testRoot, "timeseries.mat");
        exporter.export(outputFile, allSeries);

        TimeSeriesXmlExporter xmlExporter = new TimeSeriesXmlExporter();
        File xmlFile = new File(testRoot, "test.xml");
        BufferedWriter bwriter = new BufferedWriter(new FileWriter(xmlFile));
        xmlExporter.export(bwriter, allSeries);
        bwriter.close();

        TimeSeriesExportDocument doc = TimeSeriesExportDocument.Factory.parse(xmlFile);
        assertTrue(doc.validate());
    }

    @Test
    public void testMjdTimeSeriesMatFileExporter() throws IOException,
        XmlException {
        double[] mjds1 = new double[2000];
        float[] values1 = new float[2000];
        incrementFill(mjds1, Math.PI);
        incrementFill(values1, (float) Math.E);

        double[] mjds2 = new double[1000];
        float[] values2 = new float[1000];
        incrementFill(mjds2, 666.0);
        incrementFill(values2, (float) 700.0);
        FloatMjdTimeSeries mjdSeries1 = new FloatMjdTimeSeries(new FsId(
            "/mjd/01/kjsdfkjs"), mjds1[0], mjds1[mjds1.length - 1], mjds1,
            values1, 88);
        FloatMjdTimeSeries mjdSeries2 = new FloatMjdTimeSeries(new FsId(
            "/mjd/02/jdsjfkjlsdjf44884ejjdkj"), mjds2[0],
            mjds2[mjds2.length - 1], mjds2, values2, 99);

        File outputFile = new File(testRoot, "mjdExportTest.mat");
        TimeSeriesMatFileExporter exporter = new TimeSeriesMatFileExporter();
        exporter.export(outputFile, new FloatMjdTimeSeries[] { mjdSeries1,
            mjdSeries2 });

        TimeSeriesXmlExporter xmlExporter = new TimeSeriesXmlExporter();
        File xmlFile = new File(testRoot, "mjd.xml");
        BufferedWriter bwriter = new BufferedWriter(new FileWriter(xmlFile));
        xmlExporter.export(bwriter, new FloatMjdTimeSeries[] { mjdSeries1,
            mjdSeries2 });
        bwriter.close();

        FloatMjdTimeSeriesExportDocument doc = FloatMjdTimeSeriesExportDocument.Factory.parse(xmlFile);
        assertTrue(doc.validate());
    }

    private void incrementFill(int[] array, int start) {
        for (int i = 0; i < array.length; i++) {
            array[i] = i + start;
        }
    }

    private void incrementFill(double[] array, double start) {
        for (int i = 0; i < array.length; i++) {
            array[i] = i + start;
        }
    }


    private void incrementFill(float[] array, float start) {
        for (int i = 0; i < array.length; i++) {
            array[i] = i + start;
        }
    }
}
