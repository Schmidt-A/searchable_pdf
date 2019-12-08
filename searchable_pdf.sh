# run example:  bash searchable_pdf.sh input_path
#
# where input_path is a directory containing PDF files that need annotation
# converted documents will be put in a new annotated/ directory

input_path=$1
tmpdir=tmpdir
tessdatadir=/usr/local/share/tessdata
density=600
language=eng
outpath=annotated
directory_convert=0

help () {
    echo "Usage: ./searchable_pdf.sh [-d] INPUT_PATH"
    echo ""
    echo INPUT_PATH should be a PDF file for annotation.
    echo if -d is specified, INPUT_PATH is expected to be a directory of PDF files. Annotation will run on all files.
    exit $1
}

annotate_pdf () {
    infile=$1

    echo Annotating $infile...
    echo Splitting $infile into individual pages...
    pdftk $infile burst output $tmpdir/page_%03d.pdf
    if [ ${?} -ne 0 ]; then
        echo pdftk burst failed. Likely one of the following things happened:
        echo -e "\t - A directory was specified for INPUT_PATH without the -d flag;"
        echo -e "\t - An individual PDF file was specified for INPUT_PATH and -d was present;"
        echo -e "\t - INPUT_PATH does not exist."
        help 1
    fi
    imagetype="png"

    for file in $tmpdir/*.pdf
    do
        image=$file.$imagetype
        echo Converting $file to $image...
        convert -density $density $file $image
        rm $file

        echo Running Tesseract OCR on $image...
        tessoptions="--tessdata-dir "$tessdatadir" -l "$language" pdf quiet"
        tesseract $image $image $tessoptions
        rm $image
    done

    echo Rebuilding PDF document...
    pdftk $tmpdir/*.pdf cat output $tmpdir/tmp.pdf
    mv $tmpdir/tmp.pdf $outpath/`basename $infile`
    rm $tmpdir/*
    echo Done annotating $infile.
}

# Input is messed up if lingering tmp files are around (from a previously cancelled run, etc)
rm -rf tmpdir/
mkdir $tmpdir
mkdir -p $outpath

while getopts ":d:h" opt; do
    case $opt in
    d)
        directory_convert=1
        input_path="$OPTARG"
    ;;
    h) help 0
    ;;
    \?)
        echo "Invalid option -$OPTARG" >&2
        help 1
    ;;
    esac
done

if [ ${directory_convert} -eq 0 ]; then
    annotate_pdf $input_path
else
    for infile in $input_path/*.pdf
        do
        annotate_pdf "$infile"
    done
fi

rm -rf tmpdir/
