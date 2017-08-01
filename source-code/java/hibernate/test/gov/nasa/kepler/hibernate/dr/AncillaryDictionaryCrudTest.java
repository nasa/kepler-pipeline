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

package gov.nasa.kepler.hibernate.dr;

import gov.nasa.kepler.common.DefaultProperties;
import gov.nasa.kepler.hibernate.dbservice.DatabaseService;
import gov.nasa.kepler.hibernate.dbservice.DatabaseServiceFactory;
import gov.nasa.kepler.hibernate.dbservice.TestUtils;
import gov.nasa.spiffy.common.junit.ReflectionEquals;

import java.util.ArrayList;
import java.util.List;

import org.junit.After;
import org.junit.Before;
import org.junit.Test;

public class AncillaryDictionaryCrudTest {

    private static final String HEATER_MNEMONIC = "HTR";
    private static final String HEATER_ON_STRING_VALUE = "ON";
    private static final double HEATER_ON_DOUBLE_VALUE = 1.0;

    private AncillaryDictionaryCrud ancillaryDictionaryCrud;

    private DatabaseService databaseService;

    private ReflectionEquals reflectionEquals = new ReflectionEquals();

    @Before
    public void setUp() throws Exception {
        DefaultProperties.setPropsForUnitTest();
        databaseService = DatabaseServiceFactory.getInstance();
        TestUtils.setUpDatabase(databaseService);

        reflectionEquals.excludeField(".*\\.id");
    }

    @After
    public void tearDown() throws Exception {
        TestUtils.tearDownDatabase(databaseService);
    }

    @SuppressWarnings("serial")
    @Test
    public void testRetrieveAncillaryDictionary() throws Exception {
        AncillaryDictionaryMnemonic ancillaryDictionaryMnemonic = new AncillaryDictionaryMnemonic(
            HEATER_MNEMONIC);
        ancillaryDictionaryMnemonic.getValues()
            .add(
                new AncillaryDictionaryValues(HEATER_ON_STRING_VALUE,
                    HEATER_ON_DOUBLE_VALUE));

        ancillaryDictionaryCrud = new AncillaryDictionaryCrud();
        ancillaryDictionaryCrud.createAncillaryDictionaryEntry(ancillaryDictionaryMnemonic);

        List<AncillaryDictionaryMnemonic> expectedDictionary = new ArrayList<AncillaryDictionaryMnemonic>() {
            {
                AncillaryDictionaryMnemonic ancillaryDictionaryMnemonic = new AncillaryDictionaryMnemonic(
                    HEATER_MNEMONIC);
                ancillaryDictionaryMnemonic.getValues()
                    .add(
                        new AncillaryDictionaryValues(HEATER_ON_STRING_VALUE,
                            HEATER_ON_DOUBLE_VALUE));
                add(ancillaryDictionaryMnemonic);
            }
        };

        List<AncillaryDictionaryMnemonic> actualDictionary = ancillaryDictionaryCrud.retrieveAncillaryDictionary();

        reflectionEquals.assertEquals(expectedDictionary, actualDictionary);
    }

    @Test
    public void testRetrieveNullDictionary() throws Exception {
        ancillaryDictionaryCrud = new AncillaryDictionaryCrud();

        List<AncillaryDictionaryMnemonic> expectedDictionary = new ArrayList<AncillaryDictionaryMnemonic>();
        List<AncillaryDictionaryMnemonic> actualDictionary = ancillaryDictionaryCrud.retrieveAncillaryDictionary();
        reflectionEquals.assertEquals(expectedDictionary, actualDictionary);
    }

}
