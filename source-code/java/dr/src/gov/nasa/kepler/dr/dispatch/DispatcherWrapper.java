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

package gov.nasa.kepler.dr.dispatch;

import static com.google.common.collect.Sets.newTreeSet;
import gov.nasa.kepler.dr.importer.ModelMetadataImporter;
import gov.nasa.kepler.fs.api.FileStoreClient;
import gov.nasa.kepler.fs.api.FsId;
import gov.nasa.kepler.fs.client.FileStoreClientFactory;
import gov.nasa.kepler.hibernate.dr.DispatchLog;
import gov.nasa.kepler.hibernate.dr.DispatchLog.DispatcherType;
import gov.nasa.kepler.hibernate.dr.DispatchLogFactory;
import gov.nasa.kepler.hibernate.dr.FileLog;
import gov.nasa.kepler.hibernate.dr.LogCrud;
import gov.nasa.kepler.hibernate.dr.ReceiveLog;
import gov.nasa.kepler.hibernate.pi.ModelMetadataCrud;
import gov.nasa.kepler.mc.dr.DrConstants;
import gov.nasa.kepler.mc.fs.DrFsIdFactory;

import java.io.File;
import java.util.Set;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * Wraps a {@link Dispatcher}.
 * 
 * @author Miles Cote
 * 
 */
public class DispatcherWrapper {

    public static final long DATA_RECEIPT_ORIGIN_ID = DrConstants.DATA_RECEIPT_ORIGIN_ID;

    private static final Log log = LogFactory.getLog(Dispatcher.class);

    private final Dispatcher dispatcher;
    private DispatchLog dispatchLog;
    private final Set<String> filenames = newTreeSet();
    private final DispatcherType dispatcherType;
    private final String sourceDirectory;
    private final NotificationMessageHandler notificationMessageHandler;
    private final LogCrud logCrud;
    private final ModelMetadataImporter modelMetadataImporter;
    private final DispatchLogFactory dispatchLogFactory;
    private final FileStoreClient fileStoreClient;

    public DispatcherWrapper(Dispatcher dispatcher,
        DispatcherType dispatcherType, String sourceDirectory,
        NotificationMessageHandler notificationMessageHandler) {
        this(dispatcher, dispatcherType, sourceDirectory,
            notificationMessageHandler, new LogCrud(),
            new ModelMetadataImporter(new ModelMetadataCrud()),
            new DispatchLogFactory(), FileStoreClientFactory.getInstance());
    }

    DispatcherWrapper(Dispatcher dispatcher, DispatcherType dispatcherType,
        String sourceDirectory,
        NotificationMessageHandler notificationMessageHandler, LogCrud logCrud,
        ModelMetadataImporter modelMetadataImporter,
        DispatchLogFactory dispatchLogFactory, FileStoreClient fileStoreClient) {
        this.dispatcher = dispatcher;
        this.dispatcherType = dispatcherType;
        this.sourceDirectory = sourceDirectory;
        this.notificationMessageHandler = notificationMessageHandler;
        this.logCrud = logCrud;
        this.modelMetadataImporter = modelMetadataImporter;
        this.dispatchLogFactory = dispatchLogFactory;
        this.fileStoreClient = fileStoreClient;
    }

    public void addFileName(String filename) {
        try {
            filenames.add(filename);
        } catch (Exception e) {
            throwExceptionForFile(filename, e);
        }
    }

    public void dispatch() {
        ReceiveLog receiveLog = notificationMessageHandler.getReceiveLog();

        dispatchLog = dispatchLogFactory.create(receiveLog, dispatcherType);
        logCrud.createDispatchLog(dispatchLog);

        notificationMessageHandler.getDispatchLogs()
            .add(dispatchLog);

        log.info("Calling " + getClass().getSimpleName() + ".process()...");
        log.info("Processing " + filenames.size() + " files...");

        dispatchLog.start();

        dispatchLog.setTotalFileCount(filenames.size());

        dispatcher.dispatch(filenames, sourceDirectory, dispatchLog, this);

        modelMetadataImporter.importModelMetadata(receiveLog, dispatcherType);

        dispatchLog.end();

        filenames.clear();

        log.info("Completed " + getClass().getSimpleName() + ".process()");
    }

    public FileLog storeFile(String filename) {
        log.info("Storing " + dispatcherType + " file in the filestore: "
            + filename);

        FsId fsId = DrFsIdFactory.getFile(dispatcherType, filename);

        fileStoreClient.writeBlob(fsId, DATA_RECEIPT_ORIGIN_ID, new File(
            sourceDirectory, filename));

        FileLog fileLog = logCrud.createFileLog(dispatchLog, filename);

        return fileLog;
    }

    public void throwExceptionForFile(String filename, Throwable e) {
        throw new DispatchException("Unable to process file.\n  filename: "
            + filename + "\n", e);
    }

    public String getName() {
        return dispatcher.getClass()
            .getSimpleName();
    }

}
