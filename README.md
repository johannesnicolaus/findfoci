# Find foci

> ImageJ and R scripts used in the analysis of foci formation during NF-kB nuclear translocation in B-cells.
>
> Keywords: fluorescence microscopy, transcriptional regulation, transcription factor, NF-κB

---

## Prerequisites

- [FIJI distribution of ImageJ2](https://imagej.net/Fiji)
- [RStudio](https://rstudio.com/products/rstudio/download/#download) and [R](https://www.r-project.org/)

---

## Files

### ImageJ macro

ImageJ macro is available within the `ijmacro` directory. Detailed parameters of the ImageJ macro is explained in the pdf file located in the same directory.

### Raw data

Example raw data and ImageJ macro outputs are supplied within the `rawdata` and `imagej_output` directories respectively.

## Usage

### Foci counting using ImageJ

1. Download the following ImageJ macro: [link](https://github.com/johannesnicolaus/findfoci/raw/main/ijmacro/ijmacro.zip)
2. Open raw files using FIJI.
3. Open `focicount.ijm` within the `ijmacro.zip` using FIJI.
4. Edit the following parameters on the macro window for foci counting.
   - `diameterROI`: Diameter of the foci in pixel (default = 6)
   - `FMaxNoise` : Noise threshold under find maxima (default = 6000)
   - `diameterCell` : Diameter of the cells in pixel (default = 60)
   - `DotsMax` : Threshold for final foci counting from sharpened image (default = 10000)
5. Run macro (ctrl + R).
6. Specify output directory (preferably inside `imagej_output` directory).
7. Remove unwanted cells using mouse click.
8. Click OK and Continue to export the result files to the specified directory.

### Foci count analysis using RStudio

1. Install package

Requirements:

- shiny
- ggplot2
- dplyr

```R
devtools::install_github("johannesnicolaus/findfoci")
```

1. Run the following commands to summarize the number of foci within each cell and save the resulting data frame as `results.csv` to the current directory. Specify dose unit and time unit according to the file name.

```R
findfoci::count_foci("DIRECTORY_OF_IMAGEJ_OUTPUT", dose = "ugml", time = "min")
write.csv("results.csv")
```

2. Run the Shiny app for data visualization.

    ```R
    findfoci::heatscatter()
    ```

3. Using Shiny app interface, click the button browse and browse for the `results.csv` file.
4. Change different visualization parameters using the user interface of the Shiny app.
    - Data summarisation: choose how to summarize data for the line plot. (Default: median)
    - Jitter width : specifies the width of the jitter plot.
    - Data transformation method: choose how to transform the data for easier visualization. (Default: log2(n+1))
    - Plot title
    - Plot, X axis, and Y axis title
    - Y axis range

---

## Authors

- [Johannes Nicolaus Wibisana](https://jnicolaus.com) - *ImageJ Macro improvements, R package*
- Takehiko Inaba - *ImageJ Macro*

## License

This project is licensed under the MIT License - see the LICENSE.md file for details

## Acknowledgments

- Yasushi Sako (Cellular Informatics Laboratory, RIKEN) for discussions and improvements to the analysis.
