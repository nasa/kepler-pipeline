# Kepler Science Data Processing Pipeline

The Kepler telescope launched into orbit in March 2009, initiating
NASA’s first mission to discover Earth-size planets orbiting Sun-like
stars. Kepler simultaneously collected data for ∼160,000 target stars
over its four-year mission, identifying over 4700 planet candidates,
2300 confirmed or validated planets, and 2100 eclipsing binaries.
While Kepler was designed to discover exoplanets, the long term,
ultra-high photometric precision measurements it achieved also make it
a premier observational facility for stellar astrophysics, especially
in the field of asteroseismology, and for variable stars, such as RR
Lyrae stars. The Kepler Science Operations Center (SOC) was developed
at NASA Ames Research Center to process the data acquired by Kepler
starting with pixel-level calibrations all the way to identifying
transiting planet signatures and subjecting them to a suite of
diagnostic tests to establish or break confidence in their planetary
nature. Detecting small, rocky planets transiting Sun-like stars
presents a variety of daunting challenges, including achieving an
unprecedented photometric precision of ∼20 ppm on 6.5-hour timescales,
supporting the science operations, management, and repeated
reprocessing of the accumulating data stream.

The scientific objective of the Kepler Mission is to explore the
structure and diversity of planetary systems. This is achieved by
surveying a large sample of stars to:

* Determine the abundance of terrestrial and larger planets in or near
the habitable zone of a wide variety of stars;
* Determine the distribution of sizes and shapes of the orbits of these planets;
* Estimate how many planets are in multiple-star systems;
* Determine the variety of orbit sizes and planet reflectivities,
radii, masses and densities of short-period giant planets;
* Identify additional members of each discovered planetary system
  using other techniques; and
* Determine the properties of those stars that harbor planetary systems.

This repository contains the source code of the Science Data
Processing Pipeline. Please note that it is not expected that the
reader will be able to build or run this this software due to
third-party licensing restrictions and dependencies and other
complications.

The top-level directory contains the following files:

* [kscrm.pdf](kscrm.pdf)  
The Kepler Source Code Road Map. This document contains most of the
information normally found in GitHub README files. Please read this
first.
* [source-code](source-code)  
The source code itself.
* [parameters](parameters)  
The configuration details for the last run of the Kepler Science Data
Processing Pipeline.
* [MATHWORKS-LIMITED-LICENSE.docx](MATHWORKS-LIMITED-LICENSE.docx)  
The license for files from MathWorks.
* [NASA-OPEN-SOURCE-AGREEMENT.doc](NASA-OPEN-SOURCE-AGREEMENT.doc)  
The license for every other file.

## Contact Info

For questions on the science, algorithms, and MATLAB code, please
contact Jon Jenkins \<<Jon.Jenkins@nasa.gov>\>, Co-Investigator for
Data Processing.

For questions on the "plumbing" and Java code, please contact Bill
Wohler \<<Bill.Wohler@nasa.gov>\>, Senior Software Engineer.

## Copyright and Notices

The Kepler Science Data Processing Pipeline code is released under the
[NASA Open Source Agreement Version 1.3
license](NASA-OPEN-SOURCE-AGREEMENT.doc).

Code provided by MathWorks is released under the [MathWorks Limited
License](MATHWORKS-LIMITED-LICENSE.docx).

Copyright © 2017 United States Government as represented by the
Administrator of the National Aeronautics and Space Administration.
All Rights Reserved.

NASA acknowledges the SETI Institute’s primary role in authoring and
producing the Kepler Data Processing Pipeline under Cooperative
Agreement Nos. NNA04CC63A, NNX07AD96A, NNX07AD98A, NNX11AI13A,
NNX11AI14A, NNX13AD01A & NNX13AD16A.

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
