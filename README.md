# Matlab-codes-for-FM-image-analysis
This is a series of Matlab codes for the analysis of mouse whole retinal pigment epithelium (RPE) flatmount image.

The purpose of the study is to segment the whole RPE flatmount image into individual cells and perform various morphometric analyses.

The whole RPE flatmount image (example images can be found at http://cellimagelibrary.org/groups/52245) should be trimmed manually using Photoshop (Adobe Photoshop CS2; Adobe, San Jose, CA).

The image is binarized into cell borders and background by machine learning based methods (for example, the ImageJ plugin 'Trainable Weka Segmentation', 'ilastik', etc.).

Then these codes can be applied serially to the binarized image.


Code #1 - make skeletonized image and remove missegmented cells

Code #2 - Graphical User Interface for manual cell selection (made by Matlab app designer)

Code #3 - Morphometric analysis of individual cells according to the distance from the center of the optic disc. The result is exported as an Excel file.

Code #4 - Preparing for the Principal Component Analysis (PCA). All image data are combined together into a single array.

Code #5 - PCA and plotting. PCA is performed on different age groups and regional zones using various morphometric features of the cell.

Code #6 - Linear Discriminant Analysis (LDA). LDA is performed to evaluate whether morphometric features can be used to classify cells from different regions or age groups. 



