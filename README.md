# searchable_pdf

Uses PDFtk, ImageMagick, and Tesseract OCR and to annotate PDF files. Makes image/scanned/etc PDF files searchable.

## Motivation

I had to work with a large set of scanned paper documentation (we're talking thousands of pages) that were not at all searchable. I wanted to fix this but I ran into a couple roadblocks:
 * Commercial OCR annotation options exist (Adobe Acrobat, etc) but I didn't have access to any paid options like this.
 * Online submit-and-email annotation services do exist but due to the sensitive nature of the documents, it would have been a breach in contract to have them sent to third-party servers.

I figured there had to be some way to annotate the documents for free on my local workstation.

## Approach

The tools used have a couple limitations: Tesseract operates on images rather than PDF files, and ImageMagick can convert PDFs to PNGs but requires a single page as input. To solve this I took the following approach:
 1. Use PDFtk to split PDF document pages into single-page temporary PDF files;
 2. Loop over the single-page PDF files and use ImageMagick's `convert` to convert them to PNGs;
 3. Use Tesseract to perform OCR on the image, outputting a searchable single-page PDF;
 4. Once all pages are annotated, use PDFtk to rebuild a searchable PDF file from the individual pages.

## Setup Requirements

The script has the following dependencies that need to be installed first:
 * [PDFtk Server](https://www.pdflabs.com/tools/pdftk-server/)
 * [ImageMagick](https://imagemagick.org/script/download.php)
 * [Tesseract OCR](https://opensource.google/projects/tesseract) (script expects Tesseract data to be in `/usr/local/share/tessdata`)

## Usage

```
./searchable_pdf.sh [-d] INPUT_PATH
```
Where `INPUT_PATH` is the PDF file to be annotated.
If `-d` is specified, `INPUT_PATH` will accept a directory and all PDF files in the directory will be annotated.

## Issues

* Very slow. If you're annotating a large document, start the annotation and then plan to leave it alone for a while.
* Doesn't play nicely with files containing special characters in their file name.
* The converted PNG file doesn't properly have its dpi metadata set so Tesseract OCR complains/defaults dpi setting to 70. I currently have Tesseract output set to `quiet` so that it doesn't spam stdout.
* Hard-coded paths (`annotated/` output directory, etc.) This was sufficient for my needs at the time.

## Author

Allisa Schmidt

## License

This project is licensed under the MIT License - see LICENSE.md for details.