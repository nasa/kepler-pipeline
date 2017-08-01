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

import static gov.nasa.kepler.mc.refpixels.RefPixelFileReader.GAP_INDICATOR_VALUE;
import gov.nasa.kepler.aft.AutomatedFeatureTest;
import gov.nasa.kepler.common.SocEnvVars;
import gov.nasa.kepler.dr.refpixels.RefPixelDispatcher;
import gov.nasa.kepler.fs.api.FsId;
import gov.nasa.kepler.hibernate.dbservice.DatabaseServiceFactory;
import gov.nasa.kepler.hibernate.dr.DispatcherTrigger;
import gov.nasa.kepler.hibernate.dr.DispatcherTriggerCrud;
import gov.nasa.kepler.hibernate.pi.TriggerDefinition;
import gov.nasa.kepler.hibernate.pi.TriggerDefinitionCrud;
import gov.nasa.kepler.mc.refpixels.RefPixelFileReader;
import gov.nasa.kepler.pdq.PdqPipelineModule;
import gov.nasa.kepler.pi.configuration.PipelineConfigurationOperations;
import gov.nasa.spiffy.common.io.FileUtil;

import java.io.BufferedInputStream;
import java.io.BufferedOutputStream;
import java.io.DataInputStream;
import java.io.DataOutputStream;
import java.io.EOFException;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.util.Random;

import org.apache.log4j.Logger;

/**
 * Base class for all the PDQ pipeline module AFTs.
 * 
 * @author Forrest Girouard
 */
public abstract class AbstractPdqFeatureTest extends AutomatedFeatureTest {

    private static final Logger log = Logger.getLogger(AbstractPdqFeatureTest.class);

    protected static final String PDQ_TRIGGER_NAME = "PDQ";

    private static final float DEFAULT_GAP_PROBABILITY = 0.01F;

    private static final long RANDOM_SEED = 1215111865123L;
    private static Random random = new Random(RANDOM_SEED);

    private boolean addGaps;
    private float gapProbability = DEFAULT_GAP_PROBABILITY;

    public AbstractPdqFeatureTest(String testName) {
        super(PdqPipelineModule.MODULE_NAME, testName);
    }

    @Override
    protected void createDatabaseContents() throws Exception {

        seedSpice();

        TriggerDefinition trigger = new TriggerDefinitionCrud().retrieve(PDQ_TRIGGER_NAME);
        if (trigger != null) {
            return;
        }

        log.info(getLogName() + ": Importing pipeline configuration");
        new PipelineConfigurationOperations().importPipelineConfiguration(new File(
            SocEnvVars.getLocalDataDir(), AFT_PIPELINE_CONFIGURATION_ROOT
                + PdqPipelineModule.MODULE_NAME + ".xml"));

        trigger = new TriggerDefinitionCrud().retrieve(PDQ_TRIGGER_NAME);

        // Create a dispatcherTriggerMap.
        DispatcherTrigger dispatcherTrigger = new DispatcherTrigger(
            RefPixelDispatcher.class.getName(), trigger);
        dispatcherTrigger.setEnabled(true);
        DispatcherTriggerCrud dispatcherTriggerMapCrud = new DispatcherTriggerCrud(
            DatabaseServiceFactory.getInstance());
        dispatcherTriggerMapCrud.create(dispatcherTrigger);
    }

    protected boolean isAddGaps() {
        return addGaps;
    }

    protected void setAddGaps(boolean addGaps) {
        this.addGaps = addGaps;
    }

    protected float getGapProbability() {
        return gapProbability;
    }

    protected void setGapProbability(float gapProability) {
        gapProbability = gapProability;
    }

    protected void addGaps(File file) throws IOException {
        addGaps(file, getGapProbability());
    }

    private void addGaps(File file, float probability) throws IOException {

        if (!file.canRead()) {
            throw new IllegalArgumentException(file + ": unreadable");
        }

        File tmpFile = new File(file.getParentFile(), file.getName() + ".tmp");
        FileInputStream fileInput = null;
        DataInputStream input = null;
        DataOutputStream output = null;
        int gapCount = 0;
        try {
            fileInput = new FileInputStream(file);
            byte[] header = new byte[RefPixelFileReader.NUM_HEADER_BYTES];
            if (fileInput.read(header) != RefPixelFileReader.NUM_HEADER_BYTES) {
                throw new IOException(
                    "unexpected EOF: file smaller than required header");
            }
            FileUtil.close(fileInput);

            input = new DataInputStream(new BufferedInputStream(
                new FileInputStream(file)));
            output = new DataOutputStream(new BufferedOutputStream(
                new FileOutputStream(tmpFile)));
            RefPixelFileReader refPixelReader = new RefPixelFileReader(
                new FsId("/dr/RefPixel/" + file.getName()), input);

            output.write(header);
            while (true) {
                if (random.nextInt() % (int) (1 / probability) == 0) {
                    gapCount++;
                    refPixelReader.readNextPixel(); // throws EOF
                    output.writeInt(GAP_INDICATOR_VALUE);
                } else {
                    output.writeInt(refPixelReader.readNextPixel());
                }
            }
        } catch (EOFException done) {
        } finally {
            log.info(String.format("%s: %s: introduced %d pixel gaps",
                getLogName(), file.getParentFile()
                    .getName(), gapCount));
            FileUtil.close(fileInput);
            FileUtil.close(input);
            FileUtil.close(output);
        }

        if (!tmpFile.renameTo(file)) {
            throw new IOException(String.format("%s: rename to %s failed.",
                tmpFile.getAbsolutePath(), file.getAbsolutePath()));
        }
    }
}
