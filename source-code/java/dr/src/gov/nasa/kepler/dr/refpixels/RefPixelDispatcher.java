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

package gov.nasa.kepler.dr.refpixels;

import gov.nasa.kepler.common.FcConstants;
import gov.nasa.kepler.dr.dispatch.DispatchException;
import gov.nasa.kepler.dr.dispatch.Dispatcher;
import gov.nasa.kepler.dr.dispatch.DispatcherWrapper;
import gov.nasa.kepler.dr.dispatch.Launchable;
import gov.nasa.kepler.dr.dispatch.PipelineLauncher;
import gov.nasa.kepler.hibernate.dbservice.DatabaseServiceFactory;
import gov.nasa.kepler.hibernate.dr.DispatchLog;
import gov.nasa.kepler.hibernate.dr.FileLog;
import gov.nasa.kepler.hibernate.dr.LogCrud;
import gov.nasa.kepler.hibernate.dr.RefPixelLog;
import gov.nasa.kepler.hibernate.gar.CompressionCrud;
import gov.nasa.kepler.hibernate.gar.HuffmanTable;
import gov.nasa.kepler.hibernate.gar.RequantTable;
import gov.nasa.kepler.hibernate.pdq.RefPixelPipelineParameters;
import gov.nasa.kepler.hibernate.pi.ClassWrapper;
import gov.nasa.kepler.hibernate.pi.ParameterSetName;
import gov.nasa.kepler.hibernate.pi.TriggerDefinition;
import gov.nasa.kepler.hibernate.tad.TargetCrud;
import gov.nasa.kepler.hibernate.tad.TargetDefinition;
import gov.nasa.kepler.hibernate.tad.TargetTable;
import gov.nasa.kepler.hibernate.tad.TargetTable.TargetType;
import gov.nasa.kepler.mc.refpixels.RefPixelFileReader;
import gov.nasa.kepler.mc.vtc.VtcOperations;
import gov.nasa.kepler.pi.pipeline.PipelineOperations;
import gov.nasa.kepler.services.alert.AlertServiceFactory;
import gov.nasa.spiffy.common.pi.Parameters;
import gov.nasa.spiffy.common.pi.PipelineException;

import java.io.File;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * This Dispatcher handles ingest and storage of reference pixel) data received
 * from the MOC
 * 
 * The reference pixel binary file is read with
 * {@link gov.nasa.kepler.mc.refpixels.RefPixelFileReader}. {@link TargetCrud}
 * is used to retrieve the target definitions that correspond to this data set
 * by using the externalId specified in the file.
 * 
 * {@link RefPixelLog} and {@link LogCrud} are used to store metadata about the
 * reference pixels in the database.
 * 
 * @author Forrest Girouard
 * @author Todd Klaus
 */
public class RefPixelDispatcher implements Dispatcher, Launchable {

    private static final Log log = LogFactory.getLog(RefPixelDispatcher.class);

    private LogCrud logCrud;
    private TargetCrud targetCrud;
    private CompressionCrud compressionCrud;
    private Set<Integer> targetTableIds = new HashSet<Integer>();

    private int targetTableId;

    public RefPixelDispatcher() {
        try {
            logCrud = new LogCrud(DatabaseServiceFactory.getInstance());
            targetCrud = new TargetCrud(DatabaseServiceFactory.getInstance());
            compressionCrud = new CompressionCrud(
                DatabaseServiceFactory.getInstance());
        } catch (PipelineException e) {
            throw new DispatchException("Failed to initialize Cruds", e);
        }
    }

    @Override
    public void dispatch(Set<String> filenames, String sourceDirectory,
        DispatchLog dispatchLog, DispatcherWrapper dispatcherWrapper) {
        log.info("file count = " + filenames.size());
        log.info("extracting and storing reference pixel data");

        extractAndStore(filenames, sourceDirectory, dispatcherWrapper);

        // Launch pipeline(s).
        for (int ttId : targetTableIds) {
            targetTableId = ttId;

            new PipelineLauncher().launchIfEnabled(this, dispatchLog);
        }
    }

    @Override
    public void augmentPipelineParameters(TriggerDefinition triggerDefinition) {
        Map<ClassWrapper<Parameters>, ParameterSetName> pipelineParameterSetNames = triggerDefinition.getPipelineParameterSetNames();
        ParameterSetName parameterSetName = pipelineParameterSetNames.get(new ClassWrapper<Parameters>(
            RefPixelPipelineParameters.class));

        RefPixelPipelineParameters parameters = new RefPixelPipelineParameters();
        parameters.setReferencePixelTargetTableId(targetTableId);

        PipelineOperations pipelineOperations = new PipelineOperations();
        pipelineOperations.updateParameterSet(parameterSetName, parameters,
            false);
    }

    protected void extractAndStore(Set<String> filenames,
        String sourceDirectory, DispatcherWrapper dispatcherWrapper) {
        log.info("Extracting and storing cadence metadata");

        for (String filename : filenames) {
            try {
                FileLog fileLog = dispatcherWrapper.storeFile(filename);

                String filePath = sourceDirectory + File.separatorChar
                    + filename;
                RefPixelFileReader refPixelFileReader = new RefPixelFileReader(
                    new File(filePath));

                log.info("Reading reference pixel file contents for file: "
                    + filePath);

                long timestamp = refPixelFileReader.getTimestamp();

                RefPixelLog refPixelLog = null;

                // first see if this timestamp is already there (re-processing
                // case)
                refPixelLog = logCrud.retrieveRefPixelLog(timestamp);

                if (refPixelLog == null) {

                    processRefPixelFile(refPixelFileReader, filePath);

                    // create the entry for this timestamp
                    int tableId = refPixelFileReader.getReferencePixelTargetTableId();
                    int numRefPixels = refPixelFileReader.getNumberOfReferencePixels();
                    int compressionId = refPixelFileReader.getCompressionTableId();

                    VtcOperations vtcOperations = new VtcOperations();
                    double mjd = vtcOperations.getMjd(timestamp);

                    validateCompressionId(compressionId);

                    refPixelLog = new RefPixelLog(fileLog, timestamp, tableId,
                        numRefPixels, compressionId, mjd);
                    logCrud.createRefPixelLog(refPixelLog);

                    targetTableIds.add(tableId);
                } else {
                    /*
                     * Already ingested, skip this file. The MOC will always
                     * send all 9 reference pixel files (the entire contents of
                     * the on-board buffer), so we will get duplicates. They
                     * will always be the same as the original, so if we have
                     * already ingested it, we can ignore it here.
                     */

                    log.info("Skipping file: " + filename
                        + " because it was previously ingested");
                    continue;
                }
            } catch (Exception e) {
                dispatcherWrapper.throwExceptionForFile(filename, e);
            }
        }
    }

    private void validateCompressionId(int externalId) {
        HuffmanTable huffmanTable = compressionCrud.retrieveUplinkedHuffmanTable(externalId);
        if (huffmanTable == null) {
            AlertServiceFactory.getInstance()
                .generateAlert(
                    getClass().getSimpleName(),
                    "An uplinked huffman table must exist in the database for a compressionExternalId in an incoming file.  compressionExternalId = "
                        + externalId);
        }

        RequantTable requantTable = compressionCrud.retrieveUplinkedRequantTable(externalId);
        if (requantTable == null) {
            AlertServiceFactory.getInstance()
                .generateAlert(
                    getClass().getSimpleName(),
                    "An uplinked requant table must exist in the database for a compressionExternalId in an incoming file.  compressionExternalId = "
                        + externalId);
        }
    }

    private void processRefPixelFile(RefPixelFileReader refPixelFileReader,
        String filePath) {
        int numPixelsInFile = refPixelFileReader.getNumberOfReferencePixels();
        int tableId = refPixelFileReader.getReferencePixelTargetTableId();

        TargetTable targetTable = targetCrud.retrieveUplinkedTargetTable(
            tableId, TargetType.REFERENCE_PIXEL);

        if (targetTable == null) {
            throw new DispatchException(
                "Failed to find TargetTable for tableId=" + tableId);
        }

        int numPixelsInTad = 0;

        for (int ccdModule : FcConstants.modulesList) {
            for (int ccdOutput : FcConstants.outputsList) {
                /*
                 * These come back in the same order as the pixels in the
                 * reference pixel file.
                 */
                List<TargetDefinition> targetDefs = targetCrud.retrieveTargetDefinitions(
                    targetTable, ccdModule, ccdOutput);

                for (TargetDefinition targetDef : targetDefs) {
                    int numPixelsInMask = targetDef.getMask()
                        .getOffsets()
                        .size();
                    numPixelsInTad += numPixelsInMask;
                }
            }
        }

        if (numPixelsInTad != numPixelsInFile) {
            throw new DispatchException("Number of pixels found in file ("
                + numPixelsInFile
                + ") does not match number of pixels in target table ("
                + numPixelsInTad + ")");
        }
    }

}
