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

package gov.nasa.kepler.etem2;

import gov.nasa.kepler.common.pi.PlannedPhotometerConfigParameters;
import gov.nasa.kepler.common.pi.PlannedSpacecraftConfigParameters;
import gov.nasa.kepler.dr.NmGenerator;
import gov.nasa.kepler.hibernate.cm.TargetListSet;
import gov.nasa.kepler.hibernate.cm.TargetSelectionCrud;
import gov.nasa.kepler.hibernate.dbservice.DatabaseServiceFactory;
import gov.nasa.kepler.hibernate.pi.PipelineInstance;
import gov.nasa.kepler.hibernate.pi.PipelineModule;
import gov.nasa.kepler.hibernate.pi.PipelineTask;
import gov.nasa.kepler.hibernate.pi.UnitOfWorkTask;
import gov.nasa.kepler.hibernate.tad.TargetTable.TargetType;
import gov.nasa.kepler.mc.tad.TadParameters;
import gov.nasa.kepler.mc.uow.SingleUowTask;
import gov.nasa.spiffy.common.io.FileUtil;
import gov.nasa.spiffy.common.pi.ModuleFatalProcessingException;
import gov.nasa.spiffy.common.pi.Parameters;
import gov.nasa.spiffy.common.pi.PipelineException;

import java.io.File;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.LinkedList;
import java.util.List;

import org.apache.commons.io.FileUtils;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * @author Todd Klaus tklaus@arc.nasa.gov
 */
public class Etem2RpPipelineModule extends PipelineModule {
    private static final Log log = LogFactory.getLog(Etem2RpPipelineModule.class);

    public static final String MODULE_NAME = "Etem2Rp";

    private String rpDir;
    private List<File> ssrFiles;
    private int contactNumber;
    private DataGenParameters dataGenParams;
    private TadParameters tadParameters;
    private PackerParameters packerParams;
    private DataGenDirManager dataGenDirManager;
    private PlannedPhotometerConfigParameters photometerConfigParams;
    private PlannedSpacecraftConfigParameters spacecraftConfigParams;
    private int longCadencesPerBaseline;
    private Etem2DitherParameters etem2DitherParams;

    @Override
    public String getModuleName() {
        return MODULE_NAME;
    }

    @Override
    public Class<? extends UnitOfWorkTask> unitOfWorkTaskType() {
        return SingleUowTask.class;
    }

    @Override
    public List<Class<? extends Parameters>> requiredParameters() {
        List<Class<? extends Parameters>> p = new ArrayList<Class<? extends Parameters>>();

        p.add(DataGenParameters.class);
        p.add(TadParameters.class);
        p.add(PackerParameters.class);
        p.add(PlannedSpacecraftConfigParameters.class);
        p.add(PlannedPhotometerConfigParameters.class);
        p.add(Etem2DitherParameters.class);

        return p;
    }

    @Override
    public void processTask(PipelineInstance pipelineInstance,
        PipelineTask pipelineTask) {

        try {
            setup(pipelineTask);

            Etem2OutputManager outputManager = new Etem2OutputManager(
                dataGenDirManager, pipelineTask.getId());
            DataGenTimeOperations vtcOperations = new DataGenTimeOperations();
            double vtcStartSeconds = vtcOperations.getVtcStartSeconds(packerParams.getStartDate());
            double secondsPerBaseline = spacecraftConfigParams.getSecondsPerShortCadence()
                * spacecraftConfigParams.getShortCadencesPerLongCadence()
                * spacecraftConfigParams.getLongCadencesPerBaseline();
            int numCadences = 0;

            if (etem2DitherParams.isDoDithering()) {

                int numRuns = etem2DitherParams.numOffsets();
                numCadences = etem2DitherParams.getCadencesPerOffset();

                for (int runNumber = 1; runNumber <= numRuns; runNumber++) {
                    outputManager.setRunNumber(runNumber);

                    generateRpFiles(outputManager.getOutputDir(),
                        vtcStartSeconds, 0, numCadences - 1);

                    vtcStartSeconds += secondsPerBaseline;
                }
            } else { // no dithering
                // cadence numbers are relative to the start of the ETEM run
                numCadences = packerParams.getLongCadenceCount();

                generateRpFiles(outputManager.getOutputDir(), vtcStartSeconds,
                    0, numCadences - 1);
            }

            packageRpFiles();

        } catch (Exception e) {
            throw new PipelineException("Unable to run etem2Rp.", e);
        }
    }

    private void setup(PipelineTask pipelineTask) throws Exception {
        dataGenParams = pipelineTask.getParameters(DataGenParameters.class);
        tadParameters = getTadParameters(pipelineTask);
        packerParams = pipelineTask.getParameters(PackerParameters.class);
        dataGenDirManager = new DataGenDirManager(dataGenParams, packerParams,
            tadParameters);
        photometerConfigParams = pipelineTask.getParameters(PlannedPhotometerConfigParameters.class);
        spacecraftConfigParams = pipelineTask.getParameters(PlannedSpacecraftConfigParameters.class);
        etem2DitherParams = pipelineTask.getParameters(Etem2DitherParameters.class);

        rpDir = dataGenDirManager.getRpDir();

        TargetSelectionCrud targetSelectionCrud = new TargetSelectionCrud(
            DatabaseServiceFactory.getInstance());
        TargetListSet lcTls = targetSelectionCrud.retrieveTargetListSet(tadParameters.getTargetListSetName());
        TargetListSet rpTls = targetSelectionCrud.retrieveTargetListSetByTargetTable(lcTls.getRefPixTable());

        /* Make sure that the target list set exists */
        if (rpTls == null) {
            throw new ModuleFatalProcessingException(
                "refPixTls was not set for the targetListSet.  tls = " + lcTls);
        }

        longCadencesPerBaseline = spacecraftConfigParams.getLongCadencesPerBaseline();

        // Clean output dir.
        FileUtil.cleanDir(rpDir);
    }

    private TadParameters getTadParameters(PipelineTask pipelineTask) {
        TadParameters tadParameters = pipelineTask.getParameters(TadParameters.class);

        TargetSelectionCrud targetSelectionCrud = new TargetSelectionCrud(
            DatabaseServiceFactory.getInstance());
        TargetListSet tls = targetSelectionCrud.retrieveTargetListSet(tadParameters.getTargetListSetName());
        if (tls.getType()
            .equals(TargetType.REFERENCE_PIXEL)) {
            // etem2rp expects an lcTls, so change tadParameters.
            tadParameters = new TadParameters(tls.getAssociatedLcTls()
                .getName(), null);
        }

        return tadParameters;
    }

    private void generateRpFiles(String sourceDir, double vtcStartSeconds,
        int startCadence, int endCadence) throws Exception {
        log.info("Generating reference pixel files from ETEM2 output in: "
            + sourceDir + " to " + rpDir);

        Etem2Rp etem2Rp = new Etem2Rp(sourceDir, rpDir, photometerConfigParams,
            vtcStartSeconds,
            spacecraftConfigParams.getSecondsPerShortCadence(), startCadence,
            endCadence, longCadencesPerBaseline,
            spacecraftConfigParams.getSecondsPerShortCadence()
                * spacecraftConfigParams.getShortCadencesPerLongCadence());
        etem2Rp.writeFiles();
    }

    /**
     * Package rp files as they will be received from the moc. e.g. contact1:
     * (start of etem run): rp1, rp2, rp3, rp4 contact2: rp1, rp2, rp3, rp4,
     * rp5, rp6, rp7, rp8 contact3: rp4, rp5, rp6, rp7, rp8, rp9, rp10, rp11,
     * rp12 contact4: etc.
     * 
     * @throws IOException
     */
    private void packageRpFiles() throws IOException {
        File rpDirFile = new File(rpDir);
        List<File> rpFiles = Arrays.asList(rpDirFile.listFiles());
        Collections.sort(rpFiles);

        List<File> originalRpFiles = Arrays.asList(rpDirFile.listFiles());
        Collections.sort(originalRpFiles);

        ssrFiles = new LinkedList<File>();

        int originalRpFileCount = 0;
        contactNumber = 0;
        for (File originalRpFile : originalRpFiles) {
            ssrFiles.add(originalRpFile);
            if (ssrFiles.size() > dataGenParams.getBaselinesStoredOnSsr()) {
                ssrFiles.remove(0);
            }
            originalRpFileCount++;

            // Flush the ssr every four days.
            if (originalRpFileCount % dataGenParams.getBaselinesPerContact() == 0) {
                flushSsr();
            }
        }

        // Flush one final time unless the ssr was flushed in the last
        // iteration of the loop.
        if (originalRpFileCount % dataGenParams.getBaselinesPerContact() != 0) {
            flushSsr();
        }

        // Create a directory with all rp files and nm to support testing.
        File allRpFilesDir = new File(rpDirFile, "all-files");
        FileUtil.cleanDir(allRpFilesDir);
        List<File> rpDirFiles = Arrays.asList(rpDirFile.listFiles());
        for (File file : rpDirFiles) {
            if (file.getName()
                .contains("rp")) {
                file.renameTo(new File(allRpFilesDir, file.getName()));
            }
        }
        NmGenerator.generateNotificationMessage(
            allRpFilesDir.getAbsolutePath(), "rpnm");
    }

    private void flushSsr() throws IOException {
        File contactDir;
        // Create a new contact directory.
        contactDir = new File(rpDir, "contact" + contactNumber);
        FileUtil.cleanDir(contactDir);

        // Flush ssr to contact dir.
        for (File ssrFile : ssrFiles) {
            FileUtils.copyFileToDirectory(ssrFile, contactDir);
        }

        // Generate nm.
        NmGenerator.generateNotificationMessage(contactDir.getAbsolutePath(),
            "rpnm");

        contactNumber++;
    }

}
