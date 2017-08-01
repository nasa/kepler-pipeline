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

package gov.nasa.kepler.dr;

import gov.nasa.kepler.common.DateUtils;
import gov.nasa.kepler.common.file.Md5Sum;
import gov.nasa.kepler.hibernate.dbservice.ConfigurationServiceFactory;
import gov.nasa.kepler.nm.DataProductMessageDocument;
import gov.nasa.kepler.nm.DataProductMessageXB;
import gov.nasa.kepler.nm.FileListXB;
import gov.nasa.kepler.nm.FileXB;
import gov.nasa.spiffy.common.pi.PipelineException;

import java.io.File;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Date;
import java.util.List;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.apache.xmlbeans.XmlError;
import org.apache.xmlbeans.XmlOptions;

public class NmGenerator {

    private static final Log log = LogFactory.getLog(NmGenerator.class);

    /**
     * Utility to take the existing files in the dir and list them in a
     * notification message file, which will be placed in the dir.
     * 
     * @throws IOException
     * @throws PipelineException
     */
    public static void generateNotificationMessage(String directory,
        String nmType) throws IOException {
        if (!directory.endsWith("/")) {
            directory = directory.concat("/");
        }

        File dir = new File(directory);
        File[] files = dir.listFiles();
        Arrays.sort(files);

        DataProductMessageDocument doc = DataProductMessageDocument.Factory.newInstance();
        DataProductMessageXB dataProductMessage = doc.addNewDataProductMessage();

        String nmFilename = "kplr" + DateUtils.formatLikeDmc(new Date()) + "_"
            + nmType + ".xml";
        dataProductMessage.setMessageType(nmType.toUpperCase());
        dataProductMessage.setIdentifier(nmFilename);

        FileListXB fileList = dataProductMessage.addNewFileList();

        int i = 0;
        boolean skipChecksum = false;
        try {
            skipChecksum = ConfigurationServiceFactory.getInstance()
                .getBoolean("dr.notification.skipChecksum", Boolean.FALSE);
        } catch (Exception ignoreUseDefault) {
        }
        for (File file : files) {
            String name = file.getName();
            if (!name.contains("lock")) {
                FileXB dataProductFile = fileList.addNewFile();
                dataProductFile.setFilename(name);
                dataProductFile.setSize(file.length());
                if (!skipChecksum) {
                    dataProductFile.setChecksum(Md5Sum.computeMd5(file));
                } else {
                    dataProductFile.setChecksum("skipped");
                }
            }

            if (++i % 100 == 0) {
                log.info("Processed " + i + " files");
            }
        }

        XmlOptions xmlOptions = new XmlOptions().setSavePrettyPrint()
            .setSavePrettyPrintIndent(2);
        List<XmlError> errors = new ArrayList<XmlError>();
        xmlOptions.setErrorListener(errors);
        if (!doc.validate(xmlOptions)) {
            throw new PipelineException("XML validation error.  " + errors);
        }

        File file = new File(directory, nmFilename);
        doc.save(file, xmlOptions);

        log.info("Wrote " + file);
    }

    public static void main(String[] args) throws IOException,
        PipelineException {
        if (args.length != 2) {
            throw new PipelineException(NmGenerator.class.getName()
                + " must receive two input args: directoryName, nmType");
        }

        generateNotificationMessage(args[0], args[1]);
    }

}
