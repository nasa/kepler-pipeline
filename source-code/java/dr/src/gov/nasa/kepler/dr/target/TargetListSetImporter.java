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

import gov.nasa.kepler.common.MatlabDateFormatter;
import gov.nasa.kepler.dr.targetlistset.TargetListSetDocument;
import gov.nasa.kepler.dr.targetlistset.TargetListSetTypeXB;
import gov.nasa.kepler.dr.targetlistset.TargetListSetXB;
import gov.nasa.kepler.dr.targetlistset.TargetListXB;
import gov.nasa.kepler.fc.rolltime.RollTimeOperations;
import gov.nasa.kepler.hibernate.cm.TargetList;
import gov.nasa.kepler.hibernate.cm.TargetListSet;
import gov.nasa.kepler.hibernate.cm.TargetSelectionCrud;
import gov.nasa.kepler.hibernate.gar.ExportTable.State;
import gov.nasa.kepler.hibernate.tad.TargetTable.TargetType;
import gov.nasa.kepler.mc.TargetListSetValidator;
import gov.nasa.spiffy.common.pi.PipelineException;

import java.io.File;
import java.util.ArrayList;
import java.util.List;

import org.apache.xmlbeans.XmlError;
import org.apache.xmlbeans.XmlOptions;

/**
 * This class imports a specified target list set as a {@link TargetListSet}.
 * 
 * @author Miles Cote
 */
public class TargetListSetImporter {

    private TargetSelectionCrud targetSelectionCrud;
    private TargetListSetValidator targetListSetValidator;

    public TargetListSetImporter() {
        targetSelectionCrud = new TargetSelectionCrud();
        targetListSetValidator = new TargetListSetValidator(
            new RollTimeOperations());
    }

    public TargetListSet importFile(File xmlFile) {
        return importFile(xmlFile, true);
    }

    @SuppressWarnings("deprecation")
    public TargetListSet importFile(File xmlFile, boolean validate) {
        try {
            TargetListSetDocument doc = TargetListSetDocument.Factory.parse(xmlFile);

            if (validate) {
                XmlOptions xmlOptions = new XmlOptions();
                List<XmlError> errors = new ArrayList<XmlError>();
                xmlOptions.setErrorListener(errors);
                if (!doc.validate(xmlOptions)) {
                    throw new PipelineException("XML validation error.  "
                        + errors);
                }
            }

            TargetListSetXB targetListSetXB = doc.getTargetListSet();

            TargetListSet targetListSet = new TargetListSet(
                targetListSetXB.getName());
            targetListSet.setType(getTargetType(targetListSetXB.getType()));
            targetListSet.setStart(MatlabDateFormatter.dateFormatter()
                .parse(targetListSetXB.getStart()));
            targetListSet.setEnd(MatlabDateFormatter.dateFormatter()
                .parse(targetListSetXB.getEnd()));

            for (TargetListXB targetListXB : targetListSetXB.getTargetListArray()) {
                TargetList targetList = targetSelectionCrud.retrieveTargetList(targetListXB.getName());

                if (targetList == null) {
                    throw new PipelineException(
                        "Target lists referred to in the target list set must exist in the database.\n  targetListName: "
                            + targetListXB.getName());
                }

                targetListSet.getTargetLists()
                    .add(targetList);
            }

            for (TargetListXB targetListXB : targetListSetXB.getExcludedTargetListArray()) {
                TargetList targetList = targetSelectionCrud.retrieveTargetList(targetListXB.getName());

                if (targetList == null) {
                    throw new PipelineException(
                        "Target lists referred to in the target list set must exist in the database.\n  targetListName: "
                            + targetListXB.getName());
                }

                targetListSet.getExcludedTargetLists()
                    .add(targetList);
            }

            targetListSet.setState(State.LOCKED);

            if (validate) {
                List<TargetListSet> tlsList = new ArrayList<TargetListSet>();
                tlsList.add(targetListSet);
                targetListSetValidator.validate(tlsList);
            }

            return targetListSet;
        } catch (Throwable e) {
            throw new PipelineException("Unable to import file.  file = "
                + xmlFile.getAbsolutePath(), e);
        }
    }

    private TargetType getTargetType(TargetListSetTypeXB.Enum tlsType) {
        if (tlsType == TargetListSetTypeXB.LONG_CADENCE) {
            return TargetType.LONG_CADENCE;
        } else if (tlsType == TargetListSetTypeXB.SHORT_CADENCE) {
            return TargetType.SHORT_CADENCE;
        } else if (tlsType == TargetListSetTypeXB.REFERENCE_PIXEL) {
            return TargetType.REFERENCE_PIXEL;
        } else {
            throw new IllegalArgumentException("Invalid type: " + tlsType);
        }
    }

    void setTargetSelectionCrud(TargetSelectionCrud targetSelectionCrud) {
        this.targetSelectionCrud = targetSelectionCrud;
    }

    void setTargetListSetValidator(TargetListSetValidator targetListSetValidator) {
        this.targetListSetValidator = targetListSetValidator;
    }

}
