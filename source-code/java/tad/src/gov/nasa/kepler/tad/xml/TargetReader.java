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
import gov.nasa.kepler.apertures.ChannelTargetsXB;
import gov.nasa.kepler.apertures.TargetDefinitionsDocument;
import gov.nasa.kepler.apertures.TargetDefinitionsXB;
import gov.nasa.kepler.apertures.TargetTypesXB;
import gov.nasa.kepler.apertures.TargetXB;
import gov.nasa.kepler.dr.dispatch.DispatchException;
import gov.nasa.kepler.hibernate.tad.Mask;
import gov.nasa.kepler.hibernate.tad.MaskTable;
import gov.nasa.kepler.hibernate.tad.MaskTable.MaskType;
import gov.nasa.kepler.hibernate.tad.TargetDefinition;
import gov.nasa.kepler.hibernate.tad.TargetTable;
import gov.nasa.kepler.hibernate.tad.TargetTable.TargetType;

import java.io.InputStream;
import java.util.List;

import org.apache.xmlbeans.XmlError;
import org.apache.xmlbeans.XmlOptions;

/**
 * Reads {@link TargetDefinition}s.
 * 
 * @author Miles Cote
 */
public class TargetReader {

    static final MaskType DEFAULT_MASK_TYPE = MaskType.TARGET;

    private final InputStream inputStream;

    public TargetReader(InputStream inputStream) {
        this.inputStream = inputStream;
    }

    public ImportedTargetTable read() {
        TargetDefinitionsDocument doc;
        try {
            doc = TargetDefinitionsDocument.Factory.parse(inputStream);
        } catch (Exception e) {
            throw new IllegalArgumentException("Unable to parse.", e);
        }

        XmlOptions xmlOptions = new XmlOptions();
        List<XmlError> errors = newArrayList();
        xmlOptions.setErrorListener(errors);
        if (!doc.validate(xmlOptions)) {
            throw new DispatchException("XML validation error.  " + errors);
        }

        TargetDefinitionsXB targetDefinitionsXB = doc.getTargetDefinitions();

        MaskTable maskTable = new MaskTable(DEFAULT_MASK_TYPE);
        maskTable.setExternalId(targetDefinitionsXB.getApertureTableId());

        TargetTable targetTable = new TargetTable(
            getTargetType(targetDefinitionsXB.getType()));
        targetTable.setExternalId(targetDefinitionsXB.getTableId());
        targetTable.setPlannedStartTime(targetDefinitionsXB.getPlannedStartTime()
            .getTime());
        targetTable.setPlannedEndTime(targetDefinitionsXB.getPlannedEndTime()
            .getTime());
        targetTable.setMaskTable(maskTable);

        List<TargetDefinition> targetDefs = newArrayList();
        for (ChannelTargetsXB channelTargetsXB : targetDefinitionsXB.getChannelArray()) {
            for (TargetXB targetXB : channelTargetsXB.getTargetArray()) {
                Mask mask = new Mask();
                mask.setIndexInTable(targetXB.getApertureIndex());

                TargetDefinition targetDefinition = new TargetDefinition();
                targetDefinition.setKeplerId(targetXB.getKeplerId());
                targetDefinition.setCcdModule(channelTargetsXB.getModule());
                targetDefinition.setCcdOutput(channelTargetsXB.getOutput());
                targetDefinition.setMask(mask);
                targetDefinition.setIndexInModuleOutput(targetXB.getIndex());
                targetDefinition.setReferenceRow(targetXB.getRow());
                targetDefinition.setReferenceColumn(targetXB.getColumn());
                targetDefinition.setTargetTable(targetTable);

                targetDefs.add(targetDefinition);
            }
        }

        return new ImportedTargetTable(targetTable, targetDefs);
    }

    private TargetType getTargetType(TargetTypesXB.Enum targetType) {
        if (targetType == TargetTypesXB.BACKGROUND) {
            return TargetType.BACKGROUND;
        } else if (targetType == TargetTypesXB.LONG_CADENCE) {
            return TargetType.LONG_CADENCE;
        } else if (targetType == TargetTypesXB.SHORT_CADENCE) {
            return TargetType.SHORT_CADENCE;
        } else if (targetType == TargetTypesXB.REFERENCE_PIXEL) {
            return TargetType.REFERENCE_PIXEL;
        } else {
            throw new IllegalArgumentException("Unexpected type: " + targetType);
        }
    }

}
