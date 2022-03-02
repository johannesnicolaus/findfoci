/////////////////////////////////////////////////////////////////////
// Open stack file > Stop at cell mask > Fix cell mask > OK + Loop > Make mask
// > OK + Continue > Use cell mask for foci recognition + save file + results 
// > Binary > options >  Black background ^ Checked


// Parameter has to be set depending on the magnification of the image

	diameterROI = 6; // diameter of the foci

	FMaxNoise = 6000; // noise threshold under find maxima 
		
	diameterCell = 60; // diameter of the cell (nuclei) ROI in pixel
	
	DotsMax	= 10000; // only foci higher than with max pixel value higher than 10000 is counted as foci (to ask)
		
	Fdir = getDirectory("Choose a Directory") ; // specify the output directory 	
	ori_ID = getTitle(); // get the title of the image

	

// main macro contains all processes
macro main {

	setOption("black background", true); // set black background

//	ori_ID = getTitle();

// Mask from Slice1-8 (Average)
	Slice1_8_Ave(); // get mask

// ROI manager > reset
	roiManager("reset");

// Mask > analyze particles > Result ON
	run("Select All");
	run("Analyze Particles...", "size=600-Infinity circularity=0.70-1.00 display exclude clear include add");


IJ.log("Check1");

//waitForUser("Wait for Check1"); 


// Find maxima on ROI manager
	selectWindow(ori_ID);
	run("Select All");
	FindMaxima_on_ROI();

// close all windows (uncomment line below to close all windows after running script)
//	close_all();

} // End of main function



//////////////////////////// Functions ////////////////////////////////////////

// Get the first 8 slices get average
function Slice1_8_Ave(){
	
	ori_ID = getTitle();
	
    // Get the average values for the first 8 slices
	run("Z Project...", "start=1 stop=8 projection=[Average Intensity]");

    // Perform gaussian blur with sigma 2
	run("Gaussian Blur...", "sigma=2");
	
    // Enhance contrast for visualization
	run("Enhance Contrast...", "saturated=0.3");

    // Perform background subtraction 
	run("Subtract Background...", "rolling=50 sliding");
	
    // Convert to 8-bit image
	run("8-bit");
	
    // Run auto local threshold
	run("Auto Local Threshold", "method=Mean radius=50 parameter_1=0 parameter_2=0 white");

    // Fill holes
	run("Fill Holes");

    // Run watershed segmentation
	run("Watershed");


	RemoveROI();
	
	rename("ROI Mask(Sli_1-8)_" + getTitle());

	ROI_Mask_Sli1to8_ID = getTitle();
	IJ.log("ROI_Mask_Sli1to8_ID : " +ROI_Mask_Sli1to8_ID); 


// Do-Loop (Correct Mask -> Loop or Continue?)

	do{

		selectWindow(ROI_Mask_Sli1to8_ID);

		IJ.log("do");
		Cell_ROI_Check(); // Loop untill Cell Mask completed
		setForegroundColor(0, 0, 0);
		setBackgroundColor(255, 255, 255);
		setTool("Flood Fill Tool");
		waitForUser("Correct The Cell Mask" + "\n" + "Select Mask image and OK");
		gBoo = getBoolean("Mask Check", "Loop Cell Mask", "Continue");
	
	} while (gBoo > 0);
	IJ.log("do-while end");



	selectWindow(ROI_Mask_Sli1to8_ID);
	saveAs("tiff", 	Fdir +File.separator+ getTitle()); // save the mask
	IJ.log("Save " + getTitle());

}



// Cell Mask > analyze particles > XYCenter + diameterROI circle > ori_ID
function Cell_ROI_Check(){

	ROI_Mask_ID = getTitle();

	run("Watershed");

// Mask > analyze particles > Result ON
	run("Select All");
	run("Analyze Particles...", "size=600-Infinity circularity=0.70-1.00 display exclude clear include add");
	IJ.log("Analyze Particles");

// FirstROI_x, y, nSli
	FirstROI_x = newArray();
	FirstROI_y = newArray();
	FirstROI_nSli = newArray();

// FirstROI_x, y, nSli loop
	for (i=0; i<nResults; i++) {

		FirstROI_x = Array.concat(FirstROI_x, getResult('XM', i));
		FirstROI_y = Array.concat(FirstROI_y, getResult('YM', i));
		FirstROI_nSli = Array.concat(FirstROI_nSli, getResult('Slice', i));
	}

	Array.show("CheckROI", FirstROI_x, FirstROI_y, FirstROI_nSli);

	IJ.renameResults("CheckROI_" + getTitle());

// ROI center (XM, YM) > diameterCell(= 60) Resize 
	selectWindow(ori_ID);
	ROItoCellROI(FirstROI_x, FirstROI_y, FirstROI_nSli);

	selectWindow(ROI_Mask_ID);
	
} // End of function
/////////////////////////////////////////////




/////////////////////////////////////////////////////
// Remove Edge objects, small and low circularity
function RemoveROI(){

	run("Select All");
	run("Duplicate...", " ");
	run("Analyze Particles...", "size=600-Infinity circularity=0.70-1.00 display exclude clear include add");
	run("Select All");
	setForegroundColor(0, 0, 0);
	run("Fill", "slice");
	roiManager("Show None");
	roiManager("Show All");
	setForegroundColor(255, 255, 255);
	roiManager("Fill");
	
} // End of function
//////////////////////////////////////////////////



////////////////////////////////////////
// Find foci on cell ROI
function FindMaxima_on_ROI(){

	run("Select None");

	OriImageID = getImageID();
	ori_ID = getTitle();
	IJ.log("ori_ID: "+ ori_ID);


// Produce the output of the X and Y coordinates on the results window。
// FirstROI_x, y, nSli
	FirstROI_x= newArray();
	FirstROI_y= newArray();
	FirstROI_nSli = newArray();

// FirstROI_x, y, nSli loop
	for (i=0; i<nResults; i++) {	//for (i=0; i<10; i++) {

		FirstROI_x = Array.concat(FirstROI_x, getResult('XM', i));
		FirstROI_y = Array.concat(FirstROI_y, getResult('YM', i));
		FirstROI_nSli = Array.concat(FirstROI_nSli, getResult('Slice', i)); 
	} // end for 

	Array.show("FirstROI", FirstROI_x, FirstROI_y, FirstROI_nSli);

	IJ.renameResults("FirstXY" + getTitle());

// ROI center (XM, YM) > diameterCell(= 60) Resize 
	ROItoCellROI(FirstROI_x, FirstROI_y, FirstROI_nSli);

// Gaussian Kernel image
	Convolv_ID = Gauss_Convolve();
	print(Convolv_ID);
// Save convolved image
	saveAs("tif", Fdir +File.separator+ getTitle());
	Convolv_ID = getTitle(); 

	ROI_Num = 0;
	roiManager("Select", ROI_Num);

// Find max on ROI manager ROI
	for(ROI_Num = 0; ROI_Num < roiManager("count") ; ROI_Num ++){

	// FMaxNoise is the max noise from find maxima (relayed to Noise argument of the FindMax function)
		FindMax(FMaxNoise, ROI_Num); 
	}
	
	IJ.log("FindMax nResults:"+ nResults);

// ROI manager > clear
		roiManager("Deselect");
		roiManager("Delete");
// FirstROI > Add at 6th Slice < Cell Circle
	for (k = 0; k < FirstROI_x.length; k++){
		setSlice(6);
		makeOval(FirstROI_x[k]-diameterCell/2, FirstROI_y[k]-diameterCell/2, diameterCell, diameterCell);
		roiManager("Add");

	}

// Write the coordinates (X, Y, Slice) of the findmax results onto array

	x= newArray();
	y= newArray();
	nSli = newArray();

	for (i=0; i<nResults; i++) {	//for (i=0; i<10; i++) {

		x = Array.concat(x, getResult('XM', i));
		y = Array.concat(y, getResult('YM', i));
		nSli = Array.concat(nSli, getResult('Slice', i));
	} // end for loop 

// Show x, y, nSli
	Array.show(x, y, nSli);

// (X, Y, nSli, diameterROI) > ROI manager > measure

	for (j = 0; j<i; j++){

 		selectImage(Convolv_ID);
		
		setSlice(nSli[j]);
		makeOval(x[j]-diameterROI/2, y[j]-diameterROI/2, diameterROI, diameterROI);

		getStatistics(GSarea, GSmean, GSmin, GSmax, GSstd, GShistogram);


		if(GSmax > DotsMax){
			print("over", GSmax);
			roiManager("Add");

		} else {

	
		}

	} // end for loop


	selectWindow("Results");
	run("Close");



// ROI manager > Stack (Convolv) > montage
 	selectImage(Convolv_ID);

	ori_IM = getTitle();

	ROItoStack(120);

	columns_Nm = 5;

	run("Enhance Contrast", "saturated=0.35");
	row = nSlices/5 +1;
	run("Make Montage...", "columns=" + columns_Nm +" rows=" + row  + " scale=1 font=20 label use");
	rename("Montage_" + ori_IM);
	saveAs("tif", Fdir +File.separator+ getTitle());
	selectWindow (ori_IM);

// ori_ID >ROI manager > All ROI  > Measure	

 	selectImage(ori_ID);

	roiManager("Deselect");
	roiManager("Show All");
	roiManager("Measure");

	run("Select None");

// Results rename 
	selectWindow("Results");

	ResName = ori_ID + "-roi-" + diameterROI +"-FMax-"+ FMaxNoise + "_" + DotsMax;
	
	IJ.renameResults(ResName);

// Save Results
	saveAs("Results", Fdir +File.separator+ ResName + ".csv");
// Save ROI.zip
	roiManager("Save", Fdir +File.separator+ ResName + ".zip");

}	// end FindMaxima_on_ROI()


////////////////////////////
// Apply Gaussian Kernel
function Gauss_Convolve() {

	run("Select All");

	run("Duplicate...", "duplicate");

	// GaussFit
	run("Convolve...", "text1=-0.09	-0.08	-0.07	-0.08	-0.09\n-0.08	0.05	0.28	0.05	-0.08\n-0.07	0.28	0.91	0.28	-0.07\n-0.08	0.05	0.28	0.05	-0.08\n-0.09	-0.08	-0.07	-0.08	-0.09\n stack"); 

	rename("Convolv_" + getTitle());

	return getTitle();
	
} // End of function
///////////////////////////


////////////////////////////////////////
// convert ROI to cell ROI (circular)
function ROItoCellROI(X_array, Y_array, Sli_array){

// ROI manager > reset
	roiManager("reset");

// FirstROI > Add at 6th Slice < Cell Circle
	for (k = 0; k < X_array.length; k++){
		// setSlice(6);
		makeOval(X_array[k]-diameterCell/2, Y_array[k]-diameterCell/2, diameterCell, diameterCell);
		roiManager("Add");
	}

	roiManager("Deselect");
	roiManager("Remove Slice Info");


} // End of function
////////////////////////////////////////


////////////////////////////////////
function FindMax(Noise, ROI_ID){
	// Zscan_Cell_Mask_Center();

	setSlice(1);

//	roiManager("Select", ROI_ID); 

// ROI manager (ROI_ID)でFind Maxima > Point > measure
	for(i = 0; i<nSlices; i++){

		roiManager("Select", ROI_ID); 
		 
		run("Find Maxima...", "noise="+Noise+" output=[Point Selection] exclude");

// Measure if Point selection == (10) --> point 
		if(selectionType() == 10){
			run("Measure");
		} // end if

		run("Next Slice [>]");
		
	} // End for

} // End function 
/////////////////////////////




///////////////////////////////////////////
// ROI Manager > select > Stack (120 pixs)
//
function ROItoStack(Image_size){
	
	Square = Image_size; // ROI size

	ROI_Num = roiManager("count");
	
	ori_ID = getTitle();
	run("Select All");
	
// Stack image
	newImage("particle_" + ori_ID, "16-bit black", Square, Square, roiManager("count"));	
	partID	= getImageID();
	
	  setBatchMode(true);	
	
	nSli_o = 0;

// Loop Results > ROIs > paste	
	for (i=0; i < ROI_Num; i++) {	//for (i=0; i<10; i++) {

		selectImage(ori_ID);
		roiManager("Select", i);
		run("Enlarge...", "enlarge=60");		
		run("Copy");
	
		selectImage(partID);
		setSlice(i+1);
		run("Paste");

	// Dot at Slice Change 
	
		run("Select All");
	}

	rename(getTitle + "_" + Image_size + "_" + ".tif"); 
	run("Enhance Contrast", "saturated=0.35");

	saveAs("tif", Fdir +File.separator+ getTitle());

	setBatchMode(false);

} // ROItoStack()
/// end of function


/// close all function
function close_all(){
close("*");
list = getList("window.titles");
     for (i=0; i<list.length; i++){
     winame = list[i];
      selectWindow(winame);
     run("Close");
     }
}
/// end of function


////////////////////////////////////
