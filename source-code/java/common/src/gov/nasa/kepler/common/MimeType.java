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

package gov.nasa.kepler.common;

import static com.google.common.collect.Maps.newLinkedHashMap;

import java.util.Map;

/**
 * Minimal MIME type enum. This type isn't expected to cover all possible MIME
 * types (see /etc/mime.types), just the ones used by the pipeline. It is
 * intended to avoid hard-coding MIME ContentType values and extension strings.
 * 
 * @author Forrest Girouard
 * @author Bill Wohler
 */
public enum MimeType {
    // Note all text must be lower case.
    PLAIN_TEXT("text/plain", ".txt"),
    HTML("text/html", ".html"),
    XML("xml", ".xml"),
    PDF("application/pdf", ".pdf"),
    PNG("image/png", ".png"),
    GIF("image/gif", ".gif", ".html_files/px"),
    TAR("application/x-tar", ".tar"),
    OCTET_STREAM("application/octet-stream", "");

    private String contentType;
    private String[] fileExtensions;

    private static Map<String, MimeType> typeByFileExtension = newLinkedHashMap();

    static {
        for (MimeType mimeType : values()) {
            for (String fileExtension : mimeType.fileExtensions) {
                typeByFileExtension.put(fileExtension, mimeType);
            }
        }
    }

    private MimeType(String contentType, String... fileExtensions) {
        this.contentType = contentType;
        this.fileExtensions = fileExtensions;
    }

    public String getContentType() {
        return contentType;
    }

    public String getFileExtension() {
        return fileExtensions[0];
    }

    public static MimeType valueOfContentType(String contentType) {
        if (contentType == null) {
            return OCTET_STREAM;
        }

        for (MimeType mimeType : values()) {
            if (mimeType.contentType.equals(contentType.toLowerCase())) {
                return mimeType;
            }
        }

        return OCTET_STREAM;
    }

    public static MimeType valueOfFileExtension(String fileExtension) {
        if (fileExtension == null) {
            return OCTET_STREAM;
        }

        MimeType mimeType = typeByFileExtension.get(fileExtension.toLowerCase());

        return mimeType == null ? OCTET_STREAM : mimeType;
    }
}
