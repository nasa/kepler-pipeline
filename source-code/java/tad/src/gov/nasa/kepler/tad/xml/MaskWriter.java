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
import gov.nasa.kepler.hibernate.tad.Mask;
import gov.nasa.kepler.hibernate.tad.MaskTable;
import gov.nasa.kepler.hibernate.tad.MaskTable.MaskType;
import gov.nasa.kepler.hibernate.tad.Offset;
import gov.nasa.spiffy.common.pi.PipelineException;

import java.io.IOException;
import java.io.OutputStream;
import java.util.Calendar;
import java.util.List;
import java.util.TimeZone;

import org.apache.xmlbeans.XmlError;
import org.apache.xmlbeans.XmlOptions;

/**
 * Writes {@link Mask}s.
 * 
 * @author Miles Cote
 * 
 */
public class MaskWriter {

    private final OutputStream outputStream;

    public MaskWriter(OutputStream outputStream) {
        this.outputStream = outputStream;
    }

    public void write(ImportedMaskTable importedMaskTable) {
        MaskTable maskTable = importedMaskTable.getMaskTable();

        ApertureDefinitionsDocument doc = ApertureDefinitionsDocument.Factory.newInstance();

        Calendar start = Calendar.getInstance(TimeZone.getTimeZone("UTC"));
        start.setTime(maskTable.getPlannedStartTime());

        Calendar end = Calendar.getInstance(TimeZone.getTimeZone("UTC"));
        end.setTime(maskTable.getPlannedEndTime());

        ApertureDefinitionsXB apertureDefinitionsXB = doc.addNewApertureDefinitions();
        apertureDefinitionsXB.setPlannedStartTime(start);
        apertureDefinitionsXB.setPlannedEndTime(end);
        apertureDefinitionsXB.setType(getApertureTypeXB(maskTable.getType()));
        apertureDefinitionsXB.setTableId(maskTable.getExternalId());

        List<Mask> masks = importedMaskTable.getMasks();
        for (Mask aperture : masks) {
            ApertureXB apertureXB = apertureDefinitionsXB.addNewAperture();
            apertureXB.setCount(aperture.getOffsets()
                .size());
            apertureXB.setIndex(aperture.getIndexInTable());

            if (aperture.getIndexInTable() < 0) {
                throw new IllegalStateException("Mask " + aperture
                    + "may not have a negative index");
            }

            int pixelIndex = 0;
            for (Offset offset : aperture.getOffsets()) {
                ApertureOffsetXB apertureOffsetXB = apertureXB.addNewOffset();
                apertureOffsetXB.setIndex(pixelIndex);
                apertureOffsetXB.setRow((short) offset.getRow());
                apertureOffsetXB.setColumn((short) offset.getColumn());
                pixelIndex++;
            }
        }

        XmlOptions xmlOptions = new XmlOptions().setSavePrettyPrint()
            .setSavePrettyPrintIndent(2);

        List<XmlError> errors = newArrayList();
        xmlOptions.setErrorListener(errors);
        if (!doc.validate(xmlOptions)) {
            throw new PipelineException("XML validation error.  " + errors);
        }

        try {
            doc.save(outputStream, xmlOptions);

            outputStream.close();
        } catch (IOException e) {
            throw new IllegalArgumentException("Unable to save.", e);
        }
    }

    private ApertureTypesXB.Enum getApertureTypeXB(MaskType apertureTableType) {
        if (apertureTableType == MaskType.BACKGROUND) {
            return ApertureTypesXB.BACKGROUND;
        } else if (apertureTableType == MaskType.TARGET) {
            return ApertureTypesXB.TARGET;
        } else {
            throw new IllegalArgumentException("Invalid aperture type: "
                + apertureTableType);
        }
    }

}
