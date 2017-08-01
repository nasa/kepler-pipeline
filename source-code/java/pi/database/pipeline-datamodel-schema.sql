
--
-- run clean-pipeline-datamodel.sql first!
--
-- 
-- Copyright 2017 United States Government as represented by the
-- Administrator of the National Aeronautics and Space Administration.
-- All Rights Reserved.
-- 
-- This file is available under the terms of the NASA Open Source Agreement
-- (NOSA). You should have received a copy of this agreement with the
-- Kepler source code; see the file NASA-OPEN-SOURCE-AGREEMENT.doc.
-- 
-- No Warranty: THE SUBJECT SOFTWARE IS PROVIDED "AS IS" WITHOUT ANY
-- WARRANTY OF ANY KIND, EITHER EXPRESSED, IMPLIED, OR STATUTORY,
-- INCLUDING, BUT NOT LIMITED TO, ANY WARRANTY THAT THE SUBJECT SOFTWARE
-- WILL CONFORM TO SPECIFICATIONS, ANY IMPLIED WARRANTIES OF
-- MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, OR FREEDOM FROM
-- INFRINGEMENT, ANY WARRANTY THAT THE SUBJECT SOFTWARE WILL BE ERROR
-- FREE, OR ANY WARRANTY THAT DOCUMENTATION, IF PROVIDED, WILL CONFORM
-- TO THE SUBJECT SOFTWARE. THIS AGREEMENT DOES NOT, IN ANY MANNER,
-- CONSTITUTE AN ENDORSEMENT BY GOVERNMENT AGENCY OR ANY PRIOR RECIPIENT
-- OF ANY RESULTS, RESULTING DESIGNS, HARDWARE, SOFTWARE PRODUCTS OR ANY
-- OTHER APPLICATIONS RESULTING FROM USE OF THE SUBJECT SOFTWARE.
-- FURTHER, GOVERNMENT AGENCY DISCLAIMS ALL WARRANTIES AND LIABILITIES
-- REGARDING THIRD-PARTY SOFTWARE, IF PRESENT IN THE ORIGINAL SOFTWARE,
-- AND DISTRIBUTES IT "AS IS."
--
-- Waiver and Indemnity: RECIPIENT AGREES TO WAIVE ANY AND ALL CLAIMS
-- AGAINST THE UNITED STATES GOVERNMENT, ITS CONTRACTORS AND
-- SUBCONTRACTORS, AS WELL AS ANY PRIOR RECIPIENT. IF RECIPIENT'S USE OF
-- THE SUBJECT SOFTWARE RESULTS IN ANY LIABILITIES, DEMANDS, DAMAGES,
-- EXPENSES OR LOSSES ARISING FROM SUCH USE, INCLUDING ANY DAMAGES FROM
-- PRODUCTS BASED ON, OR RESULTING FROM, RECIPIENT'S USE OF THE SUBJECT
-- SOFTWARE, RECIPIENT SHALL INDEMNIFY AND HOLD HARMLESS THE UNITED
-- STATES GOVERNMENT, ITS CONTRACTORS AND SUBCONTRACTORS, AS WELL AS ANY
-- PRIOR RECIPIENT, TO THE EXTENT PERMITTED BY LAW. RECIPIENT'S SOLE
-- REMEDY FOR ANY SUCH MATTER SHALL BE THE IMMEDIATE, UNILATERAL
-- TERMINATION OF THIS AGREEMENT.
--

-- 
-- Pipeline Framework
--

CREATE TABLE pipeline_parameter_name (
    ID           	NUMBER(10) NOT NULL,
    NAME         	VARCHAR(100) NOT NULL,
    is_list         NUMBER(1) NOT NULL,
CONSTRAINT pipeline_parameter_name_pk PRIMARY KEY (id)
);

DROP SEQUENCE pipeline_parameter_name_id;
CREATE SEQUENCE pipeline_parameter_name_id start with 1 increment by 1;

CREATE TABLE pipeline_parameter_value (
    id           	NUMBER(10) NOT NULL,
    is_list         NUMBER(1) NOT NULL,
    value         	VARCHAR(100) NULL,
CONSTRAINT pipeline_parameter_value_pk PRIMARY KEY (id)
);

DROP SEQUENCE pipeline_parameter_value_id;
CREATE SEQUENCE pipeline_parameter_value_id start with 1 increment by 1;

CREATE TABLE pipeline_parameter_vl_map (
    ppv_id          	NUMBER(10) NOT NULL,
    value         		VARCHAR(255) NULL,
    order_index         NUMBER(10) NOT NULL,
CONSTRAINT pipeline_parameter_vl_map_pk PRIMARY KEY (ppv_id,order_index)
);


-- 
-- Pipeline Config
--

CREATE TABLE pipeline (
    ID           	NUMBER(10) NOT NULL,
    CREATED      	TIMESTAMP NOT NULL,
    NAME         	VARCHAR(100) NOT NULL,
    DESCRIPTION		VARCHAR(1000) NOT NULL,
    type         	VARCHAR(100) NOT NULL,
    root_node_id	number(10) null,
CONSTRAINT pipeline_pk PRIMARY KEY (id)
);

DROP SEQUENCE pipeline_id;
CREATE SEQUENCE pipeline_id start with 1 increment by 1;

CREATE TABLE active_dr_pipeline (
    ID           	NUMBER(10) NOT NULL,
    CREATED      	TIMESTAMP NOT NULL,
    pipeline_id	number(10) null,
CONSTRAINT active_dr_pipeline_pk PRIMARY KEY (id)
);

DROP SEQUENCE active_dr_pipeline_id;
CREATE SEQUENCE active_dr_pipeline_id start with 1 increment by 1;

CREATE TABLE pipeline_input_param_map (
    pipeline_id			number(10) null,
    param_name_id		number(10) null,
CONSTRAINT pipeline_input_param_map_pk PRIMARY KEY (pipeline_id, param_name_id )
);

CREATE TABLE pipeline_uow_param_map (
    pipeline_id			number(10) null,
    param_name_id		number(10) null,
CONSTRAINT pipeline_uow_param_map_pk PRIMARY KEY (pipeline_id, param_name_id )
);

CREATE TABLE pipeline_node (
    ID			NUMBER(10) NOT NULL,
    CREATED		TIMESTAMP not null,
    module_id	number(10) not null,
CONSTRAINT pipeline_node_pk PRIMARY KEY (id)
);

DROP SEQUENCE pipeline_node_id;
CREATE SEQUENCE pipeline_node_id start with 1 increment by 1;

CREATE TABLE pipeline_node_map (
    pn_owner_id			number(10) null,
    pn_next_id			number(10) null,
    order_index			number(10) null,
CONSTRAINT pipeline_node_map_pk PRIMARY KEY (pn_owner_id, order_index )
);

CREATE TABLE pipeline_module (
    ID           		NUMBER(10) NOT NULL,
    CREATED      		TIMESTAMP NOT NULL,
    NAME         		VARCHAR(100) NOT NULL,
    DESCRIPTION         VARCHAR(1000) NOT NULL,
    version				varchar(100) not null,
CONSTRAINT pipeline_module_pk PRIMARY KEY (id)
);

DROP SEQUENCE pipeline_module_id;
CREATE SEQUENCE pipeline_module_id start with 1 increment by 1;

--CREATE TABLE pipeline_module_param_map (
--    module_ID      		NUMBER(10) NULL,
--    param_name_ID      	NUMBER(10) NULL,
--    order_index			number(10) null,
--CONSTRAINT pipeline_module_param_map_pk PRIMARY KEY (module_id,order_index)
--);

CREATE TABLE KEY_VALUE_PAIR
(
    "KEY" VARCHAR2(100) NOT NULL,
    "VALUE" VARCHAR2(1000) NULL
);

ALTER TABLE KEY_VALUE_PAIR ADD CONSTRAINT KEY_VALUE_PAIR_PK PRIMARY KEY ("KEY");

CREATE TABLE MODULE_OPTIONS
(
    ID_OID NUMBER NOT NULL,
    STRING_KEY VARCHAR2(255) NOT NULL,
    STRING_VAL VARCHAR2(255) NULL
);

ALTER TABLE MODULE_OPTIONS ADD CONSTRAINT MODULE_OPTIONS_PK PRIMARY KEY (ID_OID,STRING_KEY);

--
-- Pipeline Instance
--

CREATE TABLE pipeline_instance (
    ID           		NUMBER(10) NOT NULL,
    CREATED      		TIMESTAMP NOT NULL,
    pipeline_id 		NUMBER(10) not null,
    state				number(10) not null,
    check_existing_outputs		number(1) not null,
CONSTRAINT pipeline_instance_pk PRIMARY KEY (id)
);

DROP SEQUENCE pipeline_instance_id;
CREATE SEQUENCE pipeline_instance_id start with 1 increment by 1;

CREATE TABLE pipeline_instance_p_map (
    pi_id         		NUMBER(10) NULL,
    param_name_id 		NUMBER(10) NOT NULL,
    param_value_id 		NUMBER(10) NOT NULL,
CONSTRAINT pipeline_instance_p_map_pk PRIMARY KEY (pi_id,param_name_id)
); 

CREATE TABLE pipeline_instance_node (
    ID          NUMBER(10) NOT NULL,
    CREATED     TIMESTAMP NOT NULL,
    pn_id		NUMBER(10) not null,
    pi_id		number(10) not null,
    state		number(10) not null,
    UNIT_OF_WORK_ID NUMBER NOT NULL,
CONSTRAINT pipeline_instance_node_pk PRIMARY KEY (id)
);

DROP SEQUENCE pipeline_instance_node_id;
CREATE SEQUENCE pipeline_instance_node_id start with 1 increment by 1;

CREATE TABLE pipeline_in_param_map (
    pin_id         		NUMBER(10) NULL,
    param_name_id 		NUMBER(10) NOT NULL,
    param_value_id 		NUMBER(10) NOT NULL,
CONSTRAINT pipeline_in_param_pk PRIMARY KEY (pin_id,param_name_id)
);

-- 
-- Trigger
--

CREATE TABLE PIPELINE_TRIGGER
(
    ID NUMBER NOT NULL,
    CREATED TIMESTAMP NULL,
    FIRED NUMBER(1) NOT NULL CHECK (FIRED IN ('1','0')),
    PIPELINE_ID NUMBER NULL,
    PI_ID NUMBER NULL,
    "TYPE" VARCHAR2(100) NOT NULL
);

ALTER TABLE PIPELINE_TRIGGER ADD CONSTRAINT PIPELINE_TRIGGER_PK PRIMARY KEY (ID);

--CREATE TABLE pipeline_trigger (
--    ID           		NUMBER(10) NOT NULL,
--    CREATED      		TIMESTAMP NOT NULL,
--    pipeline_id 		NUMBER(10) not null,
--    pi_id 				NUMBER(10) not null,
--    FIRED 				NUMBER(1) NOT NULL,
--    TYPE 				VARCHAR2(100) NOT NULL
--    state				number(10) not null,
--CONSTRAINT pipeline_trigger_pk PRIMARY KEY (id)
--);

DROP SEQUENCE pipeline_trigger_id;
CREATE SEQUENCE pipeline_trigger_id start with 1 increment by 1;

CREATE TABLE pipeline_trigger_p_map (
    pt_id         		NUMBER(10) NULL,
    param_name_id 		NUMBER(10) NOT NULL,
    param_value_id 		NUMBER(10) NOT NULL,
CONSTRAINT pipeline_trigger_p_map_pk PRIMARY KEY (pt_id,param_name_id)
); 

CREATE TABLE pipeline_dataset (
    ID           		NUMBER(10) NOT NULL,
    CREATED      		TIMESTAMP NOT NULL,
    pi_id		 		NUMBER(10) not null,
    start_timestamp		TIMESTAMP NOT NULL,
    end_timestamp		TIMESTAMP NOT NULL,
    dataset_type_id		varchar2(100) not null,
CONSTRAINT pipeline_dataset_pk PRIMARY KEY (id)
);

DROP SEQUENCE pipeline_dataset_id;
CREATE SEQUENCE pipeline_dataset_id start with 1 increment by 1;

CREATE TABLE dataset_type (
    short_name		VARCHAR2(100) NOT NULL,
    display_name 	VARCHAR2(100) NOT NULL,
    category		VARCHAR2(100) NOT NULL,
CONSTRAINT dataset_type_pk PRIMARY KEY (short_name)
);

purge recyclebin;
