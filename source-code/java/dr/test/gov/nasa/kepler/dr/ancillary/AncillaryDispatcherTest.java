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

package gov.nasa.kepler.dr.ancillary;

import static gov.nasa.kepler.common.FitsConstants.*;
import static com.google.common.collect.Lists.newArrayList;
import gov.nasa.kepler.common.AncillaryEngineeringData;
import gov.nasa.kepler.common.DefaultProperties;
import gov.nasa.kepler.common.utils.ReflectionEqualsMatcher;
import gov.nasa.kepler.dr.ancillary.AncillaryDispatcher.AncillaryParameterType;
import gov.nasa.kepler.dr.dispatch.DispatcherWrapper;
import gov.nasa.kepler.dr.dispatch.DispatcherWrapperFactory;
import gov.nasa.kepler.hibernate.dbservice.DatabaseServiceFactory;
import gov.nasa.kepler.hibernate.dbservice.TestUtils;
import gov.nasa.kepler.hibernate.dr.AncillaryDictionaryCrud;
import gov.nasa.kepler.hibernate.dr.AncillaryDictionaryMnemonic;
import gov.nasa.kepler.hibernate.dr.AncillaryLog;
import gov.nasa.kepler.hibernate.dr.AncillaryLogCrud;
import gov.nasa.kepler.mc.ancillary.AncillaryOperations;
import gov.nasa.spiffy.common.io.Filenames;
import gov.nasa.spiffy.common.jmock.JMockTest;
import gov.nasa.spiffy.common.junit.ReflectionEquals;

import java.io.File;
import java.util.Collection;
import java.util.List;

import nom.tam.fits.BasicHDU;
import nom.tam.fits.BinaryTableHDU;
import nom.tam.fits.Fits;
import nom.tam.fits.FitsFactory;
import nom.tam.util.BufferedFile;

import org.hamcrest.core.IsEqual;
import org.jmock.Expectations;
import org.jmock.Mockery;
import org.jmock.integration.junit4.JUnit4Mockery;
import org.jmock.lib.legacy.ClassImposteriser;
import org.junit.After;
import org.junit.Before;
import org.junit.Test;

import com.google.common.collect.ImmutableList;

/**
 * @author Miles Cote
 * 
 */
public class AncillaryDispatcherTest extends JMockTest {

    private static final String ANCILLARY_FITS_FILENAME = "kplr1000"
        + DispatcherWrapperFactory.ANCILLARY;
    private static final int SC_CONFIG_ID = 1;

    private static final double TIMESTAMP_1 = 55001;

    private static final String HEATER_MNEMONIC = "HTR";
    private static final String HEATER_ON_STRING_VALUE_1 = "ON";
    private static final double HEATER_ON_DOUBLE_VALUE_1 = 1.0;

    private Mockery mockery = new JUnit4Mockery() {
        {
            setImposteriser(ClassImposteriser.INSTANCE);
        }
    };

    private String[] stringValues;
    private double[] timestamps;
    private AncillaryEngineeringData expectedAncillaryEngineeringData;

    @Before
    public void setUp() throws Exception {
        DefaultProperties.setPropsForUnitTest();
        TestUtils.setUpDatabase(DatabaseServiceFactory.getInstance());
    }

    @After
    public void tearDown() throws Exception {
        TestUtils.tearDownDatabase(DatabaseServiceFactory.getInstance());
    }

    @Test
    public void testDoubleValues() throws Exception {
        final double[] timestamps = { TIMESTAMP_1 };
        final double[] doubleValues = { HEATER_ON_DOUBLE_VALUE_1 };
        final float[] floatValues = { (float) HEATER_ON_DOUBLE_VALUE_1 };

        File file = createAncillaryFitsFile(Filenames.BUILD_TMP,
            SC_CONFIG_ID, HEATER_MNEMONIC, timestamps, doubleValues);
        file.exists();

        expectedAncillaryEngineeringData = new AncillaryEngineeringData(
            HEATER_MNEMONIC);
        expectedAncillaryEngineeringData.setTimestamps(timestamps);
        expectedAncillaryEngineeringData.setValues(floatValues);

        AncillaryDispatcher ancillaryDispatcher = new AncillaryDispatcher();
        ancillaryDispatcher.setAncillaryLogCrud(createMockAncillaryLogCrud());
        ancillaryDispatcher.setAncillaryOperations(createMockAncillaryOperations());

        // ancillaryDispatcher.process();
    }

    @Test
    public void testStringValues() throws Exception {
        timestamps = new double[] { TIMESTAMP_1 };
        stringValues = new String[] { HEATER_ON_STRING_VALUE_1 };
        final float[] floatValues = { (float) HEATER_ON_DOUBLE_VALUE_1 };

        File file = createAncillaryFitsFile(Filenames.BUILD_TMP,
            SC_CONFIG_ID, HEATER_MNEMONIC, timestamps, stringValues);
        file.exists();

        expectedAncillaryEngineeringData = new AncillaryEngineeringData(
            HEATER_MNEMONIC);
        expectedAncillaryEngineeringData.setTimestamps(timestamps);
        expectedAncillaryEngineeringData.setValues(floatValues);

        AncillaryDispatcher ancillaryDispatcher = new AncillaryDispatcher();
        ancillaryDispatcher.setAncillaryLogCrud(createMockAncillaryLogCrud());
        ancillaryDispatcher.setAncillaryOperations(createMockAncillaryOperations());
        ancillaryDispatcher.setAncillaryDictionaryCrud(createMockAncillaryDictionaryCrud());

        // ancillaryDispatcher.process();
    }

    private AncillaryLogCrud createMockAncillaryLogCrud() {
        final AncillaryLogCrud mockAncillaryLogCrud = mockery.mock(AncillaryLogCrud.class);

        mockery.checking(new Expectations() {
            {
                exactly(1).of(mockAncillaryLogCrud)
                    .createAncillaryLog(
                        with(new IsEqual<AncillaryLog>(new AncillaryLog(null,
                            ANCILLARY_FITS_FILENAME, SC_CONFIG_ID))));
            }
        });

        return mockAncillaryLogCrud;
    }

    private AncillaryOperations createMockAncillaryOperations() {
        final AncillaryOperations mockAncillaryOperations = mockery.mock(AncillaryOperations.class);

        mockery.checking(new Expectations() {
            {
                List<AncillaryEngineeringData> expectedList = ImmutableList.of(expectedAncillaryEngineeringData);
                exactly(1).of(mockAncillaryOperations)
                    .storeAncillaryEngineeringData(
                        with(new ReflectionEqualsMatcher<Collection<AncillaryEngineeringData>>(
                            new ReflectionEquals(), expectedList)),
                        with(new IsEqual<Long>(
                            Long.valueOf(DispatcherWrapper.DATA_RECEIPT_ORIGIN_ID))));
            }
        });

        return mockAncillaryOperations;
    }

    private AncillaryDictionaryCrud createMockAncillaryDictionaryCrud() {
        final AncillaryDictionaryCrud mockAncillaryDictionaryCrud = mockery.mock(AncillaryDictionaryCrud.class);

        mockery.checking(new Expectations() {
            {
                List<AncillaryDictionaryMnemonic> result = newArrayList();

                exactly(1).of(mockAncillaryDictionaryCrud)
                    .retrieveAncillaryDictionary();
                will(returnValue(result));
                exactly(1).of(mockAncillaryDictionaryCrud)
                    .createAncillaryDictionaryEntry(
                        with(new IsEqual<AncillaryDictionaryMnemonic>(
                            new AncillaryDictionaryMnemonic(HEATER_MNEMONIC))));
            }
        });

        return mockAncillaryDictionaryCrud;
    }

    private File createAncillaryFitsFile(String path, int scConfigId,
        String mnemonic, Object timestamps, Object values) throws Exception {
        FitsFactory.setUseAsciiTables(false);
        Fits fits = new Fits();

        fits.addHDU(Fits.makeHDU(new Object[] { timestamps, values }));

        BasicHDU hdu = fits.getHDU(0);
        hdu.addValue(SCCONFIG_KW,
            scConfigId, "");

        BinaryTableHDU bhdu = (BinaryTableHDU) fits.getHDU(1);
        bhdu.setColumnName(0, TIME_TCOLUMN, "");
        bhdu.setColumnName(1, "VALUE", "");
        bhdu.addValue(MNEMONIC_KW, mnemonic,
            "");

        if (values instanceof double[]) {
            bhdu.addValue(PAR_TYPE_KW,
                AncillaryParameterType.ANALOG.fitsValue(), "");
        } else if (values instanceof String[]) {
            bhdu.addValue(PAR_TYPE_KW,
                AncillaryParameterType.DISCRETE.fitsValue(), "");
        }

        File file = new File(path, ANCILLARY_FITS_FILENAME);

        BufferedFile bf = new BufferedFile(file.getAbsolutePath(), "rw");
        fits.write(bf);
        bf.flush();
        bf.close();

        return file;
    }

}
