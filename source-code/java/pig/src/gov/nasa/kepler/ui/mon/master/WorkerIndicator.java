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

package gov.nasa.kepler.ui.mon.master;


public class WorkerIndicator extends Indicator {
    private static final long serialVersionUID = -4056901442680764397L;

	LabelValue stateLV = new LabelValue( "state", "Processing" );
    LabelValue moduleLV = new LabelValue( "module", "TPS" );
    LabelValue moduleUowLV = new LabelValue( "UOW", "[0,100]{2/1}" );
	LabelValue moduleTimeLV = new LabelValue( "PT", "00d 00h 12m 20s" );

    public WorkerIndicator(IndicatorPanel parentIndicatorPanel, String name) {
        super(parentIndicatorPanel, name);
        initGUI();
    }

    public WorkerIndicator(IndicatorPanel parentIndicatorPanel, String name, String state, String module, String moduleUow, String moduleTime) {
        super(parentIndicatorPanel, name);
        stateLV.setValue(state);
        moduleLV.setValue(module);
        moduleUowLV.setValue(moduleUow);
        moduleTimeLV.setValue(moduleTime);
        
        initGUI();
    }

    private void initGUI(){
        this.setPreferredSize(new java.awt.Dimension(220, 70));

        addDataComponent( stateLV );
        addDataComponent( moduleLV );
        addDataComponent( moduleUowLV );
        addDataComponent( moduleTimeLV );
    }
    
	public String getModule() {
		return moduleLV.getValue();
	}

	public void setModule(String module) {
		moduleLV.setValue( module );
	}

    public String getModuleUow() {
        return moduleUowLV.getValue();
    }

    public void setModuleUow(String moduleUow) {
        moduleUowLV.setValue( moduleUow );
    }

	public String getModuleTime() {
		return moduleTimeLV.getValue();
	}

	public void setModuleTime(String moduleTime) {
		moduleTimeLV.setValue( moduleTime );
	}

	public String getState() {
		return stateLV.getValue();
	}

	public void setState(String state) {
		stateLV.setValue( state );
	}
}
