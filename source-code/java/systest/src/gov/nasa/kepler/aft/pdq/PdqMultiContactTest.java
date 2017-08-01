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

package gov.nasa.kepler.aft.pdq;

import gov.nasa.kepler.aft.descriptor.TestDataSetDescriptorFactory;
import gov.nasa.kepler.common.Cadence.CadenceType;
import gov.nasa.kepler.common.pi.CadenceTypePipelineParameters;
import gov.nasa.kepler.etem2.DataGenDirManager;
import gov.nasa.kepler.etem2.DataGenParameters;
import gov.nasa.kepler.etem2.PackerParameters;
import gov.nasa.kepler.hibernate.dbservice.TransactionService;
import gov.nasa.kepler.hibernate.dbservice.TransactionServiceFactory;
import gov.nasa.kepler.hibernate.pi.ParameterSet;
import gov.nasa.kepler.ops.seed.CommonPipelineSeedData;
import gov.nasa.kepler.pi.pipeline.PipelineOperations;
import gov.nasa.spiffy.common.io.FileUtil;
import gov.nasa.spiffy.common.io.Filenames;

import java.io.File;
import java.io.FilenameFilter;

import org.apache.log4j.Logger;

/**
 * Base class for managing contacts for the PDQ AFTs.
 * 
 * @author Forrest Girouard
 */
public abstract class PdqMultiContactTest extends AbstractPdqFeatureTest {

    private static final Logger log = Logger.getLogger(PdqMultiContactTest.class);

    public PdqMultiContactTest(String testName) {
        super(testName);
    }

    protected abstract int getContactCount();

    @Override
    protected void process() throws Exception {

        log.info(getLogName() + ": begin first contact");

        runPipeline(PDQ_TRIGGER_NAME);

        for (int contact = 1; contact < getContactCount(); contact++) {
            log.info(getLogName() + ": begin next contact " + contact + " of "
                + getContactCount());
            nextContact(contact);
        }
    }

    protected void nextContact(int contact) throws Exception {
        nextContact(contact, PDQ_TRIGGER_NAME);
    }

    protected void nextContact(int contact, String triggerName)
        throws Exception {

        seedNextTestData(contact);
        runPipeline(triggerName);
    }

    protected void seedNextTestData(int contact) throws Exception {

        TransactionService transactionService = TransactionServiceFactory.getInstance();
        transactionService.beginTransaction();

        DataGenParameters dataGenParameters = createDataGenParameters(TestDataSetDescriptorFactory.getEtemDir(getTestDescriptor()));
        PackerParameters packerParameters = retrievePackerParameters();

        DataGenDirManager dataGenDirManager = new DataGenDirManager(
            dataGenParameters, packerParameters,
            new CadenceTypePipelineParameters(CadenceType.LONG));

        String sourceDir = dataGenDirManager.getRpDir() + "/contact" + contact;
        if (isAddGaps()) {
            File source = new File(sourceDir);
            File dest = new File(Filenames.BUILD_TMP, "contact"
                + contact);
            FileUtil.copyFiles(source, dest);
            for (File file : dest.listFiles(new FilenameFilter() {
                @Override
                public boolean accept(File dir, String name) {
                    return name.startsWith("kplr") && name.endsWith("_rp.rp");
                }
            })) {
                addGaps(file);
            }
            sourceDir = dest.getPath();
        }
        new AftRefPixelSeeder(getTestDescriptor(), sourceDir).seed();

        transactionService.commitTransaction();
    }

    private DataGenParameters createDataGenParameters(String etemDir) {

        ParameterSet dataGenParametersSet = retrieveParameterSet("dataGen (LC)");
        if (dataGenParametersSet == null) {
            throw new NullPointerException(String.format(
                "Missing \'%s\' parameter set", "dataGen (LC)"));
        }
        DataGenParameters dataGenParameters = dataGenParametersSet.parametersInstance();

        dataGenParameters.setDataGenOutputPath(etemDir);
        new PipelineOperations().updateParameterSet(dataGenParametersSet,
            dataGenParameters, false);

        return dataGenParameters;
    }

    private PackerParameters retrievePackerParameters() {

        ParameterSet packerParametersSet = retrieveParameterSet(CommonPipelineSeedData.PACKER);
        if (packerParametersSet == null) {
            throw new NullPointerException(String.format(
                "Missing \'%s\' parameter set", CommonPipelineSeedData.PACKER));
        }

        return packerParametersSet.parametersInstance();
    }
}
