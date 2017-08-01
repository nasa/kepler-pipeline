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
import static com.google.common.collect.Maps.newHashMap;
import gov.nasa.kepler.apertures.ChannelTargetsXB;
import gov.nasa.kepler.apertures.TargetDefinitionsDocument;
import gov.nasa.kepler.apertures.TargetDefinitionsXB;
import gov.nasa.kepler.apertures.TargetTypesXB;
import gov.nasa.kepler.apertures.TargetXB;
import gov.nasa.kepler.hibernate.tad.ModOut;
import gov.nasa.kepler.hibernate.tad.ModOutsFactory;
import gov.nasa.kepler.hibernate.tad.TargetDefinition;
import gov.nasa.kepler.hibernate.tad.TargetTable;
import gov.nasa.kepler.hibernate.tad.TargetTable.TargetType;
import gov.nasa.spiffy.common.pi.PipelineException;

import java.io.IOException;
import java.io.OutputStream;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.List;
import java.util.Map;
import java.util.TimeZone;

import org.apache.xmlbeans.XmlError;
import org.apache.xmlbeans.XmlOptions;

/**
 * Writes {@link TargetDefinition}s
 * 
 * @author Miles Cote
 * 
 */
public class TargetWriter {

    private final OutputStream outputStream;
    private final ModOutsFactory modOutsFactory;

    public TargetWriter(OutputStream outputStream) {
        this(outputStream, new ModOutsFactory());
    }

    TargetWriter(OutputStream outputStream, ModOutsFactory modOutsFactory) {
        this.outputStream = outputStream;
        this.modOutsFactory = modOutsFactory;
    }

    public void write(ImportedTargetTable importedTargetTable) {
        TargetTable targetTable = importedTargetTable.getTargetTable();
        Map<ModOut, List<TargetDefinition>> modOutToTargetDefinitions = createModOutToTargetDefinitions(importedTargetTable);

        TargetDefinitionsDocument doc = TargetDefinitionsDocument.Factory.newInstance();

        Calendar plannedStartTime = Calendar.getInstance(TimeZone.getTimeZone("UTC"));
        plannedStartTime.setTime(targetTable.getPlannedStartTime());

        Calendar plannedEndTime = Calendar.getInstance(TimeZone.getTimeZone("UTC"));
        plannedEndTime.setTime(targetTable.getPlannedEndTime());

        TargetDefinitionsXB targetDefinitionsXB = doc.addNewTargetDefinitions();
        targetDefinitionsXB.setPlannedStartTime(plannedStartTime);
        targetDefinitionsXB.setPlannedEndTime(plannedEndTime);
        targetDefinitionsXB.setType(getTargetTypeXB(targetTable.getType()));
        targetDefinitionsXB.setTableId(targetTable.getExternalId());
        targetDefinitionsXB.setApertureTableId(targetTable.getMaskTable()
            .getExternalId());

        // Initialize total counts.
        int totalTargetCount = 0;
        int totalPixelCount = 0;

        for (ModOut modOut : modOutsFactory.create()) {
            ChannelTargetsXB channelTargetsXB = targetDefinitionsXB.addNewChannel();
            channelTargetsXB.setModule(modOut.getCcdModule());
            channelTargetsXB.setOutput(modOut.getCcdOutput());

            int pixelCount = 0;

            List<TargetDefinition> targetDefinitionsForModOut = modOutToTargetDefinitions.get(modOut);
            for (TargetDefinition targetDefinition : targetDefinitionsForModOut) {
                TargetXB targetXB = channelTargetsXB.addNewTarget();
                targetXB.setApertureIndex(targetDefinition.getMask()
                    .getIndexInTable());
                targetXB.setIndex(targetDefinition.getIndexInModuleOutput());
                targetXB.setRow(targetDefinition.getReferenceRow());
                targetXB.setColumn(targetDefinition.getReferenceColumn());
                targetXB.setKeplerId(targetDefinition.getKeplerId());

                if (targetDefinition.getIndexInModuleOutput() < 0) {
                    throw new IllegalStateException("Target "
                        + targetDefinition + "may not have a negative index");
                }

                pixelCount += targetDefinition.getMask()
                    .getOffsets()
                    .size();
            }

            // Set module/output counts.
            channelTargetsXB.setTargetCount(targetDefinitionsForModOut.size());
            channelTargetsXB.setPixelCount(pixelCount);

            // Increment total counts.
            totalTargetCount += targetDefinitionsForModOut.size();
            totalPixelCount += pixelCount;
        }

        // Set total counts.
        targetDefinitionsXB.setTotalTargetCount(totalTargetCount);
        targetDefinitionsXB.setTotalPixelCount(totalPixelCount);

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

    private Map<ModOut, List<TargetDefinition>> createModOutToTargetDefinitions(
        ImportedTargetTable importedTargetTable) {
        Map<ModOut, List<TargetDefinition>> modOutToTargetDefinitions = newHashMap();
        for (ModOut modOut : modOutsFactory.create()) {
            ArrayList<TargetDefinition> targetDefs = newArrayList();
            modOutToTargetDefinitions.put(modOut, targetDefs);
        }

        for (TargetDefinition targetDefinition : importedTargetTable.getTargetDefinitions()) {
            ModOut modOut = targetDefinition.getModOut();

            List<TargetDefinition> targetDefinitions = modOutToTargetDefinitions.get(modOut);

            targetDefinitions.add(targetDefinition);
        }

        return modOutToTargetDefinitions;
    }

    private TargetTypesXB.Enum getTargetTypeXB(TargetType targetTableType) {
        if (targetTableType == TargetType.BACKGROUND) {
            return TargetTypesXB.BACKGROUND;
        } else if (targetTableType == TargetType.LONG_CADENCE) {
            return TargetTypesXB.LONG_CADENCE;
        } else if (targetTableType == TargetType.REFERENCE_PIXEL) {
            return TargetTypesXB.REFERENCE_PIXEL;
        } else if (targetTableType == TargetType.SHORT_CADENCE) {
            return TargetTypesXB.SHORT_CADENCE;
        } else {
            throw new IllegalArgumentException("Invalid target type: "
                + targetTableType);
        }
    }

}
