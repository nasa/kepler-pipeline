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

package gov.nasa.kepler.dr.target;

import gov.nasa.kepler.common.DateUtils;
import gov.nasa.kepler.common.MatlabDateFormatter;
import gov.nasa.kepler.dr.targetlistset.TargetListSetDocument;
import gov.nasa.kepler.dr.targetlistset.TargetListSetTypeXB;
import gov.nasa.kepler.dr.targetlistset.TargetListSetXB;
import gov.nasa.kepler.dr.targetlistset.TargetListXB;
import gov.nasa.kepler.hibernate.cm.TargetList;
import gov.nasa.kepler.hibernate.cm.TargetListSet;
import gov.nasa.kepler.hibernate.tad.TargetTable.TargetType;
import gov.nasa.spiffy.common.pi.PipelineException;

import java.io.File;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.apache.xmlbeans.XmlError;
import org.apache.xmlbeans.XmlObject;
import org.apache.xmlbeans.XmlOptions;

/**
 * This class exports a specified {@link TargetListSet} to a specified
 * directory.
 * 
 * @author Miles Cote
 */
public class TargetListSetExporter {

    private static final int MAX_ERRORS = 25;
    private static Log log = LogFactory.getLog(TargetListSetExporter.class);

    public File export(TargetListSet targetListSet, String path)
        throws IOException {
        return export(targetListSet, path, true);
    }

    public File export(TargetListSet targetListSet, String path,
        boolean validate) throws IOException {
        return export(targetListSet, path, new Date(), validate);
    }

    public File export(TargetListSet targetListSet, String path,
        Date timeGenerated, boolean validate) throws IOException {

        TargetListSetDocument doc = TargetListSetDocument.Factory.newInstance();
        TargetListSetXB tlsXB = doc.addNewTargetListSet();
        tlsXB.setName(targetListSet.getName());
        tlsXB.setType(getTargetListSetTypeXB(targetListSet.getType()));
        tlsXB.setStart(MatlabDateFormatter.dateFormatter()
            .format(targetListSet.getStart()));
        tlsXB.setEnd(MatlabDateFormatter.dateFormatter()
            .format(targetListSet.getEnd()));

        for (TargetList targetList : targetListSet.getTargetLists()) {
            TargetListXB targetListXB = tlsXB.addNewTargetList();
            targetListXB.setName(targetList.getName());
        }

        for (TargetList targetList : targetListSet.getExcludedTargetLists()) {
            TargetListXB targetListXB = tlsXB.addNewExcludedTargetList();
            targetListXB.setName(targetList.getName());
        }

        String fileName = String.format("kplr"
            + DateUtils.formatLikeDmc(timeGenerated) + "--"
            + targetListSet.getName() + "_target-list-set.xml");

        return writeDocument(doc, path, fileName, validate);
    }

    private File writeDocument(XmlObject doc, String path, String filename,
        boolean validate) throws IOException {

        XmlOptions xmlOptions = new XmlOptions().setSavePrettyPrint()
            .setSavePrettyPrintIndent(2);
        @SuppressWarnings("serial")
        List<XmlError> errors = new ArrayList<XmlError>() {
            @Override
            public boolean add(XmlError e) {
                if (size() >= MAX_ERRORS) {
                    throw new IllegalStateException("Too many errors");
                }
                return super.add(e);
            }
        };
        xmlOptions.setErrorListener(errors);

        if (validate) {
            log.info("Validating XML document");
            boolean valid = false;
            try {
                valid = doc.validate(xmlOptions);
            } finally {
                if (!valid) {
                    throw new PipelineException("XML validation error:  "
                        + errors);
                }
            }
        }

        File file = new File(path, filename);
        log.info("Writing " + file.getAbsolutePath());
        doc.save(file, xmlOptions);

        return file;
    }

    private TargetListSetTypeXB.Enum getTargetListSetTypeXB(
        TargetType targetType) {
        switch (targetType) {
            case LONG_CADENCE:
                return TargetListSetTypeXB.LONG_CADENCE;
            case SHORT_CADENCE:
                return TargetListSetTypeXB.SHORT_CADENCE;
            case REFERENCE_PIXEL:
                return TargetListSetTypeXB.REFERENCE_PIXEL;

            default:
                throw new IllegalArgumentException("Invalid type: "
                    + targetType);
        }
    }

}
