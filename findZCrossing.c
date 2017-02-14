#include "mex.h"
#include <math.h>
#include <stdio.h>

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]);
int countCrosses(double* diffData, double* dataPr, int negPos, int n);
void createMatrix(double* dataOutPr, double* dataPr, int count, int negPos);

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
	double* dataPr;
	double* dataOutPr;
	int crosses;
	int dataPoints;
	int rows;
	int cols;
	int negPos;
	double diffData[2000];
	
	/*I only want 2 input matrix*/
	if(nrhs != 2){
		mexErrMsgIdAndTxt("MyToolbox:ipTesting:nrs","This function requires 2 inputs");
	}
	rows = (int)mxGetM(prhs[0]); /*Get the number of rows and columns of data matrix*/
	cols = (int)mxGetN(prhs[0]);
	dataPoints = rows*cols;
	
	/*Obtaining the pointers for the input*/
	dataPr = mxGetPr(prhs[0]); /*Input 1 - Data coming in*/
	negPos = mxGetScalar(prhs[1]); /*Input 2 - option for maxes or mins*/
	
	crosses = countCrosses(diffData,dataPr,negPos,dataPoints);
	
		/*I only have one output, so plhs[0] is the only output*/
	plhs[0] = mxCreateDoubleMatrix(crosses,1,mxREAL);
	dataOutPr = mxGetPr(plhs[0]);
	
	createMatrix(dataOutPr, dataPr, dataPoints, negPos);
}

int countCrosses(double* diffData, double* dataPr, int negPos, int n)
{
	int i;
	int count = 0;
	
	i=0;
	diffData[i]=0.0;
	for(i=1; i<n; i++){
		diffData[i]=dataPr[i]-dataPr[i-1];
		if(negPos){
			if((dataPr[i-1]>0)&&(dataPr[i]<=0)){
				count++;
			}
		}
		else{
			if((dataPr[i-1]<0)&&(dataPr[i]>=0)){
				count++;
			}
		}
	}
	return count;
}

void createMatrix(double* dataOutPr, double* dataPr, int count, int negPos)
{
	int i;
	int count2 = 0;
	
	i=0;
	for(i=1; i<count; i++){
		if(negPos){
			if((dataPr[i-1]>0)&&(dataPr[i]<=0)){
				dataOutPr[count2] = (double)(i+1);
				count2++;
			}
		}
		else{
			if((dataPr[i-1]<0)&&(dataPr[i]>=0)){
				dataOutPr[count2] = (double)(i+1);
				count2++;
			}
		}
	}
}