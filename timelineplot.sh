#!/bin/bash
#
# Make a simple line plot from a two-column file of time series data.
#
# Usage:
#
#   timeplot.sh <datafile> <plotout> [options]
#
#     <datafile>
#
#        Two-colum character delimited (default is "|") text file with 
#        time series data to be plotted. First column must be a date
#        parsable by strftime (default format is "%Y-%m-%d %H:%M:%S"). 
#        Second column must be numeric. The separator and time format
#        can be set to different values with command line options.
#        Use "-" to read data from a pipe.
#
#     <plotout>
#
#        File to use for the plot output (image). This file will be
#        overwritten if it already exists.
#
#
#   Optional arguments
#
#   For input
#
#     -sep <character>
#
#        Column separator for the input data file. Default is "|".
#        (The separator character should be enclosed in double quotes.)
#
#     -tfmt <format_string>
#
#        Format string describing the time format in the first column
#        of the input file. Default value is "%Y-%m-%d %H:%M:%S".
#
#   For output
#
#     -xfmt <format_string>
#
#        Format string to use for x-axis labels in the output plot.
#        Default value is "" (no labels).
#
#     -h <pixels>
#
#        Height of output image in pixels. Default is 300.
#
#     -w <pixels>
#
#        Width of output image in pixels. Default is 400.
#
#     -format <format>
#
#        Image format for the plot image. Default is "png". Other
#        choices include "svg", "jpeg", and "gif".
#
#     -title <string>
#
#        Title to associate with the y-axis data. Default value is "".
#
#     -linetitle <string>
#
#        Title to associate with the plotted line in a key. (Not terribly
#        useful since we're only plotting one line.) Default value is "".
#
#     -xlabel <string>
#
#        Label for x-axis. Default value is "".
#
#     -ylabel <string>
#
#        Label for y-axis. Default value is "".
#
#     -ymin <number>
#     -ymax <number>
#
#        Minimum and maximum values to use for y-axis. Useful if a constant
#        scale is needed. Default is for the plot to fit the data values.
#
#     -xrot <degrees>
#
#        Rotation angle for the timestamp labels on the x-axis tics. 
#        Default is 60.
#
#     -lc <color_expression>
#
#        Set the color of the line. Default value is "#0000FF".
#        Any value that gnuplot will accept after "rgbcolor" can be used
#        here (e.g. "red", "0xff0000", or "#ff0000").
#
#     -lw <pixels>
#
#        Set the line width in pixels. Default is 2.
#
#     -bgcolor <color_expression>
#
#        Set the color of the plot background. Default is "#FFFFFF".
#
#     -grid <"" | "xtics" | "ytics" | "noxtics noytics">
#
#        Set the background grid. Default is "".
#        "" - show full grid
#        "xtics" - only show gridlines parallel to x-axis
#        "ytics" - only show gridlines parallel to y-axis
#        "noxtics noytics" - no background grid
#
#     -gridcolor <color_expression>
#
#        Set the color of background grid lines. Default is "#B0B0B0".
#
#     -font <fontname>
#
#        Specify the font. Default is "arial".
#
#     -fontsize <number>
#
#        Specify the font size. Default is 12.
#
#     -fontcolor <color_expression>
#
#        Set the color of the fonts and borders. Default is "#000000".
#  
#

err=0
datafile="$1"
plotout="$2"
shift 2
while (( $# )); do
    case $1 in
      -sep) sep="$2"; shift 2
          ;;
      -tfmt) timefmt="$2"; shift 2
          ;;
      -xfmt) xtimefmt="$2"; shift 2
          ;;
      -h) height="$2"; shift 2
          ;;
      -w) width="$2"; shift 2
          ;;
      -format) format="$2"; shift 2
          ;;
      -title) title="$2"; shift 2
          ;;
      -linetitle) linetitle="$2"; shift 2
          ;;
      -xlabel) xlabel="$2"; shift 2
          ;;
      -ylabel) ylabel="$2"; shift 2
          ;;
      -ymin) ymin="$2"; shift 2
          ;;
      -ymax) ymax="$2"; shift 2
          ;;
      -xrot) xrot="$2"; shift 2
          ;;
      -lc) linecolor="$2"; shift 2
          ;;
      -lw) linewidth="$2"; shift 2
          ;;
      -bgcolor) bgcolor="$2"; shift 2
          ;;
      -grid) grid="$2"; shift 2
          ;;
      -gridcolor) gridcolor="$2"; shift 2
          ;;
      -font) font="$2"; shift 2
          ;;
      -fontsize) fontsize="$2"; shift 2
          ;;
      -fontcolor) fontcolor="$2"; shift 2
          ;;
      *) echo "Unexpected parameter: $1" 1>&2; ((err++)); shift
          ;;
    esac
done

# Set any unset variables to default values 
: ${sep:="|"}
: ${timefmt:="%Y-%m-%d %H:%M:%S"}
: ${xtimefmt:=""}
: ${height:=300}
: ${width:=400}
: ${format:="png"}
: ${title:=""}
: ${linetitle:=""}
: ${xlabel:=""}
: ${ylabel:=""}
: ${ymin:=""}
: ${ymax:=""}
: ${xrot:=60}
: ${linecolor:="#0000FF"}
: ${linewidth:=2}
: ${bgcolor:="#FFFFFF"}
: ${grid:=""}
: ${gridcolor:="#B0B0B0"}
: ${font:="arial"}
: ${fontsize:=12}
: ${fontcolor:="#000000"}

xtics_align="right"
[[ ${xrot} -eq 0 ]] && xtics_align="center"

# Handle piped input by creating a temp file
if [[ "${datafile}" == "-" ]]; then
    T=$(mktemp) 
    cat > $T
    datafile="$T"
fi

gnuplot << EOF > "${plotout}"
set datafile separator "${sep}"
set terminal ${format} size ${width},${height} font "${font},${fontsize}" background "${bgcolor}"
set title "${title}" tc "${fontcolor}"
set yrange [${ymin}:${ymax}]
set ylabel "${ylabel}" tc "${fontcolor}"
set xlabel "${xlabel}" tc "${fontcolor}"
set xdata time
set timefmt "${timefmt}" 
set format x "${xtimefmt}"
set xtics ${xtics_align} rotate by ${xrot} font "${font},${fontsize}" tc "${fontcolor}"
set ytics tc "${fontcolor}"
set border lc "${fontcolor}"
set key left top tc "${fontcolor}"
set grid ${grid} lc "${gridcolor}" # don't quote ${grid} since gnuplot won't like the empty quotes
plot "${datafile}" using 1:2 with lines lw ${linewidth} lt 1 lc rgbcolor "${linecolor}" title "${linetitle}"
EOF

# Delete the temp file if we created one
[[ -f "$T" ]] && rm -f "$T"
