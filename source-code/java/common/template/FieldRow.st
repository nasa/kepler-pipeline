<!-- A single string template.  See stringtemplate.org
 Parameters:
  typeName
   fieldName
   defaultValue
   fieldComment
   hasDefaultValue - When true the default value is printed else it is not
    this is used instead of just checking the default value because the 
    default value may valid and evaluate to false.
    
 Copyright 2017 United States Government as represented by the
 Administrator of the National Aeronautics and Space Administration.
 All Rights Reserved.
 
 This file is available under the terms of the NASA Open Source Agreement
 (NOSA). You should have received a copy of this agreement with the
 Kepler source code; see the file NASA-OPEN-SOURCE-AGREEMENT.doc.
 
 No Warranty: THE SUBJECT SOFTWARE IS PROVIDED "AS IS" WITHOUT ANY
 WARRANTY OF ANY KIND, EITHER EXPRESSED, IMPLIED, OR STATUTORY,
 INCLUDING, BUT NOT LIMITED TO, ANY WARRANTY THAT THE SUBJECT SOFTWARE
 WILL CONFORM TO SPECIFICATIONS, ANY IMPLIED WARRANTIES OF
 MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, OR FREEDOM FROM
 INFRINGEMENT, ANY WARRANTY THAT THE SUBJECT SOFTWARE WILL BE ERROR
 FREE, OR ANY WARRANTY THAT DOCUMENTATION, IF PROVIDED, WILL CONFORM
 TO THE SUBJECT SOFTWARE. THIS AGREEMENT DOES NOT, IN ANY MANNER,
 CONSTITUTE AN ENDORSEMENT BY GOVERNMENT AGENCY OR ANY PRIOR RECIPIENT
 OF ANY RESULTS, RESULTING DESIGNS, HARDWARE, SOFTWARE PRODUCTS OR ANY
 OTHER APPLICATIONS RESULTING FROM USE OF THE SUBJECT SOFTWARE.
 FURTHER, GOVERNMENT AGENCY DISCLAIMS ALL WARRANTIES AND LIABILITIES
 REGARDING THIRD-PARTY SOFTWARE, IF PRESENT IN THE ORIGINAL SOFTWARE,
 AND DISTRIBUTES IT "AS IS."

 Waiver and Indemnity: RECIPIENT AGREES TO WAIVE ANY AND ALL CLAIMS
 AGAINST THE UNITED STATES GOVERNMENT, ITS CONTRACTORS AND
 SUBCONTRACTORS, AS WELL AS ANY PRIOR RECIPIENT. IF RECIPIENT'S USE OF
 THE SUBJECT SOFTWARE RESULTS IN ANY LIABILITIES, DEMANDS, DAMAGES,
 EXPENSES OR LOSSES ARISING FROM SUCH USE, INCLUDING ANY DAMAGES FROM
 PRODUCTS BASED ON, OR RESULTING FROM, RECIPIENT'S USE OF THE SUBJECT
 SOFTWARE, RECIPIENT SHALL INDEMNIFY AND HOLD HARMLESS THE UNITED
 STATES GOVERNMENT, ITS CONTRACTORS AND SUBCONTRACTORS, AS WELL AS ANY
 PRIOR RECIPIENT, TO THE EXTENT PERMITTED BY LAW. RECIPIENT'S SOLE
 REMEDY FOR ANY SUCH MATTER SHALL BE THE IMMEDIATE, UNILATERAL
 TERMINATION OF THIS AGREEMENT.
-->

<!-- This section is automatically generated from FieldRow.st -->
 <tr style="page-break-inside:avoid;
  height:10.0pt">
  <td width=208 valign=top style="width:156.0pt;border:solid windowtext 1.0pt;
  border-top:none;
  padding:0in 2.85pt 0in 2.85pt;height:10.0pt">
  <p  align="right" style="margin-top:2.85pt;text-align:right">
  <b>$fieldName$</b>: <span style="color:#0000C0">$typeName$</span></p></td>
  <td width="428" valign="top" style="width:321.0pt;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0in 2.85pt 0in 2.85pt;height:10.0pt">
  
  $if(hasDefaultValue)$
  <p  style="margin-top:2.85pt;margin-right:0in;margin-bottom:
  .8pt;margin-left:0in">Default = $defaultValue$.</p>
  $endif$  
  <p  style="margin-top:2.85pt;margin-right:0in;margin-bottom:
  .8pt;margin-left:0in">$fieldComment$</p>
  </td>
 </tr>
 
