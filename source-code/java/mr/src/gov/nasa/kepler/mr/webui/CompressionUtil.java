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

package gov.nasa.kepler.mr.webui;

import gov.nasa.kepler.hibernate.gar.CompressionCrud;
import gov.nasa.kepler.hibernate.gar.ExportTable;
import gov.nasa.kepler.hibernate.gar.HuffmanTableDescriptor;
import gov.nasa.kepler.hibernate.gar.RequantTableDescriptor;
import gov.nasa.kepler.mr.MrTimeUtil;

import java.util.List;

/**
 * Provides methods for obtaining Huffman and requantization tables.
 * 
 * @author Bill Wohler
 */
public class CompressionUtil extends AbstractUtil {

    public String retrieveHuffmanTables() {
        dbPrepare();

        List<HuffmanTableDescriptor> huffmanTableDescriptors = null;
        try {
            huffmanTableDescriptors = new CompressionCrud().retrieveAllHuffmanTableDescriptors();
        } catch (Exception e) {
            return displayError("Could not obtain Huffman tables: ", e);
        }

        if (huffmanTableDescriptors.size() == 0) {
            String errorText = "No Huffman tables have been created.";
            return displayError(errorText);
        }

        // Generate select list option rows. The synchronization is needed
        // because Iso8601Formatter.dateTimeFormatter() is not thread-safe.
        StringBuilder options = new StringBuilder();
        synchronized (CompressionUtil.class) {
            boolean firstOption = true;
            for (HuffmanTableDescriptor huffmanTableDescriptor : huffmanTableDescriptors) {
                options.append("<option value=\"")
                    .append(huffmanTableDescriptor.getId())
                    .append('\"');
                if (firstOption) {
                    options.append(" selected");
                    firstOption = false;
                }
                String date = NO_DATA;
                if (huffmanTableDescriptor.getPlannedStartTime() != null) {
                    date = MrTimeUtil.dateFormatter()
                        .format(huffmanTableDescriptor.getPlannedStartTime());
                }
                String externalId = NO_DATA;
                if (huffmanTableDescriptor.getExternalId() != ExportTable.INVALID_EXTERNAL_ID) {
                    externalId = Integer.toString(huffmanTableDescriptor.getExternalId());
                }
                // Trim trailing space only.
                String display = toNbsp(
                    String.format("X%6d%6d%5s  %-22s%-27s",
                        huffmanTableDescriptor.getId(),
                        huffmanTableDescriptor.getPipelineTaskId(), externalId,
                        date, huffmanTableDescriptor.getState()
                            .toString())
                        .trim()).substring(1);
                options.append(">")
                    .append(display)
                    .append("</option>\r");
            }
        }

        return options.toString();
    }

    public String retrieveRequantTables() {
        dbPrepare();

        List<RequantTableDescriptor> requantTableDescriptors = null;
        try {
            requantTableDescriptors = new CompressionCrud().retrieveAllRequantTableDescriptors();
        } catch (Exception e) {
            return displayError("Could not obtain requantization tables: ", e);
        }

        if (requantTableDescriptors.size() == 0) {
            String errorText = "No requantization tables have been created.";
            return displayError(errorText);
        }

        // Generate select list option rows. The synchronization is needed
        // because MrTimeUtil.dateFormatter() is not thread-safe.
        StringBuilder options = new StringBuilder();
        synchronized (CompressionUtil.class) {
            boolean firstOption = true;
            for (RequantTableDescriptor requantTableDescriptor : requantTableDescriptors) {
                options.append("<option value=\"")
                    .append(requantTableDescriptor.getId())
                    .append('\"');
                if (firstOption) {
                    options.append(" selected");
                    firstOption = false;
                }
                String date = NO_DATA;
                if (requantTableDescriptor.getPlannedStartTime() != null) {
                    date = MrTimeUtil.dateFormatter()
                        .format(requantTableDescriptor.getPlannedStartTime());
                }
                String externalId = NO_DATA;
                if (requantTableDescriptor.getExternalId() != ExportTable.INVALID_EXTERNAL_ID) {
                    externalId = Integer.toString(requantTableDescriptor.getExternalId());
                }
                // Trim trailing space only.
                String display = toNbsp(
                    String.format("X%6d%6d%5s  %-22s%-27s",
                        requantTableDescriptor.getId(),
                        requantTableDescriptor.getPipelineTaskId(), externalId,
                        date, requantTableDescriptor.getState()
                            .toString())
                        .trim()).substring(1);
                options.append(">")
                    .append(display)
                    .append("</option>\r");
            }
        }

        return options.toString();
    }
}
