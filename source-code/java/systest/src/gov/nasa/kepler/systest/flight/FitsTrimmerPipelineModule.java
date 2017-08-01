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

package gov.nasa.kepler.systest.flight;

import static gov.nasa.kepler.common.FitsConstants.*;
import gov.nasa.kepler.common.FitsUtils;
import gov.nasa.kepler.common.pi.ModuleOutputListsParameters;
import gov.nasa.kepler.dr.NmGenerator;
import gov.nasa.kepler.dr.dispatch.DispatcherWrapperFactory;
import gov.nasa.kepler.hibernate.pi.PipelineInstance;
import gov.nasa.kepler.hibernate.pi.PipelineModule;
import gov.nasa.kepler.hibernate.pi.PipelineTask;
import gov.nasa.kepler.hibernate.pi.UnitOfWorkTask;
import gov.nasa.kepler.hibernate.tad.ObservedTarget;
import gov.nasa.kepler.hibernate.tad.TargetCrud;
import gov.nasa.kepler.hibernate.tad.TargetDefinition;
import gov.nasa.kepler.hibernate.tad.TargetTable;
import gov.nasa.kepler.hibernate.tad.TargetTable.TargetType;
import gov.nasa.kepler.mc.KeplerException;
import gov.nasa.kepler.mc.uow.SingleUowTask;
import gov.nasa.kepler.tad.xml.TadXmlFileOperations;
import gov.nasa.kepler.tad.xml.TadXmlImportPipelineModule;
import gov.nasa.spiffy.common.io.FileUtil;
import gov.nasa.spiffy.common.pi.Parameters;
import gov.nasa.spiffy.common.pi.PipelineException;

import java.io.File;
import java.io.FileInputStream;
import java.io.FilenameFilter;
import java.io.IOException;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

import nom.tam.fits.Fits;
import nom.tam.fits.FitsException;
import nom.tam.fits.Header;

import org.apache.commons.io.FileUtils;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * This {@link PipelineModule} accepts source pmrf and cadence fits files and
 * produces trimmed pmrf and cadence fits files. keplerIds which are not in the
 * {@link TargetTable} referenced by the source pmrf files are trimmed from the
 * fits files. This class is intended for use with
 * {@link TadXmlImportPipelineModule} to import flight data into the dev
 * pipeline.
 * 
 * @author Miles Cote
 * 
 */
public class FitsTrimmerPipelineModule extends PipelineModule {

    private static final String SOC_LOCAL_SOC = "/path/to";

    public static final String MODULE_NAME = "fitsTrimmer";

    private static final Log log = LogFactory.getLog(FitsTrimmerPipelineModule.class);

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
        List<Class<? extends Parameters>> requiredParams = new ArrayList<Class<? extends Parameters>>();
        requiredParams.add(FitsTrimmerParameters.class);
        requiredParams.add(ModuleOutputListsParameters.class);
        return requiredParams;
    }

    @Override
    public void processTask(PipelineInstance pipelineInstance,
        PipelineTask pipelineTask) {
        try {
            FitsTrimmerParameters fitsTrimmerParams = pipelineTask.getParameters(FitsTrimmerParameters.class);
            ModuleOutputListsParameters moduleOutputListsParams = pipelineTask.getParameters(ModuleOutputListsParameters.class);

            File pmrfSrcDir = new File(fitsTrimmerParams.getPmrfSrcDir());
            File cadenceFitsSrcDir = new File(
                fitsTrimmerParams.getCadenceFitsSrcDir());
            File pmrfOutputDir = new File(fitsTrimmerParams.getPmrfOutputDir());
            File cadenceFitsOutputDir = new File(
                fitsTrimmerParams.getCadenceFitsOutputDir());

            // Require that output dirs are empty to prevent the possibility of
            // deleting flight data, but allow cleaning dirs in the local tree.
            if (pmrfOutputDir.exists() && pmrfOutputDir.listFiles().length != 0
                && !pmrfOutputDir.getAbsolutePath()
                    .startsWith(SOC_LOCAL_SOC)) {
                throw new PipelineException(
                    "The pmrfOutputDir must be empty.\n  pmrfOutputDir: "
                        + pmrfOutputDir + "\n  pmrfOutputDir file count: "
                        + pmrfOutputDir.listFiles().length);
            }
            if (cadenceFitsOutputDir.exists()
                && cadenceFitsOutputDir.listFiles().length != 0
                && !cadenceFitsOutputDir.getAbsolutePath()
                    .startsWith(SOC_LOCAL_SOC)) {
                throw new PipelineException(
                    "The cadenceFitsOutputDir must be empty.\n  cadenceFitsOutputDir: "
                        + cadenceFitsOutputDir
                        + "\n  cadenceFitsOutputDir file count: "
                        + cadenceFitsOutputDir.listFiles().length);
            }

            log.info("Copying pmrf source to output.");
            FileUtil.cleanDir(pmrfOutputDir);
            for (File srcFile : pmrfSrcDir.listFiles()) {
                if (srcFile.getName()
                    .endsWith(DispatcherWrapperFactory.LONG_CADENCE_TARGET_PMRF)
                    || srcFile.getName()
                        .endsWith(
                            DispatcherWrapperFactory.LONG_CADENCE_COLLATERAL_PMRF)
                    || srcFile.getName()
                        .endsWith(DispatcherWrapperFactory.BACKGROUND_PMRF)) {
                    FileUtils.copyFileToDirectory(srcFile, pmrfOutputDir);
                }
            }

            log.info("Copying cadence fits source to output.");
            FileUtil.cleanDir(cadenceFitsOutputDir);
            for (File srcFile : cadenceFitsSrcDir.listFiles()) {
                if (srcFile.getName()
                    .endsWith(DispatcherWrapperFactory.LONG_CADENCE_TARGET)
                    || srcFile.getName()
                        .endsWith(DispatcherWrapperFactory.LONG_CADENCE_COLLATERAL)
                    || srcFile.getName()
                        .endsWith(DispatcherWrapperFactory.LONG_CADENCE_BACKGROUND)) {
                    FileUtils.copyFileToDirectory(srcFile, cadenceFitsOutputDir);
                }
            }

            log.info("Trimming lc target pmrf and cadence fits files.");
            trimLcTargetFiles(moduleOutputListsParams, pmrfOutputDir,
                cadenceFitsOutputDir);

            log.info("Trimming background pmrf and cadence fits files.");
            trimBackgroundFiles(moduleOutputListsParams, pmrfOutputDir,
                cadenceFitsOutputDir);

            log.info("Trimming collateral cadence fits files.");
            trimCollateralFiles(moduleOutputListsParams, pmrfOutputDir,
                cadenceFitsOutputDir);

            // Generate NMs.
            NmGenerator.generateNotificationMessage(
                pmrfOutputDir.getAbsolutePath(), "tara");
            NmGenerator.generateNotificationMessage(
                cadenceFitsOutputDir.getAbsolutePath(), "sfnm");
        } catch (Exception e) {
            throw new PipelineException("Unable to process task.", e);
        }
    }

    private void trimLcTargetFiles(
        ModuleOutputListsParameters moduleOutputListsParams,
        File pmrfOutputDir, File cadenceFitsOutputDir) throws FitsException,
        IOException, KeplerException {
        // Get lc target externalId.
        File lcTargetPmrfFile = new TadXmlFileOperations().getFile(
            pmrfOutputDir, DispatcherWrapperFactory.LONG_CADENCE_TARGET_PMRF, null);
        Fits fits = new Fits(lcTargetPmrfFile);
        Header primaryHduHeader = fits.getHDU(0)
            .getHeader();
        int lcTargetTableId = FitsUtils.getHeaderIntValueChecked(
            primaryHduHeader, LCTRGDEF_KW);
        fits.getStream()
            .close();

        // Trim lc target pmrf file.
        Set<Integer> lcTargetKeplerIds = getKeplerIds(lcTargetTableId,
            TargetType.LONG_CADENCE);
        PmrfTrimmer pmrfTrimmer = new PmrfTrimmer();
        List<IncludedHdu> lcTargetIncludedHdus = pmrfTrimmer.trim(
            lcTargetPmrfFile, moduleOutputListsParams, lcTargetKeplerIds);

        log.info("Removing lc target cadence fits files that do not have a matching target table externalId.");
        List<File> lcTargetCadenceFitsFiles = getFiles(cadenceFitsOutputDir,
            DispatcherWrapperFactory.LONG_CADENCE_TARGET);
        removeFiles(lcTargetCadenceFitsFiles,
            LCTRGDEF_KW, lcTargetTableId);

        // Trim lc target cadence fits files.
        CadenceFitsTrimmer cadenceFitsTrimmer = new CadenceFitsTrimmer();
        lcTargetCadenceFitsFiles = getFiles(cadenceFitsOutputDir,
            DispatcherWrapperFactory.LONG_CADENCE_TARGET);
        cadenceFitsTrimmer.trim(lcTargetCadenceFitsFiles, lcTargetIncludedHdus);
    }

    private void trimBackgroundFiles(
        ModuleOutputListsParameters moduleOutputListsParams,
        File pmrfOutputDir, File cadenceFitsOutputDir) throws FitsException,
        IOException, KeplerException {
        // Get background externalId.
        File backgroundPmrfFile = new TadXmlFileOperations().getFile(
            pmrfOutputDir, DispatcherWrapperFactory.BACKGROUND_PMRF, null);
        Fits fits = new Fits(backgroundPmrfFile);
        Header primaryHduHeader = fits.getHDU(0)
            .getHeader();
        int backgroundTableId = FitsUtils.getHeaderIntValueChecked(
            primaryHduHeader, BKTRGDEF_KW);
        fits.getStream()
            .close();

        // Trim backgorund pmrf file.
        Set<Integer> backgroundKeplerIds = getKeplerIds(backgroundTableId,
            TargetType.BACKGROUND);
        PmrfTrimmer pmrfTrimmer = new PmrfTrimmer();
        List<IncludedHdu> backgroundIncludedHdus = pmrfTrimmer.trim(
            backgroundPmrfFile, moduleOutputListsParams, backgroundKeplerIds);

        log.info("Removing background cadence fits files that do not have a matching target table externalId.");
        List<File> backgroundCadenceFitsFiles = getFiles(cadenceFitsOutputDir,
            DispatcherWrapperFactory.LONG_CADENCE_BACKGROUND);
        removeFiles(backgroundCadenceFitsFiles,
            BKTRGDEF_KW, backgroundTableId);

        // Trim background cadence fits files.
        CadenceFitsTrimmer cadenceFitsTrimmer = new CadenceFitsTrimmer();
        backgroundCadenceFitsFiles = getFiles(cadenceFitsOutputDir,
            DispatcherWrapperFactory.LONG_CADENCE_BACKGROUND);
        cadenceFitsTrimmer.trim(backgroundCadenceFitsFiles,
            backgroundIncludedHdus);
    }

    private void trimCollateralFiles(
        ModuleOutputListsParameters moduleOutputListsParams,
        File pmrfOutputDir, File cadenceFitsOutputDir) throws FitsException,
        IOException, KeplerException {
        // Get lc target externalId.
        File collateralPmrfFile = new TadXmlFileOperations().getFile(
            pmrfOutputDir, DispatcherWrapperFactory.LONG_CADENCE_COLLATERAL_PMRF, null);
        Fits fits = new Fits(collateralPmrfFile);
        Header primaryHduHeader = fits.getHDU(0)
            .getHeader();
        int lcTargetTableId = FitsUtils.getHeaderIntValueChecked(
            primaryHduHeader, LCTRGDEF_KW);
        fits.getStream()
            .close();

        // Trim collateral pmrf file.
        PmrfTrimmer pmrfTrimmer = new PmrfTrimmer();
        List<IncludedHdu> collateralIncludedHdus = pmrfTrimmer.trim(
            collateralPmrfFile, moduleOutputListsParams, null);

        log.info("Removing collateral cadence fits files that do not have a matching target table externalId.");
        List<File> collateralCadenceFitsFiles = getFiles(cadenceFitsOutputDir,
            DispatcherWrapperFactory.LONG_CADENCE_COLLATERAL);
        removeFiles(collateralCadenceFitsFiles,
            LCTRGDEF_KW, lcTargetTableId);

        // Trim collateral cadence fits files.
        CadenceFitsTrimmer cadenceFitsTrimmer = new CadenceFitsTrimmer();
        collateralCadenceFitsFiles = getFiles(cadenceFitsOutputDir,
            DispatcherWrapperFactory.LONG_CADENCE_COLLATERAL);
        cadenceFitsTrimmer.trim(collateralCadenceFitsFiles,
            collateralIncludedHdus);
    }

    /**
     * Remove files that do not have the input targetTableExternalId.
     * 
     * @throws FitsException
     * @throws IOException
     * @throws KeplerException
     */
    private void removeFiles(List<File> cadenceFitsFiles,
        String hdrTgtTableKeyword, int targetTableId) throws FitsException,
        IOException, KeplerException {
        for (File cadenceFitsFile : cadenceFitsFiles) {
            Fits fits = new Fits(new FileInputStream(cadenceFitsFile));
            Header primaryHduHeader = fits.getHDU(0)
                .getHeader();
            int cadenceFitsTargetTableId = FitsUtils.getHeaderIntValueChecked(
                primaryHduHeader, hdrTgtTableKeyword);
            fits.getStream()
                .close();

            if (targetTableId != cadenceFitsTargetTableId) {
                cadenceFitsFile.delete();

                log.warn("Deleting cadenceFitsFile because it has a different targetTableId.\n  cadenceFitsFile: "
                    + cadenceFitsFile
                    + "\n  expectedTargetTableId: "
                    + targetTableId
                    + "\n  cadenceFitsTargetTableId: "
                    + cadenceFitsTargetTableId);
            }
        }
    }

    private List<File> getFiles(File srcDir, final String pattern) {
        String[] fileNameArray = srcDir.list(new FilenameFilter() {
            @Override
            public boolean accept(File dir, String name) {
                return name.contains(pattern);
            }
        });

        List<File> files = new ArrayList<File>();
        for (String fileName : fileNameArray) {
            files.add(new File(srcDir, fileName));
        }

        return files;
    }

    private Set<Integer> getKeplerIds(int targetTableExternalId,
        TargetType targetType) {
        TargetCrud targetCrud = new TargetCrud();
        TargetTable targetTable = targetCrud.retrieveUplinkedTargetTable(
            targetTableExternalId, targetType);
        List<ObservedTarget> observedTargets = targetCrud.retrieveObservedTargets(targetTable);

        Set<Integer> keplerIds = new HashSet<Integer>();
        for (ObservedTarget observedTarget : observedTargets) {
            for (TargetDefinition targetDef : observedTarget.getTargetDefinitions()) {
                keplerIds.add(targetDef.getKeplerId());
            }
        }

        return keplerIds;
    }

}
