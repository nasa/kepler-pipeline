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

package gov.nasa.kepler.soc;

import static com.google.common.collect.Lists.newArrayList;
import gov.nasa.kepler.gar.xmlbean.MeanBlackEntriesXB;
import gov.nasa.kepler.gar.xmlbean.RequantEntriesXB;
import gov.nasa.kepler.gar.xmlbean.RequantTableDocument;
import gov.nasa.kepler.gar.xmlbean.RequantTableXB;
import gov.nasa.kepler.hibernate.gar.RequantTable;
import gov.nasa.spiffy.common.pi.PipelineException;

import java.io.IOException;
import java.io.OutputStream;
import java.util.Calendar;
import java.util.List;
import java.util.TimeZone;

import org.apache.xmlbeans.XmlError;
import org.apache.xmlbeans.XmlOptions;

/**
 * Writes requant.
 * 
 * @author Miles Cote
 * 
 */
public class RequantWriter {

    private final OutputStream outputStream;

    public RequantWriter(OutputStream outputStream) {
        this.outputStream = outputStream;
    }

    public void write(ImportedRequantTable importedRequantTable) {
        RequantTable requantTable = importedRequantTable.getRequantTable();

        RequantTableDocument doc = RequantTableDocument.Factory.newInstance();

        Calendar start = Calendar.getInstance(TimeZone.getTimeZone("UTC"));
        start.setTime(requantTable.getPlannedStartTime());

        RequantTableXB requantTableXB = doc.addNewRequantTable();
        requantTableXB.setTableId(requantTable.getExternalId());
        requantTableXB.setPlannedStartTime(start);

        RequantEntriesXB requantEntriesXB = requantTableXB.addNewRequantEntries();
        int[] requantFluxes = requantTable.getRequantFluxes();
        requantEntriesXB.setTotalEntryCount(requantFluxes.length);
        for (int requantFlux : requantFluxes) {
            requantEntriesXB.addNewEntry()
                .setRequantflux(requantFlux);
        }

        MeanBlackEntriesXB meanBlackEntriesXB = requantTableXB.addNewMeanBlackEntries();
        int[] meanBlackValues = requantTable.getMeanBlackValues();
        meanBlackEntriesXB.setTotalEntryCount(meanBlackValues.length);
        for (int meanBlackValue : meanBlackValues) {
            meanBlackEntriesXB.addNewEntry()
                .setMeanBlack(meanBlackValue);
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

}
