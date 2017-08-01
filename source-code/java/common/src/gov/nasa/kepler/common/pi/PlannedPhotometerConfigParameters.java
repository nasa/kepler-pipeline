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

package gov.nasa.kepler.common.pi;

import gov.nasa.spiffy.common.pi.Parameters;


public class PlannedPhotometerConfigParameters implements Parameters {

    private int compressionExternalId;
    private int badExternalId;
    private int bgpExternalId;
    private int tadExternalId;
    private int lctExternalId;
    private int sctExternalId;
    private int rptExternalId;

    public long getPhotometerConfigId() {
        long photometerConfigId;
        
        photometerConfigId = 0x08; // all flags = 0, except finePoint = 1
        photometerConfigId = (photometerConfigId << 8)
            + getLctExternalId();
        photometerConfigId = (photometerConfigId << 8)
            + getSctExternalId();
        photometerConfigId = (photometerConfigId << 8)
            + getBgpExternalId();
        photometerConfigId = (photometerConfigId << 8)
            + getBadExternalId();
        photometerConfigId = (photometerConfigId << 8)
            + getTadExternalId();
        photometerConfigId = (photometerConfigId << 8)
            + getRptExternalId();
        photometerConfigId = (photometerConfigId << 8)
            + getCompressionExternalId();
        
        return photometerConfigId;
    }
    
    public PlannedPhotometerConfigParameters() {
    }

    public PlannedPhotometerConfigParameters(int compressionExternalId,
        int badExternalId, int bgpExternalId, int tadExternalId,
        int lctExternalId, int sctExternalId, int rptExternalId) {
        this.compressionExternalId = compressionExternalId;
        this.badExternalId = badExternalId;
        this.bgpExternalId = bgpExternalId;
        this.tadExternalId = tadExternalId;
        this.lctExternalId = lctExternalId;
        this.sctExternalId = sctExternalId;
        this.rptExternalId = rptExternalId;
    }

    public int getCompressionExternalId() {
        return compressionExternalId;
    }

    public void setCompressionExternalId(int compressionExternalId) {
        this.compressionExternalId = compressionExternalId;
    }

    public int getBadExternalId() {
        return badExternalId;
    }

    public void setBadExternalId(int badExternalId) {
        this.badExternalId = badExternalId;
    }

    public int getBgpExternalId() {
        return bgpExternalId;
    }

    public void setBgpExternalId(int bgpExternalId) {
        this.bgpExternalId = bgpExternalId;
    }

    public int getTadExternalId() {
        return tadExternalId;
    }

    public void setTadExternalId(int tadExternalId) {
        this.tadExternalId = tadExternalId;
    }

    public int getLctExternalId() {
        return lctExternalId;
    }

    public void setLctExternalId(int lctExternalId) {
        this.lctExternalId = lctExternalId;
    }

    public int getSctExternalId() {
        return sctExternalId;
    }

    public void setSctExternalId(int sctExternalId) {
        this.sctExternalId = sctExternalId;
    }

    public int getRptExternalId() {
        return rptExternalId;
    }

    public void setRptExternalId(int rptExternalId) {
        this.rptExternalId = rptExternalId;
    }

}