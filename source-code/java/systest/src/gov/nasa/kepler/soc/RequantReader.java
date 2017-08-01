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
import gov.nasa.kepler.gar.xmlbean.MeanBlackEntryXB;
import gov.nasa.kepler.gar.xmlbean.RequantEntryXB;
import gov.nasa.kepler.gar.xmlbean.RequantTableDocument;
import gov.nasa.kepler.gar.xmlbean.RequantTableXB;
import gov.nasa.kepler.hibernate.gar.ExportTable.State;
import gov.nasa.kepler.hibernate.gar.MeanBlackEntry;
import gov.nasa.kepler.hibernate.gar.RequantEntry;
import gov.nasa.kepler.hibernate.gar.RequantTable;
import gov.nasa.spiffy.common.pi.PipelineException;

import java.io.IOException;
import java.io.InputStream;
import java.util.List;

import org.apache.xmlbeans.XmlError;
import org.apache.xmlbeans.XmlOptions;

/**
 * Reads requant.
 * 
 * @author Miles Cote
 * 
 */
public class RequantReader {

    private final InputStream inputStream;

    public RequantReader(InputStream inputStream) {
        this.inputStream = inputStream;
    }

    @SuppressWarnings("deprecation")
    public ImportedRequantTable read() {
        RequantTableDocument doc;
        try {
            doc = RequantTableDocument.Factory.parse(inputStream);
        } catch (Exception e) {
            throw new IllegalArgumentException("Unable to parse.", e);
        }

        XmlOptions xmlOptions = new XmlOptions();
        List<XmlError> errors = newArrayList();
        xmlOptions.setErrorListener(errors);
        if (!doc.validate(xmlOptions)) {
            throw new PipelineException("XML validation error.  " + errors);
        }

        RequantTableXB requantTableXB = doc.getRequantTable();

        RequantTable requantTable = new RequantTable();
        requantTable.setState(State.UPLINKED);
        requantTable.setExternalId(requantTableXB.getTableId());
        requantTable.setPlannedStartTime(requantTableXB.getPlannedStartTime()
            .getTime());

        for (RequantEntryXB requantEntryXB : requantTableXB.getRequantEntries()
            .getEntryArray()) {
            requantTable.getRequantEntries()
                .add(new RequantEntry(requantEntryXB.getRequantflux()));
        }

        for (MeanBlackEntryXB meanBlackEntryXB : requantTableXB.getMeanBlackEntries()
            .getEntryArray()) {
            requantTable.getMeanBlackEntries()
                .add(new MeanBlackEntry(meanBlackEntryXB.getMeanBlack()));
        }

        try {
            inputStream.close();
        } catch (IOException e) {
            throw new IllegalArgumentException("Unable to close.", e);
        }

        return new ImportedRequantTable(requantTable);
    }

}
