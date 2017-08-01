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

package gov.nasa.kepler.soc;

import gov.nasa.kepler.common.Cadence.CadenceType;
import gov.nasa.kepler.dr.configmap.ConfigMapRetriever;
import gov.nasa.kepler.dr.configmap.ConfigMapWriter;
import gov.nasa.kepler.dr.dispatch.DispatcherWrapper;
import gov.nasa.kepler.dr.dispatch.DispatcherWrapperFactory;
import gov.nasa.kepler.dr.dispatch.Exporter;
import gov.nasa.kepler.dr.dispatch.FitsFileLog;
import gov.nasa.kepler.dr.dispatch.FitsFileLogRetriever;
import gov.nasa.kepler.dr.dispatch.FitsFileLogWriter;
import gov.nasa.kepler.dr.dispatch.NotificationMessageHandler;
import gov.nasa.kepler.dr.fits.FitsFileWriter;
import gov.nasa.kepler.dr.gap.GapReportExporter;
import gov.nasa.kepler.dr.pixels.RclcPixelDispatcher;
import gov.nasa.kepler.dr.pmrf.Pmrf;
import gov.nasa.kepler.dr.pmrf.PmrfRetriever;
import gov.nasa.kepler.dr.pmrf.PmrfWriter;
import gov.nasa.kepler.fs.api.FileStoreClient;
import gov.nasa.kepler.fs.client.FileStoreClientFactory;
import gov.nasa.kepler.hibernate.dbservice.DatabaseService;
import gov.nasa.kepler.hibernate.dbservice.DatabaseServiceFactory;
import gov.nasa.kepler.hibernate.dr.ConfigMap;
import gov.nasa.kepler.hibernate.dr.ConfigMapCrud;
import gov.nasa.kepler.hibernate.dr.DispatchLog.DispatcherType;
import gov.nasa.kepler.hibernate.dr.LogCrud;
import gov.nasa.kepler.hibernate.dr.PixelLog.DataSetType;
import gov.nasa.kepler.hibernate.dr.PmrfLog.PmrfType;
import gov.nasa.kepler.hibernate.dr.PmrfLogCrud;
import gov.nasa.kepler.hibernate.dr.RclcPixelLogCrud;
import gov.nasa.kepler.hibernate.gar.CompressionCrud;
import gov.nasa.kepler.hibernate.tad.MaskTable.MaskType;
import gov.nasa.kepler.hibernate.tad.TargetCrud;
import gov.nasa.kepler.hibernate.tad.TargetTable.TargetType;
import gov.nasa.kepler.pi.parameters.ParametersOperations;
import gov.nasa.kepler.tad.xml.MaskReader;
import gov.nasa.kepler.tad.xml.MaskWriter;
import gov.nasa.kepler.tad.xml.TargetReader;
import gov.nasa.kepler.tad.xml.TargetWriter;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.FileWriter;

import com.google.common.collect.ImmutableList;

/**
 * Contains the system-level interfaces to the soc.
 * 
 * @author Miles Cote
 * 
 */
public class Soc {

    public static final void importGapReport(String directory, String fileName) {
        DatabaseService databaseService = DatabaseServiceFactory.getInstance();
        FileStoreClient fileStoreClient = FileStoreClientFactory.getInstance();
        try {
            databaseService.beginTransaction();
            fileStoreClient.beginLocalFsTransaction();

            DispatcherWrapper dispatcherWrapper = new DispatcherWrapperFactory().createDispatcherWrapper(
                directory, fileName, new NotificationMessageHandler());
            dispatcherWrapper.addFileName(fileName);
            dispatcherWrapper.dispatch();

            fileStoreClient.commitLocalFsTransaction();
            databaseService.commitTransaction();
        } catch (Throwable e) {
            databaseService.rollbackTransactionIfActive();
            fileStoreClient.rollbackLocalFsTransactionIfActive();
            throw new IllegalArgumentException("Unable to import.", e);
        }
    }

    public static final void exportGapReport(String cadenceTypeString,
        String cadenceNumberString, String directory, String fileName) {
        try {
            CadenceType cadenceType = CadenceType.valueOf(cadenceTypeString);
            int cadenceNumber = Integer.parseInt(cadenceNumberString);
            File file = new File(directory, fileName);

            new GapReportExporter().export(cadenceType, cadenceNumber, file);
        } catch (Throwable e) {
            throw new IllegalArgumentException("Unable to export.", e);
        }
    }

    public static final void importConfigMap(String directory, String fileName) {
        DatabaseService databaseService = DatabaseServiceFactory.getInstance();
        FileStoreClient fileStoreClient = FileStoreClientFactory.getInstance();
        try {
            databaseService.beginTransaction();
            fileStoreClient.beginLocalFsTransaction();

            DispatcherWrapper dispatcherWrapper = new DispatcherWrapperFactory().createDispatcherWrapper(
                directory, fileName, new NotificationMessageHandler());
            dispatcherWrapper.addFileName(fileName);
            dispatcherWrapper.dispatch();

            fileStoreClient.commitLocalFsTransaction();
            databaseService.commitTransaction();
        } catch (Throwable e) {
            databaseService.rollbackTransactionIfActive();
            fileStoreClient.rollbackLocalFsTransactionIfActive();
            throw new IllegalArgumentException("Unable to import.", e);
        }
    }

    public static final void exportConfigMap(String scConfigIdString,
        String directory, String fileName) {
        try {
            int scConfigId = Integer.parseInt(scConfigIdString);
            File file = new File(directory, fileName);

            new Exporter<ConfigMap>(new ConfigMapRetriever(new ConfigMapCrud(),
                scConfigId), new ConfigMapWriter(new FileWriter(file))).exportData();
        } catch (Throwable e) {
            throw new IllegalArgumentException("Unable to export.", e);
        }
    }

    public static final void importCrct(String directory, String fileName) {
        DatabaseService databaseService = DatabaseServiceFactory.getInstance();
        FileStoreClient fileStoreClient = FileStoreClientFactory.getInstance();
        try {
            databaseService.beginTransaction();
            fileStoreClient.beginLocalFsTransaction();

            DispatcherWrapper dispatcherWrapper = new DispatcherWrapperFactory().createDispatcherWrapper(
                directory, fileName, new NotificationMessageHandler());
            dispatcherWrapper.addFileName(fileName);
            dispatcherWrapper.dispatch();

            fileStoreClient.commitLocalFsTransaction();
            databaseService.commitTransaction();
        } catch (Throwable e) {
            databaseService.rollbackTransactionIfActive();
            fileStoreClient.rollbackLocalFsTransactionIfActive();
            throw new IllegalArgumentException("Unable to import.", e);
        }
    }

    public static final void exportCrct(String directory, String fileName) {
        try {
            File file = new File(directory, fileName);

            new Exporter<FitsFileLog>(new FitsFileLogRetriever(fileName),
                new FitsFileLogWriter(new FitsFileWriter(new FileOutputStream(
                    file)))).exportData();
        } catch (Throwable e) {
            throw new IllegalArgumentException("Unable to export.", e);
        }
    }

    public static final void importParameterLibrary(String directory,
        String fileName) {
        File file = new File(directory, fileName);

        DatabaseService databaseService = DatabaseServiceFactory.getInstance();
        try {
            databaseService.beginTransaction();
            new ParametersOperations().importParameterLibrary(file,
                ImmutableList.<String> of(), false);
            databaseService.commitTransaction();
        } catch (Throwable e) {
            databaseService.rollbackTransactionIfActive();
            throw new IllegalArgumentException("Unable to import.", e);
        }
    }

    public static final void exportParameterLibrary(String directory,
        String fileName) {
        try {
            File file = new File(directory, fileName);

            new ParametersOperations().exportParameterLibrary(
                file.getAbsolutePath(), ImmutableList.<String> of(), false);
        } catch (Throwable e) {
            throw new IllegalArgumentException("Unable to export.", e);
        }
    }

    public static final void importRequant(String directory, String fileName) {
        File file = new File(directory, fileName);

        DatabaseService databaseService = DatabaseServiceFactory.getInstance();
        try {
            databaseService.beginTransaction();
            new RequantImporter(new RequantReader(new FileInputStream(file)),
                new RequantStorer(new CompressionCrud())).importData();
            databaseService.commitTransaction();
        } catch (Throwable e) {
            databaseService.rollbackTransactionIfActive();
            throw new IllegalArgumentException("Unable to import.", e);
        }
    }

    public static final void exportRequant(String externalIdString,
        String directory, String fileName) {
        try {
            int externalId = Integer.parseInt(externalIdString);
            File file = new File(directory, fileName);

            new RequantExporter(new RequantRetriever(new CompressionCrud(),
                externalId), new RequantWriter(new FileOutputStream(file))).exportData();
        } catch (Throwable e) {
            throw new IllegalArgumentException("Unable to export.", e);
        }
    }

    public static final void importMasks(String directory, String fileName) {
        File file = new File(directory, fileName);

        DatabaseService databaseService = DatabaseServiceFactory.getInstance();
        try {
            databaseService.beginTransaction();
            new MaskImporter(new MaskReader(new FileInputStream(file)),
                new MaskStorer(new TargetCrud())).importData();
            databaseService.commitTransaction();
        } catch (Throwable e) {
            databaseService.rollbackTransactionIfActive();
            throw new IllegalArgumentException("Unable to import.", e);
        }
    }

    public static final void exportMasks(String externalIdString,
        String maskTypeString, String directory, String fileName) {
        try {
            int externalId = Integer.parseInt(externalIdString);
            MaskType maskType = MaskType.valueOfShortName(maskTypeString);
            File file = new File(directory, fileName);

            new MaskExporter(new MaskRetriever(new TargetCrud(), externalId,
                maskType), new MaskWriter(new FileOutputStream(file))).exportData();
        } catch (Throwable e) {
            throw new IllegalArgumentException("Unable to export.", e);
        }
    }

    public static final void importTargets(String directory, String fileName,
        String maskExternalIdString, String maskTypeString) {
        int maskExternalId = Integer.parseInt(maskExternalIdString);
        MaskType maskType = MaskType.valueOfShortName(maskTypeString);
        File file = new File(directory, fileName);

        DatabaseService databaseService = DatabaseServiceFactory.getInstance();
        try {
            databaseService.beginTransaction();
            new TargetImporter(new TargetReader(new FileInputStream(file)),
                new TargetStorer(new TargetCrud(), maskExternalId, maskType)).importData();
            databaseService.commitTransaction();
        } catch (Throwable e) {
            databaseService.rollbackTransactionIfActive();
            throw new IllegalArgumentException("Unable to import.", e);
        }
    }

    public static final void exportTargets(String externalIdString,
        String targetTypeString, String directory, String fileName) {
        try {
            int externalId = Integer.parseInt(externalIdString);
            TargetType targetType = TargetType.valueOfShortName(targetTypeString);
            File file = new File(directory, fileName);

            new TargetExporter(new TargetRetriever(new TargetCrud(),
                externalId, targetType), new TargetWriter(new FileOutputStream(
                file))).exportData();
        } catch (Throwable e) {
            throw new IllegalArgumentException("Unable to export.", e);
        }
    }

    public static final void importPmrf(String directory, String fileName) {
        DatabaseService databaseService = DatabaseServiceFactory.getInstance();
        FileStoreClient fileStoreClient = FileStoreClientFactory.getInstance();
        try {
            databaseService.beginTransaction();
            fileStoreClient.beginLocalFsTransaction();

            DispatcherWrapper dispatcherWrapper = new DispatcherWrapperFactory().createDispatcherWrapper(
                directory, fileName, new NotificationMessageHandler());
            dispatcherWrapper.addFileName(fileName);
            dispatcherWrapper.dispatch();

            fileStoreClient.commitLocalFsTransaction();
            databaseService.commitTransaction();
        } catch (Throwable e) {
            databaseService.rollbackTransactionIfActive();
            fileStoreClient.rollbackLocalFsTransactionIfActive();
            throw new IllegalArgumentException("Unable to import.", e);
        }
    }

    public static final void exportPmrf(String pmrfExternalIdString,
        String pmrfTypeString, String directory, String fileName) {
        try {
            int externalId = Integer.parseInt(pmrfExternalIdString);
            PmrfType pmrfType = PmrfType.valueOf(pmrfTypeString);
            File file = new File(directory, fileName);

            new Exporter<Pmrf>(new PmrfRetriever(new PmrfLogCrud(),
                new FitsFileLogRetriever(fileName), externalId, pmrfType),
                new PmrfWriter(new FitsFileWriter(new FileOutputStream(file)))).exportData();
        } catch (Throwable e) {
            throw new IllegalArgumentException("Unable to export.", e);
        }
    }

    public static final void importPixels(String directory, String fileName) {
        DatabaseService databaseService = DatabaseServiceFactory.getInstance();
        FileStoreClient fileStoreClient = FileStoreClientFactory.getInstance();
        try {
            databaseService.beginTransaction();
            fileStoreClient.beginLocalFsTransaction();

            DispatcherWrapper dispatcherWrapper = new DispatcherWrapperFactory().createDispatcherWrapper(
                directory, fileName, new NotificationMessageHandler());
            dispatcherWrapper.addFileName(fileName);
            dispatcherWrapper.dispatch();

            fileStoreClient.commitLocalFsTransaction();
            databaseService.commitTransaction();
        } catch (Throwable e) {
            databaseService.rollbackTransactionIfActive();
            fileStoreClient.rollbackLocalFsTransactionIfActive();
            throw new IllegalArgumentException("Unable to import.", e);
        }
    }

    public static final void exportPixels(String directory, String fileName,
        String pixelCadenceType, String dataSetTypeString,
        String pixelCadenceNumber) {
        try {
            CadenceType cadenceType = CadenceType.valueOf(pixelCadenceType);
            DataSetType dataSetType = DataSetType.valueOf(dataSetTypeString);
            int cadenceNumber = Integer.parseInt(pixelCadenceNumber);
            File file = new File(directory, fileName);

            new PixelExporter(new PixelRetriever(new LogCrud(),
                FileStoreClientFactory.getInstance(), cadenceType,
                DispatcherType.LONG_CADENCE_PIXEL, dataSetType, cadenceNumber),
                new PixelWriter(new FileOutputStream(file))).exportData();
        } catch (Throwable e) {
            throw new IllegalArgumentException("Unable to export.", e);
        }
    }

    public static final void importRclcPixels(String directory, String fileName) {
        DatabaseService databaseService = DatabaseServiceFactory.getInstance();
        FileStoreClient fileStoreClient = FileStoreClientFactory.getInstance();
        try {
            databaseService.beginTransaction();
            fileStoreClient.beginLocalFsTransaction();

            DispatcherWrapper dispatcherWrapper = new DispatcherWrapper(
                new RclcPixelDispatcher(), DispatcherType.RCLC_PIXEL,
                directory, new NotificationMessageHandler());
            dispatcherWrapper.addFileName(fileName);
            dispatcherWrapper.dispatch();

            fileStoreClient.commitLocalFsTransaction();
            databaseService.commitTransaction();
        } catch (Throwable e) {
            databaseService.rollbackTransactionIfActive();
            fileStoreClient.rollbackLocalFsTransactionIfActive();
            throw new IllegalArgumentException("Unable to import.", e);
        }
    }

    public static final void exportRclcPixels(String directory,
        String fileName, String pixelCadenceType, String dataSetTypeString,
        String pixelCadenceNumber) {
        try {
            CadenceType cadenceType = CadenceType.valueOf(pixelCadenceType);
            DataSetType dataSetType = DataSetType.valueOf(dataSetTypeString);
            int cadenceNumber = Integer.parseInt(pixelCadenceNumber);
            File file = new File(directory, fileName);

            new PixelExporter(new PixelRetriever(new RclcPixelLogCrud(),
                FileStoreClientFactory.getInstance(), cadenceType,
                DispatcherType.RCLC_PIXEL, dataSetType, cadenceNumber),
                new PixelWriter(new FileOutputStream(file))).exportData();
        } catch (Throwable e) {
            throw new IllegalArgumentException("Unable to export.", e);
        }
    }

}
