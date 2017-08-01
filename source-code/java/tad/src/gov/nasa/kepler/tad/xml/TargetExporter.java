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

package gov.nasa.kepler.tad.xml;

import static com.google.common.collect.Lists.newArrayList;
import gov.nasa.kepler.common.DateUtils;
import gov.nasa.kepler.common.file.Md5Sum;
import gov.nasa.kepler.hibernate.gar.ExportTable;
import gov.nasa.kepler.hibernate.tad.Mask;
import gov.nasa.kepler.hibernate.tad.MaskTable;
import gov.nasa.kepler.hibernate.tad.MaskTable.MaskType;
import gov.nasa.kepler.hibernate.tad.TargetCrud;
import gov.nasa.kepler.hibernate.tad.TargetDefinition;
import gov.nasa.kepler.hibernate.tad.TargetTable;
import gov.nasa.kepler.hibernate.tad.TargetTable.TargetType;
import gov.nasa.kepler.hibernate.tad.TypedTable;
import gov.nasa.kepler.nm.DataProductMessageDocument;
import gov.nasa.kepler.nm.DataProductMessageXB;
import gov.nasa.kepler.nm.FileListXB;
import gov.nasa.kepler.nm.FileXB;
import gov.nasa.spiffy.common.pi.PipelineException;

import java.io.File;
import java.io.IOException;
import java.util.Date;
import java.util.List;

import org.apache.xmlbeans.XmlError;
import org.apache.xmlbeans.XmlOptions;

/**
 * This class exports {@link TargetTable}s and {@link MaskTable}s from the
 * database to a directory in XMl format.
 * 
 * @author Miles Cote
 */
public class TargetExporter {

    private final TargetCrud targetCrud;
    private final MaskWriterFactory maskWriterFactory;
    private final TargetWriterFactory targetWriterFactory;
    private final Date timeGenerated;

    public TargetExporter() {
        this(new TargetCrud(), new MaskWriterFactory(),
            new TargetWriterFactory(), new Date());
    }

    TargetExporter(TargetCrud targetCrud, MaskWriterFactory maskWriterFactory,
        TargetWriterFactory targetWriterFactory, Date timeGenerated) {
        this.targetCrud = targetCrud;
        this.maskWriterFactory = maskWriterFactory;
        this.targetWriterFactory = targetWriterFactory;
        this.timeGenerated = timeGenerated;
    }

    /**
     * Exports the group of target and aperture tables that could be sent to the
     * MOC. It is acceptable to pass in {@code null} target tables; these are
     * ignored. However, short cadence and reference pixel target tables still
     * require a long cadence target table and a target mask table. Used by the
     * export GUI.
     * 
     * @param lcTargetTable the long cadence target table to export.
     * @param bgTargetTable the background target table to export.
     * @param targetMaskTable the target aperture table to export.
     * @param bgMaskTable the background aperture table to export.
     * @param rpTargetTable the reference pixel target table to export.
     * @param sc1TargetTable the short cadence target table to export for month
     * 1.
     * @param sc2TargetTable the short cadence target table to export for month
     * 2.
     * @param sc3TargetTable the short cadence target table to export for month
     * 3.
     * @param path the directory in which to create the files.
     * @return the created files.
     * @throws PipelineException if there was a problem reading from the
     * database.
     * @throws IOException if there was a problem creating the files.
     */
    public List<File> export(TargetTable lcTargetTable,
        TargetTable bgTargetTable, MaskTable targetMaskTable,
        MaskTable bgMaskTable, TargetTable rpTargetTable,
        TargetTable sc1TargetTable, TargetTable sc2TargetTable,
        TargetTable sc3TargetTable, String path) {

        validatePath(path);

        // Validate for export. (Check that export table fields are legal.)
        validateForExport(targetMaskTable, MaskType.TARGET, null, null);
        validateForExport(bgMaskTable, MaskType.BACKGROUND, null, null);
        validateForExport(lcTargetTable, TargetType.LONG_CADENCE, null, null);
        validateForExport(bgTargetTable, TargetType.BACKGROUND, null, null);
        validateForExport(rpTargetTable, TargetType.REFERENCE_PIXEL,
            lcTargetTable, targetMaskTable);
        validateForExport(sc1TargetTable, TargetType.SHORT_CADENCE,
            lcTargetTable, targetMaskTable);
        validateForExport(sc2TargetTable, TargetType.SHORT_CADENCE,
            lcTargetTable, targetMaskTable);
        validateForExport(sc3TargetTable, TargetType.SHORT_CADENCE,
            lcTargetTable, targetMaskTable);

        // Export.
        List<File> files = newArrayList();

        files.add(exportMaskTable(targetMaskTable, path, timeGenerated));
        files.add(exportMaskTable(bgMaskTable, path, timeGenerated));

        files.add(exportTargetTable(bgTargetTable, path, timeGenerated));
        files.add(exportTargetTable(rpTargetTable, path, timeGenerated));

        files.add(exportTargetTable(sc1TargetTable, path, timeGenerated));
        files.add(exportTargetTable(sc2TargetTable, path, timeGenerated));
        files.add(exportTargetTable(sc3TargetTable, path, timeGenerated));

        files.add(exportTargetTable(lcTargetTable, path, timeGenerated));

        // Create notification message.
        DataProductMessageDocument doc = DataProductMessageDocument.Factory.newInstance();
        DataProductMessageXB dataProductMessage = doc.addNewDataProductMessage();

        dataProductMessage.setMessageType("TANM");
        String tanmFilename = String.format("kplr%s_%s.xml",
            DateUtils.formatLikeDmc(timeGenerated), "tanm");
        dataProductMessage.setIdentifier(tanmFilename);

        FileListXB fileList = dataProductMessage.addNewFileList();

        // Add provided target or mask tables to notification message.
        for (File file : files) {
            if (file != null && file.exists()) {
                FileXB dataProductFile = fileList.addNewFile();
                dataProductFile.setFilename(file.getName());
                dataProductFile.setSize(file.length());
                try {
                    dataProductFile.setChecksum(Md5Sum.computeMd5(file));
                } catch (IOException e) {
                    throw new IllegalArgumentException("Unable to computeMd5.",
                        e);
                }
            }
        }

        XmlOptions xmlOptions = new XmlOptions().setSavePrettyPrint()
            .setSavePrettyPrintIndent(2);
        List<XmlError> errors = newArrayList();
        xmlOptions.setErrorListener(errors);
        if (!doc.validate(xmlOptions)) {
            throw new PipelineException("XML validation error.  " + errors);
        }

        File tanmFile = new File(path, tanmFilename);
        try {
            doc.save(tanmFile, xmlOptions);
        } catch (IOException e) {
            throw new IllegalArgumentException("Unable to save.", e);
        }

        files.add(tanmFile);

        return files;
    }

    private void validatePath(String path) {
        File file = new File(path);
        if (!file.isDirectory()) {
            throw new IllegalArgumentException(path + " is not a directory");
        }
        // This check does not work with nfs. nfs always assumes the client
        // can't write to a file.
        // if (!file.canWrite()) {
        // throw new IllegalArgumentException(
        // "You do not have permission to add files to " + path);
        // }
    }

    private void validateForExport(ExportTable exportTable,
        Object expectedType, TargetTable lcTargetTable, MaskTable lcMaskTable) {

        // Ignore target tables that aren't given.
        if (exportTable == null) {
            return;
        }

        exportTable.validate();

        if (((TypedTable) exportTable).getType() != expectedType) {
            throw new IllegalStateException("Export table " + exportTable
                + "\nmust be of type " + expectedType);
        }

        if (expectedType == TargetType.SHORT_CADENCE) {
            TargetTable scTargetTable = (TargetTable) exportTable;
            if (scTargetTable.getMaskTable() != lcMaskTable) {
                throw new IllegalStateException(
                    "Short and long cadence target tables must have the same mask table.\n\n"
                        + "Long cadence: " + lcTargetTable
                        + "\nShort cadence: " + scTargetTable);
            }
        } else if (expectedType == TargetType.REFERENCE_PIXEL) {
            TargetTable rpTargetTable = (TargetTable) exportTable;
            if (rpTargetTable.getMaskTable() != lcMaskTable) {
                throw new IllegalStateException(
                    "Reference pixel and long cadence target tables must have the same mask table.\n\n"
                        + "Long cadence: "
                        + lcTargetTable
                        + "\nReference pixel: " + rpTargetTable);
            }
        }
    }

    private File exportMaskTable(MaskTable maskTable, String path,
        Date timeGenerated) {
        // Ignore mask tables that aren't given.
        if (maskTable == null) {
            return null;
        }

        List<Mask> masks = targetCrud.retrieveMasks(maskTable);

        File file = new File(path, maskTable.generateFileName(timeGenerated));

        MaskWriter maskWriter = maskWriterFactory.create(file);
        maskWriter.write(new ImportedMaskTable(maskTable, masks));

        return file;
    }

    private File exportTargetTable(TargetTable targetTable, String path,
        Date timeGenerated) {
        // Ignore target tables that aren't given.
        if (targetTable == null) {
            return null;
        }

        List<TargetDefinition> targetDefinitions = targetCrud.retrieveTargetDefinitions(targetTable);

        File file = new File(path, targetTable.generateFileName(timeGenerated));

        TargetWriter targetWriter = targetWriterFactory.create(file);
        targetWriter.write(new ImportedTargetTable(targetTable,
            targetDefinitions));

        return file;
    }

}
