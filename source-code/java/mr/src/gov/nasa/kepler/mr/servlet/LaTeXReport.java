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

package gov.nasa.kepler.mr.servlet;

import gov.nasa.spiffy.common.io.FileUtil;

import java.io.BufferedInputStream;
import java.io.BufferedReader;
import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * Servlet generic LaTeX report access.
 * 
 * @author Forrest Girouard
 */
public class LaTeXReport implements Report {

    protected static final Log log = LogFactory.getLog(LaTeXReport.class);

    private static final String CONTENT_TYPE_PDF = "application/pdf";
    private static final String DOT_PDF = ".pdf";
    private static final String MAKE_REPORT_COMMAND = "/bin/sh mkreport";

    private Report report;
    private InputStream inputStream;
    private long size;

    /**
     * Creates a {@link LaTeXReport} object and initializes it from the given
     * parameters. This constructor performs database and filestore reads as
     * well as uncompressing and extracting an archive and running LaTeX so it
     * is not cheap.
     * 
     * @param tmpDir directory in which to extract archive
     * @param report underlying generic report (compressed archive)
     */
    public LaTeXReport(File tmpDir, Report report) throws InterruptedException,
        IOException {

        this.report = report;

        FileUtil.mkdirs(tmpDir);

        File execDir = new File(tmpDir, report.getBaseFilename());
        synchronized (LaTeXReport.class) {
            if (!execDir.exists()) {
                log.info(String.format("Extracting archive %s",
                    report.getBaseFilename()));
                FileUtil.extractCompressedArchive(tmpDir,
                    report.getInputStream());
                log.info(String.format("Running LaTeX on %s",
                    report.getBaseFilename()));
                makeReport(execDir);
            }
        }

        File file = new File(execDir, report.getBaseFilename() + DOT_PDF);
        inputStream = new BufferedInputStream(new FileInputStream(file));
        size = file.length();
    }

    private void makeReport(File execDir) throws IOException,
        InterruptedException {

        Process process = Runtime.getRuntime()
            .exec(MAKE_REPORT_COMMAND, null, execDir);

        BufferedReader input = new BufferedReader(new InputStreamReader(
            process.getInputStream()));
        String line = null;
        int exitVal = 0;
        try {
            while ((line = input.readLine()) != null) {
                log.debug(line);
            }

            exitVal = process.waitFor();
            log.debug("Exited with error code " + exitVal);
        } finally {
            try {
                input.close();
            } catch (IOException e) {
                // Just log exception and continue. Since mkreport has
                // completed, nothing is to be gained by throwing an exception
                // here. The more important exception to be thrown is based upon
                // the exitVal.
                log.error("Failed to close input stream", e);
            }
        }
        if (exitVal != 0) {
            throw new IOException("mkreport exited with error code " + exitVal);
        }
    }

    /**
     * Returns the base filename (without ID and date) of this report.
     */
    @Override
    public String getBaseFilename() {
        return report.getBaseFilename();
    }

    /**
     * Returns the filename of this report.
     */
    @Override
    public String getFilename() {
        return report.getFilename();
    }

    /**
     * Returns the content type of the report.
     */
    @Override
    public String getContentType() {
        return CONTENT_TYPE_PDF;
    }

    /**
     * Returns an input stream for the actual report.
     */
    @Override
    public InputStream getInputStream() {
        return inputStream;
    }

    /**
     * Returns the length of the report in bytes.
     */
    @Override
    public long getSize() {
        return size;
    }

    /**
     * Frees the resources used by this object.
     */
    @Override
    public void dispose() {
        try {
            inputStream.close();
        } catch (IOException e) {
            // Just log exception and continue. What else can the caller
            // possibly expect to with it?
            log.error("Failed to close input stream", e);
        }
    }
}
