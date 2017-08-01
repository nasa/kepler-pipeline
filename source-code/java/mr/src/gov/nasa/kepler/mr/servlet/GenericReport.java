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

import gov.nasa.kepler.fs.api.StreamedBlobResult;
import gov.nasa.kepler.hibernate.mr.MrReport;
import gov.nasa.kepler.mc.mr.GenericReportOperations;
import gov.nasa.kepler.mr.ParameterUtil;

import java.io.IOException;
import java.io.InputStream;
import java.util.Map;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * Servlet generic report access.
 * 
 * @author Bill Wohler
 */
public class GenericReport implements Report {

    private static final Log log = LogFactory.getLog(GenericReport.class);

    public static final String REPORT_NAME_GENERIC_REPORT = "generic-report";
    public static final String REPORT_TITLE_GENERIC_REPORT = "Generic Report";

    private MrReport report;
    private InputStream inputStream;
    private long size;

    /**
     * Creates a {@link GenericReport} object and initializes it from the given
     * parameters. This constructor performs a database and filestore read so it
     * is not cheap.
     * 
     * @param parameterMap a non-{@code null} map of parameters which must
     * include a {@code genericReportIdentifier}
     * @throws NullPointerException if {@code parameterMap} is {@code null}
     * @throws IllegalArgumentException if the {@code parameterMap} doesn't
     * include {@code genericReportIdentifier}, this parameter does not contain
     * a valid string, or the specified report was not found in the database
     */
    public GenericReport(Map<String, Object> parameterMap) {
        if (parameterMap == null) {
            throw new NullPointerException("parameterMap can't be null");
        }

        // Grab the genericReportIdentifier parameter.
        ParameterUtil parameterUtil = new ParameterUtil(parameterMap);
        parameterUtil.expectGenericReportIdentifierParameter();
        if (parameterUtil.getPipelineTaskId() == ParameterUtil.INVALID_PIPELINE_TASK_ID) {
            throw new IllegalArgumentException(parameterUtil.getErrorText());
        }

        // Look up the report.
        GenericReportOperations genericReportOperations = new GenericReportOperations();
        report = genericReportOperations.retrieveReport(
            parameterUtil.getPipelineTaskId(), parameterUtil.getIdentifier());
        if (report == null) {
            throw new IllegalArgumentException(
                "No reports found for pipelineTaskId="
                    + parameterUtil.getPipelineTaskId() + " and identifier="
                    + parameterUtil.getIdentifier());
        }
        StreamedBlobResult blobResult = genericReportOperations.retrieveStreamedBlobResult(report);
        inputStream = blobResult.stream();
        size = blobResult.size();
    }

    /**
     * Returns the filename of this report.
     */
    @Override
    public String getFilename() {
        return report.filenameWithDate();
    }

    /**
     * Returns the base filename of this report.
     */
    @Override
    public String getBaseFilename() {
        return report.getFilename();
    }

    /**
     * Returns the content type of the report.
     */
    @Override
    public String getContentType() {
        return report.getMimeType();
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
