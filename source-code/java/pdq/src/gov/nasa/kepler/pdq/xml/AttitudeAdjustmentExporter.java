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

package gov.nasa.kepler.pdq.xml;

import gov.nasa.kepler.common.DateUtils;
import gov.nasa.kepler.common.ModifiedJulianDate;
import gov.nasa.kepler.common.file.Md5Sum;
import gov.nasa.kepler.hibernate.dbservice.DatabaseServiceFactory;
import gov.nasa.kepler.hibernate.pdq.AttitudeAdjustment;
import gov.nasa.kepler.hibernate.pdq.PdqCrud;
import gov.nasa.kepler.nm.DataProductMessageDocument;
import gov.nasa.kepler.nm.DataProductMessageXB;
import gov.nasa.kepler.nm.FileListXB;
import gov.nasa.kepler.nm.FileXB;
import gov.nasa.kepler.pdq.attitudeAdjustment.AttitudeAdjustmentDocument;
import gov.nasa.kepler.pdq.attitudeAdjustment.AttitudeAdjustmentXB;
import gov.nasa.kepler.pdq.attitudeAdjustment.DeltaQuaternionXB;
import gov.nasa.spiffy.common.pi.PipelineException;

import java.io.File;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.apache.xmlbeans.XmlError;
import org.apache.xmlbeans.XmlOptions;

/**
 * This class exports a specified {@link AttitudeAdjustment} to a specified
 * directory.
 * 
 * @author Forrest Girouard (fgirouard)
 * 
 */
public class AttitudeAdjustmentExporter {

    private static final Log log = LogFactory.getLog(AttitudeAdjustmentExporter.class);

    private static final String FILENAME_PREFIX = "kplr";
    private static final String FILENAME_BASE = "_delta-quaternion";
    private static final String FILENAME_SUFFIX = ".xml";

    public static void main(final String[] args) throws IOException {
        if (args.length != 1) {
            System.err.println("USAGE: export-attitude-adjustment EXPORT_DIR");
            System.err.println("  example: export-attitude-adjustment ops");
            System.exit(-1);
        }

        String path = args[0];

        File file = new File(path);
        if (!file.exists() || !file.isDirectory()) {
            throw new IllegalArgumentException(file.getAbsolutePath()
                + ": no such directory");
        }
        try {
            DatabaseServiceFactory.getInstance()
                .beginTransaction();

            AttitudeAdjustment attitudeDelta = new PdqCrud().retrieveLatestAttitudeAdjustment();
            if (attitudeDelta == null) {
                log.warn("no attitude adjustments available");
            } else {
                file = new AttitudeAdjustmentExporter().export(path,
                    attitudeDelta);
                if (file == null) {
                    log.warn("attitude adjustment not exported");
                } else {
                    log.info(file.getAbsoluteFile()
                        + ": contains exported attitude adjustment.");
                }
            }

            DatabaseServiceFactory.getInstance()
                .commitTransaction();
        } finally {
            DatabaseServiceFactory.getInstance()
                .rollbackTransactionIfActive();
        }
    }

    public File export(final String path, final AttitudeAdjustment attitudeDelta)
        throws IOException {

        if (path == null) {
            throw new NullPointerException("path is null");
        }
        File file = new File(path);
        if (!file.exists()) {
            throw new IllegalArgumentException("Directory " + path
                + " does not exist");
        }
        if (!file.isDirectory()) {
            throw new IllegalArgumentException(path + " is not a directory");
        }
        if (!file.canWrite()) {
            throw new IllegalArgumentException(
                "You do not have permission to add files to " + path);
        }
        if (attitudeDelta == null) {
            throw new NullPointerException("attitudeAdjustment can't be null");
        }

        Date date = new Date();
        String timeGenerated = DateUtils.formatLikeDmc(date);
        AttitudeAdjustmentDocument doc = AttitudeAdjustmentDocument.Factory.newInstance();
        AttitudeAdjustmentXB attitudeDeltaXB = doc.addNewAttitudeAdjustment();
        attitudeDeltaXB.setTimeGenerated(timeGenerated);
        DeltaQuaternionXB deltaQuaternionXB = attitudeDeltaXB.addNewDeltaQuaternion();
        deltaQuaternionXB.setStartTime(DateUtils.formatLikeDmc(ModifiedJulianDate.mjdToDate(attitudeDelta.getRefPixelLog()
            .getMjd())));
        deltaQuaternionXB.setX(attitudeDelta.getX());
        deltaQuaternionXB.setY(attitudeDelta.getY());
        deltaQuaternionXB.setZ(attitudeDelta.getZ());
        deltaQuaternionXB.setW(attitudeDelta.getW());

        XmlOptions xmlOptions = new XmlOptions().setSavePrettyPrint()
            .setSavePrettyPrintIndent(2);
        List<XmlError> errors = new ArrayList<XmlError>();
        xmlOptions.setErrorListener(errors);
        if (!doc.validate(xmlOptions)) {
            throw new PipelineException("XML validation errors: " + errors);
        }

        // Save the delta quaternion.
        file = new File(path, FILENAME_PREFIX + timeGenerated + FILENAME_BASE
            + FILENAME_SUFFIX);
        doc.save(file, xmlOptions);

        writeNotificationMessage(path, file, timeGenerated);

        // Update the given attitude adjustment with the time generated.
        attitudeDelta.setTimeGenerated(date);

        return file;
    }

    private void writeNotificationMessage(final String path, final File file,
        final String timeGenerated) throws IOException {

        DataProductMessageDocument doc = DataProductMessageDocument.Factory.newInstance();
        DataProductMessageXB dataProductMessage = doc.addNewDataProductMessage();

        dataProductMessage.setMessageType("DQNM");
        String dqnmFilename = String.format("%s%s_%s%s", FILENAME_PREFIX,
            timeGenerated, "dqnm", FILENAME_SUFFIX);
        dataProductMessage.setIdentifier(dqnmFilename);

        FileListXB fileList = dataProductMessage.addNewFileList();
        FileXB dataProductFile = fileList.addNewFile();
        dataProductFile.setFilename(file.getName());
        dataProductFile.setSize(file.length());
        dataProductFile.setChecksum(Md5Sum.computeMd5(file));

        XmlOptions xmlOptions = new XmlOptions().setSavePrettyPrint()
            .setSavePrettyPrintIndent(2);
        List<XmlError> errors = new ArrayList<XmlError>();
        xmlOptions.setErrorListener(errors);
        if (!doc.validate(xmlOptions)) {
            throw new PipelineException("XML validation errors: " + errors);
        }

        File dqnmFile = new File(path, dqnmFilename);
        doc.save(dqnmFile, xmlOptions);
    }
}
