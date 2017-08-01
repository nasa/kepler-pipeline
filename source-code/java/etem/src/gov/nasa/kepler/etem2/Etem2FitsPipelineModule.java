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

import gov.nasa.kepler.common.Cadence;
import gov.nasa.kepler.common.MatlabDateFormatter;
import gov.nasa.kepler.common.ModifiedJulianDate;
import gov.nasa.kepler.common.Cadence.CadenceType;
import gov.nasa.kepler.common.pi.PlannedPhotometerConfigParameters;
import gov.nasa.kepler.common.pi.PlannedSpacecraftConfigParameters;
import gov.nasa.kepler.hibernate.cm.TargetListSet;
import gov.nasa.kepler.hibernate.cm.TargetSelectionCrud;
import gov.nasa.kepler.hibernate.dbservice.ConfigurationServiceFactory;
import gov.nasa.kepler.hibernate.pi.PipelineInstance;
import gov.nasa.kepler.hibernate.pi.PipelineModule;
import gov.nasa.kepler.hibernate.pi.PipelineTask;
import gov.nasa.kepler.hibernate.pi.UnitOfWorkTask;
import gov.nasa.kepler.mc.DataRepoParameters;
import gov.nasa.kepler.mc.tad.TadParameters;
import gov.nasa.kepler.mc.uow.SingleUowTask;
import gov.nasa.kepler.pi.module.ExternalProcessPipelineModule;
import gov.nasa.spiffy.common.io.FileUtil;
import gov.nasa.spiffy.common.pi.ModuleFatalProcessingException;
import gov.nasa.spiffy.common.pi.Parameters;
import gov.nasa.spiffy.common.pi.PipelineException;

import java.io.File;
import java.text.ParseException;
import java.util.ArrayList;
import java.util.List;

import org.apache.commons.configuration.Configuration;
import org.apache.commons.io.FileUtils;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * @author Todd Klaus tklaus@arc.nasa.gov
 */
public class Etem2FitsPipelineModule extends PipelineModule {
    private static final Log log = LogFactory.getLog(Etem2FitsPipelineModule.class);

    public static final String MODULE_NAME = "Etem2Fits";

    private DataGenParameters dataGenParams;
    private TadParameters tadParameters;
    private PackerParameters packerParams;
    private DataGenDirManager dataGenDirManager;
    private PlannedSpacecraftConfigParameters spacecraftConfigParams;
    private PlannedPhotometerConfigParameters photometerConfigParams;
    private DataRepoParameters dataRepoParams;
    private int scConfigId;
    private int compressionId;
    private double cadenceZeroMjd;
    private CadenceType cadenceType;
    private int cadenceCount;
    private double secondsPerShortCadence;
    private int shortCadencesPerLong;
    private int badId;
    private int bgpId;
    private int tadId;
    private int lctId;
    private int sctId;
    private int rptId;
    private File localOutputDir;
    private String tlsName;

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
        p.add(DataRepoParameters.class);
        p.add(Etem2DitherParameters.class);

        return p;
    }

    @Override
    public void processTask(PipelineInstance pipelineInstance,
        PipelineTask pipelineTask) {

        try {
            initialize(pipelineInstance, pipelineTask);

            if (etem2DitherParams.isDoDithering()) {
                doDitherMode(pipelineTask);
            } else { // no dithering
                Etem2OutputManager outputManager = new Etem2OutputManager(dataGenDirManager, pipelineTask.getId());
                
                DataGenTimeOperations dataGenTimeOperations = new DataGenTimeOperations();
                int startCadence = dataGenTimeOperations.getCadence(dataGenParams,
                    spacecraftConfigParams, cadenceType,
                    packerParams.getStartDate());
                int endCadence = startCadence + cadenceCount - 1;

                log.info("startCadence = " + startCadence);
                log.info("endCadence = " + endCadence);
                
                generateFits(outputManager.getOutputDir(), startCadence, endCadence, cadenceType, 0, 0);
            }
        } catch (Exception e) {
            throw new PipelineException("Unable to run.", e);
        }
    }

    private void doDitherMode(PipelineTask pipelineTask) throws ParseException, Exception {
        Etem2OutputManager outputManager = new Etem2OutputManager(dataGenDirManager, pipelineTask.getId());
        
        int numRuns = etem2DitherParams.numOffsets();
                
        for(int runNumber = 1; runNumber <= numRuns; runNumber++){
            outputManager.setRunNumber(runNumber);
            
            int startCadence = etem2DitherParams.getStartCadenceNumber() + (runNumber-1) * etem2DitherParams.getCadencesPerOffset();
            int endCadence = startCadence + etem2DitherParams.getCadencesPerOffset() - 1;
            
            generateFits(outputManager.getOutputDir(), startCadence, endCadence, CadenceType.LONG, 2, 0);
        }
    }

    private void generateFits(String sourceDir, int startCadence, int endCadence, CadenceType cadenceTypeToGenerate, int motionInterval, int motionOffset) throws Exception{
        
        FileUtil.cleanDir(localOutputDir);

        switch (cadenceTypeToGenerate) {
            case LONG:
                // Create lc fits files.
                Etem2FitsLong etem2FitsLong = new Etem2FitsLong(
                    localOutputDir.getAbsolutePath(), sourceDir, cadenceZeroMjd,
                    startCadence, endCadence, packerParams.cadenceGapOffsets(), tlsName, scConfigId,
                    dataRepoParams.getMasterFitsPath(),
                    secondsPerShortCadence, shortCadencesPerLong,
                    compressionId, badId, bgpId, tadId, lctId, sctId, rptId);

                etem2FitsLong.setMotionInterval(motionInterval);
                etem2FitsLong.setMotionOffset(motionOffset);
                
                etem2FitsLong.generateFits();

                break;
            case SHORT:
                // Create sc fits files.
                Etem2FitsShort etem2FitsShort = new Etem2FitsShort(
                    localOutputDir.getAbsolutePath(), sourceDir, cadenceZeroMjd,
                    startCadence, endCadence, packerParams.cadenceGapOffsets(), tlsName, scConfigId,
                    dataRepoParams.getMasterFitsPath(),
                    secondsPerShortCadence, shortCadencesPerLong,
                    compressionId, badId, bgpId, tadId, lctId, sctId, rptId);

                etem2FitsShort.setMotionInterval(motionInterval);
                etem2FitsShort.setMotionOffset(motionOffset);

                etem2FitsShort.generateFits();

                break;
        }

        String outputDir = dataGenDirManager.getCadenceFitsDir();

        log.info("Copying the output files to " + outputDir + "...");
        for (File file : localOutputDir.listFiles()) {
            FileUtils.copyFileToDirectory(file, new File(outputDir));
        }

        log.info("Cleaning local dir...");
        FileUtils.forceDelete(localOutputDir);
    }
    
    private void initialize(PipelineInstance pipelineInstance, PipelineTask pipelineTask) throws Exception {
        dataGenParams = pipelineTask.getParameters(DataGenParameters.class);
        tadParameters = pipelineTask.getParameters(TadParameters.class);
        packerParams = pipelineTask.getParameters(PackerParameters.class);
        etem2DitherParams = pipelineTask.getParameters(Etem2DitherParameters.class);
        dataGenDirManager = new DataGenDirManager(
            dataGenParams, packerParams, tadParameters);

        spacecraftConfigParams = pipelineTask.getParameters(PlannedSpacecraftConfigParameters.class);
        photometerConfigParams = pipelineTask.getParameters(PlannedPhotometerConfigParameters.class);
        dataRepoParams = pipelineTask.getParameters(DataRepoParameters.class);

        scConfigId = spacecraftConfigParams.getScConfigId();
        compressionId = photometerConfigParams.getCompressionExternalId();

        /* Make sure that the target list set exists */
        tlsName = tadParameters.getTargetListSetName();
        TargetSelectionCrud targetSelectionCrud = new TargetSelectionCrud();
        TargetListSet tls = targetSelectionCrud.retrieveTargetListSet(tlsName);

        if (tls == null) {
            throw new ModuleFatalProcessingException(
                "No target list set found for name = " + tlsName);
        }

        cadenceZeroMjd = ModifiedJulianDate.dateToMjd(MatlabDateFormatter.dateFormatter()
            .parse(dataGenParams.getCadenceZeroDate()));

        cadenceType = null;
        cadenceCount = 0;
        switch (tls.getType()) {
            case LONG_CADENCE:
                cadenceType = Cadence.CadenceType.LONG;
                cadenceCount = packerParams.getLongCadenceCount();
                break;
            case SHORT_CADENCE:
                cadenceType = Cadence.CadenceType.SHORT;
                cadenceCount = packerParams.getLongCadenceCount()
                    * spacecraftConfigParams.getShortCadencesPerLongCadence();
                break;
            default:
                throw new IllegalStateException(
                    "Unexpected TargetTable.type = " + tls.getType());
        }

        // Write the outputs to the local disk, then copy to NFS.
        Configuration configService = ConfigurationServiceFactory.getInstance();
        String relativeDir = configService.getString(
            ExternalProcessPipelineModule.MODULE_EXE_WORKING_DIR_PROPERTY_NAME,
            ".");
        localOutputDir = new File(relativeDir, "etem2FitsOut-IID"
            + pipelineInstance.getId() + "-TID" + pipelineTask.getId());

        Etem2Fits.loadRequantizationTable(compressionId);

        secondsPerShortCadence = spacecraftConfigParams.getSecondsPerShortCadence();
        shortCadencesPerLong = spacecraftConfigParams.getShortCadencesPerLongCadence();

        badId = photometerConfigParams.getBadExternalId();
        bgpId = photometerConfigParams.getBgpExternalId();
        tadId = photometerConfigParams.getTadExternalId();
        lctId = photometerConfigParams.getLctExternalId();
        sctId = photometerConfigParams.getSctExternalId();
        rptId = photometerConfigParams.getRptExternalId();
    }
}
