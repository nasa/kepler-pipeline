#!D:\perl\bin\perl.exe
###!/usr/bin/perl
###!C:\oracle\ora81/Apache/perl/5.00503/bin/MSWin32-x86/perl.exe
##
## ra2pix.pl - frontend to ra2pixcgi.exe which translates RA/DEC to CCD chan/row/column
##
# 
# Copyright 2017 United States Government as represented by the
# Administrator of the National Aeronautics and Space Administration.
# All Rights Reserved.
# 
# This file is available under the terms of the NASA Open Source Agreement
# (NOSA). You should have received a copy of this agreement with the
# Kepler source code; see the file NASA-OPEN-SOURCE-AGREEMENT.doc.
# 
# No Warranty: THE SUBJECT SOFTWARE IS PROVIDED "AS IS" WITHOUT ANY
# WARRANTY OF ANY KIND, EITHER EXPRESSED, IMPLIED, OR STATUTORY,
# INCLUDING, BUT NOT LIMITED TO, ANY WARRANTY THAT THE SUBJECT SOFTWARE
# WILL CONFORM TO SPECIFICATIONS, ANY IMPLIED WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, OR FREEDOM FROM
# INFRINGEMENT, ANY WARRANTY THAT THE SUBJECT SOFTWARE WILL BE ERROR
# FREE, OR ANY WARRANTY THAT DOCUMENTATION, IF PROVIDED, WILL CONFORM
# TO THE SUBJECT SOFTWARE. THIS AGREEMENT DOES NOT, IN ANY MANNER,
# CONSTITUTE AN ENDORSEMENT BY GOVERNMENT AGENCY OR ANY PRIOR RECIPIENT
# OF ANY RESULTS, RESULTING DESIGNS, HARDWARE, SOFTWARE PRODUCTS OR ANY
# OTHER APPLICATIONS RESULTING FROM USE OF THE SUBJECT SOFTWARE.
# FURTHER, GOVERNMENT AGENCY DISCLAIMS ALL WARRANTIES AND LIABILITIES
# REGARDING THIRD-PARTY SOFTWARE, IF PRESENT IN THE ORIGINAL SOFTWARE,
# AND DISTRIBUTES IT "AS IS."
#
# Waiver and Indemnity: RECIPIENT AGREES TO WAIVE ANY AND ALL CLAIMS
# AGAINST THE UNITED STATES GOVERNMENT, ITS CONTRACTORS AND
# SUBCONTRACTORS, AS WELL AS ANY PRIOR RECIPIENT. IF RECIPIENT'S USE OF
# THE SUBJECT SOFTWARE RESULTS IN ANY LIABILITIES, DEMANDS, DAMAGES,
# EXPENSES OR LOSSES ARISING FROM SUCH USE, INCLUDING ANY DAMAGES FROM
# PRODUCTS BASED ON, OR RESULTING FROM, RECIPIENT'S USE OF THE SUBJECT
# SOFTWARE, RECIPIENT SHALL INDEMNIFY AND HOLD HARMLESS THE UNITED
# STATES GOVERNMENT, ITS CONTRACTORS AND SUBCONTRACTORS, AS WELL AS ANY
# PRIOR RECIPIENT, TO THE EXTENT PERMITTED BY LAW. RECIPIENT'S SOLE
# REMEDY FOR ANY SUCH MATTER SHALL BE THE IMMEDIATE, UNILATERAL
# TERMINATION OF THIS AGREEMENT.
#

my $FORM;

sub getUnits {

    return '
      <table border=0>
        <tr>
           <td align=center>Units:</td>
           <td>
              <table border=0>
                <tr>
                   <td>
<input type="radio" name="RADECTYPE" value="d" ',($FORM{"RADECTYPE"} eq "d") ? "CHECKED" : "",'
OnClick=submit()>
                   </td>
                   <td>Decimal</td>
                </tr>
                <tr>
                   <td>
<input type="radio" name="RADECTYPE" value="t" ',($FORM{"RADECTYPE"} ne "d") ? "CHECKED" : "",'
OnClick=submit()>
                   </td>
                   <td>Time</td>
                </tr>
              </table>
           </td>
        <tr>
      </table>';
}

sub getUnitsHorizontal {

    return '
      <table border=0>
        <tr>
           <td>
<input type="radio" name="RADECTYPE" value="d" ',($FORM{"RADECTYPE"} eq "d") ? "CHECKED" : "",'
OnClick=submit()>
           </td>
           <td>Decimal</td>
           <td>
<input type="radio" name="RADECTYPE" value="t" ',($FORM{"RADECTYPE"} ne "d") ? "CHECKED" : "",'
OnClick=submit()>
           </td>
           <td>Time</td>
        <tr>
      </table>';
}

sub getRADecFields {

    if ($FORM{"RADECTYPE"} eq "d") {
	return '
<table border=0>
   <tr>
      <td>RA:</td>
      <td><input type="text" name="RA" SIZE=16 Value="'. $FORM{"RA"}.'"></td>
      <td>Degrees</td>
   </tr>
   <tr>
      <td>DEC:</td>
      <td><input type="text" name="DEC" SIZE=16 Value="'. $FORM{"DEC"}.'"></td>
      <td>Degrees</td>
   </tr>
</table>';

    } else {

	return '
<table border=0>
   <tr>
      <td>RA:</td>
      <td><input type="text" name="RAHOURS" SIZE=3 Value="' . $FORM{"RAHOURS"}.'"></td>
      <td><input type="text" name="RAMINUTES" SIZE=2 Value="'. $FORM{"RAMINUTES"}.'"></td>
      <td><input type="text" name="RASECONDS" SIZE=2 Value="'. $FORM{"RASECONDS"}.'"></td>
      <td>Hours Minutes Seconds</td>
   </tr>
   <tr>
      <td>DEC:</td>
      <td><input type="text" name="DECDEGREES" SIZE=3 Value="'. $FORM{"DECDEGREES"}.'"></td>
      <td><input type="text" name="DECMINUTES" SIZE=2 Value="'. $FORM{"DECMINUTES"}.'"></td>
      <td><input type="text" name="DECSECONDS" SIZE=2 Value="'. $FORM{"DECSECONDS"}.'"></td>
      <td>Degrees Minutes Seconds</td>
   </tr>
</table>';

    }
}

sub getSeasonTable() {
    return 
                             '<table border=0>
                                <tr>
                                   <td>
                                   <table border=0>
                                       <tr>
                                          <td colspan=3 align=left><b>Season:</b></td>
                                       </tr>
                                       <tr>
                                          <td>&nbsp;</td>
                                          <td>
<input type="radio" name="SEASON" Value="0" ', ($FORM{"SEASON"} eq "0") ? "CHECKED" : "",'>
                                          </td>
                                          <td>Summer</td>
                                       </tr>

                                       <tr>
                                          <td>&nbsp;</td>
                                          <td>
<input type="radio" name="SEASON" Value="1" ', ($FORM{"SEASON"} eq "1") ? "CHECKED" : "",'>
                                          </td>
                                          <td>Fall</td>
                                       </tr>

                                       <tr>
                                          <td>&nbsp;</td>
                                          <td>
<input type="radio" name="SEASON" Value="2" ', ($FORM{"SEASON"} eq "2") ? "CHECKED" : "",'>
                                          </td>
                                          <td>Winter</td>
                                       </tr>
                                       <tr>
                                           <td>&nbsp;</td>
                                           <td>
<input type="radio" name="SEASON" Value="3" ', ($FORM{"SEASON"} eq "3") ? "CHECKED" : "",'>
                                           </td>
                                           <td>Spring</td>
                                       </tr>
                                   </table>
                                   </td>
                                </tr>
                              </table>';

}

sub DisplayOutput {
    $output = shift;
    if ($output) {
	$FOVLocation ="";

        @lines = split(/\n/, $output);

	foreach (@lines) {
	    if (/FPA:/) {
	        $fpaLine = $_;
		if (/\*\*\*/) {
		    $FOVLocation = "The coordinates are just outside the FOV.";
		} else {
		    $FOVLocation = "The coordinates are within the FOV.";
		}
            }
	    if (/RA2pix/) {
		$version = $_;
	    }
        }

	$fpaLine =~ s/= +/=/g;
        @fpaInfo = split(/ +/, $fpaLine);
	@channel = split(/=/, $fpaInfo[3]);
	@row = split(/=/, $fpaInfo[4]);
	@column = split(/=/, $fpaInfo[5]);
	if ($channel[1] eq "") {
	    $resultTable = 
		'<td></td>
		     <td><table border=1 bgcolor=#FFFFFF cellspacing=0 cellpadding=3><tr><td>The coordinates are well out of the FOV.</td></tr></table>';
	    $FOVLocTable = "";
        } else {
	    $resultTable = 
		     '<td>Channel:</td>
		     <td><table border=1 bgcolor=#FFFFFF cellspacing=0 cellpadding=3><tr><td>'.$channel[1].'</td></tr></table>
		     </td>
	             <td>&nbsp;&nbsp;Row:</td>
		        <td>
		     <table border=1 bgcolor=#FFFFFF cellspacing=0 cellpadding=3><tr><td>'.$row[1].'</td></tr></table>
			</td>
	             <td>&nbsp;&nbsp;Column:</td>
		     <td>
		     <table border=1 bgcolor=#FFFFFF cellspacing=0 cellpadding=3><tr><td>'.$column[1].'</td></tr></table>';

	    $FOVLocTable = '<table border=1 bgcolor=#FFFFFF cellspacing=0 cellpadding=3><tr><td>'.$FOVLocation.'</td></tr></table>';

        }
        return 
         '<table>
             <tr>
                <td colspan=2><b>Focal Plane Location:</b></td>
             </tr>
	     <tr>
	     <td><!--<pre>',$output,'</pre>--></td>
	     </tr>
             <tr>
               <td>&nbsp;&nbsp;</td>
               <td>
   	          <table border=0>
                    <tr>',$resultTable,'
		     </td>
                    </tr>
                  </table>
               </td>
             </tr>
             <tr>
               <td>&nbsp;&nbsp;</td><td>',$FOVLocTable,'</td>
             </tr>
	    <tr>
	    <td align=right>',$version,'</td>
	    <td>&nbsp;</td>
	    </tr>
         </table>'
     } else {
         '<table>
             <tr>
                <td colspan=2><b>Enter a location.</b></td>
		<td><!--', $output, '--></td>
             </tr>
         </table>'
     }
}

sub PrintForm {

	print 
'Content-Type: text/html

<html>
<head>
<title>Kepler FOV Calculator</title>
</head>
<body bgcolor="#f9f9d3">
<!-- Command: ', shift(),'-->
<table width=100%><tr><td align=right><a href="" onclick="window.close();"><font size=-1>Close window</font></a></td></tr></table>
<b><font size=+2>Kepler FOV Calculator</font></b>
<br>
<font size=-1>Version 1.6  Last updated: 08/18/2005</font>
<center>

<!-- put one border around everything -->
<table border=1 bgcolor=#CCCCCC>
<tr>
<td>

<!-- top level encompasing table for form and output -->
<table>
</tr>
<td>

<form action="/cgi-bin/ra2pix.pl" method="POST">

<table border=0>
 <tr>
   <td>
    <table border=0>
    <tr>
       <td bgcolor=#CCCCCC>
          <table border=1>
            <tr>
               <td>'
,getSeasonTable(),
               '</td>
                <td>
                  <table border=0>
                            <tr>
                               <td>
                                   <table border=0>
                                       <tr>
                                          <td>
                                             <table border=0>
                                                 <tr>
                                                    <td valign=center>
<b>Object location:</b>
                                                    </td>
                                                    <td>'
,getUnitsHorizontal(),
                                                    '</td>
                                                       <td>&nbsp;&nbsp;&nbsp;&nbsp;</td>
                                                       <td>&nbsp;&nbsp;&nbsp;&nbsp;</td>
                                                       <td>&nbsp;&nbsp;&nbsp;&nbsp;</td>
                                                       <td>&nbsp;&nbsp;&nbsp;&nbsp;</td>
                                                 </tr>
                                             </table>
                                          </td>
                                       </tr>
                                       <tr>
                                          <td>
',getRADecFields(),'
                                          </td>
                                       </tr>
                                   </table>
                               </td>
                            </tr>
                  </table>
                </td>
            </tr>
          </table>
       </td>
    </tr>
    </table>
   </td>
 <tr>
   <td align=center colspan=2>
<input type="submit" value="Find location on Focal Plane">
   </td>
 </tr>
</table>

</form>
</td>
</tr>
<tr>
<td>
<!-- ra2pix output -->
<table>
   <tr>
      <td>'
,DisplayOutput(shift()),
      '</td>
   </tr>
</table>
</td>
</tr>
</table>

</td>
</tr>
</table>
</center>
<br>
<center><img border=0 src="/gif_files/Channel_numbers.jpg"" alt="Kepler CCD Channel Numbers"></center>

<H2>About this tool...</H2>
<BLOCKQUOTE><P><FONT SIZE="+1">
This tool is an aid to the community for determining if an object of interest will be in the Kepler field-of-view (FOV). The figure above provides a graphical representation of the layout of the CCDs, the location of the 84 channels, and row/column directions. The coordinates in the graphic are probably good to within about 1 arc minute.  Each square module in the figure is composed of two rectangular CCDs with a small gap between the CCDs.
</FONT></P></BLOCKQUOTE>

<BLOCKQUOTE><P><FONT SIZE="+1">
This tool will provide the precise values for the data channel, and the CCD row and column of the center of the point spread function of the object. The CCD data channels are numbered 1 to 84. Each channel has 1024 rows and 1100 columns. The 0,0 for each channel is in the corner of the module. Row 1024 is at the gap between two CCDs on a module. Column 1100 is where the two channels on a CCD meet in the middle of the CCD chip. A single pixel is 3.98 arcsec on a side.
</FONT></P></BLOCKQUOTE>

<BLOCKQUOTE><P><FONT SIZE="+1">
If a row or column is less than 0 or a row is greater than 1024, the object is just off the CCD by a small amount. Objects that are off by large amounts will not have a calculated value, only a flag and message to indicate as much. 
</FONT></P></BLOCKQUOTE>

<BLOCKQUOTE><P><FONT SIZE="+1">
There are a number of caveats:
<ol>
<li>
This is based on the current design, which may change. The CCDs and optics are already being made so they won\'t change. The pointing on the sky may change.
</li>
<li>
The precise CCD locations in the focal plane will have an uncertainty of a few pixels and will not be known until after launch
</li>
<li>
Objects near the edges of the CCDs may be of marginal quality, since the psf for a point source is on the order of 2.5 to 5 pixels in size (95% encircled energy) and part of the psf may be off the edge of the CCD.
</li>
<li>
The location of bad pixels is unknown at this time.
</li>
</ol>
</FONT></P></BLOCKQUOTE>

<h2>Input information...</h2>

<BLOCKQUOTE><P><FONT SIZE="+1">
The spacecraft will be rotated 90 degrees every 3 months to keep the Sun on the solar array and the radiator pointed to deep space to cool the CCDs. The layout of the focal plane is four-fold symmetric so that to within a few pixels the same stars are imaged onto active silicon independent of the rotation. Thus the CCD data channel changes with the season and the exact pixel location will move slightly.
</FONT></P></BLOCKQUOTE>

<BLOCKQUOTE><P><FONT SIZE="+1">
So one first needs to pick the "season" and then enter the coordinates.
</FONT></P></BLOCKQUOTE>

</body>
</html>
';

    } #end Sub PrintForm

sub getnum {
    use POSIX qw(strtod);
    my $str = shift;
    $str =~ s/^\s+//;
    $str =~ s/\s+$//;
    $! = 0;
    my($num, $unparsed) = strtod($str);
    if (($str eq '') || ($unparsed != 0) || $!) {
        return;
    } else {
        return $num;
    } 
} 

sub is_numeric { defined scalar &getnum } 

#
# Main code...

if ( $ENV{'REQUEST_METHOD'} eq "POST" ) {

    my $validData = 1;
    my $error = "";
    my $result;
    my $RA;
    my $DEC;
    my $RAHOURS;
    my $RAMINUTES;
    my $RASECONDS;
    my $DECDEGREES;
    my $DECMINUTES;
    my $DECDEGREES;
    my $RADECTYPE;

    read(STDIN, $buffer, $ENV{'CONTENT_LENGTH'});
    $coordtype = " -type d ";

    foreach $pair (split(/&/, $buffer)) {
	my ($name, $value) = split(/=/, $pair);

	$value =~ tr/+/ /;
	$value =~ s/%([a-fA-F0-9][a-fA-F0-9])/pack("C", hex($1))/eg;

	$FORM{$name} = $value;

	if ($name eq "SEASON") {
	    $result = $result . " -s " . $value ;
	} elsif ($name eq "RA") {
            $RA = $value;
	    $result = $result . " -r " . $value ;
	} elsif ($name eq "DEC") {
            $DEC = $value;
	    $result = $result . " -d " . $value ;
	} elsif ($name eq "RAHOURS") {
	    $RAHOURS = $value;
	    $result = $result . " -rh " . $value ;
	} elsif ($name eq "RAMINUTES") {
	    $RAMINUTES = $value;
	    $result = $result . " -rm " . $value ;
	} elsif ($name eq "RASECONDS") {
	    $RASECONDS = $value;
	    $result = $result . " -rs " . $value ;
	} elsif ($name eq "DECDEGREES") {
	    $DECDEGREES = $value;
	    $result = $result . " -dd " . $value ;
	} elsif ($name eq "DECMINUTES") {
	    $DECMINUTES = $value;
	    $result = $result . " -dm " . $value ;
	} elsif ($name eq "DECSECONDS") {
	    $DECSECONDS = $value;
	    $result = $result . " -ds " . $value ;
	} elsif ($name eq "RADECTYPE") {
	    $RADECTYPE = $value;
	}
    }

#    foreach $var (keys(%FORM)) {
#	$val = $FORM{$var};
#	$args = $args . "${var}=\"${val}\"\n";
#    }

     if ($validData) {
	 if ($RADECTYPE eq "d") {
	     $coordtype = " -type d ";
	     if (($RA eq "")  || ($RA > 360)) { $validData = 0 };
	     if (($DEC eq "") || ($DEC > 360)) { $validData = 0 };
	     unless ($RA =~ /[-+]?([0-9]*\.)?[0-9]+/ ) { $validData = 0; }
	     unless ($DEC =~ /[-+]?([0-9]*\.)?[0-9]+/ ) { $validData = 0; }
	 } else {
	     $coordtype = " -type t ";
	     if (($RAHOURS eq "") || ($RAMINUTES eq "") || ($RASECONDS eq "")) { $validData = 0 };
	     if (($DECDEGREES eq "") || ($DECMINUTES eq "") || ($DECSECONDS eq "")) { $validData = 0 };
	     unless ($RAHOURS =~ /[-+]?([0-9]*\.)?[0-9]+/ ) { $validData = 0; }
	     unless ($RAMINUTES =~ /[-+]?([0-9]*\.)?[0-9]+/ ) { $validData = 0; }
	     unless ($RASECONDS =~ /[-+]?([0-9]*\.)?[0-9]+/ ) { $validData = 0; }
	     unless ($DECDEGREES =~ /[-+]?([0-9]*\.)?[0-9]+/ ) { $validData = 0; }
	     unless ($DECMINUTES =~ /[-+]?([0-9]*\.)?[0-9]+/ ) { $validData = 0; }
	     unless ($DECSECONDS =~ /[-+]?([0-9]*\.)?[0-9]+/ ) { $validData = 0; }
	     if ($RAHOURS > 24) { $validData = 0; }
	     if ($RAMINUTES > 60) { $validData = 0; }
	     if ($RASECONDS > 60) { $validData = 0; }
	     if ($DECDEGREES > 360) { $validData = 0; }
	     if ($DECMINUTES > 60) { $validData = 0; }
	     if ($DECSECONDS > 60) { $validData = 0; }
	 }
    }

     if ($validData) {
        # Path to $command changed to relative a path 24 April 2006, after
        #   the webserver was moved to a different drive on Web99, breaking 
        #   everything.  This should work as long as the relative path is
        #   maintained  --Kester Allen
        #
	$command = "../../bin/ra2pixcgi.exe $result $coordtype";
	#$command = "D:\\usr\\users\\kepler\\bin\\ra2pixcgi.exe $result $coordtype";
#	$command = "/Library/WebServer/CGI-Executables/ra2pixcgi $result $coordtype";
        $ccdLocation = qx { $command };
	
     } else { 
# an error occured, show info debug the script
	 $command = '
RADECTYPE='.$RADECTYPE.'
RA='.$RA.'
DEC='.$DEC.'
RAHOURS='.$RAHOURS.'
RAMINUTES='.$RAMINUTES.'
RASECONDS='.$RASECONDS.'
DECDEGREES='.$DECDEGREES.'
DECMINUTES='.$DECMINUTES.'
DECSECONDS='.$DECSECONDS ;

	 $ccdLocation = "";
     }
}

if ( ! $FORM{"SEASON"} ) {
    $FORM{"SEASON"} = "0";
}

PrintForm ($command, $ccdLocation);

