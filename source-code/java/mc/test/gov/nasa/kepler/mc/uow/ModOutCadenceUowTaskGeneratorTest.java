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

package gov.nasa.kepler.mc.uow;

import static org.junit.Assert.assertEquals;
import gov.nasa.kepler.common.Cadence.CadenceType;
import gov.nasa.kepler.common.pi.CadenceRangeParameters;
import gov.nasa.kepler.common.pi.CadenceTypePipelineParameters;
import gov.nasa.kepler.common.pi.ModuleOutputListsParameters;
import gov.nasa.kepler.hibernate.dbservice.DatabaseService;
import gov.nasa.kepler.hibernate.dbservice.DatabaseServiceFactory;
import gov.nasa.kepler.hibernate.dbservice.DdlInitializer;
import gov.nasa.kepler.hibernate.dr.LogCrud;
import gov.nasa.kepler.hibernate.dr.PixelLog;
import gov.nasa.kepler.hibernate.pi.UnitOfWorkTask;
import gov.nasa.spiffy.common.pi.Parameters;

import java.io.IOException;
import java.sql.SQLException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.junit.After;
import org.junit.Before;
import org.junit.Test;

/**
 * @author Todd Klaus tklaus@arc.nasa.gov
 * @author Miles Cote
 * 
 */
public class ModOutCadenceUowTaskGeneratorTest {
    private static final CadenceType CADENCE_TYPE = CadenceType.LONG;
    private static final int START_CADENCE = 0;
    private static final int END_CADENCE = 999;

    private DatabaseService databaseService;
    private DdlInitializer ddlInitializer;

    @Before
    public void setUp() throws SQLException, ClassNotFoundException,
        IOException {
        databaseService = DatabaseServiceFactory.getInstance();
        ddlInitializer = databaseService.getDdlInitializer();
        ddlInitializer.initDB();

        LogCrud logCrud = new LogCrud();

        databaseService.beginTransaction();
        for (int i = START_CADENCE; i <= END_CADENCE; i++) {
            PixelLog pixelLog = new PixelLog();
            pixelLog.setCadenceType(CADENCE_TYPE.intValue());
            pixelLog.setCadenceNumber(i);
            logCrud.createPixelLog(pixelLog);
        }
        databaseService.commitTransaction();
    }

    @After
    public void tearDown() throws SQLException {
        if (databaseService != null) {
            databaseService.closeCurrentSession();
            ddlInitializer.cleanDB();
        }
    }

    @Test
    public void testSubDivide() {
        ModuleOutputListsParameters modOutLists = new ModuleOutputListsParameters();
        CadenceRangeParameters cadenceRange = new CadenceRangeParameters(
            START_CADENCE, END_CADENCE, 10, 0);
        CadenceTypePipelineParameters cadenceType = new CadenceTypePipelineParameters(
            CADENCE_TYPE);

        Map<Class<? extends Parameters>, Parameters> parameters = new HashMap<Class<? extends Parameters>, Parameters>();
        parameters.put(modOutLists.getClass(), modOutLists);
        parameters.put(cadenceRange.getClass(), cadenceRange);
        parameters.put(cadenceType.getClass(), cadenceType);

        ModOutCadenceUowTaskGenerator taskGenerator = new ModOutCadenceUowTaskGenerator();
        List<? extends UnitOfWorkTask> tasks = taskGenerator.generateTasks(parameters);

        assertEquals("tasks size", 10 * 84, tasks.size());
    }

    @Test
    public void testSubDivideWithChannelGroups() {
        ModuleOutputListsParameters moduleOutputListsParameters = new ModuleOutputListsParameters(
            "1,2;3,4;5,6");
        CadenceRangeParameters cadenceRangeParameters = new CadenceRangeParameters(
            START_CADENCE, END_CADENCE, 10, 0);
        CadenceTypePipelineParameters cadenceTypeParameters = new CadenceTypePipelineParameters(
            CADENCE_TYPE);

        Map<Class<? extends Parameters>, Parameters> parameters = new HashMap<Class<? extends Parameters>, Parameters>();
        parameters.put(moduleOutputListsParameters.getClass(),
            moduleOutputListsParameters);
        parameters.put(cadenceRangeParameters.getClass(),
            cadenceRangeParameters);
        parameters.put(cadenceTypeParameters.getClass(), cadenceTypeParameters);

        ModOutCadenceUowTaskGenerator taskGenerator = new ModOutCadenceUowTaskGenerator();
        List<? extends UnitOfWorkTask> tasks = taskGenerator.generateTasks(parameters);

        assertEquals("number of tasks", 10 * 3, tasks.size());
    }

    @Test(expected = NullPointerException.class)
    public void testSubDivideMissingParams() {
        Map<Class<? extends Parameters>, Parameters> parameters = new HashMap<Class<? extends Parameters>, Parameters>();

        ModOutCadenceUowTaskGenerator taskGenerator = new ModOutCadenceUowTaskGenerator();
        taskGenerator.generateTasks(parameters);
    }

}
