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

package gov.nasa.kepler.mc.mr;

import static gov.nasa.kepler.common.MimeType.HTML;
import static gov.nasa.kepler.common.MimeType.OCTET_STREAM;
import static gov.nasa.kepler.common.MimeType.PDF;
import static gov.nasa.kepler.common.MimeType.PLAIN_TEXT;
import static gov.nasa.kepler.common.MimeType.TAR;
import gov.nasa.kepler.fs.api.FileStoreClient;
import gov.nasa.kepler.fs.api.FsId;
import gov.nasa.kepler.fs.api.StreamedBlobResult;
import gov.nasa.kepler.fs.client.FileStoreClientFactory;
import gov.nasa.kepler.hibernate.mr.MrReport;
import gov.nasa.kepler.hibernate.mr.MrReportCrud;
import gov.nasa.kepler.hibernate.pi.PipelineTask;
import gov.nasa.kepler.mc.fs.MrFsIdFactory;
import gov.nasa.spiffy.common.io.FileUtil;
import gov.nasa.spiffy.common.pi.PipelineException;

import java.io.File;
import java.util.List;

import org.hibernate.HibernateException;

/**
 * Operations on {@link MrReport} objects. To create a report, use
 * {@link #createReport(PipelineTask, File)} or
 * {@link #createReport(PipelineTask, File, String)}.
 * <p>
 * To retrieve a report, use one of the {@code retrieveReport} methods. Using
 * the (using the {@link MrReport} metadata returned by these methods, call
 * {@link #retrieveStreamedBlobResult(MrReport)} to retrieve the actual report.
 * 
 * @author Bill Wohler
 */
public class GenericReportOperations {

    private MrReportCrud mrReportCrud = new MrReportCrud();
    private FileStoreClient fsClient;

    /**
     * Creates an {@link MrReport} object and stores it in the database and
     * stores the file associated with it in the filestore. This method must be
     * called within both a database and filestore transaction context. After
     * this method is called (and the transaction committed), it is safe to
     * delete the file associated with {@code file}.
     * <p>
     * Since the file object must contain an absolute path name, a caller from a
     * pipeline module might create the file object as follows:
     * 
     * <pre>
     * File file = new File(getExternalBridge().getWorkingDir(),
     *     moduleOutputs.getReportFilename());
     * </pre>
     * 
     * <p>
     * If you get an {@code IllegalArgumentException} while using this method
     * because the file's MIME type was not recognized, consider using
     * {@link #createReport(PipelineTask, File, String)} and specify the MIME
     * type yourself. See {@link #mimeType(File)} for supported types.
     * 
     * @param pipelineTask the pipeline task associated with this report
     * @param file the file object which contains the absolute path to the
     * report
     * @return the report
     * @throws NullPointerException if {@code pipelineTask} or {@code file} is
     * {@code null}
     * @throws PipelineException if the given file was a directory and there
     * were problems archiving it
     */
    public MrReport createReport(PipelineTask pipelineTask, File file) {
        return createReport(pipelineTask, null, file, mimeType(file));
    }

    /**
     * Creates an {@link MrReport} object and stores it in the database and
     * stores the file associated with it in the filestore. This method must be
     * called within both a database and filestore transaction context. After
     * this method is called (and the transaction committed), it is safe to
     * delete the file associated with {@code file}.
     * <p>
     * Since the file object must contain an absolute path name, a caller from a
     * pipeline module might create the file object as follows:
     * 
     * <pre>
     * File file = new File(getExternalBridge().getWorkingDir(),
     *     moduleOutputs.getReportFilename());
     * </pre>
     * 
     * @param pipelineTask the pipeline task associated with this report
     * @param file the file object which contains the absolute path to the
     * report
     * @param mimeType the MIME type of the file
     * @return the report
     * @throws NullPointerException if any of {@code pipelineTask}, {@code file}
     * or {@code mimeType} are {@code null}
     * @throws PipelineException if the given file was a directory and there
     * were problems archiving it
     */
    public MrReport createReport(PipelineTask pipelineTask, File file,
        String mimeType) {

        return createReport(pipelineTask, null, file, mimeType);
    }

    /**
     * Creates an {@link MrReport} object and stores it in the database and
     * stores the file associated with it in the filestore. This method must be
     * called within both a database and filestore transaction context. After
     * this method is called (and the transaction committed), it is safe to
     * delete the file associated with {@code file}.
     * <p>
     * Since the file object must contain an absolute path name, a caller from a
     * pipeline module might create the file object as follows:
     * 
     * <pre>
     * File file = new File(getExternalBridge().getWorkingDir(),
     *     moduleOutputs.getReportFilename());
     * </pre>
     * 
     * <p>
     * If you get an {@code IllegalArgumentException} while using this method
     * because the file's MIME type was not recognized, consider using
     * {@link #createReport(PipelineTask, File, String)} and specify the MIME
     * type yourself. See {@link #mimeType(File)} for supported types.
     * 
     * @param pipelineTask the pipeline task associated with this report
     * @param identifier the report's distinguishing identifier; may be
     * {@code null} or empty if the task has a single report
     * @param file the file object which contains the absolute path to the
     * report
     * @return the report
     * @throws NullPointerException if {@code pipelineTask} or {@code file} is
     * {@code null}
     * @throws PipelineException if the given file was a directory and there
     * were problems archiving it
     */
    public MrReport createReport(PipelineTask pipelineTask, String identifier,
        File file) {
        return createReport(pipelineTask, identifier, file, mimeType(file));
    }

    /**
     * Creates an {@link MrReport} object and stores it in the database and
     * stores the file associated with it in the filestore. This method must be
     * called within both a database and filestore transaction context. After
     * this method is called (and the transaction committed), it is safe to
     * delete the file associated with {@code file}.
     * <p>
     * Since the file object must contain an absolute path name, a caller from a
     * pipeline module might create the file object as follows:
     * 
     * <pre>
     * File file = new File(getExternalBridge().getWorkingDir(),
     *     moduleOutputs.getReportFilename());
     * </pre>
     * 
     * @param pipelineTask the pipeline task associated with this report
     * @param identifier the report's distinguishing identifier; may be
     * {@code null} or empty if the task has a single report
     * @param file the file object which contains the absolute path to the
     * report
     * @param mimeType the MIME type of the file
     * @return the report
     * @throws NullPointerException if any of {@code pipelineTask}, {@code file}
     * or {@code mimeType} are {@code null}
     * @throws PipelineException if the given file was a directory and there
     * were problems archiving it
     */
    public MrReport createReport(PipelineTask pipelineTask, String identifier,
        File file, String mimeType) {

        File actualFile = file;
        if (file.isDirectory()) {
            try {
                actualFile = FileUtil.createCompressedArchive(file);
            } catch (Exception e) {
                throw new PipelineException(String.format(
                    "Could not archive %s: %s", file.getAbsolutePath(),
                    e.getMessage()), e);
            }
        }

        // Generate FsId and store file.
        FsId fsId = identifier != null ? MrFsIdFactory.getReportId(
            pipelineTask, identifier) : MrFsIdFactory.getReportId(pipelineTask);
        getFsClient().writeBlob(fsId, pipelineTask.getId(), actualFile);

        // Create MrReport object (using string version of FsId) and store it.
        MrReport report = new MrReport(pipelineTask, identifier,
            file.getName(), mimeType, fsId.toString());
        mrReportCrud.create(report);

        return report;
    }

    /**
     * Returns the MIME type of the given file. It is currently very simplistic
     * and only returns the following:
     * 
     * <table>
     * <tr>
     * <td><b>File Extension</b></td>
     * <td><b>MIME Type</b></td>
     * </tr>
     * <tr>
     * <td>.pdf</td>
     * <td>application/pdf</td>
     * </tr>
     * <tr>
     * <td>.html</td>
     * <td>application/html</td>
     * </tr>
     * <tr>
     * <td>&lt;directory&gt;</td>
     * <td>application/x-tar</td>
     * </tr>
     * <tr>
     * <td>.*</td>
     * <td>application/octet-stream</td>
     * </tr>
     * </table>
     * <p>
     * If more MIME types need to be supported, consider using MimeTypes from
     * the Apache Tika (incubator) project.
     * 
     * @param file the input file
     * @return the MIME type
     * @throws NullPointerException if file is {@code null}
     */
    public String mimeType(File file) {
        if (file == null) {
            throw new NullPointerException("file can't be null");
        }

        // This is *really* simplistic as it doesn't even bother with a hash
        // table.
        if (file.isDirectory()) {
            return TAR.getContentType();
        } else if (file.getName()
            .endsWith(PDF.getFileExtension())) {
            return PDF.getContentType();
        } else if (file.getName()
            .endsWith(HTML.getFileExtension())) {
            return HTML.getContentType();
        } else if (file.getName()
            .endsWith(PLAIN_TEXT.getFileExtension())) {
            return PLAIN_TEXT.getContentType();
        } else {
            return OCTET_STREAM.getContentType();
        }
    }

    /**
     * Returns the report for the given task.
     * 
     * @param pipelineTaskId the selected task
     * @return the {@link MrReport} object, or {@code null} if the associated
     * report could not be found
     */
    public MrReport retrieveReport(long pipelineTaskId) {
        return mrReportCrud.retrieveReport(pipelineTaskId);
    }

    /**
     * Returns the specified report. If a particular task has multiple reports,
     * then the identifier parameter is used to distinguish between them.
     * 
     * @param pipelineTaskId the selected task
     * @param identifier the report's distinguishing identifier; may be
     * {@code null} or empty if the task has a single report
     * @return the {@link MrReport} object, or {@code null} if the associated
     * report could not be found
     */
    public MrReport retrieveReport(long pipelineTaskId, String identifier) {
        return mrReportCrud.retrieveReport(pipelineTaskId, identifier);
    }

    /**
     * Retrieves all reports for the given module that have the given pipeline
     * instance ID.
     * 
     * @param moduleName the name of the module
     * @param pipelineInstanceId the pipeline instance ID
     * @return a non-{@code null} list of reports
     * @throws HibernateException if there were problems accessing the database
     */
    public List<MrReport> retrieveReports(String moduleName,
        long pipelineInstanceId) {
        return mrReportCrud.retrieveReports(moduleName, pipelineInstanceId);
    }

    /**
     * Returns the {@link StreamedBlobResult} that contains an input stream and
     * size of the given report's file. It is the caller's responsibility to
     * close the input stream.
     * 
     * @param report the report returned by {@link #retrieveReport(long)}
     * @return a {@link StreamedBlobResult} to the actual report
     * @throws NullPointerException if {@code report} is {@code null}
     */
    public StreamedBlobResult retrieveStreamedBlobResult(MrReport report) {
        return getFsClient().readBlobAsStream(new FsId(report.getFsId()));
    }

    /**
     * Retrieves the given report's file and saves it in {@code outputFile}.
     * 
     * @param report the report returned by {@link #retrieveReport(long)}
     * @param outputFile the destination file
     * @throws NullPointerException if either {@code report} or
     * {@code outputFile} are {@code null}
     */
    public void retrieveBlobResult(MrReport report, File outputFile) {
        getFsClient().readBlob(new FsId(report.getFsId()), outputFile);
    }

    private FileStoreClient getFsClient() {
        if (fsClient == null) {
            fsClient = FileStoreClientFactory.getInstance();
        }

        return fsClient;
    }

    /**
     * Sets the {@link FileStoreClient} object during testing.
     */
    void setFsClient(FileStoreClient fsClient) {
        this.fsClient = fsClient;
    }

    /**
     * Sets the {@link MrReportCrud} object during testing.
     */
    void setMrReportCrud(MrReportCrud mrReportCrud) {
        this.mrReportCrud = mrReportCrud;
    }
}
