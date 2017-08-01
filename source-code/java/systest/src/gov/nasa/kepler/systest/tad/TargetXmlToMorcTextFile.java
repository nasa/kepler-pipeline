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

package gov.nasa.kepler.systest.tad;

import gov.nasa.kepler.common.TargetManagementConstants;
import gov.nasa.kepler.hibernate.tad.Mask;
import gov.nasa.kepler.hibernate.tad.MaskTable.MaskType;
import gov.nasa.kepler.hibernate.tad.Offset;
import gov.nasa.kepler.hibernate.tad.TargetDefinition;
import gov.nasa.kepler.hibernate.tad.TargetTable.TargetType;
import gov.nasa.kepler.tad.xml.ImportedMaskTable;
import gov.nasa.kepler.tad.xml.ImportedTargetTable;
import gov.nasa.kepler.tad.xml.MaskReader;
import gov.nasa.kepler.tad.xml.TargetReader;

import java.io.BufferedInputStream;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileWriter;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.apache.xmlbeans.XmlException;

/**
 * This class converts target and aperture xml files into a text file of MORCs.
 * 
 * @author Miles Cote
 * 
 */
public class TargetXmlToMorcTextFile {

    private static final String EXCLUDE_CUSTOM_TARGETS = "--exclude-custom-targets";
    private static final Log log = LogFactory.getLog(TargetXmlToMorcTextFile.class);
    private MaskType maskType;
    private TargetType targetType;

    /**
     * Converts target and aperture xml files into a text file of MORCs.
     */
    public void toMorcTextFile(File targetXmlFile, File apertureXmlFile,
        File morcTextFile, boolean excludeCustomTargets) throws XmlException,
        IOException {

        log.info("Importing masks.");
        List<Mask> masks = importApertures(apertureXmlFile);

        log.info("Importing targetDefs.");
        List<TargetDefinition> targetDefs = importTargets(targetXmlFile);

        for (TargetDefinition targetDefinition : targetDefs) {
            int indexInTable = targetDefinition.getMask()
                .getIndexInTable();
            targetDefinition.setMask(masks.get(indexInTable));
        }

        if (targetType == TargetType.BACKGROUND
            && maskType != MaskType.BACKGROUND
            || targetType == TargetType.LONG_CADENCE
            && maskType != MaskType.TARGET
            || targetType == TargetType.REFERENCE_PIXEL
            && maskType != MaskType.TARGET
            || targetType == TargetType.SHORT_CADENCE
            && maskType != MaskType.TARGET) {
            throw new IllegalArgumentException(
                "targetType and apertureType must match.\n  targetType: "
                    + targetType + "\n  apertureType: " + maskType);
        }

        log.info("Creating morcs.");
        List<Morc> morcs = new ArrayList<Morc>();
        for (TargetDefinition targetDef : targetDefs) {
            if (!excludeCustomTargets
                || (excludeCustomTargets && !TargetManagementConstants.isCustomTarget(targetDef.getKeplerId()))) {
                for (Offset offset : targetDef.getMask()
                    .getOffsets()) {
                    int absRow = targetDef.getReferenceRow() + offset.getRow();
                    int absCol = targetDef.getReferenceColumn()
                        + offset.getColumn();
                    morcs.add(new Morc(targetDef.getCcdModule(),
                        targetDef.getCcdOutput(), absRow, absCol));
                }
            }
        }

        log.info("Sorting morcs.");
        Collections.sort(morcs);

        log.info("Writing morcs to file.");
        BufferedWriter writer = new BufferedWriter(new FileWriter(morcTextFile));
        for (Morc morc : morcs) {
            writer.write(morc.toString());
        }
        writer.close();
    }

    private List<Mask> importApertures(File file) throws IOException {
        MaskReader maskReader = new MaskReader(new BufferedInputStream(
            new FileInputStream(file)));
        ImportedMaskTable importedMaskTable = maskReader.read();

        maskType = importedMaskTable.getMaskTable()
            .getType();

        return importedMaskTable.getMasks();
    }

    private List<TargetDefinition> importTargets(File file) throws IOException {
        TargetReader targetReader = new TargetReader(new BufferedInputStream(
            new FileInputStream(file)));
        ImportedTargetTable importedTargetTable = targetReader.read();

        targetType = importedTargetTable.getTargetTable()
            .getType();

        return importedTargetTable.getTargetDefinitions();
    }

    private class Morc implements Comparable<Morc> {

        private int module;
        private int output;
        private int row;
        private int column;

        public Morc(int module, int output, int row, int column) {
            this.module = module;
            this.output = output;
            this.row = row;
            this.column = column;
        }

        @Override
        public String toString() {
            return module + ":" + output + ":" + row + ":" + column + "\n";
        }

        @Override
        public int compareTo(Morc o) {
            if (this.module < o.module) {
                return -1;
            } else if (this.module > o.module) {
                return 1;
            } else {
                if (this.output < o.output) {
                    return -1;
                } else if (this.output > o.output) {
                    return 1;
                } else {
                    if (this.row < o.row) {
                        return -1;
                    } else if (this.row > o.row) {
                        return 1;
                    } else {
                        if (this.column < o.column) {
                            return -1;
                        } else if (this.column > o.column) {
                            return 1;
                        } else {
                            return 0;
                        }
                    }
                }
            }
        }
    }

    public static void main(String[] args) throws XmlException, IOException {
        if (args.length == 4
            || (args.length == 5 && args[4].equals(EXCLUDE_CUSTOM_TARGETS))) {
            // args are valid.
            boolean excludeCustomTargets = args.length == 5;

            TargetXmlToMorcTextFile morcTextFile = new TargetXmlToMorcTextFile();

            File dir = new File(args[0]);

            morcTextFile.toMorcTextFile(new File(dir, args[1]), new File(dir,
                args[2]), new File(dir, args[3]), excludeCustomTargets);
        } else {
            // args are invalid.
            System.err.println("USAGE: export-morc-text-file ABSOLUTE_DIRECTORY TARGET_XML_FILE_NAME "
                + "APERTURE_XML_FILE_NAME OUTPUT_MORC_TEXT_FILE_NAME ["
                + EXCLUDE_CUSTOM_TARGETS + "]");
            System.err.println("  example: export-morc-text-file /path/to/RCLC/ops_12 "
                + "kplr2009065155243-012_lct.xml kplr2009065155243-012_tad.xml lct-morcs.txt "
                + EXCLUDE_CUSTOM_TARGETS);
            System.exit(-1);
        }
    }

}
