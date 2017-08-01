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

package gov.nasa.kepler.ar.exporter.dv;

import static gov.nasa.kepler.common.FitsConstants.*;
import static gov.nasa.kepler.common.FitsUtils.addChecksum;
import gov.nasa.kepler.ar.exporter.primary.PrimaryHeaderFormatter;
import gov.nasa.kepler.hibernate.cm.CelestialObject;


import nom.tam.fits.Header;
import nom.tam.fits.HeaderCardException;

/**
 * The primary header can appropriately be formatted using nom.tam.fits. This
 * class accomplishes that. This the is a View part of the Model-View-Controller
 * pattern, This class doesn't extend TargetPrimaryHeaderFormatter because that
 * class is declared final. It is assumed that this class will not be used to
 * export K2 data.
 * 
 * @author lbrownst
 */
public final class DvTargetPrimaryHeaderFormatter extends PrimaryHeaderFormatter {

    /** DV time series file format. */
    public static final String FILE_VERSION = "2.0";

    /**
     * The API for this class. The following cards don't apply to this exporter:
     * CAMPAIGN, CHANNEL, MODULE, OUTPUT, QUARTER, SEASON
     * 
     * @param source contains the data to be exported to the primary header; the
     * Model part of the Model-View-Controller pattern
     * @param checksumString
     * @return a new non-null Header the contents of which are specified in the
     * source argument
     * @throws HeaderCardException on failure to write a card
     * @throws NullPointerException if either argument is null
     */
    public Header formatHeader(DvTargetPrimaryHeaderSource source,
        String checksumString) throws HeaderCardException {

        Header primaryHeader = super.formatHeader(source);

        CelestialObject celestialObject = source.celestialObject();

        // These are the cards that are common to all primary headers
        // and that come from an instance of CelestialObject 
        super.addCelestialObjectKeyWords(primaryHeader, celestialObject,
            source.raDegrees(), source.isK2Target());
        
        primaryHeader.addValue(XMLSTR_KW, source.dvXmlFileName(), XMLSTR_COMMENT);
        primaryHeader.addValue(DVVERSN_KW, source.dvSoftwareRevisionNumber(), DVVERSN_COMMENT);
        primaryHeader.addValue(QUARTERS_KW, source.quarters(), QUARTERS_COMMENT);
        primaryHeader.addValue(NUMTCES_KW, source.tceCount(), NUMTCES_COMMENT);

        addChecksum(primaryHeader, checksumString, source.generatedAt());
        
        return primaryHeader;
    }

    /** @return this exporter's version number as a formatted string. */
    @Override
    protected String fileVersion() {
        return FILE_VERSION;
    }

}
