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
import gov.nasa.kepler.apertures.ApertureDefinitionsDocument;
import gov.nasa.kepler.apertures.ApertureDefinitionsXB;
import gov.nasa.kepler.apertures.ApertureOffsetXB;
import gov.nasa.kepler.apertures.ApertureTypesXB;
import gov.nasa.kepler.apertures.ApertureXB;
import gov.nasa.kepler.common.TargetManagementConstants;
import gov.nasa.kepler.hibernate.tad.Mask;
import gov.nasa.kepler.hibernate.tad.MaskTable;
import gov.nasa.kepler.hibernate.tad.MaskTable.MaskType;
import gov.nasa.kepler.hibernate.tad.Offset;
import gov.nasa.spiffy.common.pi.PipelineException;

import java.io.IOException;
import java.io.InputStream;
import java.util.List;

import org.apache.xmlbeans.XmlError;
import org.apache.xmlbeans.XmlOptions;

/**
 * Reads {@link Mask}s.
 * 
 * @author Miles Cote
 */
public class MaskReader {

    private final InputStream inputStream;

    public MaskReader(InputStream inputStream) {
        this.inputStream = inputStream;
    }

    public ImportedMaskTable read() {
        ApertureDefinitionsDocument doc;
        try {
            doc = ApertureDefinitionsDocument.Factory.parse(inputStream);
        } catch (Exception e) {
            throw new IllegalArgumentException("Unable to parse.", e);
        }

        XmlOptions xmlOptions = new XmlOptions();
        List<XmlError> errors = newArrayList();
        xmlOptions.setErrorListener(errors);
        if (!doc.validate(xmlOptions)) {
            throw new PipelineException("XML validation error.  " + errors);
        }

        ApertureDefinitionsXB apertureDefinitionsXB = doc.getApertureDefinitions();

        MaskTable maskTable = new MaskTable(
            getMaskType(apertureDefinitionsXB.getType()));
        maskTable.setExternalId(apertureDefinitionsXB.getTableId());
        maskTable.setPlannedStartTime(apertureDefinitionsXB.getPlannedStartTime()
            .getTime());
        maskTable.setPlannedEndTime(apertureDefinitionsXB.getPlannedEndTime()
            .getTime());

        int expectedIndexInTable = 0;
        List<Mask> masks = newArrayList();
        for (ApertureXB apertureXB : apertureDefinitionsXB.getApertureArray()) {
            List<Offset> offsets = newArrayList();
            for (ApertureOffsetXB apertureOffsetXB : apertureXB.getOffsetArray()) {
                offsets.add(new Offset(apertureOffsetXB.getRow(),
                    apertureOffsetXB.getColumn()));
            }

            if (expectedIndexInTable != apertureXB.getIndex()) {
                throw new PipelineException(
                    "MaskIndices must start at zero and increment by one.\n  expectedIndexInTable: "
                        + expectedIndexInTable
                        + "\n  importedIndexInTable: "
                        + apertureXB.getIndex());
            }

            Mask mask = new Mask(maskTable, offsets);
            mask.setIndexInTable(apertureXB.getIndex());

            masks.add(mask);

            expectedIndexInTable++;
        }

        checkPixelCount(masks);

        try {
            inputStream.close();
        } catch (IOException e) {
            throw new IllegalArgumentException("Unable to close.", e);
        }

        ImportedMaskTable importedMaskTable = new ImportedMaskTable(maskTable,
            masks);

        return importedMaskTable;
    }

    private void checkPixelCount(List<Mask> masks) {
        int aperturePixelCount = 0;
        for (Mask mask : masks) {
            aperturePixelCount += mask.getOffsets()
                .size();
        }
        if (aperturePixelCount > TargetManagementConstants.MAX_TOTAL_APERTURE_OFFSETS) {
            throw new PipelineException("Mask tables must not have more than "
                + TargetManagementConstants.MAX_TOTAL_APERTURE_OFFSETS
                + " totalApertureOffsets.\n  totalApertureOffsetsCount: "
                + aperturePixelCount);
        }
    }

    private MaskType getMaskType(ApertureTypesXB.Enum apertureType) {
        if (apertureType == ApertureTypesXB.TARGET) {
            return MaskType.TARGET;
        } else if (apertureType == ApertureTypesXB.BACKGROUND) {
            return MaskType.BACKGROUND;
        } else {
            throw new IllegalArgumentException("Unexpected type: "
                + apertureType);
        }
    }

}
