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

package gov.nasa.kepler.ar.exporter;

import static gov.nasa.kepler.common.FitsConstants.*;
import static org.junit.Assert.assertEquals;
import gov.nasa.kepler.ar.exporter.primary.TargetPrimaryHeaderFormatter;
import gov.nasa.kepler.ar.exporter.primary.TargetPrimaryHeaderSource;
import gov.nasa.kepler.common.*;
import gov.nasa.kepler.common.FitsConstants.ObservingMode;
import gov.nasa.kepler.hibernate.cm.CelestialObject;
import gov.nasa.spiffy.common.io.FileUtil;
import gov.nasa.spiffy.common.io.Filenames;

import java.io.*;
import java.util.Calendar;
import java.util.Date;

import nom.tam.fits.Header;
import nom.tam.fits.HeaderCard;

import org.jmock.Expectations;
import org.jmock.Mockery;
import org.jmock.integration.junit4.JMock;
import org.jmock.lib.legacy.ClassImposteriser;
import org.junit.After;
import org.junit.Before;
import org.junit.Test;
import org.junit.runner.RunWith;

import static gov.nasa.kepler.ar.exporter.MockUtils.createMinimalCelestialObject;

/**
 * @author Sean McCauliff
 *
 */
@RunWith(JMock.class)
public class PrimaryHeaderFormatterTest {

    private Mockery mockery;
    private final int KEPLER_ID = 12345678;
    private static final File testDataDir = new File("testdata");

    private final File testDir = 
        new File(Filenames.BUILD_TEST, "PrimaryHeaderFormatter");

    @Before
    public void setUp() throws Exception {
        mockery = new Mockery();
        mockery.setImposteriser(ClassImposteriser.INSTANCE);

        FileUtil.mkdirs(testDir);

    }

    @After
    public void tearDown() throws Exception {
        FileUtil.cleanDir(testDir);
    }

    private TargetPrimaryHeaderSource source(final CelestialObject kic) {
        Calendar calendar = Calendar.getInstance();
        calendar.set(2010, Calendar.AUGUST, 2); /* 2010-08-02 */
        calendar.set(Calendar.HOUR_OF_DAY, 12); //24 hour time
        calendar.set(Calendar.MINUTE, 0);
        calendar.set(Calendar.SECOND, 0);
        calendar.set(Calendar.MILLISECOND, 0);
        final Date creationDate = calendar.getTime();
        final TargetPrimaryHeaderSource source = mockery.mock(TargetPrimaryHeaderSource.class);
        mockery.checking(new Expectations() {{
            atLeast(1).of(source).extensionHduCount();
            will(returnValue(2));
            atLeast(1).of(source).keplerId();
            will(returnValue(KEPLER_ID));
            one(source).programName();
            will(returnValue("PrimaryHeaderFormatterTest"));
            one(source).subversionUrl();
            will(returnValue("svn+ssh://host/path/to/code"));
            one(source).subversionRevision();
            will(returnValue("30000"));
            one(source).pipelineTaskId();
            will(returnValue(8889333L));
            one(source).ccdChannel();
            will(returnValue(52));
            one(source).ccdModule();
            will(returnValue(15));
            one(source).ccdOutput();
            will(returnValue(4));
            one(source).quarter();
            will(returnValue(2));
            one(source).dataReleaseNumber();
            will(returnValue(3));
            one(source).observingMode();
            will(returnValue(ObservingMode.LONG_CADENCE));
            one(source).raDegrees();
            will(returnValue(299.856130));
            one(source).celestialObject();
            will(returnValue(kic));
            one(source).skyGroup();
            will(returnValue(32));
            one(source).season();
            will(returnValue(0));
            atLeast(1).of(source).generatedAt();
            will(returnValue(creationDate));
            atLeast(1).of(source).isK2Target();
            will(returnValue(false));
            atLeast(1).of(source).targetTableId();
            will(returnValue(42));
          
        }});

        return source;
    }

    @Test
    public void writeHeader() throws Exception {

        final CelestialObject kic = mockery.mock(CelestialObject.class);
        mockery.checking(new Expectations() {{
            one(kic).getDec();
            will(returnValue(45.609520));
            one(kic).getRaProperMotion();
            will(returnValue(0.00235f));
            one(kic).getDecProperMotion();
            will(returnValue(-0.01320f));
            one(kic).getTotalProperMotion();
            will(returnValue(0.01450f));
            one(kic).getParallax();
            will(returnValue(0.0001f));
            one(kic).getGalacticLatitude();
            will(returnValue(82.637822));
            one(kic).getGalacticLongitude();
            will(returnValue(8.835279));
            one(kic).getGMag();
            will(returnValue(16.044f));
            one(kic).getRMag();
            will(returnValue(13.724f));
            one(kic).getIMag();
            will(returnValue(12.141f));
            one(kic).getZMag();
            will(returnValue(11.970f));
            one(kic).getD51Mag();
            will(returnValue(15.522f));
            one(kic).getTwoMassJMag();
            will(returnValue(8.142f));
            one(kic).getTwoMassHMag();
            will(returnValue(7.704f));
            one(kic).getTwoMassKMag();
            will(returnValue(7.908f));
            one(kic).getKeplerMag();
            will(returnValue(13.081f));
            one(kic).getGrColor();
            will(returnValue(1.929f));
            one(kic).getJkColor();
            will(returnValue(1.325f));
            one(kic).getGkColor();
            will(returnValue(8.256f));
            one(kic).getEffectiveTemp();
            will(returnValue(8273));
            one(kic).getLog10SurfaceGravity();
            will(returnValue(0.350f));
            one(kic).getLog10Metallicity();
            will(returnValue(-0.051f));
            one(kic).getEbMinusVRedding();
            will(returnValue(0.266f));
            one(kic).getAvExtinction();
            will(returnValue(0.946f));
            one(kic).getRadius();
            will(returnValue(189.419f));
            one(kic).getTwoMassId();
            will(returnValue(1117146912));
            one(kic).getScpId();
            will(returnValue(1117146912));
        }});

        TargetPrimaryHeaderSource source = source(kic);

        TargetPrimaryHeaderFormatter formatter = new TargetPrimaryHeaderFormatter();
        Header header = formatter.formatHeader(source, CHECKSUM_DEFAULT);
        String headerStr = FitsUtils.headerToString(header);

        FileWriter fwriter = new FileWriter("/tmp/tpixel.primaryheader.fits");
        fwriter.write(headerStr);
        fwriter.close();

        BufferedReader breader = 
            new BufferedReader(new FileReader(new File(testDataDir, "tpixel.primaryheader.fits")));
        assertEquals(breader.readLine(), headerStr);
        breader.close();

    }

    @Test
    public void writeHeaderWithMostlyEmptyKic() throws Exception {
        final CelestialObject kic = createMinimalCelestialObject(mockery);

        TargetPrimaryHeaderFormatter formatter = new TargetPrimaryHeaderFormatter();
        TargetPrimaryHeaderSource source = source(kic);
        Header header = formatter.formatHeader(source, CHECKSUM_DEFAULT);

        String headerStr = FitsUtils.headerToString(header);
        FileWriter fwriter = new FileWriter("/tmp/tpixel.primaryheader.null-kic.fits");
        fwriter.write(headerStr);
        fwriter.close();
        BufferedReader breader = 
            new BufferedReader(new FileReader(new File(testDataDir, "tpixel.primaryheader.null-kic.fits")));
        assertEquals(breader.readLine(), headerStr);
        breader.close();

        HeaderCard redCard = header.findCard("RED");
        assertEquals(null,redCard);

    }

}
