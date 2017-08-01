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

package gov.nasa.kepler.dr.fits;

import static gov.nasa.kepler.common.FitsConstants.*;
import gov.nasa.kepler.dr.pmrf.MaskTableBuilder;
import gov.nasa.kepler.dr.pmrf.ModOutBuilder;
import gov.nasa.kepler.dr.pmrf.TargetTableBuilder;
import gov.nasa.kepler.hibernate.dr.PmrfLog.PmrfType;
import gov.nasa.kepler.hibernate.tad.MaskTable;
import gov.nasa.kepler.hibernate.tad.ModOut;
import gov.nasa.kepler.hibernate.tad.TargetTable;
import nom.tam.fits.Header;
import nom.tam.fits.HeaderCardException;

/**
 * @author Miles Cote
 * 
 */
public class FitsHeaderBuilder {

    private Header header = new Header();

    public FitsHeaderBuilder() {
        header = new Header();
        try {
            ModOut modOut = new ModOutBuilder().build();
            header.addValue(MODULE_KW, modOut.getCcdModule(), "");
            header.addValue(OUTPUT_KW, modOut.getCcdOutput(), "");

            TargetTable targetTable = new TargetTableBuilder().build();
            MaskTable maskTable = new MaskTableBuilder().build();
            for (PmrfType pmrfType : PmrfType.values()) {
                header.addValue(pmrfType.getTargetTableKeyword(),
                    targetTable.getExternalId(), "");
                header.addValue(pmrfType.getApertureTableKeyword(),
                    maskTable.getExternalId(), "");
            }
        } catch (HeaderCardException e) {
            throw new IllegalArgumentException("Unable to add value.", e);
        }
    }

    public FitsHeader build() {
        return FitsHeader.of(header);
    }

    public FitsHeaderBuilder withHeader(Header header) {
        this.header = header;
        return this;
    }

}
