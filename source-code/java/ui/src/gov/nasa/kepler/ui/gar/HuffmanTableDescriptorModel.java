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

package gov.nasa.kepler.ui.gar;

import gov.nasa.kepler.hibernate.gar.ExportTable.State;
import gov.nasa.kepler.hibernate.gar.HuffmanTableDescriptor;
import gov.nasa.kepler.ui.swing.ToolTableModel;

import java.util.ArrayList;
import java.util.Date;
import java.util.List;

import org.jdesktop.application.Application;
import org.jdesktop.application.ResourceMap;

/**
 * A table model for the Huffman table export.
 * 
 * @author Bill Wohler
 */
@SuppressWarnings("serial")
public class HuffmanTableDescriptorModel extends ToolTableModel {

    public static enum Column {
        INSTANCE_ID(Long.class),
        TASK_ID(Long.class),
        START(Date.class),
        UPLINKED(Boolean.class),
        EXTERNAL_ID(Integer.class);

        private static ResourceMap resourceMap = Application.getInstance()
            .getContext()
            .getResourceMap(HuffmanTableDescriptorModel.class);
        private Class<?> clazz;

        private Column(Class<?> clazz) {
            this.clazz = clazz;
        }

        private String getColumnName() {
            return resourceMap.getString(toString().toLowerCase() + ".text");
        }

        private String getColumnTip() {
            return resourceMap.getString(toString().toLowerCase()
                + ".shortDescription");
        }

        private Class<?> getColumnClass() {
            return clazz;
        }
    }

    private Column[] columns = Column.values();
    private List<HuffmanTableDescriptor> huffmanTableDescriptors = new ArrayList<HuffmanTableDescriptor>();

    /**
     * Returns the Huffman table descriptors that this model is handling.
     * 
     * @return the Huffman table descriptors
     */
    public List<HuffmanTableDescriptor> getHuffmanTableDescriptors() {
        return huffmanTableDescriptors;
    }

    /**
     * Sets the Huffman table descriptors that this model is handling.
     * 
     * @param huffmanTableDescriptors the Huffman table descriptors that this
     * model is handling
     * @throws NullPointerException if {@code huffmanTableDescriptors} is
     * {@code null}
     */
    public void setHuffmanTableDescriptors(
        List<HuffmanTableDescriptor> huffmanTableDescriptors) {
        if (huffmanTableDescriptors == null) {
            throw new NullPointerException(
                "huffmanTableDescriptors can't be null");
        }
        this.huffmanTableDescriptors = huffmanTableDescriptors;
        fireTableDataChanged();
    }

    /**
     * Replace the given Huffman table descriptor with a new one.
     * 
     * @param oldHuffmanTableDescriptor the old Huffman table descriptor
     * @param huffmanTableDescriptor the new Huffman table descriptor
     * @throws NullPointerException if either {@code oldHuffmanTableDescriptor}
     * or {@code huffmanTableDescriptor} is {@code null}
     * @throws IllegalStateException if {@code oldHuffmanTableDescriptor} isn't
     * present in the model
     */
    public void replace(HuffmanTableDescriptor oldHuffmanTableDescriptor,
        HuffmanTableDescriptor huffmanTableDescriptor) {

        int row = huffmanTableDescriptors.indexOf(oldHuffmanTableDescriptor);
        if (row == -1) {
            throw new IllegalStateException(oldHuffmanTableDescriptor
                + ": no such descriptor");
        }

        huffmanTableDescriptors.set(row, huffmanTableDescriptor);
        fireTableRowsUpdated(row, row);
    }

    @Override
    public int getColumnCount() {
        return columns.length;
    }

    @Override
    public String getColumnName(int column) {
        return columns[column].getColumnName();
    }

    @Override
    public Class<?> getColumnClass(int column) {
        return columns[column].getColumnClass();
    }

    @Override
    public String getColumnTip(int column) {
        return columns[column].getColumnTip();
    }

    @Override
    public int getRowCount() {
        return huffmanTableDescriptors.size();
    }

    @Override
    public Object getValueAt(int row) {
        return huffmanTableDescriptors.get(row);
    }

    @Override
    public Object getValueAt(int row, int column) {
        HuffmanTableDescriptor huffmanTableDescriptor = huffmanTableDescriptors.get(row);
        switch (columns[column]) {
            case INSTANCE_ID:
                return huffmanTableDescriptor.getPipelineInstanceId();
            case TASK_ID:
                return huffmanTableDescriptor.getPipelineTaskId();
            case START:
                return huffmanTableDescriptor.getPlannedStartTime();
            case UPLINKED:
                return huffmanTableDescriptor.getState() == State.UPLINKED;
            case EXTERNAL_ID:
                return huffmanTableDescriptor.getExternalId();
            default:
                log.error("Unknown column index: " + column);
                return null;
        }
    }

    /**
     * Refresh the given Huffman table descriptor. Call this if a Huffman table
     * is updated and you want to update the view.
     * 
     * @param huffmanTableDescriptor the Huffman table descriptor
     * @throws NullPointerException if {@code huffmanTableDescritor} is
     * {@code null}
     */
    public void refresh(HuffmanTableDescriptor huffmanTableDescriptor) {
        int row = huffmanTableDescriptors.indexOf(huffmanTableDescriptor);
        fireTableRowsUpdated(row, row);
    }
}
