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

package gov.nasa.kepler.ui.proxy;

import gov.nasa.kepler.hibernate.AbstractCrud;
import gov.nasa.kepler.hibernate.dbservice.DatabaseService;
import gov.nasa.kepler.hibernate.gar.CompressionCrud;
import gov.nasa.kepler.hibernate.gar.HuffmanTable;
import gov.nasa.kepler.hibernate.gar.HuffmanTableDescriptor;
import gov.nasa.kepler.hibernate.gar.RequantTable;
import gov.nasa.kepler.hibernate.gar.RequantTableDescriptor;

import java.util.List;
import java.util.Set;

/**
 * Provides a transactional version of {@link CompressionCrud}.
 * 
 * @author Bill Wohler
 */
public class CompressionCrudProxy extends AbstractCrud {

    private CompressionCrud compressionCrud;

    /**
     * Creates a new {@link CompressionCrudProxy} object.
     */
    public CompressionCrudProxy() {
        this(null);
    }

    /**
     * Creates a new {@link CompressionCrudProxy} object with the specified
     * database service.
     * 
     * @param databaseService the {@link DatabaseService} to use for the
     * operations
     */
    public CompressionCrudProxy(DatabaseService databaseService) {
        super(databaseService);
        compressionCrud = new CompressionCrud(databaseService);
    }

    public void createHuffmanTable(HuffmanTable table) {
        getDatabaseService().beginTransaction();
        compressionCrud.createHuffmanTable(table);
        getDatabaseService().flush();
        getDatabaseService().commitTransaction();
    }

    public HuffmanTable retrieveHuffmanTable(long id) {
        getDatabaseService().beginTransaction();
        HuffmanTable huffmanTable = compressionCrud.retrieveHuffmanTable(id);
        getDatabaseService().flush();
        getDatabaseService().commitTransaction();

        return huffmanTable;
    }

    public List<HuffmanTableDescriptor> retrieveAllHuffmanTableDescriptors() {
        getDatabaseService().beginTransaction();
        List<HuffmanTableDescriptor> huffmanTableDescriptors = compressionCrud.retrieveAllHuffmanTableDescriptors();
        getDatabaseService().flush();
        getDatabaseService().commitTransaction();

        return huffmanTableDescriptors;
    }

    public void createRequantTable(RequantTable table) {
        getDatabaseService().beginTransaction();
        compressionCrud.createRequantTable(table);
        getDatabaseService().flush();
        getDatabaseService().commitTransaction();
    }

    public RequantTable retrieveRequantTable(long id) {
        getDatabaseService().beginTransaction();
        RequantTable requantTable = compressionCrud.retrieveRequantTable(id);
        getDatabaseService().flush();
        getDatabaseService().commitTransaction();

        return requantTable;
    }

    public List<RequantTableDescriptor> retrieveAllRequantTableDescriptors() {
        getDatabaseService().beginTransaction();
        List<RequantTableDescriptor> requantTableDescriptors = compressionCrud.retrieveAllRequantTableDescriptors();
        getDatabaseService().flush();
        getDatabaseService().commitTransaction();

        return requantTableDescriptors;
    }

    public Set<Integer> retrieveUplinkedExternalIds() {
        getDatabaseService().beginTransaction();
        Set<Integer> uplinkedExternalIds = compressionCrud.retrieveUplinkedExternalIds();
        getDatabaseService().flush();
        getDatabaseService().commitTransaction();

        return uplinkedExternalIds;
    }

    public Set<Integer> retrieveExternalIdsInUse() {
        getDatabaseService().beginTransaction();
        Set<Integer> externalIdsInUse = compressionCrud.retrieveExternalIdsInUse();
        getDatabaseService().flush();
        getDatabaseService().commitTransaction();

        return externalIdsInUse;
    }

    /**
     * Used only for testing.
     */
    void setCompressionCrud(CompressionCrud compressionCrud) {
        this.compressionCrud = compressionCrud;
    }
}
