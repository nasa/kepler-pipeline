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

package gov.nasa.kepler.hibernate.fc;

import java.util.Arrays;

import gov.nasa.spiffy.common.pi.PipelineException;

import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;
import javax.persistence.JoinTable;
import javax.persistence.SequenceGenerator;
import javax.persistence.Table;

import org.hibernate.annotations.CollectionOfElements;
import org.hibernate.annotations.IndexColumn;

/**
 * A Hibernate class to persist the saturated pixels on a per-keplerId and per-season basis. 
 * 
 * @author kester
 *  
 */
@Entity
@Table(name = "FC_SATURATION")
public class Saturation {

    @Id
    @GeneratedValue(strategy = GenerationType.AUTO, generator = "sg")
    @SequenceGenerator(name = "sg", sequenceName = "FC_SAT_SEQ")
    private long id;
    
    private int keplerId;
    private int channel;
    private int season;
    
    @CollectionOfElements
    @JoinTable(name = "FC_SAT_COORDS")
    @IndexColumn(name="IDX")
    private SaturationColumn[] saturationCoordinates;

    // package-level no-op constructor for Hibernate
    Saturation() {
    }
    
    public Saturation(int keplerId, int channel, int season,
        SaturationColumn[] saturationCoordinates) {
        this.keplerId = keplerId;
        this.season = season;
        this.saturationCoordinates = saturationCoordinates;
    }
    
    public Saturation(int keplerId, int channel, int season,
        int[] columns, int[] rowStarts, int[] rowEnds) {
     
        if (columns.length != rowStarts.length || columns.length != rowEnds.length) {
            throw new PipelineException("Inconsistent data lengths in Saturation constructor");
        }

        this.keplerId = keplerId;
        this.channel = channel;
        this.season = season;
        
        SaturationColumn[] coords = new SaturationColumn[columns.length];
        for (int ii = 0; ii < coords.length; ++ii) {
            coords[ii] = new SaturationColumn(columns[ii], rowStarts[ii], rowEnds[ii]);
        }
        this.saturationCoordinates = coords;
    }
    
    public int getKeplerId() {
        return keplerId;
    }

    public void setKeplerId(int keplerId) {
        this.keplerId = keplerId;
    }

    public int getChannel() {
        return channel;
    }

    public void setChannel(int channel) {
        this.channel = channel;
    }

    public int getSeason() {
        return season;
    }

    public void setSeason(int season) {
        this.season = season;
    }

    public SaturationColumn[] getSaturationCoordinates() {
        return saturationCoordinates;
    }

    public void setSaturationCoordinates(
        SaturationColumn[] saturationCoordinates) {
        this.saturationCoordinates = saturationCoordinates;
    }    
    
    @Override
    public String toString() {
        return "Saturation [keplerId=" + keplerId + ", channel=" + channel
            + ", season=" + season + ", saturationCoordinates="
            + Arrays.toString(saturationCoordinates) + "]";
    }

}
